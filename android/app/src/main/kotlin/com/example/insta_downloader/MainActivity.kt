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
        private const val FOLDER_NAME = "Insta Downloader"
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
                        call.argument<ByteArray>("file")!!,
                        call.argument<String>("name")!!,
                        call.argument<Int>("type")!!
                    )
                )
                GET -> result.success(get(call.argument<String>("path")!!))
                CHECK -> result.success(check(call.argument<String>("path")!!))
                SHARE-> share(call.argument<List<String>>("paths")!!)
                DELETE -> delete(call.argument<List<String>>("paths")!!)
                else -> result.notImplemented()
            }
        }
    }

    private fun check(path: String): Boolean {
        val resolver = context.contentResolver
        try {
            resolver.openInputStream(Uri.parse(path))
        } catch (e: FileNotFoundException) {
            return false
        }
        return true
    }

    private fun get(path: String): ByteArray? {
        val resolver = context.contentResolver
        try {
            resolver.openInputStream(Uri.parse(path)).use {
                return it!!.readBytes()
            }
        } catch (e: FileNotFoundException) {
            return null
        }
    }

    private fun save(file: ByteArray, name: String, type: Int): String? {

        val resolver = context.contentResolver

        if (Build.VERSION.SDK_INT >= 29) {

            val values = ContentValues().apply {
                put(MediaStore.MediaColumns.DISPLAY_NAME, name)
                if (type == 2) {
                    put(MediaStore.MediaColumns.MIME_TYPE, "video/mp4")
                    put(
                        MediaStore.MediaColumns.RELATIVE_PATH,
                        Environment.DIRECTORY_MOVIES + File.separator + FOLDER_NAME
                    )
                } else {
                    put(MediaStore.MediaColumns.MIME_TYPE, "image/jpeg")
                    put(
                        MediaStore.MediaColumns.RELATIVE_PATH,
                        Environment.DIRECTORY_PICTURES + File.separator + FOLDER_NAME
                    )
                }

                put(MediaStore.MediaColumns.IS_PENDING, true)
            }

            val uri = if (type == 2)
                resolver.insert(MediaStore.Video.Media.EXTERNAL_CONTENT_URI, values)
            else
                resolver.insert(MediaStore.Images.Media.EXTERNAL_CONTENT_URI, values)

            try {
                val fos = resolver.openOutputStream(uri!!)

                fos!!.write(file)
                fos.close()

                values.put(MediaStore.MediaColumns.IS_PENDING, false)

                resolver.update(uri, values, null, null)
            } catch (e: Exception) {
                uri?.let {
                    resolver.delete(it, null, null)
                }
                return "uri is null"
            }

            return uri.toString()

        } else {
            // TODO below ANDROID
            //below A10
            return null
        }

    }

    private fun share(paths: List<String>) {
        val pathsOutStream : ArrayList<Uri> = arrayListOf()
        for (i in paths) {
            pathsOutStream.add(Uri.parse(i))
        }

        val shareIntent = Intent().apply {
            action = Intent.ACTION_SEND_MULTIPLE
            putParcelableArrayListExtra(Intent.EXTRA_STREAM, pathsOutStream)
            type = "*/*"
        }
        startActivity(Intent.createChooser(shareIntent, "Share files to.."))

    }

    private fun delete(paths: List<String>) {
        val resolver = context.contentResolver

        for(i in paths) {
            resolver.delete(Uri.parse(i), null, null)
        }
    }
}
