import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../core/utils/validators.dart';
import '../../providers/auth_provider.dart';

/// Signup screen
/// Allows new users to create an account
class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  final _formKey = GlobalKey<FormState>();
  final _usernameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _fullNameController = TextEditingController();
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;

  static const Color _backgroundColor = Color(0xFFFDF6F4);
  static const Color _brandColor = Color(0xFFA35449);
  static const Color _primaryButtonColor = Color(0xFFD92D2D);
  static const Color _textColor = Color(0xFF241F2B);
  static const Color _mutedTextColor = Color(0xFF7A7482);
  static const Color _borderColor = Color(0xFFE5D7D2);
  static const Color _inputFillColor = Color(0xFFFFFFFF);

  @override
  void dispose() {
    _usernameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _fullNameController.dispose();
    super.dispose();
  }

  Future<void> _handleSignup() async {
    // Clear any previous errors
    context.read<AuthProvider>().clearMessages();

    // Validate form
    if (!_formKey.currentState!.validate()) {
      return;
    }

    // Attempt signup
    final authProvider = context.read<AuthProvider>();
    final result = await authProvider.signUp(
      email: _emailController.text.trim(),
      password: _passwordController.text,
      username: _usernameController.text.trim(),
      fullName: _fullNameController.text.trim().isEmpty
          ? null
          : _fullNameController.text.trim(),
    );

    if ((result == SignUpFlowResult.signedIn ||
            result == SignUpFlowResult.emailConfirmationRequired) &&
        mounted) {
      // Navigation will be handled by app.dart based on auth state
      Navigator.of(context).pop(); // Close signup screen
    }
  }

  InputDecoration _authFieldDecoration({
    required String labelText,
    required String hintText,
    required IconData prefixIcon,
    Widget? suffixIcon,
  }) {
    return InputDecoration(
      labelText: labelText,
      hintText: hintText,
      filled: true,
      fillColor: _inputFillColor,
      prefixIcon: Icon(prefixIcon, color: _brandColor),
      suffixIcon: suffixIcon,
      labelStyle: const TextStyle(
        color: _mutedTextColor,
        fontWeight: FontWeight.w500,
      ),
      hintStyle: const TextStyle(color: _mutedTextColor),
      contentPadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 18),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: const BorderSide(color: _borderColor),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: const BorderSide(color: _borderColor),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: const BorderSide(color: _brandColor, width: 1.6),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: const BorderSide(color: Color(0xFFD92D2D)),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: const BorderSide(color: Color(0xFFD92D2D), width: 1.6),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _backgroundColor,
      appBar: AppBar(
        backgroundColor: _brandColor,
        foregroundColor: Colors.white,
        elevation: 0,
        title: const Text('Sign Up'),
        centerTitle: true,
      ),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24.0),
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Welcome Text
                  Text(
                    'Create Account',
                    style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                      color: _textColor,
                      fontWeight: FontWeight.w700,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Sign up to get started',
                    style: Theme.of(
                      context,
                    ).textTheme.bodyMedium?.copyWith(color: _mutedTextColor),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 32),

                  // Username Field
                  TextFormField(
                    controller: _usernameController,
                    textInputAction: TextInputAction.next,
                    style: const TextStyle(
                      color: _textColor,
                      fontWeight: FontWeight.w500,
                    ),
                    decoration: _authFieldDecoration(
                      labelText: 'Username',
                      hintText: 'Choose a username',
                      prefixIcon: Icons.person_outlined,
                    ),
                    validator: Validators.username,
                  ),
                  const SizedBox(height: 16),

                  // Full Name Field (Optional)
                  TextFormField(
                    controller: _fullNameController,
                    textInputAction: TextInputAction.next,
                    textCapitalization: TextCapitalization.words,
                    style: const TextStyle(
                      color: _textColor,
                      fontWeight: FontWeight.w500,
                    ),
                    decoration: _authFieldDecoration(
                      labelText: 'Full Name (Optional)',
                      hintText: 'Enter your full name',
                      prefixIcon: Icons.badge_outlined,
                    ),
                    validator: (value) {
                      // Optional field, only validate if not empty
                      if (value != null && value.isNotEmpty) {
                        return Validators.name(value);
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),

                  // Email Field
                  TextFormField(
                    controller: _emailController,
                    keyboardType: TextInputType.emailAddress,
                    textInputAction: TextInputAction.next,
                    style: const TextStyle(
                      color: _textColor,
                      fontWeight: FontWeight.w500,
                    ),
                    decoration: _authFieldDecoration(
                      labelText: 'Email',
                      hintText: 'Enter your email',
                      prefixIcon: Icons.email_outlined,
                    ),
                    validator: Validators.email,
                  ),
                  const SizedBox(height: 16),

                  // Password Field
                  TextFormField(
                    controller: _passwordController,
                    obscureText: _obscurePassword,
                    textInputAction: TextInputAction.next,
                    style: const TextStyle(
                      color: _textColor,
                      fontWeight: FontWeight.w500,
                    ),
                    decoration: _authFieldDecoration(
                      labelText: 'Password',
                      hintText: 'Choose a password',
                      prefixIcon: Icons.lock_outlined,
                      suffixIcon: IconButton(
                        icon: Icon(
                          _obscurePassword
                              ? Icons.visibility_outlined
                              : Icons.visibility_off_outlined,
                          color: _mutedTextColor,
                        ),
                        onPressed: () {
                          setState(() {
                            _obscurePassword = !_obscurePassword;
                          });
                        },
                      ),
                    ),
                    validator: Validators.password,
                  ),
                  const SizedBox(height: 16),

                  // Confirm Password Field
                  TextFormField(
                    controller: _confirmPasswordController,
                    obscureText: _obscureConfirmPassword,
                    textInputAction: TextInputAction.done,
                    onFieldSubmitted: (_) => _handleSignup(),
                    style: const TextStyle(
                      color: _textColor,
                      fontWeight: FontWeight.w500,
                    ),
                    decoration: _authFieldDecoration(
                      labelText: 'Confirm Password',
                      hintText: 'Re-enter your password',
                      prefixIcon: Icons.lock_outlined,
                      suffixIcon: IconButton(
                        icon: Icon(
                          _obscureConfirmPassword
                              ? Icons.visibility_outlined
                              : Icons.visibility_off_outlined,
                          color: _mutedTextColor,
                        ),
                        onPressed: () {
                          setState(() {
                            _obscureConfirmPassword = !_obscureConfirmPassword;
                          });
                        },
                      ),
                    ),
                    validator: (value) => Validators.confirmPassword(
                      value,
                      _passwordController.text,
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Error Message
                  Consumer<AuthProvider>(
                    builder: (context, authProvider, _) {
                      if (authProvider.errorMessage != null) {
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 16.0),
                          child: Text(
                            authProvider.errorMessage!,
                            style: const TextStyle(
                              color: Color(0xFFB42318),
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        );
                      }
                      if (authProvider.infoMessage != null) {
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 16.0),
                          child: Text(
                            authProvider.infoMessage!,
                            style: const TextStyle(
                              color: Color(0xFF0C6B58),
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        );
                      }
                      return const SizedBox.shrink();
                    },
                  ),

                  // Signup Button
                  Consumer<AuthProvider>(
                    builder: (context, authProvider, _) {
                      return ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: _primaryButtonColor,
                          foregroundColor: Colors.white,
                          disabledBackgroundColor: _primaryButtonColor
                              .withValues(alpha: 0.55),
                          disabledForegroundColor: Colors.white.withValues(
                            alpha: 0.9,
                          ),
                          elevation: 6,
                          shadowColor: _primaryButtonColor.withValues(
                            alpha: 0.28,
                          ),
                          padding: const EdgeInsets.symmetric(vertical: 18),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                          textStyle: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        onPressed: authProvider.isLoading
                            ? null
                            : _handleSignup,
                        child: authProvider.isLoading
                            ? const SizedBox(
                                height: 20,
                                width: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                ),
                              )
                            : const Text('Sign Up'),
                      );
                    },
                  ),
                  const SizedBox(height: 16),

                  // Login Link
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text(
                        'Already have an account? ',
                        style: TextStyle(color: _textColor),
                      ),
                      TextButton(
                        style: TextButton.styleFrom(
                          foregroundColor: _primaryButtonColor,
                        ),
                        onPressed: () => Navigator.of(context).pop(),
                        child: const Text(
                          'Login',
                          style: TextStyle(fontWeight: FontWeight.w700),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
