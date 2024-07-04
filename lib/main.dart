import 'package:flutter/material.dart';
import 'package:fluttercon24_js/video_player.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
      ),
      home: const HomePage(),
    );
  }
}

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> with TickerProviderStateMixin {
  final VideoPlayerController _controller = VideoPlayerController();

  late final AnimationController _animationController = AnimationController(
      vsync: this, duration: const Duration(milliseconds: 600));

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('FlutterCon JS Interop'),
      ),
      body: Center(
        child: Column(
          children: [
            Expanded(child: VideoPlayer(controller: _controller)),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        child: AnimatedIcon(
            icon: AnimatedIcons.pause_play,
            progress: Tween<double>(begin: 1.0, end: 0.0)
                .animate(_animationController)),
        onPressed: () {
          if (_controller.isPlaying) {
            _controller.pause();
          } else {
            _controller.play();
          }
        },
      ),
    );
  }

  @override
  void initState() {
    _controller.addListener(update);
    super.initState();
  }

  @override
  void dispose() {
    _controller.removeListener(update);
    _animationController.dispose();
    super.dispose();
  }

  void update() {
    if (_controller.isPlaying) {
      _animationController.forward();
    } else {
      _animationController.reverse();
    }
    setState(() {});
  }
}
