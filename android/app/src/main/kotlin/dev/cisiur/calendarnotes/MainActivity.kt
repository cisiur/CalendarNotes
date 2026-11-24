package dev.cisiur.calendarnotes

import android.content.Intent
import android.net.Uri
import android.provider.DocumentsContract
import android.provider.OpenableColumns
import android.util.Base64
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import java.security.MessageDigest

class MainActivity : FlutterActivity() {
    companion object {
        private const val channelName = "dev.cisiur.calendarnotes/exchange_folder"
        private const val requestOpenDocumentTree = 9202
        private const val preferencesName = "calendar_notes_exchange_folder"
        private const val selectedTreeKey = "selected_tree_uri"
    }

    private var pendingFolderResult: MethodChannel.Result? = null

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, channelName)
            .setMethodCallHandler { call, result -> handleCall(call, result) }
    }

    private fun handleCall(call: MethodCall, result: MethodChannel.Result) {
        try {
            when (call.method) {
                "checkAccess" -> result.success(accessStatus())
                "selectFolder" -> selectFolder(result)
                "listOwnTestFiles" -> result.success(listOwnFiles(requiredPrefix(call)))
                "writeOnce" -> result.success(writeOnce(call, requiredPrefix(call)))
                "readAndVerify" -> result.success(readAndVerify(call, requiredPrefix(call)))
                "deleteOwnTestFile" -> result.success(deleteOwnTestFile(call, requiredPrefix(call)))
                else -> result.notImplemented()
            }
        } catch (error: Exception) {
            result.error("EXCHANGE_FOLDER", error.message, null)
        }
    }

    private fun selectFolder(result: MethodChannel.Result) {
        if (pendingFolderResult != null) {
            result.error("SELECTION_IN_PROGRESS", "Wybór folderu jest już otwarty.", null)
            return
        }
        pendingFolderResult = result
        val intent = Intent(Intent.ACTION_OPEN_DOCUMENT_TREE).apply {
            addFlags(Intent.FLAG_GRANT_READ_URI_PERMISSION)
            addFlags(Intent.FLAG_GRANT_WRITE_URI_PERMISSION)
            addFlags(Intent.FLAG_GRANT_PERSISTABLE_URI_PERMISSION)
            addFlags(Intent.FLAG_GRANT_PREFIX_URI_PERMISSION)
        }
        startActivityForResult(intent, requestOpenDocumentTree)
    }

    @Deprecated("Activity result is required for the SAF chooser on the min SDK.")
    override fun onActivityResult(requestCode: Int, resultCode: Int, data: Intent?) {
        super.onActivityResult(requestCode, resultCode, data)
        if (requestCode != requestOpenDocumentTree) return

        val result = pendingFolderResult ?: return
        pendingFolderResult = null
        val uri = data?.data
        if (resultCode != RESULT_OK || uri == null) {
            result.success(accessStatus())
            return
        }
        try {
            val flags = (data?.flags ?: 0) and
                (Intent.FLAG_GRANT_READ_URI_PERMISSION or Intent.FLAG_GRANT_WRITE_URI_PERMISSION)
            contentResolver.takePersistableUriPermission(uri, flags)
            preferences().edit().putString(selectedTreeKey, uri.toString()).apply()
            result.success(accessStatus())
        } catch (error: SecurityException) {
            result.error("PERSIST_PERMISSION", error.message, null)
        }
    }

    private fun accessStatus(): Map<String, Any?> {
        val treeUri = selectedTreeUri()
            ?: return status(false, false, false, false, null, null, "Nie wybrano folderu wymiany.")
        val permission = contentResolver.persistedUriPermissions.any {
            it.uri == treeUri && it.isReadPermission && it.isWritePermission
        }
        if (!permission) {
            return status(false, false, false, false, treeUri, treeUri.authority,
                "Uprawnienie SAF zostało cofnięte lub nie obejmuje odczytu i zapisu.")
        }
        return try {
            contentResolver.query(childrenUri(treeUri), arrayOf(DocumentsContract.Document.COLUMN_DOCUMENT_ID),
                null, null, null)?.use { }
                ?: throw IllegalStateException("Provider nie pozwala wyświetlić zawartości drzewa.")
            status(true, true, true, true, treeUri, treeUri.authority, null)
        } catch (error: Exception) {
            status(true, false, false, false, treeUri, treeUri.authority,
                "Folder SAF jest niedostępny: ${error.message}")
        }
    }

    private fun status(
        selected: Boolean,
        readable: Boolean,
        writable: Boolean,
        listable: Boolean,
        uri: Uri?,
        provider: String?,
        error: String?,
    ) = mapOf(
        "isSelected" to selected,
        "canRead" to readable,
        "canWrite" to writable,
        "canList" to listable,
        "uri" to uri?.toString(),
        "provider" to provider,
        "error" to error,
    )

    private fun listOwnFiles(prefix: String): List<Map<String, Any>> {
        return childDocuments().mapNotNull { document ->
            val name = document.displayName ?: return@mapNotNull null
            if (!name.startsWith(prefix)) return@mapNotNull null
            mapOf("name" to name, "sizeBytes" to document.size)
        }.sortedBy { it["name"] as String }
    }

    private fun writeOnce(call: MethodCall, prefix: String): Map<String, Any> {
        val name = requiredName(call, prefix)
        if (findDocument(name) != null) {
            throw IllegalStateException("Plik testowy już istnieje: $name")
        }
        val encodedContents = call.argument<String>("contents")
            ?: throw IllegalArgumentException("Brak danych pliku testowego.")
        val contents = Base64.decode(encodedContents, Base64.DEFAULT)
        val expected = call.argument<String>("expectedSha256")
            ?: throw IllegalArgumentException("Brak oczekiwanej sumy SHA-256.")
        val actual = sha256(contents)
        if (actual != expected) {
            throw IllegalArgumentException("Suma SHA-256 danych wejściowych jest nieprawidłowa.")
        }
        val documentUri = DocumentsContract.createDocument(
            contentResolver,
            treeDocumentUri(selectedTreeUriOrThrow()),
            "application/json",
            name,
        ) ?: throw IllegalStateException("Provider SAF nie utworzył pliku testowego.")
        try {
            contentResolver.openOutputStream(documentUri, "w")?.use { output ->
                output.write(contents)
                output.flush()
            } ?: throw IllegalStateException("Provider SAF nie otworzył pliku do zapisu.")
        } catch (error: Exception) {
            DocumentsContract.deleteDocument(contentResolver, documentUri)
            throw error
        }
        return mapOf("name" to name, "sizeBytes" to contents.size, "sha256" to actual)
    }

    private fun readAndVerify(call: MethodCall, prefix: String): Map<String, Any> {
        val name = requiredName(call, prefix)
        val expected = call.argument<String>("expectedSha256")
            ?: throw IllegalArgumentException("Brak oczekiwanej sumy SHA-256.")
        val document = findDocument(name)
            ?: throw IllegalStateException("Nie znaleziono pliku testowego: $name")
        val contents = contentResolver.openInputStream(document.uri)?.use { it.readBytes() }
            ?: throw IllegalStateException("Provider SAF nie otworzył pliku do odczytu.")
        val actual = sha256(contents)
        return mapOf(
            "name" to name,
            "sizeBytes" to contents.size,
            "actualSha256" to actual,
            "hashMatches" to (actual == expected),
        )
    }

    private fun deleteOwnTestFile(call: MethodCall, prefix: String): Map<String, Any> {
        val name = requiredName(call, prefix)
        val document = findDocument(name) ?: return mapOf("name" to name, "deleted" to false)
        val deleted = DocumentsContract.deleteDocument(contentResolver, document.uri)
        return mapOf("name" to name, "deleted" to deleted)
    }

    private fun requiredPrefix(call: MethodCall): String =
        call.argument<String>("prefix")?.takeIf { it.startsWith("calendarnotes-diagnostic-") }
            ?: throw IllegalArgumentException("Brak lub nieprawidłowy prefiks diagnostyczny.")

    private fun requiredName(call: MethodCall, prefix: String): String {
        val name = call.argument<String>("name")
            ?: throw IllegalArgumentException("Brak nazwy pliku testowego.")
        if (!name.startsWith(prefix) || name.contains('/') || name.contains('\\') || name.contains("..")) {
            throw IllegalArgumentException("Niedozwolona nazwa pliku testowego.")
        }
        return name
    }

    private fun selectedTreeUri(): Uri? = preferences().getString(selectedTreeKey, null)?.let(Uri::parse)

    private fun selectedTreeUriOrThrow(): Uri = selectedTreeUri()
        ?: throw IllegalStateException("Nie wybrano folderu wymiany.")

    private fun preferences() = getSharedPreferences(preferencesName, MODE_PRIVATE)

    private fun childrenUri(treeUri: Uri): Uri = DocumentsContract.buildChildDocumentsUriUsingTree(
        treeUri,
        DocumentsContract.getTreeDocumentId(treeUri),
    )

    private fun treeDocumentUri(treeUri: Uri): Uri = DocumentsContract.buildDocumentUriUsingTree(
        treeUri,
        DocumentsContract.getTreeDocumentId(treeUri),
    )

    private fun findDocument(name: String): ChildDocument? = childDocuments().firstOrNull {
        it.displayName == name
    }

    private fun childDocuments(): List<ChildDocument> {
        val treeUri = selectedTreeUriOrThrow()
        val documents = mutableListOf<ChildDocument>()
        contentResolver.query(
            childrenUri(treeUri),
            arrayOf(
                DocumentsContract.Document.COLUMN_DOCUMENT_ID,
                OpenableColumns.DISPLAY_NAME,
                OpenableColumns.SIZE,
            ),
            null,
            null,
            null,
        )?.use { cursor ->
            val idColumn = cursor.getColumnIndexOrThrow(DocumentsContract.Document.COLUMN_DOCUMENT_ID)
            val nameColumn = cursor.getColumnIndexOrThrow(OpenableColumns.DISPLAY_NAME)
            val sizeColumn = cursor.getColumnIndexOrThrow(OpenableColumns.SIZE)
            while (cursor.moveToNext()) {
                val documentId = cursor.getString(idColumn)
                documents.add(
                    ChildDocument(
                        uri = DocumentsContract.buildDocumentUriUsingTree(treeUri, documentId),
                        displayName = cursor.getString(nameColumn),
                        size = if (cursor.isNull(sizeColumn)) 0 else cursor.getLong(sizeColumn),
                    ),
                )
            }
        } ?: throw IllegalStateException("Provider SAF nie pozwala wyświetlić zawartości folderu.")
        return documents
    }

    private fun sha256(contents: ByteArray): String = MessageDigest.getInstance("SHA-256")
        .digest(contents)
        .joinToString("") { byte -> "%02x".format(byte) }

    private data class ChildDocument(val uri: Uri, val displayName: String?, val size: Long)
}
