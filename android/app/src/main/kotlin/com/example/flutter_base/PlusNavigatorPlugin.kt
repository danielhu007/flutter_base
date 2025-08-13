package com.example.flutter_base

import android.app.Activity
import android.graphics.Color
import android.os.Build
import android.view.View
import android.view.Window
import android.view.WindowManager
import androidx.annotation.NonNull
import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.embedding.engine.plugins.activity.ActivityAware
import io.flutter.embedding.engine.plugins.activity.ActivityPluginBinding
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.MethodChannel.MethodCallHandler
import io.flutter.plugin.common.MethodChannel.Result

/** PlusNavigatorPlugin */
class PlusNavigatorPlugin: FlutterPlugin, MethodCallHandler, ActivityAware {
  /// The MethodChannel that will the communication between Flutter and native Android
  ///
  /// This local reference serves to register the plugin with the Flutter Engine and unregister it
  /// when the Flutter Engine is detached from the Activity
  private lateinit var channel : MethodChannel
  private var activity: Activity? = null

  override fun onAttachedToEngine(@NonNull flutterPluginBinding: FlutterPlugin.FlutterPluginBinding) {
    channel = MethodChannel(flutterPluginBinding.binaryMessenger, "plus_navigator")
    channel.setMethodCallHandler(this)
  }

  override fun onMethodCall(@NonNull call: MethodCall, @NonNull result: Result) {
    android.util.Log.d("PlusNavigatorPlugin", "Method called: ${call.method}")
    when (call.method) {
      "getStatusbarHeight" -> {
        val statusBarHeight = getStatusBarHeight()
        android.util.Log.d("PlusNavigatorPlugin", "getStatusbarHeight result: $statusBarHeight")
        result.success(statusBarHeight)
      }
      "setStatusBarBackground" -> {
        val colorString = call.argument<String>("color")
        android.util.Log.d("PlusNavigatorPlugin", "setStatusBarBackground called with color: $colorString")
        if (colorString != null) {
          setStatusBarBackground(colorString)
          result.success(null)
        } else {
          android.util.Log.e("PlusNavigatorPlugin", "setStatusBarBackground failed: color is null")
          result.error("INVALID_ARGUMENT", "Color is null", null)
        }
      }
      "getStatusBarBackground" -> {
        val color = getStatusBarBackground()
        result.success(color)
      }
      "setStatusBarStyle" -> {
        val style = call.argument<String>("style")
        if (style != null) {
          setStatusBarStyle(style)
          result.success(null)
        } else {
          result.error("INVALID_ARGUMENT", "Style is null", null)
        }
      }
      "getStatusBarStyle" -> {
        val style = getStatusBarStyle()
        result.success(style)
      }
      "isBackground" -> {
        // 在Android中，我们无法直接判断应用是否在后台，这里返回false作为默认值
        result.success(false)
      }
      else -> {
        result.notImplemented()
      }
    }
  }

  override fun onDetachedFromEngine(@NonNull binding: FlutterPlugin.FlutterPluginBinding) {
    channel.setMethodCallHandler(null)
  }

  override fun onAttachedToActivity(binding: ActivityPluginBinding) {
    activity = binding.activity
  }

  override fun onDetachedFromActivityForConfigChanges() {
    activity = null
  }

  override fun onReattachedToActivityForConfigChanges(binding: ActivityPluginBinding) {
    activity = binding.activity
  }

  override fun onDetachedFromActivity() {
    activity = null
  }

  private fun getStatusBarHeight(): Double {
    val resourceId = activity?.resources?.getIdentifier("status_bar_height", "dimen", "android")
    return if (resourceId != null && resourceId > 0) {
      activity?.resources?.getDimensionPixelSize(resourceId)?.toDouble() ?: 0.0
    } else {
      0.0
    }
  }

  private fun setStatusBarBackground(colorString: String) {
    android.util.Log.d("PlusNavigatorPlugin", "setStatusBarBackground called with: $colorString")
    activity?.runOnUiThread {
      activity?.window?.apply {
        android.util.Log.d("PlusNavigatorPlugin", "Setting window flags")
        clearFlags(WindowManager.LayoutParams.FLAG_TRANSLUCENT_STATUS)
        addFlags(WindowManager.LayoutParams.FLAG_DRAWS_SYSTEM_BAR_BACKGROUNDS)
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.LOLLIPOP) {
          try {
            val color = Color.parseColor(colorString)
            statusBarColor = color
            android.util.Log.d("PlusNavigatorPlugin", "Status bar color set successfully to: $colorString")
          } catch (e: IllegalArgumentException) {
            android.util.Log.e("PlusNavigatorPlugin", "Invalid color format: $colorString", e)
          }
        } else {
          android.util.Log.w("PlusNavigatorPlugin", "Status bar color not supported on API < 21")
        }
      } ?: android.util.Log.e("PlusNavigatorPlugin", "Activity window is null")
    } ?: android.util.Log.e("PlusNavigatorPlugin", "Activity is null")
  }

  private fun getStatusBarBackground(): String {
    return if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.LOLLIPOP) {
      try {
        val color = activity?.window?.statusBarColor ?: Color.BLACK
        String.format("#%06X", 0xFFFFFF and color)
      } catch (e: Exception) {
        "#000000"
      }
    } else {
      "#000000"
    }
  }

  private fun setStatusBarStyle(style: String) {
    if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.M) {
      activity?.window?.apply {
        when (style) {
          "light" -> {
            decorView.systemUiVisibility = decorView.systemUiVisibility and View.SYSTEM_UI_FLAG_LIGHT_STATUS_BAR.inv()
          }
          "dark" -> {
            decorView.systemUiVisibility = decorView.systemUiVisibility or View.SYSTEM_UI_FLAG_LIGHT_STATUS_BAR
          }
        }
      }
    }
  }

  private fun getStatusBarStyle(): String {
    return if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.M) {
      if (activity?.window?.decorView?.systemUiVisibility?.and(View.SYSTEM_UI_FLAG_LIGHT_STATUS_BAR) == View.SYSTEM_UI_FLAG_LIGHT_STATUS_BAR) {
        "dark"
      } else {
        "light"
      }
    } else {
      "light"
    }
  }
}