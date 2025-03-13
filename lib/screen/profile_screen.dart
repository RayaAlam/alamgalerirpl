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
      body: Container(
        decoration: BoxDecoration(
          image: DecorationImage(
            image: AssetImage('images/bg.jpg'),
            fit: BoxFit.cover,
            colorFilter: ColorFilter.mode(
              Colors.black.withOpacity(0),
              BlendMode.darken,
            ),
          ),
        ),
        child: CustomScrollView(
          physics: BouncingScrollPhysics(),
          slivers: [
            SliverAppBar(
              pinned: true,
              backgroundColor: Colors.transparent,
              expandedHeight: 280,
              flexibleSpace: FlexibleSpaceBar(
                background: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Colors.black.withOpacity(0.7),
                        Colors.transparent,
                      ],
                    ),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: Colors.white.withOpacity(0.2),
                              spreadRadius: 5,
                              blurRadius: 15,
                            ),
                          ],
                        ),
                        child: CircleAvatar(
                          radius: 60,
                          backgroundColor: Colors.grey[800],
                          child: Icon(
                            Icons.person,
                            size: 60,
                            color: Colors.white.withOpacity(0.9),
                          ),
                        ),
                      ),
                      SizedBox(height: 16),
                      FutureBuilder(
                        future: FirebaseFirestore.instance
                            .collection("users")
                            .doc(FirebaseAuth.instance.currentUser!.uid)
                            .get(),
                        builder: (context, snapshot) => Container(
                          padding:
                              EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(20),
                            color: Colors.black.withOpacity(0.5),
                            border: Border.all(
                              color: Colors.white.withOpacity(0.1),
                              width: 1,
                            ),
                          ),
                          child: Text(
                            snapshot.data != null
                                ? snapshot.data?.get("username")
                                : "Loading...",
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 0.5,
                              shadows: [
                                Shadow(
                                  offset: Offset(0, 2),
                                  blurRadius: 4,
                                  color: Colors.black.withOpacity(0.5),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            SliverPadding(
              padding: EdgeInsets.symmetric(horizontal: 12),
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
                      crossAxisCount: 2,
                    ),
                    mainAxisSpacing: 12,
                    crossAxisSpacing: 12,
                    delegate: SliverChildBuilderDelegate(
                      (context, index) {
                        final data = snapshot.data!.docs[index];
                        final imageUrl = generatePresignedUrl(
                          key: "gambar/${data['image']}",
                        );

                        return GestureDetector(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => DetailScreen(
                                  pin: <String, dynamic>{
                                    "title": data["title"],
                                    "imageUrl": imageUrl,
                                    "user": data["user"],
                                    "id": data.id
                                  },
                                ),
                              ),
                            );
                          },
                          child: Container(
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(16),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black38,
                                  offset: Offset(0, 2),
                                  blurRadius: 6,
                                ),
                              ],
                            ),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(16),
                              child: Stack(
                                children: [
                                  PinCard(
                                    imageUrl: imageUrl,
                                    title: data["title"],
                                    height: 300,
                                  ),
                                  Positioned(
                                    bottom: 0,
                                    left: 0,
                                    right: 0,
                                    child: Container(
                                      decoration: BoxDecoration(
                                        gradient: LinearGradient(
                                          begin: Alignment.topCenter,
                                          end: Alignment.bottomCenter,
                                          colors: [
                                            Colors.transparent,
                                            Colors.black87,
                                          ],
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        );
                      },
                      childCount: snapshot.data?.size ?? 0,
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}





// class ProfileScreen extends StatelessWidget {
//   const ProfileScreen({Key? key}) : super(key: key);
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: Colors.black,
//       body: CustomScrollView(
//         slivers: [
//           SliverAppBar(
//             pinned: true,
//             backgroundColor: Colors.black,
//             expandedHeight: 200,
//             flexibleSpace: FlexibleSpaceBar(
//               background: Column(
//                 mainAxisAlignment: MainAxisAlignment.center,
//                 children: [
//                   CircleAvatar(
//                     radius: 50,
//                     backgroundColor: Colors.grey[800],
//                     child: Icon(Icons.person, size: 50, color: Colors.white),
//                   ),
//                   SizedBox(height: 8),
//                   FutureBuilder(
//                       future: FirebaseFirestore.instance
//                           .collection("users")
//                           .doc(FirebaseAuth.instance.currentUser!.uid)
//                           .get(),
//                       builder: (context, snapshot) => Text(
//                             snapshot.data != null
//                                 ? snapshot.data?.get("username")
//                                 : "Loading...",
//                             style: TextStyle(
//                               color: Colors.white,
//                               fontSize: 20,
//                               fontWeight: FontWeight.bold,
//                             ),
//                           )),
//                 ],
//               ),
//             ),
//           ),
//           SliverPadding(
//               padding: EdgeInsets.symmetric(horizontal: 8),
//               sliver: StreamBuilder(
//                   stream: FirebaseFirestore.instance
//                       .collection('posts')
//                       .where("user",
//                           isEqualTo: FirebaseAuth.instance.currentUser!.uid)
//                       .snapshots(),
//                   builder: (BuildContext context,
//                       AsyncSnapshot<QuerySnapshot> snapshot) {
//                     return SliverMasonryGrid(
//                       gridDelegate:
//                           SliverSimpleGridDelegateWithFixedCrossAxisCount(
//                               crossAxisCount: 2),
//                       mainAxisSpacing: 8,
//                       crossAxisSpacing: 8,
//                       delegate: SliverChildBuilderDelegate((context, index) {
//                         final data = snapshot.data!.docs[index];
//                         final imageUrl = generatePresignedUrl(
//                             key: "gambar/${data['image']}");
//
//                         return GestureDetector(
//                           onTap: () {
//                             Navigator.push(
//                               context,
//                               MaterialPageRoute(
//                                 builder: (context) =>
//                                     DetailScreen(pin: <String, dynamic>{
//                                   "title": data["title"],
//                                   "imageUrl": imageUrl,
//                                       "user": data["user"],
//                                       "id": data.id
//                                 }),
//                               ),
//                             );
//                           },
//                           child: PinCard(
//                             imageUrl: imageUrl,
//                             title: data["title"],
//                             height: 300,
//                           ),
//                         );
//                       }, childCount: snapshot.data?.size ?? 0),
//                     );
//                   })),
//         ],
//       ),
//     );
//   }
// }
