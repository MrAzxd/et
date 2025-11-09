import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class ChatScreen extends StatefulWidget {
  final String receiverId;
  final String receiverName;

  const ChatScreen({
    super.key,
    required this.receiverId,
    required this.receiverName,
  });

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final currentUserId = FirebaseAuth.instance.currentUser!.uid;

  bool _isSending = false;

  // ✅ Generate unique chat ID (sorted)
  String getChatId() {
    if (currentUserId.compareTo(widget.receiverId) > 0) {
      return '$currentUserId${widget.receiverId}';
    } else {
      return '${widget.receiverId}$currentUserId';
    }
  }

  // ✅ Ensure chat document exists in Firestore
  Future<void> _ensureChatDocumentExists(String chatId) async {
    final chatRef = FirebaseFirestore.instance.collection('chats').doc(chatId);
    final doc = await chatRef.get();

    if (!doc.exists) {
      await chatRef.set({
        'users': [currentUserId, widget.receiverId],
        'lastMessage': '',
        'lastMessageTime': FieldValue.serverTimestamp(),
        'createdAt': FieldValue.serverTimestamp(),
      });
    }
  }

  // ✅ Delete message method
  Future<void> deleteMessage(String chatId, String messageId) async {
    try {
      await FirebaseFirestore.instance
          .collection('chats')
          .doc(chatId)
          .collection('messages')
          .doc(messageId)
          .delete();
    } catch (e) {
      debugPrint("⚠️ Error deleting message: $e");
    }
  }

  // ✅ Optimized WhatsApp-like message sender
  Future<void> sendMessage() async {
    final text = _messageController.text.trim();
    if (text.isEmpty) return;

    final chatId = getChatId();
    final chatRef = FirebaseFirestore.instance.collection('chats').doc(chatId);

    // ⚡ Capture text & clear immediately (for instant UX)
    final messageText = text;
    _messageController.clear();

    // ✅ Prevent rapid double-taps
    if (_isSending) return;
    _isSending = true;

    // ✅ Run Firestore write in background (no UI freeze)
    Future.microtask(() async {
      try {
        await _ensureChatDocumentExists(chatId);

        final messageData = {
          'senderId': currentUserId,
          'receiverId': widget.receiverId,
          'text': messageText,
          'time': FieldValue.serverTimestamp(),
          'isRead': false,
        };

        await chatRef.collection('messages').add(messageData);

        await chatRef.set({
          'chatid': chatId,
          'users': [currentUserId, widget.receiverId],
          'lastMessage': messageText,
          'lastMessageTime': FieldValue.serverTimestamp(),
        }, SetOptions(merge: true));

        // ✅ Auto-scroll to bottom smoothly
        if (_scrollController.hasClients) {
          await Future.delayed(const Duration(milliseconds: 200));
          _scrollController.animateTo(
            _scrollController.position.maxScrollExtent + 100,
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeOut,
          );
        }
      } catch (e) {
        debugPrint("⚠️ Send failed: $e");
      } finally {
        _isSending = false;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final chatId = getChatId();

    return Scaffold(
      backgroundColor: const Color(0xFFE5E5E5),
      appBar: AppBar(
        title: Row(
          children: [
            const CircleAvatar(
              backgroundColor: Colors.white,
              child: Icon(Icons.person, color: Colors.green),
            ),
            const SizedBox(width: 10),
            Text(
              widget.receiverName,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ],
        ),
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xFF1B5E20), Color(0xFF4CAF50)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
      ),
      body: Column(
        children: [
          // 🔹 Real-time messages
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('chats')
                  .doc(chatId)
                  .collection('messages')
                  .orderBy('time', descending: false)
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(
                    child: CircularProgressIndicator(color: Color(0xFF075E54)),
                  );
                }

                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return const Center(
                    child: Text('Say Hi 👋 to start chatting!'),
                  );
                }

                final messages = snapshot.data!.docs;

                // ✅ Auto-scroll on new messages
                WidgetsBinding.instance.addPostFrameCallback((_) {
                  if (_scrollController.hasClients) {
                    _scrollController.jumpTo(
                      _scrollController.position.maxScrollExtent,
                    );
                  }
                });

                return ListView.builder(
                  controller: _scrollController,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                  itemCount: messages.length,
                  itemBuilder: (context, index) {
                    final msg =
                        messages[index].data() as Map<String, dynamic>? ?? {};
                    final text = msg['text'] ?? '';
                    final senderId = msg['senderId'] ?? '';
                    final isMine = senderId == currentUserId;

                    return GestureDetector(
                      onLongPress: () {
                        if (isMine) {
                          showDialog(
                            context: context,
                            builder: (context) => AlertDialog(
                              title: const Text("Delete Message"),
                              content: const Text(
                                  "Do you want to delete this message?"),
                              actions: [
                                TextButton(
                                  onPressed: () => Navigator.pop(context),
                                  child: const Text("Cancel"),
                                ),
                                TextButton(
                                  onPressed: () async {
                                    Navigator.pop(context);
                                    await deleteMessage(
                                        chatId, messages[index].id);
                                  },
                                  child: const Text(
                                    "Delete",
                                    style: TextStyle(color: Colors.red),
                                  ),
                                ),
                              ],
                            ),
                          );
                        }
                      },
                      child: Align(
                        alignment: isMine
                            ? Alignment.centerRight
                            : Alignment.centerLeft,
                        child: Container(
                          margin: const EdgeInsets.symmetric(vertical: 4),
                          padding: const EdgeInsets.symmetric(
                              horizontal: 14, vertical: 10),
                          decoration: BoxDecoration(
                            color:
                                isMine ? const Color(0xFFDCF8C6) : Colors.white,
                            borderRadius: BorderRadius.only(
                              topLeft: const Radius.circular(12),
                              topRight: const Radius.circular(12),
                              bottomLeft: isMine
                                  ? const Radius.circular(12)
                                  : const Radius.circular(0),
                              bottomRight: isMine
                                  ? const Radius.circular(0)
                                  : const Radius.circular(12),
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.05),
                                blurRadius: 4,
                              ),
                            ],
                          ),
                          child: Text(
                            text,
                            style: const TextStyle(fontSize: 16),
                          ),
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),

          // 🔹 Input field
          SafeArea(
            child: Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 8.0, vertical: 6.0),
              color: Colors.white,
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _messageController,
                      textCapitalization: TextCapitalization.sentences,
                      decoration: InputDecoration(
                        hintText: 'Type a message...',
                        filled: true,
                        fillColor: Colors.grey[100],
                        contentPadding: const EdgeInsets.symmetric(
                            vertical: 10, horizontal: 16),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(25),
                          borderSide: BorderSide.none,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 6),
                  Container(
                    decoration: const BoxDecoration(
                      color: Color(0xFF075E54),
                      shape: BoxShape.circle,
                    ),
                    child: IconButton(
                      icon: const Icon(Icons.send, color: Colors.white),
                      onPressed: sendMessage,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
