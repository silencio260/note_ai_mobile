import 'package:flutter/material.dart';

class FolderSelectionSheet extends StatelessWidget {
  final String? selectedFolderId;
  final Function(String?) onFolderSelected;

  const FolderSelectionSheet({
    super.key,
    required this.selectedFolderId,
    required this.onFolderSelected,
  });

  // Mocked folders for UI demonstration
  static const List<Map<String, String>> folders = [
    {'name': 'All Notes', 'id': 'all', 'icon': '📂'},
    {'name': 'Meetings', 'id': 'meetings', 'icon': '🏢'},
    {'name': 'University', 'id': 'uni', 'icon': '🎓'},
    {'name': 'Personal', 'id': 'personal', 'icon': '🏠'},
    {'name': 'Ideas', 'id': 'ideas', 'icon': '💡'},
    {'name': 'Interview', 'id': 'interview', 'icon': '🎙️'},
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(24),
          topRight: Radius.circular(24),
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Move to Folder',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              IconButton(
                onPressed: () => Navigator.pop(context),
                icon: const Icon(Icons.close),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Flexible(
            child: ListView.builder(
              shrinkWrap: true,
              itemCount: folders.length,
              itemBuilder: (context, index) {
                final folder = folders[index];
                final isSelected = folder['id'] == selectedFolderId || (selectedFolderId == null && folder['id'] == 'all');

                return ListTile(
                  onTap: () {
                    onFolderSelected(folder['id'] == 'all' ? null : folder['id']);
                    Navigator.pop(context);
                  },
                  leading: Text(folder['icon']!, style: const TextStyle(fontSize: 20)),
                  title: Text(
                    folder['name']!,
                    style: TextStyle(
                      fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                      color: isSelected ? Colors.black : Colors.grey.shade700,
                    ),
                  ),
                  trailing: isSelected
                      ? const Icon(Icons.check_circle, color: Colors.black)
                      : null,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  tileColor: isSelected ? Colors.grey.shade50 : null,
                );
              },
            ),
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: TextButton.icon(
              onPressed: () {
                // Logic to create a new folder
                Navigator.pop(context);
              },
              icon: const Icon(Icons.add_rounded, color: Colors.black),
              label: const Text('Create New Folder', style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
              style: TextButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
                backgroundColor: Colors.grey.shade50,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
          ),
          SizedBox(height: MediaQuery.of(context).padding.bottom + 16),
        ],
      ),
    );
  }
}
