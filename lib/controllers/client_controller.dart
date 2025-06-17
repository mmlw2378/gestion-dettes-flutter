// lib/controllers/client_controller.dart - CONTRÔLEUR COMPLET
import 'package:flutter/material.dart';
import '../models/client_model.dart';
import '../services/api_service.dart';

class ClientController {
  // État du contrôleur
  List<ClientModel> _clients = [];
  bool _isLoading = false;
  String? _error;

  // Callbacks pour notifier les vues
  VoidCallback? onStateChanged;
  Function(String)? onSuccess;
  Function(String)? onError;

  // Getters publics (lecture seule)
  List<ClientModel> get clients => List.unmodifiable(_clients);
  bool get isLoading => _isLoading;
  String? get error => _error;

  // Statistiques calculées
  int get totalClients => _clients.length;
  int get totalDettes =>
      _clients.fold(0, (sum, client) => sum + client.nombreDettes);
  double get montantTotalRestant =>
      _clients.fold(0.0, (sum, client) => sum + client.totalDettes);

  // MÉTHODE : Charger tous les clients
  Future<void> loadClients() async {
    print('🎮 Controller: Chargement des clients...');
    _setLoading(true);
    _clearError();

    try {
      final clientsJson = await ApiService.getClientsJson();
      _clients = clientsJson.map((json) => ClientModel.fromJson(json)).toList();

      print('✅ Controller: ${_clients.length} clients chargés');
      onSuccess?.call('Clients chargés avec succès');
    } catch (e) {
      final errorMsg = 'Erreur lors du chargement: $e';
      _setError(errorMsg);
      onError?.call(errorMsg);
      print('❌ Controller: $errorMsg');
    } finally {
      _setLoading(false);
    }
  }

  // MÉTHODE : Ajouter un client
  Future<bool> addClient(String nom, String telephone, String adresse) async {
    print('🎮 Controller: Ajout du client $nom...');
    _clearError();

    try {
      // Validation métier
      final validation = _validateClientData(nom, telephone, adresse);
      if (validation != null) {
        _setError(validation);
        onError?.call(validation);
        return false;
      }

      // Préparer les données
      final clientData = {
        'nom': nom.trim(),
        'telephone': telephone.trim(),
        'adresse': adresse.trim(),
        'dettes': [],
      };

      // Appeler l'API
      final result = await ApiService.addClientJson(clientData);

      // Ajouter à la liste locale
      final newClient = ClientModel.fromJson(result);
      _clients.add(newClient);

      final successMsg = 'Client ${newClient.nom} ajouté avec succès';
      print('✅ Controller: $successMsg');
      onSuccess?.call(successMsg);
      _notifyChange();
      return true;
    } catch (e) {
      final errorMsg = 'Erreur lors de l\'ajout: $e';
      _setError(errorMsg);
      onError?.call(errorMsg);
      print('❌ Controller: $errorMsg');
      return false;
    }
  }

  // MÉTHODE : Ajouter une dette à un client
  Future<bool> addDetteToClient(
    String clientId,
    String date,
    double montant,
  ) async {
    print('🎮 Controller: Ajout dette au client $clientId...');
    _clearError();

    try {
      // Validation métier
      final validation = _validateDetteData(date, montant);
      if (validation != null) {
        _setError(validation);
        onError?.call(validation);
        return false;
      }

      // Trouver le client
      final clientIndex = _clients.indexWhere((c) => c.id == clientId);
      if (clientIndex == -1) {
        const errorMsg = 'Client non trouvé';
        _setError(errorMsg);
        onError?.call(errorMsg);
        return false;
      }

      final client = _clients[clientIndex];

      // Créer la nouvelle dette
      final newDette = DetteModel(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        date: date,
        montantDette: montant,
      );

      // Mettre à jour le modèle
      final updatedClient = client.copyWith(
        dettes: [...client.dettes, newDette],
      );

      // Appeler l'API
      final result = await ApiService.updateClientJson(
        clientId,
        updatedClient.toJson(),
      );

      // Mettre à jour la liste locale
      _clients[clientIndex] = ClientModel.fromJson(result);

      final successMsg = 'Dette de ${montant.toStringAsFixed(0)} FCFA ajoutée';
      print('✅ Controller: $successMsg');
      onSuccess?.call(successMsg);
      _notifyChange();
      return true;
    } catch (e) {
      final errorMsg = 'Erreur lors de l\'ajout de la dette: $e';
      _setError(errorMsg);
      onError?.call(errorMsg);
      print('❌ Controller: $errorMsg');
      return false;
    }
  }

