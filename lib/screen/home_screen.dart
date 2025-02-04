import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_uilogin/screen/create_post_screen.dart';
import 'package:flutter_uilogin/screen/search_screen.dart';
import 'package:flutter_uilogin/widget/pin_card.dart';

import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'detail_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Data dummy untuk contoh
    final List<Map<String, dynamic>> pins = [
      {
        'imageUrl': 'https://picsum.photos/id/1/400/600',
        'title': 'Workspace Setup',
        'height': 300.0,
      },
      {
        'imageUrl': 'https://picsum.photos/id/2/400/300',
        'title': 'Modern Design',
        'height': 200.0,
      },
      {
        'imageUrl': 'https://picsum.photos/id/3/400/500',
        'title': 'Creative Space',
        'height': 250.0,
      },
    ];

    return Scaffold(
      backgroundColor: Colors.black,
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            floating: true,
            title: Text('Cobaterest',
                style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
            backgroundColor: Colors.black,
            actions: [
              IconButton(
                  onPressed: () {
                    FirebaseAuth.instance.signOut();
                  },
                  icon: const Icon(Icons.logout, color: Colors.white)
              ),
            ],
          ),
          SliverPadding(
            padding: EdgeInsets.symmetric(horizontal: 8),
            sliver: SliverMasonryGrid.count(
              crossAxisCount: 2,
              mainAxisSpacing: 8,
              crossAxisSpacing: 8,
              itemBuilder: (context, index) {
                return GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => DetailScreen(pin: pins[index % pins.length]),
                      ),
                    );
                  },
                  child: PinCard(
                    imageUrl: pins[index % pins.length]['imageUrl'],
                    title: pins[index % pins.length]['title'],
                    height: pins[index % pins.length]['height'],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
