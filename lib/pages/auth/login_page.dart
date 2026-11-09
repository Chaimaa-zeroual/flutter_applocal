// import 'package:flutter/material.dart';
// import 'register_page.dart';
// import '../forgot_password_page.dart';
// import '../../services/auth_service.dart';
// import '../home_page.dart';

// class LoginPage extends StatefulWidget {
//   @override
//   _LoginPageState createState() => _LoginPageState();
// }

// class _LoginPageState extends State<LoginPage> {
//   final emailCtrl = TextEditingController();
//   final passwordCtrl = TextEditingController();
//   final authService = AuthService();

//   bool obscurePassword = true;

//   void login() async {
//     try {
//       await authService.login(emailCtrl.text.trim(), passwordCtrl.text.trim());

//       Navigator.pushReplacement(
//         context,
//         MaterialPageRoute(builder: (_) => HomePage()),
//       );
//     } catch (e) {
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(content: Text("Erreur: $e")),
//       );
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     final primaryColor = Color(0xFF855386); // Violet personnalisé

//     return Scaffold(
//       appBar: AppBar(
//         title: Text('Connexion'),
//         centerTitle: true,
//       ),
//       body: Center(
//         child: SingleChildScrollView(
//           padding: const EdgeInsets.all(24.0),
//           child: Column(
//             mainAxisSize: MainAxisSize.min,
//             children: [
//               Icon(Icons.lock_outline, size: 60, color: primaryColor),
//               SizedBox(height: 30),
//               TextField(
//                 controller: emailCtrl,
//                 keyboardType: TextInputType.emailAddress,
//                 autofillHints: null,
//                 decoration: InputDecoration(
//                   labelText: 'Email',
//                   prefixIcon: Icon(Icons.email, color: primaryColor),
//                   border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
//                 ),
//               ),
//               SizedBox(height: 20),
//               TextField(
//                 controller: passwordCtrl,
//                 obscureText: obscurePassword,
//                 autofillHints: null,
//                 decoration: InputDecoration(
//                   labelText: 'Mot de passe',
//                   prefixIcon: Icon(Icons.lock, color: primaryColor),
//                   border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
//                   suffixIcon: IconButton(
//                     icon: Icon(
//                       obscurePassword ? Icons.visibility_off : Icons.visibility,
//                       color: primaryColor,
//                     ),
//                     onPressed: () {
//                       setState(() {
//                         obscurePassword = !obscurePassword;
//                       });
//                     },
//                   ),
//                 ),
//               ),
//               Align(
//                 alignment: Alignment.centerRight,
//                 child: TextButton(
//                   onPressed: () {
//                     Navigator.push(
//                       context,
//                       MaterialPageRoute(builder: (_) => ForgotPasswordPage()),
//                     );
//                   },
//                   child: Text(
//                     'Mot de passe oublié ?',
//                     style: TextStyle(color: primaryColor),
//                   ),
//                 ),
//               ),
//               SizedBox(height: 10),
//               SizedBox(
//                 width: double.infinity,
//                 child: ElevatedButton(
//                   onPressed: login,
//                   style: ElevatedButton.styleFrom(
//                     padding: EdgeInsets.symmetric(vertical: 16),
//                     backgroundColor: primaryColor,  // fond violet
//                     foregroundColor: Colors.white,   // texte blanc
//                     shape: RoundedRectangleBorder(
//                       borderRadius: BorderRadius.circular(12),
//                     ),
//                     side: BorderSide(color: primaryColor, width: 2), // bord violet
//                   ),
//                   child: Text('Se connecter'),
//                 ),
//               ),
//               SizedBox(height: 16),
//               Row(
//                 mainAxisAlignment: MainAxisAlignment.center,
//                 children: [
//                   Text("Vous n’avez pas encore de compte ?"),
//                   TextButton(
//                     onPressed: () {
//                       Navigator.push(
//                         context,
//                         MaterialPageRoute(builder: (_) => RegisterPage()),
//                       );
//                     },
//                     style: TextButton.styleFrom(
//                       foregroundColor: primaryColor, // Texte "Créer un compte" violet
//                     ),
//                     child: Text("Créer un compte"),
//                   ),
//                 ],
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
// }  



