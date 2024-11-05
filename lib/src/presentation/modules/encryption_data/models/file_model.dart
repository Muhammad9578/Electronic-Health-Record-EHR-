enum TypeOfFile {
  text,
  image,
  video,
  document,
  audio,
  other,
}

class FileModel {
  int? id;
  String name;
  var data;
  String? path;
  String? extension;
  TypeOfFile type;

  // Constructor
  FileModel({
    this.id,
    required this.name,
    this.path,
    this.data,
    this.extension,
    required this.type,
  });

  // Factory constructor to create a FileModel from a JSON map
  factory FileModel.fromJson(Map<String, dynamic> json) {
    return FileModel(
      id: json['id'],
      name: json['name'],
      path: json['path'],
      data: json['data'],
      extension: json['extension'],
      type: _fileTypeFromString(json['type']),
    );
  }

  FileModel copyWith() {
    return FileModel(
      id: id,
      name: name,
      path: path,
      extension: extension,
      data: data,
      type: type,
    );
  }

  // Method to convert a FileModel instance to a JSON map
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'path': path,
      'extension': extension,
      'data': data,
      'type': type?.toString().split('.').last,
    };
  }

  // Helper method to convert a string to a FileType enum
  static TypeOfFile _fileTypeFromString(String? type) {
    switch (type) {
      case 'image':
        return TypeOfFile.image;
      case 'text':
        return TypeOfFile.text;
      case 'video':
        return TypeOfFile.video;
      case 'document':
        return TypeOfFile.document;
      case 'audio':
        return TypeOfFile.audio;
      default:
        return TypeOfFile.other;
    }
  }
}
