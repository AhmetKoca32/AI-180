import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sizer/sizer.dart';

import '../../core/app_export.dart';
import '../../services/api_service.dart';
import 'widgets/chat_message_widget.dart';
// import 'widgets/consultation_type_selector.dart';
import 'widgets/message_input_widget.dart';
import 'widgets/quick_reply_chips.dart';
import 'widgets/typing_indicator_widget.dart'; 

class ChatConsultation extends StatefulWidget {
  const ChatConsultation({super.key});

  @override
  State<ChatConsultation> createState() => _ChatConsultationState();
}

class _ChatConsultationState extends State<ChatConsultation>
    with TickerProviderStateMixin {
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final FocusNode _messageFocusNode = FocusNode();

  String _selectedConsultationType = 'Skin';
  bool _isTyping = false;
  bool _isAiTyping = false;

  final List<Map<String, dynamic>> _messages = [
    {
      "id": "1",
      "text":
          "Merhaba! Ben DermaScope AI asistanınızım. Cilt, saç ve genel dermatolojik sorularınızda size yardımcı olmak için buradayım. Size nasıl yardımcı olabilirim?",
      "isUser": false,
      "timestamp": DateTime.now().subtract(const Duration(minutes: 2)),
      "messageType": "text",
      "consultationType": "General",
    },
  ];

  final List<String> _quickReplies = [
    "Cilt analizi sonuçlarım hakkında",
    "Günlük bakım rutini önerisi",
    "Akne tedavi yöntemleri",
    "Güneş koruma önerileri",
    "Saç dökülmesi sorunu",
    "Cilt tipi belirleme",
  ];

  @override
  void initState() {
    super.initState();
    _messageFocusNode.addListener(_onFocusChange);
  }

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    _messageFocusNode.dispose();
    super.dispose();
  }

  void _onFocusChange() {
    setState(() {
      _isTyping = _messageFocusNode.hasFocus;
    });
  }

  void _sendMessage(String text) {
    if (text.trim().isEmpty) return;

    final userMessage = {
      "id": DateTime.now().millisecondsSinceEpoch.toString(),
      "text": text.trim(),
      "isUser": true,
      "timestamp": DateTime.now(),
      "messageType": "text",
      "consultationType": _selectedConsultationType,
    };

    setState(() {
      _messages.add(userMessage);
      _isAiTyping = true;
    });

    _messageController.clear();
    _scrollToBottom();

    // Simulate AI response
    Future.delayed(const Duration(seconds: 2), () {
      if (!mounted) return;
      _generateAiResponse(text.trim());
    });

    // Haptic feedback
    HapticFeedback.lightImpact();
  }

  Future<void> _generateAiResponse(String userMessage) async {
    if (!mounted) return;
    setState(() {
      _isAiTyping = true;
    });

    try {
      final aiResponse = await ApiService.getAdvice(
        userMessage +
            "\n\nCevabını SADECE HTML olarak, kod bloğu (```) ve <html>, <head>, <body>, <title> etiketleri olmadan, sadece <ol> veya <ul> ile sarılmış <li> listesi olarak döndür. Eğer ana başlıklar varsa <h3>Başlık</h3> şeklinde kullan. Cevabın detaylı, açıklayıcı, kişiye özel ve örneklerle desteklenmiş olsun. Her adımı kısa açıklamalarla açıkla. Kod bloğu veya başka açıklama ekleme.",
      );
    if (!mounted) return;
    final aiMessage = {
      "id": DateTime.now().millisecondsSinceEpoch.toString(),
      "text": aiResponse,
      "isUser": false,
      "timestamp": DateTime.now(),
      "messageType": "text",
      "consultationType": _selectedConsultationType,
      "hasQuickActions": true,
      };
    setState(() {
      _messages.add(aiMessage);
      _isAiTyping = false;
      });
    _scrollToBottom();
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _isAiTyping = false;
      });
      // Hata mesajı gösterebilirsin
    }
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

  void _onQuickReplyTap(String reply) {
    _sendMessage(reply);
  }

  void _onConsultationTypeChanged(String type) {
    setState(() {
      _selectedConsultationType = type;
    });
  }

  void _onAttachmentTap() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        decoration: BoxDecoration(
          color: AppTheme.lightTheme.colorScheme.surface,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 4,
              margin: const EdgeInsets.symmetric(vertical: 12),
              decoration: BoxDecoration(
                color: AppTheme.lightTheme.colorScheme.outline,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            ListTile(
              leading: CustomIconWidget(
                iconName: 'camera',
                color: AppTheme.lightTheme.colorScheme.primary,
                size: 24,
              ),
              title: Text(
                'Kamera ile Çek',
                style: AppTheme.lightTheme.textTheme.bodyLarge,
              ),
              onTap: () {
                Navigator.pop(context);
                Navigator.pushNamed(context, '/camera-capture');
              },
            ),
            ListTile(
              leading: CustomIconWidget(
                iconName: 'photo_library',
                color: AppTheme.lightTheme.colorScheme.primary,
                size: 24,
              ),
              title: Text(
                'Galeriden Seç',
                style: AppTheme.lightTheme.textTheme.bodyLarge,
              ),
              onTap: () {
                Navigator.pop(context);
                // Handle gallery selection
              },
            ),
            ListTile(
              leading: CustomIconWidget(
                iconName: 'history',
                color: AppTheme.lightTheme.colorScheme.primary,
                size: 24,
              ),
              title: Text(
                'Analiz Geçmişi',
                style: AppTheme.lightTheme.textTheme.bodyLarge,
              ),
              onTap: () {
                Navigator.pop(context);
                Navigator.pushNamed(context, '/skin-analysis-history');
              },
            ),
            SizedBox(height: 2.h),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.lightTheme.scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: AppTheme.lightTheme.colorScheme.surface,
        elevation: 0,
        leading: IconButton(
          icon: CustomIconWidget(
            iconName: 'arrow_back',
            color: AppTheme.lightTheme.colorScheme.onSurface,
            size: 24,
          ),
          onPressed: () => Navigator.pop(context),
        ),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'AI Konsültasyon',
              style: AppTheme.lightTheme.textTheme.titleLarge,
            ),
            Text(
              '$_selectedConsultationType Danışmanlığı',
              style: AppTheme.lightTheme.textTheme.bodySmall?.copyWith(
                color: AppTheme.lightTheme.colorScheme.primary,
              ),
            ),
          ],
        ),
        actions: [
          PopupMenuButton<String>(
            icon: CustomIconWidget(
              iconName: 'more_vert',
              color: AppTheme.lightTheme.colorScheme.onSurface,
              size: 24,
            ),
            onSelected: (value) {
              switch (value) {
                case 'export':
                  // Handle export conversation
                  break;
                case 'clear':
                  setState(() {
                    _messages.clear();
                  });
                  break;
                case 'settings':
                  Navigator.pushNamed(context, '/profile-settings');
                  break;
              }
            },
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 'export',
                child: Text('Konuşmayı Dışa Aktar'),
              ),
              const PopupMenuItem(
                value: 'clear',
                child: Text('Konuşmayı Temizle'),
              ),
              const PopupMenuItem(value: 'settings', child: Text('Ayarlar')),
            ],
          ),
        ],
      ),
      body: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Expanded(
            child: ListView.builder(
              controller: _scrollController,
              padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 1.h),
              itemCount: _messages.length + (_isAiTyping ? 1 : 0),
              itemBuilder: (context, index) {
                if (index == _messages.length && _isAiTyping) {
                  return const TypingIndicatorWidget();
                }
                final message = _messages[index];
                return ChatMessageWidget(
                  message: message,
                  onImageTap: (imageUrl) {
                    // Handle image tap
                  },
                );
              },
            ),
          ),
          if (!_isTyping && _messages.isNotEmpty)
            QuickReplyChips(
              replies: _quickReplies,
              onReplyTap: _onQuickReplyTap,
            ),
          MessageInputWidget(
            controller: _messageController,
            focusNode: _messageFocusNode,
            onSend: _sendMessage,
            onAttachmentTap: _onAttachmentTap,
          ),
        ],
      ),
    );
  }
}
