import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_application_4/alumnos_page.dart';
import 'package:flutter_application_4/sitios_turisticos.dart';
import 'productos_page.dart';
import 'alumnos_page.dart';
import 'chat.dart';


void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: const FirebaseOptions(
      apiKey:"AIzaSyAdVyyDrM3ancdYsZ6lR7J3dVvi637t8E8",
      authDomain:"fluttergr1.firebaseapp.com",
      projectId:"fluttergr1",
      storageBucket:"fluttergr1.firebasestorage.app",
      messagingSenderId:"928922118839",
      appId:"1:928922118839:web:1e586432c3c516d0bcbb32"
    ),
  );

  runApp (const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp ({super.key});

  @override
  Widget build (BuildContext context) {
    return MaterialApp(
      title: "Productos de la tienda",
      theme: ThemeData(primarySwatch: Colors.blue),
      home: TurismoPage(),
    );
  }
}