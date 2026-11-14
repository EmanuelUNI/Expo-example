import 'package:flutter/material.dart';

import '../../../../app/theme.dart';
import 'lab_card.dart';

class ArchitectureCard extends StatelessWidget {
  const ArchitectureCard({super.key});

  @override
  Widget build(BuildContext context) => LabCard(
    padding: EdgeInsets.zero,
    child: ExpansionTile(
      key: const Key('architecture'),
      tilePadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
      childrenPadding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
      shape: const Border(),
      collapsedShape: const Border(),
      title: const Text(
        'Cómo está organizada la app',
        style: TextStyle(fontWeight: FontWeight.w700),
      ),
      subtitle: const Text(
        'Qué hace cada parte del proyecto.',
        style: TextStyle(fontSize: 12, color: AppColors.muted),
      ),
      children: [
        const Divider(),
        const SizedBox(height: 12),
        LayoutBuilder(
          builder: (context, constraints) {
            const layers = [
              _Layer(
                title: 'Presentación',
                detail: 'CounterPage · Intent · State · Store',
                description: 'Muestra el contador y recibe tus acciones.',
              ),
              _Layer(
                title: 'Dominio',
                detail: 'Counter · casos de uso · contrato',
                description: 'Contiene las reglas y los casos de uso del contador.',
              ),
              _Layer(
                title: 'Datos',
                detail: 'InMemoryCounterRepository',
                description: 'Guarda el valor mientras la app está abierta.',
              ),
            ];
            if (constraints.maxWidth < 750) {
              return Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  layers[0],
                  SizedBox(height: 16),
                  layers[1],
                  SizedBox(height: 16),
                  layers[2],
                ],
              );
            }
            return Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                for (final layer in layers)
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.only(right: 16),
                      child: layer,
                    ),
                  ),
              ],
            );
          },
        ),
        const SizedBox(height: 20),
        const Text(
          'Dependencias: Presentación → Dominio ← Datos.\nLas capas se conectan en lib/app/dependencies.dart.',
          style: TextStyle(fontSize: 12, height: 1.6, color: AppColors.muted),
        ),
      ],
    ),
  );
}

class _Layer extends StatelessWidget {
  const _Layer({
    required this.title,
    required this.detail,
    required this.description,
  });

  final String title;
  final String detail;
  final String description;

  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(
        title,
        style: const TextStyle(
          color: AppColors.green,
          fontWeight: FontWeight.w700,
        ),
      ),
      const SizedBox(height: 4),
      Text(
        detail,
        style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
      ),
      const SizedBox(height: 4),
      Text(
        description,
        style: const TextStyle(fontSize: 12, color: AppColors.muted),
      ),
    ],
  );
}
