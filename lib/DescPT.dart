import 'package:flutter/material.dart';
import 'package:hausa/LexemeEntry.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'Categories.dart';
import 'LikedEntry.dart';
import 'main.dart';

class DescPT extends StatefulWidget {
  final Function(LexemeEntry) onLikePressed;
  final Future<Categories> futureCategories;

  DescPT(
      {required this.futureCategories,
      required this.onLikePressed,
      required List<LexemeEntry> lexemeEntry});

  @override
  _DescPTState createState() => _DescPTState();
}

class _DescPTState extends State<DescPT> {
  bool isButtonPressed = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Describing people and things'),
      ),
      body: FutureBuilder<Categories>(
        future: widget.futureCategories,
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            final data = snapshot.data; // Extract the data here

            return ListView(
              children: <Widget>[
                Column(
                  children: <Widget>[
                    Text(data!.lexemeId.replaceAll("http://www.wikidata.org/entity/", '')),
                    Text(data!.lemma),
                    Image.network(data!.full_work_at),
                  ],
                ),
                ElevatedButton(
                  onPressed: () {
                    onLikePressed(data!.lexemeId.replaceAll("http://www.wikidata.org/entity/", ''));
                    setState(() {
                      isButtonPressed = true;
                    });
                  },
                  child: Text("Like"),
                  style: ButtonStyle(
                    backgroundColor: isButtonPressed
                        ? MaterialStatePropertyAll<Color>(Colors.red)
                        : MaterialStatePropertyAll<Color>(Colors.blue),
                  ),
                ),
              ],
            );
          } else if (snapshot.hasError) {
            return Text('${snapshot.error}');
          }
          return const Center(child: CircularProgressIndicator());
        },
      ),
    );
  }
}

Future<void> onLikePressed(String likedEntry) async {
  print(likedEntry);
  // Handle adding the liked entry to the database
  final SharedPreferences prefs = await SharedPreferences.getInstance();
  await prefs.setStringList('Favorites', <String>[likedEntry]);
  // You can also update the state to refresh the list of liked entries.
}