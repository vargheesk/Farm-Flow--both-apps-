

import 'package:flutter/material.dart';
import 'package:flutter_chat_types/flutter_chat_types.dart' as types;
import 'package:flutter_chat_ui/flutter_chat_ui.dart';
import 'package:flutter_gemini/flutter_gemini.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:uuid/uuid.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

class ChatbotPage extends StatefulWidget {
  final String userProfileImage;
  const ChatbotPage({super.key, required this.userProfileImage});

  @override
  State<ChatbotPage> createState() => _ChatbotPageState();
}

class _ChatbotPageState extends State<ChatbotPage> {
  final Gemini gemini = Gemini.instance;
  final List<types.Message> _messages = [];
  late final types.User _user;
  late final types.User _bot;
  bool _isTyping = false;
  final uuid = const Uuid();
  List<Content> conversationHistory = [];

  // Theme colors
  final Color primaryGreen = const Color(0xFF2E7D32);
  final Color lightGreen = const Color(0xFFEEF7EE);
  final Color darkGreen = const Color(0xFF1B5E20);
  final Color accentGreen = const Color(0xFF81C784);

  @override
  void initState() {
    super.initState();

    // Initialize user and bot
    _user = types.User(
      id: 'user',
      imageUrl: widget.userProfileImage,
    );

    _bot = const types.User(
      id: 'bot',
      imageUrl:
          'https://i0.wp.com/arktimes.com/wp-content/uploads/2019/04/2247958-movie_review1-1.jpg?fit=600%2C570&ssl=1',
      firstName: 'Chappy',
    );

    // Load conversation history from shared preferences
    _loadConversationHistory();
  }

  Future<void> _loadConversationHistory() async {
    final prefs = await SharedPreferences.getInstance();
    final messagesJson = prefs.getString('chat_messages');
    final historyJson = prefs.getString('conversation_history');

    if (messagesJson != null && historyJson != null) {
      try {
        // Decode and load UI messages
        final List<dynamic> decodedMessages = jsonDecode(messagesJson);
        final loadedMessages = decodedMessages.map((msgJson) {
          return types.TextMessage(
            author: msgJson['authorId'] == 'user' ? _user : _bot,
            id: msgJson['id'],
            text: msgJson['text'],
            createdAt: msgJson['createdAt'],
          );
        }).toList();

        // Decode and load Gemini conversation history
        final List<dynamic> decodedHistory = jsonDecode(historyJson);
        final loadedHistory = decodedHistory.map((contentJson) {
          return Content(
            role: contentJson['role'],
            parts: [Part.text(contentJson['text'])],
          );
        }).toList();

        setState(() {
          if (loadedMessages.isNotEmpty) {
            _messages.addAll(loadedMessages);
          } else {
            _addSystemPromptToHistory();
            _sendWelcomeMessage();
          }

          if (loadedHistory.isNotEmpty) {
            conversationHistory = loadedHistory.cast<Content>();
          }
        });
      } catch (e) {
        print("Error loading conversation history: $e");
        _addSystemPromptToHistory();
        _sendWelcomeMessage();
      }
    } else {
      _addSystemPromptToHistory();
      _sendWelcomeMessage();
    }
  }

  Future<void> _saveConversationHistory() async {
    final prefs = await SharedPreferences.getInstance();

    // Save UI messages
    final messagesJson = _messages
        .map((msg) {
          if (msg is types.TextMessage) {
            return {
              'id': msg.id,
              'text': msg.text,
              'authorId': msg.author.id,
              'createdAt': msg.createdAt,
            };
          }
          return null;
        })
        .where((item) => item != null)
        .toList();

    // Save Gemini conversation history
    final historyJson = conversationHistory.map((content) {
      String text = '';
      final parts = content.parts;
      if (parts != null && parts.isNotEmpty) {
        final part = parts.first;
        if (part is TextPart) {
          text = part.text ?? '';
        }
      }

      return {
        'role': content.role ?? 'user',
        'text': text,
      };
    }).toList();

    await prefs.setString('chat_messages', jsonEncode(messagesJson));
    await prefs.setString('conversation_history', jsonEncode(historyJson));
  }

  void _addSystemPromptToHistory() {
    conversationHistory.add(Content(
      role: 'user',
      parts: [
        Part.text(
            """You are Chappy, an intelligent agricultural assistant for FarmFlow app. You help farmers with:
1. Plant disease identification and treatment
2. Sustainable farming practices
3. Crop management techniques
4. Organic pest control solutions
5. Information about government agricultural schemes and subsidies
6. Weather impact on farming
7. Soil health management
8. Water conservation techniques
9. Modern agricultural technologies
10. Market prices and trends

Be knowledgeable but accessible, using simple language when explaining complex topics. Format your responses with Markdown for clarity when needed. Always remember the context of our previous conversations to provide personalized help.
""")
      ],
    ));

    conversationHistory.add(Content(
      role: 'model',
      parts: [
        Part.text(
            "I understand my role as Chappy, the intelligent agricultural assistant for the FarmFlow app. I'll provide helpful information about plant diseases, farming practices, crop management, pest control, government schemes, weather impacts, soil health, water conservation, agricultural technologies, and market trends. I'll use simple language and Markdown formatting for clarity. I'm ready to assist farmers with their questions, and I'll remember our previous conversations to provide personalized help.")
      ],
    ));
  }

