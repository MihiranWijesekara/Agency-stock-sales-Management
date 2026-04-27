import 'package:chicken_dilivery/pages/dashboard.dart';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:sqflite_common_ffi_web/sqflite_ffi_web.dart';
import 'database/database_helper.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  if (kIsWeb) {
    databaseFactory = databaseFactoryFfiWeb;
  } else if (defaultTargetPlatform == TargetPlatform.windows ||
      defaultTargetPlatform == TargetPlatform.linux ||
      defaultTargetPlatform == TargetPlatform.macOS) {
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
  }

  try {
    await DatabaseHelper.instance.database;
  } catch (e) {
    if (kIsWeb) {
      // Fallback for browsers/environments where shared-worker init can fail.
      databaseFactory = databaseFactoryFfiWebNoWebWorker;
      await DatabaseHelper.instance.database;
    } else {
      rethrow;
    }
  }
  print(
    '[APP] DB opened. Tables: ${await DatabaseHelper.instance.getAllTableNames()}',
  );

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Chicken Sales',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(),
      home: const DashboardPage(),
      // home: const Printpage(),
    );
  }
}
