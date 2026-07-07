import 'package:flutter/material.dart';
import 'manual_entry_screen.dart';
import 'scanner_page.dart';
import 'log_store.dart';

void main() {
  runApp(const NutriScanApp());
}

class NutriScanApp extends StatefulWidget {
  const NutriScanApp({super.key});

  @override
  State<NutriScanApp> createState() => _NutriScanAppState();
}

class _NutriScanAppState extends State<NutriScanApp> {
  bool isDark = true;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: isDark ? darkTheme : lightTheme,
      home: HomePage(
        isDark: isDark,
        toggleTheme: () {
          setState(() {
            isDark = !isDark;
          });
        },
      ),
    );
  }
}

/* ------------------ THEMES ------------------ */

ThemeData darkTheme = ThemeData(
  brightness: Brightness.dark,
  scaffoldBackgroundColor: Colors.black,
);

ThemeData lightTheme = ThemeData(
  brightness: Brightness.light,
  scaffoldBackgroundColor: Colors.grey.shade100,
);

/* ------------------ HOME ------------------ */

class HomePage extends StatefulWidget {
  final bool isDark;
  final VoidCallback toggleTheme;

  const HomePage({super.key, required this.isDark, required this.toggleTheme});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _selectedIndex = 0;

  void _onTabSelected(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    final entries = LogStore.instance.entries;

    return Scaffold(
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: _onTabSelected,
        selectedItemColor: const Color(0xff1abc9c),
        unselectedItemColor: Colors.grey,
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
          BottomNavigationBarItem(icon: Icon(Icons.history), label: 'History'),
        ],
      ),
      body: SafeArea(
        child: _selectedIndex == 0
            ? _buildHomeContent(context)
            : _buildHistoryContent(context, entries),
      ),
    );
  }

  Widget _buildHomeContent(BuildContext context) {
    return Column(
      children: [
        Container(
          height: 190,
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xff1abc9c), Color(0xff16a085)],
            ),
            borderRadius: BorderRadius.vertical(bottom: Radius.circular(40)),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Align(
                  alignment: Alignment.topRight,
                  child: IconButton(
                    onPressed: widget.toggleTheme,
                    icon: Icon(
                      widget.isDark ? Icons.wb_sunny : Icons.dark_mode,
                      color: Colors.white,
                    ),
                  ),
                ),
                const SizedBox(height: 6),
                const Text(
                  "NutriScan",
                  style: TextStyle(
                    fontSize: 30,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 12),
                const Text(
                  'Scan or enter a barcode to see nutrition info and ingredients quickly.',
                  style: TextStyle(fontSize: 14, color: Colors.white70),
                ),
              ],
            ),
          ),
        ),
        Expanded(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                ActionButton(
                  icon: Icons.qr_code_scanner,
                  title: "Scan Barcode",
                  color: const Color(0xff0e6655),
                  height: 160,
                  onTap: () async {
                    await Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const ScannerPage(),
                      ),
                    );
                    setState(() {});
                  },
                ),
                const SizedBox(height: 24),
                ActionButton(
                  icon: Icons.edit_note,
                  title: "Manual Entry",
                  color: const Color(0xff1f3a5f),
                  height: 150,
                  onTap: () async {
                    await Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const ManualEntryScreen(),
                      ),
                    );
                    setState(() {});
                  },
                ),
                const SizedBox(height: 24),
                Row(
                  children: const [
                    Icon(Icons.info_outline),
                    SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        "Your latest searches are stored in History",
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildHistoryContent(BuildContext context, List<LogEntry> entries) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
      child: entries.isEmpty
          ? Center(
              child: Text(
                'No searches yet. Scan or enter a barcode first.',
                style: TextStyle(
                  color: Theme.of(context).brightness == Brightness.dark
                      ? Colors.grey.shade400
                      : Colors.grey.shade700,
                  fontSize: 16,
                ),
                textAlign: TextAlign.center,
              ),
            )
          : ListView.builder(
              itemCount: entries.length,
              itemBuilder: (context, index) {
                final entry = entries[index];
                return Dismissible(
                  key: ValueKey(entry.time.toIso8601String()),
                  direction: DismissDirection.endToStart,
                  onDismissed: (_) {
                    setState(() {
                      LogStore.instance.remove(entry);
                    });
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Search removed')),
                    );
                  },
                  background: Container(
                    margin: const EdgeInsets.only(bottom: 12),
                    decoration: BoxDecoration(
                      color: Colors.redAccent,
                      borderRadius: BorderRadius.circular(18),
                    ),
                    alignment: Alignment.centerRight,
                    padding: const EdgeInsets.only(right: 20),
                    child: const Icon(Icons.delete, color: Colors.white),
                  ),
                  child: RecentSearchTile(
                    entry: entry,
                    onDelete: () {
                      setState(() {
                        LogStore.instance.remove(entry);
                      });
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Search removed')),
                      );
                    },
                  ),
                );
              },
            ),
    );
  }
}

