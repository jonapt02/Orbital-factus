import 'package:flutter/material.dart';
import '../../core/theme/app_radius.dart';
import '../../core/theme/app_typography.dart';
import '../../models/quote.dart';
import '../../services/pdf_service.dart';
import '../../shared/widgets/app_card.dart';
import '../../shared/widgets/app_quote_form.dart';
import '../../shared/widgets/app_status_badge.dart';
import '../../storage/quote_repository.dart';

class QuotationsScreen extends StatefulWidget {
  const QuotationsScreen({super.key});

  @override
  State<QuotationsScreen> createState() => _QuotationsScreenState();
}

class _QuotationsScreenState extends State<QuotationsScreen> {
  final QuoteRepository _repo = QuoteRepository();
  final TextEditingController _searchController = TextEditingController();
  Future<List<Quote>>? _quotesFuture;
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _loadData() {
    setState(() {
      _quotesFuture = _repo.getAllQuotes();
    });
  }

  Future<void> _deleteQuote(Quote quote) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('¿Eliminar cotización?'),
        content:
            Text('Se eliminará ${quote.quoteNumber} de ${quote.clientName}.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Eliminar'),
          ),
        ],
      ),
    );
    if (confirm == true) {
      await _repo.deleteQuote(quote.id);
      _loadData();
    }
  }

  Future<void> _editQuote(Quote quote) async {
    final result = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (context) => AppQuoteForm(existingQuote: quote),
    );
    if (result == true) _loadData();
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
        final allQuotes = snapshot.data ?? [];
        final filtered = _searchQuery.isEmpty
            ? allQuotes
            : allQuotes
                .where((q) =>
                    q.clientName
                        .toLowerCase()
                        .contains(_searchQuery.toLowerCase()) ||
                    q.quoteNumber
                        .toLowerCase()
                        .contains(_searchQuery.toLowerCase()))
                .toList();

        return SingleChildScrollView(
          padding: const EdgeInsets.all(32),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Cotizaciones',
                style: AppTypography.h1.copyWith(
                  color: theme.textTheme.bodyLarge?.color,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                '${allQuotes.length} registros totales',
                style: AppTypography.body.copyWith(
                  color: theme.textTheme.bodySmall?.color,
                ),
              ),
              const SizedBox(height: 24),
              // Buscador
              SizedBox(
                width: 400,
                child: TextField(
                  controller: _searchController,
                  decoration: const InputDecoration(
                    hintText: 'Buscar por cliente o número...',
                    prefixIcon: Icon(Icons.search, size: 20),
                  ),
                  onChanged: (v) => setState(() => _searchQuery = v),
                ),
              ),
              const SizedBox(height: 24),
              AppCard(
                padding: EdgeInsets.zero,
                child: Column(
                  children: [
                    _buildTableHeader(theme),
                    if (filtered.isEmpty)
                      Padding(
                        padding: const EdgeInsets.all(48),
                        child: Center(
                          child: Text(
                            'No se encontraron cotizaciones.',
                            style: AppTypography.body.copyWith(
                              color: theme.textTheme.bodySmall?.color,
                            ),
                          ),
                        ),
                      )
                    else
                      ...filtered.asMap().entries.map((entry) {
                        final isLast = entry.key == filtered.length - 1;
                        return _buildTableRow(theme, entry.value, isLast);
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

  Widget _buildTableHeader(ThemeData theme) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(color: theme.dividerTheme.color ?? Colors.grey),
        ),
      ),
      child: Row(
        children: [
          _headerCell(theme, 'NÚMERO', flex: 2),
          _headerCell(theme, 'CLIENTE', flex: 4),
          _headerCell(theme, 'FECHA', flex: 2),
          _headerCell(theme, 'TOTAL', flex: 3, align: TextAlign.right),
          _headerCell(theme, 'ACCIONES', flex: 2, align: TextAlign.right),
        ],
      ),
    );
  }

  Widget _headerCell(ThemeData theme, String text,
      {int flex = 1, TextAlign align = TextAlign.left}) {
    return Expanded(
      flex: flex,
      child: Text(
        text,
        textAlign: align,
        style: AppTypography.overline
            .copyWith(color: theme.textTheme.bodySmall?.color),
      ),
    );
  }

  Widget _buildTableRow(ThemeData theme, Quote quote, bool isLast) {
    return Container(
      height: 56,
      padding: const EdgeInsets.symmetric(horizontal: 24),
      decoration: BoxDecoration(
        border: isLast
            ? null
            : Border(
                bottom:
                    BorderSide(color: theme.dividerTheme.color ?? Colors.grey)),
      ),
      child: Row(
        children: [
          Expanded(
            flex: 2,
            child: Text(
              quote.quoteNumber,
              style: AppTypography.body.copyWith(
                color: theme.textTheme.bodyLarge?.color,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          Expanded(
            flex: 4,
            child: Text(
              quote.clientName,
              style: AppTypography.body
                  .copyWith(color: theme.textTheme.bodyLarge?.color),
            ),
          ),
          Expanded(
            flex: 2,
            child: Text(
              '${quote.createdAt.day}/${quote.createdAt.month}/${quote.createdAt.year}',
              style: AppTypography.bodySmall.copyWith(
                color: theme.textTheme.bodySmall?.color,
              ),
            ),
          ),
          Expanded(
            flex: 3,
            child: Text(
              '\$ ${quote.grandTotal.toStringAsFixed(0)}',
              textAlign: TextAlign.right,
              style: AppTypography.money
                  .copyWith(color: theme.textTheme.bodyLarge?.color),
            ),
          ),
          Expanded(
            flex: 2,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                IconButton(
                  icon: const Icon(Icons.edit_outlined, size: 18),
                  tooltip: 'Editar',
                  onPressed: () => _editQuote(quote),
                ),
                IconButton(
                  icon: const Icon(Icons.picture_as_pdf_outlined, size: 18),
                  tooltip: 'PDF',
                  onPressed: () => PdfService.generateAndPrint(quote),
                ),
                IconButton(
                  icon: const Icon(Icons.delete_outline, size: 18),
                  tooltip: 'Eliminar',
                  onPressed: () => _deleteQuote(quote),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
