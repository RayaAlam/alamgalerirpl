import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_uilogin/screen/create_post_screen.dart';
import 'package:flutter_uilogin/screen/search_screen.dart';
import 'package:flutter_uilogin/widget/pin_card.dart';

import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'detail_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            floating: true,
            title: Text('Cobaterest',
                style: TextStyle(
                    color: Colors.white, fontWeight: FontWeight.bold)),
            backgroundColor: Colors.black,
            actions: [
              IconButton(
                  onPressed: () {
                    FirebaseAuth.instance.signOut();
                  },
                  icon: const Icon(Icons.logout, color: Colors.white)),
            ],
          ),
          SliverPadding(
              padding: EdgeInsets.symmetric(horizontal: 8),
              sliver: StreamBuilder(
                  stream: FirebaseFirestore.instance
                      .collection('posts')
                      .snapshots(),
                  builder: (BuildContext context,
                      AsyncSnapshot<QuerySnapshot> snapshot) {
                    return SliverMasonryGrid(
                      gridDelegate:
                          SliverSimpleGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 2),
                      mainAxisSpacing: 8,
                      crossAxisSpacing: 8,
                      delegate: SliverChildBuilderDelegate((context, index) {
                        final data = snapshot.data!.docs[index];

                        return GestureDetector(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => DetailScreen(
                                    pin: <String, dynamic>{
                                      "title": data["title"],
                                      "imageUrl": "https://picsum.photos/100/100",
                                    }
                                  ),
                              ),
                            );
                          },
                          child: PinCard(
                            imageUrl: "https://picsum.photos/100/100",
                            title: data["title"],
                            height: 400,
                          ),
                        );
                      }, childCount: snapshot.data?.size ?? 0),
                    );
                  })),
        ],
      ),
    );
  }
}
