import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import 'package:kronium/core/app_theme.dart';
import 'package:kronium/core/user_auth_service.dart';

class CustomerChatPage extends StatefulWidget {
  const CustomerChatPage({super.key});

  @override
  State<CustomerChatPage> createState() => _CustomerChatPageState();
}

class _CustomerChatPageState extends State<CustomerChatPage> {
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final List<Map<String, dynamic>> _messages = [
    // Mock messages
    {
      'sender': 'admin',
      'text': 'Welcome to Kronium support! How can we help you today?',
      'timestamp': DateTime.now().subtract(const Duration(minutes: 5)),
    },
    {
      'sender': 'customer',
      'text': 'Hi, I need help with my booking.',
      'timestamp': DateTime.now().subtract(const Duration(minutes: 4)),
    },
  ];

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _sendMessage() {
    final user = UserAuthService.instance.userProfile.value;
    if (_messageController.text.trim().isEmpty || user == null) return;
    setState(() {
      _messages.add({
        'sender': 'customer',
        'text': _messageController.text.trim(),
        'timestamp': DateTime.now(),
      });
    });
    _messageController.clear();
    Future.delayed(const Duration(milliseconds: 100), () {
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    });
    // Mock admin reply
    Future.delayed(const Duration(seconds: 2), () {
      setState(() {
        _messages.add({
          'sender': 'admin',
          'text': 'Thank you for your message. We will assist you shortly.',
          'timestamp': DateTime.now(),
        });
      });
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
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
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              controller: _scrollController,
              padding: const EdgeInsets.all(16),
              itemCount: _messages.length,
              itemBuilder: (context, index) {
                final msg = _messages[index];
                final isCustomer = msg['sender'] == 'customer';
                return Align(
                  alignment: isCustomer ? Alignment.centerRight : Alignment.centerLeft,
                  child: Container(
                    margin: const EdgeInsets.symmetric(vertical: 6),
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    decoration: BoxDecoration(
                      color: isCustomer ? AppTheme.primaryColor : Colors.grey[300],
                      borderRadius: BorderRadius.only(
                        topLeft: const Radius.circular(16),
                        topRight: const Radius.circular(16),
                        bottomLeft: Radius.circular(isCustomer ? 16 : 4),
                        bottomRight: Radius.circular(isCustomer ? 4 : 16),
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.04),
                          blurRadius: 4,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          msg['text'],
                          style: TextStyle(
                            color: isCustomer ? Colors.white : Colors.black87,
                            fontSize: 15,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          _formatTimestamp(msg['timestamp']),
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
            ),
          ),
          if (user != null)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              color: Colors.white,
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _messageController,
                      decoration: const InputDecoration(
                        hintText: 'Type your message...',
                        border: OutlineInputBorder(),
                        isDense: true,
                        contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                      ),
                      minLines: 1,
                      maxLines: 4,
                    ),
                  ),
                  const SizedBox(width: 8),
                  IconButton(
                    icon: const Icon(Iconsax.send_2, color: AppTheme.primaryColor),
                    onPressed: _sendMessage,
                  ),
                ],
              ),
            ),
          if (user == null)
            Container(
              color: Colors.white,
              padding: const EdgeInsets.all(20),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text('Please log in to chat with support.'),
                  const SizedBox(width: 10),
                  ElevatedButton(
                    onPressed: () => Get.toNamed('/customer-login'),
                    child: const Text('Log In'),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  String _formatTimestamp(DateTime dt) {
    final now = DateTime.now();
    if (now.difference(dt).inMinutes < 1) return 'Just now';
    if (now.difference(dt).inMinutes < 60) return '${now.difference(dt).inMinutes} min ago';
    if (now.difference(dt).inHours < 24) return '${now.difference(dt).inHours} hr ago';
    return '${dt.year}/${dt.month}/${dt.day}';
  }
} 