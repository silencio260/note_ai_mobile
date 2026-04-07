import 'package:flutter/material.dart';

class NotesToggle extends StatefulWidget {
  final ValueChanged<int> onToggle;
  
  const NotesToggle({
    super.key,
    required this.onToggle,
  });

  @override
  State<NotesToggle> createState() => _NotesToggleState();
}

class _NotesToggleState extends State<NotesToggle> {
  int _index = 0;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 40),
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: Colors.grey.withOpacity(0.12),
        borderRadius: BorderRadius.circular(30),
      ),
      child: Row(
        children: [
          Expanded(
            child: _buildToggleItem(0, Icons.edit_note_outlined, 'All Notes'),
          ),
          Expanded(
            child: _buildToggleItem(1, Icons.folder_open_outlined, 'Folders'),
          ),
        ],
      ),
    );
  }

  Widget _buildToggleItem(int index, IconData icon, String label) {
    final isSelected = _index == index;
    return GestureDetector(
      onTap: () {
        setState(() {
          _index = index;
        });
        widget.onToggle(index);
      },
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: isSelected ? Colors.white : Colors.transparent,
          borderRadius: BorderRadius.circular(28),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.08),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ]
              : null,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 20,
              color: isSelected ? Colors.black : Colors.grey[600],
            ),
            const SizedBox(width: 8),
            Text(
              label,
              style: TextStyle(
                fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                color: isSelected ? Colors.black : Colors.grey[600],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
