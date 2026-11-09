import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../widgets/bottom_nav_bar.dart';
import '../services/firestore_service.dart';
import '../models/produit.dart';
import 'package:firebase_auth/firebase_auth.dart';

class AddProductPage extends StatefulWidget {
  @override
  _AddProductPageState createState() => _AddProductPageState();
}

class _AddProductPageState extends State<AddProductPage> {
  final _formKey = GlobalKey<FormState>();
  final _nomCtrl = TextEditingController();
  final _descriptionCtrl = TextEditingController();
  final _prixCtrl = TextEditingController();

  String selectedCategory = 'Homme';
  String? selectedSubCategory;

  final Map<String, List<String>> subCategories = {
    'Homme': ['T-shirts', 'Chemises', 'Pantalons', 'Vestes'],
    'Femme': ['Robes', 'Jupes', 'Tops', 'Manteaux'],
    'Enfants': ['Bébés', 'Garçons', 'Filles', 'Chaussures'],
  };

  // Liste des images dans assets
  final List<String> assetImages = [
    'assets/images/img-1737986031434.jpeg',
    'assets/images/89d4b277e6c65224767ad167689bc17b.jpeg',
    // 'assets/images/sample1.jpg',
    // 'assets/images/sample2.jpg',
  ];

  // Images sélectionnées (chemins)
  List<String> selectedImages = [];

  void _toggleImageSelection(String path) {
    setState(() {
      if (selectedImages.contains(path)) {
        selectedImages.remove(path);
      } else {
        selectedImages.add(path);
      }
    });
  }

