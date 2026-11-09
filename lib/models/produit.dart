class Produit {
  final String id;
  final String nom;
  final String description;
  final double prix;
  final List<String> imageUrls;
  final String categorie;
  final String sousCategorie;
  final String ownerId;

  Produit({
    required this.id,
    required this.nom,
    required this.description,
    required this.prix,
    required this.imageUrls,
    required this.categorie,
    required this.sousCategorie,
    required this.ownerId,
  });

  factory Produit.fromJson(Map<String, dynamic> json, String id) {
    return Produit(
      id: id,
      nom: json['nom'] ?? '',
      description: json['description'] ?? '',
      prix: (json['prix'] as num).toDouble(),
      imageUrls: List<String>.from(json['imageUrls'] ?? []),
      categorie: json['categorie'] ?? '',
      sousCategorie: json['sousCategorie'] ?? '',
      ownerId: json['ownerId'] ?? '',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'nom': nom,
      'description': description,
      'prix': prix,
      'imageUrls': imageUrls,
      'categorie': categorie,
      'sousCategorie': sousCategorie,
      'ownerId': ownerId,
    };
  }
}
