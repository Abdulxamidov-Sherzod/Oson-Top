import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/theme/ot_colors.dart';
import '../../core/theme/ot_sizes.dart';
import '../../core/theme/ot_text.dart';
import '../../data/repositories/create_listing_repository.dart';
import '../../data/repositories/reference_repository.dart';
import '../../data/models/listing.dart';
import '../../shared/widgets/district_sheet.dart';
import '../../shared/widgets/ot_button.dart';
import '../../shared/widgets/ot_segmented.dart';
import '../../shared/widgets/ot_text_field.dart';
import '../map_picker/map_picker_screen.dart';
import '../search/widgets/filter_sheets.dart';
import 'create_listing_form.dart';
import 'review_step.dart';
import 'widgets/form_rows.dart';
import 'widgets/location_field.dart';
import 'widgets/photo_picker.dart';
import '../../core/lang.dart';

class CreateListingScreen extends StatelessWidget {
  const CreateListingScreen({super.key, this.onClose, this.editing});

  /// Tab sifatida ochilganda X bosh sahifaga qaytaradi
  final VoidCallback? onClose;

  /// Berilsa — yangi e'lon emas, shuni tahrirlaymiz
  final Listing? editing;

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (ctx) => CreateListingForm(
        ctx.read<CreateListingRepository>(),
        districts: ctx.read<ReferenceRepository>().cachedDistricts,
        editing: editing,
      ),
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

  /// Formadagi maydonlarni bitta qamrovga yig'amiz: qaysidir biri
  /// tanlanganda klaviatura ustida "Tayyor" chiqadi va shu qamrovni
  /// bir harakatda bo'shatadi.
  final _fields = FocusScopeNode();

  @override
  void initState() {
    super.initState();
    _fields.addListener(_onFocusChanged);
  }

  void _onFocusChanged() => setState(() {});

  @override
  void dispose() {
    _fields.removeListener(_onFocusChanged);
    _fields.dispose();
    _title.dispose();
    _description.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final form = context.watch<CreateListingForm>();

    return Material(
      color: OtColors.surface,
      child: SafeArea(
        bottom: false,
        child: FocusScope(
          node: _fields,
          child: GestureDetector(
            // Bo'sh joyga bosilganda klaviatura yopiladi — raqam
            // klaviaturasida boshqa yo'l yo'q
            onTap: _fields.unfocus,
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
                    onAdd: form.addPhotos,
                    onRemove: form.removePhoto,
                    onRetry: form.retryPhoto,
                  ),
                  const SizedBox(height: 18),
                  OtTextField(
                    label: tr('Sarlavha'),
                    controller: _title,
                    hint: tr('Masalan: Yumshoq burchak divan'),
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
                          label: tr('Kategoriya'),
                          value: context
                              .read<ReferenceRepository>()
                              .labelOf(form.categoryId),
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
                  Text(tr('Holati'), style: OtText.label),
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
                    lat: form.lat,
                    lng: form.lng,
                    onDistrictTap: () async {
                      final picked = await showDistrictSheet(
                        context,
                        form.district,
                        context.read<ReferenceRepository>().cachedDistricts,
                      );
                      if (!mounted || picked == null) return;
                      form.setDistrict(picked);
                    },
                    onMapTap: () => _openMapPicker(form),
                    onClear: () => form.setPoint(),
                  ),
                  const SizedBox(height: 18),
                  OtTextField(
                    label: tr('Tavsif'),
                    controller: _description,
                    optional: true,
                    multiline: true,
                    hint: tr('Mahsulot holati, xususiyatlari, nima uchun sotayotganingiz…'),
                    maxLength: 1000,
                    onChanged: form.setDescription,
                  ),
                  const SizedBox(height: 18),
                  _phoneNote(),
                ],
              ),
            ),
            _footer(form),
          ],
            ),
          ),
        ),
      ),
    );
  }

  /// Raqam Telegram orqali tasdiqlangan — qayta so'ramaymiz
  Widget _phoneNote() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 13),
      decoration: BoxDecoration(
        color: OtColors.fieldSoft,
        borderRadius: BorderRadius.circular(OtSize.rMd),
        border: Border.all(color: OtColors.line),
      ),
      child: Row(
        children: [
          const Icon(Icons.verified_outlined,
              size: 17, color: OtColors.accent),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              tr('Aloqa uchun Telegramda tasdiqlagan raqamingiz ishlatiladi. U eʼlonda yopiq turadi.'),
              style: OtText.metaSm.copyWith(height: 1.45),
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
              Expanded(
                child: Text(
                  tr(context.read<CreateListingForm>().isEditing
                      ? 'Eʼlonni tahrirlash'
                      : 'Eʼlon berish'),
                  style: OtText.display,
                ),
              ),
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
              Text(tr('1-qadam / 2'),
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
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Klaviatura ochiq turganda — uni yopish uchun. iOS'ning raqam
          // klaviaturasida "return" tugmasi yo'q, ya'ni boshqa yo'li yo'q.
          if (_fields.hasFocus)
            Align(
              alignment: Alignment.centerRight,
              child: GestureDetector(
                onTap: _fields.unfocus,
                behavior: HitTestBehavior.opaque,
                child: Padding(
                  padding: const EdgeInsets.only(bottom: 6),
                  child: SizedBox(
                    height: 32,
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(tr('Tayyor'),
                            style: OtText.link.copyWith(fontSize: 15)),
                        const SizedBox(width: 5),
                        const Icon(Icons.keyboard_hide_outlined,
                            size: 18, color: OtColors.accent),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          OtButton(
            label: tr('Davom etish'),
            trailingIcon: Icons.arrow_forward,
            large: true,
            onPressed: () => _next(form),
          ),
        ],
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

  /// Xaritada nuqta tanlash. Nuqta ixtiyoriy — tuman ham yetarli.
  Future<void> _openMapPicker(CreateListingForm form) async {
    final picked = await Navigator.of(context).push<PickedPoint>(
      MaterialPageRoute(
        builder: (_) => MapPickerScreen(
          initial: form.lat == null
              ? null
              : PickedPoint(
                  lat: form.lat!,
                  lng: form.lng!,
                  address: form.address,
                ),
        ),
      ),
    );
    if (picked == null) return;
    form.setPoint(
      address: picked.address,
      lat: picked.lat,
      lng: picked.lng,
    );
  }
}
