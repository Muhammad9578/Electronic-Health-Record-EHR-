import 'dart:core';

class MedicalRecord {
  int? id;
  String? name;
  String? size;
  int? createdOn;
  String? description;
  String? path;
  String? extension;

  // Constructor
  MedicalRecord({
    this.id,
    this.name,
    this.size,
    this.createdOn,
    this.description,
    this.path,
    this.extension,
  });

  // Factory method to create a MedicalRecord object from a JSON map
  factory MedicalRecord.fromJson(Map<String, dynamic> json) {
    return MedicalRecord(
      id: json['id'] as int?,
      name: json['name'] as String?,
      size: json['size'] as String?,
      createdOn: json['createdOn'] as int?,
      description: json['description'] as String?,
      path: json['path'] as String?,
      extension: json['extension'] as String?,
    );
  }

  // Method to convert the MedicalRecord object to a JSON map
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'size': size,
      'createdOn': createdOn,
      'description': description,
      'path': path,
      'extension': extension,
    };
  }
}

MedicalRecord record = MedicalRecord(
  id: 1,
  name: 'Health Checkup',
  size: '2 MB',
  createdOn: DateTime.now().millisecondsSinceEpoch,
  description: 'Regular health checkup report',
  path: '/documents/health_checkup_report.pdf',
  extension: 'pdf',
);
