package com.signdict.hausa

import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel
import org.python.core.PyObject
import org.python.util.PythonInterpreter


class MainActivity : FlutterActivity() {
    private val CHANNEL = "python_channel"

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL).setMethodCallHandler { call, result ->
            if (call.method == "executePythonScript") {
                val pythonScriptResult = executePythonScript()
                result.success(pythonScriptResult)
            } else {
                result.notImplemented()
            }
        }
    }

    private fun executePythonScript(): String {
        val pythonInterpreter = PythonInterpreter()
        pythonInterpreter.exec("your_python_script.py") // Provide the path to your Python script
        val pythonScriptResult: PyObject = pythonInterpreter.get("result")
        return pythonScriptResult.toString()
    }
}

d