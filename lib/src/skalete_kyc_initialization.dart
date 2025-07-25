import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'config/app_config.dart';
import 'models/kyc_result.dart';
import 'models/kyc_user_info.dart';
import 'models/kyc_customization.dart';
import 'services/kyc_state_provider.dart';
import 'ui/kyc_verification_screen.dart';
import 'ui/shared/app_color.dart';
// import 'dart:developer' as developer;

class SkaletekKYC {
  SkaletekKYC._internal();
  static final SkaletekKYC _instance = SkaletekKYC._internal();
  static SkaletekKYC get instance => _instance;

  /// Starts the KYC verification process using model objects.
  ///
  /// **IMPORTANT**: Make sure you called SkaletekKYC.initialize() in main() first!
  ///
  /// [context] - BuildContext from the calling widget
  /// [token] - Authentication token for the verification session
  /// [userInfo] - User information model
  /// [customization] - UI customization model
  /// [environment] - Environment configuration (dev, prod, sandbox) - defaults to dev
  /// [onComplete] - Callback called with the result as a Map
  Future<void> startVerification({
    required BuildContext context,
    required String token,
    required KYCUserInfo userInfo,
    required KYCCustomization customization,
    SkaletekEnvironment environment = SkaletekEnvironment.dev,
    required Function(Map<String, dynamic> result) onComplete,
  }) async {
    try {
      // developer.log('SkaletekKYC: Starting verification...');

      final config = KYCConfig(
        token: token,
        userInfo: userInfo,
        customization: customization,
        environment: environment,
      );
      await resetKYCState();

      // Initialize AppColor with customization
      AppColor.init(customization);

      KYCResult? result;
      if (context.mounted) {
        await Navigator.of(context).push<KYCResult>(
          MaterialPageRoute(
            fullscreenDialog: true,
            builder: (hostContext) => _SkaletekKYCApp(
              config: config,
              onExit: (exitResult) {
                result = exitResult;
                Navigator.of(hostContext).pop(exitResult);
              },
            ),
          ),
        );
      }

      if (result != null) {
        onComplete(result!.toMap());
      } else {
        onComplete(KYCResult.failure(status: KYCStatus.failure).toMap());
      }
    } catch (e) {
      // developer.log('SkaletekKYC: Error during verification: $e');
      onComplete(KYCResult.failure(status: KYCStatus.failure).toMap());
    }
  }

  /// Resets the KYC state (useful for testing or new sessions).
  Future<void> resetKYCState() async {
    await KYCStateProvider().resetState();
  }
}

/// Internal MaterialApp wrapper for the KYC SDK with consistent theming
class _SkaletekKYCApp extends StatelessWidget {
  final KYCConfig config;
  final Function(KYCResult) onExit;

  const _SkaletekKYCApp({required this.config, required this.onExit});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Skaletek KYC',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: AppColor.primary),
        useMaterial3: true,
      ),
      home: ChangeNotifierProvider(
        create: (_) => KYCStateProvider(),
        child: KYCVerificationScreen(config: config, onExit: onExit),
      ),
    );
  }
}
