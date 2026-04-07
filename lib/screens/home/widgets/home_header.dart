import 'package:flutter/material.dart';

class HomeHeader extends StatelessWidget {
  final VoidCallback onProfileTap;

  const HomeHeader({
    super.key,
    required this.onProfileTap,
  });

  @override
  Widget build(BuildContext context) {
    final topPadding = MediaQuery.of(context).padding.top;
    
    return Padding(
      padding: EdgeInsets.fromLTRB(20, topPadding + 16, 20, 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Text(
            'Note AI',
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.w900,
              letterSpacing: -0.5,
              color: Colors.black87,
            ),
          ),
          Row(
            children: [
              _buildProBadge(),
              const SizedBox(width: 12),
              _buildProfileButton(),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildProBadge() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: const Color(0xFF2D2D2D),
        borderRadius: BorderRadius.circular(20),
      ),
      child: const Row(
        children: [
          Icon(Icons.auto_awesome, color: Colors.white, size: 14),
          SizedBox(width: 4),
          Text(
            'PRO',
            style: TextStyle(
              color: Colors.white,
              fontSize: 12,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProfileButton() {
    return GestureDetector(
      onTap: onProfileTap,
      child: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: Colors.white,
          shape: BoxShape.circle,
          border: Border.all(color: Colors.grey.withOpacity(0.1)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.03),
              blurRadius: 10,
              spreadRadius: 2,
            ),
          ],
        ),
        child: const Icon(
          Icons.person_outline,
          size: 24,
          color: Colors.black87,
        ),
      ),
    );
  }
}
