class LogEntry {
  final String barcode;
  final String name;
  final double? calories;
  final double? proteins;
  final double? fats;
  final double? carbs;
  final double? sugar;
  final String? ingredients;
  final DateTime time;

  LogEntry({
    required this.barcode,
    required this.name,
    this.calories,
    this.proteins,
    this.fats,
    this.carbs,
    this.sugar,
    this.ingredients,
    DateTime? time,
  }) : time = time ?? DateTime.now();
}

class LogStore {
  LogStore._privateConstructor();
  static final LogStore instance = LogStore._privateConstructor();

  final List<LogEntry> _entries = [];

  List<LogEntry> get entries => List.unmodifiable(_entries.reversed);

  void add(LogEntry e) {
    _entries.add(e);
  }

  void remove(LogEntry entry) {
    _entries.remove(entry);
  }

  void clear() => _entries.clear();
}
