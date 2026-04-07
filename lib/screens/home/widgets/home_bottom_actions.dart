import 'package:flutter/material.dart';

class HomeBottomActions extends StatelessWidget {
  final VoidCallback onRecordTap;
  final VoidCallback onNewNoteTap;
  
  const HomeBottomActions({
    super.key,
    required this.onRecordTap,
    required this.onNewNoteTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 32),
      decoration: BoxDecoration(
        color: Colors.grey.withOpacity(0.04), // subtle background
      ),
      child: Row(
        children: [
          Expanded(
            flex: 6,
            child: _buildActionButton(
              onTap: onRecordTap,
              icon: Icons.circle,
              iconColor: Colors.red,
              label: 'Record',
              backgroundColor: const Color(0xFF1A1A1A),
              labelColor: Colors.white,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            flex: 5,
            child: _buildActionButton(
              onTap: onNewNoteTap,
              icon: Icons.edit_outlined,
              iconColor: Colors.black,
              label: 'New Note',
              backgroundColor: Colors.white,
              labelColor: Colors.black,
              withShadow: true,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton({
    required VoidCallback onTap,
    required IconData icon,
    required Color iconColor,
    required String label,
    required Color backgroundColor,
    required Color labelColor,
    bool withShadow = false,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          color: backgroundColor,
          borderRadius: BorderRadius.circular(30),
          boxShadow: withShadow
              ? [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ]
              : null,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 14, color: iconColor),
            const SizedBox(width: 8),
            Text(
              label,
              style: TextStyle(
                color: labelColor,
                fontWeight: FontWeight.bold,
                fontSize: 15,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
