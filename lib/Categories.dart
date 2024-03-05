
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'DescPT.dart';
import 'main.dart';

class Categories {
  final String lemma;
  final String lexemeId;
  final String full_work_at;
  final String gloss;

  const Categories({
    required this.lemma,
    required this.lexemeId,
    required this.full_work_at,
    required this.gloss
  });

  factory Categories.fromJson(Map<String, dynamic> json) {
    final List<dynamic> bindings = json['results']['bindings'];

    // Check if the 'bindings' array is not empty
    if (bindings.isNotEmpty) {
      final Map<String, dynamic> firstBinding = bindings[0];

      final Map<String, dynamic> lexemeId = firstBinding['lexemeId'];
      final String lexemeIdValue = lexemeId['value'] as String;

      final Map<String, dynamic> lemma = firstBinding['lemma'];
      final String lemmaValue = lemma['value'] as String;

      final Map<String, dynamic> full_work_at = firstBinding['full_work_at'];
      final String full_work_atValue = full_work_at['value'] as String;

      final Map<String, dynamic> gloss = firstBinding['gloss'];
      final String glossValue = gloss['value'] as String;

      return Categories(
          lexemeId: lexemeIdValue,
          lemma: lemmaValue,
          full_work_at: full_work_atValue,
          gloss: glossValue);
    } else {
      // Handle the case when the 'bindings' array is empty
      return Categories(
          lexemeId: "n",
          lemma: "l",
          full_work_at: "w",
          gloss: "g"); // or set default values as needed
    }
  }
}

class CategoriesClass extends StatefulWidget {


  CategoriesClass({Key? key}) : super(key: key);

  Future<Categories> get futureCategories => fetchAlbum();

  @override
  State<CategoriesClass> createState() =>
      _CategoriesRoute(futureCategories: futureCategories);

}

class _CategoriesRoute extends State<CategoriesClass> {

  late Future<Categories> futureCategories;

  _CategoriesRoute({required this.futureCategories});

  // Named constructor for db

  @override
  void initState() {
    super.initState();
    initializeData();
  }

  Future<void> initializeData() async {
    futureCategories = fetchAlbum();
  }

  get controller => null;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text('Categories'),
      ),
      body: ListView(children: <Widget>[
        Container(
          height: 100,
          color: Colors.white,
          child: const Center(child: Text('Family')),
        ),
        Container(
          height: 100,
          color: Colors.white,
          child: const Center(child: Text('Meeting and Communication')),
        ),
        Container(
            height: 100,
            color: Colors.white,
            child: GestureDetector(
              onTap: () {
                Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) =>
                            DescPT(
                              futureCategories: futureCategories,
                              onLikePressed: (LikedEntry) {},
                              lexemeEntry: [],)));
              },
              child:
              const Center(child: Text('Describing people and things')),
            )),
        Container(
          height: 100,
          color: Colors.white,
          child: const Center(child: Text('Commerce and counting')),
        ),
        Container(
          height: 100,
          color: Colors.white,
          child: const Center(child: Text('Everyday activities')),
        ),
        Container(
          height: 100,
          color: Colors.white,
          child: const Center(child: Text('Time and weather')),
        ),
        Container(
          height: 100,
          color: Colors.white,
          child: const Center(child: Text('Education')),
        ),
        Container(
          height: 100,
          color: Colors.white,
          child:
          const Center(child: Text('Things and activites in the house')),
        ),
        Container(
          height: 100,
          color: Colors.white,
          child: const Center(child: Text('Religion')),
        ),
      ]),
    );
  }
}

Future<Categories> fetchAlbum() async {
  final response = await http.get(Uri.parse(
      'https://query.wikidata.org/sparql?format=json&query=%20SELECT%20%3FlexemeId%20%3Flemma%20%3Fwird_beschrieben_in_URL%20%3Ffull_work_at%20%3Fgloss%20WHERE%20%7B%0A%20%20%3FlexemeId%20dct%3Alanguage%20wd%3AQ3915462%3B%0A%20%20%20%20ontolex%3Asense%20%3Fsense%3B%0A%20%20%20%20wikibase%3Alemma%20%3Flemma%3B%0A%20%20%20%20p%3AP973%20_%3Ab10.%0A%20%20_%3Ab10%20ps%3AP973%20%3Fwird_beschrieben_in_URL%3B%0A%20%20%20%20pq%3AP953%20%3Ffull_work_at.%0A%20%20%3Fsense%20skos%3Adefinition%20%3Fgloss%20%20%0A%20%20FILTER(LANG(%3Fgloss)%20%3D%20%22en%22)%0A%20%20%0A%7D%0A%0A'));

  if (response.statusCode == 200) {
    // If the server did return a 200 OK response,
    // then parse the JSON.
    return Categories.fromJson(
        jsonDecode(response.body) as Map<String, dynamic>);
  } else {
    // If the server did not return a 200 OK response,
    // then throw an exception.
    throw Exception('Failed to load album');
  }
}