import 'package:flutter/material.dart';
import '../controllers/client_controller.dart';
import '../models/client_model.dart';

class DetteDetailView extends StatefulWidget {
  final ClientModel client;
  final DetteModel dette;
  final ClientController controller;

  const DetteDetailView({
    Key? key,
    required this.client,
    required this.dette,
    required this.controller,
  }) : super(key: key);

  @override
  _DetteDetailViewState createState() => _DetteDetailViewState();
}

class _DetteDetailViewState extends State<DetteDetailView> {
  late DetteModel _currentDette;

  @override
  void initState() {
    super.initState();
    _currentDette = widget.dette;
    
    widget.controller.onStateChanged = () {
      if (mounted) {
        final updatedDette = widget.controller.getDette(widget.client.id!, widget.dette.id!);
        if (updatedDette != null) {
          setState(() {
            _currentDette = updatedDette;
          });
        }
      }
    };
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Dette du ${_currentDette.date}'),
        backgroundColor: Colors.orange,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildDetteInfo(),
            SizedBox(height: 20),
            _buildPaiementsSection(), // ← SECTION PAIEMENTS
          ],
        ),
      ),
      floatingActionButton: _currentDette.montantRestant > 0 
        ? FloatingActionButton(
            onPressed: () => _ajouterPaiement(),
            backgroundColor: Colors.green,
            child: Icon(Icons.payment, color: Colors.white),
          )
        : null,
    );
  }

  Widget _buildDetteInfo() {
    return Card(
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Informations de la dette',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 16),
            _buildInfoRow('Client', widget.client.nom),
            _buildInfoRow('Date', _currentDette.date),
            _buildInfoRow('Montant initial', '${_currentDette.montantDette.toStringAsFixed(0)} FCFA'),
            _buildInfoRow('Montant payé', '${_currentDette.montantPaye.toStringAsFixed(0)} FCFA'),
            _buildInfoRow('Montant restant', '${_currentDette.montantRestant.toStringAsFixed(0)} FCFA'),
            _buildInfoRow('Pourcentage payé', '${_currentDette.pourcentagePaye.toStringAsFixed(1)}%'),
            
            SizedBox(height: 16),
            Container(
              width: double.infinity,
              padding: EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: _currentDette.estPayee ? Colors.green.shade50 : Colors.orange.shade50,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: _currentDette.estPayee ? Colors.green : Colors.orange,
                ),
              ),
              child: Text(
                _currentDette.estPayee ? '✅ Dette payée intégralement' : '⏳ Dette en cours de paiement',
                style: TextStyle(
                  color: _currentDette.estPayee ? Colors.green : Colors.orange,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: TextStyle(color: Colors.grey[600])),
          Text(value, style: TextStyle(fontWeight: FontWeight.w500)),
        ],
      ),
    );
  }

  // ← SECTION PRINCIPALE : LISTE DES PAIEMENTS
  Widget _buildPaiementsSection() {
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
                  'Historique des paiements (${_currentDette.paiements.length})',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                if (_currentDette.montantRestant > 0)
                  ElevatedButton.icon(
                    onPressed: () => _ajouterPaiement(),
                    icon: Icon(Icons.add, size: 16),
                    label: Text('Paiement'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      foregroundColor: Colors.white,
                    ),
                  ),
              ],
            ),
            SizedBox(height: 16),
            if (_currentDette.paiements.isEmpty)
              _buildEmptyPaiements()
            else
              ..._currentDette.paiements.map((paiement) => _buildPaiementCard(paiement)).toList(),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyPaiements() {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(32),
      child: Column(
        children: [
          Icon(Icons.payment_outlined, size: 48, color: Colors.grey),
          SizedBox(height: 16),
          Text(
            'Aucun paiement effectué',
            style: TextStyle(fontSize: 16, color: Colors.grey),
          ),
          SizedBox(height: 8),
          Text(
            'Ajoutez le premier paiement pour cette dette',
            style: TextStyle(color: Colors.grey),
          ),
        ],
      ),
    );
  }

  // ← CARD POUR CHAQUE PAIEMENT
  Widget _buildPaiementCard(PaiementModel paiement) {
    return Container(
      margin: EdgeInsets.only(bottom: 8),
      padding: EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.green.shade50,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.green.shade200),
      ),
      child: Row(
        children: [
          Icon(Icons.payment, color: Colors.green, size: 24),
          SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Paiement du ${paiement.date}',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
                SizedBox(height: 4),
                Text(
                  '${paiement.montant.toStringAsFixed(0)} FCFA',
                  style: TextStyle(
                    color: Colors.green,
                    fontWeight: FontWeight.w600,
                    fontSize: 16,
                  ),
                ),
                if (paiement.commentaire != null && paiement.commentaire!.isNotEmpty)
                  Padding(
                    padding: EdgeInsets.only(top: 4),
                    child: Text(
                      paiement.commentaire!,
                      style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                    ),
                  ),
              ],
            ),
          ),
          Container(
            padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: Colors.green,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              'Payé',
              style: TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }

  void _ajouterPaiement() {
    showDialog(
      context: context,
      builder: (context) => _PaiementDialog(
        dette: _currentDette,
        onPaiementAjoute: (montant, commentaire) async {
          final date = '${DateTime.now().day}/${DateTime.now().month}/${DateTime.now().year}';
          await widget.controller.ajouterPaiementADette(
            widget.client.id!,
            _currentDette.id!,
            date,
            montant,
            commentaire: commentaire,
          );
        },
      ),
    );
  }
}

// ← DIALOG POUR AJOUTER UN PAIEMENT
class _PaiementDialog extends StatefulWidget {
  final DetteModel dette;
  final Function(double, String?) onPaiementAjoute;

  const _PaiementDialog({
    required this.dette,
    required this.onPaiementAjoute,
  });

  @override
  _PaiementDialogState createState() => _PaiementDialogState();
}

class _PaiementDialogState extends State<_PaiementDialog> {
  final _formKey = GlobalKey<FormState>();
  final _montantController = TextEditingController();
  final _commentaireController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text('Ajouter un paiement'),
      content: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.blue.shade50,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  Icon(Icons.info, color: Colors.blue),
                  SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Montant restant: ${widget.dette.montantRestant.toStringAsFixed(0)} FCFA',
                      style: TextStyle(fontWeight: FontWeight.w500),
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: 16),
            TextFormField(
              controller: _montantController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                labelText: 'Montant du paiement (FCFA)',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.attach_money),
              ),
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Le montant est obligatoire';
                }
                final montant = double.tryParse(value);
                if (montant == null || montant <= 0) {
                  return 'Montant invalide';
                }
                if (montant > widget.dette.montantRestant) {
                  return 'Montant supérieur au restant';
                }
                return null;
              },
            ),
            SizedBox(height: 16),
            TextFormField(
              controller: _commentaireController,
              decoration: InputDecoration(
                labelText: 'Commentaire (optionnel)',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.comment),
              ),
              maxLines: 2,
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text('Annuler'),
        ),
        ElevatedButton(
          onPressed: () {
            if (_formKey.currentState!.validate()) {
              final montant = double.parse(_montantController.text);
              final commentaire = _commentaireController.text.trim();
              
              widget.onPaiementAjoute(
                montant,
                commentaire.isEmpty ? null : commentaire,
              );
              Navigator.pop(context);
            }
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.green,
            foregroundColor: Colors.white,
          ),
          child: Text('Ajouter'),
        ),
      ],
    );
  }

  @override
  void dispose() {
    _montantController.dispose();
    _commentaireController.dispose();
    super.dispose();
  }
}