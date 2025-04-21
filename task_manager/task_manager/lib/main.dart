import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:task_manager/core/routes/app_pages.dart';
import 'package:task_manager/core/routes/routes.dart';
import 'package:task_manager/core/themes/app_theme.dart';
import 'package:task_manager/firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  await GetStorage.init();
  Get.put(ThemeController());

  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  final ThemeController themeController = Get.find<ThemeController>();

  MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return Obx(
      () => GetMaterialApp(
        title: 'Task Manager',
        theme: AppTheme.light,
        darkTheme: AppTheme.dark,
        themeMode:
            Get.find<ThemeController>().isDarkMode.value
                ? ThemeMode.dark
                : ThemeMode.light,
        debugShowCheckedModeBanner: false,
        initialRoute: Routes.AUTH,
        getPages: AppPages.pages,
      ),
    );
  }
}
