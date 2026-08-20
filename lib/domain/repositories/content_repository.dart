import '../models/content_item.dart';

abstract class ContentRepository {
  Future<List<ContentItem>> getAllContentItems();
  Future<ContentItem?> getContentItemById(String id);
  Future<void> insertContentItem(ContentItem item);
  Future<void> updateContentItem(ContentItem item);
  Future<void> deleteContentItem(String id);
}
