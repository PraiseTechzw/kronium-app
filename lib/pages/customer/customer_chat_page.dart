import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import 'package:kronium/core/app_theme.dart';
import 'package:kronium/core/user_auth_service.dart';
import 'package:kronium/core/firebase_service.dart';
import 'package:kronium/models/chat_model.dart';

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
    if (_messageController.text.trim().isEmpty || user == null || _chatRoomId == null) return;
    final firebaseService = Get.find<FirebaseService>();
    final message = ChatMessage(
      senderId: user.id!,
      senderName: user.name,
      senderType: 'customer',
      message: _messageController.text.trim(),
      timestamp: DateTime.now(),
    );
    await firebaseService.sendMessage(_chatRoomId!, message);
    _messageController.clear();
    Future.delayed(const Duration(milliseconds: 100), () {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  void _showSupportInfo() {
    Get.bottomSheet(
      Container(
        padding: const EdgeInsets.all(30),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Iconsax.info_circle, color: Colors.blue, size: 60),
            const SizedBox(height: 20),
            const Text('Support Info', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 22)),
            const SizedBox(height: 10),
            const Text('Our support team typically responds within 24 hours during business days.'),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () => Get.back(),
              child: const Text('Close'),
            ),
          ],
        ),
      ),
      isScrollControlled: true,
    );
  }

  @override
  Widget build(BuildContext context) {
    final user = UserAuthService.instance.userProfile.value;
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: const Text('Chat with Support'),
        actions: [
          IconButton(
            icon: const Icon(Iconsax.info_circle),
            onPressed: _showSupportInfo,
            tooltip: 'Support Info',
          ),
        ],
      ),
      body: _isLoading
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
                        const Text('Please log in to chat with support.', style: TextStyle(fontSize: 18)),
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
                      child: _chatRoomId == null
                          ? const Center(child: Text('Unable to connect to chat.'))
                          : StreamBuilder<List<ChatMessage>>(
                              stream: Get.find<FirebaseService>().getChatMessages(_chatRoomId!),
                              builder: (context, snapshot) {
                                if (snapshot.connectionState == ConnectionState.waiting) {
                                  return const Center(child: CircularProgressIndicator());
                                }
                                final messages = snapshot.data ?? [];
                                if (messages.isEmpty) {
                                  return const Center(child: Text('No messages yet. Say hello!'));
                                }
                                return ListView.builder(
                                  controller: _scrollController,
                                  padding: const EdgeInsets.all(16),
                                  itemCount: messages.length,
                                  itemBuilder: (context, index) {
                                    final msg = messages[index];
                                    final isCustomer = msg.senderType == 'customer';
                                    return Align(
                                      alignment: isCustomer ? Alignment.centerRight : Alignment.centerLeft,
                                      child: Container(
                                        margin: const EdgeInsets.symmetric(vertical: 6),
                                        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
                                        decoration: BoxDecoration(
                                          color: isCustomer ? AppTheme.primaryColor : Colors.white,
                                          borderRadius: BorderRadius.only(
                                            topLeft: const Radius.circular(16),
                                            topRight: const Radius.circular(16),
                                            bottomLeft: Radius.circular(isCustomer ? 16 : 4),
                                            bottomRight: Radius.circular(isCustomer ? 4 : 16),
                                          ),
                                          boxShadow: [
                                            BoxShadow(
                                              color: Colors.black.withOpacity(0.04),
                                              blurRadius: 6,
                                              offset: const Offset(0, 2),
                                            ),
                                          ],
                                        ),
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              msg.message,
                                              style: TextStyle(
                                                color: isCustomer ? Colors.white : Colors.black87,
                                                fontSize: 15,
                                              ),
                                            ),
                                            const SizedBox(height: 4),
                                            Text(
                                              _formatTimestamp(msg.timestamp),
                                              style: TextStyle(
                                                color: isCustomer ? Colors.white70 : Colors.black54,
                                                fontSize: 11,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    );
                                  },
                                );
                              },
                            ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                      color: Colors.white,
                      child: Row(
                        children: [
                          Expanded(
                            child: TextField(
                              controller: _messageController,
                              decoration: InputDecoration(
                                hintText: 'Type your message...',
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(25),
                                  borderSide: BorderSide.none,
                                ),
                                filled: true,
                                fillColor: Colors.grey[100],
                                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                              ),
                              minLines: 1,
                              maxLines: 4,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Container(
                            decoration: BoxDecoration(
                              color: AppTheme.primaryColor,
                              borderRadius: BorderRadius.circular(25),
                            ),
                            child: IconButton(
                              icon: const Icon(Iconsax.send_2, color: Colors.white),
                              onPressed: _sendMessage,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
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