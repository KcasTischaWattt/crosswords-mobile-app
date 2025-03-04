import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'dart:ui' as ui;
import 'package:velocity_x/velocity_x.dart';
import '../providers/article_provider.dart';
import '../data/models/article.dart';
import '../data/models/note.dart';
import 'package:flutter/services.dart';
import 'widgets/fade_background.dart';
import 'widgets/expanding_text_field.dart';

class ArticleDetailPage extends StatefulWidget {
  final Article article;

  const ArticleDetailPage({super.key, required this.article});

  @override
  _ArticleDetailPageState createState() => _ArticleDetailPageState();
}

class _ArticleDetailPageState extends State<ArticleDetailPage> {
  final TextEditingController _commentController = TextEditingController();
  Note? _editingNote;
  bool _isNotesExpanded = true;
  bool _hasTextChanged = false;

  @override
  void initState() {
    super.initState();

    _commentController.addListener(() {
      if (_editingNote == null) return;

      setState(() {
        _hasTextChanged =
            _commentController.text.trim() != _editingNote!.text.trim();
      });
    });
  }

  @override
  void dispose() {
    _commentController.removeListener(() {});
    _commentController.dispose();
    super.dispose();
  }

  /// Переключение избранного
  Future<void> _toggleFavorite() async {
    await Provider.of<ArticleProvider>(context, listen: false)
        .toggleFavorite(widget.article.id);
  }

  /// Форматирование даты и времени
  String _formatDateTime(String dateTime) {
    return DateFormat('dd/MM/yyyy HH:mm').format(DateTime.parse(dateTime));
  }

  /// Виджет пунктов меню
  Widget _buildMenuItem({
    required IconData icon,
    required String text,
    required VoidCallback onTap,
  }) {
    return ListTile(
      leading: Icon(icon, size: 28),
      title: Text(text, style: TextStyle(fontSize: 20)),
      onTap: onTap,
    );
  }

