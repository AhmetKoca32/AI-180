import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';

class MessageInputWidget extends StatefulWidget {
  final TextEditingController controller;
  final FocusNode focusNode;
  final Function(String) onSend;
  final VoidCallback onAttachmentTap;

  const MessageInputWidget({
    super.key,
    required this.controller,
    required this.focusNode,
    required this.onSend,
    required this.onAttachmentTap,
  });

  @override
  State<MessageInputWidget> createState() => _MessageInputWidgetState();
}

class _MessageInputWidgetState extends State<MessageInputWidget> {
  bool _canSend = false;

  @override
  void initState() {
    super.initState();
    widget.controller.addListener(_onTextChanged);
  }

  @override
  void dispose() {
    widget.controller.removeListener(_onTextChanged);
    super.dispose();
  }

  void _onTextChanged() {
    final canSend = widget.controller.text.trim().isNotEmpty;
    if (canSend != _canSend) {
      setState(() {
        _canSend = canSend;
      });
    }
  }

  void _handleSend() {
    if (_canSend) {
      widget.onSend(widget.controller.text);
      HapticFeedback.lightImpact();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 1.h),
      decoration: BoxDecoration(
        color: AppTheme.lightTheme.colorScheme.surface,
        border: Border(
          top: BorderSide(
            color: AppTheme.lightTheme.colorScheme.outline.withValues(
              alpha: 0.2,
            ),
            width: 1,
          ),
        ),
      ),
      child: SafeArea(
        child: Row(
          children: [
            // Attachment Button
            IconButton(
              onPressed: widget.onAttachmentTap,
              icon: CustomIconWidget(
                iconName: 'attach_file',
                color: AppTheme.lightTheme.colorScheme.primary,
                size: 24,
              ),
              style: IconButton.styleFrom(
                backgroundColor:
                    AppTheme.lightTheme.colorScheme.primaryContainer,
                shape: const CircleBorder(),
                padding: EdgeInsets.all(2.w),
              ),
            ),

            SizedBox(width: 2.w),

            // Text Input Field
            Expanded(
              child: Container(
                constraints: BoxConstraints(minHeight: 5.h, maxHeight: 15.h),
                child: TextField(
                  controller: widget.controller,
                  focusNode: widget.focusNode,
                  maxLines: null,
                  textInputAction: TextInputAction.newline,
                  keyboardType: TextInputType.multiline,
                  style: AppTheme.lightTheme.textTheme.bodyMedium,
                  decoration: InputDecoration(
                    hintText: 'Mesajınızı yazın...',
                    hintStyle: AppTheme.lightTheme.textTheme.bodyMedium
                        ?.copyWith(
                          color: AppTheme.lightTheme.colorScheme.onSurface
                              .withValues(alpha: 0.6),
                        ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(24),
                      borderSide: BorderSide(
                        color: AppTheme.lightTheme.colorScheme.outline
                            .withValues(alpha: 0.3),
                        width: 1,
                      ),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(24),
                      borderSide: BorderSide(
                        color: AppTheme.lightTheme.colorScheme.outline
                            .withValues(alpha: 0.3),
                        width: 1,
                      ),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(24),
                      borderSide: BorderSide(
                        color: AppTheme.lightTheme.colorScheme.primary,
                        width: 2,
                      ),
                    ),
                    filled: true,
                    fillColor: AppTheme.lightTheme.colorScheme.surface,
                    contentPadding: EdgeInsets.symmetric(
                      horizontal: 4.w,
                      vertical: 1.5.h,
                    ),
                    suffixIcon: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // Emoji Button
                        IconButton(
                          onPressed: () {
                            // Handle emoji picker
                            HapticFeedback.lightImpact();
                          },
                          icon: CustomIconWidget(
                            iconName: 'emoji_emotions',
                            color: AppTheme.lightTheme.colorScheme.onSurface
                                .withValues(alpha: 0.6),
                            size: 20,
                          ),
                        ),

                        // Voice Message Button
                        IconButton(
                          onPressed: () {
                            // Handle voice message
                            HapticFeedback.lightImpact();
                          },
                          icon: CustomIconWidget(
                            iconName: 'mic',
                            color: AppTheme.lightTheme.colorScheme.onSurface
                                .withValues(alpha: 0.6),
                            size: 20,
                          ),
                        ),
                      ],
                    ),
                  ),
                  onSubmitted: (value) {
                    if (_canSend) {
                      _handleSend();
                    }
                  },
                ),
              ),
            ),

            SizedBox(width: 2.w),

            // Send Button
            AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              child: IconButton(
                onPressed: _canSend ? _handleSend : null,
                icon: CustomIconWidget(
                  iconName: 'send',
                  color: _canSend
                      ? AppTheme.lightTheme.colorScheme.onPrimary
                      : AppTheme.lightTheme.colorScheme.onSurface.withValues(
                          alpha: 0.4,
                        ),
                  size: 20,
                ),
                style: IconButton.styleFrom(
                  backgroundColor: _canSend
                      ? AppTheme.lightTheme.colorScheme.primary
                      : AppTheme.lightTheme.colorScheme.outline.withValues(
                          alpha: 0.2,
                        ),
                  shape: const CircleBorder(),
                  padding: EdgeInsets.all(2.w),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
