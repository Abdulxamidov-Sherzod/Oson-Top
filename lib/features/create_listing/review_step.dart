import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/theme/ot_colors.dart';
import '../../core/theme/ot_sizes.dart';
import '../../core/theme/ot_text.dart';
import '../../data/models/listing.dart';
import '../../data/repositories/reference_repository.dart';
import '../../shared/widgets/listing_card.dart';
import '../../shared/widgets/ot_button.dart';
import 'create_listing_form.dart';
import '../../core/lang.dart';

/// 2-qadam: e'lon lentada qanday ko'rinishini ko'rsatamiz va tasdiqlaymiz.
class ReviewStep extends StatefulWidget {
  const ReviewStep({super.key, this.onDone});

  /// Muvaffaqiyatli joylangandan keyin bosh sahifaga qaytarish
  final VoidCallback? onDone;

  @override
  State<ReviewStep> createState() => _ReviewStepState();
}

class _ReviewStepState extends State<ReviewStep> {
  bool _posted = false;

  Future<void> _submit(CreateListingForm form) async {
    final ok = await form.submit();
    if (!mounted) return;
    if (ok) {
      setState(() => _posted = true);
      return;
    }
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(tr(form.submitError ?? 'Joylab boʻlmadi'))),
    );
  }

  @override
  Widget build(BuildContext context) {
    final form = context.watch<CreateListingForm>();

    return Scaffold(
      backgroundColor: OtColors.surface,
      body: SafeArea(
        bottom: false,
        child: _posted ? _success(form) : _review(form),
      ),
    );
  }

  // ---------- ko'rib chiqish ----------

  Widget _review(CreateListingForm form) {
    final draft = form.preview();

    return Column(
      children: [
        _header(),
        Expanded(
          child: ListView(
            padding: const EdgeInsets.fromLTRB(
                OtSize.screenPad, OtSize.x16, OtSize.screenPad, OtSize.x24),
            children: [
              Text(tr('Koʻrib chiqing'),
                  style: OtText.titleSm.copyWith(fontSize: 21)),
              const SizedBox(height: 5),
              Text(
                tr('Eʼloningiz lentada xaridorlarga shunday koʻrinadi.'),
                style: OtText.metaMd,
              ),
              const SizedBox(height: OtSize.x16),
              Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: OtSize.x16, vertical: 14),
                decoration: BoxDecoration(
                  color: OtColors.fieldSoft,
                  borderRadius: BorderRadius.circular(OtSize.rXl),
                  border: Border.all(color: OtColors.line),
                ),
                child: Center(
                  child: SizedBox(
                    width: 175,
                    height: ListingCard.totalHeight,
                    child: ListingCard(listing: draft),
                  ),
                ),
              ),
              const SizedBox(height: OtSize.x20),
              Row(
                children: [
                  Expanded(child: Text(tr('Maʼlumotlar'), style: OtText.section)),
                  GestureDetector(
                    onTap: () => Navigator.of(context).pop(),
                    behavior: HitTestBehavior.opaque,
                    child: Padding(
                      padding: EdgeInsets.symmetric(vertical: 8, horizontal: 4),
                      child: Text(tr('Oʻzgartirish'), style: OtText.link),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 9),
              _summary(form),
              const SizedBox(height: OtSize.x16),
              _moderationNote(),
            ],
          ),
        ),
        _footer(form),
      ],
    );
  }

  Widget _summary(CreateListingForm form) {
    final rows = <(String, String)>[
      ('Kategoriya', context.read<ReferenceRepository>().labelOf(form.categoryId)),
      ('Holati', form.condition.label),
      (
        'Joylashuv',
        form.address == null
            ? form.district
            : '${form.district}\n${form.address}'
      ),
      if (form.description.trim().isNotEmpty)
        ('Tavsif', form.description.trim()),

    ];

    return Container(
      decoration: BoxDecoration(
        color: OtColors.fieldSoft,
        borderRadius: BorderRadius.circular(OtSize.rLg),
        border: Border.all(color: OtColors.line),
      ),
      child: Column(
        children: [
          for (var i = 0; i < rows.length; i++)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 11),
              decoration: BoxDecoration(
                border: i == rows.length - 1
                    ? null
                    : const Border(
                        bottom: BorderSide(color: OtColors.line)),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(rows[i].$1, style: OtText.metaMd),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Text(
                      rows[i].$2,
                      textAlign: TextAlign.right,
                      maxLines: 3,
                      overflow: TextOverflow.ellipsis,
                      style: OtText.bodyStrong.copyWith(fontSize: 13.5),
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  Widget _moderationNote() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 13),
      decoration: BoxDecoration(
        color: OtColors.accentSofter,
        borderRadius: BorderRadius.circular(OtSize.rCard),
        border: Border.all(color: OtColors.accentLine),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.info_outline, size: 17, color: OtColors.accentPressed),
          SizedBox(width: 10),
          Expanded(
            child: Text(
              tr('Moderatsiyadan oʻtgach eʼlon saytda paydo boʻladi — odatda 15 daqiqa. Tayyor boʻlganda bildirishnoma keladi.'),
              style: TextStyle(
                fontSize: 12.5,
                height: 1.5,
                color: OtColors.accentInk,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _header() {
    return Container(
      padding: const EdgeInsets.fromLTRB(
          OtSize.screenPad, 10, OtSize.screenPad, 12),
      decoration: const BoxDecoration(
        border: Border(bottom: BorderSide(color: OtColors.lineFaint)),
      ),
      child: Column(
        children: [
          Row(
            children: [
              GestureDetector(
                onTap: () => Navigator.of(context).pop(),
                behavior: HitTestBehavior.opaque,
                child: const SizedBox(
                  width: 36,
                  height: OtSize.minTap,
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: Icon(Icons.arrow_back_ios_new,
                        size: 20, color: OtColors.ink),
                  ),
                ),
              ),
              Expanded(
                child: Text(
                  tr(context.read<CreateListingForm>().isEditing
                      ? 'Eʼlonni tahrirlash'
                      : 'Eʼlon berish'),
                  style: OtText.display,
                ),
              ),
            ],
          ),
          const SizedBox(height: OtSize.x12),
          Row(
            children: [
              Expanded(child: _bar()),
              const SizedBox(width: 10),
              Expanded(child: _bar()),
              const SizedBox(width: 10),
              Text(tr('2-qadam / 2'),
                  style: TextStyle(
                    fontSize: 11.5,
                    fontWeight: FontWeight.w600,
                    color: OtColors.inkMuted,
                  )),
            ],
          ),
        ],
      ),
    );
  }

  Widget _bar() => Container(
        height: 4,
        decoration: BoxDecoration(
          color: OtColors.accent,
          borderRadius: BorderRadius.circular(3),
        ),
      );

  Widget _footer(CreateListingForm form) {
    return Container(
      padding: EdgeInsets.fromLTRB(OtSize.screenPad, 12, OtSize.screenPad,
          12 + MediaQuery.paddingOf(context).bottom),
      decoration: const BoxDecoration(
        border: Border(top: BorderSide(color: OtColors.line)),
      ),
      child: Row(
        children: [
          Expanded(
            child: OtButton(
              label: tr('Orqaga'),
              kind: OtButtonKind.secondary,
              large: true,
              onPressed: () => Navigator.of(context).pop(),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            flex: 16,
            child: OtButton(
              label: form.submitting
                  ? tr('Saqlanmoqda…')
                  : tr(form.isEditing ? 'Saqlash' : 'Tasdiqlab joylash'),
              large: true,
              onPressed: form.submitting ? null : () => _submit(form),
            ),
          ),
        ],
      ),
    );
  }

  // ---------- muvaffaqiyat ----------

  Widget _success(CreateListingForm form) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 32),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 76,
            height: 76,
            decoration: BoxDecoration(
              color: OtColors.accentSoft,
              borderRadius: BorderRadius.circular(26),
              border: Border.all(color: OtColors.accentLine),
            ),
            child: const Icon(Icons.check_rounded,
                size: 38, color: OtColors.accent),
          ),
          const SizedBox(height: OtSize.x20),
          Text(
            tr(form.isEditing ? 'Oʻzgarishlar saqlandi' : 'Eʼlon yuborildi'),
            style: OtText.titleSm.copyWith(fontSize: 23),
          ),
          const SizedBox(height: OtSize.x8),
          Text(
            tr(switch ((form.isEditing, form.resultStatus)) {
              // Tahrirlangan eʼlon lentada qolgan — faqat narx yoki tuman
              // oʻzgargan boʻlsa shunday boʻladi
              (true, ListingStatus.active) => 'Eʼlon lentada yangilandi.',
              (true, _) =>
                'Matn yoki rasm oʻzgargani uchun eʼlon qaytadan tekshiruvga yuborildi.',
              _ =>
                'Moderator tekshirgach eʼloningiz saytda paydo boʻladi. Tayyor boʻlganda bildirishnoma keladi.',
            }),
            textAlign: TextAlign.center,
            style: TextStyle(
                fontSize: 14.5, height: 1.6, color: OtColors.inkMuted),
          ),
          const SizedBox(height: OtSize.x24),
          OtButton(
            label: tr(form.isEditing ? 'Eʼlonlarimga qaytish' : 'Asosiy sahifaga'),
            kind: OtButtonKind.secondary,
            onPressed: () {
              final nav = Navigator.of(context);
              nav.pop();
              if (form.isEditing) {
                // Ikkinchisi — tahrirlash ekranining o'zi. true qaytsa
                // "mening e'lonlarim" ro'yxatni yangilaydi.
                nav.pop(true);
                return;
              }
              widget.onDone?.call();
            },
          ),
        ],
      ),
    );
  }
}
