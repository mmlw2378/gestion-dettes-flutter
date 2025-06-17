import 'package:flutter/material.dart';
import '../controllers/client_controller.dart';
import '../models/client_model.dart';
import 'add_client_view.dart';
import 'client_detail_view.dart';

class HomeView extends StatefulWidget {
  @override
  _HomeViewState createState() => _HomeViewState();
}

class _HomeViewState extends State<HomeView> {
  late ClientController _controller;

  @override
  void initState() {
    super.initState();
    _controller = ClientController();
    _setupControllerCallbacks();
    _controller.loadClients();
  }

  void _setupControllerCallbacks() {
    _controller.onStateChanged = () {
      if (mounted) setState(() {});
    };
    
    _controller.onSuccess = (message) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(message),
            backgroundColor: Colors.green,
          ),
        );
      }
    };
    
    _controller.onError = (message) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(message),
            backgroundColor: Colors.red,
          ),
        );
      }
    };
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Gestion des Dettes'),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: Column(
        children: [
          _buildHeader(),
          Expanded(child: _buildBody()),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _navigateToAddClient(),
        backgroundColor: Colors.blue,
        child: Icon(Icons.add, color: Colors.white),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      width: double.infinity,
      color: Colors.blue,
      padding: EdgeInsets.all(16),
      child: Column(
        children: [
          Text(
            'Tableau de Bord',
            style: TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.w500,
            ),
          ),
          SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildStatCard('Clients', _controller.totalClients.toString()),
              _buildStatCard('Dettes', _controller.totalDettes.toString()),
              _buildStatCard('Total', '${_controller.montantTotalRestant.toStringAsFixed(0)} F'),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard(String title, String value) {
    return Container(
      padding: EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.2),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        children: [
          Text(
            value,
            style: TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 4),
          Text(
            title,
            style: TextStyle(
              color: Colors.white,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBody() {
    if (_controller.isLoading) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(),
            SizedBox(height: 16),
            Text('Chargement des clients...'),
          ],
        ),
      );
    }

    if (_controller.error != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error, size: 64, color: Colors.red),
            SizedBox(height: 16),
            Text(
              'Erreur de connexion',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8),
            Text(
              _controller.error!,
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey),
            ),
            SizedBox(height: 16),
            ElevatedButton(
              onPressed: () => _controller.loadClients(),
              child: Text('Réessayer'),
            ),
          ],
        ),
      );
    }

    if (_controller.clients.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.people_outline, size: 64, color: Colors.grey),
            SizedBox(height: 16),
            Text(
              'Aucun client trouvé',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8),
            Text('Ajoutez votre premier client'),
            SizedBox(height: 16),
            ElevatedButton(
              onPressed: () => _navigateToAddClient(),
              child: Text('Ajouter un client'),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: () => _controller.loadClients(),
      child: ListView.builder(
        padding: EdgeInsets.all(8),
        itemCount: _controller.clients.length,
        itemBuilder: (context, index) {
          final client = _controller.clients[index];
          return _buildClientCard(client);
        },
      ),
    );
  }

  Widget _buildClientCard(ClientModel client) {
    return Card(
      margin: EdgeInsets.symmetric(vertical: 4, horizontal: 8),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: client.hasDebts ? Colors.red : Colors.green,
          child: Text(
            client.nom.isNotEmpty ? client.nom[0].toUpperCase() : '?',
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
          ),
        ),
        title: Text(
          client.nom,
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('📞 ${client.telephone}'),
            Text('📍 ${client.adresse}'),
            SizedBox(height: 4),
            Text(
              '${client.nombreDettes} dette(s) - ${client.totalDettes.toStringAsFixed(0)} FCFA',
              style: TextStyle(
                color: client.hasDebts ? Colors.red : Colors.green,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
        trailing: Icon(Icons.arrow_forward_ios, size: 16),
        onTap: () => _navigateToClientDetail(client),
      ),
    );
  }

  void _navigateToAddClient() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => AddClientView(controller: _controller),
      ),
    );
  }

  void _navigateToClientDetail(ClientModel client) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ClientDetailView(client: client, controller: _controller),
      ),
    );
  }
}