import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class FormDriver extends StatefulWidget {
  const FormDriver({super.key});

  @override
  State<FormDriver> createState() => _FormDriverState();
}

class _FormDriverState extends State<FormDriver> {
  final _formKey = GlobalKey<FormState>();
  String name = '', phone = '', car = '', from = '', to = '', price = '';
  int seats = 1;
  TimeOfDay? time;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Proposer un trajet"),
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
        elevation: 1,
      ),
      body: Padding(
        padding: const EdgeInsets.all(18.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              // Nom
              TextFormField(
                decoration: const InputDecoration(
                  labelText: "Nom",
                  prefixIcon: Icon(Icons.person),
                  border: OutlineInputBorder(),
                ),
                validator: (v) => v!.isEmpty ? "Champ requis" : null,
                onSaved: (v) => name = v!,
              ),
              const SizedBox(height: 14),
              // Téléphone
              TextFormField(
                decoration: const InputDecoration(
                  labelText: "Téléphone",
                  prefixIcon: Icon(Icons.phone),
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.phone,
                validator: (v) => v!.isEmpty ? "Champ requis" : null,
                onSaved: (v) => phone = v!,
              ),
              const SizedBox(height: 14),
              // Véhicule
              TextFormField(
                decoration: const InputDecoration(
                  labelText: "Véhicule",
                  prefixIcon: Icon(Icons.directions_car),
                  border: OutlineInputBorder(),
                ),
                validator: (v) => v!.isEmpty ? "Champ requis" : null,
                onSaved: (v) => car = v!,
              ),
              const SizedBox(height: 14),
              // Lieu de départ
              TextFormField(
                decoration: const InputDecoration(
                  labelText: "Lieu de départ",
                  prefixIcon: Icon(Icons.location_on),
                  border: OutlineInputBorder(),
                ),
                validator: (v) => v!.isEmpty ? "Champ requis" : null,
                onSaved: (v) => from = v!,
              ),
              const SizedBox(height: 14),
              // Destination
              TextFormField(
                decoration: const InputDecoration(
                  labelText: "Destination",
                  prefixIcon: Icon(Icons.flag),
                  border: OutlineInputBorder(),
                ),
                validator: (v) => v!.isEmpty ? "Champ requis" : null,
                onSaved: (v) => to = v!,
              ),
              const SizedBox(height: 14),
              // Nombre de places
              TextFormField(
                decoration: const InputDecoration(
                  labelText: "Nombre de places",
                  prefixIcon: Icon(Icons.event_seat),
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.number,
                validator: (v) => int.tryParse(v!) == null ? "Nombre invalide" : null,
                onSaved: (v) => seats = int.parse(v!),
              ),
              const SizedBox(height: 14),
              // Heure de départ
              GestureDetector(
                onTap: () async {
                  final picked = await showTimePicker(
                    context: context,
                    initialTime: TimeOfDay.now(),
                  );
                  if (picked != null) setState(() => time = picked);
                },
                child: AbsorbPointer(
                  child: TextFormField(
                    decoration: InputDecoration(
                      labelText: "Heure de départ",
                      prefixIcon: const Icon(Icons.access_time),
                      border: const OutlineInputBorder(),
                      hintText: time != null ? time!.format(context) : "Sélectionner l'heure",
                    ),
                    validator: (v) => time == null ? "Sélectionnez l'heure" : null,
                  ),
                ),
              ),
              const SizedBox(height: 14),
            
              const SizedBox(height: 24),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF181828),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                onPressed: () async {
                  if (_formKey.currentState!.validate()) {
                    _formKey.currentState!.save();
                    // Récupère l'utilisateur connecté
                    final user = FirebaseAuth.instance.currentUser;
                    await FirebaseFirestore.instance.collection("trajets").add({
                        "name": name,
                        "phone": phone,
                        "car": car,
                        "from": from,
                        "to": to,
                        "seats": seats,
                        "time": time?.format(context),
                        "timestamp": DateTime.now(),
                        "userId": user?.uid,
                      }); 
                   ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text("Trajet proposé !")),
                    );
                    Navigator.pop(context);
                  }
                },
                child: const Text("Proposer le trajet", style: TextStyle(fontSize: 16)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}