import 'dart:async';

import 'package:flutter/material.dart';
import 'package:yandex_mapkit/yandex_mapkit.dart';

import '../../core/theme/ot_colors.dart';
import '../../core/theme/ot_sizes.dart';
import '../../core/theme/ot_text.dart';
import '../../data/geo/geocoding.dart';
import '../../data/geo/user_location.dart';
import '../../shared/widgets/ot_button.dart';
import '../../core/lang.dart';

/// Xaritada tanlangan nuqta
class PickedPoint {
  const PickedPoint({required this.lat, required this.lng, this.address});

  final double lat;
  final double lng;
  final String? address;
}

/// Xaritada joy belgilash.
///
/// Pin markazda qotib turadi, xaritaning o'zi suriladi — mobil qurilmada
/// shu usul eng qulay: barmoq pinni to'sib qo'ymaydi.
class MapPickerScreen extends StatefulWidget {
  const MapPickerScreen({super.key, this.initial});

  final PickedPoint? initial;

  /// Farg'ona shahri markazi — boshlang'ich nuqta
  static const _fergana = Point(latitude: 40.3894, longitude: 71.7864);

  @override
  State<MapPickerScreen> createState() => _MapPickerScreenState();
}

class _MapPickerScreenState extends State<MapPickerScreen> {
  YandexMapController? _controller;
  late Point _center = widget.initial == null
      ? MapPickerScreen._fergana
      : Point(
          latitude: widget.initial!.lat,
          longitude: widget.initial!.lng,
        );

  String? _address;
  bool _resolving = false;
  bool _locating = false;
  Timer? _debounce;

  /// Xarita boshlangʻich nuqtaga kelgunicha kamera hodisalarini eʼtiborsiz
  /// qoldiramiz — aks holda dunyoning markazi manzil sifatida olinadi.
  bool _ready = false;

  @override
  void initState() {
    super.initState();
    _address = widget.initial?.address;
  }

  @override
  void dispose() {
    _debounce?.cancel();
    super.dispose();
  }

