// Package imports:
import 'package:flutter/material.dart';

// Feature imports:
import '/features/home/presentation/widgets/home_action_card.dart';
import '/features/home/presentation/widgets/home_header.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final TextEditingController _roomCodeController = TextEditingController();

  @override
  void dispose() {
    _roomCodeController.dispose();
    super.dispose();
  }

  void _onJoinParty() {
    final code = _roomCodeController.text.trim();
    if (code.length != 6) return;
    // TODO: navigate to lobby with code
  }

  void _onCreateParty() {
    // TODO: navigate to host settings screen
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            children: [
              const SizedBox(height: 16),
              const HomeHeader(),
              const Spacer(),
              ActionCard(
                roomCodeController: _roomCodeController,
                onJoinParty: _onJoinParty,
                onCreateParty: _onCreateParty,
              ),
              const SizedBox(height: 16),
              const Spacer(),
            ],
          ),
        ),
      ),
    );
  }
}
