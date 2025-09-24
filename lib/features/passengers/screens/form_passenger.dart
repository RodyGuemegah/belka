import 'package:flutter/material.dart';

class FormPassenger extends StatefulWidget {
  const FormPassenger({super.key});

  @override
  State<FormPassenger> createState() => _FormPassengerState();
}

class _FormPassengerState extends State<FormPassenger> {
  final _formKey = GlobalKey<FormState>();
  String name = '', phone = '', from = '', to = '';
  int passengers = 1;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Demande de covoiturage")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              TextFormField(
                decoration: const InputDecoration(labelText: "Nom"),
                validator: (v) => v!.isEmpty ? "Champ requis" : null,
                onSaved: (v) => name = v!,
              ),
              TextFormField(
                decoration: const InputDecoration(labelText: "Téléphone"),
                keyboardType: TextInputType.phone,
                validator: (v) => v!.isEmpty ? "Champ requis" : null,
                onSaved: (v) => phone = v!,
              ),
              TextFormField(
                decoration: const InputDecoration(labelText: "Adresse de départ"),
                validator: (v) => v!.isEmpty ? "Champ requis" : null,
                onSaved: (v) => from = v!,
              ),
              TextFormField(
                decoration: const InputDecoration(labelText: "Adresse d'arrivée"),
                validator: (v) => v!.isEmpty ? "Champ requis" : null,
                onSaved: (v) => to = v!,
              ),
              TextFormField(
                decoration: const InputDecoration(labelText: "Nombre de passagers"),
                keyboardType: TextInputType.number,
                validator: (v) => int.tryParse(v!) == null ? "Nombre invalide" : null,
                onSaved: (v) => passengers = int.parse(v!),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () {
                  if (_formKey.currentState!.validate()) {
                    _formKey.currentState!.save();
                    // TODO: Enregistrer la demande et notifier les chauffeurs
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text("Demande envoyée !")),
                    );
                    Navigator.pop(context);
                  }
                },
                child: const Text("Envoyer"),
              ),
            ],
          ),
        ),
      ),
    );
  }
}