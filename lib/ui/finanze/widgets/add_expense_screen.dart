import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/themes/app_colors.dart';
import '../view_model/finanze_view_model.dart';

enum SplitMode { equalAll, equalSelected, custom }

class AddExpenseScreen extends StatefulWidget {
  const AddExpenseScreen({super.key});

  @override
  State<AddExpenseScreen> createState() => _AddExpenseScreenState();
}

class _AddExpenseScreenState extends State<AddExpenseScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _amountController = TextEditingController();
  late ScrollController _scrollController;
  String _selectedCategory = 'Spesa';
  
  final List<String> _categories = ['Spesa', 'Bolletta', 'Abbonamento', 'Altro'];

  SplitMode _splitMode = SplitMode.equalAll;
  
  bool _initialized = false;
  Set<String> _selectedUids = {};
  final Map<String, TextEditingController> _customControllers = {};

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_initialized) {
      final viewModel = context.read<FinanzeViewModel>();
      final allRoommates = viewModel.allRoommates;
      
      _selectedUids = allRoommates.map((r) => r.uid).toSet();
      for (var r in allRoommates) {
        _customControllers[r.uid] = TextEditingController();
      }
      _initialized = true;
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _amountController.dispose();
    _scrollController.dispose();
    for (var c in _customControllers.values) {
      c.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final viewModel = context.watch<FinanzeViewModel>();
    final allRoommates = viewModel.allRoommates;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: AppColors.primaryDark),
        title: const Text(
          'Nuova Spesa',
          style: TextStyle(
            color: AppColors.primaryDark,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          controller: _scrollController,
          padding: const EdgeInsets.all(24.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // -- Titolo Spesa --
                const Text(
                  'Cosa hai pagato?',
                  style: TextStyle(color: AppColors.textPrimary, fontSize: 16, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                TextFormField(
                  controller: _titleController,
                  decoration: InputDecoration(
                    hintText: 'Es. Spesa Carrefour',
                    filled: true,
                    fillColor: Colors.white,
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                  ),
                  validator: (value) => (value == null || value.isEmpty) ? 'Inserisci un titolo per la spesa' : null,
                ),
                const SizedBox(height: 24),

                // -- Importo --
                const Text(
                  'Quanto hai speso?',
                  style: TextStyle(color: AppColors.textPrimary, fontSize: 16, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                TextFormField(
                  controller: _amountController,
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  decoration: InputDecoration(
                    hintText: '0.00',
                    prefixText: '€ ',
                    prefixStyle: const TextStyle(color: AppColors.primaryDark, fontSize: 18, fontWeight: FontWeight.bold),
                    filled: true,
                    fillColor: Colors.white,
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) return 'Inserisci un importo';
                    if (double.tryParse(value.replaceAll(',', '.')) == null) return 'Inserisci un importo valido';
                    return null;
                  },
                ),
                const SizedBox(height: 24),

                // -- Categoria --
                const Text(
                  'Categoria',
                  style: TextStyle(color: AppColors.textPrimary, fontSize: 16, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 12),
                Wrap(
                  spacing: 12,
                  runSpacing: 12,
                  children: _categories.map((category) {
                    final isSelected = _selectedCategory == category;
                    return ChoiceChip(
                      label: Text(category),
                      selected: isSelected,
                      onSelected: (selected) {
                        if (selected) setState(() => _selectedCategory = category);
                      },
                      selectedColor: AppColors.primaryGreen.withValues(alpha: 0.2),
                      backgroundColor: Colors.white,
                      labelStyle: TextStyle(
                        color: isSelected ? AppColors.primaryDark : AppColors.textSecondary,
                        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                        side: BorderSide(color: isSelected ? AppColors.primaryGreen : Colors.grey.shade300),
                      ),
                    );
                  }).toList(),
                ),
                const SizedBox(height: 32),

                // -- Divisione Spesa --
                const Text(
                  'Come vuoi dividere la spesa?',
                  style: TextStyle(color: AppColors.textPrimary, fontSize: 16, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 12),
                Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Column(
                    children: [
                      RadioListTile<SplitMode>(
                        title: const Text('Tutti in parti uguali'),
                        value: SplitMode.equalAll,
                        groupValue: _splitMode,
                        activeColor: AppColors.primaryGreen,
                        onChanged: (val) => setState(() => _splitMode = val!),
                      ),
                      RadioListTile<SplitMode>(
                        title: const Text('Seleziona persone (parti uguali)'),
                        value: SplitMode.equalSelected,
                        groupValue: _splitMode,
                        activeColor: AppColors.primaryGreen,
                        onChanged: (val) {
                          setState(() {
                            _splitMode = val!;
                            // Se viene selezionato "equalSelected" e _selectedUids è vuoto, viene inizializzato con tutti i roommates
                            if (_splitMode == SplitMode.equalSelected && _selectedUids.isEmpty) {
                              final vm = context.read<FinanzeViewModel>();
                              _selectedUids = vm.allRoommates.map((r) => r.uid).toSet();
                            }
                          });
                        },
                      ),
                      RadioListTile<SplitMode>(
                        title: const Text('Importi personalizzati'),
                        value: SplitMode.custom,
                        groupValue: _splitMode,
                        activeColor: AppColors.primaryGreen,
                        onChanged: (val) => setState(() => _splitMode = val!),
                      ),
                    ],
                  ),
                ),

                // -- Dettaglio Divisione (Selezionati / Personalizzati) --
                if (_splitMode != SplitMode.equalAll) ...[
                  const SizedBox(height: 16),
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Column(
                      children: allRoommates.map((user) {
                        final isMe = user.uid == viewModel.authRepository.currentFirebaseUser?.uid;
                        final name = isMe ? 'Tu' : (user.name.isNotEmpty ? user.name : user.email);

                        if (_splitMode == SplitMode.equalSelected) {
                          return CheckboxListTile(
                            title: Text(name),
                            value: _selectedUids.contains(user.uid),
                            activeColor: AppColors.primaryGreen,
                            onChanged: (checked) {
                              setState(() {
                                if (checked == true) {
                                  _selectedUids.add(user.uid);
                                } else {
                                  _selectedUids.remove(user.uid);
                                }
                              });
                            },
                          );
                        } else {
                          return Padding(
                            padding: const EdgeInsets.only(bottom: 12.0),
                            child: Row(
                              children: [
                                Expanded(child: Text(name, style: const TextStyle(fontWeight: FontWeight.bold))),
                                SizedBox(
                                  width: 100,
                                  child: TextFormField(
                                    controller: _customControllers[user.uid],
                                    keyboardType: const TextInputType.numberWithOptions(decimal: true),
                                    decoration: const InputDecoration(
                                      prefixText: '€ ',
                                      border: OutlineInputBorder(),
                                      contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          );
                        }
                      }).toList(),
                    ),
                  ),
                ],

                const SizedBox(height: 48),

                // -- Pulsante Salva --
                SizedBox(
                  width: double.infinity,
                  height: 56,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primaryDark,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    ),
                    onPressed: () async {
                      if (!_formKey.currentState!.validate()) {
                        // Scroll in cima per mostrare i campi obbligatori
                        _scrollController.animateTo(
                          0.0,
                          duration: const Duration(milliseconds: 300),
                          curve: Curves.easeInOut,
                        );
                        return;
                      }

                      final title = _titleController.text;
                      final amount = double.parse(_amountController.text.replaceAll(',', '.'));

                      List<String>? involvedUsers;
                      Map<String, double>? customShares;

                      if (_splitMode == SplitMode.equalSelected) {
                        if (_selectedUids.isEmpty) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Seleziona almeno una persona!'), backgroundColor: Colors.red),
                          );
                          return;
                        }
                        involvedUsers = _selectedUids.toList();
                      } else if (_splitMode == SplitMode.custom) {
                        customShares = {};
                        double sum = 0;
                        for (var entry in _customControllers.entries) {
                          final textVal = entry.value.text.replaceAll(',', '.');
                          if (textVal.isNotEmpty) {
                            final val = double.tryParse(textVal) ?? 0.0;
                            if (val > 0) {
                              customShares[entry.key] = val;
                              sum += val;
                            }
                          }
                        }

                        if ((sum - amount).abs() > 0.01) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('La somma delle quote (€${sum.toStringAsFixed(2)}) non coincide col totale (€${amount.toStringAsFixed(2)})!'),
                              backgroundColor: Colors.red,
                            ),
                          );
                          return;
                        }
                      }

                      try {
                        await context.read<FinanzeViewModel>().addExpense(
                          title, 
                          amount, 
                          _selectedCategory,
                          involvedUsers: involvedUsers,
                          customShares: customShares,
                        );
                        if (context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Spesa salvata!'), backgroundColor: AppColors.primaryGreen),
                          );
                          Navigator.pop(context);
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
                    },
                    child: const Text('Aggiungi Spesa', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white)),
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
