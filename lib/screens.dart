import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';
import 'api.dart';
import 'main.dart';

class CountriesScreen extends StatelessWidget {
  const CountriesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Countries')),
      body: FutureBuilder(
        future: PortalApi.countries(),
        builder: (context, snapshot) {
          if (snapshot.hasError) return Center(child: Text('Cannot reach portal: ${snapshot.error}'));
          if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
          final countries = snapshot.data!;
          return GridView.builder(
            padding: const EdgeInsets.all(24),
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: MediaQuery.sizeOf(context).width > 800 ? 4 : 2,
              mainAxisSpacing: 16,
              crossAxisSpacing: 16,
            ),
            itemCount: countries.length,
            itemBuilder: (context, i) {
              final country = countries[i];
              return FocusableTile(
                label: '${country['flag']} ${country['name']}',
                subtitle: '${country['count']} channels',
                onPressed: () => Navigator.push(context, MaterialPageRoute(
                  builder: (_) => ChannelsScreen(code: country['code'] as String, name: country['name'] as String),
                )),
              );
            },
          );
        },
      ),
    );
  }
}

class ChannelsScreen extends StatelessWidget {
  const ChannelsScreen({super.key, required this.code, required this.name});
  final String code;
  final String name;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(name)),
      body: FutureBuilder(
        future: PortalApi.channels(code),
        builder: (context, snapshot) {
          if (snapshot.hasError) return Center(child: Text('${snapshot.error}'));
          if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
          final channels = List<Map<String, dynamic>>.from(snapshot.data!['data'] as List);
          return GridView.builder(
            padding: const EdgeInsets.all(24),
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: MediaQuery.sizeOf(context).width > 800 ? 4 : 2,
              mainAxisSpacing: 16,
              crossAxisSpacing: 16,
              childAspectRatio: 1.4,
            ),
            itemCount: channels.length,
            itemBuilder: (context, i) {
              final channel = channels[i];
              return FocusableTile(
                label: channel['name'] as String,
                onPressed: () => Navigator.push(context, MaterialPageRoute(
                  builder: (_) => PlayerScreen(title: channel['name'] as String, url: channel['play_url'] as String),
                )),
              );
            },
          );
        },
      ),
    );
  }
}

class PlayerScreen extends StatefulWidget {
  const PlayerScreen({super.key, required this.title, required this.url});
  final String title;
  final String url;

  @override
  State<PlayerScreen> createState() => _PlayerScreenState();
}

class _PlayerScreenState extends State<PlayerScreen> {
  late final VideoPlayerController _controller;
  String? _error;

  @override
  void initState() {
    super.initState();
    _controller = VideoPlayerController.networkUrl(Uri.parse(widget.url))
      ..initialize().then((_) {
        if (mounted) setState(() {});
        _controller.play();
      }).catchError((e) {
        if (mounted) setState(() => _error = '$e');
      });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.title)),
      body: Center(
        child: _error != null
            ? Text('Channel unavailable: $_error')
            : _controller.value.isInitialized
                ? AspectRatio(aspectRatio: _controller.value.aspectRatio, child: VideoPlayer(_controller))
                : const CircularProgressIndicator(),
      ),
    );
  }
}

class InfoScreen extends StatelessWidget {
  const InfoScreen({super.key, required this.title, required this.path});
  final String title;
  final String path;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(title)),
      body: FutureBuilder(
        future: PortalApi.info(path),
        builder: (context, snapshot) {
          if (snapshot.hasError) return Center(child: Text('${snapshot.error}'));
          if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
          return SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Text(const JsonEncoder.withIndent('  ').convert(snapshot.data), style: const TextStyle(fontSize: 18)),
          );
        },
      ),
    );
  }
}
