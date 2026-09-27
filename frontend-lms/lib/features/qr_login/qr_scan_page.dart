import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

import '../../app/app_scope.dart';
import '../../app/theme/hero_colors.dart';
import '../../app/theme/hero_theme.dart';
import '../../core/api/api_client.dart';
import '../../core/services/qr_login_service.dart';

/// Scans the QR code on the web sign-in page and, after the user confirms the
/// device, signs that browser in to this account (like Telegram's "Link Desktop Device").
class QrScanPage extends StatefulWidget {
  const QrScanPage({super.key});

  @override
  State<QrScanPage> createState() => _QrScanPageState();
}

class _QrScanPageState extends State<QrScanPage> {
  final _controller = MobileScannerController(formats: const [BarcodeFormat.qrCode]);
  bool _busy = false;
  String? _message;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _onDetect(BarcodeCapture capture) async {
    if (_busy) return;
    final token = QrLoginService.parseToken(capture.barcodes.firstOrNull?.rawValue);
    if (token == null) {
      setState(() => _message = 'That is not a Tafakkur sign-in code.');
      return;
    }

    final scope = AppScope.of(context);
    if (scope.auth.isDemo) {
      setState(() => _message = 'Sign in with a real school account to approve web sign-ins.');
      return;
    }

    setState(() {
      _busy = true;
      _message = null;
    });
    await _controller.stop();

    try {
      final device = await scope.qrLogin.scan(token);
      if (!mounted) return;
      final approved = await _confirm(device);
      if (approved == true) {
        await scope.qrLogin.approve(token);
      } else {
        await scope.qrLogin.decline(token);
      }
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(approved == true ? 'Signed in on ${device.deviceName}.' : 'Sign-in declined.')),
      );
      context.pop();
    } on ApiException catch (error) {
      _retry(error.message);
    } on Exception {
      _retry("Couldn't reach the server. Check your connection and try again.");
    }
  }

  Future<void> _retry(String message) async {
    if (!mounted) return;
    setState(() {
      _busy = false;
      _message = message;
    });
    await _controller.start();
  }

  Future<bool?> _confirm(QrLoginDevice device) {
    final hero = context.hero;
    final time = TimeOfDay.fromDateTime(device.requestedAt).format(context);
    return showModalBottomSheet<bool>(
      context: context,
      isDismissible: false,
      backgroundColor: hero.surface,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(HeroRadius.card))),
      builder: (context) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(24, 24, 24, 16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Container(
                width: 48,
                height: 48,
                alignment: Alignment.center,
                decoration: BoxDecoration(color: hero.soft(hero.accent), borderRadius: BorderRadius.circular(16)),
                child: Icon(Icons.computer_rounded, color: hero.softForeground(hero.accent)),
              ),
              const SizedBox(height: 16),
              const Text('Sign in on this device?', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600)),
              const SizedBox(height: 8),
              Text(
                'Only continue if you are signing in yourself. The browser will get full access to your account.',
                style: TextStyle(fontSize: 14, color: hero.muted),
              ),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: hero.surfaceSecondary,
                  borderRadius: BorderRadius.circular(HeroRadius.field),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(device.deviceName, style: const TextStyle(fontWeight: FontWeight.w600)),
                    const SizedBox(height: 4),
                    Text(
                      [if (device.ipAddress != null) 'IP ${device.ipAddress}', 'Requested at $time'].join(' · '),
                      style: TextStyle(fontSize: 13, color: hero.muted),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              FilledButton(onPressed: () => Navigator.of(context).pop(true), child: const Text('Sign in')),
              const SizedBox(height: 8),
              OutlinedButton(onPressed: () => Navigator.of(context).pop(false), child: const Text('Cancel')),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final hero = context.hero;
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        foregroundColor: Colors.white,
        title: const Text('Scan QR code', style: TextStyle(fontSize: 17, fontWeight: FontWeight.w600)),
        actions: [
          IconButton(
            tooltip: 'Flashlight',
            icon: const Icon(Icons.flashlight_on_outlined),
            onPressed: () => _controller.toggleTorch(),
          ),
        ],
      ),
      extendBodyBehindAppBar: true,
      body: Stack(
        fit: StackFit.expand,
        children: [
          MobileScanner(
            controller: _controller,
            onDetect: _onDetect,
            errorBuilder: (context, error) => Center(
              child: Padding(
                padding: const EdgeInsets.all(32),
                child: Text(
                  error.errorCode == MobileScannerErrorCode.permissionDenied
                      ? 'Allow camera access in Settings to scan sign-in codes.'
                      : 'The camera is not available.',
                  textAlign: TextAlign.center,
                  style: const TextStyle(color: Colors.white),
                ),
              ),
            ),
          ),
          const _ScanFrame(),
          Positioned(
            left: 24,
            right: 24,
            bottom: 48,
            child: SafeArea(
              child: Column(
                children: [
                  if (_busy) const CircularProgressIndicator(color: Colors.white),
                  if (_message != null)
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      decoration: BoxDecoration(
                        color: hero.danger.withValues(alpha: 0.9),
                        borderRadius: BorderRadius.circular(HeroRadius.field),
                      ),
                      child: Text(
                        _message!,
                        textAlign: TextAlign.center,
                        style: const TextStyle(color: Colors.white),
                      ),
                    ),
                  const SizedBox(height: 16),
                  const Text(
                    'Open Tafakkur on your computer and point the camera at the QR code on the sign-in page.',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Colors.white70, fontSize: 14),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Dims the camera outside a rounded square viewfinder.
class _ScanFrame extends StatelessWidget {
  const _ScanFrame();

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final side = constraints.maxWidth * 0.7;
        final rect = Rect.fromCenter(
          center: constraints.biggest.center(Offset.zero).translate(0, -40),
          width: side,
          height: side,
        );
        return CustomPaint(painter: _FramePainter(rect, context.hero.accent));
      },
    );
  }
}

class _FramePainter extends CustomPainter {
  _FramePainter(this.rect, this.color);

  final Rect rect;
  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final frame = RRect.fromRectAndRadius(rect, const Radius.circular(HeroRadius.card));
    canvas.drawPath(
      Path.combine(PathOperation.difference, Path()..addRect(Offset.zero & size), Path()..addRRect(frame)),
      Paint()..color = Colors.black54,
    );
    canvas.drawRRect(
      frame,
      Paint()
        ..color = color
        ..style = PaintingStyle.stroke
        ..strokeWidth = 3,
    );
  }

  @override
  bool shouldRepaint(_FramePainter oldDelegate) => oldDelegate.rect != rect || oldDelegate.color != color;
}
