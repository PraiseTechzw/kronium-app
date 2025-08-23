import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:animate_do/animate_do.dart';
import 'package:iconsax/iconsax.dart';
import 'package:kronium/core/app_theme.dart';
import 'package:kronium/core/firebase_service.dart';
import 'package:kronium/core/user_auth_service.dart' show userController;
import 'package:kronium/models/chat_model.dart';
import 'package:kronium/core/user_controller.dart';

class AdminChatPage extends StatefulWidget {
  const AdminChatPage({super.key});

  @override
  State<AdminChatPage> createState() => _AdminChatPageState();
}

class _AdminChatPageState extends State<AdminChatPage> {
  final _messageController = TextEditingController();
  final _scrollController = ScrollController();
  ChatRoom? _selectedChatRoom;
  final userController = Get.find<UserController>();
  final bool _isLoading = false;

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _sendMessage() async {
    if (_messageController.text.trim().isEmpty) return;
    if (_selectedChatRoom == null) {
      Get.snackbar('No Chat Selected', 'Please select a chat room before sending a message.', backgroundColor: Colors.red, colorText: Colors.white);
      return;
    }
    final user = userController.userProfile.value;
    if (user == null || userController.role.value != 'admin') {
      Get.snackbar('Not Logged In', 'Admin session expired or not an admin. Please log in again.', backgroundColor: Colors.red, colorText: Colors.white);
      return;
    }
    final firebaseService = Get.find<FirebaseService>();
    final message = ChatMessage(
      senderId: user.id!,
      senderName: user.name,
      senderType: 'admin',
      message: _messageController.text.trim(),
      timestamp: DateTime.now(),
      chatRoomId: _selectedChatRoom!.id,
    );
    await firebaseService.sendMessage(_selectedChatRoom!.id!, message);
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
    final firebaseService = Get.find<FirebaseService>();

    return Scaffold(
      backgroundColor: AppTheme.backgroundLight,
      body: _selectedChatRoom == null
          ? _buildChatRoomsList(firebaseService)
          : _buildChatInterface(firebaseService),
      bottomNavigationBar: Obx(() {
        final role = userController.role.value;
        final isAdmin = role == 'admin';
        final List<BottomNavigationBarItem> items = [
          const BottomNavigationBarItem(
            icon: Icon(Iconsax.home_2),
            label: 'Home',
          ),
          const BottomNavigationBarItem(
            icon: Icon(Iconsax.box),
            label: 'Services',
          ),
          const BottomNavigationBarItem(
            icon: Icon(Iconsax.document_text),
            label: 'Projects',
          ),
        ];
        if (role == 'customer' || isAdmin) {
          items.add(const BottomNavigationBarItem(
            icon: Icon(Iconsax.message),
            label: 'Chat',
          ));
        }
        items.add(BottomNavigationBarItem(
          icon: const Icon(Iconsax.user),
          label: role == 'guest' ? 'Login' : (isAdmin ? 'Admin Profile' : 'Profile'),
        ));
        return BottomNavigationBar(
          currentIndex: 3, // Set the correct index for this page
          onTap: (index) async {
            final isProfileTab = index == items.length - 1;
            final isLoggedIn = userController.role.value != 'guest';
            if (isProfileTab && !isLoggedIn) {
              Get.toNamed('/customer-login');
              return;
            }
            // Navigation logic for each tab
            switch (index) {
              case 0:
                Get.offAllNamed('/home');
                break;
              case 1:
                Get.offAllNamed('/services');
                break;
              case 2:
                Get.offAllNamed('/projects');
                break;
              case 3:
                Get.offAllNamed('/admin-chat');
                break;
              case 4:
                Get.offAllNamed(role == 'guest' ? '/customer-login' : '/customer-profile');
                break;
            }
          },
          backgroundColor: AppTheme.surfaceLight,
          selectedItemColor: AppTheme.primaryColor,
          unselectedItemColor: AppTheme.secondaryColor,
          showUnselectedLabels: true,
          type: BottomNavigationBarType.fixed,
          items: items,
        );
      }),
    );
  }

