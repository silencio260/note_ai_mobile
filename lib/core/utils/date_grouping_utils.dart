import 'package:intl/intl.dart';
import '../../features/recording/domain/entities/recording_entity.dart';

abstract class ListItem {}

class DateHeaderItem extends ListItem {
  final String date;
  DateHeaderItem(this.date);
}

class RecordingListItem extends ListItem {
  final RecordingEntity recording;
  RecordingListItem(this.recording);
}

class DateGroupingUtils {
  static List<ListItem> groupRecordingsByDate(List<RecordingEntity> recordings) {
    if (recordings.isEmpty) return [];

    // Sort descending by creation date
    final sortedRecordings = List<RecordingEntity>.from(recordings)
      ..sort((a, b) => b.createdAt.compareTo(a.createdAt));

    final List<ListItem> groupedList = [];
    String? currentDateHeader;
    
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = today.subtract(const Duration(days: 1));

    for (var recording in sortedRecordings) {
      final date = DateTime(
        recording.createdAt.year,
        recording.createdAt.month,
        recording.createdAt.day,
      );

      String headerText;
      if (date == today) {
        headerText = 'Today';
      } else if (date == yesterday) {
        headerText = 'Yesterday';
      } else {
        headerText = DateFormat('MMMM d, yyyy').format(recording.createdAt);
      }

      if (headerText != currentDateHeader) {
        groupedList.add(DateHeaderItem(headerText));
        currentDateHeader = headerText;
      }

      groupedList.add(RecordingListItem(recording));
    }

    return groupedList;
  }
}
