import 'package:flutter/material.dart';
import '../models/task.dart';
import '../widgets/task_card.dart';
import 'task_detail_screen.dart';

/// The main task list screen.
/// Handles: displaying, adding, deleting, filtering, sorting, and searching tasks.
class TaskListScreen extends StatefulWidget {
  const TaskListScreen({super.key});

  @override
  State<TaskListScreen> createState() => _TaskListScreenState();
}

class _TaskListScreenState extends State<TaskListScreen> {
  // ── State ────────────────────────────────────────────────────────────────
  final List<Task> _allTasks = [
    // Pre-loaded sample tasks so the app doesn't start empty
    Task(
      title: 'Submit Flutter Assignment',
      description: 'Complete and submit the major Flutter exercise to the lecturer.',
      category: 'School',
      priority: 'High',
      dueDate: DateTime.now().add(const Duration(days: 5)),
    ),
    Task(
      title: 'Morning Jog – 5km',
      description: 'Run 5 km around the campus before 7 AM.',
      category: 'Health',
      priority: 'Medium',
      dueDate: DateTime.now().add(const Duration(days: 1)),
    ),
    Task(
      title: 'Read Flutter Docs',
      description: 'Study the official Flutter documentation on state management.',
      category: 'Personal',
      priority: 'Low',
      dueDate: DateTime.now().subtract(const Duration(days: 2)),
    ),
  ];

  String _filterMode = 'All';        // 'All' | 'Pending' | 'Completed'
  String _sortMode = 'None';         // 'None' | 'Date' | 'Priority'
  String _searchQuery = '';
  bool _isSearching = false;

  final TextEditingController _searchController = TextEditingController();

  // ── Computed list ─────────────────────────────────────────────────────────
  List<Task> get _filteredTasks {
    List<Task> tasks = List.from(_allTasks);

    // 1. Filter by completion status
    if (_filterMode == 'Pending') {
      tasks = tasks.where((t) => !t.isCompleted).toList();
    } else if (_filterMode == 'Completed') {
      tasks = tasks.where((t) => t.isCompleted).toList();
    }

    // 2. Filter by search query
    if (_searchQuery.isNotEmpty) {
      tasks = tasks
          .where((t) =>
              t.title.toLowerCase().contains(_searchQuery.toLowerCase()))
          .toList();
    }

    // 3. Sort
    if (_sortMode == 'Date') {
      tasks.sort((a, b) => a.dueDate.compareTo(b.dueDate));
    } else if (_sortMode == 'Priority') {
      const priorityOrder = {'High': 0, 'Medium': 1, 'Low': 2};
      tasks.sort((a, b) =>
          (priorityOrder[a.priority] ?? 3)
              .compareTo(priorityOrder[b.priority] ?? 3));
    }

    return tasks;
  }

  // ── Statistics ────────────────────────────────────────────────────────────
  int get _totalCount => _allTasks.length;
  int get _completedCount => _allTasks.where((t) => t.isCompleted).length;
  int get _pendingCount => _allTasks.where((t) => !t.isCompleted).length;
  double get _completionRate =>
      _totalCount == 0 ? 0 : _completedCount / _totalCount;

