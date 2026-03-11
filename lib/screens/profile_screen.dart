import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import 'dart:async';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => ProfileScreenState();
}

class ProfileScreenState extends State<ProfileScreen> {
  final _nameController = TextEditingController();

  StreamSubscription? _userSubscription;

  @override
  void initState() {
    super.initState();

    Future.microtask(() {
      final authProvider =
          Provider.of<AuthProvider>(context, listen: false);

      _userSubscription =
          authProvider.getUserData().listen((snapshot) {
        if (snapshot.exists) {
          _nameController.text = snapshot['name'] ?? '';
        }
      });
    });
  }

  @override
  void dispose() {
    _nameController.dispose();
    _userSubscription?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Perfil - MedicaTime'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [

            const SizedBox(height: 20),

            const CircleAvatar(
              radius: 40,
              child: Icon(Icons.person, size: 40),
            ),

            const SizedBox(height: 30),

            /// Nome
            TextField(
              controller: _nameController,
              decoration: const InputDecoration(
                labelText: 'Nome',
                prefixIcon: Icon(Icons.person),
              ),
            ),

            const SizedBox(height: 25),

            /// Botão salvar
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                minimumSize: const Size(double.infinity, 50),
              ),
              onPressed: () async {

                await authProvider.updateProfile(
                  _nameController.text.trim(),
                );

                if (!mounted) return;

                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Perfil atualizado!'),
                  ),
                );
              },
              child: const Text('Salvar'),
            ),

            const SizedBox(height: 10),

            /// Botão sair
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                minimumSize: const Size(double.infinity, 50),
                backgroundColor: Colors.red,
              ),
              onPressed: () async {

                await authProvider.signOut();

                if (!mounted) return;

                Navigator.pushReplacementNamed(context, '/login');
              },
              child: const Text('Sair'),
            ),
          ],
        ),
      ),
    );
  }
}
