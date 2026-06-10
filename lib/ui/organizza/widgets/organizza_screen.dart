import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../core/themes/app_colors.dart';
import '../../core/ui/custom_user_header.dart';
import '../../core/ui/user_avatar.dart';
import '../view_model/organizza_view_model.dart';
import '../../../domain/models/shopping_item.dart';
import '../../core/ui/badge_popup.dart';
import '../../main_layout/widgets/main_layout.dart';

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
    
    // 2. CHIUDIAMO LA TENDINA E CONSEGNIAMO IL BADGE ALLO SCHERMO
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

class _MemberDropdownItem extends StatelessWidget {
  final OrganizzaViewModel vm;
  final String uid;
  final bool isAway;

  const _MemberDropdownItem({
    required this.vm,
    required this.uid,
    required this.isAway,
  });

  @override
  Widget build(BuildContext context) {
    final name = vm.displayNameFor(uid);
    final endDate = isAway ? vm.absenceEndDateFor(uid) : null;
    final tooltip = isAway && endDate != null
        ? '$name è assente fino al ${endDate.day}/${endDate.month}/${endDate.year}'
        : '';

    return Tooltip(
      message: tooltip,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          UserAvatar(
            user: vm.appUserFor(uid),
            radius: 12,
            backgroundColor: isAway
                ? Colors.grey.shade300
                : AppColors.primaryGreen.withValues(alpha: 0.15),
          ),
          const SizedBox(width: 8),
          Text(
            name,
            style: TextStyle(
              fontSize: 13,
              color: isAway ? Colors.grey.shade400 : Colors.black87,
              fontStyle: isAway ? FontStyle.italic : FontStyle.normal,
            ),
          ),
          if (isAway) ...[
            const SizedBox(width: 4),
            Icon(Icons.flight_takeoff, size: 12, color: Colors.orange.shade300),
          ],
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
    _selectedUserUid = widget.vm.authRepository.currentFirebaseUser?.uid;
    widget.vm.addListener(_onVmChanged);
  }

  void _onVmChanged() {
    if (mounted) setState(() {});
  }

  @override
  void dispose() {
    widget.vm.removeListener(_onVmChanged);
    _titleController.dispose();
    super.dispose();
  }

  void _showAbsentSnackBar(BuildContext context, String uid) {
    final name = widget.vm.displayNameFor(uid);
    final endDate = widget.vm.absenceEndDateFor(uid);
    final dateStr = endDate != null
        ? ' fino al ${endDate.day}/${endDate.month}/${endDate.year}'
        : '';
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('$name è assente$dateStr'),
        backgroundColor: Colors.orange,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  void _addTask() async {
    final title = _titleController.text.trim();
    if (title.isEmpty || _selectedUserUid == null) return;

    await widget.vm.addCleaningTask(title, _selectedUserUid!);
    _titleController.clear();
    setState(() {});
  }

  String _formatWeekLabel(DateTime weekStart) {
    final end = weekStart.add(const Duration(days: 6));
    return '${weekStart.day}/${weekStart.month} - ${end.day}/${end.month}';
  }

  @override
  Widget build(BuildContext context) {
    final currentTasks = widget.vm.currentWeekCleaningTasks;
    final futureTasks = widget.vm.futureCleaningTasks;

    return Container(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.80,
      ),
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
          // Header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Gestione Turni',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              IconButton(
                icon: const Icon(Icons.close),
                onPressed: () => Navigator.pop(context),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // Form aggiunta task
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _titleController,
                  decoration: InputDecoration(
                    hintText: 'Nuovo compito (es. Vetri)',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                  ),
                  onSubmitted: (_) => _addTask(),
                ),
              ),
              const SizedBox(width: 8),
              DropdownButton<String>(
                value: _selectedUserUid,
                items: widget.vm.houseMembers.map((uid) {
                  final isAway = widget.vm.isUserAway(uid);
                  return DropdownMenuItem(
                    value: uid,
                    child: _MemberDropdownItem(
                      vm: widget.vm,
                      uid: uid,
                      isAway: isAway,
                    ),
                  );
                }).toList(),
                onChanged: (val) {
                  if (val != null && !widget.vm.isUserAway(val)) {
                    setState(() => _selectedUserUid = val);
                  } else if (val != null) {
                    _showAbsentSnackBar(context, val);
                  }
                },
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

          // SEZIONE: Questa settimana
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              color: AppColors.primaryGreen.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Text(
              'QUESTA SETTIMANA',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 12,
                color: AppColors.primaryGreen,
                letterSpacing: 0.5,
              ),
            ),
          ),
          const SizedBox(height: 8),

