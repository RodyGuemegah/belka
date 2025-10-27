import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class EditProfilScreen extends StatefulWidget {
  const EditProfilScreen({super.key});

  @override
  State<EditProfilScreen> createState() => _EditProfilScreenState();
}

class _EditProfilScreenState extends State<EditProfilScreen> {
  final _formKey = GlobalKey<FormState>();
  final _passwordFormKey = GlobalKey<FormState>();
  final _vehicleFormKey = GlobalKey<FormState>();
  
  String _displayName = '';
  String _email = '';
  String _currentPassword = '';
  String _newPassword = '';
  String _confirmPassword = '';
  
  // Données du véhicule
  String _vehicleBrand = '';
  String _vehicleModel = '';
  String _vehicleColor = '';
  String _vehiclePlate = '';
  int _vehicleSeats = 4;
  
  bool _loading = false;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      final doc = await FirebaseFirestore.instance.collection('users').doc(user.uid).get();
      if (doc.exists) {
        final data = doc.data() as Map<String, dynamic>;
        setState(() {
          _displayName = data['displayName'] ?? '';
          _email = data['email'] ?? user.email ?? '';
          _vehicleBrand = data['vehicleBrand'] ?? '';
          _vehicleModel = data['vehicleModel'] ?? '';
          _vehicleColor = data['vehicleColor'] ?? '';
          _vehiclePlate = data['vehiclePlate'] ?? '';
          _vehicleSeats = data['vehicleSeats'] ?? 4;
        });
      }
    }
  }

  Future<void> _saveProfile() async {
    if (!_formKey.currentState!.validate()) return;
    _formKey.currentState!.save();
    setState(() => _loading = true);

    final emailRegex = RegExp(r"^[^@\s]+@[^@\s]+\.[^@\s]+$");
    if (!emailRegex.hasMatch(_email)) {
      setState(() => _loading = false);
      _showErrorMessage('Adresse e-mail invalide');
      return;
    }

    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        _showErrorMessage('Aucun utilisateur connecté');
        return;
      }

      // Si l'email change, demander réauthentification avant de modifier Auth
      if (_email != user.email) {
        final ok = await _promptReauthenticate();
        if (!ok) {
          setState(() => _loading = false);
          return;
        }
        // Some firebase_auth versions may have different APIs; call dynamically to avoid analyzer errors
        try {
          await (user as dynamic).updateEmail(_email);
        } catch (e) {
          _showErrorMessage('Impossible de mettre à jour l\'email: ${e.toString()}');
          setState(() => _loading = false);
          return;
        }
      }

      // Mettre à jour displayName dans Firebase Auth si nécessaire
      if (_displayName != user.displayName) {
        await user.updateDisplayName(_displayName);
      }

      // Maintenant mettre à jour Firestore (après Auth)
      await FirebaseFirestore.instance.collection('users').doc(user.uid).update({
        'displayName': _displayName,
        'email': _email,
      });

      await user.reload();
      _showSuccessMessage('Profil mis à jour avec succès !');
    } on FirebaseAuthException catch (e) {
      if (e.code == 'requires-recent-login') {
        _showErrorMessage('Veuillez vous reconnecter pour modifier l\'email.');
      } else {
        _showErrorMessage('Erreur Auth: ${e.message}');
      }
    } catch (e) {
      _showErrorMessage('Erreur lors de la mise à jour du profil');
    } finally {
      setState(() => _loading = false);
    }
  }

  Future<void> _saveVehicle() async {
    if (!_vehicleFormKey.currentState!.validate()) return;
    _vehicleFormKey.currentState!.save();
    setState(() => _loading = true);
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        _showErrorMessage('Aucun utilisateur connecté');
        return;
      }
      await FirebaseFirestore.instance.collection('users').doc(user.uid).update({
        'vehicleBrand': _vehicleBrand,
        'vehicleModel': _vehicleModel,
        'vehicleColor': _vehicleColor,
        'vehiclePlate': _vehiclePlate,
        'vehicleSeats': _vehicleSeats,
      });
      _showSuccessMessage('Informations du véhicule mises à jour !');
    } catch (e) {
      _showErrorMessage('Erreur lors de la mise à jour du véhicule');
    } finally {
      setState(() => _loading = false);
    }
  }

  // Demande une réauthentification à l'utilisateur en affichant un dialog pour saisir le mot de passe
  Future<bool> _promptReauthenticate() async {
    final TextEditingController pwdController = TextEditingController();
    final result = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        title: const Text('Confirmer votre identité'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('Pour des raisons de sécurité, veuillez saisir votre mot de passe actuel.'),
            const SizedBox(height: 12),
            TextField(
              controller: pwdController,
              obscureText: true,
              decoration: const InputDecoration(labelText: 'Mot de passe actuel'),
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Annuler')),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Valider'),
          ),
        ],
      ),
    );

    if (result != true) return false;
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return false;
    try {
      final credential = EmailAuthProvider.credential(email: user.email ?? '', password: pwdController.text.trim());
      await user.reauthenticateWithCredential(credential);
      return true;
    } on FirebaseAuthException catch (e) {
      _showErrorMessage('Réauthentification échouée : ${e.message}');
      return false;
    } catch (e) {
      _showErrorMessage('Réauthentification échouée');
      return false;
    }
  }

  Future<void> _changePassword() async {
    if (!_passwordFormKey.currentState!.validate()) return;
    _passwordFormKey.currentState!.save();

    if (_newPassword != _confirmPassword) {
      _showErrorMessage('Les mots de passe ne correspondent pas');
      return;
    }

    setState(() => _loading = true);

    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        // Réauthentification avec l'ancien mot de passe
        final credential = EmailAuthProvider.credential(
          email: user.email!,
          password: _currentPassword,
        );
        await user.reauthenticateWithCredential(credential);

        // Changement du mot de passe
        await user.updatePassword(_newPassword);

        _showSuccessMessage('Mot de passe modifié avec succès !');
        _clearPasswordFields();
      }
    } on FirebaseAuthException catch (e) {
      if (e.code == 'wrong-password') {
        _showErrorMessage('Mot de passe actuel incorrect');
      } else {
        _showErrorMessage('Erreur lors du changement de mot de passe');
      }
    } finally {
      setState(() => _loading = false);
    }
  }

  void _clearPasswordFields() {
    setState(() {
      _currentPassword = '';
      _newPassword = '';
      _confirmPassword = '';
    });
  }

  void _showSuccessMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: const Color(0xFF404040),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
    );
  }

  void _showErrorMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red[600],
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF121212),
      appBar: AppBar(
        backgroundColor: const Color(0xFF121212),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          "Modifier le profil",
          style: TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.w600,
          ),
        ),
        centerTitle: true,
      ),
      body: _loading
          ? const Center(
              child: CircularProgressIndicator(
                color: Colors.white,
              ),
            )
          : Container(
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
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Section Informations personnelles
                      _buildSectionHeader("Informations personnelles", Icons.person),
                      const SizedBox(height: 16),
                      _buildProfileForm(),
                      
                      const SizedBox(height: 40),
                      
                      // Section Véhicule
                      _buildSectionHeader("Mon véhicule", Icons.directions_car),
                      const SizedBox(height: 16),
                      _buildVehicleForm(),
                      
                      const SizedBox(height: 40),
                      
                      // Section Mot de passe
                      _buildSectionHeader("Sécurité", Icons.lock_outline),
                      const SizedBox(height: 16),
                      _buildPasswordForm(),
                      
                      const SizedBox(height: 30),
                    ],
                  ),
                ),
              ),
            ),
    );
  }

  Widget _buildSectionHeader(String title, IconData icon) {
    return Row(
      children: [
        Icon(icon, color: Colors.white, size: 24),
        const SizedBox(width: 12),
        Text(
          title,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 22,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  Widget _buildProfileForm() {
    return Container(
      padding: const EdgeInsets.all(20),
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
      child: Form(
        key: _formKey,
        child: Column(
          children: [
            _buildCustomTextField(
              label: "Nom affiché",
              icon: Icons.person_outline,
              initialValue: _displayName,
              validator: (v) => v == null || v.isEmpty ? 'Le nom est requis' : null,
              onSaved: (v) => _displayName = v ?? '',
            ),
            const SizedBox(height: 20),
            _buildCustomTextField(
              label: "Adresse email",
              icon: Icons.email_outlined,
              initialValue: _email,
              keyboardType: TextInputType.emailAddress,
              validator: (v) => v == null || v.isEmpty ? 'L\'email est requis' : null,
              onSaved: (v) => _email = v ?? '',
            ),
            const SizedBox(height: 24),
            _buildActionButton(
              label: "Mettre à jour le profil",
              icon: Icons.save_outlined,
              onPressed: _saveProfile,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildVehicleForm() {
    return Container(
      padding: const EdgeInsets.all(20),
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
      child: Form(
        key: _vehicleFormKey,
        child: Column(
          children: [
            Row(
              children: [
                Expanded(
                  child: _buildCustomTextField(
                    label: "Marque",
                    icon: Icons.directions_car_outlined,
                    initialValue: _vehicleBrand,
                    validator: (v) => v == null || v.isEmpty ? 'Marque requise' : null,
                    onSaved: (v) => _vehicleBrand = v ?? '',
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _buildCustomTextField(
                    label: "Modèle",
                    icon: Icons.car_repair,
                    initialValue: _vehicleModel,
                    validator: (v) => v == null || v.isEmpty ? 'Modèle requis' : null,
                    onSaved: (v) => _vehicleModel = v ?? '',
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                Expanded(
                  child: _buildCustomTextField(
                    label: "Couleur",
                    icon: Icons.palette_outlined,
                    initialValue: _vehicleColor,
                    validator: (v) => v == null || v.isEmpty ? 'Couleur requise' : null,
                    onSaved: (v) => _vehicleColor = v ?? '',
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _buildCustomTextField(
                    label: "Plaque",
                    icon: Icons.confirmation_number_outlined,
                    initialValue: _vehiclePlate,
                    validator: (v) => v == null || v.isEmpty ? 'Plaque requise' : null,
                    onSaved: (v) => _vehiclePlate = v ?? '',
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            _buildCustomTextField(
              label: "Nombre de places",
              icon: Icons.event_seat_outlined,
              initialValue: _vehicleSeats.toString(),
              keyboardType: TextInputType.number,
              validator: (v) {
                if (v == null || v.isEmpty) return 'Nombre de places requis';
                final seats = int.tryParse(v);
                if (seats == null || seats < 1 || seats > 8) {
                  return 'Entre 1 et 8 places';
                }
                return null;
              },
              onSaved: (v) => _vehicleSeats = int.tryParse(v ?? '4') ?? 4,
            ),
            const SizedBox(height: 24),
            _buildActionButton(
              label: "Mettre à jour le véhicule",
              icon: Icons.directions_car,
              onPressed: _saveVehicle,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPasswordForm() {
    return Container(
      padding: const EdgeInsets.all(20),
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
      child: Form(
        key: _passwordFormKey,
        child: Column(
          children: [
            _buildCustomTextField(
              label: "Mot de passe actuel",
              icon: Icons.lock_outline,
              obscureText: true,
              validator: (v) => v == null || v.isEmpty ? 'Mot de passe actuel requis' : null,
              onSaved: (v) => _currentPassword = v ?? '',
            ),
            const SizedBox(height: 20),
            _buildCustomTextField(
              label: "Nouveau mot de passe",
              icon: Icons.lock,
              obscureText: true,
              validator: (v) {
                if (v == null || v.isEmpty) return 'Nouveau mot de passe requis';
                if (v.length < 6) return 'Au moins 6 caractères';
                return null;
              },
              onSaved: (v) => _newPassword = v ?? '',
            ),
            const SizedBox(height: 20),
            _buildCustomTextField(
              label: "Confirmer le mot de passe",
              icon: Icons.lock_clock,
              obscureText: true,
              validator: (v) => v == null || v.isEmpty ? 'Confirmation requise' : null,
              onSaved: (v) => _confirmPassword = v ?? '',
            ),
            const SizedBox(height: 24),
            _buildActionButton(
              label: "Changer le mot de passe",
              icon: Icons.security,
              onPressed: _changePassword,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCustomTextField({
    required String label,
    required IconData icon,
    String? initialValue,
    TextInputType keyboardType = TextInputType.text,
    bool obscureText = false,
    required String? Function(String?) validator,
    required void Function(String?) onSaved,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF404040),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: const Color(0xFF555555),
          width: 1,
        ),
      ),
      child: TextFormField(
        initialValue: initialValue,
        keyboardType: keyboardType,
        obscureText: obscureText,
        validator: validator,
        onSaved: onSaved,
        style: const TextStyle(color: Colors.white, fontSize: 16),
        decoration: InputDecoration(
          labelText: label,
          labelStyle: const TextStyle(color: Color(0xFFB0B0B0), fontSize: 14),
          prefixIcon: Icon(icon, color: const Color(0xFFB0B0B0), size: 22),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          floatingLabelBehavior: FloatingLabelBehavior.never,
        ),
      ),
    );
  }

  Widget _buildActionButton({
    required String label,
    required IconData icon,
    required VoidCallback onPressed,
  }) {
    return Container(
      width: double.infinity,
      height: 52,
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
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.transparent,
          shadowColor: Colors.transparent,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: Colors.white, size: 20),
            const SizedBox(width: 12),
            Text(
              label,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.w600,
                letterSpacing: 0.5,
              ),
            ),
          ],
        ),
      ),
    );
  }
}