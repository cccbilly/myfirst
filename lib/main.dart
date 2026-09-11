import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';

void main() => runApp(const SpaceShooterApp());

class SpaceShooterApp extends StatelessWidget {
  const SpaceShooterApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      home: GameScreen(),
      debugShowCheckedModeBanner: false,
    );
  }
}

class GameScreen extends StatefulWidget {
  const GameScreen({super.key});

  @override
  State<GameScreen> createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen> {
  double playerX = 0; // 玩家飛機位置 (-1.0 到 1.0)
  double enemyX = 0;
  double enemyY = -1.0;
  double bulletX = 0;
  double bulletY = 1.0;
  bool isShooting = false;
  int score = 0;
  Timer? gameTimer;

  @override
  void initState() {
    super.initState();
    startGame();
  }

  void startGame() {
    gameTimer = Timer.periodic(const Duration(milliseconds: 30), (timer) {
      setState(() {
        // 敵人往下掉落
        enemyY += 0.03;
        if (enemyY > 1.0) {
          resetEnemy();
        }

        // 子彈往上飛
        if (isShooting) {
          bulletY -= 0.08;
          if (bulletY < -1.0) {
            isShooting = false;
          }
        }

        // 碰撞偵測 (擊中敵人)
        if (isShooting && (bulletX - enemyX).abs() < 0.2 && (bulletY - enemyY).abs() < 0.1) {
          score += 10;
          isShooting = false;
          resetEnemy();
        }
      });
    });
  }

  void resetEnemy() {
    enemyY = -1.0;
    enemyX = Random().nextDouble() * 1.8 - 0.9; // 隨機 X 位置
  }

  void shoot() {
    if (!isShooting) {
      bulletX = playerX;
      bulletY = 0.7;
      isShooting = true;
    }
  }

  @override
  void dispose() {
    gameTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: GestureDetector(
        onHorizontalDragUpdate: (details) {
          setState(() {
            playerX += details.delta.dx / (MediaQuery.of(context).size.width / 2);
            playerX = playerX.clamp(-0.9, 0.9);
          });
        },
        child: Stack(
          children: [
            // 分數顯示
            Positioned(
              top: 50,
              left: 20,
              child: Text("SCORE: $score", style: const TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold)),
            ),
            // 敵人 (👾)
            Container(
              alignment: Alignment(enemyX, enemyY),
              child: const Text("👾", style: TextStyle(fontSize: 40)),
            ),
            // 子彈 (🔥)
            if (isShooting)
              Container(
                alignment: Alignment(bulletX, bulletY),
                child: const Text("🔥", style: TextStyle(fontSize: 20)),
              ),
            // 玩家飛機 (🚀)
            Container(
              alignment: Alignment(playerX, 0.8),
              child: const Text("🚀", style: TextStyle(fontSize: 50)),
            ),
            // 發射按鈕
            Positioned(
              bottom: 40,
              right: 30,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  shape: const CircleBorder(),
                  padding: const EdgeInsets.all(24),
                  backgroundColor: Colors.redAccent,
                ),
                onPressed: shoot,
                child: const Text("開火", style: TextStyle(fontSize: 18, color: Colors.white)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
