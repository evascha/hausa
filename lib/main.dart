import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:convert';
import 'package:convert/convert.dart';
import 'package:http/http.dart' as http;
import 'package:logging/logging.dart';
import 'package:sqflite/sqflite.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'Categories.dart';
import 'Favorites.dart';
import 'LexemeEntry.dart';
import 'LikedEntry.dart';
import 'SearchingRoute.dart';
import 'SettingsRoute.dart';

final log = Logger('HausaApp');


/// Flutter code sample for [AppBar].
/// Future Class for the SparqlQuery
Future<List<LexemeEntry>> fetchSparql(String searchQuery) async {
  final endpointUrl = "https://query.wikidata.org/sparql";
  final query = '''
    SELECT ?lexemeId ?lemma ?wird_beschrieben_in_URL ?full_work_at WHERE {
  ?lexemeId dct:language wd:Q3915462;
    wikibase:lemma ?lemma.
  ?lexemeId p:P973 [ps:P973 ?wird_beschrieben_in_URL;
                   pq:P953 ?full_work_at;
                  ]. 
  FILTER (contains(lcase(?lemma), "${searchQuery.toLowerCase()}")).
}
  ''';

  try {
    final response =
    await http.get(Uri.parse('$endpointUrl?format=json&query=$query'));

    if (response.statusCode == 200) {
      final parsedResponse = jsonDecode(response.body);
      final searchResults = processSparqlResults(parsedResponse);
      return searchResults;
    } else {
      // Handle the case when the server does not return a 200 OK response.
      throw Exception('Failed to load search results');
    }
  } catch (e) {
    // Handle any exceptions that may occur during the search.
    throw Exception('Search failed: $e');
  }
}



List<LexemeEntry> processSparqlResults(dynamic sparqlResults) {
  final List<LexemeEntry> results = [];

  try {
    final List<dynamic> bindings = sparqlResults['results']['bindings'];
    String? lemma;
    for (var binding in bindings) {
      print("working on this binding:");
      print(binding);
      lemma = binding['lemma']['value'];
      final String? full_work_at = binding['full_work_at']['value'];
      String lexemeId = "L23414";
      if (binding['lexemeId'] != null) {
        lexemeId = binding['lexemeId']['value'];
      }
      if (lemma != null && full_work_at != null && lexemeId != null) {
        results.add(LexemeEntry(
            lemma: lemma, full_work_at: full_work_at, lexemeId: lexemeId));
      }
    }
  } catch (e) {
    // Handle any exceptions or errors here
    print('Error processing SPARQL results: $e');
  }

  return results;
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const SignDictionary());
}

class SignDictionary extends StatefulWidget {

  const SignDictionary({Key? key}) : super(key: key);

  @override
  SignDictionaryState createState() => SignDictionaryState();
}

class SignDictionaryState extends State<SignDictionary> {
  late Future<List<LexemeEntry>> futureSparql;


  @override
  void initState() {
    super.initState();
    initializeData();
  }

  Future<void> initializeData() async {
    futureSparql = fetchSparql('');
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Maganar hannu',
      home: _HausaApp(futureSparql: futureSparql),
    );
  }
}

class _HausaApp extends StatelessWidget {
  final Future<List<LexemeEntry>> futureSparql;

  _HausaApp({required this.futureSparql});

  get controller => null;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(title: const Text('maganar hannu'), actions: <Widget>[
          IconButton(
              icon: const Icon(Icons.filter),
              tooltip: 'Filter your language',
              onPressed: () {}),
          IconButton(
              icon: const Icon(Icons.search),
              tooltip: 'Searching button',
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => SearchingRoute()),
                );
              }),
          IconButton(
              icon: const Icon(Icons.settings),
              tooltip: 'Settings button',
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => const SettingsRoute()),
                );
              }),
        ]),
        body: ListView(
          children: <Widget>[
            Container(
                height: 100,
                color: Colors.white,
                child: GestureDetector(
                  onTap: () {
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => const Favorites()
                        ));
                  },
                  child: const Center(child: Text('Favorite entries')),
                )),
            Container(
              height: 100,
              color: Colors.white,
              child: const Center(child: Text('Recent searches')),
            ),
            Container(
              height: 100,
              color: Colors.white,
              child: const Center(child: Text('Recent views')),
            ),
          ],
        ),
        bottomNavigationBar: BottomAppBar(
          child: IconButton(
              icon: const Icon(Icons.category),
              tooltip: 'Categories button',
              onPressed: () {
                Navigator.push(context,
                    MaterialPageRoute(
                        builder: (context) => CategoriesClass()));
              }),
        ));
  }
}



//Database as a Singleton



/*
class EntryWidget extends StatelessWidget {
  final LikedEntry data;
  final Function(LikedEntry) onLikePressed;

  EntryWidget({required this.data, required this.onLikePressed});

  @override
  Widget build(BuildContext context) {
    return Column(children: <Widget>[
      Text(data.lexemeId1 as String),
      Text(data.lemma1),
      Image.network(data.full_work_at1),
      ElevatedButton(
        onPressed: () {
          final likedEntry = LikedEntry(
            lexemeId1: data.lexemeId1.hashCode,
            lemma1: data.lemma1,
            full_work_at1: data.full_work_at1,
          );
          onLikePressed(likedEntry);
        },
        child: Text("Like"),
      )
    ]);
  }
}
*/


