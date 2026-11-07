import 'package:flutter/material.dart';
import '../../core/theme/app_typography.dart';
import '../../models/quote.dart';
import '../../shared/widgets/app_card.dart';
import '../../storage/quote_repository.dart';

class ClientsScreen extends StatefulWidget {
  const ClientsScreen({super.key});

  @override
  State<ClientsScreen> createState() => _ClientsScreenState();
}

class _ClientsScreenState extends State<ClientsScreen> {
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

        // Agrupar por cliente
        final Map<String, List<Quote>> byClient = {};
        for (var q in quotes) {
          byClient.putIfAbsent(q.clientName, () => []).add(q);
        }

        // Ordenar por monto total descendente
        final clientEntries = byClient.entries.toList()
          ..sort((a, b) {
            final totalA = a.value.fold<double>(0, (s, q) => s + q.grandTotal);
            final totalB = b.value.fold<double>(0, (s, q) => s + q.grandTotal);
            return totalB.compareTo(totalA);
          });

        return SingleChildScrollView(
          padding: const EdgeInsets.all(32),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Clientes',
                style: AppTypography.h1.copyWith(
                  color: theme.textTheme.bodyLarge?.color,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                '${clientEntries.length} clientes únicos',
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
                          _headerCell(theme, 'CLIENTE', flex: 4),
                          _headerCell(theme, 'NIT / CC', flex: 2),
                          _headerCell(theme, 'COTIZACIONES',
                              flex: 2, align: TextAlign.center),
                          _headerCell(theme, 'TOTAL COTIZADO',
                              flex: 3, align: TextAlign.right),
                        ],
                      ),
                    ),
                    if (clientEntries.isEmpty)
                      Padding(
                        padding: const EdgeInsets.all(48),
                        child: Center(
                          child: Text(
                            'Aún no hay clientes registrados.',
                            style: AppTypography.body.copyWith(
                              color: theme.textTheme.bodySmall?.color,
                            ),
                          ),
                        ),
                      )
                    else
                      ...clientEntries.asMap().entries.map((entry) {
                        final idx = entry.key;
                        final clientName = entry.value.key;
                        final clientQuotes = entry.value.value;
                        final total = clientQuotes.fold<double>(
                            0, (s, q) => s + q.grandTotal);
                        final taxId = clientQuotes
                            .firstWhere((q) => q.clientTaxId != null,
                                orElse: () => clientQuotes.first)
                            .clientTaxId;

                        return Container(
                          height: 52,
                          padding: const EdgeInsets.symmetric(horizontal: 24),
                          decoration: BoxDecoration(
                            border: idx == clientEntries.length - 1
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
                                flex: 4,
                                child: Text(
                                  clientName,
                                  style: AppTypography.body.copyWith(
                                    color: theme.textTheme.bodyLarge?.color,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ),
                              Expanded(
                                flex: 2,
                                child: Text(
                                  taxId ?? '-',
                                  style: AppTypography.bodySmall.copyWith(
                                    color: theme.textTheme.bodySmall?.color,
                                  ),
                                ),
                              ),
                              Expanded(
                                flex: 2,
                                child: Text(
                                  '${clientQuotes.length}',
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
