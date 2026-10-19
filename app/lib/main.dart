import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'data/repository.dart';
import 'screens/root_scaffold.dart';
import 'state/app_state.dart';
import 'theme.dart';

void main() {
  runApp(const CommunityRashanApp());
}

class CommunityRashanApp extends StatelessWidget {
  const CommunityRashanApp({super.key});

  @override
  Widget build(BuildContext context) {
    // Phase 1 runs on sample data. Swap MockRepository() for a
    // FirestoreRepository() once Firebase is configured (see README).
    return ChangeNotifierProvider<AppState>(
      create: (_) => AppState(MockRepository()),
      child: MaterialApp(
        title: 'Community Rashan',
        debugShowCheckedModeBanner: false,
        theme: buildTheme(Brightness.light),
        darkTheme: buildTheme(Brightness.dark),
        home: const RootScaffold(),
      ),
    );
  }
}
