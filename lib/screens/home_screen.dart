import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/client_provider.dart';
import 'add_client_screen.dart';
import 'client_detail_screen.dart';

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<ClientProvider>(context, listen: false).loadClients();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Gestion des Dettes'),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
      ),
      body: Consumer<ClientProvider>(
        builder: (context, clientProvider, child) {
          if (clientProvider.isLoading) {
            return Center(child: CircularProgressIndicator());
          }

          if (clientProvider.error != null) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.error, size: 64, color: Colors.red),
                  SizedBox(height: 16),
                  Text(
                    'Erreur: ${clientProvider.error}',
                    style: TextStyle(color: Colors.red, fontSize: 16),
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () => clientProvider.loadClients(),
                    child: Text('Réessayer'),
                  ),
                ],
              ),
            );
          }

          if (clientProvider.clients.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.people_outline, size: 64, color: Colors.grey),
                  SizedBox(height: 16),
                  Text(
                    'Aucun client trouvé',
                    style: TextStyle(fontSize: 18, color: Colors.grey),
                  ),
                  SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () => _navigateToAddClient(context),
                    child: Text('Ajouter un client'),
                  ),
                ],
              ),
            );
          }

          return RefreshIndicator(
            onRefresh: () => clientProvider.loadClients(),
            child: ListView.builder(
              itemCount: clientProvider.clients.length,
              itemBuilder: (context, index) {
                final client = clientProvider.clients[index];
                final totalDettes = client.dettes.length;
                final montantTotal = client.dettes.fold(
                  0.0,
                  (sum, dette) => sum + dette.montantRestant,
                );

                return Card(
                  margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: ListTile(
                    leading: CircleAvatar(
                      backgroundColor: Colors.blue,
                      child: Text(
                        client.nom.isNotEmpty
                            ? client.nom[0].toUpperCase()
                            : '?',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
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
                          '$totalDettes dette(s) - ${montantTotal.toStringAsFixed(0)} FCFA restant',
                          style: TextStyle(
                            color: montantTotal > 0 ? Colors.red : Colors.green,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                    trailing: Icon(Icons.arrow_forward_ios),
                    onTap: () => _navigateToClientDetail(context, client),
                  ),
                );
              },
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _navigateToAddClient(context),
        child: Icon(Icons.add),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
      ),
    );
  }

  void _navigateToAddClient(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => AddClientScreen()),
    );
  }

  void _navigateToClientDetail(BuildContext context, client) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ClientDetailScreen(client: client),
      ),
    );
  }
}
