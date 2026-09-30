import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'screens.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const HotelApp());
}

class HotelApp extends StatelessWidget {
  const HotelApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Hotel TV',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        brightness: Brightness.dark,
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF00ADEE), brightness: Brightness.dark),
        useMaterial3: true,
      ),
      home: const HomeScreen(),
    );
  }
}

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final tiles = [
      ('Live TV', () => const CountriesScreen()),
      ('Hotel', () => const InfoScreen(title: 'Hotel', path: '/hotel')),
      ('Food & Bar', () => const InfoScreen(title: 'Food & Bar', path: '/menu')),
      ('Contacts', () => const InfoScreen(title: 'Contacts', path: '/contacts')),
    ];
    return Scaffold(
      appBar: AppBar(title: const Text('Hotel TV')),
      body: GridView.count(
        crossAxisCount: MediaQuery.sizeOf(context).width > 800 ? 4 : 2,
        padding: const EdgeInsets.all(24),
        mainAxisSpacing: 16,
        crossAxisSpacing: 16,
        children: [
          for (final tile in tiles)
            FocusableTile(
              label: tile.$1,
              onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => tile.$2())),
            ),
        ],
      ),
    );
  }
}

class FocusableTile extends StatelessWidget {
  const FocusableTile({super.key, required this.label, required this.onPressed, this.subtitle});
  final String label;
  final String? subtitle;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return Focus(
      onKeyEvent: (node, event) {
        if (event is KeyDownEvent && (event.logicalKey == LogicalKeyboardKey.select || event.logicalKey == LogicalKeyboardKey.enter)) {
          onPressed();
          return KeyEventResult.handled;
        }
        return KeyEventResult.ignored;
      },
      child: Builder(builder: (context) {
        final focused = Focus.of(context).hasFocus;
        return AnimatedScale(
          scale: focused ? 1.06 : 1,
          duration: const Duration(milliseconds: 120),
          child: Card(
            color: focused ? const Color(0xFF163544) : const Color(0xFF141414),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
              side: BorderSide(color: focused ? const Color(0xFF00ADEE) : Colors.transparent, width: 3),
            ),
            child: InkWell(
              onTap: onPressed,
              child: Center(
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(label, textAlign: TextAlign.center, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                      if (subtitle != null) Text(subtitle!, textAlign: TextAlign.center),
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      }),
    );
  }
}
