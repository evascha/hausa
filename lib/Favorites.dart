import 'package:flutter/material.dart';
import 'package:hausa/LexemeEntry.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'Categories.dart';
import 'DescPT.dart';
import 'LikedEntry.dart';
import 'main.dart';
import 'dart:convert';

class Favorites extends StatefulWidget {
  const Favorites({Key? key}) : super(key: key);

  @override
  State<Favorites> createState() => _FavoritesPages();
}

class _FavoritesPages extends State<Favorites> {
  List<LexemeEntry> lexemeEntries = [];


  @override
  initState() {
    log.warning("Start favorites");
    fillPage();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text('Favorites'),
        ),
        body: FutureBuilder<List<LexemeEntry>>(
            future: fillPage(),
            builder: (context, snapshot) {
              if (snapshot.hasData) {
                return ListView(children: [
                  ListTile(
                    title: Text(snapshot.data!.first.lexemeId
                        .replaceAll("http://www.wikidata.org/entity/", '') + snapshot.data!.first.lemma + snapshot.data!.first.gloss),

                    subtitle: Image.network(snapshot.data!.first.full_work_at)
                  )
                ]);
              } else return Text("ja das hat jetzt nicht geklappt");
            }));
  }

  Future<List<String>?> getLikedEntries() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final List<String>? items = prefs.getStringList('Favorites');
    return items;
  }

  Future<List<LexemeEntry>> fillPage() async {
    log.warning("Starting to load liked entries");
    List<String>? lexemeEntry = await getLikedEntries();
    log.warning(lexemeEntry);
    LexemeEntry entry = await fetchLexeme(lexemeEntry!.first);
    log.info(entry);
    entry.lexemeId = lexemeEntry.first;
    lexemeEntries.add(entry);
    log.info(lexemeEntries);

    return lexemeEntries;
  }

  Future<LexemeEntry> fetchLexeme(String lexemeId) async {
    final response = await http.get(Uri.parse(
        'https://query.wikidata.org/sparql?format=json&query=%20SELECT%20%3FlexemeId%20%3Flemma%20%3Fwird_beschrieben_in_URL%20%3Ffull_work_at%20%3Fgloss%20WHERE%20%7B%0A%20%20%3F' +
        lexemeId +
    '%20dct%3Alanguage%20wd%3AQ3915462%3B%0A%20%20%20%20ontolex%3Asense%20%3Fsense%3B%0A%20%20%20%20wikibase%3Alemma%20%3Flemma%3B%0A%20%20%20%20p%3AP973%20_%3Ab10.%0A%20%20_%3Ab10%20ps%3AP973%20%3Fwird_beschrieben_in_URL%3B%0A%20%20%20%20pq%3AP953%20%3Ffull_work_at.%0A%20%20%3Fsense%20skos%3Adefinition%20%3Fgloss%20%20%0A%20%20FILTER(LANG(%3Fgloss)%20%3D%20%22en%22)%0A%20%20%0A%7D%0A%0A'));

  if (response.statusCode == 200) {
      // If the server did return a 200 OK response,
      // then parse the JSON.
      final parsedResponse = jsonDecode(response.body);
      print(parsedResponse);
      return processSparqlResults(parsedResponse).first;
    } else {
      // If the server did not return a 200 OK response,
      // then throw an exception.
      throw Exception('Failed to load album');
    }
  }
}