  /// Xarita to'xtagach manzilni yangilaymiz — har harakatda so'ramaymiz
  void _onCameraChanged(CameraPosition position, CameraUpdateReason _, bool finished) {
    if (!_ready) return;
    _center = position.target;
    if (!finished) return;

    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 400), _resolve);
  }

  Future<void> _resolve() async {
    setState(() => _resolving = true);
    final address = await Geocoding.addressOf(_center);
    if (!mounted) return;
    setState(() {
      _address = address;
      _resolving = false;
    });
  }

  /// "Turgan joyim" tugmasi.
  ///
  /// MapKit'ning `getUserCameraPosition` usuli bu yerda ishlamaydi: u ruxsat
  /// allaqachon berilgan boʻlishini talab qiladi va soʻramaydi. Koordinatani
  /// geolocator beradi, MapKit'ga esa faqat koʻk nuqta uchun xabar qilamiz.
  Future<void> _locateMe() async {
    if (_locating) return;
    setState(() => _locating = true);

    final outcome = await UserLocation.current();
    if (!mounted) return;
    setState(() => _locating = false);

    switch (outcome) {
      case LocateFailed(:final reason):
        _showProblem(reason);
      case LocateOk(:final point):
        _center = point;
        // Ruxsat endi bor — foydalanuvchi joyi koʻk nuqta bilan koʻrinsin
        await _controller?.toggleUserLayer(visible: true);
        // Manzil kamera toʻxtagach yangilanadi — surib tanlagandagi kabi
        await _controller?.moveCamera(
          CameraUpdate.newCameraPosition(
            CameraPosition(target: point, zoom: 16),
          ),
          animation: const MapAnimation(duration: 0.4),
        );
    }
  }

  void _showProblem(LocateProblem reason) {
    final (message, settings) = switch (reason) {
      LocateProblem.serviceOff => (
          'Qurilmada joylashuv xizmati oʻchiq',
          false,
        ),
      LocateProblem.denied => ('Joylashuvga ruxsat berilmadi', false),
      LocateProblem.deniedForever => (
          'Joylashuvga ruxsat yopiq — Sozlamalardan oching',
          true,
        ),
      LocateProblem.notFound => (
          'Joylashuv aniqlanmadi, qaytadan urinib koʻring',
          false,
        ),
    };

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(tr(message)),
        action: settings
            ? SnackBarAction(
                label: tr('Sozlamalar'),
                onPressed: UserLocation.openSettings,
              )
            : null,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: OtColors.surface,
      body: Stack(
        children: [
          YandexMap(
            onMapCreated: (controller) async {
              _controller = controller;
              // Widget joylashib bo'lgach kamera ko'chiriladi — aks holda
              // xarita hali o'lchamsiz bo'lib, ko'chirish e'tiborsiz qoladi
              await WidgetsBinding.instance.endOfFrame;
              if (!mounted) return;
              await controller.moveCamera(
                CameraUpdate.newCameraPosition(
                  CameraPosition(target: _center, zoom: 16),
                ),
              );
              if (!mounted) return;
              _ready = true;
              if (_address == null) unawaited(_resolve());
            },
            onCameraPositionChanged: _onCameraChanged,
          ),
          // Markazdagi pin — xarita bilan birga qimirlamaydi
          const Center(
            child: Padding(
              padding: EdgeInsets.only(bottom: 44),
              child: _CenterPin(),
            ),
          ),
          // Pastki panel ekran tagigacha choʻziladi, tepasi esa
          // status bar ostiga tushmasin
          SafeArea(
            bottom: false,
            child: Column(
              children: [
                _topBar(),
                const Spacer(),
                _locateButton(),
                _bottomSheet(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _topBar() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(OtSize.screenPad, 6, OtSize.screenPad, 0),
      child: Row(
        children: [
          _floating(
            Icons.arrow_back_ios_new,
            onTap: () => Navigator.of(context).pop(),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Container(
              height: 44,
              padding: const EdgeInsets.symmetric(horizontal: 14),
              decoration: BoxDecoration(
                color: OtColors.surface,
                borderRadius: BorderRadius.circular(15),
                boxShadow: const [
                  BoxShadow(
                    color: OtColors.liftShadow,
                    blurRadius: 10,
                    offset: Offset(0, 2),
                  ),
                ],
              ),
              child: Row(
                children: [
                  const Icon(Icons.place_outlined,
                      size: 17, color: OtColors.accent),
                  const SizedBox(width: 9),
                  Expanded(
                    child: Text(
                      _address ?? tr('Xaritani suring'),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 14.5,
                        color: _address == null
                            ? OtColors.inkFaint
                            : OtColors.ink,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _locateButton() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(0, 0, OtSize.screenPad, 12),
      child: Align(
        alignment: Alignment.centerRight,
        child: _floating(
          Icons.my_location,
          onTap: _locateMe,
          size: 44,
          busy: _locating,
        ),
      ),
    );
  }

  Widget _floating(IconData icon,
      {required VoidCallback onTap, double size = 40, bool busy = false}) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          color: OtColors.surface,
          borderRadius: BorderRadius.circular(size / 2.8),
          boxShadow: const [
            BoxShadow(
              color: OtColors.liftShadow,
              blurRadius: 10,
              offset: Offset(0, 2),
            ),
          ],
        ),
        child: busy
            ? const Center(
                child: SizedBox(
                  width: 17,
                  height: 17,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: OtColors.accent,
                  ),
                ),
              )
            : Icon(icon, size: 19, color: OtColors.ink),
      ),
    );
  }

  Widget _bottomSheet() {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.fromLTRB(
        OtSize.screenPad,
        16,
        OtSize.screenPad,
        16 + MediaQuery.paddingOf(context).bottom,
      ),
      decoration: const BoxDecoration(
        color: OtColors.surface,
        borderRadius: BorderRadius.vertical(top: Radius.circular(OtSize.rSheet)),
        boxShadow: [
          BoxShadow(
            color: OtColors.liftShadow,
            blurRadius: 24,
            offset: Offset(0, -6),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 36,
            height: 4,
            decoration: BoxDecoration(
              color: OtColors.lineField,
              borderRadius: BorderRadius.circular(3),
            ),
          ),
          const SizedBox(height: OtSize.x16),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 38,
                height: 38,
                decoration: BoxDecoration(
                  color: OtColors.accentSoft,
                  borderRadius: BorderRadius.circular(13),
                ),
                child: const Icon(Icons.place_outlined,
                    size: 18, color: OtColors.accent),
              ),
              const SizedBox(width: 11),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _resolving
                          ? tr('Manzil aniqlanmoqda…')
                          : (_address ?? tr('Manzil topilmadi')),
                      style: OtText.bodyStrong,
                    ),
                    const SizedBox(height: 3),
                    Text(
                      '${_center.latitude.toStringAsFixed(5)}, ${_center.longitude.toStringAsFixed(5)}',
                      style: OtText.metaSm,
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: OtSize.x12),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 11),
            decoration: BoxDecoration(
              color: OtColors.fieldSoft,
              borderRadius: BorderRadius.circular(OtSize.rMd),
              border: Border.all(color: OtColors.line),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Icon(Icons.info_outline,
                    size: 16, color: OtColors.inkFaint),
                const SizedBox(width: 9),
                Expanded(
                  child: Text(
                    tr('Eʼlonda taxminiy hudud koʻrsatiladi, aniq uy raqami emas.'),
                    style: OtText.metaSm.copyWith(height: 1.45),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: OtSize.x16),
          SizedBox(
            width: double.infinity,
            child: OtButton(
              label: tr('Shu joyni tanlash'),
              large: true,
              onPressed: () => Navigator.of(context).pop(
                PickedPoint(
                  lat: _center.latitude,
                  lng: _center.longitude,
                  address: _address,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _CenterPin extends StatelessWidget {
  const _CenterPin();

  @override
  Widget build(BuildContext context) {
    return const Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(Icons.location_on, size: 46, color: OtColors.accent),
        // Pin uchi turgan joyni bildiruvchi soya
        SizedBox(
          width: 14,
          height: 5,
          child: DecoratedBox(
            decoration: BoxDecoration(
              color: Color(0x33102214),
              borderRadius: BorderRadius.all(Radius.circular(3)),
            ),
          ),
        ),
      ],
    );
  }
}
