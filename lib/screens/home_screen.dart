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
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text(
                    'Bem-vindo ao Super Trunfo!',
                    style: TextStyle(
                      fontSize: 26,
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 10),
                  const Text(
                    'Colecione cartas de super-heróis e batalhe!',
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.grey,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 40),
                  
                  
                  _buildMenuButton(
                    context,
                    title: 'Heróis',
                    icon: Icons.list,
                    color: Colors.blue,
                    onTap: () => _navigateToHeroesList(context),
                  ),
                  const SizedBox(height: 16),
                  
                  _buildMenuButton(
                    context,
                    title: 'Card Diário',
                    icon: Icons.card_giftcard,
                    color: Colors.blue,
                    onTap: () => _navigateToDailyCard(context),
                  ),
                  const SizedBox(height: 16),
                  
                  _buildMenuButton(
                    context,
                    title: 'Minhas Cartas',
                    icon: Icons.collections,
                    color: Colors.blue,
                    onTap: () => _navigateToMyCards(context),
                  ),
                  const SizedBox(height: 16),
                  
                  _buildMenuButton(
                    context,
                    title: 'Batalhar',
                    icon: Icons.flash_on,
                    color: Colors.blue,
                    onTap: () => _navigateToBattle(context),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }


  //construcao do botao
  Widget _buildMenuButton(
    BuildContext context, {
    required String title,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return SizedBox(
      width: double.infinity, 
      height: 70, 
      child: ElevatedButton(
        onPressed: onTap,
        style: ElevatedButton.styleFrom(
          backgroundColor: color,
          foregroundColor: Colors.white,
          elevation: 4,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 32,
              color: Colors.white,
            ),
            const SizedBox(width: 16),
            Text(
              title,
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ],
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