  void _sendWelcomeMessage() {
    final welcomeMessage = types.TextMessage(
      author: _bot,
      id: uuid.v4(),
      text:
          """👋 Hello! I'm **Chappy**, your agricultural companion from **FarmFlow**! 🌱

I'm here to help with:
- Identifying plant diseases from symptoms
- Suggesting farming best practices
- Providing crop management tips
- Offering organic pest control solutions
- Explaining government agricultural schemes

What farming questions can I help you with today? 🚜""",
      createdAt: DateTime.now().millisecondsSinceEpoch,
    );

    setState(() {
      _messages.insert(0, welcomeMessage);
    });

    conversationHistory.add(Content(
      role: 'user',
      parts: [Part.text("Let's start our conversation.")],
    ));

    conversationHistory.add(Content(
      role: 'model',
      parts: [Part.text(welcomeMessage.text)],
    ));

    _saveConversationHistory();
  }

  void _handleSendPressed(types.PartialText message) async {
    final textMessage = types.TextMessage(
      author: _user,
      createdAt: DateTime.now().millisecondsSinceEpoch,
      id: uuid.v4(),
      text: message.text,
    );

    setState(() {
      _messages.insert(0, textMessage);
      _isTyping = true;
    });

    conversationHistory.add(Content(
      role: 'user',
      parts: [Part.text(message.text)],
    ));

    try {
      final response = await gemini.chat(conversationHistory);
      final botResponse = response?.output ??
          'Sorry, I couldn\'t process that request. Could you try asking in a different way?';

      final botMessage = types.TextMessage(
        author: _bot,
        createdAt: DateTime.now().millisecondsSinceEpoch,
        id: uuid.v4(),
        text: botResponse,
      );

      setState(() {
        _isTyping = false;
        _messages.insert(0, botMessage);
      });

      conversationHistory.add(Content(
        role: 'model',
        parts: [Part.text(botResponse)],
      ));

      _saveConversationHistory();
    } catch (e) {
      print("Error with Gemini API: $e");

      final errorMessage = types.TextMessage(
        author: _bot,
        createdAt: DateTime.now().millisecondsSinceEpoch,
        id: uuid.v4(),
        text:
            "I apologize, but I'm having trouble connecting to my knowledge base right now. Please check if the Gemini API key is properly configured in your app.",
      );

      setState(() {
        _isTyping = false;
        _messages.insert(0, errorMessage);
      });

      _saveConversationHistory();
    }
  }

