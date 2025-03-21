import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

void main() {
  runApp(const ChaseGameApp());
}

class ChaseGameApp extends StatelessWidget {
  const ChaseGameApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Chase Arena',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
        fontFamily: 'Poppins',
      ),
      home: const GameWrapper(),
    );
  }
}

class GameWrapper extends StatefulWidget {
  const GameWrapper({super.key});

  @override
  State<GameWrapper> createState() => _GameWrapperState();
}

class _GameWrapperState extends State<GameWrapper> {
  bool showTitleScreen = true;
  bool showInstructions = false;
  bool showSettings = false;
  
  // Game settings
  int gameDuration = 60;
  double playerSpeed = 5.0;
  bool enableObstacles = true;
  bool enablePowerups = true;
  String gameMode = 'classic'; // classic, timeAttack, survival

  @override
  Widget build(BuildContext context) {
    if (showTitleScreen) {
      return TitleScreen(
        onStartGame: () {
          setState(() {
            showTitleScreen = false;
          });
        },
        onShowInstructions: () {
          setState(() {
            showInstructions = true;
          });
        },
        onShowSettings: () {
          setState(() {
            showSettings = true;
          });
        },
        showInstructions: showInstructions,
        showSettings: showSettings,
        onCloseModal: () {
          setState(() {
            showInstructions = false;
            showSettings = false;
          });
        },
        onSaveSettings: (duration, speed, obstacles, powerups, mode) {
          setState(() {
            gameDuration = duration;
            playerSpeed = speed;
            enableObstacles = obstacles;
            enablePowerups = powerups;
            gameMode = mode;
            showSettings = false;
          });
        },
        gameDuration: gameDuration,
        playerSpeed: playerSpeed,
        enableObstacles: enableObstacles,
        enablePowerups: enablePowerups,
        gameMode: gameMode,
      );
    } else {
      return ChaseGameScreen(
        onBackToTitle: () {
          setState(() {
            showTitleScreen = true;
          });
        },
        gameDuration: gameDuration,
        playerSpeed: playerSpeed,
        enableObstacles: enableObstacles,
        enablePowerups: enablePowerups,
        gameMode: gameMode,
      );
    }
  }
}

class TitleScreen extends StatelessWidget {
  final VoidCallback onStartGame;
  final VoidCallback onShowInstructions;
  final VoidCallback onShowSettings;
  final VoidCallback onCloseModal;
  final bool showInstructions;
  final bool showSettings;
  final Function(int, double, bool, bool, String) onSaveSettings;
  final int gameDuration;
  final double playerSpeed;
  final bool enableObstacles;
  final bool enablePowerups;
  final String gameMode;

