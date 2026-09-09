import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/theme/ot_colors.dart';
import '../../core/theme/ot_sizes.dart';
import '../../core/theme/ot_text.dart';
import '../../data/mock/mock_listings.dart';
import '../../shared/widgets/empty_state.dart';
import '../../shared/widgets/listing_card.dart';
import '../../shared/widgets/ot_button.dart';
import '../../shared/widgets/ot_chip.dart';
import '../../shared/widgets/ot_segmented.dart';
import '../../shared/widgets/ot_text_field.dart';
import '../../state/favorites_controller.dart';

/// Poydevorni ko'z bilan tekshirish uchun sahifa.
/// Keyingi qismlar tugagach o'chirilishi mumkin.
class ComponentGalleryScreen extends StatefulWidget {
  const ComponentGalleryScreen({super.key});

  @override
  State<ComponentGalleryScreen> createState() => _ComponentGalleryScreenState();
}

class _ComponentGalleryScreenState extends State<ComponentGalleryScreen> {
  String _condition = 'used';
  bool _chipOn = true;

  @override
  Widget build(BuildContext context) {
    final favorites = context.watch<FavoritesController>();

    return Scaffold(
      backgroundColor: OtColors.ground,
      body: SafeArea(
        child: Column(
          children: [
            _header(context),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.fromLTRB(
                    OtSize.screenPad, OtSize.x16, OtSize.screenPad, 40),
                children: [
                  _section('Ranglar'),
                  _swatches(),
                  const SizedBox(height: OtSize.x24),

                  _section('Eʼlon kartasi'),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      for (final l in mockListings.take(2)) ...[
                        Expanded(
                          child: ListingCard(
                            listing: l,
                            isFavorite: favorites.isFavorite(l.id),
                            onFavoriteTap: () => favorites.toggle(l.id),
                            onTap: () {},
                          ),
                        ),
                        if (l != mockListings[1]) const SizedBox(width: 12),
                      ],
                    ],
                  ),
                  const SizedBox(height: OtSize.x24),

                  _section('Tugmalar'),
                  const OtButton(label: 'Raqamni koʻrsatish', icon: Icons.call),
                  const SizedBox(height: OtSize.x8),
                  const OtButton(
                      label: 'Davom etish', trailingIcon: Icons.arrow_forward),
                  const SizedBox(height: OtSize.x8),
                  const OtButton(
                      label: 'Xabar yozish',
                      kind: OtButtonKind.secondary,
                      icon: Icons.chat_bubble_outline),
                  const SizedBox(height: OtSize.x8),
                  const OtButton(label: 'Oʻchirilgan tugma', onPressed: null),
                  const SizedBox(height: OtSize.x24),

                  _section('Chiplar'),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      OtChip(
                        label: 'Telefonlar',
                        selected: _chipOn,
                        trailing: _chipOn ? Icons.close : null,
                        onTap: () => setState(() => _chipOn = !_chipOn),
                      ),
                      const OtChip(label: 'Tuman', trailing: Icons.expand_more),
                      const OtChip(label: 'Narx', trailing: Icons.expand_more),
                      const OtChip(label: 'Holati', trailing: Icons.expand_more),
                    ],
                  ),
                  const SizedBox(height: OtSize.x24),

                  _section('Segment'),
                  OtSegmented<String>(
                    options: const {'fresh': 'Yangi', 'used': 'Ishlatilgan'},
                    value: _condition,
                    onChanged: (v) => setState(() => _condition = v),
                  ),
                  const SizedBox(height: OtSize.x24),

                  _section('Maydonlar'),
                  const OtTextField(
                    label: 'Sarlavha',
                    hint: 'Masalan: Yumshoq burchak divan',
                    helper: 'Aniq yozganingiz sari tezroq sotiladi.',
                  ),
                  const SizedBox(height: OtSize.x16),
                  const OtTextField(
                    label: 'Narx (soʻm)',
                    hint: '0',
                    error: 'Narxni kiriting',
                  ),
                  const SizedBox(height: OtSize.x16),
                  const OtTextField(
                    label: 'Tavsif',
                    optional: true,
                    multiline: true,
                    hint: 'Mahsulot holati, xususiyatlari…',
                  ),
                  const SizedBox(height: OtSize.x24),

                  _section('Boʻsh holat'),
                  Container(
                    height: 300,
                    decoration: BoxDecoration(
                      color: OtColors.surface,
                      borderRadius: BorderRadius.circular(OtSize.rCard),
                      border: Border.all(color: OtColors.line),
                    ),
                    child: const EmptyState(
                      icon: Icons.notifications_none,
                      title: 'Bildirishnomalar yoʻq',
                      body: 'Qidiruvni saqlab qoʻysangiz, mos eʼlon '
                          'chiqqanda birinchi boʻlib xabar beramiz.',
                      actionLabel: 'Qidiruvni saqlash',
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _header(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(OtSize.screenPad, 10, OtSize.screenPad, 12),
      decoration: const BoxDecoration(
        color: OtColors.surface,
        border: Border(bottom: BorderSide(color: OtColors.lineFaint)),
      ),
      child: Row(
        children: [
          GestureDetector(
            onTap: () => Navigator.of(context).pop(),
            behavior: HitTestBehavior.opaque,
            child: const SizedBox(
              width: OtSize.minTap,
              height: OtSize.minTap,
              child: Align(
                alignment: Alignment.centerLeft,
                child: Icon(Icons.arrow_back_ios_new,
                    size: 20, color: OtColors.ink),
              ),
            ),
          ),
          Text('Komponentlar', style: OtText.display),
        ],
      ),
    );
  }

  Widget _section(String title) => Padding(
        padding: const EdgeInsets.only(bottom: 12),
        child: Text(title, style: OtText.section),
      );

  Widget _swatches() {
    const items = <(String, Color)>[
      ('accent', OtColors.accent),
      ('accentSoft', OtColors.accentSoft),
      ('ink', OtColors.ink),
      ('inkMuted', OtColors.inkMuted),
      ('inkFaint', OtColors.inkFaint),
      ('ground', OtColors.ground),
      ('field', OtColors.field),
      ('line', OtColors.line),
      ('danger', OtColors.danger),
      ('warnBg', OtColors.warnBg),
    ];
    return Wrap(
      spacing: 10,
      runSpacing: 10,
      children: [
        for (final (name, color) in items)
          Column(
            children: [
              Container(
                width: 52,
                height: 40,
                decoration: BoxDecoration(
                  color: color,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: OtColors.lineStrong),
                ),
              ),
              const SizedBox(height: 5),
              SizedBox(
                width: 56,
                child: Text(name,
                    textAlign: TextAlign.center, style: OtText.mono),
              ),
            ],
          ),
      ],
    );
  }
}
