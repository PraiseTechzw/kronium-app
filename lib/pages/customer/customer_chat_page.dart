import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import 'package:kronium/core/app_theme.dart';
import 'package:kronium/core/user_auth_service.dart';
import 'package:kronium/core/firebase_service.dart';
import 'package:kronium/models/chat_model.dart';
import 'package:kronium/widgets/chat_message_bubble.dart';

class CustomerChatPage extends StatefulWidget {
  const CustomerChatPage({super.key});

  @override
  State<CustomerChatPage> createState() => _CustomerChatPageState();
}

class _CustomerChatPageState extends State<CustomerChatPage> {
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  String? _chatRoomId;
  bool _isLoading = true;
  bool _isTyping = false;
  bool _isSending = false;

  @override
  void initState() {
    super.initState();
    _initChatRoom();
  }

  Future<void> _initChatRoom() async {
    final user = UserAuthService.instance.userProfile.value;
    if (user == null) {
      setState(() => _isLoading = false);
      return;
    }
    final firebaseService = Get.find<FirebaseService>();
    final chatRoomId = await firebaseService.getOrCreateChatRoom(
      user.id!,
      user.name,
      user.email,
    );
    setState(() {
      _chatRoomId = chatRoomId;
      _isLoading = false;
    });
  }

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _sendMessage() async {
    final user = UserAuthService.instance.userProfile.value;
    if (_messageController.text.trim().isEmpty ||
        user == null ||
        _chatRoomId == null ||
        _isSending) {
      return;
    }

    setState(() {
      _isSending = true;
    });

    try {
      final firebaseService = Get.find<FirebaseService>();
      final message = ChatMessage(
        senderId: user.id!,
        senderName: user.name,
        senderType: 'customer',
        message: _messageController.text.trim(),
        timestamp: DateTime.now(),
        chatRoomId: _chatRoomId!,
      );

      await firebaseService.sendMessage(_chatRoomId!, message);
      _messageController.clear();

      // Auto-scroll to bottom
      Future.delayed(const Duration(milliseconds: 100), () {
        if (_scrollController.hasClients) {
          _scrollController.animateTo(
            _scrollController.position.maxScrollExtent,
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeOut,
          );
        }
      });
    } catch (e) {
      // Show error message
      Get.snackbar(
        'Error',
        'Failed to send message. Please try again.',
        backgroundColor: Colors.red,
        colorText: Colors.white,
        snackPosition: SnackPosition.TOP,
      );
    } finally {
      setState(() {
        _isSending = false;
      });
    }
  }

