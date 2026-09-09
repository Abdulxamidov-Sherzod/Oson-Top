import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../core/theme/ot_colors.dart';
import '../../../core/theme/ot_sizes.dart';
import '../../../shared/widgets/ot_button.dart';

/// Pastdagi bog'lanish paneli.
///
/// Telefon raqami darhol ko'rinmaydi: birinchi bosishda ochiladi, ikkinchi
/// bosishda qo'ng'iroq qilinadi. Bu raqam yig'uvchi botlardan himoya qiladi
/// va kim qancha raqam ochganini bilish imkonini beradi.
class ContactBar extends StatefulWidget {
  const ContactBar({super.key, required this.phone});

  final String phone;

  @override
  State<ContactBar> createState() => _ContactBarState();
}

class _ContactBarState extends State<ContactBar> {
  bool _revealed = false;

  Future<void> _onPrimary() async {
    if (!_revealed) {
      setState(() => _revealed = true);
      return;
    }
    final digits = widget.phone.replaceAll(RegExp(r'[^\d+]'), '');
    final uri = Uri(scheme: 'tel', path: digits);
    if (await canLaunchUrl(uri)) await launchUrl(uri);
  }

  Future<void> _onMessage() async {
    final digits = widget.phone.replaceAll(RegExp(r'[^\d]'), '');
    final uri = Uri.parse('https://t.me/+$digits');
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.fromLTRB(
        OtSize.screenPad,
        12,
        OtSize.screenPad,
        12 + MediaQuery.paddingOf(context).bottom,
      ),
      decoration: const BoxDecoration(
        color: OtColors.surface,
        border: Border(top: BorderSide(color: OtColors.line)),
      ),
      child: Row(
        children: [
          Expanded(
            flex: 12,
            child: OtButton(
              label: _revealed ? widget.phone : 'Raqamni koʻrsatish',
              icon: Icons.call,
              large: true,
              onPressed: _onPrimary,
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            flex: 10,
            child: OtButton(
              label: 'Xabar',
              kind: OtButtonKind.secondary,
              icon: Icons.chat_bubble_outline,
              large: true,
              onPressed: _onMessage,
            ),
          ),
        ],
      ),
    );
  }
}
