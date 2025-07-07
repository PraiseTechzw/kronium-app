import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:animate_do/animate_do.dart';
import 'package:iconsax/iconsax.dart';
import 'package:kronium/core/app_theme.dart';
import 'package:kronium/core/firebase_service.dart';
import 'package:kronium/core/user_auth_service.dart';
import 'package:kronium/models/chat_model.dart';

class CustomerChatPage extends StatefulWidget {
  const CustomerChatPage({super.key});

  @override
  State<CustomerChatPage> createState() => _CustomerChatPageState();
}

class _CustomerChatPageState extends State<CustomerChatPage> {
  final _messageController = TextEditingController();
  final _scrollController = ScrollController();
  String? _chatRoomId;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _initializeChat();
  }

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _initializeChat() async {
    final userAuthService = Get.find<UserAuthService>();
    final firebaseService = Get.find<FirebaseService>();
    
    final user = userAuthService.currentUserProfile;
    if (user != null) {
      _chatRoomId = await firebaseService.getOrCreateChatRoom(
        user.id!,
        user.name,
        user.email,
      );
    }
    
    setState(() => _isLoading = false);
  }

  Future<void> _sendMessage() async {
    if (_messageController.text.trim().isEmpty || _chatRoomId == null) return;

    final userAuthService = Get.find<UserAuthService>();
    final firebaseService = Get.find<FirebaseService>();
    
    final user = userAuthService.currentUserProfile;
    if (user == null) return;

    final message = ChatMessage(
      senderId: user.id!,
      senderName: user.name,
      senderType: 'customer',
      message: _messageController.text.trim(),
      timestamp: DateTime.now(),
    );

    await firebaseService.sendMessage(_chatRoomId!, message);
    _messageController.clear();
    
    // Scroll to bottom
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final userAuthService = Get.find<UserAuthService>();
    final firebaseService = Get.find<FirebaseService>();

    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: const Text('Chat with Support'),
        actions: [
          IconButton(
            icon: const Icon(Iconsax.info_circle),
            onPressed: () {
              Get.snackbar(
                'Support Hours',
                'We typically respond within 24 hours during business days',
                snackPosition: SnackPosition.BOTTOM,
                backgroundColor: AppTheme.primaryColor,
                colorText: Colors.white,
              );
            },
            tooltip: 'Support Info',
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _chatRoomId == null
              ? const Center(child: Text('Unable to load chat'))
              : Column(
                  children: [
                    // Chat Messages
                    Expanded(
                      child: StreamBuilder<List<ChatMessage>>(
                        stream: firebaseService.getChatMessages(_chatRoomId!),
                        builder: (context, snapshot) {
                          if (snapshot.connectionState == ConnectionState.waiting) {
                            return const Center(child: CircularProgressIndicator());
                          }
                          
                          if (snapshot.hasError) {
                            return Center(
                              child: Text('Error: ${snapshot.error}'),
                            );
                          }
                          
                          final messages = snapshot.data ?? [];
                          
                          if (messages.isEmpty) {
                            return Center(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    Iconsax.message,
                                    size: 64,
                                    color: Colors.grey[400],
                                  ),
                                  const SizedBox(height: 16),
                                  Text(
                                    'No messages yet',
                                    style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.w600,
                                      color: Colors.grey[600],
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    'Start a conversation with our support team',
                                    style: TextStyle(
                                      color: Colors.grey[500],
                                    ),
                                  ),
                                ],
                              ),
                            );
                          }
                          
                          return ListView.builder(
                            controller: _scrollController,
                            padding: const EdgeInsets.all(16),
                            itemCount: messages.length,
                            itemBuilder: (context, index) {
                              final message = messages[index];
                              final isCustomer = message.senderType == 'customer';
                              
                              return FadeInUp(
                                delay: Duration(milliseconds: index * 100),
                                child: Container(
                                  margin: const EdgeInsets.only(bottom: 12),
                                  child: Row(
                                    mainAxisAlignment: isCustomer
                                        ? MainAxisAlignment.end
                                        : MainAxisAlignment.start,
                                    children: [
                                      if (!isCustomer) ...[
                                        CircleAvatar(
                                          radius: 16,
                                          backgroundColor: AppTheme.primaryColor,
                                          child: const Icon(
                                            Iconsax.shield_tick,
                                            color: Colors.white,
                                            size: 16,
                                          ),
                                        ),
                                        const SizedBox(width: 8),
                                      ],
                                      Flexible(
                                        child: Container(
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 16,
                                            vertical: 12,
                                          ),
                                          decoration: BoxDecoration(
                                            color: isCustomer
                                                ? AppTheme.primaryColor
                                                : Colors.white,
                                            borderRadius: BorderRadius.circular(20),
                                            boxShadow: [
                                              BoxShadow(
                                                color: Colors.grey.withOpacity(0.1),
                                                spreadRadius: 1,
                                                blurRadius: 4,
                                                offset: const Offset(0, 2),
                                              ),
                                            ],
                                          ),
                                          child: Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              if (!isCustomer)
                                                Text(
                                                  message.senderName,
                                                  style: const TextStyle(
                                                    fontWeight: FontWeight.w600,
                                                    fontSize: 12,
                                                    color: AppTheme.primaryColor,
                                                  ),
                                                ),
                                              const SizedBox(height: 4),
                                              Text(
                                                message.message,
                                                style: TextStyle(
                                                  color: isCustomer
                                                      ? Colors.white
                                                      : Colors.black87,
                                                  fontSize: 14,
                                                ),
                                              ),
                                              const SizedBox(height: 4),
                                              Text(
                                                '${message.timestamp.hour.toString().padLeft(2, '0')}:${message.timestamp.minute.toString().padLeft(2, '0')}',
                                                style: TextStyle(
                                                  fontSize: 10,
                                                  color: isCustomer
                                                      ? Colors.white.withOpacity(0.7)
                                                      : Colors.grey[500],
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                      if (isCustomer) ...[
                                        const SizedBox(width: 8),
                                        CircleAvatar(
                                          radius: 16,
                                          backgroundColor: AppTheme.secondaryColor,
                                          child: const Icon(
                                            Iconsax.user,
                                            color: Colors.white,
                                            size: 16,
                                          ),
                                        ),
                                      ],
                                    ],
                                  ),
                                ),
                              );
                            },
                          );
                        },
                      ),
                    ),
                    
                    // Message Input
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.grey.withOpacity(0.1),
                            spreadRadius: 1,
                            blurRadius: 4,
                            offset: const Offset(0, -2),
                          ),
                        ],
                      ),
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
                                contentPadding: const EdgeInsets.symmetric(
                                  horizontal: 20,
                                  vertical: 12,
                                ),
                              ),
                              maxLines: null,
                              textCapitalization: TextCapitalization.sentences,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Container(
                            decoration: BoxDecoration(
                              color: AppTheme.primaryColor,
                              borderRadius: BorderRadius.circular(25),
                            ),
                            child: IconButton(
                              onPressed: _sendMessage,
                              icon: const Icon(
                                Iconsax.send_1,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
    );
  }
} 