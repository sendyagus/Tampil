import 'package:flutter/material.dart';

import '../widgets/lesson/lesson_app_bar.dart';
import '../widgets/lesson/lesson_button.dart';
import '../widgets/lesson/lesson_steps.dart';

/// A single, self-contained lesson flow that walks the learner through the
/// material steps shown in the roadmap design:
///   1. Concept / material   2. Video   3. Quiz   4. Summary ("Intinya")
///   5. Completion ("Lesson selesai!")
///
/// The [LessonScreen] owns the step state and renders the matching body from
/// [lesson_steps.dart] while keeping a consistent top bar and primary action.
class LessonScreen extends StatefulWidget {
  /// Lesson number shown in the top bar title (e.g. "Lesson - 6").
  final int lessonNumber;

  /// Small tag under the title, e.g. "Response".
  final String lessonTag;

  const LessonScreen({
    super.key,
    this.lessonNumber = 6,
    this.lessonTag = 'Response',
  });

  @override
  State<LessonScreen> createState() => _LessonScreenState();
}

class _LessonScreenState extends State<LessonScreen> {
  static const int _totalSteps = 5;

  int _step = 0;

  // Quiz state (step 3).
  int? _selectedOption;
  bool _isChecked = false;

  // Correct answer index for the demo quiz.
  static const int _correctOption = 1;

  bool get _isLastStep => _step == _totalSteps - 1;

  void _next() {
    if (_step < _totalSteps - 1) {
      setState(() => _step++);
    }
  }

  void _restart() {
    setState(() {
      _step = 0;
      _selectedOption = null;
      _isChecked = false;
    });
  }

  void _handleCheck() {
    if (_selectedOption == null) return;
    if (!_isChecked) {
      setState(() => _isChecked = true);
    } else {
      _next();
    }
  }

  void _close() {
    if (Navigator.canPop(context)) Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            LessonAppBar(
              lessonNumber: widget.lessonNumber,
              lessonTag: widget.lessonTag,
              step: _step + 1,
              totalSteps: _totalSteps,
              onClose: _close,
            ),
            Expanded(child: _buildStepBody()),
            _buildBottomAction(),
          ],
        ),
      ),
    );
  }

  Widget _buildStepBody() {
    switch (_step) {
      case 0:
        return const LessonConceptStep();
      case 1:
        return const LessonVideoStep();
      case 2:
        return LessonQuizStep(
          selectedOption: _selectedOption,
          isChecked: _isChecked,
          correctOption: _correctOption,
          onSelect: (i) => setState(() {
            _selectedOption = i;
            _isChecked = false;
          }),
        );
      case 3:
        return const LessonSummaryStep();
      default:
        return LessonCompleteStep(
          lessonNumber: widget.lessonNumber,
          onRestart: _restart,
          onBackToRoadmap: _close,
        );
    }
  }

  Widget _buildBottomAction() {
    // The completion step carries its own buttons in the body.
    if (_isLastStep) return const SizedBox.shrink();

    late final String label;
    late final VoidCallback onTap;
    late final bool enabled;

    switch (_step) {
      case 0:
      case 1:
        label = 'Mengerti';
        onTap = _next;
        enabled = true;
        break;
      case 2:
        label = _isChecked ? 'Lanjut' : 'Periksa';
        onTap = _handleCheck;
        enabled = _isChecked ? true : _selectedOption != null;
        break;
      case 3:
        label = 'Selesai';
        onTap = _next;
        enabled = true;
        break;
      default:
        label = 'Lanjut';
        onTap = _next;
        enabled = true;
    }

    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 20),
      child: LessonButton(
        label: label,
        onPressed: enabled ? onTap : null,
      ),
    );
  }
}
