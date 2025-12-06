
enum ProjectStatus { planning, inProgress, onHold, completed, cancelled }

class Project {
  final String id;
  final String title;
  final String description;
  final String location;
  final String size; // e.g. "10 acres", "500 sqm"
  final List<String> mediaUrls; // Supabase Storage media URLs
  final List<ProjectMedia> projectMedia; // Enhanced media with metadata
  final List<BookedDate> bookedDates;
  final List<String> features;
  final bool approved;
  final double progress;
  final ProjectStatus status;
  final DateTime? date;
  final String? category;
  final double? transportCost;
  final String? clientId; // Customer who booked this project
  final String? clientName;
  final String? clientEmail;
  final String? clientPhone;
  final List<ProjectUpdate> updates; // Progress updates
  final DateTime? startDate;
  final DateTime? endDate;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  Project({
    required this.id,
    required this.title,
    required this.description,
    required this.location,
    required this.size,
    required this.mediaUrls,
    this.projectMedia = const [],
    required this.bookedDates,
    this.features = const [],
    this.approved = false,
    this.progress = 0.0,
    this.status = ProjectStatus.planning,
    this.date,
    this.category,
    this.transportCost,
    this.clientId,
    this.clientName,
    this.clientEmail,
    this.clientPhone,
    this.updates = const [],
    this.startDate,
    this.endDate,
    this.createdAt,
    this.updatedAt,
  });

  // Create from Map
  factory Project.fromMap(Map<String, dynamic> data, {String? id}) {
    return Project(
      id: id ?? data['id'] ?? '',
      title: data['title'] ?? '',
      description: data['description'] ?? '',
      location: data['location'] ?? '',
      size: data['size'] ?? '',
      mediaUrls: List<String>.from(data['mediaUrls'] ?? []),
      projectMedia:
          (data['projectMedia'] as List<dynamic>? ?? [])
              .map((e) => ProjectMedia.fromMap(e))
              .toList(),
      bookedDates:
          (data['bookedDates'] as List<dynamic>? ?? [])
              .map((e) => BookedDate.fromMap(e))
              .toList(),
      features: List<String>.from(data['features'] ?? []),
      approved: data['approved'] ?? false,
      progress:
          (data['progress'] is int)
              ? (data['progress'] as int).toDouble()
              : (data['progress'] ?? 0.0),
      status: ProjectStatus.values.firstWhere(
        (e) => e.name == data['status'],
        orElse: () => ProjectStatus.planning,
      ),
      date: data['date'] is DateTime ? data['date'] : (data['date'] != null ? DateTime.parse(data['date'].toString()) : null),
      category: data['category'],
      transportCost:
          (data['transportCost'] is int)
              ? (data['transportCost'] as int).toDouble()
              : (data['transportCost'] ?? 0.0),
      clientId: data['clientId'],
      clientName: data['clientName'],
      clientEmail: data['clientEmail'],
      clientPhone: data['clientPhone'],
      updates:
          (data['updates'] as List<dynamic>? ?? [])
              .map((e) => ProjectUpdate.fromMap(e))
              .toList(),
      startDate: data['startDate'] is DateTime ? data['startDate'] : (data['startDate'] != null ? DateTime.parse(data['startDate'].toString()) : null),
      endDate: data['endDate'] is DateTime ? data['endDate'] : (data['endDate'] != null ? DateTime.parse(data['endDate'].toString()) : null),
      createdAt: data['createdAt'] is DateTime ? data['createdAt'] : (data['createdAt'] != null ? DateTime.parse(data['createdAt'].toString()) : null),
      updatedAt: data['updatedAt'] is DateTime ? data['updatedAt'] : (data['updatedAt'] != null ? DateTime.parse(data['updatedAt'].toString()) : null),
    );
  }

  Map<String, dynamic> toMap() => {
    'title': title,
    'description': description,
    'location': location,
    'size': size,
    'mediaUrls': mediaUrls,
    'projectMedia': projectMedia.map((e) => e.toMap()).toList(),
    'bookedDates': bookedDates.map((e) => e.toMap()).toList(),
    'features': features,
    'approved': approved,
    'progress': progress,
    'status': status.name,
    'date': date?.toIso8601String(),
    'category': category,
    'transportCost': transportCost,
    'clientId': clientId,
    'clientName': clientName,
    'clientEmail': clientEmail,
    'clientPhone': clientPhone,
    'updates': updates.map((e) => e.toMap()).toList(),
    'startDate': startDate?.toIso8601String(),
    'endDate': endDate?.toIso8601String(),
    'createdAt': createdAt?.toIso8601String(),
    'updatedAt': updatedAt?.toIso8601String(),
  };
}

class ProjectMedia {
  final String id;
  final String url;
  final String type; // 'image' or 'video'
  final String? caption;
  final DateTime uploadedAt;
  final String uploadedBy; // Admin ID who uploaded

  ProjectMedia({
    required this.id,
    required this.url,
    required this.type,
    this.caption,
    required this.uploadedAt,
    required this.uploadedBy,
  });

  factory ProjectMedia.fromMap(Map<String, dynamic> map) => ProjectMedia(
    id: map['id'] ?? '',
    url: map['url'] ?? '',
    type: map['type'] ?? 'image',
    caption: map['caption'],
    uploadedAt: map['uploadedAt'] is DateTime ? map['uploadedAt'] : (map['uploadedAt'] != null ? DateTime.parse(map['uploadedAt'].toString()) : DateTime.now()),
    uploadedBy: map['uploadedBy'] ?? '',
  );

  Map<String, dynamic> toMap() => {
    'id': id,
    'url': url,
    'type': type,
    'caption': caption,
    'uploadedAt': uploadedAt.toIso8601String(),
    'uploadedBy': uploadedBy,
  };
}

class ProjectUpdate {
  final String id;
  final String title;
  final String description;
  final double progress;
  final List<String> mediaUrls;
  final DateTime createdAt;
  final String createdBy; // Admin ID who created the update

  ProjectUpdate({
    required this.id,
    required this.title,
    required this.description,
    required this.progress,
    this.mediaUrls = const [],
    required this.createdAt,
    required this.createdBy,
  });

  factory ProjectUpdate.fromMap(Map<String, dynamic> map) => ProjectUpdate(
    id: map['id'] ?? '',
    title: map['title'] ?? '',
    description: map['description'] ?? '',
    progress: (map['progress'] ?? 0.0).toDouble(),
    mediaUrls: List<String>.from(map['mediaUrls'] ?? []),
    createdAt: map['createdAt'] is DateTime ? map['createdAt'] : (map['createdAt'] != null ? DateTime.parse(map['createdAt'].toString()) : DateTime.now()),
    createdBy: map['createdBy'] ?? '',
  );

  Map<String, dynamic> toMap() => {
    'id': id,
    'title': title,
    'description': description,
    'progress': progress,
    'mediaUrls': mediaUrls,
    'createdAt': createdAt.toIso8601String(),
    'createdBy': createdBy,
  };
}

class BookedDate {
  final DateTime date;
  final String clientId;
  final String status; // booked, cancelled, completed

  BookedDate({
    required this.date,
    required this.clientId,
    required this.status,
  });

  factory BookedDate.fromMap(Map<String, dynamic> map) => BookedDate(
    date: map['date'] is DateTime ? map['date'] : (map['date'] != null ? DateTime.parse(map['date'].toString()) : DateTime.now()),
    clientId: map['clientId'] ?? '',
    status: map['status'] ?? 'booked',
  );

  Map<String, dynamic> toMap() => {
    'date': date.toIso8601String(),
    'clientId': clientId,
    'status': status,
  };
}
