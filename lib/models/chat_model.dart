
class ChatMessage {
  final String? id;
  final String senderId;
  final String senderName;
  final String senderType; // 'customer' or 'admin'
  final String message;
  final DateTime timestamp;
  final bool isRead;
  final String? chatRoomId;

  ChatMessage({
    this.id,
    required this.senderId,
    required this.senderName,
    required this.senderType,
    required this.message,
    required this.timestamp,
    this.isRead = false,
    this.chatRoomId,
  });

  // Create from Map
  factory ChatMessage.fromMap(Map<String, dynamic> data, {String? id}) {
    return ChatMessage(
      id: id ?? data['id'],
      senderId: data['senderId'] ?? '',
      senderName: data['senderName'] ?? '',
      senderType: data['senderType'] ?? 'customer',
      message: data['message'] ?? '',
      timestamp: data['timestamp'] is DateTime ? data['timestamp'] : (data['timestamp'] != null ? DateTime.parse(data['timestamp'].toString()) : DateTime.now()),
      isRead: data['isRead'] ?? false,
      chatRoomId: data['chatRoomId'],
    );
  }

  // Convert to Map
  Map<String, dynamic> toMap() {
    return {
      'senderId': senderId,
      'senderName': senderName,
      'senderType': senderType,
      'message': message,
      'timestamp': timestamp.toIso8601String(),
      'isRead': isRead,
      if (chatRoomId != null) 'chatRoomId': chatRoomId,
    };
  }

  // Copy with method
  ChatMessage copyWith({
    String? id,
    String? senderId,
    String? senderName,
    String? senderType,
    String? message,
    DateTime? timestamp,
    bool? isRead,
    String? chatRoomId,
  }) {
    return ChatMessage(
      id: id ?? this.id,
      senderId: senderId ?? this.senderId,
      senderName: senderName ?? this.senderName,
      senderType: senderType ?? this.senderType,
      message: message ?? this.message,
      timestamp: timestamp ?? this.timestamp,
      isRead: isRead ?? this.isRead,
      chatRoomId: chatRoomId ?? this.chatRoomId,
    );
  }
}

class ChatRoom {
  final String? id;
  final String customerId;
  final String customerName;
  final String customerEmail;
  final DateTime createdAt;
  final DateTime? lastMessageAt;
  final bool isActive;

  ChatRoom({
    this.id,
    required this.customerId,
    required this.customerName,
    required this.customerEmail,
    required this.createdAt,
    this.lastMessageAt,
    this.isActive = true,
  });

  // Create from Map
  factory ChatRoom.fromMap(Map<String, dynamic> data, {String? id}) {
    return ChatRoom(
      id: id ?? data['id'],
      customerId: data['customerId'] ?? '',
      customerName: data['customerName'] ?? '',
      customerEmail: data['customerEmail'] ?? '',
      createdAt: data['createdAt'] is DateTime ? data['createdAt'] : (data['createdAt'] != null ? DateTime.parse(data['createdAt'].toString()) : DateTime.now()),
      lastMessageAt: data['lastMessageAt'] is DateTime ? data['lastMessageAt'] : (data['lastMessageAt'] != null ? DateTime.parse(data['lastMessageAt'].toString()) : null),
      isActive: data['isActive'] ?? true,
    );
  }

  // Convert to Map
  Map<String, dynamic> toMap() {
    return {
      'customerId': customerId,
      'customerName': customerName,
      'customerEmail': customerEmail,
      'createdAt': createdAt.toIso8601String(),
      'lastMessageAt': lastMessageAt?.toIso8601String(),
      'isActive': isActive,
    };
  }

  // Copy with method
  ChatRoom copyWith({
    String? id,
    String? customerId,
    String? customerName,
    String? customerEmail,
    DateTime? createdAt,
    DateTime? lastMessageAt,
    bool? isActive,
  }) {
    return ChatRoom(
      id: id ?? this.id,
      customerId: customerId ?? this.customerId,
      customerName: customerName ?? this.customerName,
      customerEmail: customerEmail ?? this.customerEmail,
      createdAt: createdAt ?? this.createdAt,
      lastMessageAt: lastMessageAt ?? this.lastMessageAt,
      isActive: isActive ?? this.isActive,
    );
  }
} 