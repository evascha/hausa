import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'LexemeEntry.dart';
import 'main.dart';

class SearchingRoute extends StatefulWidget {
  SearchingRoute({Key? key}) : super(key: key);

  @override
  SearchScreenState createState() => SearchScreenState();
}

class SearchScreenState extends State<SearchingRoute> {
  TextEditingController searchController = TextEditingController();
  late Future<List<LexemeEntry>> futureSparql = fetchSparql("");

  @override
  void initState() {
    super.initState();
    initializeData();
  }

  Future<void> initializeData() async {
    futureSparql = fetchSparql('');
  }

  // Function to perform the search
  void search(BuildContext context) async {
    // Perform your search with the query (e.g., using SPARQL)
    // Fetch and process the search results
    String searchQuery = searchController.text;
    // Navigate to the results screen or widget
    final searchResults = await fetchSparql(searchQuery);
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => SearchResultsScreen(searchResults: searchResults),
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
                controller: searchController,
                // Use the controller to capture user input
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
                  search(context);
                },
                child: Text("Search"),
              )
            ]),
      ),
    );
  }
}

class SearchResultsScreen extends StatelessWidget {
  final List<LexemeEntry> searchResults;

  SearchResultsScreen({required this.searchResults});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Search Results"),
      ),
      body: searchResults.isEmpty
          ? Center(child: Text('No results found.'))
          : ListView.builder(
              itemCount: searchResults.length,
              itemBuilder: (context, index) {
                final LexemeEntry result = searchResults[index];
                // Assuming result.full_work_at contains the image URL
                return ListTile(
                  title: Text(result.lemma),
                  subtitle: Image.network(result.full_work_at),
                );
              },
            ),
    );
  }
}
