class CastMemberModel {
  final String actorId;
  final String actorName;
  final String? roleName;

  const CastMemberModel({
    required this.actorId,
    required this.actorName,
    this.roleName,
  });

  factory CastMemberModel.fromJson(Map<String, dynamic> json) {
    return CastMemberModel(
      actorId: json['actorId'] as String? ?? '',
      actorName: json['actorName'] as String? ?? 'Unknown',
      roleName: json['roleName'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'actorId': actorId,
      'actorName': actorName,
      if (roleName != null) 'roleName': roleName,
    };
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is CastMemberModel &&
        other.actorId == actorId &&
        other.actorName == actorName &&
        other.roleName == roleName;
  }

  @override
  int get hashCode => Object.hash(actorId, actorName, roleName);
}

