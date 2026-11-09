import 'package:flutter/material.dart';
import '../../services/auth_service.dart';

class RegisterPage extends StatefulWidget {
  @override
  _RegisterPageState createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final nomCtrl = TextEditingController();
  final prenomCtrl = TextEditingController();
  final emailCtrl = TextEditingController();
  final passwordCtrl = TextEditingController();
  final telephoneCtrl = TextEditingController();
  final adresseCtrl = TextEditingController();
  String? genre;

  final authService = AuthService();

  bool obscurePassword = true;

  void register() async {
    String nom = nomCtrl.text.trim();
    String prenom = prenomCtrl.text.trim();
    String email = emailCtrl.text.trim();
    String password = passwordCtrl.text.trim();
    String telephone = telephoneCtrl.text.trim();
    String adresse = adresseCtrl.text.trim();

    if (nom.isEmpty || prenom.isEmpty || email.isEmpty || password.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Tous les champs sauf le genre sont obligatoires.")),
      );
      return;
    }

    try {
      await authService.register(
        email: email,
        password: password,
        nom: nom,
        prenom: prenom,
        genre: genre,
        telephone: telephone,
        adresse: adresse,
      );

      // Message spécifique pour email de vérification envoyé
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: Text("Inscription réussie"),
          content: Text(
            "Votre compte a été créé. Un email de vérification a été envoyé à $email. "
            "Veuillez vérifier votre boîte mail avant de vous connecter.",
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context); // Ferme la boîte de dialogue
                Navigator.pop(context); // Retour à la page précédente (login)
              },
              child: Text("OK"),
            ),
          ],
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Erreur: $e")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final primaryColor = Color(0xFF855386);

    return Scaffold(
      appBar: AppBar(
        title: Text('Créer un compte'),
        centerTitle: true,
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.person_add_alt_1, size: 60, color: primaryColor),
              SizedBox(height: 30),
              TextField(
                controller: nomCtrl,
                decoration: InputDecoration(
                  labelText: 'Nom',
                  prefixIcon: Icon(Icons.person, color: primaryColor),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                ),
              ),
              SizedBox(height: 20),
              TextField(
                controller: prenomCtrl,
                decoration: InputDecoration(
                  labelText: 'Prénom',
                  prefixIcon: Icon(Icons.person_outline, color: primaryColor),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                ),
              ),
              SizedBox(height: 20),
              DropdownButtonFormField<String>(
                value: genre,
                onChanged: (value) => setState(() => genre = value),
                decoration: InputDecoration(
                  labelText: 'Genre',
                  prefixIcon: Icon(Icons.wc, color: primaryColor),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                ),
                items: ['Homme', 'Femme', 'Enfant']
                    .map((g) => DropdownMenuItem(value: g, child: Text(g)))
                    .toList(),
              ),
              SizedBox(height: 20),
              TextField(
                controller: emailCtrl,
                decoration: InputDecoration(
                  labelText: 'Email',
                  prefixIcon: Icon(Icons.email, color: primaryColor),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                ),
              ),
              SizedBox(height: 20),
              TextField(
                controller: passwordCtrl,
                obscureText: obscurePassword,
                decoration: InputDecoration(
                  labelText: 'Mot de passe',
                  prefixIcon: Icon(Icons.lock, color: primaryColor),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
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
              SizedBox(height: 20),
              TextField(
                controller: telephoneCtrl,
                decoration: InputDecoration(
                  labelText: 'Téléphone',
                  prefixIcon: Icon(Icons.phone, color: primaryColor),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                ),
                keyboardType: TextInputType.phone,
              ),
              SizedBox(height: 20),
              TextField(
                controller: adresseCtrl,
                decoration: InputDecoration(
                  labelText: 'Adresse',
                  prefixIcon: Icon(Icons.home, color: primaryColor),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                ),
              ),
              SizedBox(height: 30),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: register,
                  style: ElevatedButton.styleFrom(
                    padding: EdgeInsets.symmetric(vertical: 16),
                    backgroundColor: primaryColor,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    side: BorderSide(color: primaryColor, width: 2),
                  ),
                  child: Text("S’inscrire"),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}



// import 'package:flutter/material.dart';
// import '../../services/auth_service.dart';

// class RegisterPage extends StatefulWidget {
//   @override
//   _RegisterPageState createState() => _RegisterPageState();
// }

// class _RegisterPageState extends State<RegisterPage> {
//   final nomCtrl = TextEditingController();
//   final prenomCtrl = TextEditingController();
//   final emailCtrl = TextEditingController();
//   final passwordCtrl = TextEditingController();
//   final telephoneCtrl = TextEditingController(); // ✅ Ajout
//   final adresseCtrl = TextEditingController();   // ✅ Ajout
//   String? genre;

//   final authService = AuthService();

//   bool obscurePassword = true; // pour l'icône œil

//   void register() async {
//     String nom = nomCtrl.text.trim();
//     String prenom = prenomCtrl.text.trim();
//     String email = emailCtrl.text.trim();
//     String password = passwordCtrl.text.trim();
//     String telephone = telephoneCtrl.text.trim(); // ✅ Ajout
//     String adresse = adresseCtrl.text.trim();     // ✅ Ajout

//     if (nom.isEmpty || prenom.isEmpty || email.isEmpty || password.isEmpty) {
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(content: Text("Tous les champs sauf le genre sont obligatoires.")),
//       );
//       return;
//     }

//     try {
//       await authService.register(
//         email: email,
//         password: password,
//         nom: nom,
//         prenom: prenom,
//         genre: genre,
//         telephone: telephone, // ✅ Ajout
//         adresse: adresse,     // ✅ Ajout
//       );

//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(content: Text("Inscription réussie ! Veuillez vous connecter.")),
//       );

//       await Future.delayed(Duration(seconds: 2));
//       Navigator.pop(context);
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
//         title: Text('Créer un compte'),
//         centerTitle: true,
//       ),
//       body: Center(
//         child: SingleChildScrollView(
//           padding: const EdgeInsets.all(24.0),
//           child: Column(
//             mainAxisSize: MainAxisSize.min,
//             children: [
//               Icon(Icons.person_add_alt_1, size: 60, color: primaryColor),
//               SizedBox(height: 30),
//               TextField(
//                 controller: nomCtrl,
//                 decoration: InputDecoration(
//                   labelText: 'Nom',
//                   prefixIcon: Icon(Icons.person, color: primaryColor),
//                   border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
//                 ),
//               ),
//               SizedBox(height: 20),
//               TextField(
//                 controller: prenomCtrl,
//                 decoration: InputDecoration(
//                   labelText: 'Prénom',
//                   prefixIcon: Icon(Icons.person_outline, color: primaryColor),
//                   border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
//                 ),
//               ),
//               SizedBox(height: 20),
//               DropdownButtonFormField<String>(
//                 value: genre,
//                 onChanged: (value) => setState(() => genre = value),
//                 decoration: InputDecoration(
//                   labelText: 'Genre',
//                   prefixIcon: Icon(Icons.wc, color: primaryColor),
//                   border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
//                 ),
//                 items: ['Homme', 'Femme', 'Enfant']
//                     .map((g) => DropdownMenuItem(value: g, child: Text(g)))
//                     .toList(),
//               ),
//               SizedBox(height: 20),
//               TextField(
//                 controller: emailCtrl,
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
//               SizedBox(height: 20),
//               TextField(
//                 controller: telephoneCtrl, // ✅ Nouveau champ
//                 decoration: InputDecoration(
//                   labelText: 'Téléphone',
//                   prefixIcon: Icon(Icons.phone, color: primaryColor),
//                   border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
//                 ),
//                 keyboardType: TextInputType.phone,
//               ),
//               SizedBox(height: 20),
//               TextField(
//                 controller: adresseCtrl, // ✅ Nouveau champ
//                 decoration: InputDecoration(
//                   labelText: 'Adresse',
//                   prefixIcon: Icon(Icons.home, color: primaryColor),
//                   border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
//                 ),
//               ),
//               SizedBox(height: 30),
//               SizedBox(
//                 width: double.infinity,
//                 child: ElevatedButton(
//                   onPressed: register,
//                   style: ElevatedButton.styleFrom(
//                     padding: EdgeInsets.symmetric(vertical: 16),
//                     backgroundColor: primaryColor,  // fond violet
//                     foregroundColor: Colors.white,   // texte blanc
//                     shape: RoundedRectangleBorder(
//                       borderRadius: BorderRadius.circular(12),
//                     ),
//                     side: BorderSide(color: primaryColor, width: 2), // bord violet
//                   ),
//                   child: Text("S’inscrire"),
//                 ),
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
// }
