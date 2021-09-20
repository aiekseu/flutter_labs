package com.aiekseu.tpu_android_labs

import android.app.Service
import android.content.Intent
import android.os.Binder
import android.os.IBinder
import io.flutter.Log
import kotlinx.coroutines.*
import kotlin.time.Duration
import kotlin.time.ExperimentalTime

class TimeService : Service() {

    private var counter = 0
    private var interval = 1
    private lateinit var job : Job;


    private val myBinder = MyBinder()
    override fun onBind(intent: Intent?): IBinder {
        return myBinder
    }
    inner class MyBinder : Binder() {
        fun getService() : TimeService {
            return this@TimeService
        }
    }

    fun getCounter(): Int {
        return counter
    }

    fun getInterval() : Int {
        return interval
    }

    fun reloadCounter() {
        counter = 0
    }

    fun setCounter(value: Int) {
        counter = value
    }

    fun setInterval(value: Int) {
        interval = value
    }

    @ExperimentalTime
    @DelicateCoroutinesApi
    override fun onStartCommand(intent: Intent, flags: Int, startId: Int): Int {
        setCounter(intent.getIntExtra("initialValue", 1))
        setInterval(intent.getIntExtra("timeInterval", 1))

        job = GlobalScope.launch {
            while (true) {
                delay(Duration.seconds(getInterval()))
//                Log.d("SERVICE", "Timer Is Ticking: " + counter)
                counter++
                val intent = Intent(BROADCAST_TIME_EVENT);
                intent.putExtra("counter", counter);
                sendBroadcast(intent);
            }
        }
        return super.onStartCommand(intent, flags, startId)
    }

    override fun onDestroy() {
        Log.d("SERVICE", "onDestroy")
        job.cancel()
        super.onDestroy()
    }

}