import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/themes/app_colors.dart';
import '../../core/ui/custom_user_header.dart';
import '../view_model/organizza_view_model.dart';
import '../../../data/repositories/user_repository.dart';
import '../../../domain/models/shopping_item.dart';

class OrganizzaScreen extends StatefulWidget {
  const OrganizzaScreen({super.key});

  @override
  State<OrganizzaScreen> createState() => _OrganizzaScreenState();
}

class _OrganizzaScreenState extends State<OrganizzaScreen> {
  final Set<String> _movingItems = {};

  Future<void> _toggleBought(OrganizzaViewModel vm, String itemId, bool bought) async {
    final current = vm.shopping.where((item) => item.id == itemId).toList();
    if (current.isNotEmpty && current.first.bought == bought) return;

    setState(() {
      _movingItems.add(itemId);
    });

    await vm.markItemBought(itemId, bought);

    await Future.delayed(const Duration(milliseconds: 240));
    if (!mounted) return;

    setState(() {
      _movingItems.remove(itemId);
    });
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
                            vm.shopping.where((item) => !item.bought || _movingItems.contains(item.id)).toList(),
                            bought: false,
                          ),
                          if (vm.shopping.any((item) => item.bought && !_movingItems.contains(item.id))) ...[
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
                              vm.shopping.where((item) => item.bought && !_movingItems.contains(item.id)).toList(),
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
          FutureBuilder(
            future: context.read<UserRepository>().getUserProfile(task.assigneeUid),
            builder: (context, snapshot) {
              final name = snapshot.hasData && snapshot.data != null && snapshot.data!.name.isNotEmpty
                  ? snapshot.data!.name
                  : 'Coinquilino';
              return Row(
                children: [
                  const Icon(Icons.person, size: 14, color: Colors.grey),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      'Assegnato a $name',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(color: Colors.grey),
                    ),
                  ),
                ],
              );
            },
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
      final moving = _movingItems.contains(item.id);
      final offsetTween = bought
          ? Tween<Offset>(
              begin: moving ? const Offset(0, 0.16) : Offset.zero,
              end: Offset.zero,
            )
          : Tween<Offset>(
              begin: Offset.zero,
              end: moving ? const Offset(0, -0.16) : Offset.zero,
            );

      final opacityTween = bought
          ? Tween<double>(
              begin: moving ? 0.0 : 1.0,
              end: 1.0,
            )
          : Tween<double>(
              begin: 1.0,
              end: moving ? 0.0 : 1.0,
            );

      widgets.add(
        TweenAnimationBuilder<Offset>(
          tween: offsetTween,
          duration: const Duration(milliseconds: 280),
          curve: Curves.easeInOut,
          builder: (context, offset, child) {
            return Transform.translate(offset: Offset(offset.dx * 24, offset.dy * 24), child: child);
          },
          child: TweenAnimationBuilder<double>(
            tween: opacityTween,
            duration: const Duration(milliseconds: 240),
            curve: Curves.easeInOut,
            builder: (context, opacity, child) {
              return Opacity(
                opacity: opacity,
                child: CheckboxListTile(
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
                  subtitle: FutureBuilder(
                    future: context.read<UserRepository>().getUserProfile(item.addedByUid),
                    builder: (context, snap) {
                      final addedBy = snap.hasData && snap.data != null && snap.data!.name.isNotEmpty
                          ? snap.data!.name
                          : 'Te';
                      final prefix = bought ? 'Comprato da ' : 'Aggiunto da ';
                      return Text(
                        '$prefix$addedBy',
                        style: TextStyle(
                          color: bought ? AppColors.primaryGreen.withValues(alpha: 0.85) : Colors.black54,
                        ),
                      );
                    },
                  ),
                  controlAffinity: ListTileControlAffinity.leading,
                ),
              );
            },
          ),
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
    final controller = TextEditingController();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (sheetContext) {
        return Padding(
          padding: EdgeInsets.only(bottom: MediaQuery.of(sheetContext).viewInsets.bottom),
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
                  controller: controller,
                  decoration: const InputDecoration(
                    labelText: 'Nome alimento / oggetto',
                    border: OutlineInputBorder(),
                  ),
                  textInputAction: TextInputAction.done,
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
                    onPressed: () async {
                      final name = controller.text.trim();
                      if (name.isEmpty) {
                        ScaffoldMessenger.of(sheetContext).showSnackBar(
                          const SnackBar(
                            content: Text('Campo vuoto: inserisci un alimento o un oggetto.'),
                            backgroundColor: Colors.red,
                          ),
                        );
                        return;
                      }

                      // Chiudiamo prima il foglio, poi salviamo: evita conflitti di rebuild durante la chiusura.
                      Navigator.pop(sheetContext);

                      final success = await vm.addShoppingItemByName(name);
                      if (!mounted) return;

                      if (!success) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Non riesco a salvare l\'elemento su Firestore.'),
                            backgroundColor: Colors.red,
                          ),
                        );
                      }
                    },
                    child: const Text('Aggiungi al carrello'),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    ).whenComplete(controller.dispose);
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
                                subtitle: FutureBuilder(
                                  future: context.read<UserRepository>().getUserProfile(task.assigneeUid),
                                  builder: (context, snapshot) {
                                    final name = snapshot.hasData && snapshot.data != null && snapshot.data!.name.isNotEmpty
                                        ? snapshot.data!.name
                                        : 'Utente';
                                    return Text('Assegnato a $name');
                                  },
                                ),
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