class RecentSearchTile extends StatelessWidget {
  final LogEntry entry;
  final VoidCallback onDelete;

  const RecentSearchTile({
    super.key,
    required this.entry,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    bool isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(18),
        gradient: isDark
            ? LinearGradient(
                colors: [Colors.grey.shade900, Colors.grey.shade800],
              )
            : LinearGradient(colors: [Colors.white, Colors.grey.shade200]),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  entry.name,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                    color: isDark ? Colors.white : Colors.blue.shade900,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  '${entry.calories != null ? '${entry.calories!.toStringAsFixed(0)} kcal' : 'N/A'} • ${entry.proteins != null ? '${entry.proteins!.toStringAsFixed(1)}g protein' : ''}',
                  style: TextStyle(
                    color: isDark ? Colors.grey.shade400 : Colors.grey.shade700,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  'Scanned at ${entry.time.hour.toString().padLeft(2, '0')}:${entry.time.minute.toString().padLeft(2, '0')}',
                  style: TextStyle(
                    color: isDark ? Colors.grey.shade500 : Colors.grey.shade600,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            onPressed: onDelete,
            icon: Icon(
              Icons.delete_outline,
              color: isDark ? Colors.red.shade300 : Colors.red.shade700,
            ),
          ),
        ],
      ),
    );
  }
}

/* ------------------ BUTTON ------------------ */

class ActionButton extends StatelessWidget {
  final IconData icon;
  final String title;
  final Color color;
  final VoidCallback onTap;
  final double height;

  const ActionButton({
    super.key,
    required this.icon,
    required this.title,
    required this.color,
    required this.onTap,
    this.height = 70,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: height,
        padding: const EdgeInsets.symmetric(horizontal: 24),
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(24),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Icon(icon, color: Colors.white, size: 36),
            const SizedBox(width: 16),
            Text(
              title,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 22,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/* ------------------ FOOD TILE ------------------ */

class FoodTile extends StatelessWidget {
  final String title;
  final String subtitle;

  const FoodTile(this.title, this.subtitle, {super.key});

  @override
  Widget build(BuildContext context) {
    bool isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(18),
        gradient: isDark
            ? LinearGradient(
                colors: [Colors.grey.shade900, Colors.grey.shade800],
              )
            : LinearGradient(colors: [Colors.white, Colors.grey.shade200]),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                    color: isDark ? Colors.white : Colors.blue.shade800,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: TextStyle(
                    color: isDark ? Colors.grey : Colors.blue.shade400,
                  ),
                ),
              ],
            ),
          ),
          Icon(
            Icons.arrow_forward_ios,
            size: 16,
            color: isDark ? Colors.white : Colors.green,
          ),
        ],
      ),
    );
  }
}

/* ------------------ BOTTOM NAV ------------------ */

class BottomNav extends StatelessWidget {
  const BottomNav({super.key});

  @override
  Widget build(BuildContext context) {
    return BottomNavigationBar(
      currentIndex: 1,
      selectedItemColor: Colors.green,
      unselectedItemColor: Colors.green.shade300,
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      items: const [
        BottomNavigationBarItem(
          icon: Icon(Icons.insert_chart),
          label: "Summary",
        ),
        BottomNavigationBarItem(icon: Icon(Icons.add), label: "Log"),
        BottomNavigationBarItem(icon: Icon(Icons.search), label: "Browse"),
        BottomNavigationBarItem(icon: Icon(Icons.settings), label: "Settings"),
      ],
    );
  }
}
