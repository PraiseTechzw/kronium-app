import 'package:flutter/material.dart';
import 'package:kronium/core/app_theme.dart';
import 'package:kronium/models/chat_model.dart';

class ChatMessageBubble extends StatelessWidget {
  final ChatMessage message;
  final bool isCustomer;
  final String Function(DateTime) formatTimestamp;
  final bool isLastMessage;
  final bool showAvatar;

  const ChatMessageBubble({
    super.key,
    required this.message,
    required this.isCustomer,
    required this.formatTimestamp,
    this.isLastMessage = false,
    this.showAvatar = true,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(
        left: isCustomer ? 60 : 0,
        right: isCustomer ? 0 : 60,
        top: 6,
        bottom: 6,
      ),
      child: Row(
        mainAxisAlignment:
            isCustomer ? MainAxisAlignment.end : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          if (!isCustomer && showAvatar) ...[
            CircleAvatar(
              radius: 16,
              backgroundColor: AppTheme.primaryColor,
              child: Text(
                message.senderName.isNotEmpty
                    ? message.senderName[0].toUpperCase()
                    : 'S',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const SizedBox(width: 8),
          ],
          Flexible(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
              decoration: BoxDecoration(
                color: isCustomer ? AppTheme.primaryColor : Colors.white,
                borderRadius: BorderRadius.only(
                  topLeft: const Radius.circular(20),
                  topRight: const Radius.circular(20),
                  bottomLeft: Radius.circular(isCustomer ? 20 : 8),
                  bottomRight: Radius.circular(isCustomer ? 8 : 20),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.08),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
                border:
                    isCustomer
                        ? null
                        : Border.all(color: Colors.grey[200]!, width: 1),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (!isCustomer) ...[
                    Text(
                      message.senderName,
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: AppTheme.primaryColor,
                      ),
                    ),
                    const SizedBox(height: 4),
                  ],
                  Text(
                    message.message,
                    style: TextStyle(
                      fontSize: 15,
                      color: isCustomer ? Colors.white : Colors.black87,
                      height: 1.4,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        formatTimestamp(message.timestamp),
                        style: TextStyle(
                          fontSize: 11,
                          color:
                              isCustomer
                                  ? Colors.white.withOpacity(0.7)
                                  : Colors.grey[500],
                        ),
                      ),
                      if (isCustomer && isLastMessage) ...[
                        const SizedBox(width: 4),
                        Icon(
                          message.isRead ? Icons.done_all : Icons.done,
                          size: 12,
                          color:
                              message.isRead
                                  ? Colors.white.withOpacity(0.7)
                                  : Colors.white.withOpacity(0.5),
                        ),
                      ],
                    ],
                  ),
                ],
              ),
            ),
          ),
          if (isCustomer && showAvatar) ...[
            const SizedBox(width: 8),
            CircleAvatar(
              radius: 16,
              backgroundColor: AppTheme.secondaryColor,
              child: const Icon(Icons.person, color: Colors.white, size: 16),
            ),
          ],
        ],
      ),
    );
  }
}