  Future<void> _submit() async {
    if (_formKey.currentState!.validate()) {
      if (selectedImages.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Veuillez sélectionner au moins une image')),
        );
        return;
      }

      final nom = _nomCtrl.text.trim();
      final description = _descriptionCtrl.text.trim();
      final prix = double.tryParse(_prixCtrl.text.trim()) ?? 0;
      final categorie = selectedCategory;
      final sousCategorie = selectedSubCategory ?? subCategories[categorie]!.first;

      final currentUser = FirebaseAuth.instance.currentUser;
      final ownerId = currentUser?.uid ?? '';

      try {
        Produit produit = Produit(
          id: '',
          nom: nom,
          description: description,
          prix: prix,
          imageUrls: selectedImages,
          categorie: categorie,
          sousCategorie: sousCategorie,
          ownerId: ownerId,
        );

        await FirestoreService().addProduit(produit);

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Article ajouté avec succès !')),
        );

        _nomCtrl.clear();
        _descriptionCtrl.clear();
        _prixCtrl.clear();
        setState(() {
          selectedCategory = 'Homme';
          selectedSubCategory = null;
          selectedImages.clear();
        });
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erreur : l\'article n\'a pas pu être ajouté')),
        );
      }
    }
  }

  @override
  void dispose() {
    _nomCtrl.dispose();
    _descriptionCtrl.dispose();
    _prixCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final primaryColor = Theme.of(context).primaryColor;
    List<String> currentSubCategories = subCategories[selectedCategory]!;

    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text(
          'Vendre un article',
          style: GoogleFonts.pacifico(
            textStyle: TextStyle(
              fontSize: 24,
              color: Colors.black,
            ),
          ),
        ),
      ),
      bottomNavigationBar: BottomNavBar(index: 3),
      body: Padding(
        padding: EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              Text('Sélectionnez des images', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              SizedBox(height: 8),

              Container(
                height: 200,
                decoration: BoxDecoration(
                  border: Border.all(color: primaryColor, width: 2),
                  borderRadius: BorderRadius.circular(12),
                  color: Colors.grey.shade100,
                ),
                padding: EdgeInsets.all(8),
                child: GridView.builder(
                  itemCount: assetImages.length,
                  scrollDirection: Axis.horizontal,
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 1,
                    mainAxisSpacing: 8,
                  ),
                  itemBuilder: (context, index) {
                    final path = assetImages[index];
                    final isSelected = selectedImages.contains(path);
                    return GestureDetector(
                      onTap: () => _toggleImageSelection(path),
                      child: Stack(
                        children: [
                          ClipRRect(
                            borderRadius: BorderRadius.circular(10),
                            child: Image.asset(path, fit: BoxFit.cover, width: 150),
                          ),
                          if (isSelected)
                            Positioned(
                              top: 4,
                              right: 4,
                              child: Container(
                                decoration: BoxDecoration(
                                  color: Colors.black54,
                                  shape: BoxShape.circle,
                                ),
                                padding: EdgeInsets.all(4),
                                child: Icon(Icons.check, color: Colors.white),
                              ),
                            ),
                        ],
                      ),
                    );
                  },
                ),
              ),

              SizedBox(height: 20),

              _buildTextField(_nomCtrl, 'Nom de l\'article', Icons.label),
              SizedBox(height: 20),

              _buildTextField(_descriptionCtrl, 'Description', Icons.description, lines: 3),
              SizedBox(height: 20),

              DropdownButtonFormField<String>(
                value: selectedCategory,
                decoration: _inputDecoration('Catégorie', Icons.category),
                items: subCategories.keys.map((cat) {
                  return DropdownMenuItem(value: cat, child: Text(cat));
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    selectedCategory = value!;
                    selectedSubCategory = null;
                  });
                },
              ),

              SizedBox(height: 20),

              DropdownButtonFormField<String>(
                value: selectedSubCategory ?? currentSubCategories.first,
                decoration: _inputDecoration('Sous-catégorie', Icons.subdirectory_arrow_right),
                items: currentSubCategories.map((subCat) {
                  return DropdownMenuItem(value: subCat, child: Text(subCat));
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    selectedSubCategory = value;
                  });
                },
              ),

              SizedBox(height: 20),

              TextFormField(
                controller: _prixCtrl,
                decoration: _inputDecoration('Prix (€)', Icons.euro),
                keyboardType: TextInputType.numberWithOptions(decimal: true),
                validator: (value) {
                  if (value == null || value.isEmpty) return 'Veuillez entrer un prix';
                  final parsed = double.tryParse(value);
                  if (parsed == null) return 'Entrez un nombre valide';
                  if (parsed <= 0) return 'Le prix doit être supérieur à 0';
                  return null;
                },
              ),

              SizedBox(height: 30),

              ElevatedButton(
                onPressed: _submit,
                child: Text('Vendre l\'article', style: TextStyle(color: Colors.white)),
                style: ElevatedButton.styleFrom(
                  minimumSize: Size(double.infinity, 48),
                  backgroundColor: primaryColor,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextField(TextEditingController controller, String label, IconData icon,
      {int lines = 1}) {
    return TextFormField(
      controller: controller,
      decoration: _inputDecoration(label, icon),
      maxLines: lines,
      validator: (value) =>
          value == null || value.isEmpty ? 'Veuillez entrer $label'.toLowerCase() : null,
    );
  }

  InputDecoration _inputDecoration(String label, IconData icon) {
    final primaryColor = Theme.of(context).primaryColor;
    return InputDecoration(
      labelText: label,
      prefixIcon: Icon(icon, color: primaryColor),
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
    );
  }
}





// import 'dart:typed_data';
// import 'dart:io' as io show File;
// import 'package:flutter/foundation.dart'; 
// import 'package:flutter/material.dart';
// import 'package:image_picker/image_picker.dart';
// import 'package:google_fonts/google_fonts.dart';
// import '../widgets/bottom_nav_bar.dart';
// import '../services/firestore_service.dart';
// import '../models/produit.dart';
// import 'package:firebase_auth/firebase_auth.dart';

// class AddProductPage extends StatefulWidget {
//   @override
//   _AddProductPageState createState() => _AddProductPageState();
// }

// class _AddProductPageState extends State<AddProductPage> {
//   final _formKey = GlobalKey<FormState>();
//   final _nomCtrl = TextEditingController();
//   final _descriptionCtrl = TextEditingController();
//   final _prixCtrl = TextEditingController();

//   String selectedCategory = 'Homme';
//   String? selectedSubCategory;
  
//   final Map<String, List<String>> subCategories = {
//     'Homme': ['T-shirts', 'Chemises', 'Pantalons', 'Vestes'],
//     'Femme': ['Robes', 'Jupes', 'Tops', 'Manteaux'],
//     'Enfants': ['Bébés', 'Garçons', 'Filles', 'Chaussures'],
//   };

//   final ImagePicker _picker = ImagePicker();

//   List<io.File> _imageFiles = [];
//   List<Uint8List> _webImages = [];

//   Future<void> _pickImage() async {
//     final pickedFile = await _picker.pickImage(source: ImageSource.gallery);
//     if (pickedFile != null) {
//       if (kIsWeb) {
//         final bytes = await pickedFile.readAsBytes();
//         setState(() {
//           _webImages.add(bytes);
//         });
//       } else {
//         setState(() {
//           _imageFiles.add(io.File(pickedFile.path));
//         });
//       }
//     }
//   }

//   void _removeImage(int index) {
//     setState(() {
//       if (kIsWeb) {
//         _webImages.removeAt(index);
//       } else {
//         _imageFiles.removeAt(index);
//       }
//     });
//   }

//   void _submit() async {
//     if (_formKey.currentState!.validate()) {
//       if (_imageFiles.isEmpty && _webImages.isEmpty) {
//         ScaffoldMessenger.of(context).showSnackBar(
//           SnackBar(content: Text('Veuillez sélectionner au moins une image')),
//         );
//         return;
//       }

//       final nom = _nomCtrl.text.trim();
//       final description = _descriptionCtrl.text.trim();
//       final prix = double.tryParse(_prixCtrl.text.trim()) ?? 0;
//       final categorie = selectedCategory;
//       final sousCategorie = selectedSubCategory ?? subCategories[categorie]!.first;

//       final currentUser = FirebaseAuth.instance.currentUser;
//       final ownerId = currentUser?.uid ?? '';

//       // Ici, tu pourrais uploader l'image et récupérer son URL
//       List<String> imagesUrls = [];

//       Produit produit = Produit(
//         id: '',
//         nom: nom,
//         description: description,
//         prix: prix,
//         imageUrl: imagesUrls.isNotEmpty ? imagesUrls.first : '',
//         categorie: categorie,
//         sousCategorie: sousCategorie,
//         ownerId: ownerId,
//       );

//       try {
//         await FirestoreService().addProduit(produit);

//         ScaffoldMessenger.of(context).showSnackBar(
//           SnackBar(content: Text('Article ajouté avec succès !')),
//         );

//         _nomCtrl.clear();
//         _descriptionCtrl.clear();
//         _prixCtrl.clear();
//         setState(() {
//           selectedCategory = 'Homme';
//           selectedSubCategory = null;
//           _imageFiles.clear();
//           _webImages.clear();
//         });
//       } catch (e) {
//         debugPrint('Erreur lors de l\'ajout d\'un article: $e');
//         ScaffoldMessenger.of(context).showSnackBar(
//           SnackBar(content: Text('Erreur : l\'article n\'a pas pu être ajouté')),
//         );
//       }
//     }
//   }

//   @override
//   void dispose() {
//     _nomCtrl.dispose();
//     _descriptionCtrl.dispose();
//     _prixCtrl.dispose();
//     super.dispose();
//   }

//   @override
//   Widget build(BuildContext context) {
//     final primaryColor = Theme.of(context).primaryColor;
//     List<String> currentSubCategories = subCategories[selectedCategory]!;

//     return Scaffold(
//       appBar: AppBar(
//         centerTitle: true,
//         title: Text(
//           'Vendre un article',
//           style: GoogleFonts.pacifico(
//             textStyle: TextStyle(
//               fontSize: 24,
//               color: const Color.fromARGB(255, 0, 0, 0),
//             ),
//           ),
//         ),
//       ),
//       bottomNavigationBar: BottomNavBar(index: 3),
//       body: Padding(
//         padding: EdgeInsets.all(16),
//         child: Form(
//           key: _formKey,
//           child: ListView(
//             children: [
//               Text('Images', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
//               SizedBox(height: 8),

//               Container(
//                 height: 200,
//                 decoration: BoxDecoration(
//                   border: Border.all(color: primaryColor, width: 2),
//                   borderRadius: BorderRadius.circular(12),
//                   color: Colors.grey.shade100,
//                 ),
//                 padding: EdgeInsets.all(8),
//                 child: kIsWeb
//                     ? _webImages.isEmpty
//                         ? Center(child: Text('Aucune image sélectionnée'))
//                         : _buildWebImagesGrid()
//                     : _imageFiles.isEmpty
//                         ? Center(child: Text('Aucune image sélectionnée'))
//                         : _buildLocalImagesGrid(),
//               ),

//               SizedBox(height: 12),
//               Center(
//                 child: ElevatedButton.icon(
//                   onPressed: _pickImage,
//                   icon: Icon(Icons.add_a_photo),
//                   label: Text('Ajouter des images'),
//                   style: ElevatedButton.styleFrom(
//                     backgroundColor: primaryColor,
//                     foregroundColor: Colors.white,
//                     shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
//                   ),
//                 ),
//               ),

//               SizedBox(height: 20),

//               _buildTextField(_nomCtrl, 'Nom de l\'article', Icons.label),
//               SizedBox(height: 20),

//               _buildTextField(_descriptionCtrl, 'Description', Icons.description, lines: 3),
//               SizedBox(height: 20),

//               DropdownButtonFormField<String>(
//                 value: selectedCategory,
//                 decoration: _inputDecoration('Catégorie', Icons.category),
//                 items: subCategories.keys.map((cat) {
//                   return DropdownMenuItem(value: cat, child: Text(cat));
//                 }).toList(),
//                 onChanged: (value) {
//                   setState(() {
//                     selectedCategory = value!;
//                     selectedSubCategory = null;
//                   });
//                 },
//               ),

//               SizedBox(height: 20),

//               DropdownButtonFormField<String>(
//                 value: selectedSubCategory ?? currentSubCategories.first,
//                 decoration: _inputDecoration('Sous-catégorie', Icons.subdirectory_arrow_right),
//                 items: currentSubCategories.map((subCat) {
//                   return DropdownMenuItem(value: subCat, child: Text(subCat));
//                 }).toList(),
//                 onChanged: (value) {
//                   setState(() {
//                     selectedSubCategory = value;
//                   });
//                 },
//               ),

//               SizedBox(height: 20),

//               TextFormField(
//                 controller: _prixCtrl,
//                 decoration: _inputDecoration('Prix (€)', Icons.euro),
//                 keyboardType: TextInputType.numberWithOptions(decimal: true),
//                 validator: (value) {
//                   if (value == null || value.isEmpty) return 'Veuillez entrer un prix';
//                   final parsed = double.tryParse(value);
//                   if (parsed == null) return 'Entrez un nombre valide';
//                   if (parsed <= 0) return 'Le prix doit être supérieur à 0';
//                   return null;
//                 },
//               ),

//               SizedBox(height: 30),

//               ElevatedButton(
//                 onPressed: _submit,
//                 child: Text('Vendre l\'article', style: TextStyle(color: Colors.white)),
//                 style: ElevatedButton.styleFrom(
//                   minimumSize: Size(double.infinity, 48),
//                   backgroundColor: primaryColor,
//                   shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
//                 ),
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }

