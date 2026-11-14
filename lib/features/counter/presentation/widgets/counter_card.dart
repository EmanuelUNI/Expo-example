import 'package:flutter/material.dart';

import '../../../../app/theme.dart';
import '../../domain/entities/counter.dart';
import '../mvi/counter_intent.dart';
import '../mvi/counter_state.dart';
import 'lab_card.dart';

class CounterCard extends StatelessWidget {
  const CounterCard({required this.state, required this.onIntent, super.key});

  final CounterState state;
  final ValueChanged<CounterIntent> onIntent;

  @override
  Widget build(BuildContext context) {
    final statusLabel = switch (state.status) {
      CounterStatus.initial || CounterStatus.loading => 'Cargando',
      CounterStatus.updating => 'Procesando',
      CounterStatus.ready => 'Listo para interactuar',
      CounterStatus.failure => 'Cambio pendiente',
    };
    final increment = FilledButton.icon(
      key: const Key('increment'),
      onPressed: state.canInteract && state.counter.value < Counter.maximum
          ? () => onIntent(const IncrementCounter())
          : null,
      icon: const Icon(Icons.add_rounded),
      label: const Text('Incrementar'),
    );
    final decrement = OutlinedButton(
      key: const Key('decrement'),
      onPressed: state.canInteract && state.counter.value > Counter.minimum
          ? () => onIntent(const DecrementCounter())
          : null,
      child: const Tooltip(
        message: 'Decrementar',
        child: Icon(Icons.remove_rounded, semanticLabel: 'Decrementar'),
      ),
    );

    return LabCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Eyebrow('01 / PRUÉBALO'),
          const SizedBox(height: 8),
          Text(
            'Un contador, muchas ideas.',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 24),
          Center(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
              decoration: BoxDecoration(
                color: AppColors.mint,
                borderRadius: BorderRadius.circular(30),
              ),
              child: Text(
                statusLabel,
                style: const TextStyle(
                  color: AppColors.green,
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
          const SizedBox(height: 16),
          Semantics(
            liveRegion: true,
            label: state.initialized
                ? 'Valor del contador: ${state.counter.value}'
                : 'Cargando contador',
            child: ExcludeSemantics(
              child: SizedBox(
                height: 138,
                child: FittedBox(
                  fit: BoxFit.scaleDown,
                  child: Text(
                    state.initialized ? '${state.counter.value}' : '—',
                    key: const Key('counter-value'),
                    style: const TextStyle(
                      fontSize: 112,
                      height: 1,
                      fontWeight: FontWeight.w800,
                      letterSpacing: -7,
                    ),
                  ),
                ),
              ),
            ),
          ),
          const Center(
            child: Text(
              'ESTADO ACTUAL',
              style: TextStyle(
                fontSize: 10,
                letterSpacing: 2,
                color: AppColors.muted,
              ),
            ),
          ),
          const SizedBox(height: 24),
          LayoutBuilder(
            builder: (context, constraints) {
              final compact =
                  constraints.maxWidth /
                      MediaQuery.textScalerOf(context).scale(1) <
                  270;
              if (compact) {
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [increment, const SizedBox(height: 10), decrement],
                );
              }
              return Row(
                children: [
                  decrement,
                  const SizedBox(width: 12),
                  Expanded(child: increment),
                ],
              );
            },
          ),
          const SizedBox(height: 8),
          TextButton.icon(
            key: const Key('reset'),
            onPressed: state.canInteract && state.counter.value != 0
                ? () => onIntent(const ResetCounter())
                : null,
            icon: const Icon(Icons.restart_alt_rounded, size: 18),
            label: const Text('Reiniciar contador'),
          ),
          const SizedBox(height: 12),
          SizedBox(
            height: 3,
            child: state.isBusy
                ? const LinearProgressIndicator(
                    semanticsLabel: 'Procesando intención',
                  )
                : const SizedBox.shrink(),
          ),
          if (state.errorMessage != null) ...[
            const SizedBox(height: 16),
            Semantics(
              liveRegion: true,
              child: Text(
                state.errorMessage!,
                style: TextStyle(color: Theme.of(context).colorScheme.error),
              ),
            ),
            if (state.status == CounterStatus.failure)
              OutlinedButton.icon(
                key: const Key('retry'),
                onPressed: () => onIntent(const RetryCounter()),
                icon: const Icon(Icons.refresh_rounded),
                label: const Text('Reintentar'),
              ),
          ],
          const Divider(height: 32),
          const Text(
            'De 0 a 99 · Guardado en memoria durante esta sesión.',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 12, color: AppColors.muted, height: 1.5),
          ),
        ],
      ),
    );
  }
}
