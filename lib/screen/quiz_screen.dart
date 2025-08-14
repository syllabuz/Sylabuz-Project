import 'package:flutter/material.dart';
import '../services/syllabus_service.dart';

class QuizScreen extends StatefulWidget {
  final Map<String, dynamic> week;
  final Map<String, dynamic> quizData;

  const QuizScreen({Key? key, required this.week, required this.quizData})
    : super(key: key);

  @override
  _QuizScreenState createState() => _QuizScreenState();
}

class _QuizScreenState extends State<QuizScreen> {
  List<int?> _answers = [];
  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    final questions = widget.quizData['questions'] ?? [];
    _answers = List.filled(questions.length, null);
  }

  @override
  Widget build(BuildContext context) {
    final questions = widget.quizData['questions'] ?? [];

    return Scaffold(
      appBar: AppBar(
        title: Text('Quiz: ${widget.week['title']}'),
        backgroundColor: Color(0xFF2196F3),
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          children: [
            Expanded(
              child: ListView.builder(
                itemCount: questions.length,
                itemBuilder: (context, index) {
                  final question = questions[index];
                  return _buildQuestionCard(question, index);
                },
              ),
            ),
            Container(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: _canSubmit() ? _submitQuiz : null,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Color(0xFF2196F3),
                ),
                child:
                    _isSubmitting
                        ? CircularProgressIndicator(color: Colors.white)
                        : Text(
                          'Submit Quiz',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuestionCard(Map<String, dynamic> question, int questionIndex) {
    return Card(
      margin: EdgeInsets.only(bottom: 16),
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Question ${questionIndex + 1}',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: Color(0xFF2196F3),
              ),
            ),
            SizedBox(height: 8),
            Text(
              question['question'] ?? '',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
                color: Colors.black87,
              ),
            ),
            SizedBox(height: 16),
            ...List.generate(
              (question['options'] as List).length,
              (optionIndex) => _buildOptionTile(
                questionIndex,
                optionIndex,
                question['options'][optionIndex],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOptionTile(int questionIndex, int optionIndex, String option) {
    return RadioListTile<int>(
      title: Text(option),
      value: optionIndex,
      groupValue: _answers[questionIndex],
      onChanged: (value) {
        setState(() {
          _answers[questionIndex] = value;
        });
      },
      activeColor: Color(0xFF2196F3),
    );
  }

  bool _canSubmit() {
    return !_isSubmitting && _answers.every((answer) => answer != null);
  }

  void _submitQuiz() async {
    setState(() {
      _isSubmitting = true;
    });

    try {
      final response = await SyllabusService.submitQuiz(
        widget.week['id'],
        _answers.cast<int>(),
      );

      if (response['success'] == true) {
        final score = response['data']['score'];

        showDialog(
          context: context,
          barrierDismissible: false,
          builder:
              (context) => AlertDialog(
                title: Text('Quiz Completed! 🎉'),
                content: Text('Your score: ${score?.toInt()}%'),
                actions: [
                  ElevatedButton(
                    onPressed: () {
                      Navigator.of(context).pop(); // Close dialog
                      Navigator.of(context).pop(); // Go back to syllabus extend
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Color(0xFF2196F3),
                    ),
                    child: Text(
                      'Continue',
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                ],
              ),
        );
      } else {
        throw Exception(response['message'] ?? 'Failed to submit quiz');
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error: ${e.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      setState(() {
        _isSubmitting = false;
      });
    }
  }
}
