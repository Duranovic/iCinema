// Re-export shared model for backward compatibility
export 'package:icinema_shared/icinema_shared.dart' show ProjectionModel;

import 'package:icinema_shared/icinema_shared.dart';

class ProjectionsResponse {
  final List<ProjectionModel> items;
  final int totalCount;
  final int page;
  final int pageSize;

  const ProjectionsResponse({
    required this.items,
    required this.totalCount,
    required this.page,
    required this.pageSize,
  });

  factory ProjectionsResponse.fromJson(Map<String, dynamic> json) {
    return ProjectionsResponse(
      items: (json['items'] as List<dynamic>)
          .map((item) => ProjectionModel.fromJson(item as Map<String, dynamic>))
          .toList(),
      totalCount: json['totalCount'] as int,
      page: json['page'] as int,
      pageSize: json['pageSize'] as int,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'items': items.map((item) => item.toJson()).toList(),
      'totalCount': totalCount,
      'page': page,
      'pageSize': pageSize,
    };
  }
}
