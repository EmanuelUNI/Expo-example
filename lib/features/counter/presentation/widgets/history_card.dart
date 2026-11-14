import 'package:flutter/material.dart';

import '../../../../app/theme.dart';
import '../mvi/counter_state.dart';
import 'lab_card.dart';

class HistoryCard extends StatelessWidget {
  const HistoryCard({required this.state, super.key});

  final CounterState state;

  @override
  Widget build(BuildContext context) => LabCard(
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const Eyebrow('03 / OBSERVA LOS CAMBIOS'),
        const SizedBox(height: 8),
        Text(
          'Cada cambio cuenta.',
          style: Theme.of(context).textTheme.titleLarge,
        ),
        const SizedBox(height: 4),
        Text(
          'Cambios confirmados: ${state.revision} · últimas 8 transiciones',
          style: const TextStyle(fontSize: 12, color: AppColors.muted),
        ),
        const SizedBox(height: 20),
        if (state.history.isEmpty)
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: AppColors.canvas,
              borderRadius: BorderRadius.circular(14),
            ),
            child: const Column(
              children: [
                Icon(Icons.history_rounded, color: AppColors.muted, size: 28),
                SizedBox(height: 8),
                Text(
                  'Tu primera intención empieza aquí.',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontWeight: FontWeight.w600),
                ),
                SizedBox(height: 4),
                Text(
                  'Pulsa Incrementar y observa la transición de 0 a 1.',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 12, color: AppColors.muted),
                ),
              ],
            ),
          )
        else
          for (final transition in state.history)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 10),
              child: Wrap(
                alignment: WrapAlignment.spaceBetween,
                crossAxisAlignment: WrapCrossAlignment.center,
                spacing: 16,
                runSpacing: 6,
                children: [
                  Text(
                    '#${transition.revision.toString().padLeft(2, '0')}   ${transition.intent.label}',
                    style: const TextStyle(fontWeight: FontWeight.w600),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 5,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.mint,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      '${transition.before} → ${transition.after}',
                      style: const TextStyle(
                        color: AppColors.green,
                        fontFamily: 'monospace',
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ],
              ),
            ),
      ],
    ),
  );
}
