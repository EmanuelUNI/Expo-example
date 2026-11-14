import 'package:flutter/material.dart';

import '../../../../app/theme.dart';
import '../mvi/counter_intent.dart';
import '../mvi/counter_state.dart';
import 'lab_card.dart';

class FlowCard extends StatelessWidget {
  const FlowCard({required this.state, super.key});

  final CounterState state;

  @override
  Widget build(BuildContext context) => LabCard(
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Eyebrow('02 / SIGUE EL RECORRIDO'),
        const SizedBox(height: 8),
        Text(
          'Así viaja tu intención.',
          style: Theme.of(context).textTheme.titleLarge,
        ),
        const SizedBox(height: 6),
        const Text(
          'Una sola dirección. Un estado predecible.',
          style: TextStyle(color: AppColors.muted),
        ),
        const SizedBox(height: 24),
        const _FlowStep(
          number: 'V',
          title: 'Vista',
          description: 'Recoge el clic y envía una intención.',
          code: 'onPressed → dispatch(intent)',
          color: Color(0xFF5069A3),
        ),
        _FlowStep(
          number: 'I',
          title: 'Intención',
          description: 'Describe qué quieres hacer.',
          code: state.lastIntent?.code ?? 'Esperando una intención…',
          color: const Color(0xFF7954A1),
        ),
        _FlowStep(
          number: '→',
          title: 'Procesamiento',
          description: state.isBusy
              ? 'Ejecutando el caso de uso…'
              : state.lastIntent is LoadCounter
              ? 'El caso de uso recupera el valor guardado.'
              : 'El caso de uso valida y guarda el valor.',
          code: state.lastIntent == null || state.lastIntent is LoadCounter
              ? 'GetCounter → repositorio'
              : 'UpdateCounter → repositorio',
          color: const Color(0xFFAD6D24),
        ),
        _FlowStep(
          number: 'M',
          title: 'Modelo / estado',
          description: switch (state.status) {
            CounterStatus.failure => 'Se conserva el último valor válido.',
            CounterStatus.initial ||
            CounterStatus.loading => 'Esperando el estado inicial…',
            CounterStatus.updating => 'El estado anterior sigue visible.',
            CounterStatus.ready => 'Nuevo estado; la vista lo representa.',
          },
          code: 'Counter(${state.counter.value}) · revisión ${state.revision}',
          color: AppColors.green,
          last: true,
        ),
        const SizedBox(height: 20),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: AppColors.mint,
            borderRadius: BorderRadius.circular(12),
          ),
          child: const Text(
            '↳ El estado vuelve a la vista y cierra el ciclo.',
            style: TextStyle(
              color: AppColors.green,
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    ),
  );
}

class _FlowStep extends StatelessWidget {
  const _FlowStep({
    required this.number,
    required this.title,
    required this.description,
    required this.code,
    required this.color,
    this.last = false,
  });

  final String number;
  final String title;
  final String description;
  final String code;
  final Color color;
  final bool last;

  @override
  Widget build(BuildContext context) => Padding(
    padding: EdgeInsets.only(bottom: last ? 0 : 18),
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 34,
          height: 34,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.10),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Text(
            number,
            style: TextStyle(color: color, fontWeight: FontWeight.w800),
          ),
        ),
        const SizedBox(width: 14),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: const TextStyle(fontWeight: FontWeight.w700)),
              Text(
                description,
                style: const TextStyle(fontSize: 12, color: AppColors.muted),
              ),
              const SizedBox(height: 4),
              Text(
                code,
                style: TextStyle(
                  fontFamily: 'monospace',
                  fontSize: 11,
                  color: color,
                  height: 1.5,
                ),
              ),
            ],
          ),
        ),
      ],
    ),
  );
}
