import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:flutter_uilogin/widget/pin_card.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Data dummy untuk profile pins
    final List<Map<String, dynamic>> profilePins = [
      {
        'imageUrl': 'https://picsum.photos/id/21/400/500',
        'title': 'My Pin 1',
        'height': 280.0,
      },
      {
        'imageUrl': 'https://picsum.photos/id/22/400/300',
        'title': 'My Pin 2',
        'height': 220.0,
      },
      // Add more items as needed
    ];

    return Scaffold(
      backgroundColor: Colors.black,
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            pinned: true,
            backgroundColor: Colors.black,
            expandedHeight: 200,
            flexibleSpace: FlexibleSpaceBar(
              background: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircleAvatar(
                    radius: 50,
                    backgroundColor: Colors.grey[800],
                    child: Icon(Icons.person, size: 50, color: Colors.white),
                  ),
                  SizedBox(height: 8),
                  Text(
                    'Username',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ),
          SliverPadding(
            padding: EdgeInsets.symmetric(horizontal: 8),
            sliver: SliverMasonryGrid.count(
              crossAxisCount: 2,
              mainAxisSpacing: 8,
              crossAxisSpacing: 8,
              itemBuilder: (context, index) {
                return PinCard(
                  imageUrl: profilePins[index % profilePins.length]['imageUrl'],
                  title: profilePins[index % profilePins.length]['title'],
                  height: profilePins[index % profilePins.length]['height'],
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}