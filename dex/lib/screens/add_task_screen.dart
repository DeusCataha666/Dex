import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import '../models/task.dart';
import '../providers/task_provider.dart';

class AddTaskScreen extends StatefulWidget {
  final DateTime initialDate;
  final Task? task;

  const AddTaskScreen({
    super.key,
    required this.initialDate,
    this.task,
  });

  @override
  State<AddTaskScreen> createState() => _AddTaskScreenState();
}

class _AddTaskScreenState extends State<AddTaskScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _titleController;
  late TextEditingController _descriptionController;
  late DateTime _selectedDate;
  late String _selectedColor;
  final List<String> _labels = [];
  late TextEditingController _labelController;
  DateTime? _reminderTime;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.task?.title ?? '');
    _descriptionController =
        TextEditingController(text: widget.task?.description ?? '');
    _selectedDate = widget.task?.date ?? widget.initialDate;
    _selectedColor = widget.task?.color ?? Colors.blue.toARGB32().toString();
    _labels.addAll(widget.task?.labels ?? []);
    _labelController = TextEditingController();
    _reminderTime = widget.task?.reminderTime;
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _labelController.dispose();
    super.dispose();
  }

  void _addLabel() {
    if (_labelController.text.isNotEmpty) {
      setState(() {
        _labels.add(_labelController.text);
        _labelController.clear();
      });
    }
  }

  void _removeLabel(String label) {
    setState(() {
      _labels.remove(label);
    });
  }

  void _saveTask() {
    if (_formKey.currentState!.validate()) {
      final task = Task(
        id: widget.task?.id,
        title: _titleController.text,
        description: _descriptionController.text,
        date: _selectedDate,
        color: _selectedColor,
        labels: _labels,
        reminderTime: _reminderTime,
      );

      final taskProvider = Provider.of<TaskProvider>(context, listen: false);
      if (widget.task == null) {
        taskProvider.addTask(task);
      } else {
        taskProvider.updateTask(task);
      }

      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.task == null ? 'Add Task' : 'Edit Task'),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            TextFormField(
              controller: _titleController,
              decoration: const InputDecoration(
                labelText: 'Title',
                border: OutlineInputBorder(),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter a title';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _descriptionController,
              decoration: const InputDecoration(
                labelText: 'Description',
                border: OutlineInputBorder(),
              ),
              maxLines: 3,
            ),
            const SizedBox(height: 16),
            ListTile(
              title: const Text('Date'),
              subtitle: Text(
                '${_selectedDate.day}/${_selectedDate.month}/${_selectedDate.year}',
              ),
              trailing: const Icon(Icons.calendar_today),
              onTap: () async {
                final DateTime? picked = await showDatePicker(
                  context: context,
                  initialDate: _selectedDate,
                  firstDate: DateTime(2000),
                  lastDate: DateTime(2100),
                );
                if (picked != null) {
                  setState(() {
                    _selectedDate = picked;
                  });
                }
              },
            ),
            const SizedBox(height: 16),
            ListTile(
              title: const Text('Color'),
              trailing: Container(
                width: 24,
                height: 24,
                decoration: BoxDecoration(
                  color: Color(int.parse(_selectedColor)),
                  shape: BoxShape.circle,
                ),
              ),
              onTap: () {
                showDialog(
                  context: context,
                  builder: (context) => AlertDialog(
                    title: const Text('Pick a color'),
                    content: SingleChildScrollView(
                      child: ColorPicker(
                        pickerColor: Color(int.parse(_selectedColor)),
                        onColorChanged: (color) {
                          setState(() {
                            _selectedColor = color.toARGB32().toString();
                          });
                        },
                      ),
                    ),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(context),
                        child: const Text('Done'),
                      ),
                    ],
                  ),
                );
              },
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    controller: _labelController,
                    decoration: const InputDecoration(
                      labelText: 'Add Label',
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.add),
                  onPressed: _addLabel,
                ),
              ],
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              children: _labels
                  .map(
                    (label) => Chip(
                      label: Text(label),
                      onDeleted: () => _removeLabel(label),
                    ),
                  )
                  .toList(),
            ),
            const SizedBox(height: 16),
            ListTile(
              title: const Text('Reminder'),
              subtitle: Text(
                _reminderTime == null
                    ? 'No reminder set'
                    : '${_reminderTime!.hour}:${_reminderTime!.minute}',
              ),
              trailing: const Icon(Icons.access_time),
              onTap: () async {
                final TimeOfDay? picked = await showTimePicker(
                  context: context,
                  initialTime: TimeOfDay.now(),
                );
                if (picked != null) {
                  setState(() {
                    _reminderTime = DateTime(
                      _selectedDate.year,
                      _selectedDate.month,
                      _selectedDate.day,
                      picked.hour,
                      picked.minute,
                    );
                  });
                }
              },
            ),
            const SizedBox(height: 32),
            ElevatedButton(
              onPressed: _saveTask,
              child: const Text('Save Task'),
            ),
          ],
        ),
      ),
    );
  }
} 