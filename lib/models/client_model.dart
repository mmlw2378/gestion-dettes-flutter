class ClientModel {
  final String? id;
  final String nom;
  final String telephone;
  final String adresse;
  final List<DetteModel> dettes;

  ClientModel({
    this.id,
    required this.nom,
    required this.telephone,
    required this.adresse,
    this.dettes = const [],
  });

  factory ClientModel.fromJson(Map<String, dynamic> json) {
    return ClientModel(
      id: json['id']?.toString(),
      nom: json['nom']?.toString() ?? '',
      telephone: json['telephone']?.toString() ?? '',
      adresse: json['adresse']?.toString() ?? '',
      dettes: (json['dettes'] as List<dynamic>?)
          ?.map((dette) => DetteModel.fromJson(dette))
          .toList() ?? [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (id != null) 'id': id,
      'nom': nom,
      'telephone': telephone,
      'adresse': adresse,
      'dettes': dettes.map((dette) => dette.toJson()).toList(),
    };
  }

  // Méthodes métier du modèle
  double get totalDettes {
    return dettes.fold(0.0, (sum, dette) => sum + dette.montantRestant);
  }

  bool get hasDebts {
    return totalDettes > 0;
  }

  int get nombreDettes {
    return dettes.length;
  }

  ClientModel copyWith({
    String? id,
    String? nom,
    String? telephone,
    String? adresse,
    List<DetteModel>? dettes,
  }) {
    return ClientModel(
      id: id ?? this.id,
      nom: nom ?? this.nom,
      telephone: telephone ?? this.telephone,
      adresse: adresse ?? this.adresse,
      dettes: dettes ?? this.dettes,
    );
  }
}

// DETTE AVEC LISTE DES PAIEMENTS COMPLÈTE
class DetteModel {
  final String? id;
  final String date; // date en chaîne de caractères
  final double montantDette;
  final List<PaiementModel> paiements; // LISTE DES PAIEMENTS

  DetteModel({
    this.id,
    required this.date,
    required this.montantDette,
    this.paiements = const [],
  });

  // CALCUL AUTOMATIQUE : montantPaye = somme des paiements effectués
  double get montantPaye {
    return paiements.fold(0.0, (sum, paiement) => sum + paiement.montant);
  }

  // CALCUL AUTOMATIQUE : montantRestant = montantDette - montantPaye  
  double get montantRestant {
    return montantDette - montantPaye;
  }

  // Vérifier si la dette est complètement payée
  bool get estPayee {
    return montantRestant <= 0;
  }

  // Pourcentage payé
  double get pourcentagePaye {
    if (montantDette == 0) return 0;
    return (montantPaye / montantDette * 100).clamp(0, 100);
  }

  factory DetteModel.fromJson(Map<String, dynamic> json) {
    return DetteModel(
      id: json['id']?.toString(),
      date: json['date']?.toString() ?? '',
      montantDette: _parseToDouble(json['montantDette']),
      paiements: (json['paiements'] as List<dynamic>?)
          ?.map((paiement) => PaiementModel.fromJson(paiement))
          .toList() ?? [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (id != null) 'id': id,
      'date': date,
      'montantDette': montantDette,
      'paiements': paiements.map((paiement) => paiement.toJson()).toList(),
    };
  }

  // Ajouter un paiement à la dette
  DetteModel ajouterPaiement(PaiementModel paiement) {
    final nouveauxPaiements = List<PaiementModel>.from(paiements)..add(paiement);
    return DetteModel(
      id: id,
      date: date,
      montantDette: montantDette,
      paiements: nouveauxPaiements,
    );
  }

  static double _parseToDouble(dynamic value) {
    if (value == null) return 0.0;
    if (value is double) return value;
    if (value is int) return value.toDouble();
    if (value is String) return double.tryParse(value) ?? 0.0;
    return 0.0;
  }
}

// MODÈLE PAIEMENT COMPLET
class PaiementModel {
  final String? id;
  final String date; // date en chaîne de caractères
  final double montant;
  final String? commentaire; // Optionnel : commentaire sur le paiement

  PaiementModel({
    this.id,
    required this.date,
    required this.montant,
    this.commentaire,
  });

  factory PaiementModel.fromJson(Map<String, dynamic> json) {
    return PaiementModel(
      id: json['id']?.toString(),
      date: json['date']?.toString() ?? '',
      montant: _parseToDouble(json['montant']),
      commentaire: json['commentaire']?.toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (id != null) 'id': id,
      'date': date,
      'montant': montant,
      if (commentaire != null) 'commentaire': commentaire,
    };
  }

  static double _parseToDouble(dynamic value) {
    if (value == null) return 0.0;
    if (value is double) return value;
    if (value is int) return value.toDouble();
    if (value is String) return double.tryParse(value) ?? 0.0;
    return 0.0;
  }
}
