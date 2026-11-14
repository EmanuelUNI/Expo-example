import 'dart:async';

import 'package:flutter/material.dart';

import '../../../../app/theme.dart';
import '../mvi/counter_intent.dart';
import '../mvi/counter_store.dart';
import '../widgets/architecture_card.dart';
import '../widgets/counter_card.dart';
import '../widgets/flow_card.dart';
import '../widgets/history_card.dart';

/// La vista solo observa y emite intenciones: no modifica el contador.
class CounterPage extends StatelessWidget {
  const CounterPage({required this.store, super.key});

  final CounterStore store;

  void _onIntent(CounterIntent intent) => unawaited(store.dispatch(intent));

  @override
  Widget build(BuildContext context) => Scaffold(
    body: SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 28),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 1080),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const _Header(),
                const SizedBox(height: 44),
                Text(
                  'Un clic.\nUn nuevo estado.',
                  style: Theme.of(context).textTheme.headlineLarge,
                ),
                const SizedBox(height: 14),
                const Text(
                  'Descubre Model–View–Intent en acción.\nInteractúa con el contador y sigue el recorrido de cada cambio.',
                  style: TextStyle(
                    fontSize: 16,
                    color: AppColors.muted,
                    height: 1.6,
                  ),
                ),
                const SizedBox(height: 30),
                ListenableBuilder(
                  listenable: store,
                  builder: (context, child) {
                    final state = store.state;
                    return LayoutBuilder(
                      builder: (context, constraints) {
                        final counter = CounterCard(
                          state: state,
                          onIntent: _onIntent,
                        );
                        final flow = FlowCard(state: state);
                        final history = HistoryCard(state: state);
                        if (constraints.maxWidth < 800) {
                          return Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              counter,
                              const SizedBox(height: 20),
                              flow,
                              const SizedBox(height: 20),
                              history,
                            ],
                          );
                        }
                        return Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.stretch,
                                children: [
                                  counter,
                                  const SizedBox(height: 20),
                                  history,
                                ],
                              ),
                            ),
                            const SizedBox(width: 24),
                            Expanded(child: flow),
                          ],
                        );
                      },
                    );
                  },
                ),
                const SizedBox(height: 24),
                const ArchitectureCard(),
                const SizedBox(height: 28),
                const Text(
                  'MVI LAB   /   Flutter + Dart   /   Aprende haciendo',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 11,
                    color: AppColors.muted,
                    letterSpacing: 0.5,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    ),
  );
}

class _Header extends StatelessWidget {
  const _Header();

  @override
  Widget build(BuildContext context) => Wrap(
    crossAxisAlignment: WrapCrossAlignment.center,
    alignment: WrapAlignment.spaceBetween,
    spacing: 20,
    runSpacing: 16,
    children: [
      Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.all(9),
            decoration: BoxDecoration(
              color: AppColors.green,
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(
              Icons.sync_alt_rounded,
              color: Colors.white,
              size: 22,
            ),
          ),
          const SizedBox(width: 12),
          const Flexible(
            child: Text.rich(
              TextSpan(
                children: [
                  TextSpan(
                    text: 'MVI',
                    style: TextStyle(fontWeight: FontWeight.w800),
                  ),
                  TextSpan(
                    text: ' Lab',
                    style: TextStyle(color: AppColors.muted),
                  ),
                ],
              ),
              style: TextStyle(fontSize: 21, letterSpacing: -0.5),
            ),
          ),
        ],
      ),
      Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          border: Border.all(color: AppColors.line),
          borderRadius: BorderRadius.circular(30),
        ),
        child: const Text(
          'FLUTTER · CLEAN ARCHITECTURE',
          style: TextStyle(
            fontSize: 10,
            fontWeight: FontWeight.w700,
            letterSpacing: 0.7,
            color: AppColors.muted,
          ),
        ),
      ),
    ],
  );
}
