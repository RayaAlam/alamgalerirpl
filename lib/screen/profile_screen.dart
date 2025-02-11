import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:flutter_uilogin/widget/pin_card.dart';

import '../services/storage.dart';
import 'detail_screen.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
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
                  FutureBuilder(
                      future: FirebaseFirestore.instance
                          .collection("users")
                          .doc(FirebaseAuth.instance.currentUser!.uid)
                          .get(),
                      builder: (context, snapshot) => Text(
                            snapshot.data != null
                                ? snapshot.data?.get("username")
                                : "Loading...",
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          )),
                ],
              ),
            ),
          ),
          SliverPadding(
              padding: EdgeInsets.symmetric(horizontal: 8),
              sliver: StreamBuilder(
                  stream: FirebaseFirestore.instance
                      .collection('posts')
                      .where("user",
                          isEqualTo: FirebaseAuth.instance.currentUser!.uid)
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
                        final imageUrl = generatePresignedUrl(
                            key: "gambar/${data['image']}");

                        return GestureDetector(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) =>
                                    DetailScreen(pin: <String, dynamic>{
                                  "title": data["title"],
                                  "imageUrl": imageUrl,
                                }),
                              ),
                            );
                          },
                          child: PinCard(
                            imageUrl: imageUrl,
                            title: data["title"],
                            height: 300,
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
