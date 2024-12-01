  import 'package:flutter/material.dart';

  class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
    final String email;

    const CustomAppBar({Key? key, required this.email}) : super(key: key);

    @override
    Widget build(BuildContext context) {
      return AppBar(
        title: const Text('App Title'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () {
              Navigator.pushReplacementNamed(context, '/login');
            },
          ),
        ],
      );
    }

    @override
    Size get preferredSize => const Size.fromHeight(kToolbarHeight);
  }