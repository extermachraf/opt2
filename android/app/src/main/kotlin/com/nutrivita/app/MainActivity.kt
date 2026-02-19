package com.nutrivita.app

import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel
import androidx.biometric.BiometricManager
import androidx.biometric.BiometricPrompt
import androidx.core.content.ContextCompat
import androidx.fragment.app.FragmentActivity
import java.util.concurrent.Executor

class MainActivity: FlutterActivity() {
    private val CHANNEL = "nutrivita/biometric"
    private lateinit var executor: Executor
    private lateinit var biometricPrompt: BiometricPrompt
    private lateinit var promptInfo: BiometricPrompt.PromptInfo
    
    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        
        executor = ContextCompat.getMainExecutor(this)
        
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL).setMethodCallHandler { call, result ->
            when (call.method) {
                "isBiometricAvailable" -> {
                    val biometricManager = BiometricManager.from(this)
                    val isAvailable = when (biometricManager.canAuthenticate(BiometricManager.Authenticators.BIOMETRIC_STRONG)) {
                        BiometricManager.BIOMETRIC_SUCCESS -> true
                        else -> false
                    }
                    result.success(isAvailable)
                }
                "getAvailableBiometrics" -> {
                    val biometricManager = BiometricManager.from(this)
                    val types = mutableListOf<String>()
                    
                    when (biometricManager.canAuthenticate(BiometricManager.Authenticators.BIOMETRIC_STRONG)) {
                        BiometricManager.BIOMETRIC_SUCCESS -> {
                            types.add("fingerprint") // Android primarily uses fingerprint
                        }
                    }
                    result.success(types)
                }
                "authenticate" -> {
                    val signInTitle = call.argument<String>("signInTitle") ?: "Autenticazione Biometrica"
                    val cancelButton = call.argument<String>("cancelButton") ?: "Annulla"
                    
                    biometricPrompt = BiometricPrompt(this as FragmentActivity, executor, 
                        object : BiometricPrompt.AuthenticationCallback() {
                            override fun onAuthenticationError(errorCode: Int, errString: CharSequence) {
                                super.onAuthenticationError(errorCode, errString)
                                when (errorCode) {
                                    BiometricPrompt.ERROR_USER_CANCELED -> result.error("UserCancel", errString.toString(), null)
                                    BiometricPrompt.ERROR_NO_BIOMETRICS -> result.error("NotEnrolled", errString.toString(), null)
                                    BiometricPrompt.ERROR_HW_NOT_PRESENT -> result.error("NotAvailable", errString.toString(), null)
                                    BiometricPrompt.ERROR_LOCKOUT_PERMANENT -> result.error("PermanentlyLockedOut", errString.toString(), null)
                                    else -> result.error("AuthenticationError", errString.toString(), null)
                                }
                            }
                            
                            override fun onAuthenticationSucceeded(authResult: BiometricPrompt.AuthenticationResult) {
                                super.onAuthenticationSucceeded(authResult)
                                result.success(true)
                            }
                            
                            override fun onAuthenticationFailed() {
                                super.onAuthenticationFailed()
                                result.success(false)
                            }
                        })
                    
                    promptInfo = BiometricPrompt.PromptInfo.Builder()
                        .setTitle(signInTitle)
                        .setSubtitle("Usa la tua impronta digitale per accedere")
                        .setNegativeButtonText(cancelButton)
                        .build()
                    
                    biometricPrompt.authenticate(promptInfo)
                }
                else -> {
                    result.notImplemented()
                }
            }
        }
    }
}