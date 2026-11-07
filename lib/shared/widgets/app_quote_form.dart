import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import '../../core/theme/app_radius.dart';
import '../../core/theme/app_typography.dart';
import '../../models/quote.dart';
import '../../models/quote_item.dart';
import '../../storage/quote_repository.dart';

class AppQuoteForm extends StatefulWidget {
  final Quote? existingQuote;
  const AppQuoteForm({super.key, this.existingQuote});

  @override
  State<AppQuoteForm> createState() => _AppQuoteFormState();
}

class _AppQuoteFormState extends State<AppQuoteForm> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _clientController = TextEditingController();
  final _taxIdController = TextEditingController();
  final _descriptionController = TextEditingController();

  final List<QuoteItem> _items = [];

  final _productController = TextEditingController();
  final _quantityController = TextEditingController(text: '1');
  final _unitPriceController = TextEditingController();
  final _linkController = TextEditingController();
  final _supplierController = TextEditingController();

  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    if (widget.existingQuote != null) {
      _titleController.text = widget.existingQuote!.title ?? '';
      _clientController.text = widget.existingQuote!.clientName;
      _taxIdController.text = widget.existingQuote!.clientTaxId ?? '';
      _descriptionController.text = widget.existingQuote!.description ?? '';
      _items.addAll(widget.existingQuote!.items);
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _clientController.dispose();
    _taxIdController.dispose();
    _descriptionController.dispose();
    _productController.dispose();
    _quantityController.dispose();
    _unitPriceController.dispose();
    _linkController.dispose();
    _supplierController.dispose();
    super.dispose();
  }

  double get _grandTotal => _items.fold(0, (sum, item) => sum + item.total);

  void _addItem() {
    if (_productController.text.isEmpty || _unitPriceController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('Producto y Valor Unitario son obligatorios')),
      );
      return;
    }

    setState(() {
      _items.add(QuoteItem(
        id: const Uuid().v4(),
        productName: _productController.text,
        quantity: double.tryParse(_quantityController.text) ?? 1,
        unitPrice: double.tryParse(_unitPriceController.text) ?? 0,
        productLink: _linkController.text.isEmpty ? null : _linkController.text,
        supplier:
            _supplierController.text.isEmpty ? null : _supplierController.text,
      ));

      _productController.clear();
      _quantityController.text = '1';
      _unitPriceController.clear();
      _linkController.clear();
      _supplierController.clear();
    });
  }

  void _removeItem(int index) => setState(() => _items.removeAt(index));

  Future<void> _saveQuote() async {
    if (!_formKey.currentState!.validate()) return;
    if (_items.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Debe agregar al menos un ítem')),
      );
      return;
    }

    setState(() => _isSaving = true);

    try {
      final repo = QuoteRepository();
      final now = DateTime.now();

      final newQuote = Quote(
        id: widget.existingQuote?.id ?? const Uuid().v4(),
        quoteNumber: widget.existingQuote?.quoteNumber ??
            'OF-${now.year}-${now.millisecondsSinceEpoch.toString().substring(8)}',
        title: _titleController.text.trim().isEmpty
            ? null
            : _titleController.text.trim(),
        clientName: _clientController.text,
        clientTaxId:
            _taxIdController.text.isEmpty ? null : _taxIdController.text,
        description: _descriptionController.text.trim().isEmpty
            ? null
            : _descriptionController.text.trim(),
        items: List.from(_items),
        createdAt: widget.existingQuote?.createdAt ?? now,
      );

      await repo.saveQuote(newQuote);
      if (mounted) Navigator.pop(context, true);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error al guardar: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final size = MediaQuery.of(context).size;
    final isMobile = size.width < 700;

    final content = Container(
      width: isMobile ? size.width : 860,
      height: isMobile ? size.height : 760,
      decoration: BoxDecoration(
        color: theme.scaffoldBackgroundColor,
        borderRadius:
            isMobile ? BorderRadius.zero : BorderRadius.circular(AppRadius.md),
        border: isMobile
            ? null
            : Border.all(color: theme.dividerTheme.color ?? Colors.grey),
      ),
      child: Column(
        children: [
          // Header
          Container(
            padding: EdgeInsets.symmetric(
              horizontal: isMobile ? 16 : 24,
              vertical: 16,
            ),
            decoration: BoxDecoration(
              border: Border(
                bottom:
                    BorderSide(color: theme.dividerTheme.color ?? Colors.grey),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  widget.existingQuote == null
                      ? 'Nueva Cotización'
                      : 'Editar Cotización',
                  style: AppTypography.h3
                      .copyWith(color: theme.textTheme.bodyLarge?.color),
                ),
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
          ),
          // Body
          Expanded(
            child: SingleChildScrollView(
              padding: EdgeInsets.all(isMobile ? 16 : 24),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // --- TÍTULO ---
                    Text('PROYECTO',
                        style: AppTypography.overline
                            .copyWith(color: theme.textTheme.bodySmall?.color)),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: _titleController,
                      decoration: const InputDecoration(
                        labelText:
                            'Título de la cotización (ej: Proyecto Planta Norte)',
                      ),
                      validator: (v) =>
                          v == null || v.trim().isEmpty ? 'Requerido' : null,
                    ),
                    const SizedBox(height: 24),

                    // --- CLIENTE ---
                    Text('DATOS DEL CLIENTE',
                        style: AppTypography.overline
                            .copyWith(color: theme.textTheme.bodySmall?.color)),
                    const SizedBox(height: 12),
                    if (isMobile) ...[
                      TextFormField(
                        controller: _clientController,
                        decoration: const InputDecoration(
                            labelText: 'Nombre del Cliente'),
                        validator: (v) =>
                            v == null || v.isEmpty ? 'Requerido' : null,
                      ),
                      const SizedBox(height: 12),
                      TextFormField(
                        controller: _taxIdController,
                        decoration: const InputDecoration(
                            labelText: 'NIT / CC (Opcional)'),
                      ),
                    ] else
                      Row(
                        children: [
                          Expanded(
                            flex: 2,
                            child: TextFormField(
                              controller: _clientController,
                              decoration: const InputDecoration(
                                  labelText: 'Nombre del Cliente'),
                              validator: (v) =>
                                  v == null || v.isEmpty ? 'Requerido' : null,
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            flex: 1,
                            child: TextFormField(
                              controller: _taxIdController,
                              decoration: const InputDecoration(
                                  labelText: 'NIT / CC (Opcional)'),
                            ),
                          ),
                        ],
                      ),

                    // --- DESCRIPCIÓN ---
                    const SizedBox(height: 24),
                    Text('DESCRIPCIÓN / NOTAS',
                        style: AppTypography.overline
                            .copyWith(color: theme.textTheme.bodySmall?.color)),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: _descriptionController,
                      maxLines: 4,
                      decoration: const InputDecoration(
                        labelText:
                            'Alcance, condiciones de pago, tiempo de entrega, validez...',
                        alignLabelWithHint: true,
                      ),
                    ),
                    const SizedBox(height: 24),

                    // --- AGREGAR ÍTEM ---
                    Text('AGREGAR ÍTEMS',
                        style: AppTypography.overline
                            .copyWith(color: theme.textTheme.bodySmall?.color)),
                    const SizedBox(height: 12),
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: theme.cardTheme.color,
                        border: Border.all(
                            color: theme.dividerTheme.color ?? Colors.grey),
                        borderRadius: BorderRadius.circular(AppRadius.sm),
                      ),
                      child: isMobile
                          ? Column(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                TextField(
                                  controller: _productController,
                                  decoration: const InputDecoration(
                                      labelText: 'Producto / Servicio'),
                                ),
                                const SizedBox(height: 12),
                                Row(
                                  children: [
                                    Expanded(
                                      child: TextField(
                                        controller: _quantityController,
                                        keyboardType: TextInputType.number,
                                        decoration: const InputDecoration(
                                            labelText: 'Cant.'),
                                      ),
                                    ),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: TextField(
                                        controller: _unitPriceController,
                                        keyboardType: TextInputType.number,
                                        decoration: const InputDecoration(
                                            labelText: 'Valor Unit.'),
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 12),
                                TextField(
                                  controller: _supplierController,
                                  decoration: const InputDecoration(
                                      labelText: 'Proveedor (Opcional)'),
                                ),
                                const SizedBox(height: 12),
                                TextField(
                                  controller: _linkController,
                                  decoration: const InputDecoration(
                                      labelText:
                                          'Enlace del producto (Opcional)'),
                                ),
                                const SizedBox(height: 12),
                                SizedBox(
                                  height: 40,
                                  child: ElevatedButton(
                                    onPressed: _addItem,
                                    child: const Text('Añadir Ítem'),
                                  ),
                                ),
                              ],
                            )
                          : Column(
                              children: [
                                Row(
                                  children: [
                                    Expanded(
                                      flex: 3,
                                      child: TextField(
                                        controller: _productController,
                                        decoration: const InputDecoration(
                                            labelText: 'Producto / Servicio'),
                                      ),
                                    ),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      flex: 1,
                                      child: TextField(
                                        controller: _quantityController,
                                        keyboardType: TextInputType.number,
                                        decoration: const InputDecoration(
                                            labelText: 'Cant.'),
                                      ),
                                    ),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      flex: 2,
                                      child: TextField(
                                        controller: _unitPriceController,
                                        keyboardType: TextInputType.number,
                                        decoration: const InputDecoration(
                                            labelText: 'Valor Unit.'),
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 12),
                                Row(
                                  children: [
                                    Expanded(
                                      flex: 1,
                                      child: TextField(
                                        controller: _supplierController,
                                        decoration: const InputDecoration(
                                            labelText: 'Proveedor (Opcional)'),
                                      ),
                                    ),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      flex: 2,
                                      child: TextField(
                                        controller: _linkController,
                                        decoration: const InputDecoration(
                                            labelText:
                                                'Enlace del producto (Opcional)'),
                                      ),
                                    ),
                                    const SizedBox(width: 12),
                                    SizedBox(
                                      height: 40,
                                      child: ElevatedButton(
                                        onPressed: _addItem,
                                        child: const Text('Añadir'),
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                    ),
                    const SizedBox(height: 24),

                    // --- LISTA DE ÍTEMS ---
                    if (_items.isNotEmpty) ...[
                      Text('ÍTEMS AGREGADOS',
                          style: AppTypography.overline.copyWith(
                              color: theme.textTheme.bodySmall?.color)),
                      const SizedBox(height: 12),
                      Container(
                        decoration: BoxDecoration(
                          border: Border.all(
                              color: theme.dividerTheme.color ?? Colors.grey),
                          borderRadius: BorderRadius.circular(AppRadius.sm),
                        ),
                        child: Column(
                          children: _items.asMap().entries.map((entry) {
                            final index = entry.key;
                            final item = entry.value;
                            return Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 16, vertical: 12),
                              decoration: BoxDecoration(
                                border: index < _items.length - 1
                                    ? Border(
                                        bottom: BorderSide(
                                            color: theme.dividerTheme.color ??
                                                Colors.grey))
                                    : null,
                              ),
                              child: Row(
                                children: [
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(item.productName,
                                            style: AppTypography.body.copyWith(
                                                fontWeight: FontWeight.w500)),
                                        if (item.supplier != null)
                                          Text('Prov: ${item.supplier}',
                                              style: AppTypography.caption
                                                  .copyWith(
                                                      color: theme.textTheme
                                                          .bodySmall?.color)),
                                        Text(
                                          'x${item.quantity.toStringAsFixed(0)}  ·  \$ ${item.total.toStringAsFixed(0)}',
                                          style: AppTypography.bodySmall
                                              .copyWith(
                                                  color: theme.textTheme
                                                      .bodySmall?.color),
                                        ),
                                      ],
                                    ),
                                  ),
                                  IconButton(
                                    icon: const Icon(Icons.delete_outline,
                                        size: 20),
                                    color: theme.textTheme.bodySmall?.color,
                                    onPressed: () => _removeItem(index),
                                  ),
                                ],
                              ),
                            );
                          }).toList(),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ),
          // Footer
          Container(
            padding: EdgeInsets.all(isMobile ? 16 : 24),
            decoration: BoxDecoration(
              border: Border(
                top: BorderSide(color: theme.dividerTheme.color ?? Colors.grey),
              ),
              color: theme.cardTheme.color,
            ),
            child: isMobile
                ? Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text('TOTAL',
                              style: AppTypography.overline.copyWith(
                                  color: theme.textTheme.bodySmall?.color)),
                          Text('\$ ${_grandTotal.toStringAsFixed(0)}',
                              style: AppTypography.h3.copyWith(
                                  color: theme.textTheme.bodyLarge?.color)),
                        ],
                      ),
                      const SizedBox(height: 12),
                      ElevatedButton(
                        onPressed: _isSaving ? null : _saveQuote,
                        child: _isSaving
                            ? const SizedBox(
                                width: 16,
                                height: 16,
                                child: CircularProgressIndicator(
                                    strokeWidth: 2, color: Colors.white))
                            : Text(widget.existingQuote == null
                                ? 'Guardar'
                                : 'Actualizar'),
                      ),
                    ],
                  )
                : Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('TOTAL COTIZADO',
                              style: AppTypography.overline.copyWith(
                                  color: theme.textTheme.bodySmall?.color)),
                          const SizedBox(height: 4),
                          Text('\$ ${_grandTotal.toStringAsFixed(0)}',
                              style: AppTypography.h2.copyWith(
                                  color: theme.textTheme.bodyLarge?.color)),
                        ],
                      ),
                      Row(
                        children: [
                          OutlinedButton(
                            onPressed: () => Navigator.pop(context),
                            child: const Text('Cancelar'),
                          ),
                          const SizedBox(width: 12),
                          ElevatedButton(
                            onPressed: _isSaving ? null : _saveQuote,
                            child: _isSaving
                                ? const SizedBox(
                                    width: 16,
                                    height: 16,
                                    child: CircularProgressIndicator(
                                        strokeWidth: 2, color: Colors.white))
                                : Text(widget.existingQuote == null
                                    ? 'Guardar'
                                    : 'Actualizar'),
                          ),
                        ],
                      ),
                    ],
                  ),
          ),
        ],
      ),
    );

    if (isMobile) {
      return Scaffold(
        backgroundColor: theme.scaffoldBackgroundColor,
        body: SafeArea(child: content),
      );
    }
    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.all(32),
      child: content,
    );
  }
}
