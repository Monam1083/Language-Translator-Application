import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../models/translation_history.dart';
import '../models/language.dart';
import '../services/history_service.dart';

class HistoryScreen extends StatefulWidget {
  const HistoryScreen({super.key});

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen>
    with SingleTickerProviderStateMixin {
  final HistoryService _historyService = HistoryService();
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _tabController.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final all = _historyService.history;
    final favs = _historyService.favorites;

    return Scaffold(
      backgroundColor: theme.colorScheme.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text(
          'History',
          style: GoogleFonts.sora(fontWeight: FontWeight.w700),
        ),
        actions: [
          if (all.isNotEmpty)
            TextButton.icon(
              onPressed: _confirmClear,
              icon: const Icon(Icons.delete_sweep_rounded, size: 18),
              label: Text(
                'Clear',
                style: GoogleFonts.sora(fontSize: 13),
              ),
              style: TextButton.styleFrom(
                foregroundColor: theme.colorScheme.error,
              ),
            ),
        ],
        bottom: TabBar(
          controller: _tabController,
          labelStyle: GoogleFonts.sora(fontWeight: FontWeight.w600),
          unselectedLabelStyle: GoogleFonts.sora(fontWeight: FontWeight.w400),
          indicatorSize: TabBarIndicatorSize.label,
          tabs: [
            Tab(text: 'All (${all.length})'),
            Tab(text: '★ Saved (${favs.length})'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildList(all),
          _buildList(favs),
        ],
      ),
    );
  }

  Widget _buildList(List<TranslationHistory> items) {
    if (items.isEmpty) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.history_rounded,
              size: 64,
              color: Theme.of(context).colorScheme.onSurface.withOpacity(0.2),
            ),
            const SizedBox(height: 16),
            Text(
              'Nothing here yet',
              style: GoogleFonts.sora(
                color:
                    Theme.of(context).colorScheme.onSurface.withOpacity(0.4),
                fontSize: 16,
              ),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: items.length,
      itemBuilder: (context, i) {
        return _HistoryCard(
          item: items[i],
          onFavorite: () async {
            await _historyService.toggleFavorite(items[i].id);
            setState(() {});
          },
          onDelete: () async {
            await _historyService.delete(items[i].id);
            setState(() {});
          },
          onTap: () {
            Navigator.pop(context, items[i]);
          },
        )
            .animate(delay: (i * 40).ms)
            .fadeIn(duration: 300.ms)
            .slideX(begin: 0.05, end: 0);
      },
    );
  }

  Future<void> _confirmClear() async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: Text('Clear history?', style: GoogleFonts.sora()),
        content: Text('This cannot be undone.', style: GoogleFonts.sora()),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Cancel')),
          TextButton(
              onPressed: () => Navigator.pop(context, true),
              style: TextButton.styleFrom(
                  foregroundColor: Theme.of(context).colorScheme.error),
              child: const Text('Clear all')),
        ],
      ),
    );
    if (ok == true) {
      await _historyService.clearAll();
      setState(() {});
    }
  }
}

class _HistoryCard extends StatelessWidget {
  final TranslationHistory item;
  final VoidCallback onFavorite;
  final VoidCallback onDelete;
  final VoidCallback onTap;

  const _HistoryCard({
    required this.item,
    required this.onFavorite,
    required this.onDelete,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final src = Language.fromCode(item.sourceLang);
    final tgt = Language.fromCode(item.targetLang);

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      child: Material(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(src.flag, style: const TextStyle(fontSize: 16)),
                    const SizedBox(width: 6),
                    Text(
                      src.name,
                      style: GoogleFonts.sora(
                          fontSize: 12,
                          color: theme.colorScheme.onSurface.withOpacity(0.5)),
                    ),
                    const SizedBox(width: 8),
                    Icon(Icons.arrow_forward_rounded,
                        size: 14,
                        color: theme.colorScheme.onSurface.withOpacity(0.3)),
                    const SizedBox(width: 8),
                    Text(tgt.flag, style: const TextStyle(fontSize: 16)),
                    Text(
                      tgt.name,
                      style: GoogleFonts.sora(
                          fontSize: 12,
                          color: theme.colorScheme.onSurface.withOpacity(0.5)),
                    ),
                    const Spacer(),
                    Text(
                      _formatTime(item.timestamp),
                      style: GoogleFonts.sora(
                          fontSize: 11,
                          color: theme.colorScheme.onSurface.withOpacity(0.35)),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  item.sourceText,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.sora(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: theme.colorScheme.onSurface,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  item.translatedText,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.sora(
                    fontSize: 14,
                    color: theme.colorScheme.primary,
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    IconButton(
                      onPressed: () {
                        Clipboard.setData(ClipboardData(
                            text:
                                '${item.sourceText}\n→ ${item.translatedText}'));
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                              content: Text('Copied!'),
                              duration: Duration(seconds: 1)),
                        );
                      },
                      icon: const Icon(Icons.copy_rounded, size: 18),
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                      color: theme.colorScheme.onSurface.withOpacity(0.4),
                    ),
                    const SizedBox(width: 16),
                    IconButton(
                      onPressed: onFavorite,
                      icon: Icon(
                        item.isFavorite
                            ? Icons.star_rounded
                            : Icons.star_outline_rounded,
                        size: 20,
                      ),
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                      color: item.isFavorite
                          ? Colors.amber
                          : theme.colorScheme.onSurface.withOpacity(0.4),
                    ),
                    const SizedBox(width: 16),
                    IconButton(
                      onPressed: onDelete,
                      icon: const Icon(Icons.delete_outline_rounded, size: 18),
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                      color: theme.colorScheme.error.withOpacity(0.6),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  String _formatTime(DateTime dt) {
    final now = DateTime.now();
    final diff = now.difference(dt);
    if (diff.inMinutes < 1) return 'Just now';
    if (diff.inHours < 1) return '${diff.inMinutes}m ago';
    if (diff.inDays < 1) return '${diff.inHours}h ago';
    if (diff.inDays == 1) return 'Yesterday';
    return '${dt.day}/${dt.month}/${dt.year}';
  }
}
