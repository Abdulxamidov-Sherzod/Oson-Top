import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/theme/ot_colors.dart';
import '../../core/theme/ot_sizes.dart';
import '../../core/theme/ot_text.dart';
import '../../data/mock/mock_categories.dart';
import '../../data/models/listing.dart';
import '../../data/repositories/listing_repository.dart';
import '../../shared/widgets/district_sheet.dart';
import '../../shared/widgets/ot_button.dart';
import '../../shared/widgets/ot_segmented.dart';
import '../../shared/widgets/ot_text_field.dart';
import '../search/widgets/filter_sheets.dart';
import 'create_listing_form.dart';
import 'review_step.dart';
import 'widgets/form_rows.dart';
import 'widgets/location_field.dart';
import 'widgets/photo_picker.dart';

class CreateListingScreen extends StatelessWidget {
  const CreateListingScreen({super.key, this.onClose});

  /// Tab sifatida ochilganda X bosh sahifaga qaytaradi
  final VoidCallback? onClose;

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (ctx) => CreateListingForm(ctx.read<ListingRepository>()),
      child: _FormView(onClose: onClose),
    );
  }
}

class _FormView extends StatefulWidget {
  const _FormView({this.onClose});
  final VoidCallback? onClose;

  @override
  State<_FormView> createState() => _FormViewState();
}

class _FormViewState extends State<_FormView> {
  final _title = TextEditingController();
  final _description = TextEditingController();
  final _phone = TextEditingController(text: '+998 ');

  @override
  void dispose() {
    _title.dispose();
    _description.dispose();
    _phone.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final form = context.watch<CreateListingForm>();

    return Material(
      color: OtColors.surface,
      child: SafeArea(
        bottom: false,
        child: Column(
          children: [
            _header(),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.fromLTRB(
                    OtSize.screenPad, OtSize.x16, OtSize.screenPad, OtSize.x24),
                children: [
                  PhotoPicker(
                    photos: form.photos,
                    maxPhotos: CreateListingForm.maxPhotos,
                    error: form.photosError,
                    onAdd: form.addPhoto,
                    onRemove: form.removePhoto,
                  ),
                  const SizedBox(height: 18),
                  OtTextField(
                    label: 'Sarlavha',
                    controller: _title,
                    hint: 'Masalan: Yumshoq burchak divan',
                    maxLength: 70,
                    error: form.titleError,
                    onChanged: form.setTitle,
                  ),
                  const SizedBox(height: 18),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: PickerField(
                          label: 'Kategoriya',
                          value: categoryLabel(form.categoryId),
                          onTap: () async {
                            final picked = await showCategoryFilter(
                                context, form.categoryId);
                            if (!mounted || picked == null) return;
                            form.setCategory(picked);
                          },
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: PriceField(
                          negotiable: form.negotiable,
                          error: form.priceError,
                          onPriceChanged: form.setPrice,
                          onNegotiableChanged: form.setNegotiable,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 18),
                  Text('Holati', style: OtText.label),
                  const SizedBox(height: 7),
                  OtSegmented<ListingCondition>(
                    options: const {
                      ListingCondition.fresh: 'Yangi',
                      ListingCondition.used: 'Ishlatilgan',
                    },
                    value: form.condition == ListingCondition.none
                        ? ListingCondition.used
                        : form.condition,
                    onChanged: form.setCondition,
                  ),
                  const SizedBox(height: 18),
                  LocationField(
                    district: form.district,
                    address: form.address,
                    lat: form.address == null ? null : 40.3894,
                    lng: form.address == null ? null : 71.7864,
                    onDistrictTap: () async {
                      final picked =
                          await showDistrictSheet(context, form.district);
                      if (!mounted || picked == null) return;
                      form.setDistrict(picked);
                    },
                    onMapTap: () => _openMapPicker(form),
                    onClear: () => form.setAddress(null),
                  ),
                  const SizedBox(height: 18),
                  OtTextField(
                    label: 'Tavsif',
                    controller: _description,
                    optional: true,
                    multiline: true,
                    hint: 'Mahsulot holati, xususiyatlari, nima uchun '
                        'sotayotganingiz…',
                    maxLength: 1000,
                    onChanged: form.setDescription,
                  ),
                  const SizedBox(height: 18),
                  OtTextField(
                    label: 'Aloqa uchun telefon',
                    controller: _phone,
                    keyboardType: TextInputType.phone,
                    helper: 'Raqam eʼlonda yopiq turadi — xaridor '
                        '«Raqamni koʻrsatish» ni bosgandan keyin ochiladi.',
                    error: form.phoneError,
                    onChanged: form.setPhone,
                  ),
                ],
              ),
            ),
            _footer(form),
          ],
        ),
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
              Expanded(child: Text('Eʼlon berish', style: OtText.display)),
              if (widget.onClose != null)
                GestureDetector(
                  onTap: widget.onClose,
                  behavior: HitTestBehavior.opaque,
                  child: Container(
                    width: 32,
                    height: 32,
                    decoration: const BoxDecoration(
                      color: OtColors.fieldAlt,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.close,
                        size: 16, color: OtColors.ink),
                  ),
                ),
            ],
          ),
          const SizedBox(height: OtSize.x12),
          Row(
            children: [
              Expanded(child: _progress(true)),
              const SizedBox(width: 10),
              Expanded(child: _progress(false)),
              const SizedBox(width: 10),
              const Text('1-qadam / 2',
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

  Widget _progress(bool filled) => Container(
        height: 4,
        decoration: BoxDecoration(
          color: filled ? OtColors.accent : OtColors.lineStrong,
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
      child: OtButton(
        label: 'Davom etish',
        trailingIcon: Icons.arrow_forward,
        large: true,
        onPressed: () => _next(form),
      ),
    );
  }

  void _next(CreateListingForm form) {
    if (!form.validate()) return;
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => ChangeNotifierProvider.value(
          value: form,
          child: ReviewStep(onDone: widget.onClose),
        ),
      ),
    );
  }

  /// 5-qismda haqiqiy Yandex xaritasi ulanadi. Hozircha nuqtani belgilangan
  /// deb hisoblaymiz — forma oqimi to'liq sinalsin.
  void _openMapPicker(CreateListingForm form) {
    form.setAddress(form.address == null ? 'Toshloq koʻchasi 12' : null);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Xarita 5-qismda ulanadi'),
        duration: Duration(seconds: 2),
      ),
    );
  }
}
