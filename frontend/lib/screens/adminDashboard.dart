import 'package:flutter/material.dart';

class AdminDashboardScreen extends StatelessWidget {
  const AdminDashboardScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: NetworkImage(
                'https://unblast.com/wp-content/uploads/2019/01/Under-Construction-Illustration.jpg'), // Replace with your image URL
            fit: BoxFit.cover,
          ),
        ),
      ),
    );
  }
}
