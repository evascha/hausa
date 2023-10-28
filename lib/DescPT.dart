
import 'package:flutter/material.dart';

import 'Categories.dart';
import 'LikedEntry.dart';
import 'main.dart';

class DescPT extends StatefulWidget {
  final Function(LikedEntry) onLikePressed;
  final Future<Categories> futureCategories;

  DescPT(
      {required this.futureCategories, required this.onLikePressed, required List<
          LikedEntry> likedEntries});

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
                    Text(data!.lexemeId)
                  ],
                ),
                ElevatedButton(
                  onPressed: () {
                    onLikePressed(data!.lexemeId);
                    setState(() {
                      isButtonPressed = true;
                    });
                  },
                  child: Text("Like"),
                  style: ButtonStyle(
                    backgroundColor: MaterialStateProperty.resolveWith<Color>(
                          (Set<MaterialState> states) {
                        if (states.contains(MaterialState.pressed)) {
                          // Change the color when the button is pressed
                          return Colors.blue; // Replace with your desired color
                        }
                        return Colors.grey; // Replace with your default color
                      },
                    ),
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


