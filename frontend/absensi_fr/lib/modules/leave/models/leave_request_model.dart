class LeaveRequestModel {
  final int id;
  final String type;
  final String typeLabel;
  final DateTime startDate;
  final DateTime endDate;
  final String reason;
  final String status;
  final String statusLabel;
  final String decisionNote;

  const LeaveRequestModel({
    required this.id,
    required this.type,
    required this.typeLabel,
    required this.startDate,
    required this.endDate,
    required this.reason,
    required this.status,
    required this.statusLabel,
    required this.decisionNote,
  });

  factory LeaveRequestModel.fromJson(Map<String, dynamic> json) =>
      LeaveRequestModel(
        id: json['id'] as int,
        type: json['type']?.toString() ?? '',
        typeLabel: json['type_label']?.toString() ?? '',
        startDate: DateTime.parse(json['start_date'].toString()),
        endDate: DateTime.parse(json['end_date'].toString()),
        reason: json['reason']?.toString() ?? '',
        status: json['status']?.toString() ?? '',
        statusLabel: json['status_label']?.toString() ?? '',
        decisionNote: json['decision_note']?.toString() ?? '',
      );
}
