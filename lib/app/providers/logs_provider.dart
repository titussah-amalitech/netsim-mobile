

import 'package:netsim_mobile/app/services/log_services.dart';
import 'package:riverpod/legacy.dart';
import 'package:riverpod/riverpod.dart';
import '../models/log_model.dart';
import '../models/log_state_model.dart';
final logsFutureProvider = FutureProvider<List<LogModel>>((ref) async {
  var logs = await LogServices.fetchLogs();
  ref.read(logsProvider.notifier).setLogs(logs);
  return logs;
});



class LogNotifier extends StateNotifier<LogState> {
  LogNotifier() : super(LogState(logs: [], filteredLogs: [], page: 10));
  void setLogs(List<LogModel> logs) {
    state = state.copyWith(logs: logs);
    applyFilters();
  }
  
  void applyFilters() {
    List<LogModel> filtered = state.logs;

    if (state.statusFilter != null && state.statusFilter!.isNotEmpty) {
      filtered = filtered.where((log) => log.status == state.statusFilter).toList();
    }

    if (state.eventTypeFilter != null && state.eventTypeFilter!.isNotEmpty) {
      filtered = filtered.where((log) => log.eventType == state.eventTypeFilter).toList();
    }

    state = state.copyWith(filteredLogs: filtered);
  }
}
final logsProvider = StateNotifierProvider<LogNotifier, LogState>((ref) {
  return LogNotifier();
});