          Flexible(
            child: ListView(
              shrinkWrap: true,
              children: [
                // Task della settimana corrente con possibilità  di riassegnare
                if (currentTasks.isEmpty)
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 12),
                    child: Text(
                      'Nessun compito per questa settimana.',
                      style: TextStyle(color: Colors.black54, fontSize: 13),
                    ),
                  )
                else
                  ...currentTasks.map((task) {
                    return ListTile(
                      contentPadding: EdgeInsets.zero,
                      leading: Icon(
                        task.completed ? Icons.check_circle : Icons.circle_outlined,
                        color: task.completed ? AppColors.primaryGreen : Colors.grey.shade400,
                        size: 22,
                      ),
                      title: Text(
                        task.title,
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          decoration: task.completed ? TextDecoration.lineThrough : null,
                        ),
                      ),
                      subtitle: DropdownButton<String>(
                        value: widget.vm.houseMembers.contains(task.assigneeUid) ? task.assigneeUid : null,
                        isExpanded: true,
                        underline: const SizedBox(),
                        items: widget.vm.houseMembers.map((uid) {
                          final isAway = widget.vm.isUserAway(uid);
                          return DropdownMenuItem(
                            value: uid,
                            child: _MemberDropdownItem(
                              vm: widget.vm,
                              uid: uid,
                              isAway: isAway,
                            ),
                          );
                        }).toList(),
                        onChanged: task.completed ? null : (newUid) {
                          if (newUid == null) return;
                          if (widget.vm.isUserAway(newUid)) {
                            _showAbsentSnackBar(context, newUid);
                          } else {
                            widget.vm.reassignCleaningTask(task.id, newUid);
                          }
                        },
                      ),
                      trailing: IconButton(
                        icon: const Icon(Icons.delete_outline, color: Colors.red, size: 20),
                        onPressed: () => widget.vm.removeCleaningTask(task.id),
                      ),
                    );
                  }),

