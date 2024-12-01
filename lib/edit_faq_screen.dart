import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class EditFAQScreen extends StatefulWidget {
  final String? question;
  final String? answer;
  final Function(String, String) onUpdate;

  const EditFAQScreen({
    Key? key,
    this.question,
    this.answer,
    required this.onUpdate,
  }) : super(key: key);

  @override
  _EditFAQScreenState createState() => _EditFAQScreenState();
}

class _EditFAQScreenState extends State<EditFAQScreen> {
  late TextEditingController _questionController;
  late TextEditingController _answerController;

  @override
  void initState() {
    super.initState();
    _questionController = TextEditingController(text: widget.question);
    _answerController = TextEditingController(text: widget.answer);
  }

  @override
  void dispose() {
    _questionController.dispose();
    _answerController.dispose();
    super.dispose();
  }

  void _saveChanges() {
    widget.onUpdate(_questionController.text, _answerController.text);
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit FAQ'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _questionController,
              decoration: const InputDecoration(labelText: 'Question'),
            ),
            TextField(
              controller: _answerController,
              decoration: const InputDecoration(labelText: 'Answer'),
              maxLines: 5,
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _saveChanges,
              child: const Text('Save Changes'),
            ),
          ],
        ),
      ),
    );
  }
}