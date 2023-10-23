import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
//import 'package:flutter_launcher_icons/android.dart';
import 'dart:convert';
import 'package:convert/convert.dart';
import 'package:http/http.dart' as http;

/// Flutter code sample for [AppBar].
/// Future Class for the SparqlQuery
Future<List<ResultItem>> fetchSparql(String searchQuery) async {
  final endpointUrl = "https://query.wikidata.org/sparql";
  final query = '''
    SELECT ?lemma ?full_work_at WHERE {
      ?lexeme dct:language wd:Q3915462;
             wikibase:lemma ?lemma.
      ?lexeme p:P973 [ps:P973 ?full_work_at].
      FILTER (contains(lcase(?lemma), "${searchQuery.toLowerCase()}")).
    }
  ''';

  try {
    final response = await http.get(Uri.parse('$endpointUrl?format=json&query=$query'));

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

class ResultItem {
  final String lemma;
  final String full_work_at;

  ResultItem({required this.lemma, required this.full_work_at});
}


List<ResultItem> processSparqlResults(dynamic sparqlResults) {
  final List<ResultItem> results = [];

  try {
    final List<dynamic> bindings = sparqlResults['results']['bindings'];

    for (var binding in bindings) {
      final String? lemma = binding['lemma']['value'];
      final String? full_work_atValue = binding['full_work_at']['value'];

      if (lemma != null && full_work_atValue != null) {
        results.add(ResultItem(lemma: lemma, full_work_at: full_work_atValue));
      }
    }
  } catch (e) {
    // Handle any exceptions or errors here
    print('Error processing SPARQL results: $e');
  }

  return results;
}

void main() {
  runApp(const SignDictionary());
}

class SignDictionary extends StatefulWidget {
  const SignDictionary({Key? key}) : super(key: key);

  @override
  SignDictionaryState createState() => SignDictionaryState();
}

class SignDictionaryState extends State<SignDictionary> {
  late Future<List<ResultItem>> futureSparql;

  @override
  void initState() {
    super.initState();
    futureSparql = fetchSparql('');
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Maganar hannu',
      home: _AppBarExample(futureSparql: futureSparql,),
      );
  }
}

class _AppBarExample extends StatelessWidget {
  final Future<List<ResultItem>> futureSparql;

  _AppBarExample({required this.futureSparql});

  get controller => null;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text('maganar hannu'),
            actions: <Widget>[
              IconButton(
                  icon: const Icon(Icons.filter),
                  tooltip: 'Filter your language',
                  onPressed: () {}
              ),
              IconButton(
                  icon: const Icon(Icons.search),
                  tooltip: 'Searching button',
                  onPressed: () {
                    Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => SearchingRoute()),
                        );
                    }
              ),
              IconButton(
                  icon: const Icon(Icons.settings),
                  tooltip: 'Settings button',
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const SettingsRoute()),
                    );
                  }
              ),
            ]
        ),
        body: ListView(
            children: <Widget>[
              Container(
                height: 100,
                color: Colors.white,
                child: const Center(child: Text('Favorites')),
              ),
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
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => CategoriesRoute(futureSparql: futureSparql)),
                  );
                }
            ),
        )
    );
  }
}

class SettingsRoute extends StatelessWidget {
  const SettingsRoute({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings Route'),
      ),
      body: Padding(
        padding: EdgeInsets.all(8.0),
        child: Container(
          padding: const EdgeInsets.symmetric(
              horizontal: 8.0),
        ),
      ),
    );
  }
}

class SearchingRoute extends StatefulWidget {
  @override
  SearchScreenState createState() => SearchScreenState();
}

class SearchScreenState extends State<SearchingRoute> {
  TextEditingController searchController = TextEditingController();

  //String query = ""; // Store the search query


  // Function to perform the search
  void search() async {
    // Perform your search with the query (e.g., using SPARQL)
    // Fetch and process the search results
    String searchQuery = searchController.text;
    // Navigate to the results screen or widget
    final searchResults = await fetchSparql(searchQuery);
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => SearchResultsScreen(searchResults: fetchSparql(searchQuery)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Searching screen'),
      ),
      body: Center(
        child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              TextField(
                controller: searchController, // Use the controller to capture user input
                decoration: InputDecoration(
                  hintText: "Enter your search query",
                ),
                onChanged: (value) {
                  setState(() {
                    // The searchQuery will be updated as the user types
                  });
                },
              ),
            ElevatedButton(
              onPressed: () {
                search();
              },
              child: Text("Search"),
            )
          ]

        ),
      ),
    );
  }
}


class SearchResultsScreen extends StatelessWidget {
  final Future<List<ResultItem>> searchResults;

  SearchResultsScreen({required this.searchResults});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Search Results"),
      ),
      body: FutureBuilder<List<ResultItem>>(
        future: searchResults,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(child: Text('No results found.'));
          } else {
            final List<ResultItem> results = snapshot.data!;
            return ListView.builder(
              itemCount: results.length,
              itemBuilder: (context, index) {
                final ResultItem result = results[index];
                final String imageUrl = result.full_work_at;

                return ListTile(
                  title: Text(result.lemma),
                  subtitle: Image.network(imageUrl),
                );
              },
            );
          }
        },
      ),
    );
  }
}



class CategoriesRoute extends StatelessWidget {
  final Future<List<ResultItem>> futureSparql;

  CategoriesRoute({required this.futureSparql});

  get controller => null;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text('Categories screen'),
        ),
        body: ListView(
            children: <Widget>[
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
             /* Container(
                height: 100,
                color: Colors.white,
                  child: GestureDetector(
                    onTap: () {
                      Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => DescPT(futureSparql: futureSparql)),
                      );
                    },
                    child: const Center(child: Text('Describing people and things')),
              )
              ),*/
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
                child: const Center(child: Text('Things and activites in the house')),
              ),
              Container(
                height: 100,
                color: Colors.white,
                child: const Center(child: Text('Religion')),
              ),
            ])
    );
  }
}


/*
class DescPT extends StatelessWidget {
  final Future<List<ResultItem>> futureSparql;

  DescPT({required this.futureSparql});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Describing people and things'),
      ),
      body: ListView(
        children: <Widget>[
        FutureBuilder<List<ResultItem>>(
          future: futureSparql,
          builder: (context, snapshot) {
            if (snapshot.hasData) {
              return Column(
                children: <Widget> [
                  Text(snapshot.data!.lexemeId),
                  Text(snapshot.data!.lemma),
                  Text(snapshot.data!.wird_beschrieben_in_URL),
                  Image.network(snapshot.data!.full_work_at),
                ]
              );
            } else if(snapshot.hasError) {
              return Text('${snapshot.error}');
            }
            return const CircularProgressIndicator();
          }
      ),
      ]
      ),
    );
  }
}

 */