                // SEZIONE: Prossime settimane
                if (futureTasks.isNotEmpty) ...[
                  const SizedBox(height: 16),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                    decoration: BoxDecoration(
                      color: Colors.orange.shade50,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      'PROSSIME SETTIMANE',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                        color: Colors.orange.shade800,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  ...futureTasks.map((task) {
                    return ListTile(
                      contentPadding: EdgeInsets.zero,
                      leading: Icon(
                        Icons.schedule,
                        color: Colors.orange.shade300,
                        size: 20,
                      ),
                      title: Text(task.title, style: const TextStyle(fontWeight: FontWeight.w600)),
                      subtitle: Text(
                        '${widget.vm.displayNameFor(task.assigneeUid)} â€¢ ${_formatWeekLabel(task.weekStart)}',
                        style: TextStyle(fontSize: 12, color: Colors.grey.shade500),
                      ),
                      trailing: IconButton(
                        icon: const Icon(Icons.delete_outline, color: Colors.red, size: 20),
                        onPressed: () => widget.vm.removeCleaningTask(task.id),
                      ),
                    );
                  }),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _RoomManagerSheet extends StatefulWidget {
  final OrganizzaViewModel vm;
  const _RoomManagerSheet({required this.vm});

  @override
  State<_RoomManagerSheet> createState() => _RoomManagerSheetState();
}

class _RoomManagerSheetState extends State<_RoomManagerSheet> {
  final _roomController = TextEditingController();

  @override
  void dispose() {
    _roomController.dispose();
    super.dispose();
  }

  void _addRoom() async {
    final name = _roomController.text.trim();
    if (name.isEmpty) return;
    await widget.vm.addChoreRoom(name);
    _roomController.clear();
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.70,
      ),
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
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Gestisci Stanze',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              IconButton(
                icon: const Icon(Icons.close),
                onPressed: () => Navigator.pop(context),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            'Aggiungi o rimuovi le stanze/compiti da assegnare settimanalmente.',
            style: TextStyle(color: Colors.grey.shade600, fontSize: 13),
          ),
          const SizedBox(height: 16),

          // Form aggiunta
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _roomController,
                  decoration: InputDecoration(
                    hintText: 'Nuova stanza (es. Camera, Corridoio)',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                  ),
                  onSubmitted: (_) => _addRoom(),
                ),
              ),
              const SizedBox(width: 8),
              IconButton(
                onPressed: _addRoom,
                icon: const Icon(
                  Icons.add_circle,
                  color: AppColors.primaryGreen,
                  size: 36,
                ),
              ),
            ],
          ),

          const SizedBox(height: 20),
          const Text(
            'Stanze attuali:',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
          ),
          const SizedBox(height: 8),

          Flexible(
            child: widget.vm.choreRooms.isEmpty
                ? const Center(
                    child: Text(
                      'Nessuna stanza configurata.',
                      style: TextStyle(color: Colors.black54),
                    ),
                  )
                : ListView.separated(
                    shrinkWrap: true,
                    itemCount: widget.vm.choreRooms.length,
                    separatorBuilder: (_, __) => const Divider(height: 1),
                    itemBuilder: (context, index) {
                      final room = widget.vm.choreRooms[index];
                      return Dismissible(
                        key: Key(room),
                        direction: widget.vm.choreRooms.length > 1
                            ? DismissDirection.endToStart
                            : DismissDirection.none,
                        background: Container(
                          alignment: Alignment.centerRight,
                          padding: const EdgeInsets.symmetric(horizontal: 20),
                          decoration: BoxDecoration(
                            color: Colors.red.shade400,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Icon(Icons.delete_outline, color: Colors.white),
                        ),
                        onDismissed: (_) => widget.vm.removeChoreRoom(room),
                        child: ListTile(
                          contentPadding: const EdgeInsets.symmetric(horizontal: 4),
                          leading: Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: AppColors.primaryGreen.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: const Icon(
                              Icons.meeting_room_outlined,
                              color: AppColors.primaryGreen,
                              size: 22,
                            ),
                          ),
                          title: Text(
                            room,
                            style: const TextStyle(fontWeight: FontWeight.w600),
                          ),
                          trailing: widget.vm.choreRooms.length > 1
                              ? Icon(Icons.swipe_left_outlined, size: 18, color: Colors.grey.shade400)
                              : null,
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

class _AbsenceManagerSheet extends StatefulWidget {
  final OrganizzaViewModel vm;
  const _AbsenceManagerSheet({required this.vm});

  @override
  State<_AbsenceManagerSheet> createState() => _AbsenceManagerSheetState();
}

class _AbsenceManagerSheetState extends State<_AbsenceManagerSheet> {
  String? _absenceUserUid;
  DateTime? _absenceDate;

  @override
  void initState() {
    super.initState();
    _absenceUserUid = widget.vm.authRepository.currentFirebaseUser?.uid;
    widget.vm.addListener(_onVmChanged);
  }

  void _onVmChanged() {
    if (mounted) setState(() {});
  }

  @override
  void dispose() {
    widget.vm.removeListener(_onVmChanged);
    super.dispose();
  }

  void _setAbsence() async {
    if (_absenceUserUid == null || _absenceDate == null) return;
    final userName = widget.vm.displayNameFor(_absenceUserUid!);

    await widget.vm.addAbsenceEvent(_absenceUserUid!, _absenceDate!);

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('$userName segnato come assente fino al ${_absenceDate!.day}/${_absenceDate!.month}')),
      );
      setState(() => _absenceDate = null);
    }
  }

  @override
  Widget build(BuildContext context) {
    final absences = widget.vm.activeAbsences;

    return Container(
      constraints: BoxConstraints(maxHeight: MediaQuery.of(context).size.height * 0.75),
      padding: EdgeInsets.only(
        left: 20, right: 20, top: 20,
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
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Gestisci Assenze',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              IconButton(
                icon: const Icon(Icons.close),
                onPressed: () => Navigator.pop(context),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text('Segnala un coinquilino come assente fino a una data.',
              style: TextStyle(color: Colors.grey.shade600, fontSize: 13)),
          const SizedBox(height: 16),

          // Form segnalazione assenza
          Row(
            children: [
              Expanded(
                flex: 2,
                child: DropdownButton<String>(
                  isExpanded: true,
                  value: _absenceUserUid,
                  items: widget.vm.houseMembers.map((uid) {
                    return DropdownMenuItem(
                      value: uid,
                      child: Row(
                        children: [
                          UserAvatar(user: widget.vm.appUserFor(uid), radius: 14),
                          const SizedBox(width: 8),
                          Flexible(
                            child: Text(
                              widget.vm.displayNameFor(uid),
                              style: const TextStyle(fontSize: 13),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    );
                  }).toList(),
                  onChanged: (val) => setState(() => _absenceUserUid = val),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                flex: 3,
                child: OutlinedButton.icon(
                  onPressed: () async {
                    final date = await showDatePicker(
                      context: context,
                      initialDate: DateTime.now(),
                      firstDate: DateTime.now(),
                      lastDate: DateTime.now().add(const Duration(days: 365)),
                    );
                    if (date != null) setState(() => _absenceDate = date);
                  },
                  icon: const Icon(Icons.calendar_today, size: 16),
                  label: Text(
                    _absenceDate == null
                        ? 'Fino al...'
                        : '${_absenceDate!.day}/${_absenceDate!.month}/${_absenceDate!.year}',
                    style: const TextStyle(fontSize: 12),
                  ),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                  ),
                ),
              ),
              IconButton(
                onPressed: _setAbsence,
                icon: Icon(
                  Icons.flight_takeoff,
                  color: _absenceDate == null ? Colors.grey : Colors.orange,
                  size: 28,
                ),
              ),
            ],
          ),

          const SizedBox(height: 16),
          const Divider(),
          const SizedBox(height: 8),

          // Lista assenze attive
          if (absences.isEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 12),
              child: Text('Nessun coinquilino assente al momento.',
                  style: TextStyle(color: Colors.grey.shade500, fontSize: 13)),
            )
          else
            Flexible(
              child: ListView.builder(
                shrinkWrap: true,
                itemCount: absences.length,
                itemBuilder: (context, index) {
                  final event = absences[index];
                  final name = event.title.replaceFirst('Assente: ', '');
                  final user = widget.vm.appUserForAbsenceEvent(event);
                  return ListTile(
                    contentPadding: EdgeInsets.zero,
                    leading: UserAvatar(user: user, radius: 18),
                    title: Text(name,
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                    subtitle: event.end != null
                        ? Text('Fino al ${event.end!.day}/${event.end!.month}/${event.end!.year}',
                            style: const TextStyle(fontSize: 12))
                        : null,
                    trailing: IconButton(
                      icon: Icon(Icons.delete_outline, color: Colors.red.shade300, size: 20),
                      onPressed: () {
                        widget.vm.removeEvent(event.id);
                        setState(() {});
                      },
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

  final TabChangeNotifier tabNotifier;
  final int tabIndex;

  const OrganizzaScreen({
    super.key,
    required this.tabNotifier,
    required this.tabIndex,
  });

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
                      labelText: 'QtÃ ',
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
  late ScrollController _scrollController;

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
    widget.tabNotifier.addListener(_onTabChanged);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    widget.tabNotifier.removeListener(_onTabChanged);
    super.dispose();
  }

  void _onTabChanged() {
    if (widget.tabNotifier.currentTab == widget.tabIndex) {
      _scrollController.animateTo(
        0.0,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
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
                controller: _scrollController,
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
                                const Row(
                                  children: [
                                    Icon(Icons.event_outlined, color: AppColors.primaryGreen, size: 20),
                                    SizedBox(width: 8),
                                    Text(
                                      'Prossimi Eventi',
                                      style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ],
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
                            if (vm.events.where((e) => !e.title.startsWith('Assente:')).isEmpty)
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
                                      child: Text('Nessun evento in programma.', style: TextStyle(fontSize: 14)),
                                    ),
                                  ],
                                ),
                              )
                            else
                              ListView.separated(
                                shrinkWrap: true,
                                physics: const NeverScrollableScrollPhysics(),
                                itemCount: vm.events.where((e) => !e.title.startsWith('Assente:')).length > 3
                                    ? 3
                                    : vm.events.where((e) => !e.title.startsWith('Assente:')).length,
                                separatorBuilder: (context, index) => const SizedBox(height: 8),
                                itemBuilder: (context, index) {
                                  final event = vm.events
                                      .where((e) => !e.title.startsWith('Assente:'))
                                      .toList()[index];
                                  return Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                                    decoration: BoxDecoration(
                                      color: AppColors.finanzeBackground,
                                      borderRadius: BorderRadius.circular(14),
                                    ),
                                    child: Row(
                                      children: [
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                event.title,
                                                style: const TextStyle(
                                                  fontWeight: FontWeight.w600,
                                                  fontSize: 14,
                                                  color: Colors.black87,
                                                ),
                                              ),
                                              Text(
                                                DateFormat('dd/MM/yyyy - HH:mm').format(event.start),
                                                style: TextStyle(
                                                  fontSize: 12,
                                                  color: Colors.grey.shade500,
                                                ),
                                              ),
                                              if (event.notes != null && event.notes!.isNotEmpty)
                                                Text(
                                                  event.notes!,
                                                  style: TextStyle(
                                                    fontSize: 12,
                                                    color: Colors.grey.shade400,
                                                  ),
                                                  maxLines: 1,
                                                  overflow: TextOverflow.ellipsis,
                                                ),
                                            ],
                                          ),
                                        ),
                                        IconButton(
                                          icon: Icon(Icons.delete_outline,
                                              size: 20, color: Colors.red.shade300),
                                          onPressed: () => vm.removeEvent(event.id),
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
                            TextButton.icon(
                              onPressed: () => _showRoomManager(context),
                              icon: const Icon(Icons.meeting_room_outlined, size: 16, color: AppColors.primaryGreen),
                              label: const Text(
                                'Stanze',
                                style: TextStyle(color: AppColors.primaryGreen),
                              ),
                            ),
                            TextButton(
                              onPressed: () => _showCleaningManager(context),
                              child: const Text(
                                'Gestisci',
                                style: TextStyle(color: AppColors.primaryGreen),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),

                    const SizedBox(height: 8),

                    // Mostra TUTTI i task della settimana
                    _buildAllWeeklyTasks(context, vm),

                    const SizedBox(height: 20),

                    // Coinquilini assenti
                    _buildAbsentMembersSection(context, vm),

                    const SizedBox(height: 16),

                    // Gestione spazzatura (Raccolta Differenziata)
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text(
                              'Raccolta differenziata',
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            TextButton(
                              onPressed: () => _showRecyclingManager(context),
                              child: const Text(
                                'Gestisci',
                                style: TextStyle(color: AppColors.primaryGreen),
                              ),
                            ),
                          ],
                        ),
                        if (vm.currentWasteResponsibleUid != null)
                          Padding(
                            padding: const EdgeInsets.only(top: 2, bottom: 8),
                            child: Text(
                              'Questa settimana tocca a: ${vm.displayNameFor(vm.currentWasteResponsibleUid!)}',
                              style: TextStyle(
                                color: Colors.grey.shade600,
                                fontSize: 13,
                              ),
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    // Card DOMANI
                    _buildRecyclingCard(
                      context,
                      'DOMANI',
                      vm.tomorrowWaste,
                      isToday: false,
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

  Widget _buildAllWeeklyTasks(BuildContext context, OrganizzaViewModel vm) {
    final currentUser = vm.authRepository.currentFirebaseUser;
    if (currentUser == null) return const SizedBox.shrink();

    final weekTasks = vm.currentWeekCleaningTasks;

    if (weekTasks.isEmpty) {
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

    return Column(
      children: weekTasks.map((task) {
        final bool isMine = task.assigneeUid == currentUser.uid;
        final bool isCompleted = task.completed;

        return Padding(
          padding: const EdgeInsets.only(bottom: 8),
          child: Card(
            elevation: 0,
            color: isMine ? AppColors.primaryDark : Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
              side: isMine
                  ? BorderSide.none
                  : BorderSide(color: AppColors.primaryGreen.withValues(alpha: 0.1)),
            ),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
              child: Row(
                children: [
                  UserAvatar(
                    user: vm.appUserFor(task.assigneeUid),
                    radius: 22,
                    backgroundColor: isMine
                        ? Colors.white.withValues(alpha: 0.2)
                        : AppColors.primaryGreen.withValues(alpha: 0.15),
                    iconColor: isMine ? Colors.white : AppColors.primaryDark,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          task.title,
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                            color: isMine ? Colors.white : Colors.black,
                          ),
                        ),
                        Text(
                          isMine
                              ? 'Tocca a te'
                              : vm.displayNameFor(task.assigneeUid, showStatus: true),
                          style: TextStyle(
                            color: isMine ? Colors.white70 : Colors.grey.shade500,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                  if (isCompleted)
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(
                          Icons.check_circle,
                          color: AppColors.primaryGreen,
                          size: 18,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          'Fatto!',
                          style: TextStyle(
                            color: isMine ? AppColors.accentGreen : AppColors.primaryGreen,
                            fontWeight: FontWeight.bold,
                            fontSize: 13,
                          ),
                        ),
                      ],
                    )
                  else if (isMine)
                    Row(
                      mainAxisSize: MainAxisSize.min, // Aggiunto per evitare che la Row occupi tutto lo spazio
                      children: [
                        // --- BOTTONE JOLLY ---
                        if ((vm.appUserFor(currentUser.uid)?.jollies ?? 0) > 0)
                          IconButton(
                            tooltip: 'Usa Jolly per saltare',
                            icon: const Text('🃏', style: TextStyle(fontSize: 22)),
                            onPressed: () async {
                              final confirm = await showDialog<bool>(
                                context: context,
                                builder: (ctx) => AlertDialog(
                                  title: const Text('Usa un Jolly? 🃏'),
                                  content: const Text('Vuoi spendere 1 Jolly per saltare questo turno senza perdere la streak?'),
                                  actions: [
                                    TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Annulla')),
                                    ElevatedButton(onPressed: () => Navigator.pop(ctx, true), child: const Text('Usa Jolly')),
                                  ],
                                ),
                              );
                              if (confirm == true) {
                                await vm.useJollyForCleaningTask(task.id);
                                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Jolly usato! Turno saltato.')));
                              }
                            },
                          ),
                        
                        // --- BOTTONE FATTO ---
                        ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            elevation: 0,
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                          ),
                          onPressed: () async {
                            Map<String, dynamic>? newBadge = await vm.toggleTaskCompleted(
                              task.id,
                              true,
                            );
                            if (newBadge != null && context.mounted) {
                              showGenericBadgePopup(context, newBadge);
                            }
                          },
                          child: const Text(
                            'Fatto',
                            style: TextStyle(
                              color: AppColors.primaryDark,
                              fontWeight: FontWeight.bold,
                              fontSize: 13,
                            ),
                          ),
                        ),
                      ],
                    ),
                ],
              ),
            ),
          ),
        );
      }).toList(),
    );
  }


  Widget _buildAbsentMembersSection(BuildContext context, OrganizzaViewModel vm) {
    final absences = vm.activeAbsences;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                const Icon(Icons.flight_takeoff, color: Colors.orange, size: 20),
                const SizedBox(width: 8),
                const Text(
                  'Coinquilini Assenti',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                if (absences.isNotEmpty)
                  Container(
                    margin: const EdgeInsets.only(left: 8),
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                    decoration: BoxDecoration(
                      color: Colors.orange,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      '${absences.length}',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
              ],
            ),
            TextButton(
              onPressed: () => _showAbsenceManager(context),
              child: const Text(
                'Gestisci',
                style: TextStyle(color: AppColors.primaryGreen),
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        if (absences.isEmpty)
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Colors.grey.shade100),
            ),
            child: Row(
              children: [
                Icon(Icons.home_outlined, color: Colors.grey.shade400),
                const SizedBox(width: 12),
                Text(
                  'Tutti i coinquilini sono a casa!',
                  style: TextStyle(color: Colors.grey.shade500, fontSize: 14),
                ),
              ],
            ),
          )
        else
          Column(
            children: absences.map((event) {
              final name = event.title.replaceFirst('Assente: ', '');
              final until = event.end;
              final user = vm.appUserForAbsenceEvent(event);
              return Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(16),
                  child: IntrinsicHeight(
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Container(width: 4, color: Colors.orange),
                        Expanded(
                          child: Container(
                            color: Colors.white,
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                            child: Row(
                              children: [
                                UserAvatar(user: user, radius: 22),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        '$name assente',
                                        style: const TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 15,
                                          color: Colors.black87,
                                        ),
                                      ),
                                      if (until != null)
                                        Text(
                                          'fino al ${until.day}/${until.month}/${until.year}',
                                          style: TextStyle(
                                            fontSize: 13,
                                            color: Colors.grey.shade500,
                                          ),
                                        ),
                                    ],
                                  ),
                                ),
                                IconButton(
                                  icon: Icon(Icons.delete_outline, color: Colors.red.shade300, size: 20),
                                  onPressed: () => vm.removeEvent(event.id),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
      ],
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

    final bool isTakenOut = isToday ? vm.todayWasteTakenOut : vm.tomorrowWasteTakenOut;

    final bool isResponsible = vm.isUserResponsibleForTodayWaste;

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
                  : (isToday && !isResponsible)
                      ? Tooltip(
                          message: 'Solo il responsabile di oggi può confermare',
                          child: Icon(
                            Icons.lock_outline,
                            color: Colors.grey.shade400,
                            size: 24,
                          ),
                        )
                      : Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            // --- BOTTONE JOLLY IMMONDIZIA ---
                            if (isToday && isResponsible && (vm.appUserFor(vm.authRepository.currentFirebaseUser?.uid ?? '')?.jollies ?? 0) > 0)
                              Padding(
                                padding: const EdgeInsets.only(right: 8.0),
                                child: IconButton(
                                  tooltip: 'Passa il turno con un Jolly',
                                  icon: const Text('🃏', style: TextStyle(fontSize: 22)),
                                  onPressed: () async {
                                    final confirm = await showDialog<bool>(
                                      context: context,
                                      builder: (ctx) => AlertDialog(
                                        title: const Text('Usa un Jolly? 🃏'),
                                        content: const Text('Vuoi spendere 1 Jolly per passare il turno di spazzatura al prossimo coinquilino?'),
                                        actions: [
                                          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Annulla')),
                                          ElevatedButton(onPressed: () => Navigator.pop(ctx, true), child: const Text('Usa Jolly')),
                                        ],
                                      ),
                                    );
                                    if (confirm == true) {
                                      await vm.useJollyForWaste();
                                      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Jolly usato! Turno passato.')));
                                    }
                                  },
                                ),
                              ),
                            
                            // --- BOTTONE FATTO ---
                            ElevatedButton(
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
                                // Segniamo graficamente come portata fuori
                                vm.setTomorrowWasteTakenOut(true);

                                // Controlliamo se sblocca il badge
                                Map<String, dynamic>? newBadge = await vm.confirmWasteTakenOut(wasteType);

                                // Se sblocca il badge, mostriamo il popup celebrativo!
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

    // Se la tendina si è chiusa restituendoci un badge sbloccato
    if (newBadge != null && context.mounted) {
      // Aspettiamo mezzo secondo per far finire l'animazione di chiusura
      Future.delayed(const Duration(milliseconds: 500), () {
        if (context.mounted) {
          // Mosrtiamo il popup celebrativo per il nuovo badge sbloccato
          showGenericBadgePopup(context, newBadge);
        }
      });
    }
  }

  void _showAbsenceManager(BuildContext context) {
    final vm = context.read<OrganizzaViewModel>();
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (sheetContext) {
        return _AbsenceManagerSheet(vm: vm);
      },
    );
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

  void _showRoomManager(BuildContext context) {
    final vm = context.read<OrganizzaViewModel>();
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (sheetContext) {
        return _RoomManagerSheet(vm: vm);
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
                                subtitle: Text('Assegnato a ${vm.displayNameFor(task.assigneeUid, showStatus: true)}'),
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
