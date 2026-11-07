import 'package:flutter/material.dart';
import '../../core/theme/app_typography.dart';
import '../../models/quote.dart';
import '../../shared/widgets/app_card.dart';
import '../../storage/quote_repository.dart';

class SuppliersScreen extends StatefulWidget {
  const SuppliersScreen({super.key});

  @override
  State<SuppliersScreen> createState() => _SuppliersScreenState();
}

class _SuppliersScreenState extends State<SuppliersScreen> {
  final QuoteRepository _repo = QuoteRepository();
  Future<List<Quote>>? _quotesFuture;

  @override
  void initState() {
    super.initState();
    _quotesFuture = _repo.getAllQuotes();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return FutureBuilder<List<Quote>>(
      future: _quotesFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        final quotes = snapshot.data ?? [];

        // Agrupar por proveedor
        final Map<String, int> itemCount = {};
        final Map<String, double> totalAmount = {};

        for (var q in quotes) {
          for (var item in q.items) {
            final supplier = item.supplier?.trim();
            if (supplier == null || supplier.isEmpty) continue;
            itemCount[supplier] = (itemCount[supplier] ?? 0) + 1;
            totalAmount[supplier] = (totalAmount[supplier] ?? 0) + item.total;
          }
        }

        // Ordenar por monto descendente
        final supplierEntries = totalAmount.entries.toList()
          ..sort((a, b) => b.value.compareTo(a.value));

        return SingleChildScrollView(
          padding: const EdgeInsets.all(32),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Proveedores',
                style: AppTypography.h1.copyWith(
                  color: theme.textTheme.bodyLarge?.color,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                '${supplierEntries.length} proveedores registrados',
                style: AppTypography.body.copyWith(
                  color: theme.textTheme.bodySmall?.color,
                ),
              ),
              const SizedBox(height: 32),
              AppCard(
                padding: EdgeInsets.zero,
                child: Column(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 24,
                        vertical: 16,
                      ),
                      decoration: BoxDecoration(
                        border: Border(
                          bottom: BorderSide(
                            color: theme.dividerTheme.color ?? Colors.grey,
                          ),
                        ),
                      ),
                      child: Row(
                        children: [
                          _headerCell(theme, 'PROVEEDOR', flex: 5),
                          _headerCell(theme, 'ÍTEMS COTIZADOS',
                              flex: 3, align: TextAlign.center),
                          _headerCell(theme, 'MONTO COTIZADO',
                              flex: 3, align: TextAlign.right),
                        ],
                      ),
                    ),
                    if (supplierEntries.isEmpty)
                      Padding(
                        padding: const EdgeInsets.all(48),
                        child: Center(
                          child: Text(
                            'Aún no hay proveedores registrados. Añade el campo "Proveedor" al crear ítems.',
                            style: AppTypography.body.copyWith(
                              color: theme.textTheme.bodySmall?.color,
                            ),
                          ),
                        ),
                      )
                    else
                      ...supplierEntries.asMap().entries.map((entry) {
                        final idx = entry.key;
                        final supplier = entry.value.key;
                        final total = entry.value.value;
                        final count = itemCount[supplier] ?? 0;

                        return Container(
                          height: 52,
                          padding: const EdgeInsets.symmetric(horizontal: 24),
                          decoration: BoxDecoration(
                            border: idx == supplierEntries.length - 1
                                ? null
                                : Border(
                                    bottom: BorderSide(
                                      color: theme.dividerTheme.color ??
                                          Colors.grey,
                                    ),
                                  ),
                          ),
                          child: Row(
                            children: [
                              Expanded(
                                flex: 5,
                                child: Text(
                                  supplier,
                                  style: AppTypography.body.copyWith(
                                    color: theme.textTheme.bodyLarge?.color,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ),
                              Expanded(
                                flex: 3,
                                child: Text(
                                  '$count',
                                  textAlign: TextAlign.center,
                                  style: AppTypography.body.copyWith(
                                    color: theme.textTheme.bodyLarge?.color,
                                  ),
                                ),
                              ),
                              Expanded(
                                flex: 3,
                                child: Text(
                                  '\$ ${total.toStringAsFixed(0)}',
                                  textAlign: TextAlign.right,
                                  style: AppTypography.money.copyWith(
                                    color: theme.textTheme.bodyLarge?.color,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        );
                      }).toList(),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _headerCell(
    ThemeData theme,
    String text, {
    int flex = 1,
    TextAlign align = TextAlign.left,
  }) {
    return Expanded(
      flex: flex,
      child: Text(
        text,
        textAlign: align,
        style: AppTypography.overline.copyWith(
          color: theme.textTheme.bodySmall?.color,
        ),
      ),
    );
  }
}
