package com.example.cast

import android.os.Bundle
import android.content.Intent

import io.flutter.app.FlutterActivity
import io.flutter.plugin.common.ActivityLifecycleListener
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.MethodChannel.MethodCallHandler
import io.flutter.plugins.GeneratedPluginRegistrant

class MainActivity: FlutterActivity() {
   private var sharedText: String? = null

  // Handles while intents while running

  override fun onNewIntent(intent: Intent) {
    super.onNewIntent(intent)
    handleSendText(intent)
  }

  // Handles intents 'as launch' and sets the methodchannel

  override fun onCreate(savedInstanceState: Bundle?) {
    super.onCreate(savedInstanceState)
    GeneratedPluginRegistrant.registerWith(this)
    handleSendText(intent)

    MethodChannel(flutterView, "app.channel.shared.data")
            .setMethodCallHandler { call, result ->
              if (call.method.contentEquals("getSharedText")) {
                result.success(sharedText)
                sharedText = null
              }
            }
  }

  fun handleSendText(intent : Intent) {
    sharedText = intent.getStringExtra(Intent.EXTRA_TEXT)
  } 
}
