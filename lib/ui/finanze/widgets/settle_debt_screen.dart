import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../../core/themes/app_colors.dart';
import '../view_model/finanze_view_model.dart';

class SettleDebtScreen extends StatefulWidget {
  final String? roommateUid;
  final String? roommateName;

  const SettleDebtScreen({
    super.key,
    this.roommateUid,
    this.roommateName,
  });

  @override
  State<SettleDebtScreen> createState() => _SettleDebtScreenState();
}

class _SettleDebtScreenState extends State<SettleDebtScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _amountController = TextEditingController();
  String? _selectedRoommate;

  @override
  void initState() {
    super.initState();
    if (widget.roommateUid != null) {
      _selectedRoommate = widget.roommateUid;
    }
  }

  @override
  void dispose() {
    _amountController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final viewModel = context.watch<FinanzeViewModel>();
    final roommates = viewModel.roommates;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: AppColors.primaryDark),
        title: const Text(
          'Salda Debito',
          style: TextStyle(
            color: AppColors.primaryDark,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // -- Destinatario --
                const Text(
                  'A chi stai inviando i soldi?',
                  style: TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                if (widget.roommateUid != null && widget.roommateName != null)
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: Colors.grey[300]!),
                    ),
                    child: Text(
                      widget.roommateName!,
                      style: const TextStyle(
                        color: AppColors.textPrimary,
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  )
                else
                  DropdownButtonFormField<String>(
                    initialValue: _selectedRoommate,
                    decoration: InputDecoration(
                      filled: true,
                      fillColor: Colors.white,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                        borderSide: BorderSide.none,
                      ),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                    ),
                    hint: const Text('Seleziona coinquilino'),
                    items: roommates.map((user) {
                      return DropdownMenuItem<String>(
                        value: user.uid,
                        child: Text(user.name.isNotEmpty ? user.name : user.email),
                      );
                    }).toList(),
                    onChanged: (newValue) {
                      setState(() {
                        _selectedRoommate = newValue;
                      });
                    },
                    validator: (value) => value == null ? 'Seleziona un destinatario' : null,
                  ),
                const SizedBox(height: 24),

                // -- Importo --
                const Text(
                  'Quanto stai pagando?',
                  style: TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                TextFormField(
                  controller: _amountController,
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  inputFormatters: [
                    FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d{0,2}')),
                  ],
                  decoration: InputDecoration(
                    hintText: '0.00',
                    prefixText: '€ ',
                    prefixStyle: const TextStyle(
                      color: AppColors.primaryDark,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                    filled: true,
                    fillColor: Colors.white,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16),
                      borderSide: BorderSide.none,
                    ),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Inserisci un importo';
                    }
                    final amount = double.tryParse(value.replaceAll(',', '.'));
                    if (amount == null || amount <= 0) {
                      return 'Inserisci un importo valido';
                    }

                    if (_selectedRoommate != null) {
                      try {
                        final rb = viewModel.roommateBalances.firstWhere(
                          (element) => element.user.uid == _selectedRoommate,
                        );
                        
                        if (rb.balance >= 0) {
                          return 'Non hai debiti verso questa persona';
                        }
                        
                        // Arrotondiamo per evitare problemi millesimali con i double
                        final maxAmount = double.parse(rb.balance.abs().toStringAsFixed(2));
                        if (amount > maxAmount) {
                          return 'Massimo rimborsabile: €$maxAmount';
                        }
                      } catch (e) {
                        // Se non trova il coinquilino nei saldi, ignora (non dovrebbe succedere)
                      }
                    }

                    return null;
                  },
                ),
                const SizedBox(height: 48),

                // -- Pulsante Conferma --
                SizedBox(
                  width: double.infinity,
                  height: 56,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primaryGreen,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                    onPressed: () async {
                      if (_formKey.currentState!.validate()) {
                        final amount = double.parse(_amountController.text.replaceAll(',', '.'));
                        
                        try {
                          // 1. Salviamo il risultato del ViewModel in una variabile
                          Map<String, dynamic>? newBadge = await context.read<FinanzeViewModel>().addReimbursement(_selectedRoommate!, amount);
                          
                          if (context.mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text('Hai saldato ${_amountController.text}€!'),
                                backgroundColor: AppColors.primaryGreen,
                              ),
                            );
                            // 2. Torniamo indietro e portiamo il badge in regalo!
                            Navigator.pop(context, newBadge);
                          }
                        } catch (e) {
                          if (context.mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text('Errore: ${e.toString()}'),
                                backgroundColor: Colors.red,
                                duration: const Duration(seconds: 4),
                              ),
                            );
                          }
                        }
                      }
                    },
                    child: const Text(
                      'Conferma Pagamento',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
