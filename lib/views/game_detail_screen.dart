import 'dart:convert';
import 'package:battleships/services/auth_service.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:google_fonts/google_fonts.dart';

class GameDetailScreen extends StatefulWidget {
  final int gameId;

  const GameDetailScreen({super.key, required this.gameId});

  @override
  State<GameDetailScreen> createState() => _GameDetailScreenState();
}

class _GameDetailScreenState extends State<GameDetailScreen> {
  late Map<String, dynamic> _gameDetails;
  bool _isLoading = true;
  bool isShotting = false;
  bool _isSubmitting = false;
  String? gridLocation;

  Future<void> _fetchGameDetails() async {
    final String? token = await AuthService().getToken();

    final String apiUrl =
        'https://battleships-app.onrender.com/games/${widget.gameId}';
    try {
      final response = await http.get(
        Uri.parse(apiUrl),
        headers: {'Authorization': 'Bearer $token'},
      );
      if (response.statusCode == 200) {
        setState(() {
          _gameDetails = json.decode(response.body);
          _isLoading = false;
        });
      } else {
        throw Exception('Failed to load game details');
      }
    } catch (error) {
      setState(() {
        _isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error fetching game details: $error')),
      );
    }
  }

  Future<void> _playShot(String coordinate) async {
    final String? token = await AuthService().getToken();

    if (_isSubmitting) return;

    setState(() {
      _isSubmitting = true;
    });

    final String apiUrl =
        'https://battleships-app.onrender.com/games/${widget.gameId}';
    try {
      setState(() {
        isShotting = true;
      });
      final response = await http.put(
        Uri.parse(apiUrl),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: json.encode({'shot': coordinate}),
      );
      setState(() {
        isShotting = false;
      });
      if (response.statusCode == 200) {
        setState(() {
          gridLocation = null;
        });
        final result = json.decode(response.body);
        if (result['sunk_ship'] == true) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(const SnackBar(content: Text('Ship Sunk!')));
          setState(() {
            _gameDetails['sunk'].add(coordinate);
          });
        }
        if (result['sunk_ship'] == false) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(const SnackBar(content: Text('Missed Shot!')));
          setState(() {
            _gameDetails['sunk'].add(coordinate);
          });
        }

        if (result['won'] == true) {
          showDialog(
            context: context,
            builder:
                (context) => AlertDialog(
                  backgroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  title: Text(
                    'Game Over',
                    style: GoogleFonts.pirataOne(
                      fontSize: 24,
                      color: Colors.blue.shade900,
                    ),
                  ),
                  content: Text(
                    'Congratulations! You have won the game.',
                    style: GoogleFonts.roboto(fontSize: 16),
                  ),
                  actions: [
                    TextButton(
                      onPressed: () {
                        Navigator.pop(context);
                        Navigator.pop(context);
                      },
                      child: Text(
                        'OK',
                        style: GoogleFonts.roboto(
                          color: Colors.blue.shade900,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
          );
        } else {
          await _fetchGameDetails();
        }
      } else {
        throw Exception('Failed to play shot');
      }
    } catch (error) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error playing shot: $error')));
    } finally {
      setState(() {
        _isSubmitting = false;
      });
    }
  }

  bool _isCellClickable() {
    return _gameDetails['status'] == 3 &&
        _gameDetails['turn'] == _gameDetails['position'];
  }

  @override
  void initState() {
    super.initState();
    _fetchGameDetails();
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        Navigator.of(
          context,
        ).pushNamedAndRemoveUntil('/game_list', (route) => false);
        return false;
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text(
            'Game #${widget.gameId}',
            style: GoogleFonts.pirataOne(fontSize: 24, color: Colors.white),
          ),
          backgroundColor: Colors.blue.shade900,
        ),
        body: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [Colors.cyan.shade700, Colors.blue.shade900],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
          ),
          child:
              _isLoading
                  ? const Center(
                    child: CircularProgressIndicator(color: Colors.white),
                  )
                  : Column(
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Text(
                          _gameDetails['turn'] == _gameDetails['position']
                              ? 'Your Turn'
                              : 'Opponent\'s Turn',
                          style: GoogleFonts.roboto(
                            fontSize: 20,
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16.0),
                          child: GridView.builder(
                            gridDelegate:
                                const SliverGridDelegateWithFixedCrossAxisCount(
                                  crossAxisCount: 5,
                                  childAspectRatio: 1,
                                  crossAxisSpacing: 8,
                                  mainAxisSpacing: 8,
                                ),
                            itemCount: 25,
                            itemBuilder: (context, index) {
                              String gridPosition = _indexToCoordinate(index);

                              List<Widget> icons = [];

                              if (_gameDetails['ships'].contains(
                                gridPosition,
                              )) {
                                icons.add(
                                  const Icon(
                                    Icons.directions_boat_filled,
                                    color: Colors.green,
                                    size: 32,
                                  ),
                                );
                              }
                              if (_gameDetails['wrecks'].contains(
                                gridPosition,
                              )) {
                                icons.add(
                                  const Icon(
                                    Icons.directions_boat_filled,
                                    color: Colors.red,
                                    size: 32,
                                  ),
                                );
                              }
                              if (_gameDetails['shots'].contains(
                                    gridPosition,
                                  ) &&
                                  !_gameDetails['sunk'].contains(
                                    gridPosition,
                                  )) {
                                icons.add(
                                  const Icon(
                                    Icons.waves,
                                    color: Colors.white,
                                    size: 32,
                                  ),
                                );
                              }
                              if (_gameDetails['sunk'].contains(gridPosition)) {
                                icons.add(
                                  Icon(
                                    Icons.local_fire_department,
                                    color: Colors.orange.shade900,
                                    size: 32,
                                  ),
                                );
                              }

                              return GestureDetector(
                                onTap: () {
                                  if (_isCellClickable() &&
                                      !_gameDetails['shots'].contains(
                                        gridPosition,
                                      ) &&
                                      !_gameDetails['sunk'].contains(
                                        gridPosition,
                                      )) {
                                    setState(() {
                                      gridLocation = gridPosition;
                                    });
                                  } else if (!_isCellClickable()) {
                                    setState(() {
                                      gridLocation = null;
                                    });
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                        content: Text("You cannot play now."),
                                      ),
                                    );
                                  } else {
                                    setState(() {
                                      gridLocation = null;
                                    });
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                        content: Text(
                                          "You already played this location.",
                                        ),
                                      ),
                                    );
                                  }
                                },
                                child: AnimatedContainer(
                                  duration: const Duration(milliseconds: 200),
                                  decoration: BoxDecoration(
                                    color:
                                        gridPosition == gridLocation
                                            ? Colors.yellow.shade700
                                            : Colors.white.withOpacity(0.2),
                                    borderRadius: BorderRadius.circular(8),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.black.withOpacity(0.2),
                                        blurRadius: 4,
                                        offset: const Offset(2, 2),
                                      ),
                                    ],
                                  ),
                                  child: Stack(
                                    alignment: Alignment.center,
                                    children: [
                                      Text(
                                        gridPosition,
                                        style: GoogleFonts.roboto(
                                          color: Colors.white70,
                                          fontSize: 14,
                                        ),
                                      ),
                                      ...icons,
                                    ],
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: ElevatedButton(
                          onPressed:
                              gridLocation != null
                                  ? () => _playShot(gridLocation!)
                                  : null,
                          style: ElevatedButton.styleFrom(
                            backgroundColor:
                                gridLocation == null
                                    ? Colors.grey.shade700
                                    : Colors.white,
                            foregroundColor: Colors.blue.shade900,
                            padding: const EdgeInsets.symmetric(
                              horizontal: 32,
                              vertical: 16,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            elevation: 5,
                          ),
                          child:
                              isShotting
                                  ? const CircularProgressIndicator(
                                    color: Colors.blue,
                                  )
                                  : Text(
                                    'Fire Shot',
                                    style: GoogleFonts.roboto(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
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

  String _indexToCoordinate(int index) {
    String row = String.fromCharCode(65 + index ~/ 5);
    String col = (index % 5 + 1).toString();
    return "$row$col";
  }
}
