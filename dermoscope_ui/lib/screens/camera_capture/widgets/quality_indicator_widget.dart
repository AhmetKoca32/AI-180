import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

class QualityIndicatorWidget extends StatelessWidget {
  final String status;
  final String message;

  const QualityIndicatorWidget({
    Key? key,
    required this.status,
    required this.message,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 2.h),
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: 0.7),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: _getStatusColor().withValues(alpha: 0.5),
          width: 1,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Status Indicator
          Container(
            width: 3.w,
            height: 3.w,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: _getStatusColor(),
              boxShadow: [
                BoxShadow(
                  color: _getStatusColor().withValues(alpha: 0.5),
                  blurRadius: 4,
                  spreadRadius: 1,
                ),
              ],
            ),
          ),

          SizedBox(width: 3.w),

          // Status Message
          Flexible(
            child: Text(
              message,
              style: TextStyle(
                color: Colors.white,
                fontSize: 14.sp,
                fontWeight: FontWeight.w500,
              ),
              textAlign: TextAlign.center,
            ),
          ),

          SizedBox(width: 2.w),

          // Quality Indicators
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildQualityDot('sharpness'),
              SizedBox(width: 1.w),
              _buildQualityDot('lighting'),
              SizedBox(width: 1.w),
              _buildQualityDot('focus'),
            ],
          ),
        ],
      ),
    );
  }

  Color _getStatusColor() {
    switch (status) {
      case 'good':
        return Colors.green;
      case 'warning':
        return Colors.orange;
      case 'poor':
        return Colors.red;
      case 'checking':
      default:
        return Colors.yellow;
    }
  }

  Widget _buildQualityDot(String type) {
    Color dotColor;
    switch (status) {
      case 'good':
        dotColor = Colors.green;
        break;
      case 'warning':
        dotColor = Colors.orange;
        break;
      case 'poor':
        dotColor = Colors.red;
        break;
      case 'checking':
      default:
        dotColor = Colors.yellow;
        break;
    }

    return Container(
      width: 2.w,
      height: 2.w,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: dotColor,
      ),
    );
  }
}
