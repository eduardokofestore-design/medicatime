import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';

class HomeScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: Text('MedicaTime'),
        actions: [
          IconButton(
            icon: Icon(Icons.person),
            onPressed: () {
              Navigator.of(context).pushNamed('/profile');
            },
          ),
        ],
      ),
      body: Center(
        child: StreamBuilder(
          stream: authProvider.getUserData(),
          builder: (context, snapshot) {
            if (snapshot.hasData && snapshot.data!.exists) {
              var data = snapshot.data!.data() as Map<String, dynamic>;
              return Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircleAvatar(
                    radius: 50,
                    backgroundImage: data['photoUrl'] != null
                        ? NetworkImage(data['photoUrl'])
                        : null,
                    child: data['photoUrl'] == null
                        ? Icon(Icons.person, size: 50)
                        : null,
                  ),
                  Text('Bem-vindo, ${data['name']}!'),
                ],
              );
            }
            return CircularProgressIndicator();
          },
        ),
      ),
    );
  }
}