//   Widget _buildTextField(TextEditingController controller, String label, IconData icon,
//       {int lines = 1}) {
//     final primaryColor = Theme.of(context).primaryColor;
//     return TextFormField(
//       controller: controller,
//       decoration: _inputDecoration(label, icon),
//       maxLines: lines,
//       validator: (value) =>
//           value == null || value.isEmpty ? 'Veuillez entrer $label'.toLowerCase() : null,
//     );
//   }

//   InputDecoration _inputDecoration(String label, IconData icon) {
//     final primaryColor = Theme.of(context).primaryColor;
//     return InputDecoration(
//       labelText: label,
//       prefixIcon: Icon(icon, color: primaryColor),
//       border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
//     );
//   }

//   Widget _buildWebImagesGrid() {
//     return GridView.builder(
//       gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
//         crossAxisCount: 3,
//         crossAxisSpacing: 8,
//         mainAxisSpacing: 8,
//       ),
//       itemCount: _webImages.length,
//       itemBuilder: (context, index) {
//         return _imagePreview(Image.memory(_webImages[index]), index);
//       },
//     );
//   }

//   Widget _buildLocalImagesGrid() {
//     return GridView.builder(
//       gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
//         crossAxisCount: 3,
//         crossAxisSpacing: 8,
//         mainAxisSpacing: 8,
//       ),
//       itemCount: _imageFiles.length,
//       itemBuilder: (context, index) {
//         return _imagePreview(Image.file(_imageFiles[index]), index);
//       },
//     );
//   }

//   Widget _imagePreview(Image imageWidget, int index) {
//     return Stack(
//       children: [
//         ClipRRect(
//           borderRadius: BorderRadius.circular(10),
//           child: imageWidget,
//         ),
//         Positioned(
//           top: 4,
//           right: 4,
//           child: GestureDetector(
//             onTap: () => _removeImage(index),
//             child: Container(
//               decoration: BoxDecoration(
//                 color: Colors.black54,
//                 shape: BoxShape.circle,
//               ),
//               child: Icon(Icons.close, color: Colors.white, size: 20),
//             ),
//           ),
//         ),
//       ],
//     );
//   }
// }
