import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';

class ProfileScreen extends StatefulWidget {
  @override
  _ProfileScreenState createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final _nameController = TextEditingController();
  File? _image;
  final picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    authProvider.getUserData().listen((snapshot) {
      if (snapshot.exists) {
        _nameController.text = snapshot['name'] ?? '';
      }
    });
  }

  Future getImage() async {
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);

    setState(() {
      if (pickedFile != null) {
        _image = File(pickedFile.path);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);

    return Scaffold(
      appBar: AppBar(title: Text('Perfil - MedicaTime')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            GestureDetector(
              onTap: getImage,
              child: CircleAvatar(
                radius: 50,
                backgroundImage: _image != null ? FileImage(_image!) : null,
                child: _image == null ? Icon(Icons.camera_alt, size: 50) : null,
              ),
            ),
            TextField(
              controller: _nameController,
              decoration: InputDecoration(labelText: 'Nome'),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () async {
                String? photoUrl;
                if (_image != null) {
                  photoUrl = await authProvider.uploadPhoto(_image!.path);
                }
                await authProvider.updateProfile(_nameController.text, photoUrl);
                ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Perfil atualizado!')));
              },
              child: Text('Salvar'),
            ),
            ElevatedButton(
              onPressed: () async {
                await authProvider.signOut();
                Navigator.of(context).pushReplacementNamed('/login');
              },
              child: Text('Sair'),
            ),
          ],
        ),
      ),
    );
  }
}