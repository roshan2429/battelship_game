import 'dart:convert';
import 'package:battleships/services/auth_service.dart';
import 'package:battleships/views/game_list_screen.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:http/http.dart' as http; 

class CreateGameScreen extends StatefulWidget {
  final String? ai;
  const CreateGameScreen({super.key, this.ai});
  @override
  State<CreateGameScreen> createState() => _CreateGameScreenState();
}

class _CreateGameScreenState extends State<CreateGameScreen> {
  final List<bool> _gridSelection = List.generate(25, (index) => false);
  int _selectedShips = 0;
  final int _maxShips = 5;
  final List<String> _shipPositions = [];
  bool isSubmitting = false;

  String _getGridPosition(int index) {
    String row = String.fromCharCode(65 + index ~/ 5);
    String col = (index % 5 + 1).toString();
    return "$row$col";
  }

  void _placeShip(int index) {
    if (_selectedShips < _maxShips) {
      setState(() {
        if (_gridSelection[index]) {
          _selectedShips--;
          _shipPositions.remove(_getGridPosition(index));
        } else if (_selectedShips < _maxShips) {
          _selectedShips++;
          _shipPositions.add(_getGridPosition(index));
        }
        _gridSelection[index] = !_gridSelection[index];

        if (_selectedShips > _maxShips) {
          _gridSelection[index] = false;
          _selectedShips--;
          _shipPositions.remove(_getGridPosition(index));
        }
      });
    }
  }

  void _validateShipPlacement() {
    if (_selectedShips < _maxShips) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Please select $_maxShips ships.'),
        ),
      );
    } else {
      _submitShipData();
    }
  }

  Future<void> _submitShipData() async {
    const String baseUrl = 'https://battleships-app.onrender.com/games';

    final String? token = await AuthService().getToken();

    List<String> shipsData = _shipPositions;

    try {
      setState(() {
        isSubmitting = true;
      });
      final response = await http.post(
        Uri.parse(baseUrl),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: json.encode(
          widget.ai != null
              ? {'ships': shipsData, 'ai': widget.ai}
              : {'ships': shipsData},
        ),
      );
      setState(() {
        isSubmitting = false;
      });

      if (response.statusCode == 200) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Game created successfully!')),
        );
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const GameListScreen()),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to create game')),
        );
      }
    } catch (error) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $error')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Place Your Ships',
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
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Text(
                'Selected Ships: $_selectedShips/$_maxShips',
                style: GoogleFonts.roboto(
                  fontSize: 18,
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: GridView.builder(
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 5,
                    crossAxisSpacing: 8,
                    mainAxisSpacing: 8,
                    childAspectRatio: 1,
                  ),
                  itemCount: 25,
                  itemBuilder: (context, index) {
                    return GestureDetector(
                      onTap: () => _placeShip(index),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        decoration: BoxDecoration(
                          color: _gridSelection[index]
                              ? Colors.green.shade700
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
                        child: Center(
                          child: _gridSelection[index]
                              ? const Icon(
                                  Icons.directions_boat_filled,
                                  color: Colors.white,
                                  size: 32,
                                )
                              : Text(
                                  _getGridPosition(index),
                                  style: GoogleFonts.roboto(
                                    color: Colors.white70,
                                    fontSize: 16,
                                  ),
                                ),
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
                onPressed: _validateShipPlacement,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white,
                  foregroundColor: Colors.blue.shade900,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 5,
                ),
                child: isSubmitting
                    ? const CircularProgressIndicator(color: Colors.blue)
                    : Text(
                        'Confirm Placement',
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
    );
  }
}