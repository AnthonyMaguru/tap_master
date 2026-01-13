import 'package:flutter/material.dart';
import 'dart:math';
import 'dart:async';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Tap Master',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepOrange),
        useMaterial3: true,
      ),
      home: const GameHomePage(),
    );
  }
}

class GameHomePage extends StatefulWidget {
  const GameHomePage({super.key});

  @override
  State<GameHomePage> createState() => _GameHomePageState();
}

class _GameHomePageState extends State<GameHomePage> {
  int _score = 0;
  int _timeLeft = 30;
  bool _gameStarted = false;
  bool _gameOver = false;
  Timer? _gameTimer;
  
  // Target properties
  double _targetX = 0.5;
  double _targetY = 0.5;
  double _targetSize = 80;
  Color _targetColor = Colors.red;
  
  final Random _random = Random();

  void _startGame() {
    setState(() {
      _score = 0;
      _timeLeft = 30;
      _gameStarted = true;
      _gameOver = false;
    });
    
    _moveTarget();
    
    _gameTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        _timeLeft--;
        if (_timeLeft <= 0) {
          _endGame();
        }
      });
    });
  }

  void _endGame() {
    _gameTimer?.cancel();
    setState(() {
      _gameStarted = false;
      _gameOver = true;
    });
  }

  void _moveTarget() {
    setState(() {
      _targetX = 0.1 + _random.nextDouble() * 0.8;
      _targetY = 0.2 + _random.nextDouble() * 0.6;
      _targetSize = 60 + _random.nextDouble() * 40;
      _targetColor = _getRandomColor();
    });
  }

  Color _getRandomColor() {
    List<Color> colors = [
      Colors.red,
      Colors.blue,
      Colors.green,
      Colors.orange,
      Colors.purple,
      Colors.pink,
      Colors.teal,
    ];
    return colors[_random.nextInt(colors.length)];
  }

  void _onTargetTap() {
    if (_gameStarted && !_gameOver) {
      setState(() {
        _score += 10;
      });
      _moveTarget();
    }
  }

  @override
  void dispose() {
    _gameTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[900],
      appBar: AppBar(
        backgroundColor: Colors.deepOrange,
        title: const Text('Tap Master', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        centerTitle: true,
      ),
      body: _gameStarted
          ? _buildGameArea()
          : _buildStartScreen(),
    );
  }

  Widget _buildStartScreen() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.videogame_asset,
            size: 100,
            color: Colors.deepOrange,
          ),
          const SizedBox(height: 30),
          Text(
            _gameOver ? 'Game Over!' : 'Tap Master',
            style: const TextStyle(
              fontSize: 48,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 20),
          if (_gameOver)
            Text(
              'Final Score: $_score',
              style: const TextStyle(
                fontSize: 32,
                color: Colors.orange,
                fontWeight: FontWeight.bold,
              ),
            ),
          const SizedBox(height: 30),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 40),
            child: Text(
              'Tap the colored circles as fast as you can!\nYou have 30 seconds to score as many points as possible.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 18,
                color: Colors.white70,
              ),
            ),
          ),
          const SizedBox(height: 50),
          ElevatedButton(
            onPressed: _startGame,
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.deepOrange,
              padding: const EdgeInsets.symmetric(horizontal: 50, vertical: 20),
              textStyle: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            child: Text(_gameOver ? 'Play Again' : 'Start Game'),
          ),
        ],
      ),
    );
  }

  Widget _buildGameArea() {
    return Stack(
      children: [
        // Score and Time Display
        Positioned(
          top: 20,
          left: 20,
          right: 20,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  'Score: $_score',
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                decoration: BoxDecoration(
                  color: _timeLeft <= 5 ? Colors.red : Colors.white,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  'Time: $_timeLeft',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: _timeLeft <= 5 ? Colors.white : Colors.black,
                  ),
                ),
              ),
            ],
          ),
        ),
        // Game Area with Target
        Positioned.fill(
          child: LayoutBuilder(
            builder: (context, constraints) {
              return GestureDetector(
                onTapDown: (details) {
                  // Check if tap is on target
                  final double targetCenterX = constraints.maxWidth * _targetX;
                  final double targetCenterY = constraints.maxHeight * _targetY;
                  final double dx = details.localPosition.dx - targetCenterX;
                  final double dy = details.localPosition.dy - targetCenterY;
                  final double distance = sqrt(dx * dx + dy * dy);
                  
                  if (distance <= _targetSize / 2) {
                    _onTargetTap();
                  }
                },
                child: Stack(
                  children: [
                    Positioned(
                      left: constraints.maxWidth * _targetX - _targetSize / 2,
                      top: constraints.maxHeight * _targetY - _targetSize / 2,
                      child: GestureDetector(
                        onTap: _onTargetTap,
                        child: Container(
                          width: _targetSize,
                          height: _targetSize,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: _targetColor,
                            boxShadow: [
                              BoxShadow(
                                color: _targetColor.withOpacity(0.5),
                                blurRadius: 20,
                                spreadRadius: 5,
                              ),
                            ],
                          ),
                          child: Center(
                            child: Text(
                              '+10',
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: _targetSize * 0.25,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}