  const TitleScreen({
    super.key,
    required this.onStartGame,
    required this.onShowInstructions,
    required this.onShowSettings,
    required this.onCloseModal,
    required this.showInstructions,
    required this.showSettings,
    required this.onSaveSettings,
    required this.gameDuration,
    required this.playerSpeed,
    required this.enableObstacles,
    required this.enablePowerups,
    required this.gameMode,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Colors.indigo.shade900,
              Colors.indigo.shade700,
              Colors.blue.shade500,
            ],
          ),
        ),
        child: Stack(
          children: [
            // Background particles
            ...List.generate(50, (index) {
              final random = Random();
              return Positioned(
                left: random.nextDouble() * MediaQuery.of(context).size.width,
                top: random.nextDouble() * MediaQuery.of(context).size.height,
                child: Container(
                  width: random.nextDouble() * 5 + 2,
                  height: random.nextDouble() * 5 + 2,
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(random.nextDouble() * 0.5 + 0.1),
                    borderRadius: BorderRadius.circular(5),
                  ),
                ),
              );
            }),
            
            Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Game title
                  const Text(
                    'CHASE ARENA',
                    style: TextStyle(
                      fontSize: 64,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                      letterSpacing: 2,
                      shadows: [
                        Shadow(
                          color: Colors.black45,
                          offset: Offset(2, 2),
                          blurRadius: 4,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    '2-PLAYER WEB GAME',
                    style: TextStyle(
                      fontSize: 18,
                      color: Colors.white70,
                      letterSpacing: 4,
                    ),
                  ),
                  const SizedBox(height: 60),
                  
                  // Game characters preview
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      _buildPlayerPreview(
                        'CHASER',
                        Colors.red.shade400,
                        Colors.red.shade700,
                      ),
                      const SizedBox(width: 40),
                      Container(
                        width: 80,
                        height: 2,
                        color: Colors.white30,
                      ),
                      const SizedBox(width: 40),
                      _buildPlayerPreview(
                        'RUNNER',
                        Colors.blue.shade400,
                        Colors.blue.shade700,
                      ),
                    ],
                  ),
                  
                  const SizedBox(height: 60),
                  
                  // Menu buttons
                  _buildMenuButton('START GAME', Icons.play_arrow, onStartGame),
                  const SizedBox(height: 16),
                  _buildMenuButton('HOW TO PLAY', Icons.help_outline, onShowInstructions),
                  const SizedBox(height: 16),
                  _buildMenuButton('SETTINGS', Icons.settings, onShowSettings),
                ],
              ),
            ),
            
            // Footer
            Positioned(
              bottom: 20,
              left: 0,
              right: 0,
              child: const Center(
                child: Text(
                  '© 2025 Chase Arena | Made with Flutter Web',
                  style: TextStyle(
                    color: Colors.white54,
                    fontSize: 12,
                  ),
                ),
              ),
            ),
            
            // Instructions modal
            if (showInstructions)
              _buildInstructionsModal(context),
              
            // Settings modal
            if (showSettings)
              _buildSettingsModal(context),
          ],
        ),
      ),
    );
  }
  
  Widget _buildPlayerPreview(String label, Color color, Color shadowColor) {
    return Column(
      children: [
        Container(
          width: 60,
          height: 60,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: shadowColor,
                blurRadius: 10,
                spreadRadius: 2,
              ),
            ],
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                color,
                shadowColor,
              ],
            ),
          ),
        ),
        const SizedBox(height: 12),
        Text(
          label,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 16,
            fontWeight: FontWeight.w600,
            letterSpacing: 1,
          ),
        ),
      ],
    );
  }
  
  Widget _buildMenuButton(String label, IconData icon, VoidCallback onPressed) {
    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.white,
        foregroundColor: Colors.indigo.shade900,
        padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
        minimumSize: const Size(240, 54),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(30),
        ),
        elevation: 5,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 24),
          const SizedBox(width: 12),
          Text(
            label,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              letterSpacing: 1,
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildInstructionsModal(BuildContext context) {
    return _buildModal(
      context,
      title: 'HOW TO PLAY',
      content: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildInstructionSection(
            'Game Objective',
            'The Chaser (Red) must catch the Runner (Blue) before time runs out. If the Runner survives until the timer ends, they win!',
          ),
          const SizedBox(height: 20),
          _buildInstructionSection(
            'Controls',
            '• Player 1 (Chaser): WASD keys to move\n• Player 2 (Runner): Arrow keys to move',
          ),
          const SizedBox(height: 20),
          _buildInstructionSection(
            'Power-ups',
            '• Speed Boost: Temporarily increases movement speed\n• Shield: Makes the Runner immune to being caught\n• Freeze: Temporarily stops the opponent',
          ),
          const SizedBox(height: 20),
          _buildInstructionSection(
            'Game Modes',
            '• Classic: Standard chase with a time limit\n• Time Attack: Runner must collect time bonuses to survive\n• Survival: Multiple rounds with increasing difficulty',
          ),
        ],
      ),
      onClose: onCloseModal,
    );
  }
  
  Widget _buildSettingsModal(BuildContext context) {
    // Local state for settings
    int localDuration = gameDuration;
    double localSpeed = playerSpeed;
    bool localObstacles = enableObstacles;
    bool localPowerups = enablePowerups;
    String localGameMode = gameMode;
    
    return StatefulBuilder(
      builder: (context, setState) {
        return _buildModal(
          context,
          title: 'GAME SETTINGS',
          content: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Game Duration',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
              Slider(
                value: localDuration.toDouble(),
                min: 30,
                max: 120,
                divisions: 6,
                label: '$localDuration seconds',
                onChanged: (value) {
                  setState(() {
                    localDuration = value.round();
                  });
                },
              ),
              const SizedBox(height: 20),
              
              const Text(
                'Player Speed',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
              Slider(
                value: localSpeed,
                min: 3,
                max: 8,
                divisions: 5,
                label: localSpeed.toStringAsFixed(1),
                onChanged: (value) {
                  setState(() {
                    localSpeed = value;
                  });
                },
              ),
              const SizedBox(height: 20),
              
              Row(
                children: [
                  Expanded(
                    child: SwitchListTile(
                      title: const Text('Obstacles'),
                      value: localObstacles,
                      onChanged: (value) {
                        setState(() {
                          localObstacles = value;
                        });
                      },
                    ),
                  ),
                  Expanded(
                    child: SwitchListTile(
                      title: const Text('Power-ups'),
                      value: localPowerups,
                      onChanged: (value) {
                        setState(() {
                          localPowerups = value;
                        });
                      },
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              
              const Text(
                'Game Mode',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
              const SizedBox(height: 10),
              
              Row(
                children: [
                  _buildGameModeButton(
                    'Classic',
                    'classic',
                    localGameMode,
                    () {
                      setState(() {
                        localGameMode = 'classic';
                      });
                    },
                  ),
                  const SizedBox(width: 10),
                  _buildGameModeButton(
                    'Time Attack',
                    'timeAttack',
                    localGameMode,
                    () {
                      setState(() {
                        localGameMode = 'timeAttack';
                      });
                    },
                  ),
                  const SizedBox(width: 10),
                  _buildGameModeButton(
                    'Survival',
                    'survival',
                    localGameMode,
                    () {
                      setState(() {
                        localGameMode = 'survival';
                      });
                    },
                  ),
                ],
              ),
              
              const SizedBox(height: 30),
              
              Center(
                child: ElevatedButton(
                  onPressed: () {
                    onSaveSettings(
                      localDuration,
                      localSpeed,
                      localObstacles,
                      localPowerups,
                      localGameMode,
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.indigo.shade700,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                  ),
                  child: const Text(
                    'SAVE SETTINGS',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1,
                    ),
                  ),
                ),
              ),
            ],
          ),
          onClose: onCloseModal,
        );
      },
    );
  }
  
  Widget _buildGameModeButton(String label, String value, String currentMode, VoidCallback onPressed) {
    final isSelected = value == currentMode;
    
    return Expanded(
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: isSelected ? Colors.indigo.shade700 : Colors.grey.shade200,
          foregroundColor: isSelected ? Colors.white : Colors.black87,
          elevation: isSelected ? 5 : 0,
          padding: const EdgeInsets.symmetric(vertical: 12),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
          ),
        ),
      ),
    );
  }
  
  Widget _buildInstructionSection(String title, String content) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 18,
            color: Colors.indigo,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          content,
          style: const TextStyle(
            fontSize: 14,
            height: 1.5,
          ),
        ),
      ],
    );
  }
  
  Widget _buildModal(
    BuildContext context, {
    required String title,
    required Widget content,
    required VoidCallback onClose,
  }) {
    return Container(
      width: double.infinity,
      height: double.infinity,
      color: Colors.black54,
      child: Center(
        child: Container(
          width: min(600, MediaQuery.of(context).size.width * 0.9),
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black26,
                blurRadius: 10,
                spreadRadius: 2,
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.indigo,
                    ),
                  ),
                  IconButton(
                    onPressed: onClose,
                    icon: const Icon(Icons.close),
                    color: Colors.grey,
                  ),
                ],
              ),
              const Divider(height: 30),
              ConstrainedBox(
                constraints: BoxConstraints(
                  maxHeight: MediaQuery.of(context).size.height * 0.6,
                ),
                child: SingleChildScrollView(
                  child: content,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class ChaseGameScreen extends StatefulWidget {
  final VoidCallback onBackToTitle;
  final int gameDuration;
  final double playerSpeed;
  final bool enableObstacles;
  final bool enablePowerups;
  final String gameMode;

  const ChaseGameScreen({
    super.key,
    required this.onBackToTitle,
    required this.gameDuration,
    required this.playerSpeed,
    required this.enableObstacles,
    required this.enablePowerups,
    required this.gameMode,
  });

  @override
  State<ChaseGameScreen> createState() => _ChaseGameScreenState();
}

class _ChaseGameScreenState extends State<ChaseGameScreen> with TickerProviderStateMixin {
  // Game state
  bool isGameRunning = false;
  bool isGameOver = false;
  bool isPaused = false;
  bool isCountdown = false;
  int countdownValue = 3;
  String winner = '';
  late int timeLeft;
  late Timer gameTimer;
  late Timer animationTimer;

  // Player positions and sizes
  double player1X = 100;
  double player1Y = 100;
  double player2X = 400;
  double player2Y = 400;
  final double playerSize = 50;
  late double playerSpeed;
  
  // Player stats
  double player1Speed = 0;
  double player2Speed = 0;
  bool player1Shielded = false;
  bool player2Shielded = false;
  bool player1Frozen = false;
  bool player2Frozen = false;
  
  // Power-up effects duration
  int speedBoostDuration = 5;
  int shieldDuration = 3;
  int freezeDuration = 2;
  
  // Active power-ups
  List<PowerUp> powerUps = [];
  
  // Obstacles
  List<Obstacle> obstacles = [];
  
  // Game arena size
  late double arenaWidth;
  late double arenaHeight;
  
  // Animation controllers
  late AnimationController player1PulseController;
  late AnimationController player2PulseController;
  late AnimationController countdownController;
  
  // Game stats
  int nearMisses = 0;
  int powerUpsCollected = 0;
  int distanceTraveled = 0;
  
  // Key states for both players
  final Set<LogicalKeyboardKey> player1Keys = {};
  final Set<LogicalKeyboardKey> player2Keys = {};

  // Focus node for keyboard input
  final FocusNode _focusNode = FocusNode();
  
  // Random generator
  final Random random = Random();

  @override
  void initState() {
    super.initState();
    
    // Initialize game settings
    timeLeft = widget.gameDuration;
    playerSpeed = widget.playerSpeed;
    
    // Initialize animation controllers
    player1PulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat(reverse: true);
    
    player2PulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat(reverse: true);
    
    countdownController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    
    // Start countdown to game
    startCountdown();
  }

  @override
  void dispose() {
    if (isGameRunning) {
      gameTimer.cancel();
    }
    if (isCountdown) {
      animationTimer.cancel();
    }
    player1PulseController.dispose();
    player2PulseController.dispose();
    countdownController.dispose();
    _focusNode.dispose();
    super.dispose();
  }
  
  void startCountdown() {
    setState(() {
      isCountdown = true;
      countdownValue = 3;
    });
    
    countdownController.forward(from: 0.0);
    
    animationTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        countdownValue--;
        countdownController.forward(from: 0.0);
      });
      
      if (countdownValue <= 0) {
        timer.cancel();
        setState(() {
          isCountdown = false;
        });
        startGame();
      }
    });
  }

  void startGame() {
    // Calculate arena size (80% of screen width, 70% of screen height)
    arenaWidth = MediaQuery.of(context).size.width * 0.8;
    arenaHeight = MediaQuery.of(context).size.height * 0.7;
    
    // Generate obstacles if enabled
    if (widget.enableObstacles) {
      generateObstacles();
    }
    
    setState(() {
      // Reset positions
      player1X = arenaWidth * 0.2;
      player1Y = arenaHeight * 0.5;
      player2X = arenaWidth * 0.8;
      player2Y = arenaHeight * 0.5;
      
      // Reset player stats
      player1Speed = playerSpeed;
      player2Speed = playerSpeed;
      player1Shielded = false;
      player2Shielded = false;
      player1Frozen = false;
      player2Frozen = false;
      
      // Reset game state
      isGameRunning = true;
      isGameOver = false;
      isPaused = false;
      winner = '';
      timeLeft = widget.gameDuration;
      
      // Reset game stats
      nearMisses = 0;
      powerUpsCollected = 0;
      distanceTraveled = 0;
      
      // Start the game timer
      gameTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
        if (!isPaused) {
          setState(() {
            if (timeLeft > 0) {
              timeLeft--;
              
              // Generate power-ups randomly if enabled
              if (widget.enablePowerups && random.nextDouble() < 0.1) {
                generatePowerUp();
              }
              
              // Update game stats
              distanceTraveled += 10;
            } else {
              // Time's up, runner (player 2) wins
              endGame('Runner (Blue)');
            }
          });
        }
      });
    });
  }
  
  void generateObstacles() {
    obstacles.clear();
    
    // Number of obstacles based on arena size
    final obstacleCount = (arenaWidth * arenaHeight / 40000).round().clamp(3, 8);
    
    for (int i = 0; i < obstacleCount; i++) {
      // Ensure obstacles don't spawn too close to players
      double obstacleX;
      double obstacleY;
      bool validPosition = false;
      
      while (!validPosition) {
        obstacleX = random.nextDouble() * (arenaWidth - 60);
        obstacleY = random.nextDouble() * (arenaHeight - 60);
        
        // Check distance from players' starting positions
        final distFromPlayer1 = sqrt(pow(obstacleX - player1X, 2) + pow(obstacleY - player1Y, 2));
        final distFromPlayer2 = sqrt(pow(obstacleX - player2X, 2) + pow(obstacleY - player2Y, 2));
        
        if (distFromPlayer1 > 100 && distFromPlayer2 > 100) {
          validPosition = true;
          
          // Random obstacle size
          final width = random.nextInt(60) + 40.0;
          final height = random.nextInt(60) + 40.0;
          
          obstacles.add(
            Obstacle(
              x: obstacleX,
              y: obstacleY,
              width: width,
              height: height,
            ),
          );
        }
      }
    }
  }
  
  void generatePowerUp() {
    if (powerUps.length >= 3) return; // Limit number of active power-ups
    
    // Random position within arena
    double powerUpX;
    double powerUpY;
    bool validPosition = false;
    
    while (!validPosition) {
      powerUpX = random.nextDouble() * (arenaWidth - 30);
      powerUpY = random.nextDouble() * (arenaHeight - 30);
      
      // Check if not colliding with obstacles
      bool collidesWithObstacle = false;
      for (final obstacle in obstacles) {
        if (powerUpX < obstacle.x + obstacle.width &&
            powerUpX + 30 > obstacle.x &&
            powerUpY < obstacle.y + obstacle.height &&
            powerUpY + 30 > obstacle.y) {
          collidesWithObstacle = true;
          break;
        }
      }
      
      if (!collidesWithObstacle) {
        validPosition = true;
        
        // Random power-up type
        final powerUpType = PowerUpType.values[random.nextInt(PowerUpType.values.length)];
        
        powerUps.add(
          PowerUp(
            x: powerUpX,
            y: powerUpY,
            type: powerUpType,
          ),
        );
      }
    }
  }
  
  void collectPowerUp(PowerUp powerUp, bool isPlayer1) {
    setState(() {
      powerUps.remove(powerUp);
      powerUpsCollected++;
      
      switch (powerUp.type) {
        case PowerUpType.speedBoost:
          if (isPlayer1) {
            player1Speed = playerSpeed * 1.5;
            Future.delayed(Duration(seconds: speedBoostDuration), () {
              if (mounted) {
                setState(() {
                  player1Speed = playerSpeed;
                });
              }
            });
          } else {
            player2Speed = playerSpeed * 1.5;
            Future.delayed(Duration(seconds: speedBoostDuration), () {
              if (mounted) {
                setState(() {
                  player2Speed = playerSpeed;
                });
              }
            });
          }
          break;
        case PowerUpType.shield:
          if (isPlayer1) {
            player1Shielded = true;
            Future.delayed(Duration(seconds: shieldDuration), () {
              if (mounted) {
                setState(() {
                  player1Shielded = false;
                });
              }
            });
          } else {
            player2Shielded = true;
            Future.delayed(Duration(seconds: shieldDuration), () {
              if (mounted) {
                setState(() {
                  player2Shielded = false;
                });
              }
            });
          }
          break;
        case PowerUpType.freeze:
          if (isPlayer1) {
            player2Frozen = true;
            Future.delayed(Duration(seconds: freezeDuration), () {
              if (mounted) {
                setState(() {
                  player2Frozen = false;
                });
              }
            });
          } else {
            player1Frozen = true;
            Future.delayed(Duration(seconds: freezeDuration), () {
              if (mounted) {
                setState(() {
                  player1Frozen = false;
                });
              }
            });
          }
          break;
      }
    });
  }

  void endGame(String winnerName) {
    setState(() {
      isGameRunning = false;
      isGameOver = true;
      winner = winnerName;
      gameTimer.cancel();
    });
  }
  
  void togglePause() {
    setState(() {
      isPaused = !isPaused;
    });
  }

  void updatePlayerPositions() {
    if (!isGameRunning || isPaused) return;

    // Calculate previous positions for distance calculation
    final prevPlayer1X = player1X;
    final prevPlayer1Y = player1Y;
    final prevPlayer2X = player2X;
    final prevPlayer2Y = player2Y;

    // Update Player 1 position (Chaser - Red) if not frozen
    if (!player1Frozen) {
      if (player1Keys.contains(LogicalKeyboardKey.keyW)) {
        player1Y = max(0, player1Y - player1Speed);
      }
      if (player1Keys.contains(LogicalKeyboardKey.keyS)) {
        player1Y = min(arenaHeight - playerSize, player1Y + player1Speed);
      }
      if (player1Keys.contains(LogicalKeyboardKey.keyA)) {
        player1X = max(0, player1X - player1Speed);
      }
      if (player1Keys.contains(LogicalKeyboardKey.keyD)) {
        player1X = min(arenaWidth - playerSize, player1X + player1Speed);
      }
    }

    // Update Player 2 position (Runner - Blue) if not frozen
    if (!player2Frozen) {
      if (player2Keys.contains(LogicalKeyboardKey.arrowUp)) {
        player2Y = max(0, player2Y - player2Speed);
      }
      if (player2Keys.contains(LogicalKeyboardKey.arrowDown)) {
        player2Y = min(arenaHeight - playerSize, player2Y + player2Speed);
      }
      if (player2Keys.contains(LogicalKeyboardKey.arrowLeft)) {
        player2X = max(0, player2X - player2Speed);
      }
      if (player2Keys.contains(LogicalKeyboardKey.arrowRight)) {
        player2X = min(arenaWidth - playerSize, player2X + player2Speed);
      }
    }
    
    // Check for collision with obstacles
    for (final obstacle in obstacles) {
      // Player 1 collision with obstacle
      if (player1X < obstacle.x + obstacle.width &&
          player1X + playerSize > obstacle.x &&
          player1Y < obstacle.y + obstacle.height &&
          player1Y + playerSize > obstacle.y) {
        // Revert to previous position
        player1X = prevPlayer1X;
        player1Y = prevPlayer1Y;
      }
      
      // Player 2 collision with obstacle
      if (player2X < obstacle.x + obstacle.width &&
          player2X + playerSize > obstacle.x &&
          player2Y < obstacle.y + obstacle.height &&
          player2Y + playerSize > obstacle.y) {
        // Revert to previous position
        player2X = prevPlayer2X;
        player2Y = prevPlayer2Y;
      }
    }
    
    // Check for power-up collection
    for (final powerUp in List.from(powerUps)) {
      // Player 1 collects power-up
      if (player1X < powerUp.x + 30 &&
          player1X + playerSize > powerUp.x &&
          player1Y < powerUp.y + 30 &&
          player1Y + playerSize > powerUp.y) {
        collectPowerUp(powerUp, true);
      }
      
      // Player 2 collects power-up
      if (player2X < powerUp.x + 30 &&
          player2X + playerSize > powerUp.x &&
          player2Y < powerUp.y + 30 &&
          player2Y + playerSize > powerUp.y) {
        collectPowerUp(powerUp, false);
      }
    }

    // Check for player collision (chaser catches runner)
    if (isColliding()) {
      // If runner has shield, don't end game
      if (!player2Shielded) {
        endGame('Chaser (Red)');
      }
    } else {
      // Check for near miss (within 30 pixels)
      final distance = sqrt(pow(player1X - player2X, 2) + pow(player1Y - player2Y, 2));
      if (distance < playerSize + 30 && distance > playerSize) {
        nearMisses++;
      }
    }
  }

  bool isColliding() {
    // Collision detection using bounding boxes
    return (player1X < player2X + playerSize &&
        player1X + playerSize > player2X &&
        player1Y < player2Y + playerSize &&
        player1Y + playerSize > player2Y);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Colors.grey.shade900,
              Colors.grey.shade800,
              Colors.grey.shade700,
            ],
          ),
        ),
        child: KeyboardListener(
          focusNode: _focusNode,
          autofocus: true,
          onKeyEvent: (KeyEvent event) {
            if (event is KeyDownEvent) {
              setState(() {
                // Player 1 controls (WASD)
                if (event.logicalKey == LogicalKeyboardKey.keyW ||
                    event.logicalKey == LogicalKeyboardKey.keyA ||
                    event.logicalKey == LogicalKeyboardKey.keyS ||
                    event.logicalKey == LogicalKeyboardKey.keyD) {
                  player1Keys.add(event.logicalKey);
                }
                
                // Player 2 controls (Arrow keys)
                if (event.logicalKey == LogicalKeyboardKey.arrowUp ||
                    event.logicalKey == LogicalKeyboardKey.arrowDown ||
                    event.logicalKey == LogicalKeyboardKey.arrowLeft ||
                    event.logicalKey == LogicalKeyboardKey.arrowRight) {
                  player2Keys.add(event.logicalKey);
                }
                
                // Pause game with Escape key
                if (event.logicalKey == LogicalKeyboardKey.escape && isGameRunning) {
                  togglePause();
                }
              });
            } else if (event is KeyUpEvent) {
              setState(() {
                // Player 1 controls (WASD)
                if (event.logicalKey == LogicalKeyboardKey.keyW ||
                    event.logicalKey == LogicalKeyboardKey.keyA ||
                    event.logicalKey == LogicalKeyboardKey.keyS ||
                    event.logicalKey == LogicalKeyboardKey.keyD) {
                  player1Keys.remove(event.logicalKey);
                }
                
                // Player 2 controls (Arrow keys)
                if (event.logicalKey == LogicalKeyboardKey.arrowUp ||
                    event.logicalKey == LogicalKeyboardKey.arrowDown ||
                    event.logicalKey == LogicalKeyboardKey.arrowLeft ||
                    event.logicalKey == LogicalKeyboardKey.arrowRight) {
                  player2Keys.remove(event.logicalKey);
                }
              });
            }
            
            if (isGameRunning && !isPaused) {
              updatePlayerPositions();
            }
          },
          child: Stack(
            children: [
              // Game header
              Positioned(
                top: 20,
                left: 0,
                right: 0,
                child: _buildGameHeader(),
              ),
              
              // Game arena
              Center(
                child: Container(
                  width: arenaWidth,
                  height: arenaHeight,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade200,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black26,
                        blurRadius: 10,
                        spreadRadius: 2,
                      ),
                    ],
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(20),
                    child: Stack(
                      children: [
                        // Arena grid pattern
                        ...List.generate(20, (i) => 
                          Positioned(
                            left: 0,
                            top: i * (arenaHeight / 20),
                            child: Container(
                              width: arenaWidth,
                              height: 1,
                              color: Colors.grey.shade300,
                            ),
                          ),
                        ),
                        ...List.generate(20, (i) => 
                          Positioned(
                            left: i * (arenaWidth / 20),
                            top: 0,
                            child: Container(
                              width: 1,
                              height: arenaHeight,
                              color: Colors.grey.shade300,
                            ),
                          ),
                        ),
                        
                        // Obstacles
                        if (widget.enableObstacles)
                          ...obstacles.map((obstacle) => 
                            Positioned(
                              left: obstacle.x,
                              top: obstacle.y,
                              child: Container(
                                width: obstacle.width,
                                height: obstacle.height,
                                decoration: BoxDecoration(
                                  color: Colors.grey.shade800,
                                  borderRadius: BorderRadius.circular(8),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black26,
                                      blurRadius: 4,
                                      spreadRadius: 1,
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        
                        // Power-ups
                        ...powerUps.map((powerUp) => 
                          Positioned(
                            left: powerUp.x,
                            top: powerUp.y,
                            child: Container(
                              width: 30,
                              height: 30,
                              decoration: BoxDecoration(
                                color: _getPowerUpColor(powerUp.type),
                                shape: BoxShape.circle,
                                boxShadow: [
                                  BoxShadow(
                                    color: _getPowerUpColor(powerUp.type).withOpacity(0.5),
                                    blurRadius: 10,
                                    spreadRadius: 2,
                                  ),
                                ],
                              ),
                              child: Center(
                                child: Icon(
                                  _getPowerUpIcon(powerUp.type),
                                  color: Colors.white,
                                  size: 16,
                                ),
                              ),
                            ),
                          ),
                        ),
                        
                        // Player 1 (Chaser - Red)
                        Positioned(
                          left: player1X,
                          top: player1Y,
                          child: AnimatedBuilder(
                            animation: player1PulseController,
                            builder: (context, child) {
                              return Container(
                                width: playerSize,
                                height: playerSize,
                                decoration: BoxDecoration(
                                  color: Colors.red.shade500,
                                  shape: BoxShape.circle,
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.red.shade700.withOpacity(0.7),
                                      blurRadius: 10 + player1PulseController.value * 5,
                                      spreadRadius: 2 + player1PulseController.value * 2,
                                    ),
                                  ],
                                  gradient: LinearGradient(
                                    begin: Alignment.topLeft,
                                    end: Alignment.bottomRight,
                                    colors: [
                                      Colors.red.shade400,
                                      Colors.red.shade700,
                                    ],
                                  ),
                                ),
                                child: Stack(
                                  children: [
                                    Center(
                                      child: const Text(
                                        '1',
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontWeight: FontWeight.bold,
                                          fontSize: 18,
                                        ),
                                      ),
                                    ),
                                    if (player1Frozen)
                                      Container(
                                        width: playerSize,
                                        height: playerSize,
                                        decoration: BoxDecoration(
                                          color: Colors.blue.withOpacity(0.5),
                                          shape: BoxShape.circle,
                                        ),
                                        child: const Center(
                                          child: Icon(
                                            Icons.ac_unit,
                                            color: Colors.white,
                                            size: 24,
                                          ),
                                        ),
                                      ),
                                    if (player1Shielded)
                                      Container(
                                        width: playerSize,
                                        height: playerSize,
                                        decoration: BoxDecoration(
                                          color: Colors.transparent,
                                          shape: BoxShape.circle,
                                          border: Border.all(
                                            color: Colors.yellow.shade500,
                                            width: 3,
                                          ),
                                        ),
                                      ),
                                    if (player1Speed > playerSpeed)
                                      Positioned(
                                        right: 0,
                                        bottom: 0,
                                        child: Container(
                                          width: 20,
                                          height: 20,
                                          decoration: BoxDecoration(
                                            color: Colors.green,
                                            shape: BoxShape.circle,
                                          ),
                                          child: const Center(
                                            child: Icon(
                                              Icons.bolt,
                                              color: Colors.white,
                                              size: 12,
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
                        
                        // Player 2 (Runner - Blue)
                        Positioned(
                          left: player2X,
                          top: player2Y,
                          child: AnimatedBuilder(
                            animation: player2PulseController,
                            builder: (context, child) {
                              return Container(
                                width: playerSize,
                                height: playerSize,
                                decoration: BoxDecoration(
                                  color: Colors.blue.shade500,
                                  shape: BoxShape.circle,
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.blue.shade700.withOpacity(0.7),
                                      blurRadius: 10 + player2PulseController.value * 5,
                                      spreadRadius: 2 + player2PulseController.value * 2,
                                    ),
                                  ],
                                  gradient: LinearGradient(
                                    begin: Alignment.topLeft,
                                    end: Alignment.bottomRight,
                                    colors: [
                                      Colors.blue.shade400,
                                      Colors.blue.shade700,
                                    ],
                                  ),
                                ),
                                child: Stack(
                                  children: [
                                    Center(
                                      child: const Text(
                                        '2',
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontWeight: FontWeight.bold,
                                          fontSize: 18,
                                        ),
                                      ),
                                    ),
                                    if (player2Frozen)
                                      Container(
                                        width: playerSize,
                                        height: playerSize,
                                        decoration: BoxDecoration(
                                          color: Colors.blue.withOpacity(0.5),
                                          shape: BoxShape.circle,
                                        ),
                                        child: const Center(
                                          child: Icon(
                                            Icons.ac_unit,
                                            color: Colors.white,
                                            size: 24,
                                          ),
                                        ),
                                      ),
                                    if (player2Shielded)
                                      Container(
                                        width: playerSize,
                                        height: playerSize,
                                        decoration: BoxDecoration(
                                          color: Colors.transparent,
                                          shape: BoxShape.circle,
                                          border: Border.all(
                                            color: Colors.yellow.shade500,
                                            width: 3,
                                          ),
                                        ),
                                      ),
                                    if (player2Speed > playerSpeed)
                                      Positioned(
                                        right: 0,
                                        bottom: 0,
                                        child: Container(
                                          width: 20,
                                          height: 20,
                                          decoration: BoxDecoration(
                                            color: Colors.green,
                                            shape: BoxShape.circle,
                                          ),
                                          child: const Center(
                                            child: Icon(
                                              Icons.bolt,
                                              color: Colors.white,
                                              size: 12,
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
                    ),
                  ),
                ),
              ),
              
              // Game controls
              Positioned(
                bottom: 20,
                left: 0,
                right: 0,
                child: _buildGameControls(),
              ),
              
              // Countdown overlay
              if (isCountdown)
                Container(
                  width: double.infinity,
                  height: double.infinity,
                  color: Colors.black54,
                  child: Center(
                    child: AnimatedBuilder(
                      animation: countdownController,
                      builder: (context, child) {
                        return Transform.scale(
                          scale: 1.0 + (1.0 - countdownController.value) * 0.5,
                          child: Opacity(
                            opacity: 1.0 - countdownController.value,
                            child: Text(
                              countdownValue.toString(),
                              style: TextStyle(
                                fontSize: 120,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ),
              
              // Pause overlay
              if (isPaused)
                Container(
                  width: double.infinity,
                  height: double.infinity,
                  color: Colors.black54,
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text(
                          'GAME PAUSED',
                          style: TextStyle(
                            fontSize: 36,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                            letterSpacing: 2,
                          ),
                        ),
                        const SizedBox(height: 30),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            _buildPauseMenuButton(
                              'RESUME',
                              Icons.play_arrow,
                              togglePause,
                            ),
                            const SizedBox(width: 20),
                            _buildPauseMenuButton(
                              'QUIT',
                              Icons.exit_to_app,
                              widget.onBackToTitle,
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              
              // Game over overlay
              if (isGameOver)
                Container(
                  width: double.infinity,
                  height: double.infinity,
                  color: Colors.black54,
                  child: Center(
                    child: Container(
                      width: min(500, MediaQuery.of(context).size.width * 0.9),
                      padding: const EdgeInsets.all(30),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black26,
                            blurRadius: 10,
                            spreadRadius: 2,
                          ),
                        ],
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            'GAME OVER',
                            style: TextStyle(
                              fontSize: 36,
                              fontWeight: FontWeight.bold,
                              color: winner.contains('Red') ? Colors.red.shade700 : Colors.blue.shade700,
                              letterSpacing: 2,
                            ),
                          ),
                          const SizedBox(height: 20),
                          Text(
                            '$winner WINS!',
                            style: TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              color: winner.contains('Red') ? Colors.red.shade700 : Colors.blue.shade700,
                            ),
                          ),
                          const SizedBox(height: 30),
                          
                          // Game stats
                          Container(
                            padding: const EdgeInsets.all(15),
                            decoration: BoxDecoration(
                              color: Colors.grey.shade100,
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Column(
                              children: [
                                _buildGameStat('Time Played', '${widget.gameDuration - timeLeft} seconds'),
                                _buildGameStat('Near Misses', '$nearMisses'),
                                _buildGameStat('Power-ups Collected', '$powerUpsCollected'),
                                _buildGameStat('Distance Traveled', '${distanceTraveled}m'),
                              ],
                            ),
                          ),
                          
                          const SizedBox(height: 30),
                          
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              _buildGameOverButton(
                                'PLAY AGAIN',
                                Icons.replay,
                                startCountdown,
                                Colors.green.shade600,
                              ),
                              const SizedBox(width: 20),
                              _buildGameOverButton(
                                'MAIN MENU',
                                Icons.home,
                                widget.onBackToTitle,
                                Colors.blue.shade600,
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
  
  Widget _buildGameHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(30),
            boxShadow: [
              BoxShadow(
                color: Colors.black26,
                blurRadius: 10,
                spreadRadius: 2,
              ),
            ],
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Player 1 indicator
              Container(
                width: 20,
                height: 20,
                decoration: BoxDecoration(
                  color: Colors.red.shade500,
                  shape: BoxShape.circle,
                ),
                child: const Center(
                  child: Text(
                    '1',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 10,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              const Text(
                'Chaser',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
              ),
              
              const SizedBox(width: 20),
              
              // Timer
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 5),
                decoration: BoxDecoration(
                  color: timeLeft <= 10 ? Colors.red.shade100 : Colors.grey.shade100,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.timer,
                      size: 18,
                      color: timeLeft <= 10 ? Colors.red.shade700 : Colors.grey.shade700,
                    ),
                    const SizedBox(width: 5),
                    Text(
                      '$timeLeft',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                        color: timeLeft <= 10 ? Colors.red.shade700 : Colors.grey.shade700,
                      ),
                    ),
                  ],
                ),
              ),
              
              const SizedBox(width: 20),
              
              // Player 2 indicator
              const Text(
                'Runner',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
              ),
              const SizedBox(width: 8),
              Container(
                width: 20,
                height: 20,
                decoration: BoxDecoration(
                  color: Colors.blue.shade500,
                  shape: BoxShape.circle,
                ),
                child: const Center(
                  child: Text(
                    '2',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 10,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
        
        const SizedBox(width: 15),
        
        // Pause button
        if (isGameRunning && !isGameOver && !isCountdown)
          IconButton(
            onPressed: togglePause,
            icon: Icon(
              isPaused ? Icons.play_arrow : Icons.pause,
              color: Colors.white,
            ),
            style: IconButton.styleFrom(
              backgroundColor: Colors.black54,
              padding: const EdgeInsets.all(8),
            ),
          ),
      ],
    );
  }
  
  Widget _buildGameControls() {
    return Center(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(10),
          boxShadow: [
            BoxShadow(
              color: Colors.black26,
              blurRadius: 10,
              spreadRadius: 2,
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'CONTROLS',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 12,
                color: Colors.grey,
                letterSpacing: 1,
              ),
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                _buildControlInfo(
                  'Player 1 (Red)',
                  'WASD Keys',
                  Colors.red.shade100,
                  Colors.red.shade700,
                ),
                const SizedBox(width: 20),
                _buildControlInfo(
                  'Player 2 (Blue)',
                  'Arrow Keys',
                  Colors.blue.shade100,
                  Colors.blue.shade700,
                ),
                const SizedBox(width: 20),
                _buildControlInfo(
                  'Pause Game',
                  'ESC Key',
                  Colors.grey.shade100,
                  Colors.grey.shade700,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildControlInfo(String player, String keys, Color bgColor, Color textColor) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        children: [
          Text(
            player,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 12,
              color: textColor,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            keys,
            style: TextStyle(
              fontSize: 12,
              color: textColor,
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildPauseMenuButton(String label, IconData icon, VoidCallback onPressed) {
    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.white,
        foregroundColor: Colors.black87,
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(30),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon),
          const SizedBox(width: 8),
          Text(
            label,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildGameOverButton(String label, IconData icon, VoidCallback onPressed, Color color) {
    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: color,
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(30),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon),
          const SizedBox(width: 8),
          Text(
            label,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildGameStat(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              color: Colors.grey.shade700,
              fontSize: 14,
            ),
          ),
          Text(
            value,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }
  
  Color _getPowerUpColor(PowerUpType type) {
    switch (type) {
      case PowerUpType.speedBoost:
        return Colors.green;
      case PowerUpType.shield:
        return Colors.yellow.shade600;
      case PowerUpType.freeze:
        return Colors.lightBlue;
    }
  }
  
  IconData _getPowerUpIcon(PowerUpType type) {
    switch (type) {
      case PowerUpType.speedBoost:
        return Icons.bolt;
      case PowerUpType.shield:
        return Icons.shield;
      case PowerUpType.freeze:
        return Icons.ac_unit;
    }
  }
}

// Game models
class Obstacle {
  final double x;
  final double y;
  final double width;
  final double height;
  
  Obstacle({
    required this.x,
    required this.y,
    required this.width,
    required this.height,
  });
}

enum PowerUpType {
  speedBoost,
  shield,
  freeze,
}

class PowerUp {
  final double x;
  final double y;
  final PowerUpType type;
  
  PowerUp({
    required this.x,
    required this.y,
    required this.type,
  });
}

