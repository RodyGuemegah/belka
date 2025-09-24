import 'package:flutter/material.dart';

class EventCarpoolPage extends StatefulWidget {
  final String eventTitle;
  const EventCarpoolPage({super.key, required this.eventTitle});

  @override
  State<EventCarpoolPage> createState() => _EventCarpoolPageState();
}

class _EventCarpoolPageState extends State<EventCarpoolPage> {
  int selectedTab = 0; // 0: Tous, 1: Offres, 2: Demandes

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Covoiturages'),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
            child: Text(
              widget.eventTitle,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(
              children: [
                Expanded(
                  child: Container(
                    height: 40,
                    decoration: BoxDecoration(
                      color: const Color(0xFF181828),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: TextButton.icon(
                      onPressed: () {},
                      icon: const Icon(Icons.add, color: Colors.white),
                      label: const Text(
                        "Proposer un trajet",
                        style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Container(
                  height: 40,
                  width: 40,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    border: Border.all(color: Colors.black12),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: IconButton(
                    icon: const Icon(Icons.filter_alt_outlined, color: Colors.black87),
                    onPressed: () {},
                  ),
                ),
              ],
            ),
          ),
          // Onglets
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            child: Container(
              decoration: BoxDecoration(
                color: const Color(0xFFF3F3F7),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Row(
                children: [
                  _tabButton("Tous", 0),
                  _tabButton("Offres", 1),
                  _tabButton("Demandes", 2),
                ],
              ),
            ),
          ),
          // Liste des trajets
          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                CarpoolCard(),
                // Ajoute d'autres CarpoolCard ici
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _tabButton(String label, int index) {
    final isSelected = selectedTab == index;
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => selectedTab = index),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            color: isSelected ? Colors.white : Colors.transparent,
            borderRadius: BorderRadius.circular(20),
          ),
          alignment: Alignment.center,
          child: Text(
            label,
            style: TextStyle(
              color: Colors.black87,
              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
            ),
          ),
        ),
      ),
    );
  }
}

class CarpoolCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 18),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
      elevation: 1,
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(
              children: [
                CircleAvatar(
                  backgroundColor: Colors.grey.shade200,
                  child: Text("MD", style: TextStyle(color: Colors.black)),
                ),
                const SizedBox(width: 12),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text("Marie Dubois", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                    Row(
                      children: const [
                        Icon(Icons.star, color: Colors.amber, size: 16),
                        SizedBox(width: 2),
                        Text("4.8/5", style: TextStyle(fontSize: 13)),
                      ],
                    ),
                  ],
                ),
                const Spacer(),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: Color(0xFF181828),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Text(
                    "Propose",
                    style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),
            // Trajet
            Row(
              children: [
                Column(
                  children: [
                    Icon(Icons.circle, color: Colors.black, size: 10),
                    Container(
                      width: 2,
                      height: 18,
                      color: Colors.grey.shade300,
                    ),
                    Icon(Icons.circle, color: Colors.red, size: 10),
                  ],
                ),
                const SizedBox(width: 10),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: const [
                    Text("Gare de Lyon, Paris", style: TextStyle(fontSize: 15)),
                    SizedBox(height: 16),
                    Text("Parc de la Villette", style: TextStyle(fontSize: 15)),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 14),
            // Infos
            Row(
              children: const [
                Icon(Icons.access_time, size: 16, color: Colors.grey),
                SizedBox(width: 4),
                Text("14:30"),
                SizedBox(width: 16),
                Icon(Icons.people, size: 16, color: Colors.grey),
                SizedBox(width: 4),
                Text("3 places"),
                Spacer(),
                Text("€", style: TextStyle(fontWeight: FontWeight.bold)),
                SizedBox(width: 2),
                Text("8€", style: TextStyle(fontWeight: FontWeight.bold)),
              ],
            ),
            const SizedBox(height: 14),
            // Boutons
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () {},
                    icon: const Icon(Icons.chat_bubble_outline),
                    label: const Text("Contacter"),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.black,
                      side: const BorderSide(color: Colors.black12),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {},
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Color(0xFF181828),
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    child: const Text("Réserver"),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}