import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'app.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();

  // Release'da widget xatosi bo'm-bo'sh qora ekran bo'lib ko'rinadi va
  // nima bo'lganini bilib bo'lmaydi. Hech bo'lmasa matnini ko'rsatamiz.
  ErrorWidget.builder = (details) => Material(
        color: const Color(0xFFFFFFFF),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Center(
            child: Text(
              'Ekranni ochib boʻlmadi.\n\n${details.exception}',
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 13, color: Color(0xFF6B7A72)),
            ),
          ),
        ),
      );

  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
      statusBarBrightness: Brightness.light,
    ),
  );
  runApp(const OsonTopApp());
}
