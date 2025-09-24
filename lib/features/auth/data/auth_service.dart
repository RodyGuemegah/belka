import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  // Inscription avec rôle
  Future<User?> register(String email, String password, String role, String displayName) async {
    try {
      UserCredential result = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      User? user = result.user;
      if (user != null) {
        await _db.collection("users").doc(user.uid).set({
          "email": email,
          "role": role,
          "displayName": displayName,
          "createdAt": FieldValue.serverTimestamp(),
        });
        await user.sendEmailVerification();
      }
      return user;
    } on FirebaseAuthException catch (e) {
      switch (e.code) {
        case 'email-already-in-use':
          throw Exception('Cet email est déjà utilisé.');
        case 'invalid-email':
          throw Exception('Email invalide.');
        case 'weak-password':
          throw Exception('Mot de passe trop faible.');
        default:
          throw Exception('Erreur inscription: ${e.message}');
      }
    } catch (e) {
      throw Exception('Erreur inscription: $e');
    }
  }

  // Connexion
  Future<User?> login(String email, String password) async {
    try {
      UserCredential result = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      return result.user;
    } on FirebaseAuthException catch (e) {
      switch (e.code) {
        case 'user-not-found':
          throw Exception('Utilisateur non trouvé.');
        case 'wrong-password':
          throw Exception('Mot de passe incorrect.');
        case 'invalid-email':
          throw Exception('Email invalide.');
        default:
          throw Exception('Erreur connexion: ${e.message}');
      }
    } catch (e) {
      throw Exception('Erreur connexion: $e');
    }
  }

  // Réinitialisation du mot de passe
  Future<void> resetPassword(String email) async {
    try {
      await _auth.sendPasswordResetEmail(email: email);
    } on FirebaseAuthException catch (e) {
      switch (e.code) {
        case 'user-not-found':
          throw Exception('Utilisateur non trouvé.');
        case 'invalid-email':
          throw Exception('Email invalide.');
        default:
          throw Exception('Erreur réinitialisation: ${e.message}');
      }
    } catch (e) {
      throw Exception('Erreur réinitialisation: $e');
    }
  }

  // Déconnexion
  Future<void> logout() async {
    await _auth.signOut();
  }

  // Récupérer rôle utilisateur
  Future<String?> getUserRole(String uid) async {
    DocumentSnapshot doc = await _db.collection("users").doc(uid).get();
    return doc.exists ? doc["role"] : null;
  }
}