  // MÉTHODE : Actualiser un client
  Future<void> refreshClient(String clientId) async {
    print('🎮 Controller: Actualisation du client $clientId...');

    try {
      final clientJson = await ApiService.getClientJson(clientId);
      final updatedClient = ClientModel.fromJson(clientJson);

      final index = _clients.indexWhere((c) => c.id == clientId);
      if (index != -1) {
        _clients[index] = updatedClient;
        _notifyChange();
        print('✅ Controller: Client actualisé');
      }
    } catch (e) {
      print('❌ Controller: Erreur lors de l\'actualisation: $e');
    }
  }

  // MÉTHODE : Récupérer un client par ID
  ClientModel? getClientById(String clientId) {
    try {
      return _clients.firstWhere((c) => c.id == clientId);
    } catch (e) {
      return null;
    }
  }

  // MÉTHODE : Récupérer les dettes d'un client
  List<DetteModel> getClientDettes(String clientId) {
    final client = getClientById(clientId);
    return client?.dettes ?? [];
  }

  // MÉTHODE : Ajouter un paiement à une dette
  Future<bool> ajouterPaiementADette(
    String clientId,
    String detteId,
    String date,
    double montant, {
    String? commentaire,
  }) async {
    print(
      '🎮 Controller: Ajout paiement à la dette $detteId du client $clientId...',
    );
    _clearError();

    try {
      // Validation métier
      if (montant <= 0) {
        const errorMsg = 'Le montant du paiement doit être positif';
        _setError(errorMsg);
        onError?.call(errorMsg);
        return false;
      }

      // Trouver le client
      final clientIndex = _clients.indexWhere((c) => c.id == clientId);
      if (clientIndex == -1) {
        const errorMsg = 'Client non trouvé';
        _setError(errorMsg);
        onError?.call(errorMsg);
        return false;
      }

      final client = _clients[clientIndex];

      // Trouver la dette
      final detteIndex = client.dettes.indexWhere((d) => d.id == detteId);
      if (detteIndex == -1) {
        const errorMsg = 'Dette non trouvée';
        _setError(errorMsg);
        onError?.call(errorMsg);
        return false;
      }

      final dette = client.dettes[detteIndex];

      // Vérifier que le paiement ne dépasse pas le montant restant
      if (montant > dette.montantRestant) {
        final errorMsg =
            'Le paiement (${montant.toStringAsFixed(0)} FCFA) dépasse le montant restant (${dette.montantRestant.toStringAsFixed(0)} FCFA)';
        _setError(errorMsg);
        onError?.call(errorMsg);
        return false;
      }

      // Créer le nouveau paiement
      final nouveauPaiement = PaiementModel(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        date: date,
        montant: montant,
        commentaire: commentaire,
      );

      // Ajouter le paiement à la dette
      final detteAvecPaiement = dette.ajouterPaiement(nouveauPaiement);

      // Mettre à jour la liste des dettes du client
      final nouvellesDettes = List<DetteModel>.from(client.dettes);
      nouvellesDettes[detteIndex] = detteAvecPaiement;

      // Mettre à jour le client
      final clientMisAJour = client.copyWith(dettes: nouvellesDettes);

      // Appeler l'API pour sauvegarder
      final result = await ApiService.updateClientJson(
        clientId,
        clientMisAJour.toJson(),
      );

      // Mettre à jour la liste locale
      _clients[clientIndex] = ClientModel.fromJson(result);

      final successMsg =
          'Paiement de ${montant.toStringAsFixed(0)} FCFA ajouté';
      print('✅ Controller: $successMsg');
      onSuccess?.call(successMsg);
      _notifyChange();
      return true;
    } catch (e) {
      final errorMsg = 'Erreur lors de l\'ajout du paiement: $e';
      _setError(errorMsg);
      onError?.call(errorMsg);
      print('❌ Controller: $errorMsg');
      return false;
    }
  }

