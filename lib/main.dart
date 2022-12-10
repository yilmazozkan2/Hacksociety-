import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:untitled1/LocaleStrings.dart';
import 'pages/login_page.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';

main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  await GetStorage.init();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
        translations: LocalString(),
        locale: Locale('en', 'US'),
        home: Iskele());
  }
}
