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
                        .replaceAll("http://www.wikidata.org/entity/", '')),
                    subtitle: Image.network(snapshot.data!.first.full_work_at),
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
    lexemeEntries.add(entry);
    log.info(lexemeEntries);

    return lexemeEntries;
  }

  Future<LexemeEntry> fetchLexeme(String lexemeId) async {
    final response = await http.get(Uri.parse(
        'https://query.wikidata.org/sparql?format=json&query=SELECT%20%3FlexemeId%20%3Flemma%20%3Fwird_beschrieben_in_URL%20%3Ffull_work_at%20WHERE%20%7B%0A%20%20%20wd%3A' +
            lexemeId +
            '%20wikibase%3Alemma%20%3Flemma.%0A%20%20%20wd%3A' +
            lexemeId +
            '%20p%3AP973%20%5Bps%3AP973%20%3Fwird_beschrieben_in_URL%3B%0A%20%20%20%20%20%20%20%20%20%20%20%20%20%20%20%20%20%20%20pq%3AP953%20%3Ffull_work_at%3B%0A%20%20%20%20%20%20%20%20%20%20%20%20%20%20%20%20%20%20%5D.%20%0A%7D%0A'));
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
