import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../core/theme/ot_colors.dart';
import '../../core/theme/ot_sizes.dart';
import '../../core/theme/ot_text.dart';
import '../../shared/widgets/ot_button.dart';
import '../../state/auth_controller.dart';

/// Kirish. SMS yo'q — Telegram bot raqamni o'zi tasdiqlab beradi.
class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key, this.onSkip});

  /// "Keyinroq" — kirmasdan lentani ko'rish
  final VoidCallback? onSkip;

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthController>();

    return Scaffold(
      backgroundColor: OtColors.surface,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 28),
          child: Column(
            children: [
              const Spacer(flex: 2),
              _brand(),
              const SizedBox(height: OtSize.x24),
              Text(
                'Fargʻona viloyati eʼlonlari',
                textAlign: TextAlign.center,
                style: OtText.titleSm.copyWith(fontSize: 22),
              ),
              const SizedBox(height: OtSize.x8),
              const Text(
                'Kirish uchun Telegram yetarli — SMS kutish shart emas. '
                'Bot raqamingizni soʻraydi, u eʼlonlaringizda xaridorlar '
                'bogʻlanishi uchun kerak.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 14.5,
                  height: 1.6,
                  color: OtColors.inkMuted,
                ),
              ),
              const Spacer(flex: 3),
              if (auth.isWaitingForTelegram)
                _waiting(context, auth)
              else
                _actions(context, auth),
              if (auth.error != null) ...[
                const SizedBox(height: OtSize.x12),
                Text(
                  auth.error!,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 13,
                    color: OtColors.danger,
                  ),
                ),
              ],
              const SizedBox(height: OtSize.x24),
            ],
          ),
        ),
      ),
    );
  }

  Widget _brand() {
    return Column(
      children: [
        Container(
          width: 72,
          height: 72,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: OtColors.accent,
            borderRadius: BorderRadius.circular(24),
          ),
          child: const Text(
            'O',
            style: TextStyle(
              fontSize: 34,
              fontWeight: FontWeight.w800,
              color: OtColors.surface,
            ),
          ),
        ),
        const SizedBox(height: OtSize.x16),
        Text('Oson Top', style: OtText.display.copyWith(fontSize: 30)),
      ],
    );
  }

  Widget _actions(BuildContext context, AuthController auth) {
    return Column(
      children: [
        SizedBox(
          width: double.infinity,
          child: OtButton(
            label: 'Telegram orqali kirish',
            icon: Icons.send_outlined,
            large: true,
            onPressed: () => _openTelegram(context, auth),
          ),
        ),
        if (onSkip != null) ...[
          const SizedBox(height: OtSize.x12),
          TextButton(
            onPressed: onSkip,
            child: Text(
              'Keyinroq — avval eʼlonlarni koʻraman',
              style: OtText.bodyStrong.copyWith(color: OtColors.inkMuted),
            ),
          ),
        ],
      ],
    );
  }

  Widget _waiting(BuildContext context, AuthController auth) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(OtSize.x16),
          decoration: BoxDecoration(
            color: OtColors.accentSofter,
            borderRadius: BorderRadius.circular(OtSize.rCard),
            border: Border.all(color: OtColors.accentLine),
          ),
          child: const Row(
            children: [
              SizedBox(
                width: 18,
                height: 18,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: OtColors.accent,
                ),
              ),
              SizedBox(width: 14),
              Expanded(
                child: Text(
                  'Telegramda «Raqamni ulashish» tugmasini bosing — '
                  'shundan keyin bu yerga oʻzi qaytadi.',
                  style: TextStyle(
                    fontSize: 13.5,
                    height: 1.5,
                    color: OtColors.accentInk,
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: OtSize.x12),
        TextButton(
          onPressed: auth.cancelTelegramLogin,
          child: Text(
            'Bekor qilish',
            style: OtText.bodyStrong.copyWith(color: OtColors.inkMuted),
          ),
        ),
      ],
    );
  }

  Future<void> _openTelegram(BuildContext context, AuthController auth) async {
    final link = await auth.startTelegramLogin();
    if (link == null) return;

    final uri = Uri.parse(link);
    if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Telegram ochilmadi')),
      );
    }
  }
}
