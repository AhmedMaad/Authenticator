import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cupertino_ui/cupertino_ui.dart';
import 'package:firebase_auth/firebase_auth.dart';

class FormPage extends StatefulWidget {
  const FormPage({super.key});

  @override
  State<FormPage> createState() => _FormScreenState();
}

class _FormScreenState extends State<FormPage> {
  final nameController = TextEditingController();
  final emailController = TextEditingController();
  final phoneController = TextEditingController();
  final linkedInController = TextEditingController();
  final githubController = TextEditingController();
  final expectationsController = TextEditingController();
  var isLoading = false;

  Future<void> getEmail() async {
    emailController.text = FirebaseAuth.instance.currentUser!.email!;
  }

  @override
  void initState() {
    getEmail();
    super.initState();
  }

  @override
  void dispose() {
    nameController.dispose();
    emailController.dispose();
    phoneController.dispose();
    linkedInController.dispose();
    githubController.dispose();
    expectationsController.dispose();
    super.dispose();
  }

  Widget buildTextField({
    required TextEditingController controller,
    required String placeholder,
    TextInputType keyboardType = TextInputType.text,
    int maxLines = 1,
  }) {
    return CupertinoTextField(
      controller: controller,
      placeholder: placeholder,
      keyboardType: keyboardType,
      maxLines: maxLines,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      decoration: BoxDecoration(
        color: CupertinoColors.systemGrey6,
        borderRadius: BorderRadius.circular(14),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      navigationBar: const CupertinoNavigationBar(middle: Text('Intern Gate')),
      child: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Application Form',
                style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              const Text(
                'Fill in your information to apply for the internship.',
                style: TextStyle(
                  fontSize: 15,
                  color: CupertinoColors.secondaryLabel,
                ),
              ),
              const SizedBox(height: 28),

              buildTextField(
                controller: nameController,
                placeholder: 'Full name',
              ),
              const SizedBox(height: 16),

              buildTextField(
                controller: emailController,
                placeholder: 'Email address',
                keyboardType: TextInputType.emailAddress,
              ),
              const SizedBox(height: 16),

              buildTextField(
                controller: phoneController,
                placeholder: 'Phone number',
                keyboardType: TextInputType.phone,
              ),
              const SizedBox(height: 16),

              buildTextField(
                controller: linkedInController,
                placeholder: 'LinkedIn profile URL',
                keyboardType: TextInputType.url,
              ),
              const SizedBox(height: 16),

              buildTextField(
                controller: githubController,
                placeholder: 'GitHub profile URL',
                keyboardType: TextInputType.url,
              ),
              const SizedBox(height: 16),

              buildTextField(
                controller: expectationsController,
                placeholder: 'What do you expect from this internship?',
                maxLines: 5,
              ),
              const SizedBox(height: 28),

              SizedBox(
                width: double.infinity,
                height: 52,
                child: CupertinoButton.filled(
                  borderRadius: BorderRadius.circular(14),
                  onPressed: () {
                    setState(() {
                      isLoading = true;
                    });
                    addTraineeData();
                  },
                  child: const Text(
                    'Submit',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                  ),
                ),
              ),

              const SizedBox(height: 20),

              Center(
                child: isLoading
                    ? const CupertinoActivityIndicator(radius: 14)
                    : const SizedBox.shrink(),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> addTraineeData() async {
    final db = FirebaseFirestore.instance;
    await db
        .collection('trainees')
        .doc(FirebaseAuth.instance.currentUser!.uid)
        .set({
          'name': nameController.text,
          'email': emailController.text,
          'phone': phoneController.text,
          'linkedIn': linkedInController.text,
          'github': githubController.text,
          'expectations': expectationsController.text,
        });
    setState(() {
      isLoading = false;
    });
  }
}
