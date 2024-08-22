package com.example.c001apk.flutter

import android.app.DownloadManager
import android.content.Context
import android.content.pm.ApplicationInfo
import android.content.pm.PackageInfo
import android.content.pm.PackageManager
import android.graphics.Bitmap
import android.graphics.Canvas
import android.graphics.drawable.BitmapDrawable
import android.graphics.drawable.Drawable
import android.net.Uri
import android.os.Build.VERSION.SDK_INT
import android.os.Build.VERSION_CODES.P
import android.os.Environment
import android.webkit.MimeTypeMap;
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel
import java.io.ByteArrayOutputStream

class MainActivity: FlutterActivity(){
    private val CHANNEL = "samples.flutter.dev/channel"

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL).setMethodCallHandler {
            call, result ->
            if (call.method == "getInstalledApps") {
                Thread {
                    result.success(getInstalledApps())
                }.start()
            } else if (call.method == "downloadApk") {
                val url= call.argument<String>("url")
                val name = call.argument<String>("name")
                if(url != null && name != null){
                    val response = downloadApk(url, name)
                    result.success(response)
                } else {
                    result.success(false)
                }
            } else {
                result.notImplemented()
            }
        }
    }

    private fun downloadApk(url: String, name: String): Boolean {
        try{
            val mimeType = MimeTypeMap.getSingleton().getMimeTypeFromExtension(MimeTypeMap.getFileExtensionFromUrl(url))
            val downloadManager = getSystemService(Context.DOWNLOAD_SERVICE) as DownloadManager
            val request = DownloadManager
            .Request(Uri.parse(url))
            .setMimeType(mimeType)
            .setTitle(name)
            .setNotificationVisibility(DownloadManager.Request.VISIBILITY_VISIBLE_NOTIFY_COMPLETED)
            .setDestinationInExternalPublicDir(Environment.DIRECTORY_DOWNLOADS, name)
            if (SDK_INT < 29) {
                request.allowScanningByMediaScanner()
                request.setVisibleInDownloadsUi(true)
            }
            downloadManager.enqueue(request)
            return true
        } catch(e: Exception) {
            return false
        }
    }

    private fun getInstalledApps(): List<Map<String, Any?>> {
        var appList = packageManager.getInstalledApplications(0).filter { info -> 
            (info.flags and ApplicationInfo.FLAG_SYSTEM) != ApplicationInfo.FLAG_SYSTEM
         }
        return appList.map { info ->
            val packageInfo = packageManager.getPackageInfo(info.packageName, 0)
            mapOf(
                "icon" to drawableToByteArray(info.loadIcon(packageManager)),
                "appName" to packageManager.getApplicationLabel(info),
                "packageName" to info.packageName,
                "versionName" to packageInfo.versionName,
                "versionCode" to getVersionCode(packageInfo).toString(),
                "lastUpdateTime" to packageInfo.lastUpdateTime.toString(),
            )
        }
    }

    private fun drawableToByteArray(drawable: Drawable): ByteArray {
        val bitmap = drawableToBitmap(drawable)
        ByteArrayOutputStream().use { stream ->
            bitmap.compress(Bitmap.CompressFormat.PNG, 100, stream)
            return stream.toByteArray()
        }
    }

    private fun drawableToBitmap(drawable: Drawable): Bitmap {
        if (drawable is BitmapDrawable) {
            return drawable.bitmap
        }
        val bitmap = Bitmap.createBitmap(
            drawable.intrinsicWidth,
            drawable.intrinsicHeight,
            Bitmap.Config.ARGB_8888
        )
        val canvas = Canvas(bitmap)
        drawable.setBounds(0, 0, canvas.width, canvas.height)
        drawable.draw(canvas)
        return bitmap
    }

    private fun getVersionCode(packageInfo: PackageInfo): Long {
        return if (SDK_INT < P) packageInfo.versionCode.toLong()
        else packageInfo.longVersionCode
    }

}
