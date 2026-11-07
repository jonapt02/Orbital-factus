import 'package:hive/hive.dart';
import 'quote_item.dart';

part 'quote.g.dart';

@HiveType(typeId: 0)
class Quote extends HiveObject {
  @HiveField(0)
  String id;

  @HiveField(1)
  String quoteNumber;

  @HiveField(2)
  String clientName;

  @HiveField(3)
  String? clientTaxId;

  @HiveField(4)
  List<QuoteItem> items;

  @HiveField(5)
  DateTime createdAt;

  @HiveField(6)
  String? title;

  @HiveField(7)
  String? description;

  Quote({
    required this.id,
    required this.quoteNumber,
    required this.clientName,
    this.clientTaxId,
    required this.items,
    required this.createdAt,
    this.title,
    this.description,
  });

  double get grandTotal => items.fold(0, (sum, item) => sum + item.total);
}
