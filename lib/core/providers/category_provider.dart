import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:electromart_pro/core/firebase/firestore_service.dart';
import 'package:electromart_pro/core/models/category_model.dart';
import 'package:electromart_pro/core/providers/banner_provider.dart';

final categoriesProvider = FutureProvider<List<CategoryModel>>((ref) {
  final firestoreService = ref.watch(firestoreServiceProvider);
  // TODO: Implement getCategories in FirestoreService
  return Future.value([]); // Placeholder
});
