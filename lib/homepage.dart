import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';
import 'pixel.dart';
import 'player.dart';
import 'path.dart';
import 'ghost.dart'; // Ghost sınıfını içeriye dahil et

class HomePage extends StatefulWidget {
  HomePage({Key? key}) : super(key: key);

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  static int numberInRow = 11;
  int numberOfSquares = numberInRow * 17;
  int player = numberInRow * 15 + 1;
  int ghost = -1;
  List<int> barriers= [
    0,1,2,3,4,5,6,7,8,9,10,11,22,33,44,55,66,77,99,110,121,132,143,154,165,176,177,178,179,180,181,182,183,184,185,186,175,164,153,142,131,120,109,87,76,65,54,43,32,21,24,35,46,57,26,37,38,39,28,30,41,52,63,59,61,70,72,81,80,79,78,83,84,85,86,100,101,102,103,114,125,127,116,105,106,107,108,123,134,145,156,147,158,148,149,160,129,140,151,162,
  ];
  List<int> food = [];
  String direction = "right";
  bool preGame = true;
  bool mouthClosed = false;
  int score = 0;

  void startGame() {

      moveGhost();

    getFood();

    setState(() {
      player = numberInRow * 15 + 1;
      score = 0;
    });

    Duration duration = Duration(milliseconds: 120);
    Timer.periodic(duration, (timer) {
      setState(() {
        mouthClosed = !mouthClosed;
      });

      if (food.contains(player)) {
        food.remove(player);
        score++;
      }
      if (player == ghost) {
        gameOver();
      }

      switch (direction) {
        case "left":
          moveLeft();
          break;
        case "right":
          moveRight();
          break;
        case "up":
          moveUp();
          break;
        case "down":
          moveDown();
          break;
      }
    });
  }
  void moveGhost() {
    setState(() {
      Random random = Random();
      int newGhostPosition;
      int attempts = 0;  // Add a counter for attempts

      do {
        newGhostPosition = random.nextInt(numberOfSquares);
        attempts++;  // Increment attempts
        if (attempts > 100) {
          print("Exceeded 100 attempts. Stopping loop.");
          break;  // Break the loop if attempts exceed 100
        }
      } while (barriers.contains(newGhostPosition));

      int direction = random.nextInt(4); // 0, 1, 2, 3

      // Yeni konum belirleme
      switch (direction) {
        case 0: // Yukarı
          if (!barriers.contains(newGhostPosition - numberInRow)) {
            newGhostPosition -= numberInRow;
          }
          break;
        case 1: // Aşağı
          if (!barriers.contains(newGhostPosition + numberInRow)) {
            newGhostPosition += numberInRow;
          }
          break;
        case 2: // Sol
          if (!barriers.contains(newGhostPosition - 1)) {
            newGhostPosition -= 1;
          }
          break;
        case 3: // Sağ
          if (!barriers.contains(newGhostPosition + 1)) {
            newGhostPosition += 1;
          }
          break;
      }

      ghost = newGhostPosition;
    });
    checkGameOver();
  }




  void getFood() {
    for (int i = 0; i <= numberOfSquares; i++) {
      if (barriers.contains(i)) {
        food.add(i);
      }
    }
  }

  void moveLeft() {
    if (!barriers.contains(player - 1)) {
      setState(() {
        player--;
      });
    }
    checkGameOver();
  }

  void moveRight() {
    if (!barriers.contains(player + 1)) {
      setState(() {
        player++;
      });
    }
    checkGameOver();
  }

  void moveUp() {
    if (!barriers.contains(player - numberInRow)) {
      setState(() {
        player -= numberInRow;
      });
    }
    checkGameOver();
  }

  void moveDown() {
    if (!barriers.contains(player + numberInRow)) {
      setState(() {
        player += numberInRow;
      });
    }
    checkGameOver();
  }




  void checkGameOver() {
    if (player == ghost) {
      gameOver();
    }
  }

  void gameOver() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text("Game Over"),
          content: Text("You were caught by the ghost. Your score: $score"),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                resetGame();
              },
              child: Text("Play Again"),
            ),
          ],
        );
      },
    );
  }

  void resetGame() {
    setState(() {
      player = numberInRow * 15 + 1;
      ghost = -1;
      score = 0;
    });
    startGame();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Column(
        children: [
          Expanded(
            flex: 5,
            child: GestureDetector(
              onVerticalDragUpdate: (details) {
                if (details.delta.dy > 0) {
                  direction = "down";
                } else if (details.delta.dy < 0) {
                  direction = "up";
                }
              },
              onHorizontalDragUpdate: (details) {
                if (details.delta.dx > 0) {
                  direction = "right";
                } else if (details.delta.dx < 0) {
                  direction = "left";
                }
              },
              child: Container(
                child: GridView.builder(
                  physics: NeverScrollableScrollPhysics(),
                  itemCount: numberOfSquares,
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: numberInRow,
                  ),
                  itemBuilder: (BuildContext context, int index) {
                    if (mouthClosed) {
                      return Padding(
                        padding: EdgeInsets.all(4),
                        child: Container(
                          decoration: BoxDecoration(
                              color: Colors.yellow, shape: BoxShape.circle),
                        ),
                      );
                    } else if (player == index) {
                      switch (direction) {
                        case "left":
                          return Transform.rotate(
                            angle: pi,
                            child: MyPlayer(),
                          );
                          break;
                        case "right":
                          return MyPlayer();
                          break;
                        case "up":
                          return Transform.rotate(
                            angle: 3 * pi / 2,
                            child: MyPlayer(),
                          );
                          break;
                        case "down":
                          return Transform.rotate(
                            angle: pi / 2,
                            child: MyPlayer(),
                          );
                          break;
                        default:
                          return MyPlayer();
                      }
                    } else if (ghost == index) {
                      return MyGhost();
                    } else if (barriers.contains(index)) {
                      return MyPixel(
                        innerColor: Colors.blue[800],
                        outerColor: Colors.blue[900],
                      );
                    } else {
                      return MyPath(
                        innerColor: Colors.yellow,
                        outerColor: Colors.black,
                      );
                    }
                  },
                ),
              ),
            ),
          ),
          Expanded(
            child: Container(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  Text(
                    "Score:$score",
                    style: TextStyle(color: Colors.white, fontSize: 40),
                  ),
                  GestureDetector(
                    onTap: startGame,
                    child: Text(
                      "P L A Y:",
                      style: TextStyle(color: Colors.white, fontSize: 40),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}



