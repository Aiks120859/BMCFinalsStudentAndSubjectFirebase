import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';

import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  runApp(const RegistrationApp());
}

class RegistrationApp extends StatelessWidget {
  const RegistrationApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Student Registration',
      theme: ThemeData(
        useMaterial3: true,
        fontFamily: 'Arial',
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF6C3CE9),
        ),
        scaffoldBackgroundColor: const Color(0xFFF7F5FC),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: const Color(0xFFF9F8FD),
          hintStyle: const TextStyle(
            color: Color(0xFF9B98A7),
          ),
          prefixIconColor: const Color(0xFF6C3CE9),
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 18,
            vertical: 17,
          ),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide.none,
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: const BorderSide(
              color: Color(0xFFE7E2F0),
            ),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: const BorderSide(
              color: Color(0xFF6C3CE9),
              width: 2,
            ),
          ),
        ),
      ),
      home: const RegistrationPage(),
    );
  }
}

class RegistrationPage extends StatefulWidget {
  const RegistrationPage({super.key});

  @override
  State<RegistrationPage> createState() => _RegistrationPageState();
}

class _RegistrationPageState extends State<RegistrationPage> {
  int currentStep = 0;

  final nameController = TextEditingController();
  final sectionController = TextEditingController();
  final courseController = TextEditingController();

  final subject1Controller = TextEditingController();
  final subject1TimeController = TextEditingController();

  final subject2Controller = TextEditingController();
  final subject2TimeController = TextEditingController();

  bool isSaving = false;

  @override
  void dispose() {
    nameController.dispose();
    sectionController.dispose();
    courseController.dispose();
    subject1Controller.dispose();
    subject1TimeController.dispose();
    subject2Controller.dispose();
    subject2TimeController.dispose();
    super.dispose();
  }

  void nextStep() {
    if (currentStep == 0) {
      if (nameController.text.trim().isEmpty ||
          sectionController.text.trim().isEmpty ||
          courseController.text.trim().isEmpty) {
        showMessage('Please complete all registration fields.');
        return;
      }
    }

    if (currentStep == 1) {
      if (subject1Controller.text.trim().isEmpty ||
          subject1TimeController.text.trim().isEmpty ||
          subject2Controller.text.trim().isEmpty ||
          subject2TimeController.text.trim().isEmpty) {
        showMessage('Please complete all subject fields.');
        return;
      }
    }

    setState(() {
      currentStep++;
    });
  }

  void previousStep() {
    if (currentStep > 0) {
      setState(() {
        currentStep--;
      });
    }
  }

