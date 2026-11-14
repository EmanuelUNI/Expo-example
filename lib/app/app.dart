import 'dart:async';

import 'package:flutter/material.dart';

import '../features/counter/presentation/mvi/counter_intent.dart';
import '../features/counter/presentation/mvi/counter_store.dart';
import '../features/counter/presentation/pages/counter_page.dart';
import 'dependencies.dart';
import 'theme.dart';

class MviApp extends StatelessWidget {
  const MviApp({super.key});

  @override
  Widget build(BuildContext context) => MaterialApp(
    title: 'MVI Lab · Un clic, un estado',
    debugShowCheckedModeBanner: false,
    theme: buildTheme(),
    home: const _CounterFeature(),
  );
}

class _CounterFeature extends StatefulWidget {
  const _CounterFeature();

  @override
  State<_CounterFeature> createState() => _CounterFeatureState();
}

class _CounterFeatureState extends State<_CounterFeature> {
  late final CounterStore _store;

  @override
  void initState() {
    super.initState();
    _store = createCounterStore();
    unawaited(_store.dispatch(const LoadCounter()));
  }

  @override
  void dispose() {
    _store.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => CounterPage(store: _store);
}
