package com.example.insta_downloader

import android.content.Intent
import android.os.Environment
import android.util.Log
import androidx.annotation.NonNull
import androidx.annotation.UiThread
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel


class MainActivity : FlutterActivity() {
    companion object {
        private const val CHANNEL = "com.example.insta_downloader/folder"
        private const val FOLDER_PICKER = "folderPicker"
        private const val DOWNLOAD_PATH = "downloadPath"
        private const val REQUEST_CODE = 9999
    }

    private var result: MethodChannel.Result? = null

    override fun configureFlutterEngine(@NonNull flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL).setMethodCallHandler { call, result ->
            when (call.method) {
                FOLDER_PICKER -> {
                    if (android.os.Build.VERSION.SDK_INT >= android.os.Build.VERSION_CODES.LOLLIPOP) {
                        val i = Intent(Intent.ACTION_OPEN_DOCUMENT_TREE)
                        i.addCategory(Intent.CATEGORY_DEFAULT)
                        startActivityForResult(Intent.createChooser(i, "Choose directory"), REQUEST_CODE)
                    }
                    this.result = result
                }
                DOWNLOAD_PATH -> result.success(getDownloadsDirectory())
                else -> result.notImplemented()
            }
        }
    }

    @UiThread
    fun success(temp: String) {
        result!!.success(getRealPath(temp))
    }


    override fun onActivityResult(requestCode: Int, resultCode: Int, data: Intent?) {
        super.onActivityResult(requestCode, resultCode, data)
        when (requestCode) {
            REQUEST_CODE -> {
                if (data != null) success(data!!.getData()!!.getPath()!!)
                else result!!.error("UNAVAILABLE", "Cancelled", null)
            }
        }
    }

    private fun getDownloadsDirectory(): String? {
        return Environment.getExternalStoragePublicDirectory(Environment.DIRECTORY_DOWNLOADS).getAbsolutePath()
    }


    fun getRealPath(path: String): String {
        if (path.startsWith("/tree/")) {
            val path2 = path.removePrefix("/tree/")
            if (path2.startsWith("primary:")) {
                val path3 = path2.removePrefix("primary:")
                return "/storage/emulated/0/$path3"
            } else {
                val path3 = path2.replace(":", "/")
                return path3
            }
        }
        return path
    }


}
