import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/produit.dart';
import '../pages/product_detail_page.dart';

class ProductCard extends StatelessWidget {
  final Produit produit;

  const ProductCard({Key? key, required this.produit}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final Color customPurple = const Color(0xFF855386);
    final Color lightGrey = Colors.grey.shade200;

    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(18),
      ),
      elevation: 5,
      margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 10),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Image produit
          ClipRRect(
            borderRadius: const BorderRadius.vertical(top: Radius.circular(18)),
            child: AspectRatio(
              aspectRatio: 1.1,
              child: produit.imageUrls.isNotEmpty
                  ? Image.network(
                      produit.imageUrls[0],
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => const Center(
                        child: Icon(Icons.broken_image, size: 50, color: Colors.grey),
                      ),
                    )
                  : Container(
                      color: lightGrey,
                      child: const Center(
                        child: Icon(Icons.image_not_supported, size: 50, color: Colors.grey),
                      ),
                    ),
            ),
          ),

          const SizedBox(height: 8),

          // Nom + Sous-catégorie + Prix
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: Row(
              children: [
                // Nom et catégorie
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        produit.nom,
                        style: GoogleFonts.poppins(
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                        overflow: TextOverflow.ellipsis,
                        maxLines: 1,
                      ),
                      const SizedBox(height: 2),
                      Text(
                        produit.sousCategorie,
                        style: GoogleFonts.poppins(
                          fontSize: 12.5,
                          color: Colors.grey.shade600,
                        ),
                        overflow: TextOverflow.ellipsis,
                        maxLines: 1,
                      ),
                    ],
                  ),
                ),

                // Prix
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      'PRIX:',
                      style: GoogleFonts.poppins(
                        fontSize: 12,
                        color: Colors.grey.shade700,
                      ),
                    ),
                    Text(
                      '${produit.prix.toStringAsFixed(2)} DH',
                      style: GoogleFonts.poppins(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                        color: customPurple,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          const Spacer(),

          // Bouton "Voir plus"
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 6, 12, 12),
            child: SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: customPurple,
                  foregroundColor: Colors.white,
                  elevation: 3,
                  padding: const EdgeInsets.symmetric(vertical: 10),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ).copyWith(
                  overlayColor: MaterialStateProperty.all(customPurple.withOpacity(0.15)),
                ),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => ProductDetailPage(produit: produit),
                    ),
                  );
                },
                child: Text(
                  'Voir plus',
                  style: GoogleFonts.poppins(
                    fontSize: 14.5,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
