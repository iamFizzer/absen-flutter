class BusinessIntelligencePeriod {
  final String startDate;
  final String endDate;
  final int workdays;

  const BusinessIntelligencePeriod({
    required this.startDate,
    required this.endDate,
    required this.workdays,
  });

  factory BusinessIntelligencePeriod.fromJson(Map<String, dynamic> json) {
    return BusinessIntelligencePeriod(
      startDate: json['start_date']?.toString() ?? '',
      endDate: json['end_date']?.toString() ?? '',
      workdays: json['workdays'] ?? 0,
    );
  }
}

class BusinessIntelligenceSummary {
  final int activeEmployees;
  final int expectedPresence;
  final int presentCount;
  final int lateCount;
  final int absentCount;
  final int leaveCount;
  final double attendanceRate;
  final double lateRate;
  final double completionRate;
  final int checkedInToday;
  final int checkedOutToday;
  final int notCheckedInToday;

  const BusinessIntelligenceSummary({
    required this.activeEmployees,
    required this.expectedPresence,
    required this.presentCount,
    required this.lateCount,
    required this.absentCount,
    required this.leaveCount,
    required this.attendanceRate,
    required this.lateRate,
    required this.completionRate,
    required this.checkedInToday,
    required this.checkedOutToday,
    required this.notCheckedInToday,
  });

  factory BusinessIntelligenceSummary.fromJson(Map<String, dynamic> json) {
    return BusinessIntelligenceSummary(
      activeEmployees: json['active_employees'] ?? 0,
      expectedPresence: json['expected_presence'] ?? 0,
      presentCount: json['present_count'] ?? 0,
      lateCount: json['late_count'] ?? 0,
      absentCount: json['absent_count'] ?? 0,
      leaveCount: json['leave_count'] ?? 0,
      attendanceRate: (json['attendance_rate'] as num? ?? 0).toDouble(),
      lateRate: (json['late_rate'] as num? ?? 0).toDouble(),
      completionRate: (json['completion_rate'] as num? ?? 0).toDouble(),
      checkedInToday: json['checked_in_today'] ?? 0,
      checkedOutToday: json['checked_out_today'] ?? 0,
      notCheckedInToday: json['not_checked_in_today'] ?? 0,
    );
  }
}

class BusinessIntelligenceStatusItem {
  final String status;
  final int total;

  const BusinessIntelligenceStatusItem({required this.status, required this.total});

  factory BusinessIntelligenceStatusItem.fromJson(Map<String, dynamic> json) {
    return BusinessIntelligenceStatusItem(
      status: json['status']?.toString() ?? '',
      total: json['total'] ?? 0,
    );
  }
}

class BusinessIntelligenceDailyItem {
  final String date;
  final String label;
  final int hadir;
  final int terlambat;
  final int izin;
  final int alpa;

  const BusinessIntelligenceDailyItem({
    required this.date,
    required this.label,
    required this.hadir,
    required this.terlambat,
    required this.izin,
    required this.alpa,
  });

  factory BusinessIntelligenceDailyItem.fromJson(Map<String, dynamic> json) {
    return BusinessIntelligenceDailyItem(
      date: json['date']?.toString() ?? '',
      label: json['label']?.toString() ?? '',
      hadir: json['hadir'] ?? 0,
      terlambat: json['terlambat'] ?? 0,
      izin: json['izin'] ?? 0,
      alpa: json['alpa'] ?? 0,
    );
  }
}

class BusinessIntelligenceOfficeItem {
  final String office;
  final int employees;
  final int hadir;
  final int terlambat;
  final double attendanceRate;
  final double lateRate;
  final double averageFaceScore;

  const BusinessIntelligenceOfficeItem({
    required this.office,
    required this.employees,
    required this.hadir,
    required this.terlambat,
    required this.attendanceRate,
    required this.lateRate,
    required this.averageFaceScore,
  });

  factory BusinessIntelligenceOfficeItem.fromJson(Map<String, dynamic> json) {
    return BusinessIntelligenceOfficeItem(
      office: json['office']?.toString() ?? '',
      employees: json['employees'] ?? 0,
      hadir: json['hadir'] ?? 0,
      terlambat: json['terlambat'] ?? 0,
      attendanceRate: (json['attendance_rate'] as num? ?? 0).toDouble(),
      lateRate: (json['late_rate'] as num? ?? 0).toDouble(),
      averageFaceScore: (json['average_face_score'] as num? ?? 0).toDouble(),
    );
  }
}

class BusinessIntelligenceAttentionItem {
  final int employeeId;
  final String nama;
  final String jabatan;
  final String office;
  final int hadir;
  final int terlambat;
  final int alpa;

  const BusinessIntelligenceAttentionItem({
    required this.employeeId,
    required this.nama,
    required this.jabatan,
    required this.office,
    required this.hadir,
    required this.terlambat,
    required this.alpa,
  });

  factory BusinessIntelligenceAttentionItem.fromJson(Map<String, dynamic> json) {
    return BusinessIntelligenceAttentionItem(
      employeeId: json['employee_id'] ?? 0,
      nama: json['nama']?.toString() ?? '',
      jabatan: json['jabatan']?.toString() ?? '',
      office: json['office']?.toString() ?? '',
      hadir: json['hadir'] ?? 0,
      terlambat: json['terlambat'] ?? 0,
      alpa: json['alpa'] ?? 0,
    );
  }
}

class BusinessIntelligenceModel {
  final BusinessIntelligencePeriod period;
  final BusinessIntelligenceSummary summary;
  final List<BusinessIntelligenceStatusItem> statusBreakdown;
  final List<BusinessIntelligenceDailyItem> dailyTrend;
  final List<BusinessIntelligenceOfficeItem> officePerformance;
  final List<BusinessIntelligenceAttentionItem> attentionList;

  const BusinessIntelligenceModel({
    required this.period,
    required this.summary,
    required this.statusBreakdown,
    required this.dailyTrend,
    required this.officePerformance,
    required this.attentionList,
  });

  factory BusinessIntelligenceModel.fromJson(Map<String, dynamic> json) {
    return BusinessIntelligenceModel(
      period: BusinessIntelligencePeriod.fromJson(
        Map<String, dynamic>.from(json['period'] as Map),
      ),
      summary: BusinessIntelligenceSummary.fromJson(
        Map<String, dynamic>.from(json['summary'] as Map),
      ),
      statusBreakdown: (json['status_breakdown'] as List? ?? [])
          .map(
            (item) => BusinessIntelligenceStatusItem.fromJson(
              Map<String, dynamic>.from(item),
            ),
          )
          .toList(),
      dailyTrend: (json['daily_trend'] as List? ?? [])
          .map(
            (item) => BusinessIntelligenceDailyItem.fromJson(
              Map<String, dynamic>.from(item),
            ),
          )
          .toList(),
      officePerformance: (json['office_performance'] as List? ?? [])
          .map(
            (item) => BusinessIntelligenceOfficeItem.fromJson(
              Map<String, dynamic>.from(item),
            ),
          )
          .toList(),
      attentionList: (json['attention_list'] as List? ?? [])
          .map(
            (item) => BusinessIntelligenceAttentionItem.fromJson(
              Map<String, dynamic>.from(item),
            ),
          )
          .toList(),
    );
  }
}
