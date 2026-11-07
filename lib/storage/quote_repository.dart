import 'package:hive/hive.dart';
import '../models/quote.dart';

class QuoteRepository {
  static const String boxName = 'quotes_box';

  Future<Box<Quote>> get _box async => await Hive.openBox<Quote>(boxName);

  Future<void> saveQuote(Quote quote) async {
    final box = await _box;
    await box.put(quote.id, quote);
  }

  Future<List<Quote>> getAllQuotes() async {
    final box = await _box;
    final quotes = box.values.toList();
    quotes.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    return quotes;
  }

  Future<void> deleteQuote(String id) async {
    final box = await _box;
    await box.delete(id);
  }
}