import 'package:flutter/material.dart';
import 'register_page.dart';
import '../forgot_password_page.dart';
import '../../services/auth_service.dart';
import '../home_page.dart';
import 'package:firebase_auth/firebase_auth.dart';

class LoginPage extends StatefulWidget {
  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final emailCtrl = TextEditingController();
  final passwordCtrl = TextEditingController();
  final authService = AuthService();

  bool obscurePassword = true;

  void login() async {
    final email = emailCtrl.text.trim();
    final password = passwordCtrl.text.trim();

    // Vérification des champs
    if (email.isEmpty || password.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Veuillez remplir tous les champs.")),
      );
      return;
    }

    if (password.length < 6) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Le mot de passe doit contenir au moins 6 caractères.")),
      );
      return;
    }

    try {
      await authService.login(email, password);

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => HomePage()),
      );
    } on FirebaseAuthException catch (e) {
      String errorMessage;
      switch (e.code) {
        case 'invalid-email':
          errorMessage = "L'adresse e-mail est invalide.";
          break;
        case 'user-not-found':
          errorMessage = "Aucun compte n'est associé à cet e-mail.";
          break;
        case 'wrong-password':
          errorMessage = "Mot de passe incorrect.";
          break;
        case 'user-disabled':
          errorMessage = "Ce compte a été désactivé.";
          break;
        case 'invalid-credential':
        case 'malformed-credential':
          errorMessage = "Mot de passe incorrect.";
          break;
        default:
          errorMessage = "Une erreur est survenue : ${e.message}";
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(errorMessage)),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Une erreur inconnue est survenue.")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final primaryColor = Color(0xFF855386); // Violet personnalisé

    return Scaffold(
      appBar: AppBar(
        title: Text('Connexion'),
        centerTitle: true,
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.lock_outline, size: 60, color: primaryColor),
              SizedBox(height: 30),
              TextField(
                controller: emailCtrl,
                keyboardType: TextInputType.emailAddress,
                autofillHints: null,
                decoration: InputDecoration(
                  labelText: 'Email',
                  prefixIcon: Icon(Icons.email, color: primaryColor),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
              SizedBox(height: 20),
              TextField(
                controller: passwordCtrl,
                obscureText: obscurePassword,
                autofillHints: null,
                decoration: InputDecoration(
                  labelText: 'Mot de passe',
                  prefixIcon: Icon(Icons.lock, color: primaryColor),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  suffixIcon: IconButton(
                    icon: Icon(
                      obscurePassword ? Icons.visibility_off : Icons.visibility,
                      color: primaryColor,
                    ),
                    onPressed: () {
                      setState(() {
                        obscurePassword = !obscurePassword;
                      });
                    },
                  ),
                ),
              ),
              Align(
                alignment: Alignment.centerRight,
                child: TextButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => ForgotPasswordPage()),
                    );
                  },
                  child: Text(
                    'Mot de passe oublié ?',
                    style: TextStyle(color: primaryColor),
                  ),
                ),
              ),
              SizedBox(height: 10),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: login,
                  style: ElevatedButton.styleFrom(
                    padding: EdgeInsets.symmetric(vertical: 16),
                    backgroundColor: primaryColor,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    side: BorderSide(color: primaryColor, width: 2),
                  ),
                  child: Text('Se connecter'),
                ),
              ),
              SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text("Vous n’avez pas encore de compte ?"),
                  TextButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => RegisterPage()),
                      );
                    },
                    style: TextButton.styleFrom(
                      foregroundColor: primaryColor,
                    ),
                    child: Text("Créer un compte"),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
