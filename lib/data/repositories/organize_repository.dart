import '../../domain/models/cleaning_task.dart';
import '../../domain/models/shopping_item.dart';
import '../../domain/models/house_event.dart';
import '../../domain/models/sticky_note.dart';
import '../../domain/models/house_rule.dart';

/// Interfaccia che astrae tutte le operazioni relative all'organizzazione della casa.
/// (Turni di pulizia, Spesa, Eventi, Post-it, Regole e Immondizia).
abstract class OrganizeRepository {
  // --- Turni di Pulizia (Cleaning Rota) ---
  /// Restituisce lo stream dei turni di pulizia per la casa specificata.
  Stream<List<CleaningTask>> getCleaningTasksStream(String houseId);
  Future<void> addOrUpdateCleaningTask(String houseId, CleaningTask task);
  Future<void> toggleCleaningTaskCompleted(String houseId, String taskId, bool completed);
  Future<void> deleteCleaningTask(String houseId, String taskId);

  // --- Lista della Spesa (Shopping List) ---
  /// Restituisce lo stream degli articoli da acquistare.
  Stream<List<ShoppingItem>> getShoppingListStream(String houseId);
  Future<bool> addShoppingItem(String houseId, ShoppingItem item);
  Future<void> markItemBought(String houseId, String itemId, bool bought, String userUid);
  Future<void> deleteShoppingItem(String houseId, String itemId);

  // --- Eventi e Calendario (Events) ---
  /// Restituisce lo stream degli eventi condivisi della casa.
  Stream<List<HouseEvent>> getEventsStream(String houseId);
  Future<void> addOrUpdateEvent(String houseId, HouseEvent event);
  Future<void> deleteEvent(String houseId, String eventId);

  // --- Post-it (Sticky Notes) ---
  /// Restituisce lo stream dei post-it lasciati in bacheca.
  Stream<List<StickyNote>> getStickyNotesStream(String houseId);
  Future<void> addStickyNote(String houseId, StickyNote note);
  Future<void> deleteStickyNote(String houseId, String noteId);

  // --- Regole della Casa (House Rules) ---
  /// Restituisce lo stream delle regole attualmente in vigore.
  Stream<List<HouseRule>> getHouseRulesStream(String houseId);
  Future<void> updateHouseRules(String houseId, List<HouseRule> rules);

  // --- Calendario Immondizia (Recycling) ---
  /// Restituisce le regole di conferimento dei rifiuti divise per giorno.
  Stream<Map<String, String>> getRecyclingScheduleStream(String houseId);
  Future<void> updateRecyclingSchedule(String houseId, Map<String, String> schedule);

  // Chore rooms (stanze personalizzabili)
  Stream<List<String>> getChoreRoomsStream(String houseId);
  Future<void> updateChoreRooms(String houseId, List<String> rooms);

  // Waste responsible (turno immondizia persistente)
  Stream<Map<String, dynamic>> getWasteResponsibleStream(String houseId);
  Future<void> updateWasteResponsible(String houseId, String uid, DateTime weekStart);
  Future<void> confirmWasteTakenOutToday(String houseId, String uid, String wasteType);
  Stream<Map<String, dynamic>> getWasteConfirmationStream(String houseId);
}