  // ── Helpers ───────────────────────────────────────────────────────────────
  String _formatDate(DateTime date) {
    const months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
    ];
    return '${months[date.month - 1]} ${date.day}, ${date.year}';
  }

  // ── Add / Edit task bottom sheet ──────────────────────────────────────────
  void _openAddTaskSheet({Task? existingTask, int? existingIndex}) {
    final titleCtrl =
        TextEditingController(text: existingTask?.title ?? '');
    final descCtrl =
        TextEditingController(text: existingTask?.description ?? '');
    String selectedCategory = existingTask?.category ?? 'School';
    String selectedPriority = existingTask?.priority ?? 'Medium';
    DateTime selectedDate = existingTask?.dueDate ?? DateTime.now();

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
                borderRadius:
                    BorderRadius.vertical(top: Radius.circular(24)),
              ),
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
                child: Form(
                  key: formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Drag handle
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
                      Text(
                        existingTask == null ? 'Add New Task' : 'Edit Task',
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w800,
                          color: Color(0xFF1B4332),
                        ),
                      ),
                      const SizedBox(height: 16),

                      // Title
                      TextFormField(
                        controller: titleCtrl,
                        decoration:
                            const InputDecoration(labelText: 'Task Title'),
                        validator: (v) =>
                            (v == null || v.trim().isEmpty)
                                ? 'Title cannot be empty'
                                : null,
                      ),
                      const SizedBox(height: 12),

                      // Description
                      TextFormField(
                        controller: descCtrl,
                        maxLines: 3,
                        decoration:
                            const InputDecoration(labelText: 'Description'),
                        validator: (v) =>
                            (v == null || v.trim().isEmpty)
                                ? 'Description cannot be empty'
                                : null,
                      ),
                      const SizedBox(height: 12),

                      // Category dropdown
                      DropdownButtonFormField<String>(
                        value: selectedCategory,
                        decoration:
                            const InputDecoration(labelText: 'Category'),
                        items: categories
                            .map((c) =>
                                DropdownMenuItem(value: c, child: Text(c)))
                            .toList(),
                        onChanged: (v) =>
                            setSheetState(() => selectedCategory = v!),
                        validator: (v) =>
                            v == null ? 'Please choose a category' : null,
                      ),
                      const SizedBox(height: 12),

                      // Priority dropdown
                      DropdownButtonFormField<String>(
                        value: selectedPriority,
                        decoration:
                            const InputDecoration(labelText: 'Priority'),
                        items: priorities
                            .map((p) =>
                                DropdownMenuItem(value: p, child: Text(p)))
                            .toList(),
                        onChanged: (v) =>
                            setSheetState(() => selectedPriority = v!),
                        validator: (v) =>
                            v == null ? 'Please choose a priority' : null,
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

                      // Submit button
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: () {
                            if (formKey.currentState!.validate()) {
                              setState(() {
                                if (existingTask == null) {
                                  // Add new task
                                  _allTasks.add(Task(
                                    title: titleCtrl.text.trim(),
                                    description: descCtrl.text.trim(),
                                    category: selectedCategory,
                                    priority: selectedPriority,
                                    dueDate: selectedDate,
                                  ));
                                } else {
                                  // Update existing task in-place
                                  existingTask.title = titleCtrl.text.trim();
                                  existingTask.description =
                                      descCtrl.text.trim();
                                  existingTask.category = selectedCategory;
                                  existingTask.priority = selectedPriority;
                                  existingTask.dueDate = selectedDate;
                                }
                              });
                              Navigator.of(ctx).pop();
                            }
                          },
                          child: Text(existingTask == null
                              ? 'Add Task'
                              : 'Save Changes'),
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

  // ── Sort picker ────────────────────────────────────────────────────────────
  void _showSortOptions() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) {
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Padding(
                padding: EdgeInsets.only(bottom: 12),
                child: Text(
                  'Sort Tasks',
                  style: TextStyle(
                    fontWeight: FontWeight.w800,
                    fontSize: 16,
                    color: Color(0xFF1B4332),
                  ),
                ),
              ),
              ListTile(
                leading: const Icon(Icons.calendar_today_rounded),
                title: const Text('Due Date (Earliest First)'),
                trailing: _sortMode == 'Date'
                    ? const Icon(Icons.check, color: Color(0xFF2D6A4F))
                    : null,
                onTap: () {
                  setState(() => _sortMode = 'Date');
                  Navigator.pop(ctx);
                },
              ),
              ListTile(
                leading: const Icon(Icons.flag_rounded),
                title: const Text('Priority (High → Low)'),
                trailing: _sortMode == 'Priority'
                    ? const Icon(Icons.check, color: Color(0xFF2D6A4F))
                    : null,
                onTap: () {
                  setState(() => _sortMode = 'Priority');
                  Navigator.pop(ctx);
                },
              ),
              ListTile(
                leading: const Icon(Icons.clear_all_rounded),
                title: const Text('No Sort'),
                trailing: _sortMode == 'None'
                    ? const Icon(Icons.check, color: Color(0xFF2D6A4F))
                    : null,
                onTap: () {
                  setState(() => _sortMode = 'None');
                  Navigator.pop(ctx);
                },
              ),
            ],
          ),
        );
      },
    );
  }

  // ── Clear all tasks ────────────────────────────────────────────────────────
  Future<void> _confirmClearAll() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        title: const Text(
          'Clear All Tasks?',
          style: TextStyle(fontWeight: FontWeight.w700),
        ),
        content: const Text(
          'This will permanently delete all tasks. Are you sure?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFD62828)),
            onPressed: () => Navigator.of(ctx).pop(true),
            child: const Text('Clear All'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      setState(() => _allTasks.clear());
    }
  }

  // ── Navigate to detail screen ─────────────────────────────────────────────
  void _openDetail(Task task) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => TaskDetailScreen(
          task: task,
          onDelete: () {
            setState(() => _allTasks.remove(task));
          },
          onToggleComplete: () {
            setState(() => task.isCompleted = !task.isCompleted);
          },
          onEdit: (updatedTask) {
            setState(() {}); // list screen refresh
          },
        ),
      ),
    );
  }

  // ── Build ─────────────────────────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    final List<Task> displayedTasks = _filteredTasks;

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAF9),
      appBar: AppBar(
        title: _isSearching
            ? TextField(
                controller: _searchController,
                autofocus: true,
                style: const TextStyle(color: Colors.white),
                cursorColor: Colors.white70,
                decoration: const InputDecoration(
                  hintText: 'Search tasks…',
                  hintStyle: TextStyle(color: Colors.white60),
                  border: InputBorder.none,
                  filled: false,
                ),
                onChanged: (v) => setState(() => _searchQuery = v),
              )
            : const Text('My Tasks'),
        actions: [
          // Search toggle
          IconButton(
            icon: Icon(_isSearching ? Icons.close_rounded : Icons.search_rounded),
            tooltip: _isSearching ? 'Close Search' : 'Search',
            onPressed: () {
              setState(() {
                _isSearching = !_isSearching;
                if (!_isSearching) {
                  _searchQuery = '';
                  _searchController.clear();
                }
              });
            },
          ),
          // Sort
          IconButton(
            icon: const Icon(Icons.sort_rounded),
            tooltip: 'Sort',
            onPressed: _showSortOptions,
          ),
          // Clear all
          IconButton(
            icon: const Icon(Icons.delete_sweep_rounded),
            tooltip: 'Clear All',
            onPressed: _allTasks.isEmpty ? null : _confirmClearAll,
          ),
        ],
      ),

      body: Column(
        children: [
          // ── Statistics bar ───────────────────────────────────────────────
          Container(
            color: const Color(0xFF2D6A4F),
            padding:
                const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _StatBadge(
                        label: 'Total', value: '$_totalCount', color: Colors.white),
                    _StatBadge(
                        label: 'Done',
                        value: '$_completedCount',
                        color: const Color(0xFFB7E4C7)),
                    _StatBadge(
                        label: 'Pending',
                        value: '$_pendingCount',
                        color: const Color(0xFFFFD6A5)),
                    Text(
                      '${(_completionRate * 100).toStringAsFixed(0)}%',
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w800,
                        fontSize: 16,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: LinearProgressIndicator(
                    value: _completionRate,
                    minHeight: 6,
                    backgroundColor: Colors.white24,
                    valueColor: const AlwaysStoppedAnimation<Color>(
                        Color(0xFF52B788)),
                  ),
                ),
              ],
            ),
          ),

          // ── Filter chips ─────────────────────────────────────────────────
          Padding(
            padding:
                const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            child: Row(
              children: ['All', 'Pending', 'Completed'].map((label) {
                final isSelected = _filterMode == label;
                return Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: FilterChip(
                    label: Text(label),
                    selected: isSelected,
                    onSelected: (_) =>
                        setState(() => _filterMode = label),
                    selectedColor: const Color(0xFF2D6A4F),
                    checkmarkColor: Colors.white,
                    labelStyle: TextStyle(
                      color: isSelected ? Colors.white : const Color(0xFF374151),
                      fontWeight: FontWeight.w600,
                    ),
                    backgroundColor: Colors.white,
                    side: BorderSide(
                      color: isSelected
                          ? const Color(0xFF2D6A4F)
                          : Colors.grey.shade300,
                    ),
                  ),
                );
              }).toList(),
            ),
          ),

          // ── Task list ────────────────────────────────────────────────────
          Expanded(
            child: displayedTasks.isEmpty
                ? _EmptyState(
                    isFiltered: _filterMode != 'All' || _searchQuery.isNotEmpty)
                : ListView.builder(
                    padding: const EdgeInsets.only(bottom: 90, top: 4),
                    itemCount: displayedTasks.length,
                    itemBuilder: (ctx, index) {
                      final task = displayedTasks[index];
                      return Dismissible(
                        key: ObjectKey(task),
                        direction: DismissDirection.endToStart,
                        background: Container(
                          alignment: Alignment.centerRight,
                          padding: const EdgeInsets.only(right: 24),
                          margin: const EdgeInsets.symmetric(
                              horizontal: 16, vertical: 6),
                          decoration: BoxDecoration(
                            color: const Color(0xFFD62828),
                            borderRadius: BorderRadius.circular(14),
                          ),
                          child: const Icon(Icons.delete_rounded,
                              color: Colors.white, size: 28),
                        ),
                        onDismissed: (_) {
                          setState(() => _allTasks.remove(task));
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('${task.title} deleted'),
                              backgroundColor: const Color(0xFF2D6A4F),
                              behavior: SnackBarBehavior.floating,
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10)),
                            ),
                          );
                        },
                        child: TaskCard(
                          task: task,
                          onTap: () => _openDetail(task),
                          onToggleComplete: () {
                            setState(
                                () => task.isCompleted = !task.isCompleted);
                          },
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),

      // ── FAB — add new task ───────────────────────────────────────────────
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _openAddTaskSheet,
        icon: const Icon(Icons.add_rounded),
        label: const Text(
          'Add Task',
          style: TextStyle(fontWeight: FontWeight.w700),
        ),
      ),
    );
  }
}

// ── Supporting widgets ──────────────────────────────────────────────────────

/// Small stat badge shown in the statistics bar.
class _StatBadge extends StatelessWidget {
  final String label;
  final String value;
  final Color color;

  const _StatBadge({
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          value,
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.w800,
            color: color,
          ),
        ),
        Text(
          label,
          style: const TextStyle(
            fontSize: 11,
            color: Colors.white60,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}

/// Shown when the task list is empty — varies message based on context.
class _EmptyState extends StatelessWidget {
  final bool isFiltered;

  const _EmptyState({required this.isFiltered});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(40),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              isFiltered
                  ? Icons.search_off_rounded
                  : Icons.task_alt_rounded,
              size: 72,
              color: Colors.grey.shade300,
            ),
            const SizedBox(height: 16),
            Text(
              isFiltered ? 'No tasks match your filter' : 'No tasks yet!',
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: Color(0xFF9CA3AF),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              isFiltered
                  ? 'Try a different filter or clear your search.'
                  : 'Tap the button below to add your first task.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey.shade400,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
