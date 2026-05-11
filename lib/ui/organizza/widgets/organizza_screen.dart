import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../core/themes/app_colors.dart';
import '../../core/ui/custom_user_header.dart';
import '../view_model/organizza_view_model.dart';
import '../../../domain/models/shopping_item.dart';
import '../../core/ui/badge_popup.dart';

class _EventManagerSheet extends StatefulWidget {
  final OrganizzaViewModel vm;
  const _EventManagerSheet({required this.vm});

  @override
  State<_EventManagerSheet> createState() => _EventManagerSheetState();
}

class _EventManagerSheetState extends State<_EventManagerSheet> {
  final _titleController = TextEditingController();
  final _notesController = TextEditingController();
  DateTime _selectedDate = DateTime.now();

  @override
  void dispose() {
    _titleController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  // Funzione per aggiungere un evento e gestire il possibile sblocco del badge "Party Planner"
  void _addEvent() async {
    final title = _titleController.text.trim();
    if (title.isEmpty) return;

    // 1. Il ViewModel calcola se c'è un badge da sbloccare
    final newBadge = await widget.vm.addEvent(
      title,
      _selectedDate,
      notes: _notesController.text.trim(),
    );
    
    if (!mounted) return;
    
    // 2. CHIUDIAMO LA TENDINA E CONSEGNIAMO IL BADGE ALLO SCHERMO!
    Navigator.pop(context, newBadge); 
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(
        left: 20,
        right: 20,
        top: 20,
        bottom: MediaQuery.of(context).viewInsets.bottom + 20,
      ),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Nuovo Evento',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _titleController,
            decoration: const InputDecoration(
              hintText: 'Titolo (es. Cena con amici, Idraulico)',
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _notesController,
            decoration: const InputDecoration(
              hintText: 'Note (opzionale)',
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 12),
          ListTile(
            title: const Text('Data'),
            subtitle: Text(
              DateFormat('dd/MM/yyyy HH:mm').format(_selectedDate),
            ),
            trailing: const Icon(Icons.calendar_today),
            onTap: () async {
              final date = await showDatePicker(
                context: context,
                initialDate: _selectedDate,
                firstDate: DateTime.now(),
                lastDate: DateTime.now().add(const Duration(days: 365)),
              );
              if (date != null && mounted) {
                final time = await showTimePicker(
                  context: context,
                  initialTime: TimeOfDay.fromDateTime(_selectedDate),
                );
                if (time != null) {
                  setState(() {
                    _selectedDate = DateTime(
                      date.year,
                      date.month,
                      date.day,
                      time.hour,
                      time.minute,
                    );
                  });
                }
              }
            },
          ),
          const SizedBox(height: 20),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _addEvent,
              child: const Text('Salva Evento'),
            ),
          ),
        ],
      ),
    );
  }
}

class _CleaningManagerSheet extends StatefulWidget {
  final OrganizzaViewModel vm;
  const _CleaningManagerSheet({required this.vm});

  @override
  State<_CleaningManagerSheet> createState() => _CleaningManagerSheetState();
}

class _CleaningManagerSheetState extends State<_CleaningManagerSheet> {
  final _titleController = TextEditingController();
  String? _selectedUserUid;

  @override
  void initState() {
    super.initState();
    // Pre-seleziona l'utente corrente o il primo disponibile
    _selectedUserUid = widget.vm.authRepository.currentFirebaseUser?.uid;
  }

  @override
  void dispose() {
    _titleController.dispose();
    super.dispose();
  }

  void _addTask() async {
    final title = _titleController.text.trim();
    if (title.isEmpty || _selectedUserUid == null) return;

    await widget.vm.addCleaningTask(title, _selectedUserUid!);
    _titleController.clear();
    setState(() {}); // Refresh list
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(
        left: 20,
        right: 20,
        top: 20,
        bottom: MediaQuery.of(context).viewInsets.bottom + 20,
      ),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Gestione Turni Settimanali',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),

          // Form aggiunta
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _titleController,
                  decoration: const InputDecoration(
                    hintText: 'Cosa pulire? (es. Vetri)',
                    border: OutlineInputBorder(),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              DropdownButton<String>(
                value: _selectedUserUid,
                items: widget.vm.houseMembers.map((uid) {
                  return DropdownMenuItem(
                    value: uid,
                    child: Text(widget.vm.displayNameFor(uid)),
                  );
                }).toList(),
                onChanged: (val) => setState(() => _selectedUserUid = val),
              ),
              IconButton(
                onPressed: _addTask,
                icon: const Icon(
                  Icons.add_circle,
                  color: AppColors.primaryGreen,
                  size: 32,
                ),
              ),
            ],
          ),

