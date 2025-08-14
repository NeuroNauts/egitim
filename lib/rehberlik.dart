import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:animated_text_kit/animated_text_kit.dart';
import 'package:flutter/services.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'program.dart';
import 'pomodoro.dart';
import 'package:cloud_firestore/cloud_firestore.dart'; // Firestore için yeni import

// Sohbet mesajları için güncellenmiş sınıf
class Message {
  final String text;
  final String role; // 'user' veya 'model'
  final List<String> suggestions;
  final String? rawGeminiResponse;
  final bool? isThinking;

  final String? messageId; // Firebase'deki belge ID'si için eklendi
  final bool isReported; // Bildirilme durumu için
  final bool animationCompleted;

  Message({
    required this.text,
    required this.role,
    this.suggestions = const [],
    this.rawGeminiResponse,
    this.isThinking,
    this.messageId,
    this.isReported = false,
    this.animationCompleted = false,
  });

  Message copyWith({
    String? text,
    String? role,
    List<String>? suggestions,
    String? rawGeminiResponse,
    bool? isThinking,
    String? messageId,
    bool? isReported,
    bool? animationCompleted,
  }) {
    return Message(
      text: text ?? this.text,
      role: role ?? this.role,
      suggestions: suggestions ?? this.suggestions,
      rawGeminiResponse: rawGeminiResponse ?? this.rawGeminiResponse,
      isThinking: isThinking ?? this.isThinking,
      messageId: messageId ?? this.messageId,
      isReported: isReported ?? this.isReported,
      animationCompleted: animationCompleted ?? this.animationCompleted,
    );
  }
}

class RehberlikPage extends StatefulWidget {
  final String userName;
  const RehberlikPage({super.key, required this.userName});

  @override
  State<RehberlikPage> createState() => _RehberlikPageState();
}

class _RehberlikPageState extends State<RehberlikPage> {
  final TextEditingController _messageController = TextEditingController();
  final List<Message> _messages = [];
  bool _isLoading = false;
  Message? _thinkingMessage;

  // Firebase Firestore referansı
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  String? _currentChatDocId; // Mevcut sohbetin Firebase Document ID'si
  int _messageCounter = 0; // Her mesaj için benzersiz ID oluşturmak için