  Widget _buildCustomMessage(
    types.Message message, {
    required int messageWidth,
  }) {
    final isUserMessage = message.author.id == _user.id;

    if (message is types.TextMessage) {
      return Container(
        margin: const EdgeInsets.symmetric(vertical: 4),
        padding: const EdgeInsets.symmetric(horizontal: 12),
        child: Row(
          mainAxisAlignment:
              isUserMessage ? MainAxisAlignment.end : MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            if (!isUserMessage) _buildAvatar(_bot),
            const SizedBox(width: 8),
            Flexible(
              child: Container(
                padding:
                    const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                decoration: BoxDecoration(
                  color: isUserMessage ? primaryGreen : lightGreen,
                  borderRadius: BorderRadius.circular(20).copyWith(
                    bottomRight:
                        isUserMessage ? Radius.zero : const Radius.circular(20),
                    bottomLeft:
                        isUserMessage ? const Radius.circular(20) : Radius.zero,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.08),
                      blurRadius: 4,
                      offset: const Offset(0, 2),
                    ),
                  ],
                  border: !isUserMessage
                      ? Border.all(color: accentGreen, width: 1)
                      : null,
                ),
                child: MarkdownBody(
                  data: message.text,
                  selectable: true,
                  styleSheet: MarkdownStyleSheet(
                    p: TextStyle(
                      color: isUserMessage ? Colors.white : darkGreen,
                      fontSize: 16,
                    ),
                    strong: TextStyle(
                      color: isUserMessage ? Colors.white : primaryGreen,
                      fontWeight: FontWeight.bold,
                    ),
                    em: TextStyle(
                      color: isUserMessage ? Colors.white : darkGreen,
                      fontStyle: FontStyle.italic,
                    ),
                    h1: TextStyle(
                      color: isUserMessage ? Colors.white : primaryGreen,
                      fontWeight: FontWeight.bold,
                      fontSize: 20,
                    ),
                    h2: TextStyle(
                      color: isUserMessage ? Colors.white : primaryGreen,
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                    ),
                    h3: TextStyle(
                      color: isUserMessage ? Colors.white : primaryGreen,
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                    listBullet: TextStyle(
                      color: isUserMessage ? Colors.white : primaryGreen,
                    ),
                    code: TextStyle(
                      color: isUserMessage ? lightGreen : darkGreen,
                      backgroundColor: isUserMessage
                          ? primaryGreen.withOpacity(0.7)
                          : Colors.white.withOpacity(0.7),
                      fontFamily: 'monospace',
                    ),
                    codeblockDecoration: BoxDecoration(
                      color: isUserMessage
                          ? primaryGreen.withOpacity(0.7)
                          : Colors.white.withOpacity(0.7),
                      borderRadius: BorderRadius.circular(4),
                      border: Border.all(color: accentGreen.withOpacity(0.5)),
                    ),
                    blockquote: TextStyle(
                      color: darkGreen,
                      fontStyle: FontStyle.italic,
                    ),
                    blockquoteDecoration: BoxDecoration(
                      border: Border(
                        left: BorderSide(color: primaryGreen, width: 4),
                      ),
                    ),
                  ),
                  onTapLink: (text, href, title) {},
                ),
              ),
            ),
            const SizedBox(width: 8),
            if (isUserMessage) _buildAvatar(_user),
          ],
        ),
      );
    }

    return const SizedBox();
  }

  Widget _buildAvatar(types.User user) {
    return CircleAvatar(
      radius: 16,
      backgroundImage:
          user.imageUrl != null ? NetworkImage(user.imageUrl!) : null,
      backgroundColor: user.id == _user.id ? primaryGreen : accentGreen,
      child: user.imageUrl == null
          ? Icon(
              user.id == _user.id ? Icons.person : Icons.smart_toy,
              color: Colors.white,
              size: 16,
            )
          : null,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: primaryGreen,
        elevation: 4,
        toolbarHeight: 65,
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            CircleAvatar(
              radius: 16,
              backgroundImage:
                  _bot.imageUrl != null ? NetworkImage(_bot.imageUrl!) : null,
              backgroundColor: accentGreen,
            ),
            const SizedBox(width: 8),
            const Flexible(
              child: Text(
                'FarmFlow Assistant',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: Colors.white),
            onPressed: () async {
              setState(() {
                _messages.clear();
                conversationHistory.clear();
                _addSystemPromptToHistory();
                _sendWelcomeMessage();
              });

              final prefs = await SharedPreferences.getInstance();
              await prefs.remove('chat_messages');
              await prefs.remove('conversation_history');
            },
          ),
        ],
      ),
      body: Container(
        decoration: BoxDecoration(
          color: lightGreen.withOpacity(0.2),
          image: const DecorationImage(
            image: NetworkImage(
              "https://www.transparenttextures.com/patterns/light-paper-fibers.png",
            ),
            repeat: ImageRepeat.repeat,
            opacity: 0.5,
          ),
        ),
        child: Column(
          children: [
            if (_isTyping)
              Container(
                padding: const EdgeInsets.symmetric(vertical: 8),
                color: lightGreen.withOpacity(0.3),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(primaryGreen),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'Chappy is thinking...',
                      style: TextStyle(
                        color: darkGreen,
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                  ],
                ),
              ),
            Expanded(
              child: Chat(
                messages: _messages,
                onSendPressed: _handleSendPressed,
                user: _user,
                customMessageBuilder: _buildCustomMessage,
                theme: DefaultChatTheme(
                  backgroundColor: Colors.transparent,
                  primaryColor: primaryGreen,
                  secondaryColor: Colors.white,
                  inputBackgroundColor: Colors.white,
                  inputTextColor: darkGreen,
                  inputBorderRadius: BorderRadius.circular(24),
                  inputPadding: const EdgeInsets.all(16),
                  inputMargin: const EdgeInsets.all(16),
                  sendButtonIcon: Icon(
                    Icons.send_rounded,
                    color: primaryGreen,
                  ),
                  inputTextDecoration: InputDecoration(
                    hintText: 'Ask Chappy about farming...',
                    hintStyle: TextStyle(
                      color: darkGreen.withOpacity(0.5),
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(24),
                      borderSide: BorderSide(color: lightGreen),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(24),
                      borderSide: BorderSide(color: lightGreen),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(24),
                      borderSide: BorderSide(color: primaryGreen, width: 2),
                    ),
                    filled: true,
                    fillColor: Colors.white,
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 10,
                    ),
                  ),
                ),
                showUserAvatars: true,
                showUserNames: true,
                emptyState: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.chat_outlined,
                        size: 80,
                        color: primaryGreen.withOpacity(0.3),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'Start a conversation with Chappy',
                        style: TextStyle(
                          fontSize: 16,
                          color: darkGreen.withOpacity(0.7),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
