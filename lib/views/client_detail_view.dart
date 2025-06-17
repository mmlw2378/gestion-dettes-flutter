import 'package:flutter/material.dart';
import '../controllers/client_controller.dart';
import '../models/client_model.dart';
import 'add_dette_view.dart';
import 'dette_detail_view.dart';

class ClientDetailView extends StatefulWidget {
  final ClientModel client;
  final ClientController controller;

  const ClientDetailView({
    Key? key,
    required this.client,
    required this.controller,
  }) : super(key: key);

  @override
  _ClientDetailViewState createState() => _ClientDetailViewState();
}

class _ClientDetailViewState extends State<ClientDetailView> {
  late ClientModel _currentClient;

  @override
  void initState() {
    super.initState();
    _currentClient = widget.client;

    widget.controller.onStateChanged = () {
      if (mounted) {
        final updatedClient = widget.controller.getClientById(
          widget.client.id!,
        );
        if (updatedClient != null) {
          setState(() {
            _currentClient = updatedClient;
          });
        }
      }
    };
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_currentClient.nom),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: Icon(Icons.refresh),
            onPressed: () =>
                widget.controller.refreshClient(_currentClient.id!),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildClientInfo(),
            SizedBox(height: 20),
            _buildDettesSection(),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _navigateToAddDette(),
        backgroundColor: Colors.green,
        child: Icon(Icons.add, color: Colors.white),
      ),
    );
  }

  Widget _buildClientInfo() {
    return Card(
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Informations du client',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 16),
            Row(
              children: [
                Icon(Icons.person, color: Colors.blue),
                SizedBox(width: 8),
                Text('Nom: ${_currentClient.nom}'),
              ],
            ),
            SizedBox(height: 8),
            Row(
              children: [
                Icon(Icons.phone, color: Colors.blue),
                SizedBox(width: 8),
                Text('Téléphone: ${_currentClient.telephone}'),
              ],
            ),
            SizedBox(height: 8),
            Row(
              children: [
                Icon(Icons.location_on, color: Colors.blue),
                SizedBox(width: 8),
                Expanded(child: Text('Adresse: ${_currentClient.adresse}')),
              ],
            ),
            SizedBox(height: 16),
            Container(
              width: double.infinity,
              padding: EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: _currentClient.hasDebts
                    ? Colors.red.shade50
                    : Colors.green.shade50,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: _currentClient.hasDebts ? Colors.red : Colors.green,
                ),
              ),
              child: Column(
                children: [
                  Text(
                    'Résumé des dettes',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 8),
                  Text('${_currentClient.nombreDettes} dette(s)'),
                  Text(
                    'Total: ${_currentClient.totalDettes.toStringAsFixed(0)} FCFA',
                    style: TextStyle(
                      color: _currentClient.hasDebts
                          ? Colors.red
                          : Colors.green,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDettesSection() {
    return Card(
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Dettes (${_currentClient.nombreDettes})',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                ElevatedButton.icon(
                  onPressed: () => _navigateToAddDette(),
                  icon: Icon(Icons.add, size: 16),
                  label: Text('Ajouter'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    foregroundColor: Colors.white,
                  ),
                ),
              ],
            ),
            SizedBox(height: 16),
            if (_currentClient.dettes.isEmpty)
              _buildEmptyDettes()
            else
              ..._currentClient.dettes
                  .map((dette) => _buildDetteCard(dette))
                  .toList(),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyDettes() {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(32),
      child: Column(
        children: [
          Icon(Icons.receipt_long_outlined, size: 48, color: Colors.grey),
          SizedBox(height: 16),
          Text(
            'Aucune dette trouvée',
            style: TextStyle(fontSize: 16, color: Colors.grey),
          ),
          SizedBox(height: 8),
          Text(
            'Ajoutez la première dette de ce client',
            style: TextStyle(color: Colors.grey),
          ),
        ],
      ),
    );
  }

  Widget _buildDetteCard(DetteModel dette) {
    return Container(
      margin: EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(8),
          onTap: () =>
              _navigateToDetteDetail(dette), // ← NAVIGATION VERS DÉTAIL
          child: Padding(
            padding: EdgeInsets.all(12),
            child: Row(
              children: [
                Icon(
                  dette.montantRestant > 0
                      ? Icons.attach_money
                      : Icons.check_circle,
                  color: dette.montantRestant > 0 ? Colors.red : Colors.green,
                ),
                SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Dette du ${dette.date}',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      Text(
                        'Montant: ${dette.montantDette.toStringAsFixed(0)} FCFA',
                      ),
                      Text(
                        'Restant: ${dette.montantRestant.toStringAsFixed(0)} FCFA',
                        style: TextStyle(
                          color: dette.montantRestant > 0
                              ? Colors.red
                              : Colors.green,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      // ← AFFICHAGE DES PAIEMENTS
                      Text(
                        '${dette.paiements.length} paiement(s) - ${dette.montantPaye.toStringAsFixed(0)} FCFA payé',
                        style: TextStyle(fontSize: 12, color: Colors.blue),
                      ),
                    ],
                  ),
                ),
                Column(
                  children: [
                    Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey),
                    SizedBox(height: 4),
                    Text(
                      'Voir détails',
                      style: TextStyle(fontSize: 10, color: Colors.grey),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _navigateToAddDette() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) =>
            AddDetteView(client: _currentClient, controller: widget.controller),
      ),
    );
  }

  // ← NOUVELLE NAVIGATION VERS DÉTAIL DETTE
  void _navigateToDetteDetail(DetteModel dette) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => DetteDetailView(
          client: _currentClient,
          dette: dette,
          controller: widget.controller,
        ),
      ),
    );
  }
}
