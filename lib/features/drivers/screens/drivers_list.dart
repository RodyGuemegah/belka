import 'package:flutter/material.dart';
import '../../../core/widgets/driver_card.dart';

class DriversList extends StatelessWidget {
  const DriversList({super.key});

  @override
  Widget build(BuildContext context) {
    // Exemple statique, à remplacer par une liste dynamique (Firestore, etc.)
    final drivers = [
      {'name': 'Jean', 'car': 'Peugeot 208', 'from': 'Fort-de-France', 'to': 'Le Marin', 'seats': 3},
      {'name': 'Marie', 'car': 'Renault Clio', 'from': 'Schoelcher', 'to': 'Saint-Pierre', 'seats': 2},
    ];

    return Scaffold(
      appBar: AppBar(title: const Text("Chauffeurs disponibles")),
      body: ListView.builder(
        itemCount: drivers.length,
        itemBuilder: (context, index) {
          final driver = drivers[index];
          return null;
          // return DriverCard(
          //   name: driver['name'],
          //   car: driver['car'],
          //   from: driver['from'],
          //   to: driver['to'],
          //   seats: driver['seats'],
          // );
        },
      ),
    );
  }
}