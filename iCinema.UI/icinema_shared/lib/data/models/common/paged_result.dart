/// Generic paged result model for paginated API responses
class PagedResult<T> {
  final List<T> items;
  final int totalCount;
  final int page;
  final int pageSize;

  const PagedResult({
    required this.items,
    required this.totalCount,
    required this.page,
    required this.pageSize,
  });

  /// Creates a PagedResult from JSON
  factory PagedResult.fromJson(
    Map<String, dynamic> json,
    T Function(Map<String, dynamic>) fromJsonT,
  ) {
    final itemsList = json['items'] as List<dynamic>? ?? [];
    return PagedResult<T>(
      items: itemsList
          .map((item) => fromJsonT(item as Map<String, dynamic>))
          .toList(),
      totalCount: (json['totalCount'] ?? itemsList.length) as int,
      page: (json['page'] ?? 1) as int,
      pageSize: (json['pageSize'] ?? itemsList.length) as int,
    );
  }

  /// Converts PagedResult to JSON
  Map<String, dynamic> toJson(Map<String, dynamic> Function(T) toJsonT) {
    return {
      'items': items.map((item) => toJsonT(item)).toList(),
      'totalCount': totalCount,
      'page': page,
      'pageSize': pageSize,
    };
  }

  /// Checks if there are more pages
  bool get hasMore => (page * pageSize) < totalCount;

  /// Gets the total number of pages
  int get totalPages => (totalCount / pageSize).ceil();

  @override
  String toString() => 'PagedResult(items: ${items.length}, totalCount: $totalCount, page: $page, pageSize: $pageSize)';
}

