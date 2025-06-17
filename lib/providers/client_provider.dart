import 'package:flutter/material.dart';
import '../models/client.dart';
import '../services/api_service.dart';

class ClientProvider with ChangeNotifier {
  List<Client> _clients = [];
  bool _isLoading = false;
  String? _error;

  List<Client> get clients => _clients;
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<void> loadClients() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _clients = await ApiService.getClients();
      print('✅ ${_clients.length} clients chargés');
    } catch (e) {
      _error = e.toString();
      print('❌ Erreur lors du chargement: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> addClient(Client client) async {
    try {
      print('🔄 Ajout du client: ${client.nom}');
      final newClient = await ApiService.addClient(client);
      _clients.add(newClient);
      print('✅ Client ajouté avec ID: ${newClient.id}');
      notifyListeners();
      return true;
    } catch (e) {
      _error = e.toString();
      print('❌ Erreur lors de l\'ajout du client: $e');
      notifyListeners();
      return false;
    }
  }

  // Ajouter une dette à un client 
  Future<bool> addDetteToClient(String clientId, Dette dette) async {
    try {
      print('🔄 Ajout d\'une dette au client ID: $clientId');
      
      final clientIndex = _clients.indexWhere((c) => c.id == clientId);
      if (clientIndex == -1) {
        print('❌ Client non trouvé avec ID: $clientId');
        _error = 'Client non trouvé';
        notifyListeners();
        return false;
      }

      final client = _clients[clientIndex];
      print('✅ Client trouvé: ${client.nom}');
      
      // Générer un ID unique pour la dette
      final newDette = Dette(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        date: dette.date,
        montantDette: dette.montantDette,
        paiements: dette.paiements,
      );
      
      final updatedDettes = List<Dette>.from(client.dettes)..add(newDette);
      final updatedClient = client.copyWith(dettes: updatedDettes);
      
      print('🔄 Mise à jour du client avec ${updatedDettes.length} dette(s)');
      
      final result = await ApiService.updateClient(updatedClient);
      _clients[clientIndex] = result;
      
      print('✅ Dette ajoutée avec succès');
      notifyListeners();
      return true;
      
    } catch (e) {
      _error = e.toString();
      print('❌ Erreur lors de l\'ajout de la dette: $e');
      notifyListeners();
      return false;
    }
  }

  List<Dette> getClientDettes(String clientId) {
    try {
      final client = _clients.firstWhere((c) => c.id == clientId);
      return client.dettes;
    } catch (e) {
      print('❌ Client non trouvé pour ID: $clientId');
      return [];
    }
  }

  Client? getClientById(String clientId) {
    try {
      return _clients.firstWhere((c) => c.id == clientId);
    } catch (e) {
      print('❌ Client non trouvé pour ID: $clientId');
      return null;
    }
  }
}