class PassModel {
  final String id;
  final String userId;
  final String type;
  final DateTime validFrom;
  final DateTime validTo;
  final String barcode;
  final String status;
  final String? studentName;
  final String? purpose;
  final String? rejectionReason;
  final String? barcodeImagePath;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final DateTime? exitTime;
  final DateTime? entryTime;

  PassModel({
    required this.id,
    required this.userId,
    required this.type,
    required this.validFrom,
    required this.validTo,
    required this.barcode,
    required this.status,
    this.studentName,
    this.purpose,
    this.rejectionReason,
    this.barcodeImagePath,
    this.createdAt,
    this.updatedAt,
    this.exitTime,
    this.entryTime,
  });

  factory PassModel.fromJson(Map<String, dynamic> json) => PassModel(
    id: json['id'],
    userId: json['userId'],
    type: json['type'],
    validFrom: DateTime.parse(json['validFrom']),
    validTo: DateTime.parse(json['validTo']),
    barcode: json['barcode'],
    status: json['status'],
    studentName: json['studentName'],
    purpose: json['purpose'],
    rejectionReason: json['rejectionReason'],
    barcodeImagePath: json['barcodeImagePath'],
    createdAt: json['createdAt'] != null ? DateTime.parse(json['createdAt']) : null,
    updatedAt: json['updatedAt'] != null ? DateTime.parse(json['updatedAt']) : null,
    exitTime: json['exitTime'] != null ? DateTime.parse(json['exitTime']) : null,
    entryTime: json['entryTime'] != null ? DateTime.parse(json['entryTime']) : null,
  );

  Map<String, dynamic> toJson() => {
    'id': id,
    'userId': userId,
    'type': type,
    'validFrom': validFrom.toIso8601String(),
    'validTo': validTo.toIso8601String(),
    'barcode': barcode,
    'status': status,
    'studentName': studentName,
    'purpose': purpose,
    'rejectionReason': rejectionReason,
    'barcodeImagePath': barcodeImagePath,
    'createdAt': createdAt?.toIso8601String(),
    'updatedAt': updatedAt?.toIso8601String(),
    'exitTime': exitTime?.toIso8601String(),
    'entryTime': entryTime?.toIso8601String(),
  };
}
