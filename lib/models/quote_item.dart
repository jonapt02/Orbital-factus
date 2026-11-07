import 'package:hive/hive.dart';

part 'quote_item.g.dart';

@HiveType(typeId: 1)
class QuoteItem extends HiveObject {
  @HiveField(0)
  String id;

  @HiveField(1)
  String productName;

  @HiveField(2)
  double quantity;

  @HiveField(3)
  double unitPrice;

  @HiveField(4)
  String? productLink; // Enlace opcional

  @HiveField(5)
  String? supplier; // Proveedor

  QuoteItem({
    required this.id,
    required this.productName,
    required this.quantity,
    required this.unitPrice,
    this.productLink,
    this.supplier,
  });

  double get total => quantity * unitPrice;
}