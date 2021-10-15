package com.example.insta_downloader

import android.content.ContentValues
import android.content.Intent
import android.net.Uri
import android.os.Build
import android.os.Environment
import android.provider.MediaStore
import androidx.annotation.NonNull
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel
import java.io.File
import java.io.FileNotFoundException


class MainActivity : FlutterActivity() {
    companion object {
        private const val CHANNEL = "com.example.insta_downloader/folder"
        private const val SAVE = "save"
        private const val GET = "get"
        private const val CHECK = "check"
        private const val SHARE = "share"
        private const val DELETE = "delete"
        private const val DELETE_SINGLE = "delete_single"
        private const val FOLDER_NAME = "Insta Downloader"
        private const val SDK = "get_sdk"
        private const val PATH = "path"
    }

    override fun configureFlutterEngine(@NonNull flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        MethodChannel(
            flutterEngine.dartExecutor.binaryMessenger,
            CHANNEL
        ).setMethodCallHandler { call, result ->
            when (call.method) {
                SAVE -> result.success(
                    save(
                        call.argument<ByteArray>("byte_array")!!,
                        call.argument<String>("name")!!,
                        call.argument<Int>("file_type")!!
                    )
                )
                GET -> result.success(get(call.argument<String>("uri")!!))
                CHECK -> result.success(check(call.argument<String>("uri")!!))
                SHARE -> share(call.argument<List<String>>("uris")!!)
                DELETE -> delete(call.argument<List<String>>("uris")!!)
                DELETE_SINGLE -> deleteSingle(call.argument<String>("uri")!!, result)
                SDK -> result.success(getVersionSdk())
                PATH -> result.success(getPath())
                else -> result.notImplemented()
            }
        }
    }

    private fun check(uri: String): Boolean {
        val resolver = context.contentResolver
        try {
            resolver.openInputStream(Uri.parse(uri))
        } catch (e: FileNotFoundException) {
            return false
        }
        return true
    }

    private fun get(uri: String): ByteArray? {
        val resolver = context.contentResolver
        try {
            resolver.openInputStream(Uri.parse(uri)).use {
                return it!!.readBytes()
            }
        } catch (e: FileNotFoundException) {
            return null
        }
    }

    private fun save(byteArray: ByteArray, name: String, type: Int): String? {
        //Type
        //1 - Image
        //2 - Video

        val resolver = context.contentResolver

        var dir =
            File(Environment.getExternalStoragePublicDirectory(Environment.DIRECTORY_PICTURES).absolutePath + File.separator + FOLDER_NAME)
        if (!dir.exists())
            dir.mkdir()

        dir =
            File(Environment.getExternalStoragePublicDirectory(Environment.DIRECTORY_MOVIES).absolutePath + File.separator + FOLDER_NAME)
        if (!dir.exists())
            dir.mkdir()

        val values = ContentValues().apply {
            put(MediaStore.MediaColumns.DISPLAY_NAME, name)
            if (type == 2) {
                put(MediaStore.MediaColumns.MIME_TYPE, "video/mp4")
                if (getVersionSdk() < 29)
                    put(
                        MediaStore.MediaColumns.DATA,
                        Environment.getExternalStoragePublicDirectory(Environment.DIRECTORY_MOVIES).absolutePath + File.separator + FOLDER_NAME + File.separator + name + ".mp4"
                    )
                else
                    put(
                        MediaStore.MediaColumns.RELATIVE_PATH,
                        Environment.DIRECTORY_MOVIES + File.separator + FOLDER_NAME
                    )
            } else {
                put(MediaStore.MediaColumns.MIME_TYPE, "image/jpeg")
                if (getVersionSdk() < 29)
                    put(
                        MediaStore.MediaColumns.DATA,
                        Environment.getExternalStoragePublicDirectory(Environment.DIRECTORY_PICTURES).absolutePath + File.separator + FOLDER_NAME + File.separator + name + ".jpg"
                    )
                else
                    put(
                        MediaStore.MediaColumns.RELATIVE_PATH,
                        Environment.DIRECTORY_PICTURES + File.separator + FOLDER_NAME
                    )
            }
            if (getVersionSdk() >= 29)
                put(MediaStore.MediaColumns.IS_PENDING, true)
        }

        val uri = if (type == 2)
            resolver.insert(MediaStore.Video.Media.EXTERNAL_CONTENT_URI, values)
        else
            resolver.insert(MediaStore.Images.Media.EXTERNAL_CONTENT_URI, values)

        try {
            val fos = resolver.openOutputStream(uri!!)

            fos!!.write(byteArray)
            fos.close()

            if (getVersionSdk() >= 29) {
                values.put(MediaStore.MediaColumns.IS_PENDING, false)
                resolver.update(uri, values, null, null)
            }

        } catch (e: Exception) {
            uri?.let {
                resolver.delete(it, null, null)
            }
            e.stackTrace
            e.message
            return "uri is null"
        }

        return uri.toString()

    }

    private fun share(uris: List<String>) {
        val urisOutStream: ArrayList<Uri> = arrayListOf()
        for (i in uris) {
            urisOutStream.add(Uri.parse(i))
        }

        val shareIntent = Intent().apply {
            action = Intent.ACTION_SEND_MULTIPLE
            putParcelableArrayListExtra(Intent.EXTRA_STREAM, urisOutStream)
            type = "*/*"
        }
        startActivity(Intent.createChooser(shareIntent, "Share files to.."))

    }

    private fun delete(uris: List<String>) {
        val resolver = context.contentResolver
        for (i in uris) {
            resolver.delete(Uri.parse(i), null, null)
        }
    }

    private fun deleteSingle(uri: String, result: MethodChannel.Result) {
        val resolver = context.contentResolver
        resolver.delete(Uri.parse(uri), null, null)
        result.success("")
    }

    private fun getVersionSdk(): Int {
        return Build.VERSION.SDK_INT
    }

    private fun getPath(): String {
        return context.getExternalFilesDir(null)!!.absolutePath
    }
}
