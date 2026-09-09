import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../core/theme/ot_colors.dart';
import '../../../core/theme/ot_sizes.dart';
import '../../../data/repositories/listing_repository.dart';
import '../../../shared/widgets/ot_button.dart';

/// Pastdagi bog'lanish paneli.
///
/// Telefon raqami e'lon bilan birga kelmaydi — birinchi bosishda serverdan
/// so'raladi, ikkinchi bosishda qo'ng'iroq ketadi. Bu raqam yig'uvchi
/// botlardan himoya qiladi va nechta odam qiziqqanini sanash imkonini beradi.
class ContactBar extends StatefulWidget {
  const ContactBar({super.key, required this.listingId, this.phone});

  final String listingId;

  /// Mock rejimida raqam allaqachon ma'lum bo'lishi mumkin
  final String? phone;

  @override
  State<ContactBar> createState() => _ContactBarState();
}

class _ContactBarState extends State<ContactBar> {
  String? _phone;
  bool _loading = false;

  Future<void> _onPrimary() async {
    if (_phone == null) {
      setState(() => _loading = true);
      try {
        final phone = widget.phone ??
            await context.read<ListingRepository>().revealPhone(widget.listingId);
        if (!mounted) return;
        setState(() {
          _phone = phone;
          _loading = false;
        });
      } catch (error) {
        if (!mounted) return;
        setState(() => _loading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('$error')),
        );
      }
      return;
    }

    final digits = _phone!.replaceAll(RegExp(r'[^\d+]'), '');
    final uri = Uri(scheme: 'tel', path: digits);
    if (await canLaunchUrl(uri)) await launchUrl(uri);
  }

  Future<void> _onMessage() async {
    final phone = _phone;
    if (phone == null) {
      await _onPrimary();
      return;
    }
    final digits = phone.replaceAll(RegExp(r'[^\d]'), '');
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
              label: _loading
                  ? 'Yuklanmoqda…'
                  : (_phone ?? 'Raqamni koʻrsatish'),
              icon: Icons.call,
              large: true,
              onPressed: _loading ? null : _onPrimary,
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
