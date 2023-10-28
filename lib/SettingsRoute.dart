
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

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
          padding: const EdgeInsets.symmetric(horizontal: 8.0),
        ),
      ),
    );
  }
}
