package com.aiekseu.tpu_android_labs

import android.content.*
import android.os.Bundle
import android.os.IBinder
import androidx.annotation.NonNull
import io.flutter.Log
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel


const val BROADCAST_TIME_EVENT = "com.avk224.lab10.timeevent"

class MainActivity: FlutterActivity() {

    private val CHANNEL = "com.avk224.lab10/counter"

    override fun configureFlutterEngine(@NonNull flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL).setMethodCallHandler {
            // Note: this method is invoked on the main thread.
            call, result ->

            when (call.method) {
                "reloadCounter" -> {
                    reloadCounter()
                }
                "startService" -> {
                    startMyService(call.argument("initialValue")!!, call.argument("timeInterval")!!)
                    result.success(null)
                }
                "stopService" -> {
                    stopMyService()
                    result.success(null)
                }
                else -> {
                    result.notImplemented()
                }
            }
        }
    }

    var myService: TimeService? = null
    var isBound = false
    val myConnection = object : ServiceConnection {
        override fun onServiceConnected(className: ComponentName, service: IBinder) {
            val binder = service as TimeService.MyBinder
            myService = binder.getService()
            isBound = true
        }
        override fun onServiceDisconnected(name: ComponentName) {
            isBound = false
        }
    }
    var receiver: BroadcastReceiver? = null


    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)

        receiver = object : BroadcastReceiver() {
            // Получено широковещательное сообщение
            override fun onReceive(context: Context?, intent: Intent) {
                val counter = intent.getIntExtra("counter", 0)
                Log.d("SERVICE", "Timer Is Ticking: $counter")
                MethodChannel(flutterEngine?.dartExecutor?.binaryMessenger, CHANNEL).invokeMethod("counterHasChanged", counter);
            }
        }
        val filter = IntentFilter(BROADCAST_TIME_EVENT)
        registerReceiver(receiver, filter)
    }

    override fun onDestroy() {
        unregisterReceiver(receiver);
        super.onDestroy()
    }

    private fun reloadCounter() {
        if (isBound) {
            myService?.reloadCounter()
        }
    }

    private fun startMyService(initialValue: Int, timeInterval: Int) {
        if (!isBound) {
            val intent = Intent(this, TimeService::class.java)
            intent.putExtra("initialValue", initialValue)
            intent.putExtra("timeInterval", timeInterval)
            startService(intent)
            bindService(Intent(this, TimeService::class.java),
                    myConnection, Context.BIND_AUTO_CREATE)
        }
    }

    private fun stopMyService() {
        stopService(Intent(this, TimeService::class.java))
        unbindService(myConnection)
        isBound = false;
    }




}

