import 'dart:convert';
import 'package:battleships/services/auth_service.dart';
import 'package:battleships/services/game_service.dart';
import 'package:battleships/views/game_detail_screen.dart';
import 'package:battleships/views/create_game_screen.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class GameListScreen extends StatefulWidget {
  const GameListScreen({super.key});

  @override
  State<GameListScreen> createState() => _GameListScreenState();
}

class _GameListScreenState extends State<GameListScreen> {
  final GameService _gameService = GameService();
  List<dynamic> _games = [];
  bool isLoading = false;
  bool showOnlyCompletedGmes = false;
  String? user;

  @override
  void initState() {
    super.initState();
    _fetchGames();
  }

  void _fetchGames() async {
    setState(() {
      isLoading = true;
    });
    var games = await _gameService.getGames();
    user = await AuthService().getUser();
    if (games.statusCode == 200) {
      final decodedBody = jsonDecode(games.body);
      setState(() {
        isLoading = false;
        _games = decodedBody['games'];
      });
    } else if (games.statusCode == 401) {
      AuthService().clearToken();
      Navigator.of(context).pushNamedAndRemoveUntil('/login', (route) => false);
    } else {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("Failed to fetch games")));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          showOnlyCompletedGmes ? 'Completed Games' : 'Active Games',
          style: GoogleFonts.pirataOne(fontSize: 24, color: Colors.white),
        ),
        backgroundColor: Colors.blue.shade900,
        actions: [
          IconButton(
            onPressed: _fetchGames,
            icon: const Icon(Icons.refresh, color: Colors.white),
          ),
        ],
      ),
      drawer: Drawer(
        child: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [Colors.blue.shade900, Colors.cyan.shade700],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
          ),
          child: ListView(
            padding: EdgeInsets.zero,
            children: [
              DrawerHeader(
                decoration: const BoxDecoration(),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Battleship',
                      style: GoogleFonts.pirataOne(
                        color: Colors.white,
                        fontSize: 32,
                      ),
                    ),
                    Text(
                      user ?? "",
                      style: GoogleFonts.roboto(
                        color: Colors.white70,
                        fontSize: 20,
                      ),
                    ),
                  ],
                ),
              ),
              _buildDrawerItem(
                icon: Icons.add,
                title: 'Create New Game',
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const CreateGameScreen(),
                    ),
                  );
                },
              ),
              _buildDrawerItem(
                icon: Icons.computer,
                title: 'New Game with AI',
                onTap: () => _showAIOptions(context),
              ),
              _buildDrawerItem(
                icon: Icons.history,
                title:
                    showOnlyCompletedGmes
                        ? 'Show Active Games'
                        : 'Show Completed Games',
                onTap: () {
                  setState(() {
                    showOnlyCompletedGmes = !showOnlyCompletedGmes;
                  });
                },
              ),
              _buildDrawerItem(
                icon: Icons.logout,
                title: 'Logout',
                onTap: () {
                  AuthService().clearToken();
                  Navigator.of(
                    context,
                  ).pushNamedAndRemoveUntil('/login', (route) => false);
                },
              ),
            ],
          ),
        ),
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
            isLoading
                ? const Center(
                  child: CircularProgressIndicator(color: Colors.white),
                )
                : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: _games.length,
                  itemBuilder: (context, index) {
                    var game = _games[index];
                    if (showOnlyCompletedGmes) {
                      if (game['status'] == 0 || game['status'] == 3) {
                        return Container();
                      }
                    }
                    if (!showOnlyCompletedGmes) {
                      if (game['status'] == 1 || game['status'] == 2) {
                        return Container();
                      }
                    }
                    return Dismissible(
                      key: Key(game['id'].toString()),
                      background: Container(
                        color: Colors.red.shade700,
                        alignment: Alignment.centerRight,
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        child: const Icon(Icons.delete, color: Colors.white),
                      ),
                      direction: DismissDirection.endToStart,
                      onDismissed: (direction) async {
                        final res = await GameService().forfeitGame(game['id']);
                        if (res.statusCode == 200) {
                          setState(() {
                            _games.removeAt(index);
                          });
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Game deleted successfully.'),
                            ),
                          );
                        } else {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Failed to delete the game.'),
                            ),
                          );
                        }
                      },
                      child: Card(
                        elevation: 5,
                        margin: const EdgeInsets.symmetric(vertical: 8),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: ListTile(
                          contentPadding: const EdgeInsets.all(16),
                          title: Text(
                            game['status'] == 0
                                ? "#${game['id']} Matchmaking"
                                : "#${game['id']} ${game['player1'] ?? ''} vs ${game['player2'] ?? ''}",
                            style: GoogleFonts.roboto(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.blue.shade900,
                            ),
                          ),
                          subtitle: Text(
                            game['status'] == 0
                                ? ""
                                : game['status'] == 1
                                ? "${game['player1']} win"
                                : game['status'] == 2
                                ? "${game['player2']} win"
                                : "Active",
                            style: GoogleFonts.roboto(
                              fontSize: 14,
                              color: Colors.grey.shade600,
                            ),
                          ),
                          trailing: Text(
                            game['turn'] == 0
                                ? ""
                                : game['turn'] == game['position']
                                ? "Your Turn"
                                : "Opponent Turn",
                            style: GoogleFonts.roboto(
                              fontSize: 16,
                              color:
                                  game['turn'] == game['position']
                                      ? Colors.green.shade700
                                      : Colors.red.shade700,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) {
                                  return GameDetailScreen(gameId: game['id']);
                                },
                              ),
                            );
                          },
                        ),
                      ),
                    );
                  },
                ),
      ),
    );
  }

  Widget _buildDrawerItem({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
  }) {
    return ListTile(
      leading: Icon(icon, color: Colors.white),
      title: Text(
        title,
        style: GoogleFonts.roboto(color: Colors.white, fontSize: 16),
      ),
      onTap: onTap,
    );
  }

  void _showAIOptions(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          title: Text(
            'Select AI Opponent',
            style: GoogleFonts.pirataOne(
              fontSize: 24,
              color: Colors.blue.shade900,
            ),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildAIButton('Random AI', 'random'),
              _buildAIButton('Perfect AI', 'perfect'),
              _buildAIButton('Oneship(A1) AI', 'oneship'),
            ],
          ),
        );
      },
    );
  }

  Widget _buildAIButton(String title, String aiType) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: ElevatedButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) {
                return CreateGameScreen(ai: aiType);
              },
            ),
          );
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.blue.shade900,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          padding: const EdgeInsets.symmetric(vertical: 12),
        ),
        child: Text(title, style: GoogleFonts.roboto(fontSize: 16)),
      ),
    );
  }
}
