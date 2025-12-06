class KnowledgeQuestion {
  final String id;
  final String question;
  final String? category;
  final String? authorId;
  final String? authorName;
  final DateTime createdAt;
  final DateTime? updatedAt;
  final bool isPinned;
  final int viewCount;
  final List<KnowledgeAnswer> answers;

  KnowledgeQuestion({
    required this.id,
    required this.question,
    this.category,
    this.authorId,
    this.authorName,
    required this.createdAt,
    this.updatedAt,
    this.isPinned = false,
    this.viewCount = 0,
    this.answers = const [],
  });

  factory KnowledgeQuestion.fromMap(Map<String, dynamic> map, {List<KnowledgeAnswer>? answers}) {
    return KnowledgeQuestion(
      id: map['id'] ?? '',
      question: map['question'] ?? '',
      category: map['category'],
      authorId: map['authorid'] ?? map['author_id'],
      authorName: map['authorname'] ?? map['author_name'],
      createdAt: map['createdat'] is DateTime
          ? map['createdat']
          : (map['createdat'] != null
              ? DateTime.parse(map['createdat'].toString())
              : DateTime.now()),
      updatedAt: map['updatedat'] is DateTime
          ? map['updatedat']
          : (map['updatedat'] != null
              ? DateTime.parse(map['updatedat'].toString())
              : null),
      isPinned: map['ispinned'] ?? map['is_pinned'] ?? false,
      viewCount: map['viewcount'] ?? map['view_count'] ?? 0,
      answers: answers ?? [],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'question': question,
      'category': category,
      'authorid': authorId,
      'authorname': authorName,
      'ispinned': isPinned,
    };
  }
}

class KnowledgeAnswer {
  final String id;
  final String questionId;
  final String answer;
  final String? authorId;
  final String? authorName;
  final DateTime createdAt;
  final DateTime? updatedAt;
  final int helpfulCount;
  final bool isAccepted;

  KnowledgeAnswer({
    required this.id,
    required this.questionId,
    required this.answer,
    this.authorId,
    this.authorName,
    required this.createdAt,
    this.updatedAt,
    this.helpfulCount = 0,
    this.isAccepted = false,
  });

  factory KnowledgeAnswer.fromMap(Map<String, dynamic> map) {
    return KnowledgeAnswer(
      id: map['id'] ?? '',
      questionId: map['questionid'] ?? map['question_id'] ?? '',
      answer: map['answer'] ?? '',
      authorId: map['authorid'] ?? map['author_id'],
      authorName: map['authorname'] ?? map['author_name'],
      createdAt: map['createdat'] is DateTime
          ? map['createdat']
          : (map['createdat'] != null
              ? DateTime.parse(map['createdat'].toString())
              : DateTime.now()),
      updatedAt: map['updatedat'] is DateTime
          ? map['updatedat']
          : (map['updatedat'] != null
              ? DateTime.parse(map['updatedat'].toString())
              : null),
      helpfulCount: map['helpfulcount'] ?? map['helpful_count'] ?? 0,
      isAccepted: map['isaccepted'] ?? map['is_accepted'] ?? false,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'questionid': questionId,
      'answer': answer,
      'authorid': authorId,
      'authorname': authorName,
    };
  }
}

