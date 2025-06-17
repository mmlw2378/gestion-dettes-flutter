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

  // ACTIONS DU CONTRÔLEUR

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

  // MÉTHODES DE CONSULTATION

  ClientModel? getClientById(String clientId) {
    try {
      return _clients.firstWhere((c) => c.id == clientId);
    } catch (e) {
      return null;
    }
  }

  List<DetteModel> getClientDettes(String clientId) {
    final client = getClientById(clientId);
    return client?.dettes ?? [];
  }

  List<ClientModel> getClientsWithDebts() {
    return _clients.where((client) => client.hasDebts).toList();
  }

  List<ClientModel> getClientsWithoutDebts() {
    return _clients.where((client) => !client.hasDebts).toList();
  }

  // MÉTHODES PRIVÉES

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
