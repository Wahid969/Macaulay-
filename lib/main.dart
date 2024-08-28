import 'dart:io';

import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';
import 'package:wahid_uber_app/driver/views/screens/driver_main_screen.dart';
import 'package:wahid_uber_app/provider/app_data.dart';
import 'package:wahid_uber_app/provider/geo_provider.dart';
import 'package:wahid_uber_app/provider/user_provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Permission.locationWhenInUse.isDenied.then((value) {
    if (value == true) {
      Permission.locationWhenInUse.request();
    }
  });
  Platform.isAndroid
      ? await Firebase.initializeApp(
          options: const FirebaseOptions(
            apiKey: "AIzaSyB_SdqRX8aYQ6LgUneHgQ4Nudw2EIIE-uc",
            appId: '1:107113386007:android:b6faa5a9aa0f3b41318c52',
            messagingSenderId: '107113386007',
            projectId: 'uber-app-439a2',
            storageBucket: "uber-app-439a2.appspot.com",
          ),
        )
      : await Firebase.initializeApp();

  runApp(MultiProvider(providers: [
    ChangeNotifierProvider(
      create: (_) {
        return AppData();
      },
    ),
    ChangeNotifierProvider(
      create: (_) {
        return UserProvider();
      },
    ),
    ChangeNotifierProvider(
      create: (_) {
        return GeofireProvider();
      },
    )
  ], child: const MyApp()));
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
      ),
    );
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Flutter Demo',
      theme: ThemeData(
        // This is the theme of your application.
        //
        // TRY THIS: Try running your application with "flutter run". You'll see

        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home:  DriverMainScreen(),
    );
  }
}
