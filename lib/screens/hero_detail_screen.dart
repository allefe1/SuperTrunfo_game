// lib/screens/hero_detail_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:primer_progress_bar/primer_progress_bar.dart';
import 'package:awesome_dialog/awesome_dialog.dart';
import '../domain/hero_domain.dart';
import '../providers/hero_provider.dart';

class HeroDetailScreen extends StatelessWidget {
  final SuperHero hero;

  const HeroDetailScreen({super.key, required this.hero});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(hero.name),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        actions: [
          Consumer<HeroProvider>(
            builder: (context, provider, child) {
              final hasCard = provider.hasCard(hero);
              return IconButton(
                icon: Icon(
                  hasCard ? Icons.bookmark : Icons.bookmark_border,
                  color: hasCard ? Colors.red : null,
                ),
                onPressed: hasCard
                    ? () => _removeFromCollection(context)
                    : () => _addToCollection(context),
              );
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeroImage(),
            _buildBasicInfo(),
            _buildPowerStats(),
            _buildAppearanceInfo(),
            _buildBiographyInfo(),
            _buildWorkInfo(),
            _buildConnectionsInfo(),
          ],
        ),
      ),
    );
  }

  Widget _buildHeroImage() {
    return Container(
      height: 300,
      width: double.infinity,
      child: CachedNetworkImage(
        imageUrl: hero.images.lg,
        fit: BoxFit.cover,
        placeholder: (context, url) => const Center(
          child: CircularProgressIndicator(),
        ),
        errorWidget: (context, url, error) => Container(
          color: Colors.grey[300],
          child: const Icon(Icons.person, size: 100, color: Colors.grey),
        ),
      ),
    );
  }

  Widget _buildBasicInfo() {
  return Padding(
    padding: const EdgeInsets.all(16.0),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          hero.name,
          style: const TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.bold,
          ),
        ),
        if (hero.biography.fullName.isNotEmpty)
          Text(
            hero.biography.fullName,
            style: const TextStyle(
              fontSize: 18,
              color: Colors.grey,
            ),
          ),
        const SizedBox(height: 8),
        if (hero.biography.publisher != null)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.blue.withOpacity(0.2),  // Cor fixa em vez de Theme
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              hero.biography.publisher!,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.blue,  // Cor do texto também
              ),
            ),
          ),
      ],
    ),
  );
}

  Widget _buildPowerStats() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Poderes',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          _buildPowerBar(
              'Intelligence', hero.powerStats.intelligence, Colors.blue),
          _buildPowerBar('Strength', hero.powerStats.strength, Colors.red),
          _buildPowerBar('Speed', hero.powerStats.speed, Colors.green),
          _buildPowerBar(
              'Durability', hero.powerStats.durability, Colors.orange),
          _buildPowerBar('Power', hero.powerStats.power, Colors.purple),
          _buildPowerBar('Combat', hero.powerStats.combat, Colors.teal),
        ],
      ),
    );
  }

  Widget _buildPowerBar(String label, int value, Color color) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(label, style: const TextStyle(fontWeight: FontWeight.w500)),
              Text('$value',
                  style: const TextStyle(fontWeight: FontWeight.bold)),
            ],
          ),
          const SizedBox(height: 4),
          PrimerProgressBar(
            segments: [
              Segment(
                value: value, // Valor int direto, sem divisão
                color: color,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildAppearanceInfo() {
    return _buildSection(
      title: 'Aparência',
      children: [
        _buildInfoRow('Gênero', hero.appearance.gender),
        _buildInfoRow('Raça', hero.appearance.race),
        _buildInfoRow('Cor dos Olhos', hero.appearance.eyeColor),
        _buildInfoRow('Cor do Cabelo', hero.appearance.hairColor),
        if (hero.appearance.height.isNotEmpty)
          _buildInfoRow('Altura', hero.appearance.height.join(', ')),
        if (hero.appearance.weight.isNotEmpty)
          _buildInfoRow('Peso', hero.appearance.weight.join(', ')),
      ],
    );
  }

  Widget _buildBiographyInfo() {
    return _buildSection(
      title: 'Biografia',
      children: [
        if (hero.biography.alterEgos.isNotEmpty)
          _buildInfoRow('Alter Egos', hero.biography.alterEgos),
        if (hero.biography.aliases.isNotEmpty)
          _buildInfoRow('Aliases', hero.biography.aliases.join(', ')),
        _buildInfoRow('Local de Nascimento', hero.biography.placeOfBirth),
        _buildInfoRow('Primeira Aparição', hero.biography.firstAppearance),
        _buildInfoRow('Alinhamento', hero.biography.alignment),
      ],
    );
  }

  Widget _buildWorkInfo() {
    return _buildSection(
      title: 'Trabalho',
      children: [
        _buildInfoRow('Ocupação', hero.work.occupation),
        _buildInfoRow('Base', hero.work.base),
      ],
    );
  }

  Widget _buildConnectionsInfo() {
    return _buildSection(
      title: 'Conexões',
      children: [
        _buildInfoRow('Afiliação de Grupo', hero.connections.groupAffiliation),
        _buildInfoRow('Parentes', hero.connections.relatives),
      ],
    );
  }

  Widget _buildSection(
      {required String title, required List<Widget> children}) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),
          ...children,
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    if (value.isEmpty || value == '-') return const SizedBox.shrink();

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              '$label:',
              style: const TextStyle(fontWeight: FontWeight.w500),
            ),
          ),
          Expanded(
            child: Text(value),
          ),
        ],
      ),
    );
  }

  void _addToCollection(BuildContext context) {
    final provider = context.read<HeroProvider>();

    try {
      provider.addToMyCards(hero);

      AwesomeDialog(
        context: context,
        dialogType: DialogType.success,
        animType: AnimType.scale,
        title: 'Sucesso!',
        desc: '${hero.name} foi adicionado à sua coleção!',
        btnOkOnPress: () {},
      ).show();
    } catch (e) {
      AwesomeDialog(
        context: context,
        dialogType: DialogType.error,
        animType: AnimType.leftSlide,
        title: 'Erro!',
        desc: e.toString(),
        btnOkOnPress: () {},
      ).show();
    }
  }

  void _removeFromCollection(BuildContext context) {
    AwesomeDialog(
      context: context,
      dialogType: DialogType.warning,
      animType: AnimType.scale,
      title: 'Confirmar Remoção',
      desc: 'Deseja remover ${hero.name} da sua coleção?',
      btnCancelOnPress: () {},
      btnOkOnPress: () {
        context.read<HeroProvider>().removeFromMyCards(hero);
      },
    ).show();
  }
}
