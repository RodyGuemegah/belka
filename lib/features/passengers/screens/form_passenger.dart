import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'dart:io';

class FormPassenger extends StatefulWidget {
  const FormPassenger({super.key});

  @override
  State<FormPassenger> createState() => _FormPassengerState();
}

class _FormPassengerState extends State<FormPassenger> {
  File? _selectedImage;
  String? _uploadedImageUrl;

  Future<void> _pickAndUploadImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _selectedImage = File(pickedFile.path);
      });
      // Upload vers Firebase Storage
      final storageRef = FirebaseStorage.instance.ref().child('passenger_images/${DateTime.now().millisecondsSinceEpoch}_${pickedFile.name}');
      final uploadTask = await storageRef.putFile(_selectedImage!);
      final downloadUrl = await storageRef.getDownloadURL();
      setState(() {
        _uploadedImageUrl = downloadUrl;
      });
      // Utilise _uploadedImageUrl pour enregistrer dans Firestore ou afficher
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Image uploadée avec succès !')),
      );
    }
  }
  final _formKey = GlobalKey<FormState>();
  String name = '', phone = '', from = '', to = '';
  int passengers = 1;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF121212), // Fond noir profond
      appBar: AppBar(
        backgroundColor: const Color(0xFF121212),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          "Demande de covoiturage",
          style: TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.w600,
          ),
        ),
        centerTitle: true,
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFF121212),
              Color(0xFF1E1E1E),
            ],
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
            child: Form(
              key: _formKey,
              child: ListView(
                children: [
                  // Ajout bouton pour choisir et uploader une image
                  ElevatedButton.icon(
                    icon: const Icon(Icons.image),
                    label: const Text('Ajouter une photo'),
                    onPressed: _pickAndUploadImage,
                  ),
                  if (_selectedImage != null)
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      child: Image.file(_selectedImage!, height: 120),
                    ),
                  if (_uploadedImageUrl != null)
                    Text('URL Firebase: $_uploadedImageUrl', style: const TextStyle(color: Colors.greenAccent)),
                  // Header avec icône
                  Container(
                    padding: const EdgeInsets.all(24),
                    margin: const EdgeInsets.only(bottom: 32),
                    decoration: BoxDecoration(
                      color: const Color(0xFF2A2A2A),
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.3),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Row(
                      children: [
                        Icon(
                          Icons.directions_car,
                          color: Colors.white,
                          size: 32,
                        ),
                        SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                "Nouvelle demande",
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              SizedBox(height: 4),
                              Text(
                                "Trouvez votre trajet idéal",
                                style: TextStyle(
                                  color: Color(0xFFB0B0B0),
                                  fontSize: 14,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Champ Nom
                  _buildCustomTextField(
                    label: "Nom complet",
                    icon: Icons.person_outline,
                    keyboardType: TextInputType.name,
                    validator: (v) => v!.isEmpty ? "Le nom est requis" : null,
                    onSaved: (v) => name = v!,
                  ),

                  const SizedBox(height: 20),

                  // Champ Téléphone
                  _buildCustomTextField(
                    label: "Numéro de téléphone",
                    icon: Icons.phone_outlined,
                    keyboardType: TextInputType.phone,
                    validator: (v) => v!.isEmpty ? "Le téléphone est requis" : null,
                    onSaved: (v) => phone = v!,
                  ),

                  const SizedBox(height: 20),

                  // Champ Départ
                  _buildCustomTextField(
                    label: "Adresse de départ",
                    icon: Icons.my_location,
                    keyboardType: TextInputType.streetAddress,
                    validator: (v) => v!.isEmpty ? "L'adresse de départ est requise" : null,
                    onSaved: (v) => from = v!,
                  ),

                  const SizedBox(height: 20),

                  // Champ Arrivée
                  _buildCustomTextField(
                    label: "Adresse d'arrivée",
                    icon: Icons.location_on_outlined,
                    keyboardType: TextInputType.streetAddress,
                    validator: (v) => v!.isEmpty ? "L'adresse d'arrivée est requise" : null,
                    onSaved: (v) => to = v!,
                  ),

                  const SizedBox(height: 20),

                  // Champ Passagers
                  _buildCustomTextField(
                    label: "Nombre de passagers",
                    icon: Icons.group_outlined,
                    keyboardType: TextInputType.number,
                    validator: (v) => int.tryParse(v!) == null ? "Nombre invalide" : null,
                    onSaved: (v) => passengers = int.parse(v!),
                  ),

                  const SizedBox(height: 40),

                  // Bouton d'envoi
                  Container(
                    width: double.infinity,
                    height: 56,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12),
                      gradient: const LinearGradient(
                        colors: [Color(0xFF404040), Color(0xFF2A2A2A)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.3),
                          blurRadius: 8,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: ElevatedButton(
                      onPressed: () {
                        if (_formKey.currentState!.validate()) {
                          _formKey.currentState!.save();
                          _showSuccessDialog();
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.transparent,
                        shadowColor: Colors.transparent,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.send, color: Colors.white, size: 20),
                          SizedBox(width: 12),
                          Text(
                            "Envoyer la demande",
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              letterSpacing: 0.5,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 20),

                  // Note informative
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: const Color(0xFF2A2A2A).withOpacity(0.5),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: const Color(0xFF404040),
                        width: 1,
                      ),
                    ),
                    child: const Row(
                      children: [
                        Icon(
                          Icons.info_outline,
                          color: Color(0xFFB0B0B0),
                          size: 20,
                        ),
                        SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            "Vous recevrez une notification dès qu'un conducteur acceptera votre demande.",
                            style: TextStyle(
                              color: Color(0xFFB0B0B0),
                              fontSize: 13,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCustomTextField({
    required String label,
    required IconData icon,
    required TextInputType keyboardType,
    required String? Function(String?) validator,
    required void Function(String?) onSaved,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF2A2A2A),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: const Color(0xFF404040),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: TextFormField(
        keyboardType: keyboardType,
        validator: validator,
        onSaved: onSaved,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 16,
        ),
        decoration: InputDecoration(
          labelText: label,
          labelStyle: const TextStyle(
            color: Color(0xFFB0B0B0),
            fontSize: 14,
          ),
          prefixIcon: Icon(
            icon,
            color: const Color(0xFFB0B0B0),
            size: 22,
          ),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 16,
          ),
          floatingLabelBehavior: FloatingLabelBehavior.never,
        ),
      ),
    );
  }

  void _showSuccessDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          backgroundColor: const Color(0xFF2A2A2A),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 64,
                  height: 64,
                  decoration: const BoxDecoration(
                    color: Color(0xFF404040),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.check,
                    color: Colors.white,
                    size: 32,
                  ),
                ),
                const SizedBox(height: 16),
                const Text(
                  "Demande envoyée !",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  "Nous recherchons des conducteurs disponibles pour votre trajet.",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Color(0xFFB0B0B0),
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 20),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.of(context).pop(); // Ferme le dialog
                      Navigator.of(context).pop(); // Ferme la page
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF404040),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: const Text(
                      "OK",
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}