  Future<void> saveData() async {
    setState(() {
      isSaving = true;
    });

    try {
      await FirebaseFirestore.instance.collection('registrations').add({
        'name': nameController.text.trim(),
        'section': sectionController.text.trim(),
        'course': courseController.text.trim(),
        'subjects': [
          {
            'subject': subject1Controller.text.trim(),
            'time': subject1TimeController.text.trim(),
          },
          {
            'subject': subject2Controller.text.trim(),
            'time': subject2TimeController.text.trim(),
          },
        ],
        'createdAt': FieldValue.serverTimestamp(),
      });

      if (!mounted) return;

      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) {
          return AlertDialog(
            backgroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(25),
            ),
            title: const Row(
              children: [
                Icon(
                  Icons.check_circle_rounded,
                  color: Color(0xFF6C3CE9),
                  size: 32,
                ),
                SizedBox(width: 10),
                Expanded(
                  child: Text(
                    'Registration Saved',
                    style: TextStyle(
                      fontWeight: FontWeight.w800,
                      color: Color(0xFF292334),
                    ),
                  ),
                ),
              ],
            ),
            content: const Text(
              'Your registration has been successfully saved to Firebase Firestore.',
              style: TextStyle(
                color: Color(0xFF777280),
              ),
            ),
            actions: [
              FilledButton(
                onPressed: () {
                  Navigator.pop(context);
                  resetForm();
                },
                style: FilledButton.styleFrom(
                  backgroundColor: const Color(0xFF6C3CE9),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 22,
                    vertical: 12,
                  ),
                ),
                child: const Text('Done'),
              ),
            ],
          );
        },
      );
    } catch (e) {
      showMessage('Failed to save data: $e');
    } finally {
      if (mounted) {
        setState(() {
          isSaving = false;
        });
      }
    }
  }

  void resetForm() {
    nameController.clear();
    sectionController.clear();
    courseController.clear();
    subject1Controller.clear();
    subject1TimeController.clear();
    subject2Controller.clear();
    subject2TimeController.clear();

    setState(() {
      currentStep = 0;
    });
  }

  void showMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        behavior: SnackBarBehavior.floating,
        backgroundColor: const Color(0xFF6C3CE9),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(14),
        ),
        margin: const EdgeInsets.all(15),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7F5FC),
      appBar: AppBar(
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.white,
        elevation: 0,
        toolbarHeight: 76,
        titleSpacing: 20,
        title: Row(
          children: [
            Container(
              width: 46,
              height: 46,
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    Color(0xFF8B5CF6),
                    Color(0xFF5B21B6),
                  ],
                ),
                borderRadius: BorderRadius.circular(15),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF6C3CE9).withOpacity(.20),
                    blurRadius: 15,
                    offset: const Offset(0, 6),
                  ),
                ],
              ),
              child: const Icon(
                Icons.school_rounded,
                color: Colors.white,
                size: 24,
              ),
            ),
            const SizedBox(width: 12),
            const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'STUDENT HUB',
                  style: TextStyle(
                    color: Color(0xFF292334),
                    fontWeight: FontWeight.w900,
                    fontSize: 17,
                    letterSpacing: .8,
                  ),
                ),
                SizedBox(height: 2),
                Text(
                  'Registration Portal',
                  style: TextStyle(
                    color: Color(0xFF918D9D),
                    fontSize: 11,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            buildProgress(),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(18, 12, 18, 30),
                child: AnimatedSwitcher(
                  duration: const Duration(milliseconds: 350),
                  transitionBuilder: (child, animation) {
                    return FadeTransition(
                      opacity: animation,
                      child: SlideTransition(
                        position: Tween<Offset>(
                          begin: const Offset(.03, 0),
                          end: Offset.zero,
                        ).animate(animation),
                        child: child,
                      ),
                    );
                  },
                  child: buildCurrentStep(),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget buildProgress() {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 12, 16, 8),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: const Color(0xFFEAE5F2),
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF4B3A68).withOpacity(.06),
            blurRadius: 20,
            offset: const Offset(0, 7),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              const Text(
                'APPLICATION PROGRESS',
                style: TextStyle(
                  color: Color(0xFF777280),
                  fontSize: 10,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 1,
                ),
              ),
              const Spacer(),
              Text(
                '${currentStep + 1} of 3',
                style: const TextStyle(
                  color: Color(0xFF6C3CE9),
                  fontWeight: FontWeight.w800,
                  fontSize: 11,
                ),
              ),
            ],
          ),
          const SizedBox(height: 15),
          Row(
            children: [
              progressItem(
                number: 1,
                title: 'Registration',
                active: currentStep >= 0,
              ),
              progressLine(currentStep >= 1),
              progressItem(
                number: 2,
                title: 'Subjects',
                active: currentStep >= 1,
              ),
              progressLine(currentStep >= 2),
              progressItem(
                number: 3,
                title: 'Verify',
                active: currentStep >= 2,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget progressItem({
    required int number,
    required String title,
    required bool active,
  }) {
    return Expanded(
      child: Column(
        children: [
          AnimatedContainer(
            duration: const Duration(milliseconds: 250),
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              gradient: active
                  ? const LinearGradient(
                      colors: [
                        Color(0xFF8B5CF6),
                        Color(0xFF5B21B6),
                      ],
                    )
                  : null,
              color: active
                  ? null
                  : const Color(0xFFF0EDF5),
              shape: BoxShape.circle,
              boxShadow: active
                  ? [
                      BoxShadow(
                        color: const Color(0xFF6C3CE9)
                            .withOpacity(.22),
                        blurRadius: 12,
                        offset: const Offset(0, 5),
                      ),
                    ]
                  : null,
            ),
            child: Center(
              child: active
                  ? Icon(
                      number < currentStep + 1
                          ? Icons.check_rounded
                          : Icons.circle,
                      size: number < currentStep + 1 ? 20 : 10,
                      color: Colors.white,
                    )
                  : Text(
                      '$number',
                      style: const TextStyle(
                        color: Color(0xFFAAA5B5),
                        fontWeight: FontWeight.w800,
                      ),
                    ),
            ),
          ),
          const SizedBox(height: 7),
          Text(
            title,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: active
                  ? const Color(0xFF5B21B6)
                  : const Color(0xFFA39EAD),
              fontSize: 10,
              fontWeight:
                  active ? FontWeight.w800 : FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget progressLine(bool active) {
    return Container(
      height: 3,
      width: 24,
      margin: const EdgeInsets.only(bottom: 23),
      decoration: BoxDecoration(
        color: active
            ? const Color(0xFF8B5CF6)
            : const Color(0xFFE7E2EF),
        borderRadius: BorderRadius.circular(10),
      ),
    );
  }

  Widget buildCurrentStep() {
    switch (currentStep) {
      case 0:
        return buildRegistration();

      case 1:
        return buildSubjects();

      case 2:
        return buildVerification();

      default:
        return const SizedBox();
    }
  }

  Widget buildRegistration() {
    return Column(
      key: const ValueKey('registration'),
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        buildHeader(
          icon: Icons.person_add_rounded,
          title: 'Create Your Profile',
          subtitle:
              'Let’s start with your basic academic information.',
        ),

        const SizedBox(height: 22),

        buildLabel('Full Name'),
        buildTextField(
          controller: nameController,
          hint: 'Enter your complete name',
          icon: Icons.person_outline_rounded,
        ),

        const SizedBox(height: 18),

        buildLabel('Section'),
        buildTextField(
          controller: sectionController,
          hint: 'Example: 301',
          icon: Icons.groups_rounded,
        ),

        const SizedBox(height: 18),

        buildLabel('Course'),
        buildTextField(
          controller: courseController,
          hint: 'Example: BST',
          icon: Icons.school_outlined,
        ),

        const SizedBox(height: 25),

        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: const Color(0xFFF0EAFF),
            borderRadius: BorderRadius.circular(17),
            border: Border.all(
              color: const Color(0xFFE2D8FF),
            ),
          ),
          child: const Row(
            children: [
              Icon(
                Icons.info_outline_rounded,
                color: Color(0xFF6C3CE9),
                size: 20,
              ),
              SizedBox(width: 11),
              Expanded(
                child: Text(
                  'Make sure your information is correct before continuing.',
                  style: TextStyle(
                    color: Color(0xFF5B4B75),
                    fontSize: 12,
                    height: 1.4,
                  ),
                ),
              ),
            ],
          ),
        ),

        const SizedBox(height: 25),

        buildNextButton(),
      ],
    );
  }

  Widget buildSubjects() {
    return Column(
      key: const ValueKey('subjects'),
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        buildHeader(
          icon: Icons.auto_stories_rounded,
          title: 'Choose Your Subjects',
          subtitle:
              'Add your enrolled subjects and class schedules.',
        ),

        const SizedBox(height: 22),

        buildSubjectCard(
          number: '01',
          subjectController: subject1Controller,
          timeController: subject1TimeController,
        ),

        const SizedBox(height: 16),

        buildSubjectCard(
          number: '02',
          subjectController: subject2Controller,
          timeController: subject2TimeController,
        ),

        const SizedBox(height: 25),

        buildNavigationButtons(),
      ],
    );
  }

  Widget buildVerification() {
    return Column(
      key: const ValueKey('verification'),
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        buildHeader(
          icon: Icons.fact_check_rounded,
          title: 'Final Review',
          subtitle:
              'Check everything before completing your registration.',
        ),

        const SizedBox(height: 22),

        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(24),
            border: Border.all(
              color: const Color(0xFFE8E2F0),
            ),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF4B3A68).withOpacity(.06),
                blurRadius: 20,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF0EAFF),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(
                      Icons.person_rounded,
                      color: Color(0xFF6C3CE9),
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 12),
                  const Column(
                    crossAxisAlignment:
                        CrossAxisAlignment.start,
                    children: [
                      Text(
                        'STUDENT INFORMATION',
                        style: TextStyle(
                          color: Color(0xFF292334),
                          fontWeight: FontWeight.w900,
                          fontSize: 12,
                          letterSpacing: .7,
                        ),
                      ),
                      SizedBox(height: 2),
                      Text(
                        'Personal & academic details',
                        style: TextStyle(
                          color: Color(0xFF9993A4),
                          fontSize: 10,
                        ),
                      ),
                    ],
                  ),
                ],
              ),

              const SizedBox(height: 20),

              verificationRow(
                'Name',
                nameController.text,
                Icons.person_outline_rounded,
              ),

              verificationRow(
                'Section',
                sectionController.text,
                Icons.groups_rounded,
              ),

              verificationRow(
                'Course',
                courseController.text,
                Icons.school_outlined,
              ),

              const SizedBox(height: 8),

              Container(
                height: 1,
                color: const Color(0xFFEDE9F2),
              ),

              const SizedBox(height: 18),

              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFFF3E8),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(
                      Icons.menu_book_rounded,
                      color: Color(0xFFE98225),
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 12),
                  const Column(
                    crossAxisAlignment:
                        CrossAxisAlignment.start,
                    children: [
                      Text(
                        'ENROLLED SUBJECTS',
                        style: TextStyle(
                          color: Color(0xFF292334),
                          fontWeight: FontWeight.w900,
                          fontSize: 12,
                          letterSpacing: .7,
                        ),
                      ),
                      SizedBox(height: 2),
                      Text(
                        'Class schedule',
                        style: TextStyle(
                          color: Color(0xFF9993A4),
                          fontSize: 10,
                        ),
                      ),
                    ],
                  ),
                ],
              ),

              const SizedBox(height: 18),

              verificationRow(
                'Subject 1',
                subject1Controller.text,
                Icons.book_outlined,
              ),

              verificationRow(
                'Time',
                subject1TimeController.text,
                Icons.schedule_rounded,
              ),

              Container(
                height: 1,
                color: const Color(0xFFEDE9F2),
              ),

              const SizedBox(height: 18),

              verificationRow(
                'Subject 2',
                subject2Controller.text,
                Icons.book_outlined,
              ),

              verificationRow(
                'Time',
                subject2TimeController.text,
                Icons.schedule_rounded,
              ),
            ],
          ),
        ),

        const SizedBox(height: 25),

        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(15),
          decoration: BoxDecoration(
            color: const Color(0xFFEAFBF2),
            borderRadius: BorderRadius.circular(17),
            border: Border.all(
              color: const Color(0xFFD1F1E0),
            ),
          ),
          child: const Row(
            children: [
              Icon(
                Icons.verified_rounded,
                color: Color(0xFF18A866),
                size: 21,
              ),
              SizedBox(width: 10),
              Expanded(
                child: Text(
                  'Everything looks good. You can now save your registration.',
                  style: TextStyle(
                    color: Color(0xFF287351),
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
        ),

        const SizedBox(height: 25),

        Row(
          children: [
            Expanded(
              child: OutlinedButton(
                onPressed: isSaving ? null : previousStep,
                style: OutlinedButton.styleFrom(
                  foregroundColor: const Color(0xFF625B6F),
                  side: const BorderSide(
                    color: Color(0xFFDAD4E4),
                  ),
                  padding: const EdgeInsets.symmetric(
                    vertical: 16,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                child: const Text(
                  'Back',
                  style: TextStyle(
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ),

            const SizedBox(width: 12),

            Expanded(
              flex: 2,
              child: buildSaveButton(),
            ),
          ],
        ),
      ],
    );
  }

  Widget buildHeader({
    required IconData icon,
    required String title,
    required String subtitle,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFF8B5CF6),
            Color(0xFF6C3CE9),
            Color(0xFF5425B5),
          ],
        ),
        borderRadius: BorderRadius.circular(27),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF6C3CE9).withOpacity(.20),
            blurRadius: 25,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Stack(
        children: [
          Positioned(
            right: -15,
            top: -25,
            child: Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(.08),
                shape: BoxShape.circle,
              ),
            ),
          ),
          Positioned(
            right: 25,
            bottom: -40,
            child: Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(.06),
                shape: BoxShape.circle,
              ),
            ),
          ),
          Row(
            children: [
              Container(
                width: 58,
                height: 58,
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(.16),
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(
                    color: Colors.white.withOpacity(.20),
                  ),
                ),
                child: Icon(
                  icon,
                  color: Colors.white,
                  size: 29,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment:
                      CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 21,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    const SizedBox(height: 5),
                    Text(
                      subtitle,
                      style: TextStyle(
                        color: Colors.white.withOpacity(.78),
                        fontSize: 12,
                        height: 1.3,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget buildLabel(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(
        text.toUpperCase(),
        style: const TextStyle(
          color: Color(0xFF625B6F),
          fontWeight: FontWeight.w800,
          fontSize: 10,
          letterSpacing: 1,
        ),
      ),
    );
  }

  Widget buildTextField({
    required TextEditingController controller,
    required String hint,
    required IconData icon,
  }) {
    return TextField(
      controller: controller,
      style: const TextStyle(
        color: Color(0xFF292334),
        fontWeight: FontWeight.w600,
      ),
      decoration: InputDecoration(
        hintText: hint,
        prefixIcon: Icon(icon),
      ),
    );
  }

  Widget buildSubjectCard({
    required String number,
    required TextEditingController subjectController,
    required TextEditingController timeController,
  }) {
    return Container(
      padding: const EdgeInsets.all(19),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(23),
        border: Border.all(
          color: const Color(0xFFE8E2F0),
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF4B3A68).withOpacity(.05),
            blurRadius: 18,
            offset: const Offset(0, 7),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 43,
                height: 43,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [
                      Color(0xFFFFB86C),
                      Color(0xFFE98225),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Center(
                  child: Text(
                    number,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 13,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              const Column(
                crossAxisAlignment:
                    CrossAxisAlignment.start,
                children: [
                  Text(
                    'SUBJECT DETAILS',
                    style: TextStyle(
                      color: Color(0xFF292334),
                      fontWeight: FontWeight.w900,
                      fontSize: 12,
                      letterSpacing: .7,
                    ),
                  ),
                  SizedBox(height: 2),
                  Text(
                    'Enter class information',
                    style: TextStyle(
                      color: Color(0xFF9993A4),
                      fontSize: 10,
                    ),
                  ),
                ],
              ),
            ],
          ),

          const SizedBox(height: 19),

          buildLabel('Subject'),

          buildTextField(
            controller: subjectController,
            hint: 'Example: BMC',
            icon: Icons.menu_book_rounded,
          ),

          const SizedBox(height: 15),

          buildLabel('Class Time'),

          buildTextField(
            controller: timeController,
            hint: 'Example: 7:30 - 10:30',
            icon: Icons.schedule_rounded,
          ),
        ],
      ),
    );
  }

  Widget verificationRow(
    String label,
    String value,
    IconData icon,
  ) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Row(
        crossAxisAlignment:
            CrossAxisAlignment.start,
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: const Color(0xFFF1ECFF),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(
              icon,
              color: const Color(0xFF6C3CE9),
              size: 18,
            ),
          ),
          const SizedBox(width: 11),
          Expanded(
            child: Column(
              crossAxisAlignment:
                  CrossAxisAlignment.start,
              children: [
                Text(
                  label.toUpperCase(),
                  style: const TextStyle(
                    color: Color(0xFF9993A4),
                    fontSize: 9,
                    fontWeight: FontWeight.w800,
                    letterSpacing: .8,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  value.isEmpty ? '-' : value,
                  style: const TextStyle(
                    color: Color(0xFF292334),
                    fontWeight: FontWeight.w700,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget buildNextButton() {
    return SizedBox(
      width: double.infinity,
      height: 55,
      child: Container(
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [
              Color(0xFF8B5CF6),
              Color(0xFF5B21B6),
            ],
          ),
          borderRadius: BorderRadius.circular(17),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF6C3CE9).withOpacity(.22),
              blurRadius: 18,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: FilledButton.icon(
          onPressed: nextStep,
          icon: const Icon(Icons.arrow_forward_rounded),
          label: const Text(
            'CONTINUE',
            style: TextStyle(
              fontWeight: FontWeight.w900,
              letterSpacing: 1,
            ),
          ),
          style: FilledButton.styleFrom(
            backgroundColor: Colors.transparent,
            foregroundColor: Colors.white,
            shadowColor: Colors.transparent,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(17),
            ),
          ),
        ),
      ),
    );
  }

  Widget buildSaveButton() {
    return SizedBox(
      height: 53,
      child: Container(
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [
              Color(0xFF8B5CF6),
              Color(0xFF5B21B6),
            ],
          ),
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF6C3CE9).withOpacity(.20),
              blurRadius: 16,
              offset: const Offset(0, 7),
            ),
          ],
        ),
        child: FilledButton.icon(
          onPressed: isSaving ? null : saveData,
          icon: isSaving
              ? const SizedBox(
                  width: 18,
                  height: 18,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: Colors.white,
                  ),
                )
              : const Icon(
                  Icons.cloud_done_rounded,
                ),
          label: Text(
            isSaving ? 'Saving...' : 'SAVE REGISTRATION',
            style: const TextStyle(
              fontWeight: FontWeight.w900,
              fontSize: 11,
              letterSpacing: .5,
            ),
          ),
          style: FilledButton.styleFrom(
            backgroundColor: Colors.transparent,
            foregroundColor: Colors.white,
            shadowColor: Colors.transparent,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
          ),
        ),
      ),
    );
  }

  Widget buildNavigationButtons() {
    return Row(
      children: [
        Expanded(
          child: OutlinedButton.icon(
            onPressed: previousStep,
            icon: const Icon(
              Icons.arrow_back_rounded,
              size: 18,
            ),
            label: const Text('Back'),
            style: OutlinedButton.styleFrom(
              foregroundColor: const Color(0xFF625B6F),
              side: const BorderSide(
                color: Color(0xFFDAD4E4),
              ),
              padding: const EdgeInsets.symmetric(
                vertical: 16,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
            ),
          ),
        ),

        const SizedBox(width: 12),

        Expanded(
          flex: 2,
          child: Container(
            height: 52,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [
                  Color(0xFF8B5CF6),
                  Color(0xFF5B21B6),
                ],
              ),
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF6C3CE9)
                      .withOpacity(.20),
                  blurRadius: 16,
                  offset: const Offset(0, 7),
                ),
              ],
            ),
            child: FilledButton.icon(
              onPressed: nextStep,
              icon: const Icon(
                Icons.arrow_forward_rounded,
              ),
              label: const Text(
                'CONTINUE',
                style: TextStyle(
                  fontWeight: FontWeight.w900,
                  letterSpacing: .7,
                ),
              ),
              style: FilledButton.styleFrom(
                backgroundColor: Colors.transparent,
                foregroundColor: Colors.white,
                shadowColor: Colors.transparent,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}