import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';

class QuickReplyChips extends StatelessWidget {
  final List<String> replies;
  final Function(String) onReplyTap;

  const QuickReplyChips({
    super.key,
    required this.replies,
    required this.onReplyTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 6.h,
      padding: EdgeInsets.symmetric(vertical: 1.h),
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: EdgeInsets.symmetric(horizontal: 4.w),
        itemCount: replies.length,
        itemBuilder: (context, index) {
          final reply = replies[index];
          return Container(
            margin: EdgeInsets.only(right: 2.w),
            child: InkWell(
              onTap: () {
                HapticFeedback.lightImpact();
                onReplyTap(reply);
              },
              borderRadius: BorderRadius.circular(20),
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 1.h),
                decoration: BoxDecoration(
                  color: AppTheme.lightTheme.colorScheme.primaryContainer,
                  borderRadius: BorderRadius.circular(20),
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
                    CustomIconWidget(
                      iconName: _getIconForReply(reply),
                      color: AppTheme.lightTheme.colorScheme.primary,
                      size: 16,
                    ),
                    SizedBox(width: 2.w),
                    Text(
                      reply,
                      style: AppTheme.lightTheme.textTheme.bodySmall?.copyWith(
                        color: AppTheme.lightTheme.colorScheme.primary,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  String _getIconForReply(String reply) {
    if (reply.contains('analiz') || reply.contains('sonuç')) {
      return 'analytics';
    } else if (reply.contains('bakım') || reply.contains('rutin')) {
      return 'spa';
    } else if (reply.contains('akne') || reply.contains('tedavi')) {
      return 'healing';
    } else if (reply.contains('güneş') || reply.contains('koruma')) {
      return 'wb_sunny';
    } else if (reply.contains('saç') || reply.contains('dökülme')) {
      return 'brush';
    } else if (reply.contains('cilt tipi')) {
      return 'face';
    } else {
      return 'help_outline';
    }
  }
}
