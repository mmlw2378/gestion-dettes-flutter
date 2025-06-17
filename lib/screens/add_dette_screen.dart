import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/client.dart';
import '../providers/client_provider.dart';

class AddDetteScreen extends StatefulWidget {
  final Client client;

  const AddDetteScreen({Key? key, required this.client}) : super(key: key);

  @override
  _AddDetteScreenState createState() => _AddDetteScreenState();
}

class _AddDetteScreenState extends State<AddDetteScreen> {
  final _formKey = GlobalKey<FormState>();
  final _montantController = TextEditingController();
  DateTime _selectedDate = DateTime.now();
  bool _isLoading = false;

  @override
  void dispose() {
    _montantController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Ajouter une Dette'),
        backgroundColor: Colors.green,
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Informations du client
              Container(
                padding: EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.blue.shade50,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.blue.shade200),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Client: ${widget.client.nom}',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.blue.shade800,
                      ),
                    ),
                    SizedBox(height: 4),
                    Text('Téléphone: ${widget.client.telephone}'),
                    if (widget.client.id != null)
                      Text(
                        'ID: ${widget.client.id}',
                        style: TextStyle(fontSize: 12, color: Colors.grey),
                      ),
                  ],
                ),
              ),

              SizedBox(height: 24),

              // Date de la dette
              InkWell(
                onTap: _selectDate,
                child: Container(
                  padding: EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.calendar_today, color: Colors.grey[600]),
                      SizedBox(width: 12),
                      Text(
                        'Date: ${_selectedDate.day}/${_selectedDate.month}/${_selectedDate.year}',
                        style: TextStyle(fontSize: 16),
                      ),
                    ],
                  ),
                ),
              ),

              SizedBox(height: 16),

              // Montant de la dette
              TextFormField(
                controller: _montantController,
                decoration: InputDecoration(
                  labelText: 'Montant de la dette (FCFA)',
                  prefixIcon: Icon(Icons.attach_money),
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Le montant est obligatoire';
                  }
                  final montant = double.tryParse(value);
                  if (montant == null || montant <= 0) {
                    return 'Veuillez entrer un montant valide';
                  }
                  return null;
                },
              ),

              SizedBox(height: 24),

              ElevatedButton(
                onPressed: _isLoading ? null : _addDette,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  foregroundColor: Colors.white,
                  padding: EdgeInsets.symmetric(vertical: 16),
                ),
                child: _isLoading
                    ? CircularProgressIndicator(color: Colors.white)
                    : Text('Ajouter la Dette', style: TextStyle(fontSize: 16)),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _selectDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
    );
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  Future<void> _addDette() async {
    if (!_formKey.currentState!.validate()) return;

    // Vérifier que le client a un ID
    if (widget.client.id == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Erreur: Client sans ID valide'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final dette = Dette(
        date:
            '${_selectedDate.day}/${_selectedDate.month}/${_selectedDate.year}',
        montantDette: double.parse(_montantController.text),
      );

      print('🔄 Ajout dette pour client ID: ${widget.client.id}');

      final success = await Provider.of<ClientProvider>(
        context,
        listen: false,
      ).addDetteToClient(widget.client.id!, dette);

      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Dette ajoutée avec succès'),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.pop(context);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erreur lors de l\'ajout de la dette'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      print('❌ Erreur dans _addDette: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erreur: $e'), backgroundColor: Colors.red),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }
}
