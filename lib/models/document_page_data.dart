import 'dart:convert';

import 'package:equatable/equatable.dart';
import 'package:flutter_quill/flutter_quill.dart';

class DocumentPageData extends Equatable {
  final String id;
  final String title;
  final Delta content;
  final String owner;

  const DocumentPageData(
      {required this.id,
      required this.title,
      required this.content,
      required this.owner});

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'content': jsonEncode(content.toJson()),
      "owner": owner
    };
  }

  factory DocumentPageData.fromMap(Map<String, dynamic> map) {
    final contentJson =
        (map['content'] == null) ? [] : jsonDecode(map['content']);
    return DocumentPageData(
      owner: map["owner"],
      id: map['id'],
      title: map['title'] ?? '',
      content: Delta.fromJson(contentJson),
    );
  }

  String toJson() => json.encode(toMap());

  factory DocumentPageData.fromJson(String source) =>
      DocumentPageData.fromMap(json.decode(source));

  @override
  List<Object?> get props => [title, content];

  DocumentPageData copyWith(
      {String? id, String? title, Delta? content, String? owner}) {
    return DocumentPageData(
        id: id ?? this.id,
        title: title ?? this.title,
        content: content ?? this.content,
        owner: owner ?? this.owner);
  }
}
