import '../models/shopping_item.dart';

abstract class ShoppingRepository {
  Future<List<ShoppingItem>> getToBuyItems();
  Future<List<ShoppingItem>> getBoughtItems();
  Future<ShoppingItem?> getShoppingItemById(String id);
  Future<void> insertShoppingItem(ShoppingItem item);
  Future<void> updateShoppingItem(ShoppingItem item);
  Future<void> deleteShoppingItem(String id);
  Future<void> setShoppingItemBought(String id, bool isBought, {DateTime? boughtAt});
}
