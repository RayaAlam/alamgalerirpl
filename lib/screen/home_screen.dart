import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_uilogin/screen/create_post_screen.dart';
import 'package:flutter_uilogin/screen/search_screen.dart';
import 'package:flutter_uilogin/services/storage.dart';
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
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = "";

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Background Image
          Container(
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
          ),
          // Main Content
          CustomScrollView(
            physics: BouncingScrollPhysics(),
            slivers: [
              SliverAppBar(
                floating: true,
                expandedHeight: 60,
                title: Row(
                  children: [
                    Expanded(
                      flex: 3,
                      child: Text(
                        'Galeri Alam',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w800,
                          fontSize: 24,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ),
                    Expanded(
                      flex: 4,
                      child: Container(
                        height: 30,
                        decoration: BoxDecoration(
                          color: Colors.white24,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: TextField(
                          controller: _searchController,
                          style: TextStyle(color: Colors.white),
                          decoration: InputDecoration(
                            hintText: 'Cari postingan...',
                            hintStyle: TextStyle(color: Colors.white70),
                            contentPadding: EdgeInsets.symmetric(
                                horizontal: 16, vertical: 9),
                            border: InputBorder.none,
                            suffixIcon: Padding(
                              padding: EdgeInsets.only(top: 2), // Add padding to move the icon up
                              child: IconButton(
                                icon: Icon(Icons.search, color: Colors.white70),
                                onPressed: () {
                                  setState(() {
                                    _searchQuery = _searchController.text.trim().toLowerCase();
                                  });
                                  FocusScope.of(context).unfocus();
                                },
                                padding: EdgeInsets.zero, // Remove default padding
                                constraints: BoxConstraints(), // Remove default constraints
                                iconSize: 22, // Slightly smaller icon for better vertical positioning
                              ),
                            ),
                          ),
                          onSubmitted: (value) {
                            setState(() {
                              _searchQuery = value.trim().toLowerCase();
                            });
                          },
                        ),
                      ),
                    ),
                  ],
                ),
                backgroundColor: Colors.transparent,
                elevation: 0,
                actions: [
                  IconButton(
                    onPressed: () {
                      FirebaseAuth.instance.signOut();
                    },
                    icon: const Icon(Icons.logout, color: Colors.white70),
                    splashRadius: 24,
                  ),
                ],
              ),
              SliverPadding(
                padding: EdgeInsets.symmetric(horizontal: 12),
                sliver: StreamBuilder(
                  stream: FirebaseFirestore.instance
                      .collection('posts')
                      .snapshots(),
                  builder: (BuildContext context,
                      AsyncSnapshot<QuerySnapshot> snapshot) {
                    if (!snapshot.hasData) {
                      return SliverToBoxAdapter(
                        child: Center(
                          child: CircularProgressIndicator(
                            color: Colors.white70,
                          ),
                        ),
                      );
                    }

                    // Filter posts based on search query
                    var filteredDocs = snapshot.data!.docs;
                    if (_searchQuery.isNotEmpty) {
                      filteredDocs = filteredDocs.where((doc) {
                        final title = doc['title'].toString().toLowerCase();
                        return title.contains(_searchQuery);
                      }).toList();
                    }

                    // Check if no results found
                    if (filteredDocs.isEmpty && _searchQuery.isNotEmpty) {
                      return SliverToBoxAdapter(
                        child: Center(
                          child: Padding(
                            padding: const EdgeInsets.only(top: 100),
                            child: Column(
                              children: [
                                Icon(
                                  Icons.search_off,
                                  size: 64,
                                  color: Colors.white70,
                                ),
                                SizedBox(height: 16),
                                Text(
                                  'No pins found for "$_searchQuery"',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 18,
                                  ),
                                ),
                                SizedBox(height: 8),
                                TextButton(
                                  onPressed: () {
                                    setState(() {
                                      _searchController.clear();
                                      _searchQuery = "";
                                    });
                                  },
                                  child: Text(
                                    'Clear search',
                                    style: TextStyle(
                                      color: Colors.blue[200],
                                      fontSize: 16,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    }

                    return SliverMasonryGrid(
                      gridDelegate:
                          SliverSimpleGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                      ),
                      mainAxisSpacing: 12,
                      crossAxisSpacing: 12,
                      delegate: SliverChildBuilderDelegate(
                        (context, index) {
                          final data = filteredDocs[index];
                          final imageUrl = generatePresignedUrl(
                              key: "gambar/${data['image']}");

                          final dynamic_height = index % 3 == 0
                              ? 280.0
                              : index % 3 == 1
                                  ? 350.0
                                  : 320.0;

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
                                      height: dynamic_height,
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
                                        padding: EdgeInsets.all(12),
                                        child: Text(
                                          data["title"],
                                          style: TextStyle(
                                            color: Colors.white,
                                            fontSize: 16,
                                            fontWeight: FontWeight.w600,
                                          ),
                                          maxLines: 2,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          );
                        },
                        childCount: filteredDocs.length,
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
