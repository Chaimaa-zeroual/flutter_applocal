import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'auth/login_page.dart'; // Assure-toi que le chemin est correct : lib/pages/auth/login_page.dart

class ForgotPasswordPage extends StatefulWidget {
  @override
  _ForgotPasswordPageState createState() => _ForgotPasswordPageState();
}

class _ForgotPasswordPageState extends State<ForgotPasswordPage> {
  final _emailController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _loading = false;

  Future<void> _resetPassword() async {
    final email = _emailController.text.trim();

    setState(() => _loading = true);

    try {
      await FirebaseAuth.instance.sendPasswordResetEmail(email: email);

      // Affiche un message vert
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Email de réinitialisation envoyé à $email"),
          backgroundColor: Colors.green,
        ),
      );

      // ⏳ Attend 2 secondes puis retourne à la page de connexion
      await Future.delayed(Duration(seconds: 2));
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => LoginPage()),
      );
    } on FirebaseAuthException catch (e) {
      setState(() => _loading = false);

      String message;
      switch (e.code) {
        case 'user-not-found':
          message = "Aucun utilisateur trouvé pour cet e-mail.";
          break;
        case 'invalid-email':
          message = "L'adresse e-mail est invalide.";
          break;
        default:
          message = "Erreur : ${e.message}";
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(message)),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final primaryColor = Color(0xFF855386); // Violet personnalisé

    return Scaffold(
      appBar: AppBar(
        title: Text('Mot de passe oublié'),
        centerTitle: true,
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.lock_reset, size: 60, color: primaryColor),
              SizedBox(height: 30),
              Text(
                'Entrez votre adresse e-mail pour recevoir un lien de réinitialisation.',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 16),
              ),
              SizedBox(height: 30),
              Form(
                key: _formKey,
                child: TextFormField(
                  controller: _emailController,
                  keyboardType: TextInputType.emailAddress,
                  decoration: InputDecoration(
                    labelText: 'Email',
                    prefixIcon: Icon(Icons.email, color: primaryColor),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  validator: (value) =>
                      value == null || value.isEmpty ? 'Veuillez entrer votre e-mail' : null,
                ),
              ),
              SizedBox(height: 30),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _loading
                      ? null
                      : () {
                          if (_formKey.currentState!.validate()) {
                            _resetPassword();
                          }
                        },
                  style: ElevatedButton.styleFrom(
                    padding: EdgeInsets.symmetric(vertical: 16),
                    backgroundColor: primaryColor,  // fond violet
                    foregroundColor: Colors.white,   // texte blanc
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    side: BorderSide(color: primaryColor, width: 2), // bord violet
                  ),
                  child: _loading
                      ? CircularProgressIndicator(color: Colors.white)
                      : Text('Envoyer le lien'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
