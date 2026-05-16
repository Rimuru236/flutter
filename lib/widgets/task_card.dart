import 'package:flutter/material.dart';
import '../models/task.dart';

/// A styled card widget that represents a single task in the list.
/// Shows the title (with strikethrough if completed), category icon,
/// priority badge, due date, and completion status.
class TaskCard extends StatelessWidget {
  final Task task;
  final VoidCallback onTap;
  final VoidCallback onToggleComplete;

  const TaskCard({
    super.key,
    required this.task,
    required this.onTap,
    required this.onToggleComplete,
  });

  /// Maps a priority string to a display colour.
  Color _priorityColor(String priority) {
    switch (priority) {
      case 'High':
        return const Color(0xFFD62828);
      case 'Medium':
        return const Color(0xFFE07B39);
      case 'Low':
        return const Color(0xFF2D9E6A);
      default:
        return Colors.grey;
    }
  }

  /// Maps a category string to a representative icon.
  IconData _categoryIcon(String category) {
    switch (category) {
      case 'School':
        return Icons.menu_book_rounded;
      case 'Personal':
        return Icons.person_rounded;
      case 'Health':
        return Icons.favorite_rounded;
      case 'Work':
        return Icons.work_rounded;
      case 'Finance':
        return Icons.attach_money_rounded;
      default:
        return Icons.label_rounded;
    }
  }

  @override
  Widget build(BuildContext context) {
    final bool isOverdue = task.isOverdue;
    final Color priorityColor = _priorityColor(task.priority);

    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: isOverdue
              ? Border.all(color: const Color(0xFFD62828), width: 1.5)
              : Border.all(color: Colors.transparent),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.07),
              blurRadius: 8,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Row(
          children: [
            // Left colour accent strip (based on priority)
            Container(
              width: 6,
              height: 80,
              decoration: BoxDecoration(
                color: task.isCompleted ? Colors.grey.shade300 : priorityColor,
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(14),
                  bottomLeft: Radius.circular(14),
                ),
              ),
            ),

            // Category icon
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              child: Icon(
                _categoryIcon(task.category),
                color: task.isCompleted ? Colors.grey : const Color(0xFF2D6A4F),
                size: 26,
              ),
            ),

            // Title, category, due date
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Title — strikethrough when completed
                    Text(
                      task.title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        color: task.isCompleted
                            ? Colors.grey
                            : const Color(0xFF1F2937),
                        decoration: task.isCompleted
                            ? TextDecoration.lineThrough
                            : TextDecoration.none,
                        decorationColor: Colors.grey,
                        decorationThickness: 2,
                      ),
                    ),
                    const SizedBox(height: 4),

                    // Category chip + priority badge
                    Row(
                      children: [
                        _SmallChip(
                          label: task.category,
                          color: const Color(0xFFD8F3DC),
                          textColor: const Color(0xFF1B4332),
                        ),
                        const SizedBox(width: 6),
                        _SmallChip(
                          label: task.priority,
                          color: priorityColor.withOpacity(0.12),
                          textColor: priorityColor,
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),

                    // Due date row — highlighted red if overdue
                    Row(
                      children: [
                        Icon(
                          Icons.calendar_today_rounded,
                          size: 12,
                          color: isOverdue
                              ? const Color(0xFFD62828)
                              : Colors.grey.shade500,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          _formatDate(task.dueDate),
                          style: TextStyle(
                            fontSize: 12,
                            color: isOverdue
                                ? const Color(0xFFD62828)
                                : Colors.grey.shade500,
                            fontWeight: isOverdue
                                ? FontWeight.w700
                                : FontWeight.normal,
                          ),
                        ),
                        if (isOverdue) ...[
                          const SizedBox(width: 4),
                          const Text(
                            'OVERDUE',
                            style: TextStyle(
                              fontSize: 10,
                              color: Color(0xFFD62828),
                              fontWeight: FontWeight.w800,
                              letterSpacing: 0.5,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ],
                ),
              ),
            ),

            // Completion toggle checkbox
            Padding(
              padding: const EdgeInsets.only(right: 12),
              child: GestureDetector(
                onTap: onToggleComplete,
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  width: 26,
                  height: 26,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: task.isCompleted
                        ? const Color(0xFF2D6A4F)
                        : Colors.transparent,
                    border: Border.all(
                      color: task.isCompleted
                          ? const Color(0xFF2D6A4F)
                          : Colors.grey.shade400,
                      width: 2,
                    ),
                  ),
                  child: task.isCompleted
                      ? const Icon(Icons.check_rounded,
                          color: Colors.white, size: 16)
                      : null,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Formats a DateTime to a human-readable string, e.g. "May 15, 2026".
  String _formatDate(DateTime date) {
    const months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
    ];
    return '${months[date.month - 1]} ${date.day}, ${date.year}';
  }
}

/// A small rounded label chip used for category and priority tags.
class _SmallChip extends StatelessWidget {
  final String label;
  final Color color;
  final Color textColor;

  const _SmallChip({
    required this.label,
    required this.color,
    required this.textColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w700,
          color: textColor,
        ),
      ),
    );
  }
}
