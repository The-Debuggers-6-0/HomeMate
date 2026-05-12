import '../../domain/models/cleaning_task.dart';
import '../../domain/models/shopping_item.dart';
import '../../domain/models/house_event.dart';
import '../../domain/models/sticky_note.dart';
import '../../domain/models/house_rule.dart';

abstract class OrganizeRepository {
  // Cleaning rota
  Stream<List<CleaningTask>> getCleaningTasksStream(String houseId);
  Future<void> addOrUpdateCleaningTask(String houseId, CleaningTask task);
  Future<void> toggleCleaningTaskCompleted(String houseId, String taskId, bool completed);
  Future<void> deleteCleaningTask(String houseId, String taskId);

  // Shopping list
  Stream<List<ShoppingItem>> getShoppingListStream(String houseId);
  Future<bool> addShoppingItem(String houseId, ShoppingItem item);
  Future<void> markItemBought(String houseId, String itemId, bool bought, String userUid);
  Future<void> deleteShoppingItem(String houseId, String itemId);

  // Events
  Stream<List<HouseEvent>> getEventsStream(String houseId);
  Future<void> addOrUpdateEvent(String houseId, HouseEvent event);
  Future<void> deleteEvent(String houseId, String eventId);

  // Sticky notes
  Stream<List<StickyNote>> getStickyNotesStream(String houseId);
  Future<void> addStickyNote(String houseId, StickyNote note);
  Future<void> deleteStickyNote(String houseId, String noteId);

  // Rules
  Stream<List<HouseRule>> getHouseRulesStream(String houseId);
  Future<void> updateHouseRules(String houseId, List<HouseRule> rules);

  // Recycling
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
