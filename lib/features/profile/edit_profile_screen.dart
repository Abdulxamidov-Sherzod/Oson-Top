import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/lang.dart';
import '../../core/theme/ot_colors.dart';
import '../../core/theme/ot_sizes.dart';
import '../../core/theme/ot_text.dart';
import '../../data/repositories/reference_repository.dart';
import '../../shared/widgets/district_sheet.dart';
import '../../shared/widgets/ot_button.dart';
import '../../shared/widgets/ot_text_field.dart';
import '../../state/auth_controller.dart';

/// Profilni tahrirlash: ism va tuman. Telefon raqami Telegram orqali
/// tasdiqlangan, shuning uchun ilovadan oʻzgartirilmaydi.
class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  late final TextEditingController _name;

  /// Boʻsh satr — tuman tanlanmagan
  late String _district;
  late final String _initialName;
  late final String _initialDistrict;

  bool _saving = false;
  String? _nameError;

  @override
  void initState() {
    super.initState();
    final user = context.read<AuthController>().user;
    _initialName = user?.name ?? '';
    _initialDistrict = user?.district ?? '';
    _name = TextEditingController(text: _initialName);
    _district = _initialDistrict;
  }

  @override
  void dispose() {
    _name.dispose();
    super.dispose();
  }

  bool get _changed =>
      _name.text.trim() != _initialName.trim() || _district != _initialDistrict;

  String get _initials {
    final parts = _name.text.trim().split(RegExp(r'\s+'));
    final letters = parts.take(2).map((p) => p.isEmpty ? '' : p[0]).join();
    return letters.isEmpty ? '?' : letters.toUpperCase();
  }

  Future<void> _pickDistrict() async {
    final picked = await showDistrictSheet(
      context,
      _district.isEmpty ? allDistrictsLabel : _district,
      context.read<ReferenceRepository>().cachedDistricts,
    );
    if (!mounted || picked == null) return;
    // "Fargʻona viloyati" — aniq tuman emas, ya'ni tanlanmagan
    setState(() => _district = picked == allDistrictsLabel ? '' : picked);
  }

  Future<void> _save() async {
    final name = _name.text.trim();
    if (name.isEmpty) {
      setState(() => _nameError = tr('Ismingizni yozing'));
      return;
    }

    setState(() {
      _saving = true;
      _nameError = null;
    });

    final error = await context
        .read<AuthController>()
        .updateProfile(name: name, district: _district);
    if (!mounted) return;

    if (error != null) {
      setState(() => _saving = false);
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(tr(error))));
      return;
    }

    // Xabarni profil ekrani koʻrsatadi: bu yerdan chiqarilsa, snackbar
    // yopilayotgan ekranga ilashib, u bilan birga yoʻqoladi.
    Navigator.of(context).pop(true);
  }

  @override
  Widget build(BuildContext context) {
    final user = context.watch<AuthController>().user;

    return Scaffold(
      backgroundColor: OtColors.ground,
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            _header(),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.fromLTRB(
                    OtSize.screenPad, OtSize.x20, OtSize.screenPad, OtSize.x24),
                children: [
                  _avatar(),
                  const SizedBox(height: OtSize.x24),
                  OtTextField(
                    label: 'Ism',
                    controller: _name,
                    hint: tr('Ismingiz'),
                    maxLength: 80,
                    error: _nameError,
                    raised: true,
                    helper: 'Eʼlonlaringizda shu ism koʻrinadi',
                    onChanged: (_) => setState(() => _nameError = null),
                  ),
                  const SizedBox(height: OtSize.x20),
                  _districtField(),
                  const SizedBox(height: OtSize.x20),
                  _phone(user?.phone ?? ''),
                ],
              ),
            ),
            _footer(),
          ],
        ),
      ),
    );
  }

  /// Sarlavha sahifaning oʻzi bilan bir xil fonda — oq chiziq boʻlsa,
  /// tepada boshqa ekran turganday koʻrinadi. Maydonlar oq va soyali,
  /// ajratuvchi chiziq shusiz ham yetarli.
  Widget _header() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(
          OtSize.screenPad, 10, OtSize.screenPad, OtSize.x12),
      child: Row(
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
            child: Text(tr('Profilni tahrirlash'), style: OtText.display),
          ),
        ],
      ),
    );
  }

  /// Ism yozilayotganda harflar darhol oʻzgaradi — natija koʻrinib turadi
  Widget _avatar() {
    return Center(
      child: Container(
        width: 72,
        height: 72,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: OtColors.accentTint,
          borderRadius: BorderRadius.circular(24),
        ),
        child: Text(
          _initials,
          style: const TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.w700,
            color: OtColors.accentPressed,
          ),
        ),
      ),
    );
  }

  Widget _districtField() {
    final empty = _district.isEmpty;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        RichText(
          text: TextSpan(
            style: OtText.label,
            children: [
              TextSpan(text: tr('Tuman')),
              TextSpan(
                text: tr(' · ixtiyoriy'),
                style: const TextStyle(
                  fontWeight: FontWeight.w400,
                  color: OtColors.inkFaint,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 7),
        GestureDetector(
          onTap: _pickDistrict,
          behavior: HitTestBehavior.opaque,
          child: Container(
            height: OtSize.field,
            padding: const EdgeInsets.symmetric(horizontal: 14),
            decoration: BoxDecoration(
              color: OtColors.surface,
              borderRadius: BorderRadius.circular(OtSize.rMd),
              boxShadow: otFieldShadow,
            ),
            child: Row(
              children: [
                const Icon(Icons.place_outlined,
                    size: 15, color: OtColors.accent),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    tr(empty ? 'Tanlanmagan' : _district),
                    style: TextStyle(
                      fontSize: 15,
                      color: empty ? OtColors.inkFaint : OtColors.ink,
                    ),
                  ),
                ),
                const Icon(Icons.expand_more,
                    size: 18, color: OtColors.inkMuted),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _phone(String phone) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(tr('Telefon raqami'), style: OtText.label),
        const SizedBox(height: 7),
        Container(
          height: OtSize.field,
          padding: const EdgeInsets.symmetric(horizontal: 14),
          decoration: BoxDecoration(
            color: OtColors.surface,
            borderRadius: BorderRadius.circular(OtSize.rMd),
            // Soyasiz va chegarali — tahrirlanadigan maydonlardan bir pogʻona past
            border: Border.all(color: OtColors.line),
          ),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  phone,
                  style: const TextStyle(fontSize: 15, color: OtColors.inkMuted),
                ),
              ),
              const Icon(Icons.verified_outlined,
                  size: 17, color: OtColors.accent),
            ],
          ),
        ),
        const SizedBox(height: 6),
        Text(
          tr('Raqam Telegram orqali tasdiqlangan — uni ilovadan oʻzgartirib boʻlmaydi.'),
          style: OtText.metaSm,
        ),
      ],
    );
  }

  Widget _footer() {
    return Container(
      padding: EdgeInsets.fromLTRB(OtSize.screenPad, OtSize.x12,
          OtSize.screenPad, OtSize.x12 + MediaQuery.paddingOf(context).bottom),
      // Tugma tagidagi yoʻlak ham sahifa rangida — ajratish uchun ingichka
      // chiziq yetarli, oq yoʻlak esa boshqa ekranday koʻrinardi
      decoration: const BoxDecoration(
        color: OtColors.ground,
        border: Border(top: BorderSide(color: OtColors.line)),
      ),
      child: SizedBox(
        width: double.infinity,
        child: OtButton(
          label: _saving ? tr('Saqlanmoqda…') : tr('Saqlash'),
          large: true,
          onPressed: _saving || !_changed ? null : _save,
        ),
      ),
    );
  }
}
