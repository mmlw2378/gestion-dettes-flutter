import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/client.dart';

class ApiService {
  static const String baseUrl = 'http://192.168.1.9:3000';

  // Timeout pour éviter les blocages
  static const Duration timeout = Duration(seconds: 15);

  // Récupérer tous les clients
  static Future<List<Client>> getClients() async {
    try {
      print('🔄 Tentative de connexion à : $baseUrl/clients');
      final response = await http
          .get(Uri.parse('$baseUrl/clients'))
          .timeout(timeout);

      if (response.statusCode == 200) {
        print('✅ Connexion réussie ! ${response.body.length} caractères reçus');
        final List<dynamic> data = json.decode(response.body);
        return data.map((json) => Client.fromJson(json)).toList();
      } else {
        print('❌ Erreur serveur: ${response.statusCode}');
        throw Exception('Erreur serveur: ${response.statusCode}');
      }
    } catch (e) {
      print('❌ Erreur de connexion: $e');
      throw Exception('Erreur de connexion: $e');
    }
  }

  // Ajouter un client
  static Future<Client> addClient(Client client) async {
    try {
      print('🔄 Ajout du client: ${client.nom}');
      final response = await http
          .post(
            Uri.parse('$baseUrl/clients'),
            headers: {'Content-Type': 'application/json'},
            body: json.encode(client.toJson()),
          )
          .timeout(timeout);

      if (response.statusCode == 201) {
        print('✅ Client ajouté avec succès');
        return Client.fromJson(json.decode(response.body));
      } else {
        print('❌ Erreur lors de l\'ajout: ${response.statusCode}');
        throw Exception(
          'Erreur lors de l\'ajout du client: ${response.statusCode}',
        );
      }
    } catch (e) {
      print('❌ Erreur de connexion lors de l\'ajout: $e');
      throw Exception('Erreur de connexion: $e');
    }
  }

  // Mettre à jour un client
  static Future<Client> updateClient(Client client) async {
    try {
      print('🔄 Mise à jour du client ID: ${client.id}');
      final response = await http
          .put(
            Uri.parse('$baseUrl/clients/${client.id}'),
            headers: {'Content-Type': 'application/json'},
            body: json.encode(client.toJson()),
          )
          .timeout(timeout);

      if (response.statusCode == 200) {
        print('✅ Client mis à jour avec succès');
        return Client.fromJson(json.decode(response.body));
      } else {
        print('❌ Erreur lors de la mise à jour: ${response.statusCode}');
        throw Exception(
          'Erreur lors de la mise à jour du client: ${response.statusCode}',
        );
      }
    } catch (e) {
      print('❌ Erreur de connexion lors de la mise à jour: $e');
      throw Exception('Erreur de connexion: $e');
    }
  }

  // Récupérer un client par ID
  static Future<Client> getClient(int id) async {
    try {
      print('🔄 Récupération du client ID: $id');
      final response = await http
          .get(Uri.parse('$baseUrl/clients/$id'))
          .timeout(timeout);

      if (response.statusCode == 200) {
        print('✅ Client récupéré avec succès');
        return Client.fromJson(json.decode(response.body));
      } else {
        print('❌ Client non trouvé: ${response.statusCode}');
        throw Exception('Client non trouvé');
      }
    } catch (e) {
      print('❌ Erreur de connexion lors de la récupération: $e');
      throw Exception('Erreur de connexion: $e');
    }
  }
}