  void _showSupportInfo() {
    Get.bottomSheet(
      Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Handle bar
            Container(
              margin: const EdgeInsets.only(top: 12, bottom: 8),
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(30),
              child: Column(
                children: [
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          AppTheme.primaryColor.withOpacity(0.1),
                          AppTheme.secondaryColor.withOpacity(0.1),
                        ],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: AppTheme.primaryColor.withOpacity(0.2),
                        width: 1,
                      ),
                    ),
                    child: Icon(
                      Iconsax.info_circle,
                      color: AppTheme.primaryColor,
                      size: 60,
                    ),
                  ),
                  const SizedBox(height: 24),
                  Text(
                    'Support Information',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 24,
                      color: AppTheme.primaryColor,
                      letterSpacing: 0.5,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Our dedicated support team is here to help you with any questions or concerns. We typically respond within 24 hours during business days.',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.grey[700],
                      height: 1.5,
                      letterSpacing: 0.3,
                    ),
                  ),
                  const SizedBox(height: 32),
                  Container(
                    width: double.infinity,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          AppTheme.primaryColor,
                          AppTheme.secondaryColor,
                        ],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: AppTheme.primaryColor.withOpacity(0.3),
                          blurRadius: 20,
                          offset: const Offset(0, 8),
                        ),
                      ],
                    ),
                    child: Material(
                      color: Colors.transparent,
                      child: InkWell(
                        borderRadius: BorderRadius.circular(16),
                        onTap: () => Get.back(),
                        child: Container(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          child: const Text(
                            'Got it!',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
    );
  }

  @override
  Widget build(BuildContext context) {
    final user = UserAuthService.instance.userProfile.value;
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [AppTheme.primaryColor, AppTheme.secondaryColor],
            ),
            boxShadow: [
              BoxShadow(
                color: AppTheme.primaryColor.withOpacity(0.3),
                blurRadius: 20,
                offset: const Offset(0, 8),
              ),
            ],
          ),
        ),
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.2),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(
                Iconsax.message_question,
                color: Colors.white,
                size: 24,
              ),
            ),
            const SizedBox(width: 12),
            const Text(
              'Chat with Support',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 20,
                letterSpacing: 0.5,
              ),
            ),
          ],
        ),
        actions: [
          Container(
            margin: const EdgeInsets.only(right: 8),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: IconButton(
              icon: const Icon(Iconsax.info_circle, color: Colors.white),
              onPressed: _showSupportInfo,
              tooltip: 'Support Info',
            ),
          ),
        ],
      ),
      body:
          _isLoading
              ? const Center(child: CircularProgressIndicator())
              : user == null
              ? Center(
                child: Padding(
                  padding: const EdgeInsets.all(32),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Iconsax.login, size: 60, color: Colors.orange),
                      const SizedBox(height: 20),
                      const Text(
                        'Please log in to chat with support.',
                        style: TextStyle(fontSize: 18),
                      ),
                      const SizedBox(height: 20),
                      ElevatedButton(
                        onPressed: () => Get.toNamed('/customer-login'),
                        child: const Text('Log In'),
                      ),
                    ],
                  ),
                ),
              )
              : Column(
                children: [
                  Expanded(
                    child:
                        _chatRoomId == null
                            ? const Center(
                              child: Text('Unable to connect to chat.'),
                            )
                            : StreamBuilder<List<ChatMessage>>(
                              stream: Get.find<FirebaseService>()
                                  .getChatMessages(_chatRoomId!),
                              builder: (context, snapshot) {
                                if (snapshot.connectionState ==
                                    ConnectionState.waiting) {
                                  return const Center(
                                    child: CircularProgressIndicator(),
                                  );
                                }
                                final messages = snapshot.data ?? [];
                                if (messages.isEmpty) {
                                  return Center(
                                    child: Padding(
                                      padding: const EdgeInsets.all(32),
                                      child: Column(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          Container(
                                            width: 120,
                                            height: 120,
                                            decoration: BoxDecoration(
                                              gradient: LinearGradient(
                                                colors: [
                                                  AppTheme.primaryColor
                                                      .withOpacity(0.1),
                                                  AppTheme.secondaryColor
                                                      .withOpacity(0.1),
                                                ],
                                                begin: Alignment.topLeft,
                                                end: Alignment.bottomRight,
                                              ),
                                              shape: BoxShape.circle,
                                            ),
                                            child: const Icon(
                                              Iconsax.message_question,
                                              size: 48,
                                              color: AppTheme.primaryColor,
                                            ),
                                          ),
                                          const SizedBox(height: 24),
                                          Text(
                                            'Start a Conversation',
                                            style: TextStyle(
                                              fontSize: 24,
                                              fontWeight: FontWeight.bold,
                                              color: Colors.grey[800],
                                            ),
                                          ),
                                          const SizedBox(height: 12),
                                          Text(
                                            'Our support team is here to help you with any questions or concerns. Send a message to get started!',
                                            textAlign: TextAlign.center,
                                            style: TextStyle(
                                              fontSize: 16,
                                              color: Colors.grey[600],
                                              height: 1.5,
                                            ),
                                          ),
                                          const SizedBox(height: 32),
                                          Wrap(
                                            spacing: 12,
                                            runSpacing: 12,
                                            children: [
                                              _buildQuickActionChip(
                                                'Hello! I need help',
                                                () {
                                                  _messageController.text =
                                                      'Hello! I need help';
                                                  setState(() {
                                                    _isTyping = true;
                                                  });
                                                },
                                              ),
                                              _buildQuickActionChip(
                                                'I have a question about my project',
                                                () {
                                                  _messageController.text =
                                                      'I have a question about my project';
                                                  setState(() {
                                                    _isTyping = true;
                                                  });
                                                },
                                              ),
                                              _buildQuickActionChip(
                                                'I need technical support',
                                                () {
                                                  _messageController.text =
                                                      'I need technical support';
                                                  setState(() {
                                                    _isTyping = true;
                                                  });
                                                },
                                              ),
                                            ],
                                          ),
                                        ],
                                      ),
                                    ),
                                  );
                                }
                                return ListView.builder(
                                  controller: _scrollController,
                                  padding: const EdgeInsets.all(16),
                                  itemCount: messages.length,
                                  itemBuilder: (context, index) {
                                    final msg = messages[index];
                                    final isCustomer =
                                        msg.senderType == 'customer';
                                    final isLastMessage =
                                        index == messages.length - 1;

                                    return ChatMessageBubble(
                                      message: msg,
                                      isCustomer: isCustomer,
                                      formatTimestamp: _formatTimestamp,
                                      isLastMessage: isLastMessage,
                                      showAvatar: true,
                                    );
                                  },
                                );
                              },
                            ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 12,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          blurRadius: 10,
                          offset: const Offset(0, -2),
                        ),
                      ],
                    ),
                    child: Column(
                      children: [
                        // Typing indicator
                        if (_isTyping)
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 8,
                            ),
                            child: Row(
                              children: [
                                SizedBox(
                                  width: 20,
                                  height: 20,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    valueColor: AlwaysStoppedAnimation<Color>(
                                      AppTheme.primaryColor.withOpacity(0.7),
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  'Support is typing...',
                                  style: TextStyle(
                                    color: Colors.grey[600],
                                    fontSize: 12,
                                    fontStyle: FontStyle.italic,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        Row(
                          children: [
                            Expanded(
                              child: Container(
                                decoration: BoxDecoration(
                                  color: Colors.grey[50],
                                  borderRadius: BorderRadius.circular(25),
                                  border: Border.all(
                                    color:
                                        _isSending
                                            ? Colors.grey[300]!
                                            : Colors.grey[200]!,
                                    width: 1,
                                  ),
                                ),
                                child: TextField(
                                  controller: _messageController,
                                  enabled: !_isSending,
                                  onChanged: (value) {
                                    setState(() {
                                      _isTyping = value.isNotEmpty;
                                    });
                                  },
                                  decoration: InputDecoration(
                                    hintText:
                                        _isSending
                                            ? 'Sending...'
                                            : 'Type your message...',
                                    hintStyle: TextStyle(
                                      color:
                                          _isSending
                                              ? Colors.grey[400]
                                              : Colors.grey[500],
                                      fontSize: 15,
                                    ),
                                    border: InputBorder.none,
                                    contentPadding: const EdgeInsets.symmetric(
                                      horizontal: 20,
                                      vertical: 16,
                                    ),
                                    suffixIcon:
                                        _messageController.text.isNotEmpty
                                            ? IconButton(
                                              icon: const Icon(
                                                Iconsax.close_circle,
                                                size: 20,
                                              ),
                                              onPressed: () {
                                                _messageController.clear();
                                                setState(() {
                                                  _isTyping = false;
                                                });
                                              },
                                              color: Colors.grey[500],
                                            )
                                            : null,
                                  ),
                                  minLines: 1,
                                  maxLines: 4,
                                  style: const TextStyle(
                                    fontSize: 15,
                                    color: Colors.black87,
                                  ),
                                  onSubmitted: (value) {
                                    if (value.trim().isNotEmpty &&
                                        !_isSending) {
                                      _sendMessage();
                                    }
                                  },
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Container(
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  colors:
                                      _isSending
                                          ? [
                                            Colors.grey[400]!,
                                            Colors.grey[500]!,
                                          ]
                                          : [
                                            AppTheme.primaryColor,
                                            AppTheme.secondaryColor,
                                          ],
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                ),
                                borderRadius: BorderRadius.circular(25),
                                boxShadow:
                                    _isSending
                                        ? null
                                        : [
                                          BoxShadow(
                                            color: AppTheme.primaryColor
                                                .withOpacity(0.3),
                                            blurRadius: 15,
                                            offset: const Offset(0, 4),
                                          ),
                                        ],
                              ),
                              child: Material(
                                color: Colors.transparent,
                                child: InkWell(
                                  borderRadius: BorderRadius.circular(25),
                                  onTap: _isSending ? null : _sendMessage,
                                  child: Container(
                                    padding: const EdgeInsets.all(16),
                                    child:
                                        _isSending
                                            ? SizedBox(
                                              width: 20,
                                              height: 20,
                                              child: CircularProgressIndicator(
                                                strokeWidth: 2,
                                                valueColor:
                                                    const AlwaysStoppedAnimation<
                                                      Color
                                                    >(Colors.white),
                                              ),
                                            )
                                            : const Icon(
                                              Iconsax.send_2,
                                              color: Colors.white,
                                              size: 20,
                                            ),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
    );
  }

  Widget _buildQuickActionChip(String text, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: AppTheme.primaryColor.withOpacity(0.1),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: AppTheme.primaryColor.withOpacity(0.3),
            width: 1,
          ),
        ),
        child: Text(
          text,
          style: TextStyle(
            color: AppTheme.primaryColor,
            fontSize: 14,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
    );
  }

  String _formatTimestamp(DateTime timestamp) {
    final now = DateTime.now();
    if (now.difference(timestamp).inDays == 0) {
      // Today: show time only
      return '${timestamp.hour.toString().padLeft(2, '0')}:${timestamp.minute.toString().padLeft(2, '0')}';
    } else {
      // Else: show date
      return '${timestamp.day}/${timestamp.month}/${timestamp.year}';
    }
  }
}
