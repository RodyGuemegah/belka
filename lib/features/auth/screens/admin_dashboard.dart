import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';

class AdminDashboard extends StatefulWidget {
  const AdminDashboard({super.key});

  @override
  State<AdminDashboard> createState() => _AdminDashboardState();
}

class _AdminDashboardState extends State<AdminDashboard> {
  String searchQuery = '';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[900],
      appBar: AppBar(
        backgroundColor: Colors.tealAccent[700],
        title: const Text("Admin Dashboard"),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => setState(() {}),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView(
          children: [
            // --- Dashboard rapide ---
            StreamBuilder(
              stream: FirebaseFirestore.instance.collection("users").snapshots(),
              builder: (context, snapshotUsers) {
                return StreamBuilder(
                  stream: FirebaseFirestore.instance.collection("events").snapshots(),
                  builder: (context, snapshotEvents) {
                    final userCount = snapshotUsers.hasData ? snapshotUsers.data!.docs.length : 0;
                    final eventCount = snapshotEvents.hasData ? snapshotEvents.data!.docs.length : 0;

                    return Row(
                      children: [
                        _buildStatCard("Utilisateurs", userCount, Icons.people),
                        const SizedBox(width: 12),
                        _buildStatCard("Événements", eventCount, Icons.event),
                      ],
                    );
                  },
                );
              },
            ),
            const SizedBox(height: 20),

            // --- Boutons actions principales ---
            ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.tealAccent[700],
                minimumSize: const Size(double.infinity, 55),
              ),
              onPressed: () {
                showDialog(
                  context: context,
                  builder: (context) => _EventDialog(),
                );
              },
              icon: const Icon(Icons.add),
              label: const Text("Créer un événement"),
            ),
             ElevatedButton.icon(
                                onPressed: () => Navigator.pushReplacementNamed(context, '/home'),
                                icon: Icon(Icons.home),
                                label: const Text('Home'),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.white,
                                  foregroundColor: Colors.black,
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                ),
                              ),
            const SizedBox(height: 20),

            // --- Recherche utilisateur ---
            TextField(
              decoration: InputDecoration(
                hintText: "Rechercher un utilisateur...",
                hintStyle: const TextStyle(color: Colors.grey),
                prefixIcon: const Icon(Icons.search, color: Colors.tealAccent),
                filled: true,
                fillColor: Colors.grey[850],
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              ),
              style: const TextStyle(color: Colors.white),
              onChanged: (value) {
                setState(() {
                  searchQuery = value.toLowerCase();
                });
              },
            ),
            const SizedBox(height: 20),

            // --- Liste des utilisateurs ---
            const Text("Utilisateurs inscrits", style: TextStyle(color: Colors.white, fontSize: 18)),
            const SizedBox(height: 8),

