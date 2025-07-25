import 'package:flutter/material.dart';
import 'package:skaletek_kyc/src/ui/shared/app_color.dart';
import 'package:skaletek_kyc/src/ui/shared/logo.dart';
import 'package:skaletek_kyc/src/ui/shared/alert.dart';

class KYCHeader extends StatelessWidget implements PreferredSizeWidget {
  final String? logoUrl;
  final VoidCallback? onClose;
  final List<Widget>? actions;

  const KYCHeader({super.key, this.logoUrl, this.onClose, this.actions});

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  @override
  Widget build(BuildContext context) {
    Future<void> showCloseConfirmation() async {
      final navigator = Navigator.of(context);
      final shouldClose = await showDialog<bool>(
        barrierDismissible: false,
        context: context,
        builder: (context) => KYCAlert(
          title: 'Exit Verification?',
          description:
              'Are you sure you want to exit the verification process? Your progress will be lost.',
          confirmText: 'Exit',
          cancelText: 'Cancel',
        ),
      );
      if (shouldClose == true) {
        if (onClose != null) {
          onClose!();
        } else if (navigator.canPop()) {
          navigator.maybePop();
        }
      }
    }

    Widget appBar = AppBar(
      backgroundColor: Colors.white,
      automaticallyImplyLeading: false,
      title: Row(
        children: [
          KYCLogo(logoUrl: logoUrl),
          const Spacer(),
        ],
      ),
      actions: [
        if (actions != null) ...actions!,
        Padding(
          padding: const EdgeInsets.only(right: 8),
          child: IconButton(
            style: IconButton.styleFrom(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
                side: BorderSide(color: AppColor.light),
              ),
            ),
            icon: Icon(Icons.close, color: Colors.grey[700], size: 24),
            onPressed: showCloseConfirmation,
            splashRadius: 24,
            tooltip: 'Close',
          ),
        ),
      ],
    );

    return appBar;
  }
}
