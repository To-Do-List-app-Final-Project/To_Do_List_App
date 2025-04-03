import 'package:flutter/material.dart';
import 'package:to_do_list_app/features/todo/data/models/category_model.dart';
import 'category_option_widget.dart';
import 'task_input_modal.dart';

final List<Category> mockCategories = [
  Category(id: '1', title: 'Work', color: '#FF5722'),
  Category(id: '2', title: 'Personal', color: '#4CAF50'),
  Category(id: '3', title: 'Shopping', color: '#3F51B5'),
  Category(id: '4', title: 'Fitness', color: '#E91E63'),
];

void showAddTaskModal(BuildContext context) {
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.white,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
    ),
    builder: (BuildContext context) {
      return buildCategoryOptions(context, mockCategories);
    },
  );
}

Widget buildCategoryOptions(BuildContext context, List<Category> categories) {
  return Padding(
    padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
    child: Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Select Category',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            TextButton(
              onPressed: () {
                // Placeholder for category editor page
              },
              child: Text(
                'Add / Edit',
                style: TextStyle(color: Colors.blue, fontSize: 16),
              ),
            ),
          ],
        ),
        const SizedBox(height: 24),
        Wrap(
          spacing: 12,
          runSpacing: 12,
          children: categories.map((category) {
            return CategoryOptionWidget(
              color: Color(int.parse("0xFF${category.color.substring(1)}")),
              label: category.title,
              onTap: () {
                Navigator.pop(context);
                showTaskInputModal(context, category.title, "1");
              },
            );
          }).toList(),
        ),
      ],
    ),
  );
}
