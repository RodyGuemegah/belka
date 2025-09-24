import 'package:belka_app/features/auth/screens/inscription.dart';
import 'package:belka_app/features/dashboard/wrapper.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';

import 'core/firebase_options.dart';
import 'features/drivers/screens/drivers_list.dart';
import 'features/events/events.dart';
import 'features/events/events_list.dart';
import 'features/drivers/screens/form_driver.dart';
import 'features/passengers/screens/form_passenger.dart';
import 'features/dashboard/home.dart';
import 'features/profil/profil.dart';
import 'core/app_router.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  ); 
  runApp(const BelkaApp());
}

class BelkaApp extends StatelessWidget {
  const BelkaApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Belka Covoiturage',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color.fromARGB(255, 0, 8, 9),
          primary: const Color.fromARGB(255, 0, 5, 6),
          secondary: const Color(0xFFFFD600),
          background: Colors.white,
          onPrimary: Colors.white,
          onSecondary: Colors.black,
        ),
        scaffoldBackgroundColor: Colors.white,
        fontFamily: 'Montserrat',
        useMaterial3: true,
      ),
      routes: {
        '/form-passenger': (context) => const FormPassenger(),
        '/form-driver': (context) => const FormDriver(),
        '/drivers-list': (context) => const DriversList(),
        '/events-list': (context) => const EventsListPage(),
        '/events': (context) =>
            const EventCarpoolPage(eventTitle: "Événement"),
        '/profil': (context) => const ProfilScreen(),
        '/register': (context) => const RegisterPage(),
        '/home': (context) => const HomePage(),
      },
      home: const Wrapper(), // ✅ Wrapper devient la porte d'entrée
    );
  }
}