            Expanded(
              child: StreamBuilder<QuerySnapshot>(
                stream: FirebaseFirestore.instance.collection("users").snapshots(),
                builder: (context, snapshot) {
                  if (!snapshot.hasData) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  final users = snapshot.data!.docs.where((user) {
                    final name = (user["displayName"] ?? "").toString().toLowerCase();
                    return searchQuery.isEmpty || name.contains(searchQuery);
                  }).toList();

                  return ListView.builder(
                    shrinkWrap: true,
                    itemCount: users.length,
                    itemBuilder: (context, index) {
                      final user = users[index];
                      return Card(
                        color: Colors.grey[850],
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        child: ListTile(
                          leading: const CircleAvatar(
                            backgroundColor: Colors.tealAccent,
                            child: Icon(Icons.person, color: Colors.black),
                          ),
                          title: Text(user["displayName"] ?? "Sans nom", style: const TextStyle(color: Colors.white)),
                          subtitle: Text(user["role"] ?? "Aucun rôle", style: const TextStyle(color: Colors.grey)),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              IconButton(
                                icon: const Icon(Icons.edit, color: Colors.blueAccent),
                                onPressed: () => _changeUserRole(context, user.id, user["role"]),
                              ),
                              IconButton(
                                icon: const Icon(Icons.delete, color: Colors.red),
                                onPressed: () {
                                  FirebaseFirestore.instance.collection("users").doc(user.id).delete();
                                },
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatCard(String title, int count, IconData icon) {
    return Expanded(
      child: Card(
        color: Colors.grey[850],
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              Icon(icon, color: Colors.tealAccent, size: 32),
              const SizedBox(height: 8),
              Text("$count", style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)),
              Text(title, style: const TextStyle(color: Colors.grey)),
            ],
          ),
        ),
      ),
    );
  }

  void _changeUserRole(BuildContext context, String userId, String currentRole) {
    final roles = ["user", "admin", "chauffeur"];
    String newRole = currentRole;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Changer le rôle"),
        content: DropdownButtonFormField<String>(
          value: currentRole,
          dropdownColor: const Color.fromARGB(255, 201, 201, 201),
          decoration: const InputDecoration(
            labelText: "Rôle",
            labelStyle: TextStyle(color: Color.fromARGB(255, 4, 0, 0)),
          ),
          items: roles.map((role) {
            return DropdownMenuItem(
              value: role,
              child: Text(role, style: const TextStyle(color: Color.fromARGB(255, 4, 4, 4))),
            );
          }).toList(),
          onChanged: (value) {
            newRole = value!;
          },
        ),
        actions: [
          TextButton(
            child: const Text("Annuler"),
            onPressed: () => Navigator.pop(context),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.tealAccent[700]),
            child: const Text("Enregistrer"),
            onPressed: () {
              FirebaseFirestore.instance.collection("users").doc(userId).update({"role": newRole});
              Navigator.pop(context);
            },
          ),
        ],
      ),
    );
  }
}

// --- Formulaire d'événement ---
class _EventDialog extends StatefulWidget {
  @override
  State<_EventDialog> createState() => _EventDialogState();
}

class _EventDialogState extends State<_EventDialog> {
  File? _imageFile;
  final _formKey = GlobalKey<FormState>();
  String title = '';
  String description = '';
  String location = '';
  DateTime? date;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: Colors.grey[900],
      title: const Text("Créer un événement", style: TextStyle(color: Colors.white)),
      content: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildTextField("Titre", (v) => title = v ?? ''),
              const SizedBox(height: 12),
              _buildTextField("Description", (v) => description = v ?? '', maxLines: 2),
              const SizedBox(height: 12),
              _buildTextField("Lieu", (v) => location = v ?? ''),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: Text(
                      date == null
                          ? "Sélectionner la date"
                          : "Date: ${date!.day}/${date!.month}/${date!.year}",
                      style: const TextStyle(color: Colors.white),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.calendar_today, color: Colors.tealAccent),
                    onPressed: () async {
                      final picked = await showDatePicker(
                        context: context,
                        initialDate: DateTime.now(),
                        firstDate: DateTime(2020),
                        lastDate: DateTime(2100),
                      );
                      if (picked != null) setState(() => date = picked);
                    },
                  ),
                ],
              ),
              const SizedBox(height: 12),
              if (_imageFile != null)
                Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: Image.file(_imageFile!, height: 120, fit: BoxFit.cover),
                ),
              ElevatedButton.icon(
                style: ElevatedButton.styleFrom(backgroundColor: Colors.tealAccent[700]),
                icon: const Icon(Icons.image),
                label: const Text("Choisir une image"),
                onPressed: () async {
                  final picker = ImagePicker();
                  final pickedFile = await picker.pickImage(source: ImageSource.gallery);
                  if (pickedFile != null) {
                    setState(() {
                      _imageFile = File(pickedFile.path);
                    });
                  }
                },
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text("Annuler", style: TextStyle(color: Colors.tealAccent)),
        ),
        ElevatedButton(
          style: ElevatedButton.styleFrom(backgroundColor: Colors.tealAccent[700]),
          onPressed: () async {
            if (_formKey.currentState!.validate() && date != null) {
              _formKey.currentState!.save();
              String? imagePath;
              if (_imageFile != null) {
                imagePath = _imageFile!.path;
              }
              await FirebaseFirestore.instance.collection("events").add({
                "title": title,
                "description": description,
                "location": location,
                "date": date,
                "createdAt": DateTime.now(),
                "image": imagePath ?? '',
              });
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text("Événement créé !")),
              );
            }
          },
          child: const Text("Créer", style: TextStyle(color: Colors.white)),
        ),
      ],
    );
  }

  Widget _buildTextField(String label, Function(String?) onSaved, {int maxLines = 1}) {
    return TextFormField(
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(color: Colors.white),
        enabledBorder: const UnderlineInputBorder(
          borderSide: BorderSide(color: Colors.tealAccent),
        ),
      ),
      style: const TextStyle(color: Colors.white),
      maxLines: maxLines,
      validator: (v) => v == null || v.isEmpty ? "Champ requis" : null,
      onSaved: onSaved,
    );
  }
}
