// lib/screens/battle_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:primer_progress_bar/primer_progress_bar.dart';
import 'package:awesome_dialog/awesome_dialog.dart';
import '../domain/hero_domain.dart';
import '../providers/hero_provider.dart';

class BattleScreen extends StatefulWidget {
  const BattleScreen({super.key});

  @override
  State<BattleScreen> createState() => _BattleScreenState();
}

class _BattleScreenState extends State<BattleScreen> {
  List<SuperHero> _myBattleDeck = [];
  int _currentCardIndex = 0;
  int _myWins = 0;
  int _myLosses = 0;
  int _draws = 0;
  bool _gameFinished = false;
  int? _selectedPowerIndex;

  @override
  void initState() {
    super.initState();
    _initializeBattle();
  }

  void _initializeBattle() {
    final provider = context.read<HeroProvider>();
    _myBattleDeck = List.from(provider.myCards);
    _myBattleDeck.shuffle(); // Ordem aleatória conforme especificação
  }

  @override
  Widget build(BuildContext context) {
    if (_gameFinished) {
      return _buildGameFinishedScreen();
    }

    if (_myBattleDeck.isEmpty) {
      return _buildNoBattleDeckScreen();
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(
            'Batalha - Carta ${_currentCardIndex + 1}/${_myBattleDeck.length}'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        actions: [
          IconButton(
            icon: const Icon(Icons.info_outline),
            onPressed: _showGameInstructions,
          ),
        ],
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Colors.red.withOpacity(0.2),
              Colors.white,
            ],
          ),
        ),
        child: Column(
          children: [
            _buildScoreBoard(),
            Expanded(
              child: _buildCurrentCard(),
            ),
            _buildBattleButtons(),
          ],
        ),
      ),
    );
  }

  Widget _buildScoreBoard() {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.3),
            blurRadius: 5,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _buildScoreItem('Vitórias', _myWins, Colors.green),
          _buildScoreItem('Derrotas', _myLosses, Colors.red),
          _buildScoreItem('Empates', _draws, Colors.orange),
        ],
      ),
    );
  }

  Widget _buildScoreItem(String label, int value, Color color) {
    return Column(
      children: [
        Text(
          value.toString(),
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        Text(
          label,
          style: TextStyle(
            fontSize: 14,
            color: color,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  Widget _buildCurrentCard() {
    final currentHero = _myBattleDeck[_currentCardIndex];

    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            const Text(
              'Sua Carta Atual',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            _buildHeroCard(currentHero),
            const SizedBox(height: 20),
            _buildPowerSelection(currentHero),
          ],
        ),
      ),
    );
  }

  Widget _buildHeroCard(SuperHero hero) {
    return Card(
      elevation: 8,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Container(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: CachedNetworkImage(
                imageUrl: hero.images.md,
                height: 200,
                width: 200,
                fit: BoxFit.cover,
                placeholder: (context, url) => Container(
                  height: 200,
                  width: 200,
                  child: const Center(child: CircularProgressIndicator()),
                ),
                errorWidget: (context, url, error) => Container(
                  height: 200,
                  width: 200,
                  color: Colors.grey[300],
                  child: const Icon(Icons.person, size: 50, color: Colors.grey),
                ),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              hero.name,
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
            if (hero.biography.publisher != null)
              Container(
                margin: const EdgeInsets.only(top: 8),
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: Colors.blue.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  hero.biography.publisher!,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.blue,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildPowerSelection(SuperHero hero) {
    final powers = [
      ('Intelligence', hero.powerStats.intelligence, Colors.blue),
      ('Strength', hero.powerStats.strength, Colors.red),
      ('Speed', hero.powerStats.speed, Colors.green),
      ('Durability', hero.powerStats.durability, Colors.orange),
      ('Power', hero.powerStats.power, Colors.purple),
      ('Combat', hero.powerStats.combat, Colors.teal),
    ];

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Escolha o Atributo para Competir:',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            ...powers.asMap().entries.map((entry) {
              final index = entry.key;
              final power = entry.value;
              return _buildPowerSelectionTile(
                  index, power.$1, power.$2, power.$3);
            }),
          ],
        ),
      ),
    );
  }

  Widget _buildPowerSelectionTile(
      int index, String label, int value, Color color) {
    final isSelected = _selectedPowerIndex == index;

    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedPowerIndex = index;
        });
      },
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 4),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: isSelected ? color.withOpacity(0.3) : Colors.transparent,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: isSelected ? color : Colors.grey.withOpacity(0.3),
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        label,
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          color: isSelected ? color : Colors.black,
                        ),
                      ),
                      Text(
                        value.toString(),
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                          color: isSelected ? color : Colors.black,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  PrimerProgressBar(
                    segments: [
                      Segment(
                        value:
                            value, // Remove o "* 1.0" - usa o int diretamente
                        color: color,
                      ),
                    ],
                  ),
                ],
              ),
            ),
            if (isSelected)
              Container(
                margin: const EdgeInsets.only(left: 12),
                child: Icon(
                  Icons.check_circle,
                  color: color,
                  size: 24,
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildBattleButtons() {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          if (_selectedPowerIndex != null)
            Container(
              padding: const EdgeInsets.all(12),
              margin: const EdgeInsets.only(bottom: 16),
              decoration: BoxDecoration(
                color: Colors.blue.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                'Compare ${_getPowerName(_selectedPowerIndex!)} com seu oponente!',
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          Row(
            children: [
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: _selectedPowerIndex != null
                      ? () => _handleRoundResult('win')
                      : null,
                  icon: const Icon(Icons.emoji_events),
                  label: const Text('Venci o Round'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: _selectedPowerIndex != null
                      ? () => _handleRoundResult('lose')
                      : null,
                  icon: const Icon(Icons.sentiment_dissatisfied),
                  label: const Text('Perdi o Round'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: _selectedPowerIndex != null
                  ? () => _handleRoundResult('draw')
                  : null,
              icon: const Icon(Icons.horizontal_rule),
              label: const Text('Empate'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.orange,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _getPowerName(int index) {
    const powerNames = [
      'Intelligence',
      'Strength',
      'Speed',
      'Durability',
      'Power',
      'Combat'
    ];
    return powerNames[index];
  }

  void _handleRoundResult(String result) {
    setState(() {
      switch (result) {
        case 'win':
          _myWins++;
          break;
        case 'lose':
          _myLosses++;
          break;
        case 'draw':
          _draws++;
          break;
      }

      _currentCardIndex++;
      _selectedPowerIndex = null;

      if (_currentCardIndex >= _myBattleDeck.length) {
        _gameFinished = true;
      }
    });
  }

  Widget _buildGameFinishedScreen() {
    final totalRounds = _myWins + _myLosses + _draws;
    String resultMessage;
    Color resultColor;
    IconData resultIcon;

    if (_myWins > _myLosses) {
      resultMessage = 'Você Venceu!';
      resultColor = Colors.green;
      resultIcon = Icons.emoji_events;
    } else if (_myLosses > _myWins) {
      resultMessage = 'Você Perdeu!';
      resultColor = Colors.red;
      resultIcon = Icons.sentiment_dissatisfied;
    } else {
      resultMessage = 'Empate!';
      resultColor = Colors.orange;
      resultIcon = Icons.handshake;
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Resultado da Batalha'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              resultColor.withOpacity(0.2),
              Colors.white,
            ],
          ),
        ),
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(32.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  resultIcon,
                  size: 80,
                  color: resultColor,
                ),
                const SizedBox(height: 24),
                Text(
                  resultMessage,
                  style: TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                    color: resultColor,
                  ),
                ),
                const SizedBox(height: 32),
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(24.0),
                    child: Column(
                      children: [
                        const Text(
                          'Resultado Final',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 16),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            _buildFinalScoreItem(
                                'Vitórias', _myWins, Colors.green),
                            _buildFinalScoreItem(
                                'Derrotas', _myLosses, Colors.red),
                            _buildFinalScoreItem(
                                'Empates', _draws, Colors.orange),
                          ],
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'Total de $totalRounds rounds jogados',
                          style: const TextStyle(
                            fontSize: 16,
                            color: Colors.grey,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 32),
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: _restartBattle,
                        icon: const Icon(Icons.refresh),
                        label: const Text('Nova Batalha'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blue,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: () => Navigator.pop(context),
                        icon: const Icon(Icons.home),
                        label: const Text('Voltar ao Início'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.grey,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildFinalScoreItem(String label, int value, Color color) {
    return Column(
      children: [
        Text(
          value.toString(),
          style: TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        Text(
          label,
          style: TextStyle(
            fontSize: 14,
            color: color,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  Widget _buildNoBattleDeckScreen() {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Batalha'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: const Center(
        child: Padding(
          padding: EdgeInsets.all(32.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.error,
                size: 80,
                color: Colors.red,
              ),
              SizedBox(height: 24),
              Text(
                'Sem Cartas para Batalhar',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.red,
                ),
              ),
              SizedBox(height: 16),
              Text(
                'Você precisa ter pelo menos uma carta na sua coleção para batalhar!',
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.grey,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _restartBattle() {
    setState(() {
      _currentCardIndex = 0;
      _myWins = 0;
      _myLosses = 0;
      _draws = 0;
      _gameFinished = false;
      _selectedPowerIndex = null;
      _myBattleDeck.shuffle(); // Nova ordem aleatória
    });
  }

  void _showGameInstructions() {
    AwesomeDialog(
      context: context,
      dialogType: DialogType.info,
      animType: AnimType.scale,
      title: 'Como Jogar',
      desc: '''1. Escolha um atributo da sua carta
2. Compare com a carta do seu oponente
3. Clique no resultado do round:
   • Verde: Você venceu
   • Vermelho: Você perdeu
   • Laranja: Empate
4. Repita até acabar as cartas
5. Quem ganhar mais rounds vence!''',
      btnOkOnPress: () {},
    ).show();
  }
}