  // MÉTHODE : Récupérer les paiements d'une dette
  List<PaiementModel> getPaiementsDette(String clientId, String detteId) {
    try {
      final client = _clients.firstWhere((c) => c.id == clientId);
      final dette = client.dettes.firstWhere((d) => d.id == detteId);
      return dette.paiements;
    } catch (e) {
      print('❌ Controller: Impossible de récupérer les paiements: $e');
      return [];
    }
  }

  // MÉTHODE : Récupérer une dette spécifique
  DetteModel? getDette(String clientId, String detteId) {
    try {
      final client = _clients.firstWhere((c) => c.id == clientId);
      return client.dettes.firstWhere((d) => d.id == detteId);
    } catch (e) {
      print('❌ Controller: Dette non trouvée: $e');
      return null;
    }
  }

  // MÉTHODE : Récupérer clients avec dettes
  List<ClientModel> getClientsWithDebts() {
    return _clients.where((client) => client.hasDebts).toList();
  }

  // MÉTHODE : Récupérer clients sans dettes
  List<ClientModel> getClientsWithoutDebts() {
    return _clients.where((client) => !client.hasDebts).toList();
  }

  // MÉTHODE : Statistiques des paiements
  Map<String, dynamic> getStatistiquesPaiements() {
    int totalPaiements = 0;
    double montantTotalPaiements = 0.0;

    for (final client in _clients) {
      for (final dette in client.dettes) {
        totalPaiements += dette.paiements.length;
        montantTotalPaiements += dette.montantPaye;
      }
    }

    return {
      'totalPaiements': totalPaiements,
      'montantTotalPaiements': montantTotalPaiements,
      'moyennePaiement': totalPaiements > 0
          ? montantTotalPaiements / totalPaiements
          : 0.0,
    };
  }

  // MÉTHODES DE VALIDATION PRIVÉES

  String? _validateClientData(String nom, String telephone, String adresse) {
    if (nom.trim().isEmpty) return 'Le nom est obligatoire';
    if (telephone.trim().isEmpty) return 'Le téléphone est obligatoire';
    if (adresse.trim().isEmpty) return 'L\'adresse est obligatoire';

    // Vérifier si le client existe déjà
    final existingClient = _clients.any(
      (c) =>
          c.nom.toLowerCase() == nom.trim().toLowerCase() &&
          c.telephone == telephone.trim(),
    );
    if (existingClient) return 'Un client avec ce nom et téléphone existe déjà';

    return null;
  }

  String? _validateDetteData(String date, double montant) {
    if (date.trim().isEmpty) return 'La date est obligatoire';
    if (montant <= 0) return 'Le montant doit être positif';
    if (montant > 1000000)
      return 'Le montant ne peut pas dépasser 1 000 000 FCFA';
    return null;
  }

  // MÉTHODES UTILITAIRES PRIVÉES

  void _setLoading(bool loading) {
    _isLoading = loading;
    _notifyChange();
  }

  void _setError(String error) {
    _error = error;
    _notifyChange();
  }

  void _clearError() {
    _error = null;
    _notifyChange();
  }

  void _notifyChange() {
    onStateChanged?.call();
  }

  // Nettoyage
  void dispose() {
    onStateChanged = null;
    onSuccess = null;
    onError = null;
  }
}
