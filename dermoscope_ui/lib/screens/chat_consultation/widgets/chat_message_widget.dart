import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';

class ChatMessageWidget extends StatelessWidget {
  final Map<String, dynamic> message;
  final Function(String)? onImageTap;

  const ChatMessageWidget({super.key, required this.message, this.onImageTap});

  @override
  Widget build(BuildContext context) {
    final bool isUser = message['isUser'] ?? false;
    final String text = message['text'] ?? '';
    final DateTime timestamp = message['timestamp'] ?? DateTime.now();
    final String messageType = message['messageType'] ?? 'text';
    final bool hasQuickActions = message['hasQuickActions'] ?? false;

    if (!isUser) {
      debugPrint('AI MAIN HTML: ' + ensureListWrapped(fixLiParagraphs(text)));
      debugPrint('AI RAW: $text');
      debugPrint(
        'AI CLEAN: ' + ensureListWrapped(fixLiParagraphs(cleanHtml(text))),
      );
    }

    return Container(
      margin: EdgeInsets.symmetric(vertical: 0.5.h),
      child: Column(
        crossAxisAlignment: isUser
            ? CrossAxisAlignment.end
            : CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: isUser
                ? MainAxisAlignment.end
                : MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              if (!isUser) ...[
                CircleAvatar(
                  radius: 16,
                  backgroundColor: AppTheme.lightTheme.colorScheme.primary,
                  child: CustomIconWidget(
                    iconName: 'smart_toy',
                    color: AppTheme.lightTheme.colorScheme.onPrimary,
                    size: 18,
                  ),
                ),
                SizedBox(width: 2.w),
              ],
              Flexible(
                child: GestureDetector(
                  onLongPress: () => _showMessageOptions(context, text),
                  child: Container(
                    constraints: BoxConstraints(maxWidth: 75.w),
                    padding: EdgeInsets.symmetric(
                      horizontal: 4.w,
                      vertical: 1.5.h,
                    ),
                    decoration: BoxDecoration(
                      color: isUser
                          ? AppTheme.lightTheme.colorScheme.primary
                          : AppTheme.lightTheme.colorScheme.surface,
                      borderRadius: BorderRadius.only(
                        topLeft: const Radius.circular(16),
                        topRight: const Radius.circular(16),
                        bottomLeft: Radius.circular(isUser ? 16 : 4),
                        bottomRight: Radius.circular(isUser ? 4 : 16),
                      ),
                      border: !isUser
                          ? Border.all(
                              color: AppTheme.lightTheme.colorScheme.outline
                                  .withValues(alpha: 0.2),
                              width: 1,
                            )
                          : null,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (messageType == 'image') ...[
                          ClipRRect(
                            borderRadius: BorderRadius.circular(8),
                            child: CustomImageWidget(
                              imageUrl: message['imageUrl'] ?? '',
                              width: 60.w,
                              height: 30.h,
                              fit: BoxFit.cover,
                            ),
                          ),
                          if (text.isNotEmpty) ...[
                            SizedBox(height: 1.h),
                            !isUser && messageType == 'text'
                                ? Html(
                                    data: ensureListWrapped(
                                      fixLiParagraphs(cleanHtml(text)),
                                    ),
                                    style: {
                                      "body": Style(
                                        fontSize: FontSize(14.0),
                                        color: AppTheme
                                            .lightTheme
                                            .colorScheme
                                            .onSurface,
                                        fontFamily: AppTheme
                                            .lightTheme
                                            .textTheme
                                            .bodyMedium
                                            ?.fontFamily,
                                      ),
                                      "h3": Style(
                                        fontSize: FontSize(18.0),
                                        fontWeight: FontWeight.bold,
                                      ),
                                      "li": Style(),
                                    },
                                  )
                                : Text(
                                    text,
                                    style: AppTheme
                                        .lightTheme
                                        .textTheme
                                        .bodyMedium
                                        ?.copyWith(
                                          color: isUser
                                              ? AppTheme
                                                    .lightTheme
                                                    .colorScheme
                                                    .onPrimary
                                              : AppTheme
                                                    .lightTheme
                                                    .colorScheme
                                                    .onSurface,
                                        ),
                                  ),
                          ],
                        ] else ...[
                          !isUser && messageType == 'text'
                              ? Html(
                                  data: ensureListWrapped(
                                    fixLiParagraphs(cleanHtml(text)),
                                  ),
                                  style: {
                                    "body": Style(
                                      fontSize: FontSize(14.0),
                                      color: AppTheme
                                          .lightTheme
                                          .colorScheme
                                          .onSurface,
                                      fontFamily: AppTheme
                                          .lightTheme
                                          .textTheme
                                          .bodyMedium
                                          ?.fontFamily,
                                    ),
                                    "h3": Style(
                                      fontSize: FontSize(18.0),
                                      fontWeight: FontWeight.bold,
                                    ),
                                    "li": Style(),
                                  },
                                )
                              : Text(
                                  text,
                                  style: AppTheme
                                      .lightTheme
                                      .textTheme
                                      .bodyMedium
                                      ?.copyWith(
                                        color: isUser
                                            ? AppTheme
                                                  .lightTheme
                                                  .colorScheme
                                                  .onPrimary
                                            : AppTheme
                                                  .lightTheme
                                                  .colorScheme
                                                  .onSurface,
                                      ),
                          ),
                        ],
                        SizedBox(height: 0.5.h),
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              _formatTime(timestamp),
                              style: AppTheme.lightTheme.textTheme.bodySmall
                                  ?.copyWith(
                                    color:
                                        (isUser
                                                ? AppTheme
                                                      .lightTheme
                                                      .colorScheme
                                                      .onPrimary
                                                : AppTheme
                                                      .lightTheme
                                                      .colorScheme
                                                      .onSurface)
                                            .withValues(alpha: 0.7),
                                    fontSize: 10.sp,
                                  ),
                            ),
                            if (isUser) ...[
                              SizedBox(width: 1.w),
                              CustomIconWidget(
                                iconName: 'done_all',
                                color: AppTheme.lightTheme.colorScheme.onPrimary
                                    .withValues(alpha: 0.7),
                                size: 12,
                              ),
                            ],
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              if (isUser) ...[
                SizedBox(width: 2.w),
                CircleAvatar(
                  radius: 16,
                  backgroundColor: AppTheme.lightTheme.colorScheme.secondary,
                  child: CustomIconWidget(
                    iconName: 'person',
                    color: AppTheme.lightTheme.colorScheme.onSecondary,
                    size: 18,
                  ),
                ),
              ],
            ],
          ),
          if (hasQuickActions && !isUser) ...[
            SizedBox(height: 1.h),
            Padding(
              padding: EdgeInsets.only(left: 10.w),
              child: Wrap(
                spacing: 2.w,
                runSpacing: 1.h,
                children: [
                  _buildQuickActionChip(
                    context,
                    'Daha Fazla Bilgi',
                    Icons.info_outline,
                    isUser,
                  ),
                  _buildQuickActionChip(
                    context,
                    'Uzman Önerisi',
                    Icons.medical_services_outlined,
                    isUser,
                  ),
                  _buildQuickActionChip(
                    context,
                    'Analiz Geçmişi',
                    Icons.history,
                    isUser,
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildQuickActionChip(
    BuildContext context,
    String label,
    IconData icon,
    bool isUser,
  ) {
    return InkWell(
      onTap: () {
        // Handle quick action
        HapticFeedback.lightImpact();
      },
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 3.w, vertical: 0.8.h),
        decoration: BoxDecoration(
          color: AppTheme.lightTheme.colorScheme.primaryContainer,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: AppTheme.lightTheme.colorScheme.primary.withValues(
              alpha: 0.3,
            ),
            width: 1,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 14,
              color: AppTheme.lightTheme.colorScheme.primary,
            ),
            SizedBox(width: 1.w),
            isUser
                ? Text(
                    label,
                    style: AppTheme.lightTheme.textTheme.bodySmall?.copyWith(
                      color: AppTheme.lightTheme.colorScheme.primary,
                      fontWeight: FontWeight.w500,
                    ),
                  )
                : Html(
                    data: ensureListWrapped(fixLiParagraphs(cleanHtml(label))),
                    style: {
                      "body": Style(
                        fontSize: FontSize(16),
                        color: Colors.black87,
                        lineHeight: LineHeight(2.0),
                        padding: HtmlPaddings.zero,
                        margin: Margins.zero,
                      ),
                      "ol": Style(
                        margin: Margins.only(left: 12, top: 12, bottom: 12),
                        padding: HtmlPaddings.only(left: 12),
                      ),
                      "ul": Style(
                        margin: Margins.only(left: 24, top: 8, bottom: 8),
                        padding: HtmlPaddings.only(left: 16),
                      ),
                      "li": Style(
                        fontSize: FontSize(16),
                        color: Colors.black87,
                        padding: HtmlPaddings.symmetric(
                          vertical: 8,
                          horizontal: 8,
                        ),
                        margin: Margins.only(bottom: 10),
                        backgroundColor: Color(0xFFF6F6FA),
                        // borderRadius yerine:
                        border: Border.all(color: Colors.transparent),
                        lineHeight: LineHeight(1.7),
                      ),
                      "b": Style(
                        fontWeight: FontWeight.bold,
                        fontSize: FontSize(18),
                        color: Colors.deepPurple,
                        letterSpacing: 0.5,
                      ),
                      "strong": Style(
                        fontWeight: FontWeight.bold,
                        fontSize: FontSize(18),
                        color: Colors.deepPurple,
                        letterSpacing: 0.5,
                      ),
                    },
                  )
          ],
        ),
      ),
    );
  }

  void _showMessageOptions(BuildContext context, String text) {
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
                iconName: 'copy',
                color: AppTheme.lightTheme.colorScheme.primary,
                size: 24,
              ),
              title: Text(
                'Kopyala',
                style: AppTheme.lightTheme.textTheme.bodyLarge,
              ),
              onTap: () {
                Clipboard.setData(ClipboardData(text: text));
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Mesaj kopyalandı')),
                );
              },
            ),
            ListTile(
              leading: CustomIconWidget(
                iconName: 'share',
                color: AppTheme.lightTheme.colorScheme.primary,
                size: 24,
              ),
              title: Text(
                'Paylaş',
                style: AppTheme.lightTheme.textTheme.bodyLarge,
              ),
              onTap: () {
                Navigator.pop(context);
                // Handle share
              },
            ),
            ListTile(
              leading: CustomIconWidget(
                iconName: 'bookmark',
                color: AppTheme.lightTheme.colorScheme.primary,
                size: 24,
              ),
              title: Text(
                'Kaydet',
                style: AppTheme.lightTheme.textTheme.bodyLarge,
              ),
              onTap: () {
                Navigator.pop(context);
                // Handle save
              },
            ),
            SizedBox(height: 2.h),
          ],
        ),
      ),
    );
  }

  String _formatTime(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.inMinutes < 1) {
      return 'Şimdi';
    } else if (difference.inMinutes < 60) {
      return '${difference.inMinutes}dk';
    } else if (difference.inHours < 24) {
      return '${difference.inHours}sa';
    } else {
      return '${dateTime.day}/${dateTime.month}';
    }
  }
}

String cleanHtml(String html) {
  return html
      .replaceAll(RegExp(r'```html|```', caseSensitive: false), '')
      .replaceAll(RegExp(r'<html.*?>|</html>', caseSensitive: false), '')
      .replaceAll(
        RegExp(r'<head.*?>.*?</head>', caseSensitive: false, dotAll: true),
        '',
      )
      .replaceAll(RegExp(r'<body.*?>|</body>', caseSensitive: false), '')
      .replaceAll(
        RegExp(r'<title.*?>.*?</title>', caseSensitive: false, dotAll: true),
        '',
      )
      .replaceAll('\n', '')
      .trim();
}

String fixLiParagraphs(String html) {
  return html.replaceAllMapped(
    RegExp(r'<li>(.*?)<p>(.*?)</p>(.*?)</li>', dotAll: true),
    (m) => '<li>${m[1]}${m[2]}${m[3]}</li>',
  );
}

String ensureListWrapped(String html) {
  final trimmed = html.trim();
  if (trimmed.startsWith('<li') && trimmed.endsWith('</li>')) {
    return '<ol>$trimmed</ol>';
  }
  return trimmed;
}