          const SizedBox(height: 20),
          const Text(
            'Compiti di questa settimana:',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),

          Flexible(
            child: ListView.builder(
              shrinkWrap: true,
              itemCount: widget.vm.currentWeekCleaningTasks.length,
              itemBuilder: (context, index) {
                final task = widget.vm.currentWeekCleaningTasks[index];
                return ListTile(
                  contentPadding: EdgeInsets.zero,
                  title: Text(task.title),
                  subtitle: Text(
                    'Assegnato a ${widget.vm.displayNameFor(task.assigneeUid)}',
                  ),
                  trailing: IconButton(
                    icon: const Icon(Icons.delete_outline, color: Colors.red),
                    onPressed: () => widget.vm.removeCleaningTask(task.id),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

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
  final _nameController = TextEditingController();
  final _quantityController = TextEditingController();
  bool _isSaving = false;

  @override
  void dispose() {
    _nameController.dispose();
    _quantityController.dispose();
    super.dispose();
  }

  void _saveItem() async {
    final name = _nameController.text.trim();
    final quantity = _quantityController.text.trim();
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
    FocusScope.of(context).unfocus();

    final success = await widget.vm.addShoppingItemByName(
      name,
      quantity: quantity,
    );

    if (!mounted) return;

    if (success) {
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
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  flex: 3,
                  child: TextField(
                    controller: _nameController,
                    decoration: const InputDecoration(
                      labelText: 'Nome alimento / oggetto',
                      border: OutlineInputBorder(),
                    ),
                    textInputAction: TextInputAction.next,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  flex: 1,
                  child: TextField(
                    controller: _quantityController,
                    decoration: const InputDecoration(
                      labelText: 'Qtà',
                      border: OutlineInputBorder(),
                    ),
                    textInputAction: TextInputAction.done,
                    onSubmitted: (_) => _saveItem(),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            const Text(
              'Es: Latte (2L), Mele (5), Carta igienica (8 rotoli)',
              style: TextStyle(color: Colors.black54, fontSize: 12),
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
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Text('Aggiungi al carrello'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _RecyclingScheduleSheet extends StatefulWidget {
  final OrganizzaViewModel vm;
  const _RecyclingScheduleSheet({required this.vm});

  @override
  State<_RecyclingScheduleSheet> createState() =>
      _RecyclingScheduleSheetState();
}

class _RecyclingScheduleSheetState extends State<_RecyclingScheduleSheet> {
  late Map<String, String> _tempSchedule;

  @override
  void initState() {
    super.initState();
    _tempSchedule = Map<String, String>.from(widget.vm.recyclingSchedule);
    // Inizializza i giorni mancanti
    for (var day in OrganizzaViewModel.weekDays) {
      _tempSchedule.putIfAbsent(day, () => 'Nulla');
    }
  }

  void _save() async {
    await widget.vm.updateRecyclingSchedule(_tempSchedule);
    if (mounted) Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Calendario Raccolta',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              IconButton(
                icon: const Icon(Icons.close),
                onPressed: () => Navigator.pop(context),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Flexible(
            child: ListView.builder(
              shrinkWrap: true,
              itemCount: OrganizzaViewModel.weekDays.length,
              itemBuilder: (context, index) {
                final day = OrganizzaViewModel.weekDays[index];
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 4),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        day,
                        style: const TextStyle(fontWeight: FontWeight.w500),
                      ),
                      DropdownButton<String>(
                        value: _tempSchedule[day],
                        underline: const SizedBox(),
                        onChanged: (String? newValue) {
                          if (newValue != null) {
                            setState(() {
                              _tempSchedule[day] = newValue;
                            });
                          }
                        },
                        items: OrganizzaViewModel.wasteTypes
                            .map<DropdownMenuItem<String>>((String value) {
                              return DropdownMenuItem<String>(
                                value: value,
                                child: Text(value),
                              );
                            })
                            .toList(),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: 20),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _save,
              child: const Text('Salva Calendario'),
            ),
          ),
          const SizedBox(height: 10),
        ],
      ),
    );
  }
}

class _OrganizzaScreenState extends State<OrganizzaScreen> {
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
                    CustomUserHeader(
                      greetingText:
                          'GESTISCI LA CASA',
                    ),
                    const SizedBox(height: 16),

                    // Calendario reale
                    Card(
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                        side: BorderSide(
                          color: AppColors.primaryGreen.withValues(alpha: 0.1),
                        ),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                const Text(
                                  'Prossimi Eventi',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                IconButton(
                                  icon: const Icon(
                                    Icons.add,
                                    color: AppColors.primaryGreen,
                                  ),
                                  onPressed: () => _showEventManager(context),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            if (vm.events.isEmpty)
                              Container(
                                width: double.infinity,
                                padding: const EdgeInsets.all(16),
                                decoration: BoxDecoration(
                                  color: AppColors.finanzeBackground,
                                  borderRadius: BorderRadius.circular(14),
                                ),
                                child: const Row(
                                  children: [
                                    Icon(
                                      Icons.calendar_month,
                                      color: AppColors.primaryGreen,
                                    ),
                                    SizedBox(width: 12),
                                    Expanded(
                                      child: Text(
                                        'Nessun evento in programma.',
                                        style: TextStyle(fontSize: 14),
                                      ),
                                    ),
                                  ],
                                ),
                              )
                            else
                              ListView.separated(
                                shrinkWrap: true,
                                physics: const NeverScrollableScrollPhysics(),
                                itemCount: vm.events.length > 3
                                    ? 3
                                    : vm.events.length,
                                separatorBuilder: (context, index) =>
                                    const SizedBox(height: 8),
                                itemBuilder: (context, index) {
                                  final event = vm.events[index];
                                  final isToday = DateUtils.isSameDay(
                                    event.start,
                                    DateTime.now(),
                                  );
                                  return Container(
                                    padding: const EdgeInsets.all(12),
                                    decoration: BoxDecoration(
                                      color: isToday
                                          ? AppColors.primaryGreen.withValues(
                                              alpha: 0.05,
                                            )
                                          : Colors.grey.shade50,
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: Row(
                                      children: [
                                        Container(
                                          width: 4,
                                          height: 30,
                                          decoration: BoxDecoration(
                                            color: isToday
                                                ? AppColors.primaryGreen
                                                : Colors.grey.shade300,
                                            borderRadius: BorderRadius.circular(
                                              2,
                                            ),
                                          ),
                                        ),
                                        const SizedBox(width: 12),
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                event.title,
                                                style: const TextStyle(
                                                  fontWeight: FontWeight.bold,
                                                ),
                                              ),
                                              Text(
                                                '${DateFormat('dd MMM, HH:mm').format(event.start)}${event.notes != null && event.notes!.isNotEmpty ? " • ${event.notes}" : ""}',
                                                style: TextStyle(
                                                  fontSize: 12,
                                                  color: Colors.grey.shade600,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                        IconButton(
                                          icon: const Icon(
                                            Icons.delete_outline,
                                            size: 20,
                                            color: Colors.grey,
                                          ),
                                          onPressed: () =>
                                              vm.removeEvent(event.id),
                                        ),
                                      ],
                                    ),
                                  );
                                },
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
                        const Text(
                          'Turni di pulizia',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Row(
                          children: [
                            TextButton(
                              onPressed: () => _showCleaningManager(context),
                              child: const Text(
                                'Gestisci',
                                style: TextStyle(color: AppColors.primaryGreen),
                              ),
                            ),
                            TextButton(
                              onPressed: () => _showCompletedTasks(context, vm),
                              child: Text(
                                'Fatto (${vm.completedCleaningTasksCount})',
                                style: const TextStyle(
                                  color: AppColors.primaryGreen,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),

                    const SizedBox(height: 8),
                    _buildCleaningCard(context, vm),

                    const SizedBox(height: 16),

                    // Gestione spazzatura (Raccolta Differenziata)
                    const Text(
                      'Raccolta differenziata',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 12),
                    // Card DOMANI
                    _buildRecyclingCard(
                      context,
                      'DOMANI',
                      vm.tomorrowWaste,
                      isToday: false,
                    ),
                    const SizedBox(height: 8),
                    // Bottone Imposta Calendario
                    SizedBox(
                      width: double.infinity,
                      child: OutlinedButton.icon(
                        onPressed: () => _showRecyclingManager(context),
                        icon: const Icon(
                          Icons.calendar_month_outlined,
                          size: 20,
                        ),
                        label: const Text('Gestisci calendario raccolta'),
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                          side: BorderSide(
                            color: AppColors.primaryGreen.withValues(
                              alpha: 0.3,
                            ),
                          ),
                          foregroundColor: AppColors.primaryGreen,
                        ),
                      ),
                    ),

                    const SizedBox(height: 20),

                    // Lista della spesa
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Lista della spesa',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        TextButton(
                          onPressed: () => _showShoppingManager(context),
                          child: const Text('Gestisci carrello'),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),

                    Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Column(
                        children: [
                          ..._buildShoppingSection(
                            context,
                            vm,
                            vm.pendingShoppingItems,
                            bought: false,
                          ),
                          if (vm.boughtShoppingItems.isNotEmpty) ...[
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
                              vm.boughtShoppingItems,
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

  Widget _buildCleaningCard(BuildContext context, OrganizzaViewModel vm) {
    final currentUser = vm.authRepository.currentFirebaseUser;
    if (currentUser == null) return const SizedBox.shrink();

    // Task dell'utente per questa settimana
    final myTasks = vm.currentWeekCleaningTasks.where(
      (t) => t.assigneeUid == currentUser.uid,
    );
    final myTask = myTasks.isNotEmpty ? myTasks.first : null;

    // Se l'utente non ha task, mostriamo il primo task pendente della settimana
    final pendingTasks = vm.pendingCleaningTasks;
    final displayTask =
        myTask ?? (pendingTasks.isNotEmpty ? pendingTasks.first : null);

    if (displayTask == null) {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: AppColors.primaryGreen.withValues(alpha: 0.1),
          ),
        ),
        child: const Row(
          children: [
            Icon(Icons.check_circle_outline, color: AppColors.primaryGreen),
            SizedBox(width: 12),
            Text(
              'Tutto pulito per questa settimana!',
              style: TextStyle(
                fontWeight: FontWeight.w600,
                color: Colors.black87,
              ),
            ),
          ],
        ),
      );
    }

    final bool isMine = displayTask.assigneeUid == currentUser.uid;
    final bool isCompleted = displayTask.completed;

    return Card(
      elevation: 0,
      color: isMine ? AppColors.primaryDark : Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: isMine
            ? BorderSide.none
            : BorderSide(color: AppColors.primaryGreen.withValues(alpha: 0.1)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: isMine
                    ? Colors.white.withValues(alpha: 0.1)
                    : AppColors.primaryGreen.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.cleaning_services_outlined,
                color: isMine ? Colors.white : AppColors.primaryGreen,
                size: 20,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    isMine ? 'IL TUO TURNO' : 'QUESTA SETTIMANA',
                    style: TextStyle(
                      color: isMine ? Colors.white70 : Colors.grey.shade500,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    displayTask.title,
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: isMine ? Colors.white : Colors.black,
                    ),
                  ),
                  if (!isMine)
                    Text(
                      'Assegnato a ${vm.displayNameFor(displayTask.assigneeUid)}',
                      style: TextStyle(
                        color: Colors.grey.shade500,
                        fontSize: 13,
                      ),
                    ),
                ],
              ),
            ),
            if (isCompleted)
              Row(
                children: [
                  const Icon(
                    Icons.check_circle,
                    color: AppColors.primaryGreen,
                    size: 20,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    isMine ? 'Pulito!' : 'Fatto!',
                    style: const TextStyle(
                      color: AppColors.primaryGreen,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              )
            else
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: isMine
                      ? Colors.white
                      : AppColors.primaryGreen,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  elevation: 0,
                ),
                onPressed: () async {
                  // 1. Aspettiamo che il ViewModel completi la task e ci dica se c'è un badge
                  Map<String, dynamic>? newBadge = await vm.toggleTaskCompleted(
                    displayTask.id,
                    true,
                  );

                  // 2. Se ci ha restituito i dati del badge, mostriamo il popup!
                  if (newBadge != null && context.mounted) {
                    showGenericBadgePopup(context, newBadge);
                  }
                },
                // ---> FINE MODIFICA GRILLETTO <---
                child: Text(
                  'Fatto',
                  style: TextStyle(
                    color: isMine ? AppColors.primaryDark : Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
          ],
        ),
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

    return items.map((item) {
      return Dismissible(
        key: Key(item.id),
        direction: DismissDirection.endToStart,
        background: Container(
          alignment: Alignment.centerRight,
          padding: const EdgeInsets.symmetric(horizontal: 20),
          margin: const EdgeInsets.symmetric(vertical: 4),
          decoration: BoxDecoration(
            color: Colors.red.shade400,
            borderRadius: BorderRadius.circular(16),
          ),
          child: const Icon(Icons.delete_outline, color: Colors.white),
        ),
        onDismissed: (direction) => vm.removeShoppingItem(item.id),
        child: AnimatedOpacity(
          duration: const Duration(milliseconds: 300),
          opacity: bought ? 0.6 : 1.0,
          child: Container(
            margin: const EdgeInsets.symmetric(vertical: 4),
            decoration: BoxDecoration(
              color: bought ? Colors.grey.shade50 : Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: bought
                    ? Colors.transparent
                    : AppColors.primaryGreen.withValues(alpha: 0.1),
              ),
              boxShadow: bought
                  ? []
                  : [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.02),
                        blurRadius: 4,
                        offset: const Offset(0, 2),
                      ),
                    ],
            ),
            child: ListTile(
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 4,
              ),
              leading: GestureDetector(
                onTap: () => vm.markItemBought(item.id, !bought),
                child: Container(
                  width: 24,
                  height: 24,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: bought ? AppColors.primaryGreen : Colors.transparent,
                    border: Border.all(
                      color: bought
                          ? AppColors.primaryGreen
                          : Colors.grey.shade400,
                      width: 2,
                    ),
                  ),
                  child: bought
                      ? const Icon(Icons.check, size: 16, color: Colors.white)
                      : null,
                ),
              ),
              title: RichText(
                text: TextSpan(
                  children: [
                    TextSpan(
                      text: item.name,
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 16,
                        decoration: bought ? TextDecoration.lineThrough : null,
                        color: bought ? Colors.grey : AppColors.textPrimary,
                        fontFamily:
                            'Inter', // Assicurati di usare il font del tema
                      ),
                    ),
                    if (item.quantity.isNotEmpty)
                      TextSpan(
                        text: ' (${item.quantity})',
                        style: TextStyle(
                          fontWeight: FontWeight.w400,
                          fontSize: 14,
                          decoration: bought
                              ? TextDecoration.lineThrough
                              : null,
                          color: bought ? Colors.grey : Colors.black54,
                          fontFamily: 'Inter',
                        ),
                      ),
                  ],
                ),
              ),
              subtitle: Text(
                bought
                    ? 'Preso da ${vm.displayNameFor(item.boughtByUid ?? "")} (Aggiunto da ${vm.displayNameFor(item.addedByUid)})'
                    : 'Aggiunto da ${vm.displayNameFor(item.addedByUid)}',
                style: TextStyle(fontSize: 12, color: Colors.grey.shade500),
              ),
              trailing: bought
                  ? null
                  : IconButton(
                      icon: const Icon(Icons.delete_outline, size: 22),
                      color: Colors.red.shade300,
                      onPressed: () => vm.removeShoppingItem(item.id),
                    ),
            ),
          ),
        ),
      );
    }).toList();
  }

  Widget _buildRecyclingCard(
    BuildContext context,
    String label,
    String wasteType, {
    required bool isToday,
  }) {
    final vm = context.watch<OrganizzaViewModel>();
    final bool isNone = wasteType == 'Nulla';
    final String title = vm.getWasteTitle(wasteType);
    final String subtitle = vm.getWasteSubtitle(wasteType, isToday);

    // Per "DOMANI", usiamo lo stato del ViewModel
    final bool isTakenOut = !isToday && vm.tomorrowWasteTakenOut;

    return Card(
      elevation: 0,
      color: isToday ? Colors.white : AppColors.primaryDark,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: isToday
            ? BorderSide(color: AppColors.primaryGreen.withValues(alpha: 0.1))
            : BorderSide.none,
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            if (isToday)
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: AppColors.primaryGreen.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.delete_outline,
                  color: AppColors.primaryGreen,
                ),
              )
            else
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.auto_delete_outlined,
                  color: Colors.white,
                ),
              ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: TextStyle(
                      color: isToday ? Colors.grey.shade500 : Colors.white70,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: isToday ? Colors.black : Colors.white,
                    ),
                  ),
                  if (subtitle.isNotEmpty && !isTakenOut)
                    Text(
                      subtitle,
                      style: TextStyle(
                        color: isToday ? Colors.grey.shade500 : Colors.white70,
                        fontSize: 13,
                      ),
                    ),
                ],
              ),
            ),
            if (!isNone)
              isTakenOut
                  ? const Row(
                      children: [
                        Icon(
                          Icons.check_circle,
                          color: AppColors.primaryGreen,
                          size: 20,
                        ),
                        SizedBox(width: 4),
                        Text(
                          'Portata fuori!',
                          style: TextStyle(
                            color: AppColors.primaryGreen,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    )
                  : ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: isToday
                            ? AppColors.primaryGreen
                            : Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        elevation: 0,
                      ),
                      onPressed: () async {
                        // 1. Se è la spazzatura di domani, la segniamo graficamente come portata fuori
                        if (!isToday) {
                          vm.setTomorrowWasteTakenOut(true);
                        } 
                        
                        // 2. FUORI DALL'ELSE: Controlliamo SEMPRE se sblocca il badge!
                        Map<String, dynamic>? newBadge = await vm.confirmWasteTakenOut(wasteType);

                        // 3. Se sblocca il badge, mostriamo il popup celebrativo!
                        if (newBadge != null && context.mounted) {
                          showGenericBadgePopup(context, newBadge);
                        }
                      },
                      child: Text(
                        'Fatto',
                        style: TextStyle(
                          color: isToday ? Colors.white : AppColors.primaryDark,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
          ],
        ),
      ),
    );
  }

  void _showRecyclingManager(BuildContext context) {
    final vm = context.read<OrganizzaViewModel>();
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (sheetContext) {
        return _RecyclingScheduleSheet(vm: vm);
      },
    );
  }

  // Funzione per mostrare la tendina di gestione eventi e, se sblocca un badge, mostrare il popup celebrativo
  void _showEventManager(BuildContext context) async {
    final vm = context.read<OrganizzaViewModel>();
    
    // Apriamo la tendina e ASPETTIAMO che ci restituisca qualcosa
    final newBadge = await showModalBottomSheet<Map<String, dynamic>?>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (sheetContext) {
        return _EventManagerSheet(vm: vm);
      },
    );

    // Se la tendina si è chiusa restituendoci un badge sbloccato...
    if (newBadge != null && context.mounted) {
      // Aspettiamo mezzo secondo per far finire l'animazione di chiusura
      Future.delayed(const Duration(milliseconds: 500), () {
        if (context.mounted) {
          // Mosrtiamo il popup celebrativo per il nuovo badge sbloccato!
          showGenericBadgePopup(context, newBadge);
        }
      });
    }
  }

  void _showCleaningManager(BuildContext context) {
    final vm = context.read<OrganizzaViewModel>();
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (sheetContext) {
        return _CleaningManagerSheet(vm: vm);
      },
    );
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
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (sheetContext) {
        return Container(
          constraints: BoxConstraints(
            maxHeight: MediaQuery.of(sheetContext).size.height * 0.75,
          ),
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
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      IconButton(
                        onPressed: () => Navigator.pop(sheetContext),
                        icon: const Icon(Icons.close),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Expanded(
                    child: vm.completedCleaningTasks.isEmpty
                        ? const Center(
                            child: Text(
                              'Nessun turno completato al momento.',
                              style: TextStyle(color: Colors.black54),
                            ),
                          )
                        : ListView.separated(
                            itemCount: vm.completedCleaningTasks.length,
                            separatorBuilder: (_, _) =>
                                const Divider(height: 20),
                            itemBuilder: (context, index) {
                              final task = vm.completedCleaningTasks[index];
                              final assigneeName = vm.displayNameFor(
                                task.assigneeUid,
                              );
                              return ListTile(
                                contentPadding: EdgeInsets.zero,
                                leading: CircleAvatar(
                                  backgroundColor: AppColors.primaryGreen
                                      .withValues(alpha: 0.15),
                                  child: const Icon(
                                    Icons.check,
                                    color: AppColors.primaryGreen,
                                  ),
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
