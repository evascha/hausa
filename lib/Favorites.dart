
import 'package:flutter/material.dart';

import 'Categories.dart';
import 'DescPT.dart';
import 'LikedEntry.dart';
import 'main.dart';

class Favorites extends StatefulWidget {

  const Favorites({Key? key}) : super(key: key);

  @override
  State<Favorites> createState() => _MyFavoritesPages();
}

class _MyFavoritesPages extends State<Favorites> {
  late Future<Categories> futureCategories;
  List<LikedEntry> likedEntries = []; // Store liked entries

  @override
  void initState() {
    super.initState();
    getLikedEntries(); // Load liked entries when the screen loads
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Favorites'),
      ),
      body: ListView.builder(
        itemCount: likedEntries.length,
        itemBuilder: (context, index) {
          final entry = likedEntries[index];
          return DescPT(
            futureCategories: futureCategories,
            // Provide the appropriate futureCategories
            onLikePressed: (data) {
              // Handle unliking here, if needed
            },
            likedEntries: likedEntries, // Pass the list of liked entries
          );
        },
      ),
    );
  }
}