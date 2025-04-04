// lib/features/home/presentation/pages/edit_category_page.dart

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../data/models/category_model.dart';
import '../controllers/category_controller.dart';

class EditCategoryPage extends StatefulWidget {
  static const routeName = '/edit-category';

  const EditCategoryPage({super.key});

  @override
  State<EditCategoryPage> createState() => _EditCategoryPageState();
}

class _EditCategoryPageState extends State<EditCategoryPage> {
  final TextEditingController _categoryNameController = TextEditingController();
  Color _selectedColor = Colors.blue.shade200;

  // Get the controller directly without initialization
  final CategoryController _categoryController = Get.find<CategoryController>();

  @override
  void dispose() {
    _categoryNameController.dispose();
    super.dispose();
  }

  void _showAddCategoryModal(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.grey,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return Padding(
              padding: EdgeInsets.only(
                bottom: MediaQuery.of(context).viewInsets.bottom,
                left: 16,
                right: 16,
                top: 16,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Add Category',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: _categoryNameController,
                    style: const TextStyle(color: Colors.black),
                    decoration: InputDecoration(
                      hintText: 'Category Name',
                      hintStyle: TextStyle(color: Colors.grey.shade900),
                      prefixIcon: Icon(
                        Icons.circle,
                        color: _selectedColor,
                        size: 20,
                      ),
                      filled: true,
                      fillColor: const Color.fromARGB(179, 193, 192, 192),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: BorderSide.none,
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'Color',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 8),
                  SizedBox(
                    height: 50,
                    child: ListView(
                      scrollDirection: Axis.horizontal,
                      children: [
                        _colorOption(Colors.blue.shade200, setState),
                        _colorOption(Colors.pink.shade200, setState),
                        _colorOption(Colors.green.shade200, setState),
                        _colorOption(Colors.orange.shade200, setState),
                        _colorOption(Colors.purple.shade200, setState),
                        _colorOption(Colors.red.shade200, setState),
                        _colorOption(Colors.teal.shade200, setState),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      TextButton(
                        onPressed: () => Navigator.pop(context),
                        child: const Text(
                          'Cancel',
                          style: TextStyle(color: Colors.grey),
                        ),
                      ),
                      const SizedBox(width: 16),
                      ElevatedButton(
                        onPressed: () {
                          if (_categoryNameController.text.trim().isNotEmpty) {
                            // Call the controller method directly
                            _categoryController.createCategory(
                              _categoryNameController.text.trim(),
                              _selectedColor,
                            );

                            _categoryNameController.clear();
                            Navigator.pop(context);
                          }
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blue,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        child: const Text('Add'),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Widget _colorOption(Color color, StateSetter setState) {
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedColor = color;
        });
      },
      child: Container(
        margin: const EdgeInsets.only(right: 12),
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: color,
          shape: BoxShape.circle,
          border: Border.all(
            color: _selectedColor == color ? Colors.white : Colors.transparent,
            width: 2,
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: const Text(
          'Edit Category',
          style: TextStyle(
            color: Colors.black,
            fontSize: 28,
            fontWeight: FontWeight.bold,
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.black),
          onPressed: () => Navigator.of(context).pop(),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.add_circle, color: Colors.blue, size: 30),
            onPressed: () {
              _showAddCategoryModal(context);
            },
          ),
        ],
      ),
      body: Obx(() {
        if (_categoryController.isLoading.value) {
          return const Center(
            child: CircularProgressIndicator(),
          );
        } else if (_categoryController.error.value.isNotEmpty) {
          return Center(
            child: Text(
              'Error: ${_categoryController.error.value}',
              style: const TextStyle(color: Colors.red),
            ),
          );
        } else if (_categoryController.categories.isNotEmpty) {
          return Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                Container(
                  decoration: BoxDecoration(
                    color: Colors.grey,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: _categoryController.categories.length,
                    itemBuilder: (context, index) {
                      final category = _categoryController.categories[index];
                      return Dismissible(
                        key: Key(category.id),
                        background: Container(
                          color: Colors.red,
                          alignment: Alignment.centerRight,
                          padding: const EdgeInsets.only(right: 20),
                          child: const Icon(
                            Icons.delete,
                            color: Colors.white,
                          ),
                        ),
                        direction: DismissDirection.endToStart,
                        onDismissed: (direction) {
                          // Delete category using the controller
                          _categoryController.deleteCategory(category.id);
                        },
                        child: ListTile(
                          leading: CircleAvatar(
                            backgroundColor: category.colorValue,
                            radius: 12,
                          ),
                          title: Text(
                            category.title,
                            style: const TextStyle(
                              color: Colors.black,
                              fontSize: 18,
                            ),
                          ),
                          trailing: const Icon(
                            Icons.drag_handle,
                            color: Colors.black,
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          );
        } else {
          return const Center(
            child: Text('No categories available'),
          );
        }
      }),
      bottomNavigationBar: Container(
        height: 20,
        color: Colors.black,
        alignment: Alignment.center,
        child: Container(
          width: 120,
          height: 5,
          decoration: BoxDecoration(
            color: Colors.grey,
            borderRadius: BorderRadius.circular(10),
          ),
        ),
      ),
    );
  }
}
