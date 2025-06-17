import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/client.dart';
import '../providers/client_provider.dart';
import 'add_dette_screen.dart';

class ClientDetailScreen extends StatelessWidget {
  final Client client;

  const ClientDetailScreen({Key? key, required this.client}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(client.nom),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
      ),
      body: Consumer<ClientProvider>(
        builder: (context, clientProvider, child) {
          final currentClient = clientProvider.getClientById(client.id!) ?? client;
          final totalMontantDette = currentClient.dettes.fold(0.0, (sum, dette) => sum + dette.montantDette);
          final totalMontantPaye = currentClient.dettes.fold(0.0, (sum, dette) => sum + dette.montantPaye);
          final totalMontantRestant = currentClient.dettes.fold(0.0, (sum, dette) => sum + dette.montantRestant);

          return Column(
            children: [
              // Informations du client
              Container(
                width: double.infinity,
                padding: EdgeInsets.all(16),
                margin: EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.blue.shade50,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.blue.shade200),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Informations du client',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.blue.shade800,
                      ),
                    ),
                    SizedBox(height: 12),
                    Row(
                      children: [
                        Icon(Icons.person, color: Colors.blue),
                        SizedBox(width: 8),
                        Text('Nom: ${currentClient.nom}', style: TextStyle(fontSize: 16)),
                      ],
                    ),
                    SizedBox(height: 8),
                    Row(
                      children: [
                        Icon(Icons.phone, color: Colors.blue),
                        SizedBox(width: 8),
                        Text('Téléphone: ${currentClient.telephone}', style: TextStyle(fontSize: 16)),
                      ],
                    ),
                    SizedBox(height: 8),
                    Row(
                      children: [
                        Icon(Icons.location_on, color: Colors.blue),
                        SizedBox(width: 8),
                        Expanded(
                          child: Text('Adresse: ${currentClient.adresse}', style: TextStyle(fontSize: 16)),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              // Résumé des dettes
              Container(
                width: double.infinity,
                padding: EdgeInsets.all(16),
                margin: EdgeInsets.symmetric(horizontal: 16),
                decoration: BoxDecoration(
                  color: Colors.grey.shade50,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.grey.shade300),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Résumé des dettes',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.grey.shade800,
                      ),
                    ),
                    SizedBox(height: 12),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('Total des dettes:', style: TextStyle(fontSize: 16)),
                        Text('${totalMontantDette.toStringAsFixed(0)} FCFA', 
                             style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                      ],
                    ),
                    SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('Total payé:', style: TextStyle(fontSize: 16)),
                        Text('${totalMontantPaye.toStringAsFixed(0)} FCFA', 
                             style: TextStyle(fontSize: 16, color: Colors.green, fontWeight: FontWeight.bold)),
                      ],
                    ),
                    SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('Total restant:', style: TextStyle(fontSize: 16)),
                        Text('${totalMontantRestant.toStringAsFixed(0)} FCFA', 
                             style: TextStyle(fontSize: 16, color: Colors.red, fontWeight: FontWeight.bold)),
                      ],
                    ),
                  ],
                ),
              ),

              SizedBox(height: 16),

              // Liste des dettes
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Dettes (${currentClient.dettes.length})',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    ElevatedButton.icon(
                      onPressed: () => _navigateToAddDette(context),
                      icon: Icon(Icons.add, size: 18),
                      label: Text('Ajouter'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green,
                        foregroundColor: Colors.white,
                        padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      ),
                    ),
                  ],
                ),
              ),

              SizedBox(height: 8),

              Expanded(
                child: currentClient.dettes.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.receipt_long_outlined, size: 64, color: Colors.grey),
                            SizedBox(height: 16),
                            Text(
                              'Aucune dette trouvée',
                              style: TextStyle(fontSize: 16, color: Colors.grey),
                            ),
                            SizedBox(height: 16),
                            ElevatedButton(
                              onPressed: () => _navigateToAddDette(context),
                              child: Text('Ajouter une dette'),
                            ),
                          ],
                        ),
                      )
                    : ListView.builder(
                        padding: EdgeInsets.symmetric(horizontal: 16),
                        itemCount: currentClient.dettes.length,
                        itemBuilder: (context, index) {
                          final dette = currentClient.dettes[index];
                          return Card(
                            margin: EdgeInsets.only(bottom: 8),
                            child: ListTile(
                              leading: CircleAvatar(
                                backgroundColor: dette.montantRestant > 0 ? Colors.red : Colors.green,
                                child: Icon(
                                  dette.montantRestant > 0 ? Icons.attach_money : Icons.check,
                                  color: Colors.white,
                                ),
                              ),
                              title: Text('Dette du ${dette.date}'),
                              subtitle: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text('Montant: ${dette.montantDette.toStringAsFixed(0)} FCFA'),
                                  Text('Payé: ${dette.montantPaye.toStringAsFixed(0)} FCFA'),
                                  Text(
                                    'Restant: ${dette.montantRestant.toStringAsFixed(0)} FCFA',
                                    style: TextStyle(
                                      color: dette.montantRestant > 0 ? Colors.red : Colors.green,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                              trailing: Text(
                                '${dette.paiements.length} paiement(s)',
                                style: TextStyle(color: Colors.grey),
                              ),
                            ),
                          );
                        },
                      ),
              ),
            ],
          );
        },
      ),
    );
  }

  void _navigateToAddDette(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => AddDetteScreen(client: client),
      ),
    );
  }
}
