import 'package:flutter/material.dart';

class DriverCard extends StatelessWidget {
  final String name, car, from, to;
  final int seats;

  const DriverCard({
    super.key,
    required this.name,
    required this.car,
    required this.from,
    required this.to,
    required this.seats,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: ListTile(
        leading: Icon(Icons.directions_car, color: Color(0xFF00B8D4), size: 36),
        title: Text('$name - $car'),
        subtitle: Text('De $from à $to\nPlaces: $seats'),
        isThreeLine: true,
      ),
    );
  }
}