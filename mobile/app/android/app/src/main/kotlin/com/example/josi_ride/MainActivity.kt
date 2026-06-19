package com.example.josi_ride

import android.Manifest
import android.content.Context
import android.content.Intent
import android.content.pm.PackageManager
import android.location.Location
import android.location.LocationListener
import android.location.LocationManager
import android.net.Uri
import android.os.Build
import android.os.Bundle
import android.os.Handler
import android.os.Looper
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class MainActivity : FlutterActivity() {
    private val locationChannelName = "josi_ride/device_location"
    private val phoneChannelName = "josi_ride/phone"
    private val locationPermissionRequest = 4810
    private val locationTimeoutMs = 10000L
    private var pendingLocationResult: MethodChannel.Result? = null
    private var pendingLocationListener: LocationListener? = null
    private val timeoutHandler = Handler(Looper.getMainLooper())

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

        MethodChannel(
            flutterEngine.dartExecutor.binaryMessenger,
            locationChannelName,
        ).setMethodCallHandler { call, result ->
            when (call.method) {
                "currentPosition" -> startLocationLookup(result)
                else -> result.notImplemented()
            }
        }

        MethodChannel(
            flutterEngine.dartExecutor.binaryMessenger,
            phoneChannelName,
        ).setMethodCallHandler { call, result ->
            when (call.method) {
                "dial" -> dialPhoneNumber(call.argument<String>("phone"), result)
                else -> result.notImplemented()
            }
        }
    }

    private fun dialPhoneNumber(phoneNumber: String?, result: MethodChannel.Result) {
        val normalized = phoneNumber?.trim().orEmpty()
        if (normalized.isEmpty()) {
            result.error("PHONE_EMPTY", "Rider phone number is not available.", null)
            return
        }

        val intent = Intent(Intent.ACTION_DIAL).apply {
            data = Uri.parse("tel:$normalized")
        }

        if (intent.resolveActivity(packageManager) == null) {
            result.error("PHONE_UNAVAILABLE", "No phone app is available on this device.", null)
            return
        }

        startActivity(intent)
        result.success(true)
    }

    private fun startLocationLookup(result: MethodChannel.Result) {
        if (pendingLocationResult != null) {
            result.error(
                "LOCATION_BUSY",
                "GPS is already finding your position.",
                null,
            )
            return
        }

        if (!hasLocationPermission()) {
            pendingLocationResult = result
            if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.M) {
                requestPermissions(
                    arrayOf(
                        Manifest.permission.ACCESS_FINE_LOCATION,
                        Manifest.permission.ACCESS_COARSE_LOCATION,
                    ),
                    locationPermissionRequest,
                )
            } else {
                result.error(
                    "PERMISSION_DENIED",
                    "Location permission was denied.",
                    null,
                )
                pendingLocationResult = null
            }
            return
        }

        resolveCurrentLocation(result)
    }

    override fun onRequestPermissionsResult(
        requestCode: Int,
        permissions: Array<out String>,
        grantResults: IntArray,
    ) {
        super.onRequestPermissionsResult(requestCode, permissions, grantResults)
        if (requestCode != locationPermissionRequest) {
            return
        }

        val result = pendingLocationResult ?: return
        if (grantResults.any { it == PackageManager.PERMISSION_GRANTED }) {
            pendingLocationResult = null
            resolveCurrentLocation(result)
        } else {
            pendingLocationResult = null
            result.error(
                "PERMISSION_DENIED",
                "Location permission was denied.",
                null,
            )
        }
    }

    private fun hasLocationPermission(): Boolean {
        if (Build.VERSION.SDK_INT < Build.VERSION_CODES.M) {
            return true
        }

        return checkSelfPermission(Manifest.permission.ACCESS_FINE_LOCATION) ==
            PackageManager.PERMISSION_GRANTED ||
            checkSelfPermission(Manifest.permission.ACCESS_COARSE_LOCATION) ==
            PackageManager.PERMISSION_GRANTED
    }

    private fun resolveCurrentLocation(result: MethodChannel.Result) {
        val locationManager =
            getSystemService(Context.LOCATION_SERVICE) as LocationManager
        val enabledProviders = listOf(
            LocationManager.GPS_PROVIDER,
            LocationManager.NETWORK_PROVIDER,
        ).filter { provider ->
            try {
                locationManager.isProviderEnabled(provider)
            } catch (_: Exception) {
                false
            }
        }

        if (enabledProviders.isEmpty()) {
            result.error(
                "LOCATION_DISABLED",
                "Turn on phone location services and try again.",
                null,
            )
            return
        }

        val lastKnownLocation = bestLastKnownLocation(
            locationManager,
            enabledProviders,
        )
        if (lastKnownLocation != null && isFresh(lastKnownLocation)) {
            result.success(locationMap(lastKnownLocation))
            return
        }

        pendingLocationResult = result
        val listener = object : LocationListener {
            override fun onLocationChanged(location: Location) {
                completeLocationLookup(location)
            }

            override fun onProviderEnabled(provider: String) = Unit

            override fun onProviderDisabled(provider: String) = Unit

            @Deprecated("Deprecated in Java")
            override fun onStatusChanged(
                provider: String?,
                status: Int,
                extras: Bundle?,
            ) = Unit
        }
        pendingLocationListener = listener

        try {
            enabledProviders.forEach { provider ->
                locationManager.requestLocationUpdates(
                    provider,
                    0L,
                    0f,
                    listener,
                    Looper.getMainLooper(),
                )
            }
        } catch (_: SecurityException) {
            clearLocationListener(locationManager)
            pendingLocationResult = null
            result.error(
                "PERMISSION_DENIED",
                "Location permission was denied.",
                null,
            )
            return
        }

        timeoutHandler.postDelayed(
            {
                val pending = pendingLocationResult ?: return@postDelayed
                val fallback = bestLastKnownLocation(
                    locationManager,
                    enabledProviders,
                )
                clearLocationListener(locationManager)
                pendingLocationResult = null
                if (fallback != null) {
                    pending.success(locationMap(fallback))
                } else {
                    pending.error(
                        "LOCATION_TIMEOUT",
                        "GPS took too long to find your position.",
                        null,
                    )
                }
            },
            locationTimeoutMs,
        )
    }

    private fun completeLocationLookup(location: Location) {
        val result = pendingLocationResult ?: return
        val locationManager =
            getSystemService(Context.LOCATION_SERVICE) as LocationManager
        clearLocationListener(locationManager)
        pendingLocationResult = null
        result.success(locationMap(location))
    }

    private fun clearLocationListener(locationManager: LocationManager) {
        timeoutHandler.removeCallbacksAndMessages(null)
        pendingLocationListener?.let { listener ->
            try {
                locationManager.removeUpdates(listener)
            } catch (_: SecurityException) {
                // Permission can be revoked while the lookup is running.
            }
        }
        pendingLocationListener = null
    }

    private fun bestLastKnownLocation(
        locationManager: LocationManager,
        providers: List<String>,
    ): Location? {
        return providers.mapNotNull { provider ->
            try {
                locationManager.getLastKnownLocation(provider)
            } catch (_: SecurityException) {
                null
            }
        }.maxByOrNull { location -> location.time }
    }

    private fun isFresh(location: Location): Boolean {
        return System.currentTimeMillis() - location.time < 300000L
    }

    private fun locationMap(location: Location): Map<String, Double> {
        return mapOf(
            "latitude" to location.latitude,
            "longitude" to location.longitude,
        )
    }
}