  Widget _buildChatRoomsList(FirebaseService firebaseService) {
    return StreamBuilder<List<ChatRoom>>(
      stream: firebaseService.getChatRooms(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        
        if (snapshot.hasError) {
          return Center(
            child: Text('Error: ${snapshot.error}'),
          );
        }
        
        final chatRooms = snapshot.data ?? [];
        
        if (chatRooms.isEmpty) {
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
                  'No active chats',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: Colors.grey[600],
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Customer messages will appear here',
                  style: TextStyle(
                    color: Colors.grey[500],
                  ),
                ),
              ],
            ),
          );
        }
        
        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: chatRooms.length,
          itemBuilder: (context, index) {
            final chatRoom = chatRooms[index];
            
            return FadeInUp(
              delay: Duration(milliseconds: index * 100),
              child: Card(
                margin: const EdgeInsets.only(bottom: 12),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                elevation: 3,
                child: ListTile(
                  contentPadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
                  leading: CircleAvatar(
                    backgroundColor: AppTheme.primaryColor,
                    child: Text(
                      chatRoom.customerName.isNotEmpty 
                          ? chatRoom.customerName[0].toUpperCase() 
                          : 'C',
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  title: Text(
                    chatRoom.customerName,
                    style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 16),
                  ),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(chatRoom.customerEmail, style: const TextStyle(fontSize: 13)),
                      if (chatRoom.lastMessageAt != null)
                        Text(
                          'Last message: ${_formatDate(chatRoom.lastMessageAt!)}',
                          style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                        ),
                    ],
                  ),
                  trailing: const Icon(Iconsax.arrow_right_3),
                  onTap: () {
                    setState(() {
                      _selectedChatRoom = chatRoom;
                    });
                  },
                ),
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildChatInterface(FirebaseService firebaseService) {
    return Column(
      children: [
        // Chat Header
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withOpacity(0.1),
                spreadRadius: 1,
                blurRadius: 4,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Row(
            children: [
              CircleAvatar(
                backgroundColor: AppTheme.primaryColor,
                child: Text(
                  _selectedChatRoom!.customerName.isNotEmpty 
                      ? _selectedChatRoom!.customerName[0].toUpperCase() 
                      : 'C',
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _selectedChatRoom!.customerName,
                      style: const TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 16,
                      ),
                    ),
                    Text(
                      _selectedChatRoom!.customerEmail,
                      style: TextStyle(
                        color: Colors.grey[600],
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        
        // Chat Messages
        Expanded(
          child: StreamBuilder<List<ChatMessage>>(
            stream: firebaseService.getChatMessages(_selectedChatRoom!.id!),
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
                return const Center(
                  child: Text('No messages yet'),
                );
              }
              
              return ListView.builder(
                controller: _scrollController,
                padding: const EdgeInsets.all(16),
                itemCount: messages.length,
                itemBuilder: (context, index) {
                  final message = messages[index];
                  final isAdmin = message.senderType == 'admin';
                  
                  return Container(
                    margin: const EdgeInsets.only(bottom: 12),
                    child: Row(
                      mainAxisAlignment: isAdmin
                          ? MainAxisAlignment.end
                          : MainAxisAlignment.start,
                      children: [
                        if (!isAdmin) ...[
                          CircleAvatar(
                            radius: 16,
                            backgroundColor: AppTheme.primaryColor,
                            child: Text(
                              message.senderName.isNotEmpty 
                                  ? message.senderName[0].toUpperCase() 
                                  : 'C',
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
                            padding: const EdgeInsets.symmetric(
                              horizontal: 18,
                              vertical: 14,
                            ),
                            decoration: BoxDecoration(
                              color: isAdmin
                                  ? AppTheme.primaryColor
                                  : Colors.white,
                              borderRadius: BorderRadius.circular(20),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.grey.withOpacity(0.08),
                                  spreadRadius: 1,
                                  blurRadius: 6,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                if (!isAdmin)
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
                                    color: isAdmin
                                        ? Colors.white
                                        : Colors.black87,
                                    fontSize: 15,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  '${message.timestamp.hour.toString().padLeft(2, '0')}:${message.timestamp.minute.toString().padLeft(2, '0')}',
                                  style: TextStyle(
                                    fontSize: 10,
                                    color: isAdmin
                                        ? Colors.white.withOpacity(0.7)
                                        : Colors.grey[500],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        if (isAdmin) ...[
                          const SizedBox(width: 8),
                          CircleAvatar(
                            radius: 16,
                            backgroundColor: AppTheme.secondaryColor,
                            child: const Icon(
                              Iconsax.shield_tick,
                              color: Colors.white,
                              size: 16,
                            ),
                          ),
                        ],
                      ],
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
                    hintText: 'Type your response...',
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
    );
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);
    
    if (difference.inDays > 0) {
      return '${difference.inDays} day${difference.inDays > 1 ? 's' : ''} ago';
    } else if (difference.inHours > 0) {
      return '${difference.inHours} hour${difference.inHours > 1 ? 's' : ''} ago';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes} minute${difference.inMinutes > 1 ? 's' : ''} ago';
    } else {
      return 'Just now';
    }
  }
} 