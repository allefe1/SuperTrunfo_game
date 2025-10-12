// lib/screens/home_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/hero_provider.dart';
import 'heroes_list_screen.dart';
import 'daily_card_screen.dart';
import 'my_cards_screen.dart';
import 'battle_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<HeroProvider>().loadLocalData();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Super Trunfo Heróis'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        centerTitle: true,
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Theme.of(context).colorScheme.primaryContainer,
              Theme.of(context).colorScheme.surface,
            ],
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(
                  Icons.sports_kabaddi,
                  size: 80,
                  color: Colors.deepPurple,
                ),
                const SizedBox(height: 20),
                const Text(
                  'Bem-vindo ao Super Trunfo!',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 10),
                const Text(
                  'Colecione cartas de super-heróis e batalhe!',
                  style: TextStyle(fontSize: 16),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 40),
                Expanded(
                  child: GridView.count(
                    crossAxisCount: 2,
                    crossAxisSpacing: 20,
                    mainAxisSpacing: 20,
                    children: [
                      _buildMenuCard(
                        context,
                        title: 'Heróis',
                        icon: Icons.list,
                        color: Colors.blue,
                        onTap: () => _navigateToHeroesList(context),
                      ),
                      _buildMenuCard(
                        context,
                        title: 'Card Diário',
                        icon: Icons.card_giftcard,
                        color: Colors.orange,
                        onTap: () => _navigateToDailyCard(context),
                      ),
                      _buildMenuCard(
                        context,
                        title: 'Minhas Cartas',
                        icon: Icons.collections,
                        color: Colors.green,
                        onTap: () => _navigateToMyCards(context),
                      ),
                      _buildMenuCard(
                        context,
                        title: 'Batalhar',
                        icon: Icons.flash_on,
                        color: Colors.red,
                        onTap: () => _navigateToBattle(context),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildMenuCard(
    BuildContext context, {
    required String title,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Card(
      elevation: 4,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                color.withOpacity(0.8),
                color.withOpacity(0.6),
              ],
            ),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                size: 50,
                color: Colors.white,
              ),
              const SizedBox(height: 10),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _navigateToHeroesList(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const HeroesListScreen()),
    );
  }

  void _navigateToDailyCard(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const DailyCardScreen()),
    );
  }

  void _navigateToMyCards(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const MyCardsScreen()),
    );
  }

  void _navigateToBattle(BuildContext context) {
    final provider = context.read<HeroProvider>();
    if (provider.myCards.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Você precisa ter pelo menos uma carta para batalhar!'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const BattleScreen()),
    );
  }
}
