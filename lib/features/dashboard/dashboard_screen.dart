import 'package:flutter/material.dart';
import '../../core/theme/app_typography.dart';
import '../../models/quote.dart';
import '../../shared/widgets/app_card.dart';
import '../../shared/widgets/app_quote_form.dart';
import '../../shared/widgets/app_sidebar.dart';
import '../../shared/widgets/app_stat_card.dart';
import '../../storage/quote_repository.dart';
import '../clients/clients_screen.dart';
import '../quotations/quotations_screen.dart';
import '../suppliers/suppliers_screen.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  int _selectedIndex = 0;
  final QuoteRepository _repo = QuoteRepository();
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  Future<List<Quote>>? _quotesFuture;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  void _loadData() {
    setState(() {
      _quotesFuture = _repo.getAllQuotes();
    });
  }

  Future<void> _openNewQuoteForm() async {
    final result = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (context) => const AppQuoteForm(),
    );

    if (result == true && mounted) {
      _loadData();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Cotización guardada exitosamente')),
      );
    }
  }

  Future<void> _clearAllQuotes() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('¿Borrar todas las cotizaciones?'),
        content: const Text(
            'Esta acción eliminará todos los registros de la base de datos local.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Borrar Todo'),
          ),
        ],
      ),
    );

    if (confirm == true) {
      final all = await _repo.getAllQuotes();
      for (var quote in all) {
        await _repo.deleteQuote(quote.id);
      }
      _loadData();
    }
  }

  void _handleNewQuote() {
    if (_scaffoldKey.currentState?.isDrawerOpen ?? false) {
      Navigator.pop(context); // cierra el drawer antes de abrir el modal
    }
    _openNewQuoteForm();
  }

  void _handleItemSelected(int index) {
    setState(() => _selectedIndex = index);
    if (_scaffoldKey.currentState?.isDrawerOpen ?? false) {
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final width = MediaQuery.of(context).size.width;
    final isDesktop = width >= 900;

    if (isDesktop) {
      return Scaffold(
        body: Row(
          children: [
            AppSidebar(
              selectedIndex: _selectedIndex,
              onItemSelected: _handleItemSelected,
              onNewQuote: _openNewQuoteForm,
            ),
            Expanded(child: _buildSelectedScreen(theme)),
          ],
        ),
      );
    }

    // Layout móvil/tablet
    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.menu),
          onPressed: () => _scaffoldKey.currentState?.openDrawer(),
        ),
        title: Text(
          _titleForIndex(_selectedIndex),
          style: AppTypography.h4.copyWith(
            color: theme.textTheme.bodyLarge?.color,
          ),
        ),
      ),
      drawer: Drawer(
        backgroundColor: Colors.transparent,
        child: AppSidebar(
          selectedIndex: _selectedIndex,
          onItemSelected: _handleItemSelected,
          onNewQuote: _handleNewQuote,
          showCloseButton: true,
        ),
      ),
      body: _buildSelectedScreen(theme),
    );
  }

  String _titleForIndex(int index) {
    switch (index) {
      case 0:
        return 'Dashboard';
      case 1:
        return 'Cotizaciones';
      case 2:
        return 'Clientes';
      case 3:
        return 'Proveedores';
      default:
        return 'Orbital Factus';
    }
  }

  Widget _buildSelectedScreen(ThemeData theme) {
    switch (_selectedIndex) {
      case 0:
        return _buildDashboardContent(theme);
      case 1:
        return const QuotationsScreen();
      case 2:
        return const ClientsScreen();
      case 3:
        return const SuppliersScreen();
      default:
        return Center(
          child: Text(
            'Módulo en construcción',
            style: AppTypography.body.copyWith(
              color: theme.textTheme.bodySmall?.color,
            ),
          ),
        );
    }
  }

  Widget _buildDashboardContent(ThemeData theme) {
    return FutureBuilder<List<Quote>>(
      future: _quotesFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        }

        final quotes = snapshot.data ?? [];
        final totalCotizado =
            quotes.fold<double>(0, (sum, q) => sum + q.grandTotal);
        final totalQuotes = quotes.length;

        final Map<String, int> suppliers = {};
        for (var q in quotes) {
          for (var i in q.items) {
            if (i.supplier != null && i.supplier!.isNotEmpty) {
              suppliers[i.supplier!] = (suppliers[i.supplier!] ?? 0) + 1;
            }
          }
        }
        final topSupplier = suppliers.isEmpty
            ? 'N/A'
            : suppliers.entries.reduce((a, b) => a.value > b.value ? a : b).key;

        final width = MediaQuery.of(context).size.width;
        final isMobile = width < 700;
        final padding = isMobile ? 16.0 : 32.0;

        return SingleChildScrollView(
          padding: EdgeInsets.all(padding),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Resumen General',
                          style: AppTypography.h1.copyWith(
                            color: theme.textTheme.bodyLarge?.color,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Estado actual de la operación comercial.',
                          style: AppTypography.body.copyWith(
                            color: theme.textTheme.bodySmall?.color,
                          ),
                        ),
                      ],
                    ),
                  ),
                  if (!isMobile)
                    TextButton.icon(
                      onPressed: _clearAllQuotes,
                      icon: const Icon(Icons.delete_sweep_outlined, size: 16),
                      label: const Text('Borrar datos de prueba'),
                      style: TextButton.styleFrom(
                        foregroundColor: theme.textTheme.bodySmall?.color,
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 24),
              // Stats: 1 col en móvil, 3 en desktop
              if (isMobile)
                Column(
                  children: [
                    AppStatCard(
                      title: 'Cotizado (Total)',
                      value: '\$ ${totalCotizado.toStringAsFixed(0)}',
                      icon: Icons.attach_money,
                      caption: '${totalQuotes} cotizaciones',
                    ),
                    const SizedBox(height: 12),
                    AppStatCard(
                      title: 'Cotizaciones',
                      value: '$totalQuotes',
                      icon: Icons.description_outlined,
                      caption: 'Registradas en el sistema',
                    ),
                    const SizedBox(height: 12),
                    AppStatCard(
                      title: 'Proveedor Top',
                      value: topSupplier,
                      icon: Icons.local_shipping_outlined,
                      caption: 'Con más ítems cotizados',
                    ),
                  ],
                )
              else
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: AppStatCard(
                        title: 'Cotizado (Total)',
                        value: '\$ ${totalCotizado.toStringAsFixed(0)}',
                        icon: Icons.attach_money,
                        caption: '${totalQuotes} cotizaciones',
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: AppStatCard(
                        title: 'Cotizaciones',
                        value: '$totalQuotes',
                        icon: Icons.description_outlined,
                        caption: 'Registradas en el sistema',
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: AppStatCard(
                        title: 'Proveedor Top',
                        value: topSupplier,
                        icon: Icons.local_shipping_outlined,
                        caption: 'Con más ítems cotizados',
                      ),
                    ),
                  ],
                ),
              const SizedBox(height: 32),
              Text(
                'Cotizaciones Recientes',
                style: AppTypography.h3.copyWith(
                  color: theme.textTheme.bodyLarge?.color,
                ),
              ),
              const SizedBox(height: 16),
              if (isMobile)
                _buildMobileQuoteList(theme, quotes)
              else
                _buildDesktopQuoteTable(theme, quotes),
            ],
          ),
        );
      },
    );
  }

  // --- Vista móvil: tarjetas apiladas ---
  Widget _buildMobileQuoteList(ThemeData theme, List<Quote> quotes) {
    if (quotes.isEmpty) {
      return AppCard(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 32),
          child: Center(
            child: Text(
              'No hay cotizaciones aún.\nCrea la primera con el botón del menú.',
              textAlign: TextAlign.center,
              style: AppTypography.body.copyWith(
                color: theme.textTheme.bodySmall?.color,
              ),
            ),
          ),
        ),
      );
    }

    return Column(
      children: quotes.take(5).map((quote) {
        return Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: AppCard(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      quote.quoteNumber,
                      style: AppTypography.overline.copyWith(
                        color: theme.textTheme.bodySmall?.color,
                      ),
                    ),
                    Text(
                      '${quote.createdAt.day}/${quote.createdAt.month}/${quote.createdAt.year}',
                      style: AppTypography.caption.copyWith(
                        color: theme.textTheme.bodySmall?.color,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  quote.title ?? quote.clientName,
                  style: AppTypography.h4.copyWith(
                    color: theme.textTheme.bodyLarge?.color,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  quote.clientName,
                  style: AppTypography.bodySmall.copyWith(
                    color: theme.textTheme.bodySmall?.color,
                  ),
                ),
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      '\$ ${quote.grandTotal.toStringAsFixed(0)}',
                      style: AppTypography.h3.copyWith(
                        color: theme.textTheme.bodyLarge?.color,
                      ),
                    ),
                    Row(
                      children: [
                        IconButton(
                          icon: const Icon(Icons.edit_outlined, size: 18),
                          tooltip: 'Editar',
                          onPressed: () async {
                            final r = await showDialog<bool>(
                              context: context,
                              barrierDismissible: false,
                              builder: (_) =>
                                  AppQuoteForm(existingQuote: quote),
                            );
                            if (r == true) _loadData();
                          },
                        ),
                        IconButton(
                          icon: const Icon(Icons.delete_outline, size: 18),
                          tooltip: 'Eliminar',
                          onPressed: () async {
                            final confirm = await showDialog<bool>(
                              context: context,
                              builder: (context) => AlertDialog(
                                title: const Text('¿Eliminar cotización?'),
                                content: const Text(
                                    'Esta acción no se puede deshacer.'),
                                actions: [
                                  TextButton(
                                    onPressed: () =>
                                        Navigator.pop(context, false),
                                    child: const Text('Cancelar'),
                                  ),
                                  ElevatedButton(
                                    onPressed: () =>
                                        Navigator.pop(context, true),
                                    child: const Text('Eliminar'),
                                  ),
                                ],
                              ),
                            );
                            if (confirm == true) {
                              await _repo.deleteQuote(quote.id);
                              _loadData();
                            }
                          },
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }

  // --- Vista desktop: tabla ---
  Widget _buildDesktopQuoteTable(ThemeData theme, List<Quote> quotes) {
    return AppCard(
      padding: EdgeInsets.zero,
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
            decoration: BoxDecoration(
              border: Border(
                bottom:
                    BorderSide(color: theme.dividerTheme.color ?? Colors.grey),
              ),
            ),
            child: Row(
              children: [
                _headerCell(theme, 'NÚMERO', flex: 2),
                _headerCell(theme, 'PROYECTO', flex: 4),
                _headerCell(theme, 'CLIENTE', flex: 3),
                _headerCell(theme, 'TOTAL', flex: 2, align: TextAlign.right),
                _headerCell(theme, 'ACCIONES', flex: 2, align: TextAlign.right),
              ],
            ),
          ),
          if (quotes.isEmpty)
            Padding(
              padding: const EdgeInsets.all(48),
              child: Center(
                child: Text(
                  'No hay cotizaciones aún. Crea la primera con el botón del menú lateral.',
                  style: AppTypography.body.copyWith(
                    color: theme.textTheme.bodySmall?.color,
                  ),
                ),
              ),
            )
          else
            ...quotes.take(5).toList().asMap().entries.map((entry) {
              final index = entry.key;
              final quote = entry.value;
              return _tableRow(
                theme,
                quote: quote,
                isLast: index == quotes.take(5).length - 1,
              );
            }).toList(),
        ],
      ),
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

  Widget _tableRow(
    ThemeData theme, {
    required Quote quote,
    bool isLast = false,
  }) {
    return Container(
      height: 52,
      padding: const EdgeInsets.symmetric(horizontal: 24),
      decoration: BoxDecoration(
        border: isLast
            ? null
            : Border(
                bottom: BorderSide(
                  color: theme.dividerTheme.color ?? Colors.grey,
                ),
              ),
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
              quote.title ?? '-',
              style: AppTypography.body.copyWith(
                color: theme.textTheme.bodyLarge?.color,
                fontWeight: FontWeight.w500,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
          Expanded(
            flex: 3,
            child: Text(
              quote.clientName,
              style: AppTypography.body.copyWith(
                color: theme.textTheme.bodyLarge?.color,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
          Expanded(
            flex: 2,
            child: Text(
              '\$ ${quote.grandTotal.toStringAsFixed(0)}',
              textAlign: TextAlign.right,
              style: AppTypography.money.copyWith(
                color: theme.textTheme.bodyLarge?.color,
              ),
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
                  onPressed: () async {
                    final r = await showDialog<bool>(
                      context: context,
                      barrierDismissible: false,
                      builder: (_) => AppQuoteForm(existingQuote: quote),
                    );
                    if (r == true) _loadData();
                  },
                ),
                IconButton(
                  icon: const Icon(Icons.delete_outline, size: 18),
                  tooltip: 'Eliminar',
                  onPressed: () async {
                    final confirm = await showDialog<bool>(
                      context: context,
                      builder: (context) => AlertDialog(
                        title: const Text('¿Eliminar cotización?'),
                        content:
                            const Text('Esta acción no se puede deshacer.'),
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
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
