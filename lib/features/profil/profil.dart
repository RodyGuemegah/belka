import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ProfilScreen extends StatelessWidget {
  const ProfilScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    return Scaffold(
      appBar: AppBar(
        title: const Text("Profil"),
        backgroundColor: const Color.fromARGB(255, 12, 12, 12),
        foregroundColor: const Color.fromARGB(255, 250, 250, 250),
        elevation: 1,
      ),
      body: user == null
          ? const Center(child: Text("Aucun utilisateur connecté."))
          : FutureBuilder<DocumentSnapshot>(
              future: FirebaseFirestore.instance.collection("users").doc(user.uid).get(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (!snapshot.hasData || !snapshot.data!.exists) {
                  return const Center(child: Text("Profil non trouvé."));
                }
                final data = snapshot.data!.data() as Map<String, dynamic>;
                final displayName = data["displayName"] ?? "";
                final email = data["email"] ?? user.email ?? "";
                final role = data["role"] ?? "";
                return ListView(
                  padding: const EdgeInsets.all(16),
                  children: [
                    // Carte profil dynamique
                    Card(
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                      elevation: 1,
                      child: Padding(
                        padding: const EdgeInsets.all(18),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            CircleAvatar(
                              radius: 28,
                              backgroundColor: Colors.grey.shade200,
                              child: Text(
                                displayName.isNotEmpty ? displayName[0].toUpperCase() : "?",
                                style: const TextStyle(fontSize: 22, color: Colors.black),
                              ),
                            ),
                            const SizedBox(width: 18),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Text(displayName, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
                                      const SizedBox(width: 8),
                                      Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                        decoration: BoxDecoration(
                                          color: Colors.blue.shade50,
                                          borderRadius: BorderRadius.circular(12),
                                        ),
                                        child: Text(role, style: const TextStyle(color: Colors.blue, fontWeight: FontWeight.bold, fontSize: 12)),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 6),
                                  Text(email, style: const TextStyle(fontSize: 15, color: Colors.grey)),
                                  const SizedBox(height: 12),
                                  OutlinedButton.icon(
                                    onPressed: () {},
                                    icon: const Icon(Icons.edit, size: 18),
                                    label: const Text("Modifier le profil"),
                                    style: OutlinedButton.styleFrom(
                                      foregroundColor: Colors.black,
                                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 18),
                    // Mon véhicule
                    Card(
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                      elevation: 0,
                      child: Padding(
                        padding: const EdgeInsets.all(18),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text("Mon véhicule", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                            const SizedBox(height: 10),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: const [
                                Text("Modèle", style: TextStyle(color: Colors.grey)),
                                Text("Renault Clio"),
                              ],
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: const [
                                Text("Couleur", style: TextStyle(color: Colors.grey)),
                                Text("Bleu"),
                              ],
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: const [
                                Text("Année", style: TextStyle(color: Colors.grey)),
                                Text("2020"),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 18),
                    // Préférences
                    Card(
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                      elevation: 0,
                      child: Padding(
                        padding: const EdgeInsets.all(18),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text("Préférences", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                            const SizedBox(height: 10),
                            Wrap(
                              spacing: 8,
                              children: [
                                _chip("Non-fumeur"),
                                _chip("Musique autorisée"),
                                _chip("Animaux acceptés"),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 18),
                    // Trajets récents
                    Card(
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                      elevation: 0,
                      child: Padding(
                        padding: const EdgeInsets.all(18),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text("Trajets récents", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                            const SizedBox(height: 10),
                            _trajetRecent("Festival de Jazz", "15/02/2025", "Conducteur", 5),
                            _trajetRecent("Match de Rugby", "10/02/2025", "Passager", 4),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 18),
                    // Liens rapides
                    Card(
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                      elevation: 0,
                      child: Column(
                        children: [
                          ListTile(
                            leading: const Icon(Icons.chat_bubble_outline),
                            title: const Text("Mes conversations"),
                            onTap: () {},
                          ),
                          Divider(height: 1),
                          ListTile(
                            leading: const Icon(Icons.history),
                            title: const Text("Historique des trajets"),
                            onTap: () {},
                          ),
                          Divider(height: 1),
                          ListTile(
                            leading: const Icon(Icons.settings),
                            title: const Text("Paramètres"),
                            onTap: () {},
                          ),
                          Divider(height: 1),
                          ElevatedButton(
                            onPressed: () async {
                              await FirebaseAuth.instance.signOut();
                              Navigator.pushReplacementNamed(context, '/login');
                            },
                            child: const Text('Déconnexion'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.red,
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                );
              },
            ),
    );
  }

  Widget _chip(String label) {
    return Chip(
      label: Text(label),
      backgroundColor: Colors.grey.shade100,
      labelStyle: const TextStyle(color: Colors.black),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
    );
  }

  Widget _trajetRecent(String title, String date, String role, int stars) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
                Text(date, style: const TextStyle(color: Colors.grey)),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
            decoration: BoxDecoration(
              color: role == "Conducteur" ? Colors.black : Colors.grey.shade200,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                Text(role, style: TextStyle(color: role == "Conducteur" ? Colors.white : Colors.black)),
                const SizedBox(width: 4),
                Icon(Icons.star, color: Colors.amber, size: 16),
                Text("$stars", style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.amber)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}