  static const String _geminiApiKey = "AIzaSyD57e6Ly9RgFXTf5eg5nnryvo0nGQ3tV4k";
  static const String _geminiApiUrl = "https://generativelanguage.googleapis.com/v1beta/models/gemini-2.0-flash:generateContent";

  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _addMessage(Message(text: "Merhaba! Sana nasıl yardımcı olabilirim? Ders çalışma, motivasyon, programlama veya herhangi bir konuda bana danışabilirsin.", role: 'model'));
  }

  void _addMessage(Message message) {
    setState(() {
      _messages.add(message);
    });
    _scrollToBottom();
  }

  void _scrollToBottom() {
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

  // Firebase'e yeni bir chat oturumu kaydetme metodu
  Future<String?> _saveNewChatToFirebase(String content) async {
    try {
      DocumentReference docRef = await _firestore.collection('chats').add({
        'content': content,
        'is_rep': false,
        'time': FieldValue.serverTimestamp(),
        'type': 'rehberlik',
      });
      return docRef.id;
    } catch (e) {
      print('Firebase\'e yeni sohbet kaydedilirken hata oluştu: $e');
      return null;
    }
  }

  // Mevcut bir chat oturumunu güncelleme metodu
  Future<void> _updateChatOnFirebase(String docId, String content) async {
    try {
      await _firestore.collection('chats').doc(docId).update({
        'content': content,
        'time': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      print('Firebase sohbeti güncellenirken hata oluştu: $e');
    }
  }

  // Bir mesajı bildirildi olarak işaretleme metodu
  Future<void> _reportMessage(String docId) async {
    try {
      await _firestore.collection('chats').doc(docId).update({
        'is_rep': true,
        'time': FieldValue.serverTimestamp(),
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Mesaj bildirildi. Teşekkür ederiz!')),
      );
    } catch (e) {
      print('Firebase\'de mesaj bildirilirken hata oluştu: $e');
    }
  }

  // Markdown işaretlerini kaldıran yardımcı fonksiyon
  String _removeMarkdownStyling(String text) {
    // Markdown kalınlaştırma işaretlerini (**) kaldırır
    String cleanedText = text.replaceAll(RegExp(r'\*\*'), ''); 
    
    // Markdown italik işaretlerini (*) kaldırır
    cleanedText = cleanedText.replaceAll(RegExp(r'\*'), ''); 

    // Markdown başlık işaretlerini (#) kaldırır
    cleanedText = cleanedText.replaceAll(RegExp(r'^\s*#+\s*'), '');
    
    // Markdown liste işaretlerini (-) kaldırır
    cleanedText = cleanedText.replaceAll(RegExp(r'^\s*-\s*'), '');

    // Diğer Markdown işaretlerini de buraya ekleyebilirsiniz.

    return cleanedText;
  }

  Future<void> _sendMessageToGemini(String messageText) async {
    // İlk mesaj gönderildiğinde yeni bir chat oluştur ve belge ID'sini kaydet
    if (_currentChatDocId == null) {
      String? newDocId = await _saveNewChatToFirebase("1. ${widget.userName}: $messageText");
      if (newDocId != null) {
        _currentChatDocId = newDocId;
      }
    }

    // Kullanıcının mesajını ekle
    _addMessage(Message(text: messageText, role: 'user', messageId: _messageCounter.toString()));
    _messageCounter++;
    _messageController.clear();

    setState(() {
      _isLoading = true;
      _thinkingMessage = Message(text: "Düşünüyorum...", role: 'model', isThinking: true);
      _messages.add(_thinkingMessage!);
    });
    _scrollToBottom();

    try {
      List<dynamic> conversationHistory = _messages
          .where((msg) => !(msg.isThinking ?? false))
          .map((msg) {
        return <String, dynamic>{
          "role": msg.role,
          "parts": [
            <String, dynamic>{"text": msg.text}
          ]
        };
      }).toList();

      String currentPrompt = "Sen bir ders çalışma ve motivasyon rehberisin. Kullanıcıya yardımcı ol, motive et ve gerektiğinde onu 'program oluşturma', 'pomodoro zamanlayıcı', 'hoca arama' veya 'kaynak önerisi' gibi sayfalarımıza yönlendirmeyi teklif et. Gerekli olanlara ve konuyla ilgili olanlara yönlendir. Çok uzun açıklamalar yapma. Cevabında bu yönlendirmeleri açıkça belirt. Soru: $messageText";

      conversationHistory.last = <String, dynamic>{
        "role": "user",
        "parts": [
          <String, dynamic>{"text": currentPrompt}
        ]
      };

      final response = await http.post(
        Uri.parse('$_geminiApiUrl?key=$_geminiApiKey'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          "contents": conversationHistory,
        }),
      );

      setState(() {
        if (_thinkingMessage != null) {
          _messages.remove(_thinkingMessage);
          _thinkingMessage = null;
        }
      });

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        String geminiResponse = "Üzgünüm, bir şeyler ters gitti. Tekrar deneyebilir misin?";
        List<String> suggestedPages = [];

        if (data != null && data['candidates'] != null && data['candidates'].isNotEmpty && data['candidates'][0]['content'] != null && data['candidates'][0]['content']['parts'] != null && data['candidates'][0]['content']['parts'].isNotEmpty && data['candidates'][0]['content']['parts'][0]['text'] != null) {
          geminiResponse = data['candidates'][0]['content']['parts'][0]['text'];
          suggestedPages = _parseSuggestionsFromGeminiResponse(geminiResponse);
        }

        _addMessage(Message(text: geminiResponse, role: 'model', suggestions: suggestedPages, rawGeminiResponse: geminiResponse, animationCompleted: false));
      } else {
        _addMessage(Message(text: "Üzgünüm, Gemini ile bağlantı kurulamadı: ${response.statusCode}", role: 'model'));
      }
      
      // Sohbet geçmişini tek bir string olarak birleştir
      String updatedContent = _messages
          .where((msg) => !(msg.isThinking ?? false))
          .map((msg) {
            return "${_messages.indexOf(msg) + 1}. ${msg.role == 'user' ? 'Kullanıcı' : 'AI'}: ${msg.text}";
          })
          .join('\n');

      // Firebase'de mevcut sohbeti güncelle
      if (_currentChatDocId != null) {
        await _updateChatOnFirebase(_currentChatDocId!, updatedContent);
      }
    } catch (e) {
      setState(() {
        if (_thinkingMessage != null) {
          _messages.remove(_thinkingMessage);
          _thinkingMessage = null;
        }
      });
      _addMessage(Message(text: "Bir hata oluştu: $e", role: 'model'));
    }
  }

  List<String> _parseSuggestionsFromGeminiResponse(String responseText) {
    List<String> suggestions = [];
    String lowerCaseResponse = responseText.toLowerCase();

    if (lowerCaseResponse.contains("program oluştur") || lowerCaseResponse.contains("takvim yap") || lowerCaseResponse.contains("ders programı")) {
      suggestions.add("Program Oluştur");
    }
    if (lowerCaseResponse.contains("pomodoro") || lowerCaseResponse.contains("zamanlayıcı") || lowerCaseResponse.contains("mola")) {
      suggestions.add("Pomodoro Zamanlayıcı");
    }
    if (lowerCaseResponse.contains("hoca ara") || lowerCaseResponse.contains("eğitmen") || lowerCaseResponse.contains("öğretmen")) {
      suggestions.add("Hoca Ara");
    }
    if (lowerCaseResponse.contains("kaynak önerisi") || lowerCaseResponse.contains("kitap") || lowerCaseResponse.contains("materyal") || lowerCaseResponse.contains("ders notu")) {
      suggestions.add("Kaynak Önerisi");
    }
    return suggestions;
  }

  Widget _buildNavigationButton(String text) {
    VoidCallback onPressed;
    switch (text) {
      case "Program Oluştur":
        onPressed = () {
          Navigator.push(context, MaterialPageRoute(builder: (context) => ProgramPage(userName: widget.userName)));
        };
        break;
      case "Pomodoro Zamanlayıcı":
        onPressed = () {
          Navigator.push(context, MaterialPageRoute(builder: (context) => const PomodoroPage()));
        };
        break;
      case "Hoca Ara":
        onPressed = () {
          // Navigator.push(context, MaterialPageRoute(builder: (context) => const HocaAramaPage()));
        };
        break;
      case "Kaynak Önerisi":
        onPressed = () {
          // Navigator.push(context, MaterialPageRoute(builder: (context) => const KaynakOnerisiPage()));
        };
        break;
      default:
        onPressed = () {};
        break;
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.blueAccent,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        ),
        child: Text(text, style: const TextStyle(fontSize: 16)),
      ),
    );
  }

  Widget _buildStyledText(String text, String role) {
    final List<TextSpan> spans = [];
    final RegExp boldRegex = RegExp(r'\*\*(.*?)\*\*');

    int lastMatchEnd = 0;
    for (final Match match in boldRegex.allMatches(text)) {
      if (match.start > lastMatchEnd) {
        spans.add(TextSpan(text: text.substring(lastMatchEnd, match.start)));
      }
      spans.add(
        TextSpan(
          text: match.group(1),
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
      );
      lastMatchEnd = match.end;
    }
    if (lastMatchEnd < text.length) {
      spans.add(TextSpan(text: text.substring(lastMatchEnd)));
    }

    return RichText(
      text: TextSpan(
        style: TextStyle(
          color: role == 'user' ? Colors.blue.shade900 : Colors.black87,
          fontSize: 16,
        ),
        children: spans,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Rehberlik Asistanı', style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.blueAccent,
        centerTitle: true,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Color(0xFFE0F7FA),
              Color(0xFFBBDEFB),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Column(
          children: [
            Expanded(
              child: ListView.builder(
                controller: _scrollController,
                reverse: false,
                padding: const EdgeInsets.all(16.0),
                itemCount: _messages.length,
                itemBuilder: (context, index) {
                  final message = _messages[index];

                  return Column(
                    crossAxisAlignment: message.role == 'user' ? CrossAxisAlignment.end : CrossAxisAlignment.start,
                    children: [
                      Align(
                        alignment: message.role == 'user' ? Alignment.centerRight : Alignment.centerLeft,
                        child: Container(
                          margin: const EdgeInsets.symmetric(vertical: 5, horizontal: 10),
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: message.role == 'user' ? Colors.blue.shade100 : Colors.grey.shade200,
                            borderRadius: BorderRadius.circular(15),
                          ),
                          child: (message.isThinking ?? false)
                              ? Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    const Icon(Icons.psychology_outlined, color: Colors.blueGrey, size: 24),
                                    const SizedBox(width: 8),
                                    Text(
                                      message.text,
                                      style: const TextStyle(
                                        color: Colors.blueGrey,
                                        fontSize: 16,
                                        fontStyle: FontStyle.italic,
                                      ),
                                    ),
                                  ],
                                )
                              : message.role == 'user'
                                  ? _buildStyledText(message.text, message.role)
                                  : message.animationCompleted
                                      ? MarkdownBody(
                                          data: message.text,
                                          styleSheet: MarkdownStyleSheet(
                                            p: const TextStyle(color: Colors.black87, fontSize: 16),
                                            strong: const TextStyle(fontWeight: FontWeight.w600, color: Colors.black),
                                          ),
                                        )
                                      : AnimatedTextKit(
                                          animatedTexts: [
                                            TyperAnimatedText(
                                              _removeMarkdownStyling(message.text),
                                              textStyle: const TextStyle(
                                                color: Colors.black87,
                                                fontSize: 16,
                                              ),
                                              speed: const Duration(milliseconds: 10),
                                            ),
                                          ],
                                          isRepeatingAnimation: false,
                                          onFinished: () {
                                            setState(() {
                                              _isLoading = false;
                                              int msgIndex = _messages.indexOf(message);
                                              if (msgIndex != -1) {
                                                _messages[msgIndex] = message.copyWith(animationCompleted: true);
                                              }
                                            });
                                            _scrollToBottom();
                                          },
                                        ),
                        ),
                      ),
                      if (message.role == 'model' && message.suggestions.isNotEmpty && (message.isThinking ?? false) == false)
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 5.0),
                          child: Wrap(
                            alignment: WrapAlignment.start,
                            spacing: 8.0,
                            runSpacing: 4.0,
                            children: message.suggestions.map((suggestion) {
                              return _buildNavigationButton(suggestion);
                            }).toList(),
                          ),
                        ),
                      if (message.role == 'model' && !(message.isThinking ?? false) && message.animationCompleted)
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 5.0),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              IconButton(
                                icon: const Icon(Icons.copy, size: 20, color: Colors.blueGrey),
                                tooltip: 'Mesajı Kopyala',
                                onPressed: () {
                                  Clipboard.setData(ClipboardData(text: message.text));
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(content: Text('Mesaj kopyalandı!')),
                                  );
                                },
                              ),
                              IconButton(
                                icon: const Icon(Icons.report_outlined, size: 20, color: Colors.blueGrey),
                                tooltip: 'Uygunsuz İçeriği Bildir',
                                onPressed: () {
                                  // Firebase'de mesajı bildirildi olarak işaretle
                                  if (_currentChatDocId != null) {
                                    _reportMessage(_currentChatDocId!);
                                  }
                                },
                              ),
                            ],
                          ),
                        ),
                      const SizedBox(height: 5),
                    ],
                  );
                },
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _messageController,
                      enabled: !_isLoading,
                      decoration: InputDecoration(
                        hintText: _isLoading ? 'Düşünüyorum...' : 'Bir şeyler yaz...',
                        filled: true,
                        fillColor: _isLoading ? Colors.grey.shade300 : Colors.white,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(25.0),
                          borderSide: BorderSide.none,
                        ),
                        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                      ),
                      onSubmitted: _isLoading ? null : (value) {
                        if (value.isNotEmpty) {
                          _sendMessageToGemini(value);
                        }
                      },
                    ),
                  ),
                  const SizedBox(width: 10),
                  FloatingActionButton(
                    onPressed: _isLoading ? null : () {
                      if (_messageController.text.isNotEmpty) {
                        _sendMessageToGemini(_messageController.text);
                      }
                    },
                    backgroundColor: _isLoading ? Colors.grey : Colors.blueAccent,
                    mini: true,
                    child: _isLoading
                        ? const CircularProgressIndicator(valueColor: AlwaysStoppedAnimation<Color>(Colors.white))
                        : const Icon(Icons.send, color: Colors.white),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}