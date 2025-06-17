class Client {
  final String? id;
  final String nom;
  final String telephone;
  final String adresse;
  final List<Dette> dettes;

  Client({
    this.id,
    required this.nom,
    required this.telephone,
    required this.adresse,
    this.dettes = const [],
  });

  factory Client.fromJson(Map<String, dynamic> json) {
    return Client(
      id: json['id']?.toString(),
      nom: json['nom']?.toString() ?? '',
      telephone: json['telephone']?.toString() ?? '',
      adresse: json['adresse']?.toString() ?? '',
      dettes:
          (json['dettes'] as List<dynamic>?)
              ?.map((dette) => Dette.fromJson(dette))
              .toList() ??
          [],
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

  Client copyWith({
    String? id,
    String? nom,
    String? telephone,
    String? adresse,
    List<Dette>? dettes,
  }) {
    return Client(
      id: id ?? this.id,
      nom: nom ?? this.nom,
      telephone: telephone ?? this.telephone,
      adresse: adresse ?? this.adresse,
      dettes: dettes ?? this.dettes,
    );
  }
}

class Dette {
  final String? id;
  final String date;
  final double montantDette;
  final List<Paiement> paiements;

  Dette({
    this.id,
    required this.date,
    required this.montantDette,
    this.paiements = const [],
  });

  double get montantPaye {
    return paiements.fold(0.0, (sum, paiement) => sum + paiement.montant);
  }

  double get montantRestant {
    return montantDette - montantPaye;
  }

  factory Dette.fromJson(Map<String, dynamic> json) {
    return Dette(
      id: json['id']?.toString(),
      date: json['date']?.toString() ?? '',
      montantDette: _parseToDouble(json['montantDette']),
      paiements:
          (json['paiements'] as List<dynamic>?)
              ?.map((paiement) => Paiement.fromJson(paiement))
              .toList() ??
          [],
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

  static double _parseToDouble(dynamic value) {
    if (value == null) return 0.0;
    if (value is double) return value;
    if (value is int) return value.toDouble();
    if (value is String) {
      return double.tryParse(value) ?? 0.0;
    }
    return 0.0;
  }
}

class Paiement {
  final String? id;
  final String date;
  final double montant;

  Paiement({this.id, required this.date, required this.montant});

  factory Paiement.fromJson(Map<String, dynamic> json) {
    return Paiement(
      id: json['id']?.toString(),
      date: json['date']?.toString() ?? '',
      montant: _parseToDouble(json['montant']),
    );
  }

  Map<String, dynamic> toJson() {
    return {if (id != null) 'id': id, 'date': date, 'montant': montant};
  }

  static double _parseToDouble(dynamic value) {
    if (value == null) return 0.0;
    if (value is double) return value;
    if (value is int) return value.toDouble();
    if (value is String) {
      return double.tryParse(value) ?? 0.0;
    }
    return 0.0;
  }
}
