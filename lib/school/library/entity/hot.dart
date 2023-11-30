import 'package:json_annotation/json_annotation.dart';

part 'hot.g.dart';

@JsonSerializable()
class HotSearchItem {
  final String keyword;
  final int count;

  const HotSearchItem({
    required this.keyword,
    required this.count,
  });

  @override
  String toString() {
    return "$keyword($count)";
  }

  factory HotSearchItem.fromJson(Map<String, dynamic> json) => _$HotSearchItemFromJson(json);

  Map<String, dynamic> toJson() => _$HotSearchItemToJson(this);
}

@JsonSerializable()
class HotSearch {
  final List<HotSearchItem> recent30days;
  final List<HotSearchItem> total;

  const HotSearch({
    required this.recent30days,
    required this.total,
  });

  @override
  String toString() {
    return {
      "recent30days": recent30days,
      "total": total,
    }.toString();
  }

  factory HotSearch.fromJson(Map<String, dynamic> json) => _$HotSearchFromJson(json);

  Map<String, dynamic> toJson() => _$HotSearchToJson(this);
}