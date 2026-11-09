import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/produit.dart';

class EditArticlePage extends StatefulWidget {
  final Produit produit;

  const EditArticlePage({Key? key, required this.produit}) : super(key: key);

  @override
  _EditArticlePageState createState() => _EditArticlePageState();
}

class _EditArticlePageState extends State<EditArticlePage> {
  final _formKey = GlobalKey<FormState>();

  late TextEditingController nomController;
  late TextEditingController descriptionController;
  late TextEditingController prixController;

  bool _isSaving = false;
  final Color primaryColor = Color(0xFF855386);
  final Color backgroundColor = Color(0xFFF8F2F9);

  @override
  void initState() {
    super.initState();
    nomController = TextEditingController(text: widget.produit.nom);
    descriptionController = TextEditingController(text: widget.produit.description);
    prixController = TextEditingController(text: widget.produit.prix.toString());
  }

  @override
  void dispose() {
    nomController.dispose();
    descriptionController.dispose();
    prixController.dispose();
    super.dispose();
  }

  Future<void> _saveChanges() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSaving = true);

    try {
      await FirebaseFirestore.instance
          .collection('produits')
          .doc(widget.produit.id)
          .update({
        'nom': nomController.text.trim(),
        'description': descriptionController.text.trim(),
        'prix': double.parse(prixController.text.trim()),
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Article mis à jour !')),
      );
      Navigator.of(context).pop(true);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erreur lors de la mise à jour')),
      );
    } finally {
      setState(() => _isSaving = false);
    }
  }

  InputDecoration _inputDecoration(String label, IconData icon) {
    return InputDecoration(
      labelText: label,
      labelStyle: TextStyle(color: primaryColor),
      filled: true,
      fillColor: backgroundColor,
      prefixIcon: Icon(icon, color: primaryColor),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide.none,
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: primaryColor, width: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Color(0xFFFFF4FF),
        iconTheme: IconThemeData(color: Colors.black),
        centerTitle: true,
        title: Text(
          'Modifier l\'article',
          style: GoogleFonts.pacifico(
            textStyle: TextStyle(fontSize: 24, color: Colors.black),
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                controller: nomController,
                decoration: _inputDecoration('Nom', Icons.label),
                validator: (val) =>
                    val == null || val.isEmpty ? 'Nom obligatoire' : null,
              ),
              SizedBox(height: 16),
              TextFormField(
                controller: descriptionController,
                decoration: _inputDecoration('Description', Icons.description),
                maxLines: 4,
              ),
              SizedBox(height: 16),
              TextFormField(
                controller: prixController,
                decoration: _inputDecoration('Prix (€)', Icons.euro),
                keyboardType: TextInputType.numberWithOptions(decimal: true),
                validator: (val) {
                  if (val == null || val.isEmpty) return 'Prix obligatoire';
                  if (double.tryParse(val) == null) return 'Prix invalide';
                  return null;
                },
              ),
              SizedBox(height: 32),
              SizedBox(
                width: double.infinity,
                height: 55,
                child: ElevatedButton.icon(
                  onPressed: _isSaving ? null : _saveChanges,
                  icon: _isSaving
                      ? SizedBox(
                          width: 24,
                          height: 24,
                          child: CircularProgressIndicator(
                            strokeWidth: 3,
                            color: Colors.white,
                          ),
                        )
                      : Icon(Icons.save, color: Colors.white),
                  label: Text(
                    _isSaving ? 'Enregistrement...' : 'Sauvegarder',
                    style: TextStyle(fontSize: 18, color: Colors.white),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: primaryColor,
                    padding: EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
