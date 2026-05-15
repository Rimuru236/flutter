import 'package:flutter/material.dart';
import '../models/task.dart';


class TaskDetailScreen extends StatefulWidget {
  final Task task;
  final VoidCallback onDelete;
  final VoidCallback onToggleComplete;
  final Function(Task updatedTask) onEdit;

  const TaskDetailScreen({
    super.key,
    required this.task,
    required this.onDelete,
    required this.onToggleComplete,
    required this.onEdit,
  });

  @override
  State<TaskDetailScreen> createState() => _TaskDetailScreenState();
}

class _TaskDetailScreenState extends State<TaskDetailScreen> {
  late Task _task;

  @override
  void initState() {
    super.initState();
    _task = widget.task;
  }

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

  String _formatDate(DateTime date) {
    const months = [
      'January', 'February', 'March', 'April', 'May', 'June',
      'July', 'August', 'September', 'October', 'November', 'December'
    ];
    return '${months[date.month - 1]} ${date.day}, ${date.year}';
  }

  /// Shows a confirmation dialog before deleting the task.
  Future<void> _confirmDelete() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        title: const Text(
          'Delete Task?',
          style: TextStyle(fontWeight: FontWeight.w700),
        ),
        content: Text(
          'Are you sure you want to delete "${_task.title}"? This cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFD62828)),
            onPressed: () => Navigator.of(ctx).pop(true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      widget.onDelete();
      if (mounted) Navigator.of(context).pop();
    }
  }

  
  void _openEditSheet() {
    // Controllers pre-filled with existing values
    final titleCtrl = TextEditingController(text: _task.title);
    final descCtrl = TextEditingController(text: _task.description);
    String selectedCategory = _task.category;
    String selectedPriority = _task.priority;
    DateTime selectedDate = _task.dueDate;

    const categories = ['School', 'Personal', 'Health', 'Work', 'Finance'];
    const priorities = ['Low', 'Medium', 'High'];
    final formKey = GlobalKey<FormState>();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (ctx, setSheetState) {
            return Container(
              padding: EdgeInsets.only(
                bottom: MediaQuery.of(ctx).viewInsets.bottom,
              ),
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
              ),
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
                child: Form(
                  key: formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Sheet drag handle
                      Center(
                        child: Container(
                          width: 40,
                          height: 4,
                          decoration: BoxDecoration(
                            color: Colors.grey.shade300,
                            borderRadius: BorderRadius.circular(2),
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      const Text(
                        'Edit Task',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w800,
                          color: Color(0xFF1B4332),
                        ),
                      ),
                      const SizedBox(height: 16),

                      // Title field
                      TextFormField(
                        controller: titleCtrl,
                        decoration: const InputDecoration(labelText: 'Task Title'),
                        validator: (v) =>
                            (v == null || v.trim().isEmpty) ? 'Title is required' : null,
                      ),
                      const SizedBox(height: 12),

                      // Description field
                      TextFormField(
                        controller: descCtrl,
                        maxLines: 3,
                        decoration: const InputDecoration(labelText: 'Description'),
                        validator: (v) =>
                            (v == null || v.trim().isEmpty) ? 'Description is required' : null,
                      ),
                      const SizedBox(height: 12),

                      // Category dropdown
                      DropdownButtonFormField<String>(
                        value: selectedCategory,
                        decoration: const InputDecoration(labelText: 'Category'),
                        items: categories
                            .map((c) => DropdownMenuItem(value: c, child: Text(c)))
                            .toList(),
                        onChanged: (v) => setSheetState(() => selectedCategory = v!),
                        validator: (v) => v == null ? 'Pick a category' : null,
                      ),
                      const SizedBox(height: 12),

                      // Priority dropdown
                      DropdownButtonFormField<String>(
                        value: selectedPriority,
                        decoration: const InputDecoration(labelText: 'Priority'),
                        items: priorities
                            .map((p) => DropdownMenuItem(value: p, child: Text(p)))
                            .toList(),
                        onChanged: (v) => setSheetState(() => selectedPriority = v!),
                        validator: (v) => v == null ? 'Pick a priority' : null,
                      ),
                      const SizedBox(height: 12),

                      // Date picker button
                      OutlinedButton.icon(
                        onPressed: () async {
                          final picked = await showDatePicker(
                            context: ctx,
                            initialDate: selectedDate,
                            firstDate: DateTime(2024),
                            lastDate: DateTime(2030),
                          );
                          if (picked != null) {
                            setSheetState(() => selectedDate = picked);
                          }
                        },
                        icon: const Icon(Icons.calendar_today_rounded),
                        label: Text(
                          'Due: ${_formatDate(selectedDate)}',
                          style: const TextStyle(fontWeight: FontWeight.w600),
                        ),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: const Color(0xFF2D6A4F),
                          side: const BorderSide(color: Color(0xFF2D6A4F)),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10)),
                          minimumSize: const Size(double.infinity, 48),
                        ),
                      ),
                      const SizedBox(height: 20),

                      // Save button
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: () {
                            if (formKey.currentState!.validate()) {
                              _task.title = titleCtrl.text.trim();
                              _task.description = descCtrl.text.trim();
                              _task.category = selectedCategory;
                              _task.priority = selectedPriority;
                              _task.dueDate = selectedDate;

                              widget.onEdit(_task);
                              setState(() {}); // Refresh detail screen
                              Navigator.of(ctx).pop();
                            }
                          },
                          child: const Text('Save Changes'),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final bool isOverdue = _task.isOverdue;
    final Color priorityColor = _priorityColor(_task.priority);

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAF9),
      appBar: AppBar(
        title: const Text('Task Details'),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit_rounded),
            tooltip: 'Edit Task',
            onPressed: _openEditSheet,
          ),
          IconButton(
            icon: const Icon(Icons.delete_rounded),
            tooltip: 'Delete Task',
            onPressed: _confirmDelete,
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Title + status banner
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(14),
                border: isOverdue
                    ? Border.all(color: const Color(0xFFD62828), width: 1.5)
                    : null,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.06),
                    blurRadius: 8,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(_categoryIcon(_task.category),
                          color: const Color(0xFF2D6A4F), size: 22),
                      const SizedBox(width: 8),
                      Text(
                        _task.category,
                        style: const TextStyle(
                          fontSize: 13,
                          color: Color(0xFF2D6A4F),
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const Spacer(),
                      if (isOverdue)
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 10, vertical: 3),
                          decoration: BoxDecoration(
                            color: const Color(0xFFFFE5E5),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: const Text(
                            'OVERDUE',
                            style: TextStyle(
                              fontSize: 11,
                              color: Color(0xFFD62828),
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Text(
                    _task.title,
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.w800,
                      color: const Color(0xFF1F2937),
                      decoration: _task.isCompleted
                          ? TextDecoration.lineThrough
                          : TextDecoration.none,
                      decorationColor: Colors.grey,
                      decorationThickness: 2,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 14),

            // Description card
            _DetailCard(
              title: 'Description',
              icon: Icons.notes_rounded,
              child: Text(
                _task.description,
                style: const TextStyle(
                  fontSize: 14.5,
                  color: Color(0xFF374151),
                  height: 1.6,
                ),
              ),
            ),
            const SizedBox(height: 12),

            // Metadata row — priority + due date
            Row(
              children: [
                Expanded(
                  child: _DetailCard(
                    title: 'Priority',
                    icon: Icons.flag_rounded,
                    child: Row(
                      children: [
                        Container(
                          width: 10,
                          height: 10,
                          decoration: BoxDecoration(
                            color: priorityColor,
                            shape: BoxShape.circle,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          _task.priority,
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w700,
                            color: priorityColor,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _DetailCard(
                    title: 'Due Date',
                    icon: Icons.calendar_today_rounded,
                    child: Text(
                      _formatDate(_task.dueDate),
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: isOverdue
                            ? const Color(0xFFD62828)
                            : const Color(0xFF1F2937),
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),

            // Status card
            _DetailCard(
              title: 'Status',
              icon: Icons.check_circle_rounded,
              child: Row(
                children: [
                  Icon(
                    _task.isCompleted
                        ? Icons.check_circle_rounded
                        : Icons.radio_button_unchecked_rounded,
                    color: _task.isCompleted
                        ? const Color(0xFF2D6A4F)
                        : Colors.grey,
                    size: 20,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    _task.isCompleted ? 'Completed' : 'Pending',
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                      color: _task.isCompleted
                          ? const Color(0xFF2D6A4F)
                          : Colors.grey.shade600,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 28),

            // Toggle complete button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () {
                  widget.onToggleComplete();
                  setState(() {
                    _task.isCompleted = !_task.isCompleted;
                  });
                },
                icon: Icon(_task.isCompleted
                    ? Icons.undo_rounded
                    : Icons.check_rounded),
                label: Text(
                  _task.isCompleted ? 'Mark as Incomplete' : 'Mark as Complete',
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: _task.isCompleted
                      ? Colors.grey.shade600
                      : const Color(0xFF2D6A4F),
                  minimumSize: const Size(double.infinity, 50),
                ),
              ),
            ),
            const SizedBox(height: 12),

            // Delete button
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: _confirmDelete,
                icon: const Icon(Icons.delete_rounded),
                label: const Text('Delete Task'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: const Color(0xFFD62828),
                  side: const BorderSide(color: Color(0xFFD62828)),
                  minimumSize: const Size(double.infinity, 50),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10)),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}


class _DetailCard extends StatelessWidget {
  final String title;
  final IconData icon;
  final Widget child;

  const _DetailCard({
    required this.title,
    required this.icon,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 14, color: Colors.grey.shade500),
              const SizedBox(width: 6),
              Text(
                title.toUpperCase(),
                style: TextStyle(
                  fontSize: 11,
                  color: Colors.grey.shade500,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0.6,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          child,
        ],
      ),
    );
  }
}
