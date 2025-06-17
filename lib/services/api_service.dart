import 'dart:convert';
import 'package:http/http.dart' as http;

class ApiService {
  static const String baseUrl = 'http://192.168.1.9:3000';
  static const Duration timeout = Duration(seconds: 15);

  static Future<List<Map<String, dynamic>>> getClientsJson() async {
    try {
      print('🔄 API: Récupération des clients...');
      final response = await http.get(
        Uri.parse('$baseUrl/clients'),
      ).timeout(timeout);
      
      if (response.statusCode == 200) {
        print('✅ API: Clients récupérés avec succès');
        final List<dynamic> data = json.decode(response.body);
        return data.cast<Map<String, dynamic>>();
      } else {
        throw Exception('Erreur serveur: ${response.statusCode}');
      }
    } catch (e) {
      print('❌ API: Erreur de connexion: $e');
      throw Exception('Erreur de connexion: $e');
    }
  }

  static Future<Map<String, dynamic>> addClientJson(Map<String, dynamic> clientData) async {
    try {
      print('🔄 API: Ajout du client...');
      final response = await http.post(
        Uri.parse('$baseUrl/clients'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode(clientData),
      ).timeout(timeout);
      
      if (response.statusCode == 201) {
        print('✅ API: Client ajouté avec succès');
        return json.decode(response.body);
      } else {
        throw Exception('Erreur lors de l\'ajout: ${response.statusCode}');
      }
    } catch (e) {
      print('❌ API: Erreur lors de l\'ajout: $e');
      throw Exception('Erreur de connexion: $e');
    }
  }

  static Future<Map<String, dynamic>> updateClientJson(String clientId, Map<String, dynamic> clientData) async {
    try {
      print('🔄 API: Mise à jour du client $clientId...');
      final response = await http.put(
        Uri.parse('$baseUrl/clients/$clientId'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode(clientData),
      ).timeout(timeout);
      
      if (response.statusCode == 200) {
        print('✅ API: Client mis à jour avec succès');
        return json.decode(response.body);
      } else {
        throw Exception('Erreur lors de la mise à jour: ${response.statusCode}');
      }
    } catch (e) {
      print('❌ API: Erreur lors de la mise à jour: $e');
      throw Exception('Erreur de connexion: $e');
    }
  }

  static Future<Map<String, dynamic>> getClientJson(String clientId) async {
    try {
      print('🔄 API: Récupération du client $clientId...');
      final response = await http.get(
        Uri.parse('$baseUrl/clients/$clientId')
      ).timeout(timeout);
      
      if (response.statusCode == 200) {
        print('✅ API: Client récupéré avec succès');
        return json.decode(response.body);
      } else {
        throw Exception('Client non trouvé');
      }
    } catch (e) {
      print('❌ API: Erreur lors de la récupération: $e');
      throw Exception('Erreur de connexion: $e');
    }
  }
}