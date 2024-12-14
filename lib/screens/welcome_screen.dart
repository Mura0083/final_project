import 'dart:io';

import 'package:android_id/android_id.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:final_project/utils/app_state.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'share_code_screen.dart';
import 'enter_code_screen.dart';

const double kDefaultPadding = 8.0;

class WelcomeScreen extends StatefulWidget {
  const WelcomeScreen({super.key});

  @override
  State<WelcomeScreen> createState() => _WelcomeScreenState();
}

class _WelcomeScreenState extends State<WelcomeScreen> {
  @override
  void initState() {
    super.initState();
    _initializeDeviceId();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Movie Night',
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                color: Theme.of(context).colorScheme.onPrimary,
              ),
        ),
        backgroundColor: Theme.of(context).colorScheme.primary,
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(kDefaultPadding * 2),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const ShareCodeScreen(),
                    ),
                  );
                },
                child: Text(
                  'Start Session',
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        fontFamily: 'Roboto',
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).colorScheme.onPrimary,
                      ),
                ),
              ),
              const SizedBox(height: 16.0),
              ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const EnterCodeScreen(),
                    ),
                  );
                },
                child: Text(
                  'Enter Code',
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        fontFamily: 'Roboto',
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).colorScheme.onSecondary,
                      ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _initializeDeviceId() async {
    final appState = Provider.of<AppState>(context, listen: false);
    if (appState.deviceId != null && appState.deviceId!.isNotEmpty) {
      if (kDebugMode) {
        print('Device ID already initialized: ${appState.deviceId}');
      }
      return;
    }

    String deviceId = await _fetchDeviceId();
    appState.setDeviceId(deviceId);
    if (kDebugMode) {
      print('Device ID initialized: $deviceId');
    }
  }

  Future<String> _fetchDeviceId() async {
    String deviceId = '';
    try {
      if (Platform.isAndroid) {
        const androidPlugin = AndroidId();
        deviceId = await androidPlugin.getId() ?? 'unknown id';
      } else if (Platform.isIOS) {
        var deviceInfoPlugin = DeviceInfoPlugin();
        var iosInfo = await deviceInfoPlugin.iosInfo;
        deviceId = iosInfo.identifierForVendor ?? 'unknown id';
      } else {
        deviceId = 'unsupported platform';
      }
    } catch (e) {
      deviceId = 'error: $e';
    }
    if (kDebugMode) {
      print('Device ID: $deviceId');
    }
    return deviceId;
  }
}
