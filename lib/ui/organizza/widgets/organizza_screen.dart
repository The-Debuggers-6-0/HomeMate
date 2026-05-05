import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/themes/app_colors.dart';
import '../../core/ui/custom_user_header.dart';
import '../view_model/organizza_view_model.dart';
import '../../../domain/models/shopping_item.dart';

class OrganizzaScreen extends StatefulWidget {
  const OrganizzaScreen({super.key});

  @override
  State<OrganizzaScreen> createState() => _OrganizzaScreenState();
}

class _ShoppingManagerSheet extends StatefulWidget {
  final OrganizzaViewModel vm;
  const _ShoppingManagerSheet({required this.vm});

  @override
  State<_ShoppingManagerSheet> createState() => _ShoppingManagerSheetState();
}

class _ShoppingManagerSheetState extends State<_ShoppingManagerSheet> {
  final _controller = TextEditingController();
  bool _isSaving = false;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _saveItem() async {
    final name = _controller.text.trim();
    if (name.isEmpty) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Campo vuoto: inserisci un alimento o un oggetto.'),
            backgroundColor: Colors.red,
          ),
        );
      }
      return;
    }

    setState(() => _isSaving = true);
    // Prima nascondiamo la tastiera per evitare sbalzi strani
    FocusScope.of(context).unfocus();

    final success = await widget.vm.addShoppingItemByName(name);
    
    if (!mounted) return;

    if (success) {
      // Chiudiamo il bottom sheet!
      Navigator.pop(context);
    } else {
      setState(() => _isSaving = false);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Non riesco a salvare l'elemento su Firestore."),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    // Usiamo il Padding che reagisce a viewInsets
    return Padding(
      padding: EdgeInsets.only(bottom: MediaQuery.viewInsetsOf(context).bottom),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Gestisci carrello',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _controller,
              decoration: const InputDecoration(
                labelText: 'Nome alimento / oggetto',
                border: OutlineInputBorder(),
              ),
              textInputAction: TextInputAction.done,
              onSubmitted: (_) => _saveItem(),
            ),
            const SizedBox(height: 8),
            const Text(
              'Se il campo è vuoto, non puoi aggiungere nulla.',
              style: TextStyle(
                color: Colors.black54,
                fontSize: 12,
              ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _isSaving ? null : _saveItem,
                child: _isSaving
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(strokeWidth: 2))
                    : const Text('Aggiungi al carrello'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _OrganizzaScreenState extends State<OrganizzaScreen> {
  Future<void> _toggleBought(OrganizzaViewModel vm, String itemId, bool bought) async {
    final current = vm.shopping.where((item) => item.id == itemId).toList();
    if (current.isNotEmpty && current.first.bought == bought) return;
    await vm.markItemBought(itemId, bought);
  }

  String _weekdayLabel(DateTime d) {
    const names = ['LUNEDÌ', 'MARTEDÌ', 'MERCOLEDÌ', 'GIOVEDÌ', 'VENERDÌ', 'SABATO', 'DOMENICA'];
    return names[d.weekday - 1];
  }

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<OrganizzaViewModel>();

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: vm.isLoading
            ? const Center(child: CircularProgressIndicator())
            : SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const CustomUserHeader(greetingText: 'Ciao, Nome'),
                    const SizedBox(height: 16),

                    // Calendario placeholder
                    Card(
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                const Text(
                                  'Calendario',
                                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                                ),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                                  decoration: BoxDecoration(
                                    color: AppColors.primaryGreen.withValues(alpha: 0.12),
                                    borderRadius: BorderRadius.circular(999),
                                  ),
                                  child: const Text(
                                    'In arrivo',
                                    style: TextStyle(
                                      color: AppColors.primaryGreen,
                                      fontSize: 12,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 12),
                            Container(
                              width: double.infinity,
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                color: AppColors.finanzeBackground,
                                borderRadius: BorderRadius.circular(14),
                              ),
                              child: const Row(
                                children: [
                                  Icon(Icons.calendar_month, color: AppColors.primaryGreen),
                                  SizedBox(width: 12),
                                  Expanded(
                                    child: Text(
                                      'Qui vedrai eventi, ospiti, assenze e impegni della casa.',
                                      style: TextStyle(fontSize: 14),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

                    const SizedBox(height: 20),

                    // Turni di pulizia
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('Turni di pulizia', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                        Row(
                          children: [
                            TextButton(
                              onPressed: () => _showCompletedTasks(context, vm),
                              child: Text(
                                'Completati (${vm.cleaning.where((task) => task.completed).length})',
                                style: const TextStyle(color: AppColors.primaryGreen),
                              ),
                            ),
                          ],
                        )
                      ],
                    ),

                    const SizedBox(height: 8),
                    if (vm.currentWeekCleaningTasks.isEmpty)
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: const Text(
                          'Turni della settimana in preparazione...',
                          style: TextStyle(color: Colors.black54),
                        ),
                      )
                    else
                      Column(
                        children: vm.currentWeekCleaningTasks.where((task) => !task.completed).take(3).map((t) {
                          return _buildCleaningTaskCard(context, vm, t);
                        }).toList(),
                      ),

                    const SizedBox(height: 16),

                    // Gestione spazzatura
                    Card(
                      color: AppColors.primaryDark,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Row(
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: const [
                                  Text('DOMANI', style: TextStyle(color: Colors.white70, fontSize: 12)),
                                  SizedBox(height: 6),
                                  Text('Umido e Plastica', style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
                                  SizedBox(height: 6),
                                  Text('Tocca a Giulia', style: TextStyle(color: Colors.white70)),
                                ],
                              ),
                            ),
                            ElevatedButton(
                              style: ElevatedButton.styleFrom(backgroundColor: Colors.white, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16))),
                              onPressed: () {},
                              child: const Text('Ricordami', style: TextStyle(color: AppColors.primaryDark)),
                            ),
                          ],
                        ),
                      ),
                    ),

                    const SizedBox(height: 20),

                    // Lista della spesa
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('Lista della spesa', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                        TextButton(
                          onPressed: () => _showShoppingManager(context),
                          child: const Text('Gestisci carrello'),
                        )
                      ],
                    ),
                    const SizedBox(height: 8),

                    Container(
                      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16)),
                      child: Column(
                        children: [
                          ..._buildShoppingSection(
                            context,
                            vm,
                            vm.shopping.where((item) => !item.bought).toList(),
                            bought: false,
                          ),
                          if (vm.shopping.any((item) => item.bought)) ...[
                            Container(
                              width: double.infinity,
                              padding: const EdgeInsets.fromLTRB(16, 14, 16, 8),
                              color: Colors.grey[50],
                              child: const Text(
                                'Acquistato',
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                  letterSpacing: 1.1,
                                  color: AppColors.primaryGreen,
                                ),
                              ),
                            ),
                            ..._buildShoppingSection(
                              context,
                              vm,
                              vm.shopping.where((item) => item.bought).toList(),
                              bought: true,
                            ),
                          ],
                        ],
                      ),
                    ),

                    const SizedBox(height: 80),
                  ],
                ),
              ),
      ),
    );
  }

  double _computeHarmony(OrganizzaViewModel vm) {
    if (vm.cleaning.isEmpty) return 0.85;
    final total = vm.cleaning.length;
    final done = vm.cleaning.where((c) => c.completed).length;
    return done / total;
  }

  Widget _buildCleaningTaskCard(BuildContext context, OrganizzaViewModel vm, dynamic task) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  color: AppColors.primaryGreen.withValues(alpha: 0.10),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Text(
                  'SETTIMANA',
                  style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppColors.primaryGreen),
                ),
              ),
              ElevatedButton(
                onPressed: () => vm.toggleTaskCompleted(task.id, true),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primaryGreen,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                ),
                child: const Text(
                  'Fatto',
                  style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            task.title,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
          ),
          const SizedBox(height: 6),
          Row(
            children: [
              const Icon(Icons.person, size: 14, color: Colors.grey),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  'Assegnato a ${vm.displayNameFor(task.assigneeUid)}',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(color: Colors.grey),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  List<Widget> _buildShoppingSection(
    BuildContext context,
    OrganizzaViewModel vm,
    List<ShoppingItem> items, {
    required bool bought,
  }) {
    if (items.isEmpty) return const [];

    final widgets = <Widget>[];
    for (final item in items) {
      widgets.add(
        CheckboxListTile(
          value: bought,
          onChanged: (v) => _toggleBought(vm, item.id, v ?? false),
          title: Text(
            item.name,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              decoration: bought ? TextDecoration.lineThrough : TextDecoration.none,
              color: bought ? AppColors.primaryGreen : Colors.black,
            ),
          ),
          subtitle: Text(
            '${bought ? 'Comprato da ' : 'Aggiunto da '}${vm.displayNameFor(item.addedByUid)}',
            style: TextStyle(
              color: bought ? AppColors.primaryGreen.withValues(alpha: 0.85) : Colors.black54,
            ),
          ),
          controlAffinity: ListTileControlAffinity.leading,
        ),
      );

      if (item != items.last) {
        widgets.add(const Divider(height: 1));
      }
    }

    return widgets;
  }

  void _showShoppingManager(BuildContext context) {
    final vm = context.read<OrganizzaViewModel>();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (sheetContext) {
        return _ShoppingManagerSheet(vm: vm);
      },
    );
  }

  void _showCompletedTasks(BuildContext context, OrganizzaViewModel vm) {
    final completedTasks = vm.cleaning.where((task) => task.completed).toList();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (sheetContext) {
        return Container(
          constraints: BoxConstraints(maxHeight: MediaQuery.of(sheetContext).size.height * 0.75),
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          ),
          child: SafeArea(
            top: false,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Turni completati',
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      IconButton(
                        onPressed: () => Navigator.pop(sheetContext),
                        icon: const Icon(Icons.close),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Expanded(
                    child: completedTasks.isEmpty
                        ? const Center(
                            child: Text(
                              'Nessun turno completato al momento.',
                              style: TextStyle(color: Colors.black54),
                            ),
                          )
                        : ListView.separated(
                            itemCount: completedTasks.length,
                            separatorBuilder: (_, __) => const Divider(height: 20),
                            itemBuilder: (context, index) {
                              final task = completedTasks[index];
                              final assigneeName = vm.displayNameFor(task.assigneeUid);
                              return ListTile(
                                contentPadding: EdgeInsets.zero,
                                leading: CircleAvatar(
                                  backgroundColor: AppColors.primaryGreen.withValues(alpha: 0.15),
                                  child: const Icon(Icons.check, color: AppColors.primaryGreen),
                                ),
                                title: Text(
                                  task.title,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: AppColors.primaryGreen,
                                  ),
                                ),
                                subtitle: Text('Assegnato a $assigneeName'),
                              );
                            },
                          ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
