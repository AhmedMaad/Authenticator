import 'package:cupertino_ui/cupertino_ui.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';

import 'firebase_options.dart';

void main() async {
  //is necessary when you perform asynchronous initialization before runApp()
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  runApp(const AuthenticatorApp());
}

class AuthenticatorApp extends StatelessWidget {
  const AuthenticatorApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const CupertinoApp(
      debugShowCheckedModeBanner: false,
      theme: CupertinoThemeData(
        primaryColor: CupertinoColors.systemBlue,
        brightness: Brightness.light,
      ),
      home: AuthPage(),
    );
  }
}

class AuthPage extends StatefulWidget {
  const AuthPage({super.key});

  @override
  State<AuthPage> createState() => _AuthPageState();
}

class _AuthPageState extends State<AuthPage> {
  int selectedTab = 0;

  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final confirmPasswordController = TextEditingController();

  bool obscurePassword = true;
  bool obscureConfirmPassword = true;

  bool isLoading = false;
  bool isForgotPasswordLoading = false;

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    confirmPasswordController.dispose();
    super.dispose();
  }

  void showMessage(String message) {
    showCupertinoDialog(
      context: context,
      builder: (context) => CupertinoAlertDialog(
        content: Text(message),
        actions: [
          CupertinoDialogAction(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  Widget buildTextField({
    required TextEditingController controller,
    required String placeholder,
    required IconData icon,
    bool obscureText = false,
    Widget? suffix,
    TextInputType keyboardType = TextInputType.text,
  }) {
    return CupertinoTextField(
      controller: controller,
      placeholder: placeholder,
      obscureText: obscureText,
      keyboardType: keyboardType,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 17),
      prefix: Padding(
        padding: const EdgeInsets.only(left: 14),
        child: Icon(icon, color: CupertinoColors.systemGrey, size: 20),
      ),
      suffix: suffix,
      decoration: BoxDecoration(
        color: CupertinoColors.systemGrey6,
        borderRadius: BorderRadius.circular(14),
      ),
    );
  }

  Widget buildPasswordField({
    required TextEditingController controller,
    required String placeholder,
    required bool obscure,
    required VoidCallback onToggle,
  }) {
    return buildTextField(
      controller: controller,
      placeholder: placeholder,
      icon: CupertinoIcons.lock,
      obscureText: obscure,
      suffix: CupertinoButton(
        padding: const EdgeInsets.symmetric(horizontal: 14),
        minimumSize: Size(0, 0),
        onPressed: onToggle,
        child: Icon(
          obscure ? CupertinoIcons.eye : CupertinoIcons.eye_slash,
          color: CupertinoColors.systemGrey,
          size: 20,
        ),
      ),
    );
  }

  Widget buildPrimaryButton({
    required String title,
    required VoidCallback onPressed,
  }) {
    return SizedBox(
      width: double.infinity,
      height: 52,
      child: CupertinoButton.filled(
        borderRadius: BorderRadius.circular(14),
        onPressed: onPressed,
        child: isLoading
            ? CupertinoActivityIndicator(color: CupertinoColors.white)
            : Text(
                title,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
      ),
    );
  }

  Widget buildLoginForm() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        buildTextField(
          controller: emailController,
          placeholder: 'Email address',
          icon: CupertinoIcons.mail,
          keyboardType: TextInputType.emailAddress,
        ),
        const SizedBox(height: 16),
        buildPasswordField(
          controller: passwordController,
          placeholder: 'Password',
          obscure: obscurePassword,
          onToggle: () {
            setState(() {
              obscurePassword = !obscurePassword;
            });
          },
        ),
        const SizedBox(height: 12),
        Align(
          alignment: Alignment.centerRight,
          child: GestureDetector(
            onTap: () async {
              setState(() => isForgotPasswordLoading = true);
              sendPasswordResetLink();
            },
            child: isForgotPasswordLoading
                ? const CupertinoActivityIndicator()
                : const Text(
                    'Forgot Password?',
                    style: TextStyle(
                      color: CupertinoColors.systemBlue,
                      fontSize: 14,
                      decoration: TextDecoration.underline,
                    ),
                  ),
          ),
        ),
        const SizedBox(height: 28),
        buildPrimaryButton(title: 'Login', onPressed: validateLogin),
      ],
    );
  }

  Widget buildSignUpForm() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        buildTextField(
          controller: emailController,
          placeholder: 'Email address',
          icon: CupertinoIcons.mail,
          keyboardType: TextInputType.emailAddress,
        ),
        const SizedBox(height: 16),
        buildPasswordField(
          controller: passwordController,
          placeholder: 'Password',
          obscure: obscurePassword,
          onToggle: () {
            setState(() {
              obscurePassword = !obscurePassword;
            });
          },
        ),
        const SizedBox(height: 16),
        buildPasswordField(
          controller: confirmPasswordController,
          placeholder: 'Confirm password',
          obscure: obscureConfirmPassword,
          onToggle: () {
            setState(() {
              obscureConfirmPassword = !obscureConfirmPassword;
            });
          },
        ),
        const SizedBox(height: 28),
        buildPrimaryButton(title: 'Sign Up', onPressed: validateSignUp),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      child: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 32),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Icon(
                  CupertinoIcons.person_circle,
                  size: 64,
                  color: CupertinoColors.systemBlue,
                ),
                const SizedBox(height: 24),
                const Text(
                  'Welcome',
                  style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Login or create an account to get started.',
                  style: TextStyle(
                    fontSize: 15,
                    color: CupertinoColors.secondaryLabel,
                  ),
                ),
                const SizedBox(height: 32),

                // Login / Sign Up tabs
                SizedBox(
                  width: double.infinity,
                  child: CupertinoSlidingSegmentedControl<int>(
                    groupValue: selectedTab,
                    children: const {
                      0: Padding(
                        padding: EdgeInsets.symmetric(vertical: 10),
                        child: Text('Login'),
                      ),
                      1: Padding(
                        padding: EdgeInsets.symmetric(vertical: 10),
                        child: Text('Sign Up'),
                      ),
                    },
                    onValueChanged: (value) {
                      if (value != null) {
                        setState(() {
                          isLoading = false;
                          selectedTab = value;
                        });
                      }
                    },
                  ),
                ),

                const SizedBox(height: 32),

                // Selected tab content
                AnimatedSwitcher(
                  duration: const Duration(milliseconds: 250),
                  child: selectedTab == 0
                      ? KeyedSubtree(
                          key: const ValueKey('login'),
                          child: buildLoginForm(),
                        )
                      : KeyedSubtree(
                          key: const ValueKey('signup'),
                          child: buildSignUpForm(),
                        ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> validateLogin() async {
    final email = emailController.text.trim();
    final password = passwordController.text;
    if (email.isEmpty || password.isEmpty) {
      showMessage('Please fill in all fields.');
    } else {
      setState(() => isLoading = true);
      loginUser(email, password);
    }
  }

  Future<void> validateSignUp() async {
    final email = emailController.text.trim();
    final password = passwordController.text;
    final confirmPassword = confirmPasswordController.text;

    if (email.isEmpty || password.isEmpty || confirmPassword.isEmpty) {
      showMessage('Please fill in all fields.');
    } else if (!email.contains('@')) {
      showMessage('Please enter a valid email address.');
    } else if (password.length < 6) {
      showMessage('Password must be at least 6 characters.');
    } else if (password != confirmPassword) {
      showMessage('Passwords do not match.');
    } else {
      setState(() => isLoading = true);
      addUser(email, password);
    }
  }

  Future<void> addUser(email, password) async {
    try {
      final credential = await FirebaseAuth.instance
          .createUserWithEmailAndPassword(email: email, password: password);
      verifyEmail(credential.user);
    } on FirebaseAuthException catch (e) {
      if (e.code == 'weak-password') {
        showMessage('The password provided is too weak.');
      } else if (e.code == 'email-already-in-use') {
        showMessage('The account already exists for that email.');
      }
      setState(() {
        isLoading = false;
      });
    } catch (e) {
      showMessage("$e");
      setState(() {
        isLoading = false;
      });
    }
  }

  Future<void> verifyEmail(User? user) async {
    try {
      await user?.sendEmailVerification();
      showMessage('Check your email');
    } catch (e) {
      showMessage('Cannot send email verification link');
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  Future<void> loginUser(email, password) async {
    try {
      final credential = await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      if (credential.user!.emailVerified) {
        showMessage('Logged in successfully!');
      } else {
        showMessage('Verify your email first!');
      }
    } on FirebaseAuthException catch (e) {
      if (e.code == 'user-not-found') {
        showMessage('No user found for that email.');
      } else if (e.code == 'invalid-credential') {
        showMessage('Wrong email or password.');
      }
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  Future<void> sendPasswordResetLink() async {
    try {
      await FirebaseAuth.instance.sendPasswordResetEmail(
        email: emailController.text,
      );
      showMessage('Sent!');
    } catch (e) {
      showMessage('$e');
    } finally {
      setState(() {
        isForgotPasswordLoading = false;
      });
    }
  }
}