  /// Виджет меню
  Widget _buildMenu(BuildContext context, BuildContext bottomSheetContext, Note note) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
      padding: const EdgeInsets.symmetric(vertical: 8),
      decoration: BoxDecoration(
        color: Theme.of(context).bottomNavigationBarTheme.backgroundColor,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildMenuItem(
            icon: Icons.content_copy,
            text: "Копировать",
            onTap: () => _copyNoteText(context, note),
          ),
          _buildMenuItem(
            icon: Icons.edit,
            text: "Редактировать",
            onTap: () => _editNote(context, note),
          ),
          _buildMenuItem(
            icon: Icons.delete,
            text: "Удалить",
            onTap: () => _confirmDeleteNote(context, bottomSheetContext, note),
          ),
        ],
      ),
    );
  }

  /// Копирование текста заметки
  void _copyNoteText(BuildContext context, Note note) {
    Clipboard.setData(ClipboardData(text: note.text));
    Navigator.pop(context);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Заметка скопирована")),
    );
  }

  /// Подтверждение входа в режим редактирования
  void _confirmEnterEditMode(BuildContext context, Note note) {
    Navigator.pop(context);
    _showConfirmationDialog(
      context: context,
      title: "Начать редактирование?",
      content: "Введенный текст будет утерян.",
      cancelText: "Отмена",
      confirmText: "Редактировать",
      onConfirm: () {
        setState(() {
          _editingNote = note;
          _commentController.text = note.text;
        });
      },
    );
  }

  /// Редактирование заметки
  void _editNote(BuildContext context, Note note) {
    if (_commentController.text.trim().isNotEmpty) {
      _confirmEnterEditMode(context, note);
      return;
    }
    setState(() {
      _editingNote = note;
      _commentController.text = note.text;
    });
    Navigator.pop(context);
  }

  /// Подтверждение удаления заметки
  void _confirmDeleteNote(BuildContext context, BuildContext bottomSheetContext, Note note) {
    Navigator.pop(bottomSheetContext);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      _showConfirmationDialog(
        context: context,
        title: "Удалить заметку?",
        content: "Вы уверены, что хотите удалить эту заметку?",
        cancelText: "Отмена",
        confirmText: "Удалить",
        onConfirm: () {
          Provider.of<ArticleProvider>(context, listen: false)
              .deleteNote(note.id);
        },
      );
    });
  }

  /// Отображение опций заметки
  void _showNoteOptions(BuildContext context, Note note) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (BuildContext bottomSheetContext) {
        return FadeBackground(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              _buildMenu(context, bottomSheetContext, note),
              const SizedBox(height: 10),
            ],
          ),
        );
      },
    );
  }

  /// Показ диалога подтверждения действия
  void _showConfirmationDialog({
    required BuildContext context,
    required String title,
    required String content,
    required String cancelText,
    required String confirmText,
    required VoidCallback onConfirm,
  }) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(title),
          content: Text(content),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(cancelText, style: const TextStyle(fontSize: 18)),
            ),
            TextButton(
              onPressed: () {
                onConfirm();
                Navigator.pop(context);
              },
              child: Text(confirmText,
                  style: const TextStyle(fontSize: 18, color: Colors.red)),
            ),
          ],
        );
      },
    );
  }

  TextPainter _createTextPainter({
    required String text,
    required TextStyle style,
    double? maxWidth,
  }) {
    return TextPainter(
      text: TextSpan(text: text, style: style),
      textDirection: ui.TextDirection.ltr,
      maxLines: null,
    )..layout(maxWidth: maxWidth ?? double.infinity);
  }

  Widget buildNoteContent(Note note) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final noteStyle = TextStyle(
            fontSize: 18, color: Theme.of(context).textTheme.bodyLarge!.color);
        final noteSpan = TextSpan(text: note.text, style: noteStyle);

        final textPainter = TextPainter(
          text: noteSpan,
          textDirection: ui.TextDirection.ltr,
          maxLines: null,
        );
        textPainter.layout(maxWidth: constraints.maxWidth);

        final lines = textPainter.computeLineMetrics();
        final linesCount = lines.length;
        final lastLineWidth = lines.isNotEmpty ? lines.last.width : 0.0;

        final timeText = note.updatedAt != note.createdAt
            ? "изм. ${_formatDateTime(note.updatedAt)}"
            : _formatDateTime(note.createdAt);
        final timeStyle = TextStyle(fontSize: 14, color: Colors.grey[600]);
        final timeSpan = TextSpan(text: timeText, style: timeStyle);

        final timePainter = TextPainter(
          text: timeSpan,
          textDirection: ui.TextDirection.ltr,
        );
        timePainter.layout();
        final timeWidth = timePainter.width;

        if (linesCount == 1 &&
            lastLineWidth + timeWidth + 8 < constraints.maxWidth) {
          return Row(
            children: [
              Expanded(
                child: Text(
                  note.text,
                  style: noteStyle,
                ),
              ),
              Text(
                timeText,
                style: timeStyle,
              ),
            ],
          );
        } else {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(note.text, style: noteStyle),
              const SizedBox(height: 4),
              Align(
                alignment: Alignment.bottomRight,
                child: Text(timeText, style: timeStyle),
              ),
            ],
          );
        }
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<ArticleProvider>(context);
    final bool isFavorite =
        provider.favoriteArticles.contains(widget.article.id);
    return PopScope(
      canPop: _editingNote == null && _commentController.text.isEmpty,
      onPopInvokedWithResult: (didPop, result) async {
        if (didPop) return;
        if (_editingNote != null) {
          _showConfirmationDialog(
            context: context,
            title: "Отменить редактирование?",
            content:
                "Вы действительно хотите выйти? Изменения не будут сохранены.",
            cancelText: "Остаться",
            confirmText: "Выйти",
            onConfirm: () {
              setState(() {
                _editingNote = null;
                _commentController.clear();
              });
              Navigator.pop(context);
            },
          );
        } else if (_commentController.text.isNotEmpty) {
          _showConfirmationDialog(
            context: context,
            title: "Отменить создание заметки?",
            content:
                "Вы действительно хотите выйти? Изменения не будут сохранены.",
            cancelText: "Остаться",
            confirmText: "Выйти",
            onConfirm: () {
              setState(() {
                _editingNote = null;
                _commentController.clear();
              });
              Navigator.pop(context);
            },
          );
        } else {
          Navigator.pop(context, result);
        }
      },
      child: Scaffold(
        appBar: AppBar(
          toolbarHeight: 60,
          centerTitle: true,
          title: Text(
            'Детали статьи',
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          actions: [
            IconButton(
              icon: provider.isLoading
                  ? const SizedBox(
                      width: 24,
                      height: 24,
                      child: CircularProgressIndicator(strokeWidth: 2))
                  : Icon(
                      isFavorite ? Icons.favorite : Icons.favorite_border,
                      color: isFavorite ? Colors.red : Colors.grey,
                      size: 24,
                    ),
              onPressed: provider.isLoading ? null : _toggleFavorite,
            ),
          ],
          backgroundColor: Theme.of(context).scaffoldBackgroundColor,
          surfaceTintColor: Colors.transparent,
          elevation: 0,
          shadowColor: Colors.transparent,
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Дата и источник
              '${widget.article.date} | ${widget.article.source}'
                  .text
                  .xl
                  .color(Theme.of(context).textTheme.bodySmall!.color!)
                  .make(),
              const SizedBox(height: 8),

              // Заголовок статьи
              widget.article.title.text.bold.xl3.make(),
              const SizedBox(height: 16),

              // Тэги
              Wrap(
                spacing: 8,
                children: widget.article.tags.map((tag) {
                  return Chip(
                    label: Text(
                      tag,
                      style: const TextStyle(
                          color: Colors.white, fontWeight: FontWeight.bold),
                    ),
                    backgroundColor: const Color(0xFF517ECF),
                    padding:
                        const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
                  );
                }).toList(),
              ),
              const SizedBox(height: 16),

              // Аккордеон краткого содержания
              Container(
                decoration: BoxDecoration(
                  color: (Theme.of(context)
                          .bottomNavigationBarTheme
                          .backgroundColor ??
                      Colors.grey[900]) as Color,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Theme(
                  data: Theme.of(context).copyWith(
                    dividerColor: Colors.transparent,
                    expansionTileTheme: ExpansionTileThemeData(
                      collapsedIconColor: Theme.of(context).iconTheme.color,
                      iconColor: Theme.of(context).iconTheme.color,
                      backgroundColor: Colors.transparent,
                    ),
                  ),
                  child: ExpansionTile(
                    tilePadding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 12),
                    title: Row(
                      children: [
                        Icon(
                          Icons.book,
                          size: 24,
                          color: Theme.of(context).iconTheme.color,
                        ),
                        const SizedBox(width: 8),
                        const Text(
                          'Краткое содержание',
                          style: TextStyle(
                              fontSize: 20, fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                    children: [
                      Container(
                        decoration: BoxDecoration(
                          color: (Theme.of(context)
                                  .bottomNavigationBarTheme
                                  .backgroundColor ??
                              Colors.white),
                          borderRadius: const BorderRadius.only(
                            bottomLeft: Radius.circular(12),
                            bottomRight: Radius.circular(12),
                          ),
                        ),
                        padding: const EdgeInsets.all(16),
                        child: Text(
                          widget.article.summary,
                          style: TextStyle(
                            fontSize: 18,
                            color: Theme.of(context).textTheme.bodyLarge!.color,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),

              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                decoration: BoxDecoration(
                  color: Theme.of(context).scaffoldBackgroundColor,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  widget.article.text,
                  style: TextStyle(
                    fontSize: 18,
                    color: Theme.of(context).textTheme.bodyLarge!.color,
                  ),
                ),
              ),

              const SizedBox(height: 20),

              // Кнопка для перехода на оригинальную статью
              ElevatedButton(
                onPressed: () {
                  // Переход на оригинальную статью
                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                    content: Text('Переход по ссылке: ${widget.article.url}'),
                  ));
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Theme.of(context).primaryColor,
                  padding:
                      const EdgeInsets.symmetric(vertical: 12, horizontal: 12),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8)),
                ),
                child: const Text('Читать оригинал',
                    style: TextStyle(color: Colors.black, fontSize: 18)),
              ),

              const SizedBox(height: 20),

              // Заголовок заметок
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Заметки',
                    style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                  ),
                  Consumer<ArticleProvider>(
                    builder: (context, provider, child) {
                      final notes = provider
                          .getNotesForArticle(int.parse(widget.article.id));
                      return notes.isNotEmpty
                          ? IconButton(
                              icon: Icon(_isNotesExpanded
                                  ? Icons.expand_less
                                  : Icons.expand_more),
                              onPressed: () {
                                setState(() {
                                  _isNotesExpanded = !_isNotesExpanded;
                                });
                              },
                            )
                          : SizedBox.shrink();
                    },
                  ),
                ],
              ),

              // Список заметок
              Consumer<ArticleProvider>(
                builder: (context, provider, child) {
                  final notes =
                      provider.getNotesForArticle(int.parse(widget.article.id));
                  if (notes.isEmpty) {
                    return const Text("Заметок пока нет.");
                  }

                  return AnimatedSize(
                    duration: const Duration(milliseconds: 500),
                    curve: Curves.easeInOut,
                    child: _isNotesExpanded
                        ? ListView.builder(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            itemCount: notes.length,
                            itemBuilder: (context, index) {
                              final note = notes[index];
                              return GestureDetector(
                                onLongPress: () {
                                  _showNoteOptions(context, note);
                                },
                                child: Container(
                                  margin:
                                      const EdgeInsets.symmetric(vertical: 6),
                                  padding: const EdgeInsets.all(12),
                                  decoration: BoxDecoration(
                                    color: Theme.of(context)
                                        .bottomNavigationBarTheme
                                        .backgroundColor,
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: buildNoteContent(note),
                                ),
                              );
                            },
                          )
                        : GestureDetector(
                            onTap: () {
                              setState(() {
                                _isNotesExpanded = true;
                              });
                            },
                            child: Container(
                              width: double.infinity,
                              margin: const EdgeInsets.symmetric(vertical: 6),
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: Theme.of(context)
                                    .bottomNavigationBarTheme
                                    .backgroundColor,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Text(
                                'Всего заметок: ${notes.length}',
                                style: const TextStyle(
                                    fontSize: 18, fontWeight: FontWeight.bold),
                                textAlign: TextAlign.center,
                              ),
                            ),
                          ),
                  );
                },
              ),

              const SizedBox(height: 10),

              Row(
                children: [
                  if (_editingNote != null)
                    IconButton(
                      icon: const Icon(Icons.close, size: 30),
                      onPressed: () {
                        if (_editingNote == null) return;

                        if (!_hasTextChanged) {
                          setState(() {
                            _editingNote = null;
                            _commentController.clear();
                          });
                          return;
                        }

                        _showConfirmationDialog(
                          context: context,
                          title: "Отменить редактирование?",
                          content: "Изменения не будут сохранены.",
                          cancelText: "Нет",
                          confirmText: "Да",
                          onConfirm: () {
                            setState(() {
                              _editingNote = null;
                              _commentController.clear();
                            });
                          },
                        );
                      },
                    ),
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.only(bottom: 10),
                      child: ExpandingTextField(controller: _commentController),
                    ),
                  ),
                  const SizedBox(width: 10),
                  IconButton(
                    icon: Icon(_editingNote == null ? Icons.send : Icons.check,
                        size: 30),
                    onPressed: () {
                      final provider =
                          Provider.of<ArticleProvider>(context, listen: false);

                      if (_editingNote != null) {
                        if (!_hasTextChanged) {
                          setState(() {
                            _editingNote = null;
                            _commentController.clear();
                          });
                          return;
                        }

                        provider.updateNote(
                            _editingNote!.id, _commentController.text.trim());

                        WidgetsBinding.instance.addPostFrameCallback((_) {
                          if (!mounted) return;
                          setState(() {
                            _editingNote = null;
                            _commentController.clear();
                          });
                        });
                      } else {
                        provider.addNote(int.parse(widget.article.id),
                            _commentController.text);
                        _commentController.clear();
                      }
                    },
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
