import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'home.dart';
import '../drivers/screens/form_driver.dart';
import '../passengers/screens/form_passenger.dart';
import '../profil/profil.dart';
import '../auth/screens/login.dart'; // à créer pour login stylé
import '../auth/screens/admin_dashboard.dart'; // à créer pour l’admin

class Wrapper extends StatelessWidget {
  const Wrapper({super.key});

  Future<String?> _getUserRole(String uid) async {
    try {
      final doc =
          await FirebaseFirestore.instance.collection('users').doc(uid).get();
      if (doc.exists) {
        return doc['role'] as String?;
      }
    } catch (e) {
      print("Erreur Firestore: $e");
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        // Pas encore d’info sur l’utilisateur
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        // Utilisateur non connecté → page login
        if (!snapshot.hasData) {
          return const LoginPage(); // 🔥 page de connexion stylée
        }

        // Utilisateur connecté
        final user = snapshot.data!;
        return FutureBuilder<String?>(
          future: _getUserRole(user.uid),
          builder: (context, roleSnapshot) {
            if (roleSnapshot.connectionState == ConnectionState.waiting) {
              return const Scaffold(
                body: Center(child: CircularProgressIndicator()),
              );
            }

            final role = roleSnapshot.data;

            switch (role) {
              case 'admin':
                return const AdminDashboard();
              case 'driver':
              case 'passenger':
                return const HomePage();
              default:
                return const ProfilScreen(); // fallback si pas de rôle
            }
          },
        );
      },
    );
  }
}
