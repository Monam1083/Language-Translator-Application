import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/language.dart';

class LanguagePickerSheet extends StatefulWidget {
  final Language selected;
  final Function(Language) onSelect;
  final String title;

  const LanguagePickerSheet({
    super.key,
    required this.selected,
    required this.onSelect,
    required this.title,
  });

  static Future<void> show(
    BuildContext context, {
    required Language selected,
    required Function(Language) onSelect,
    required String title,
  }) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => LanguagePickerSheet(
        selected: selected,
        onSelect: onSelect,
        title: title,
      ),
    );
  }

  @override
  State<LanguagePickerSheet> createState() => _LanguagePickerSheetState();
}

class _LanguagePickerSheetState extends State<LanguagePickerSheet> {
  String _search = '';
  late List<Language> _filtered;

  @override
  void initState() {
    super.initState();
    _filtered = Language.languages;
  }

  void _onSearch(String q) {
    setState(() {
      _search = q;
      _filtered = Language.languages
          .where((l) => l.name.toLowerCase().contains(q.toLowerCase()))
          .toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return DraggableScrollableSheet(
      initialChildSize: 0.75,
      maxChildSize: 0.95,
      minChildSize: 0.5,
      builder: (_, controller) => Container(
        decoration: BoxDecoration(
          color: theme.colorScheme.surface,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
        ),
        child: Column(
          children: [
            const SizedBox(height: 8),
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: theme.colorScheme.onSurface.withOpacity(0.2),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.title,
                    style: GoogleFonts.sora(
                      fontSize: 20,
                      fontWeight: FontWeight.w700,
                      color: theme.colorScheme.onSurface,
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    onChanged: _onSearch,
                    decoration: InputDecoration(
                      hintText: 'Search language…',
                      prefixIcon: const Icon(Icons.search_rounded),
                      filled: true,
                      fillColor:
                          theme.colorScheme.surfaceVariant.withOpacity(0.5),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(14),
                        borderSide: BorderSide.none,
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 12),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 8),
            Expanded(
              child: ListView.builder(
                controller: controller,
                itemCount: _filtered.length,
                padding: const EdgeInsets.symmetric(horizontal: 12),
                itemBuilder: (_, i) {
                  final lang = _filtered[i];
                  final isSelected = lang.code == widget.selected.code;
                  return ListTile(
                    onTap: () {
                      widget.onSelect(lang);
                      Navigator.pop(context);
                    },
                    leading: Text(
                      lang.flag,
                      style: const TextStyle(fontSize: 26),
                    ),
                    title: Text(
                      lang.name,
                      style: GoogleFonts.sora(
                        fontWeight: isSelected
                            ? FontWeight.w700
                            : FontWeight.w400,
                        color: isSelected
                            ? theme.colorScheme.primary
                            : theme.colorScheme.onSurface,
                      ),
                    ),
                    trailing: isSelected
                        ? Icon(Icons.check_circle_rounded,
                            color: theme.colorScheme.primary)
                        : null,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                    selected: isSelected,
                    selectedTileColor:
                        theme.colorScheme.primary.withOpacity(0.08),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
