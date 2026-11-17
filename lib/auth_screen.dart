import 'package:audiyo/appColors.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class AuthScreen extends StatefulWidget {
  const AuthScreen({super.key});

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  final formKey = GlobalKey<FormState>();

  final nameController = TextEditingController();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final dateController = TextEditingController();

  bool isLogin = true;
  bool hidePassword = true;
  bool isLoading = false;

  String? selectedCountry;

  final countries = [
    'Afghanistan',
    'Albania',
    'Azerbaijan',
    'Armenia',
    'Australia',
    'Bulgaria',
    'Bangladesh',
    'Bhutan',
    'Bahrain',
    'Burkina Faso',
    'Congo',
    'Canada',
    'Indonesia',
    'India',
    'Pakistan',
    'Palestine',
    'Saudi Arabia',
    'Qatar',
    'Somalia',
    'New Zealand',
    'Germany',
    'Fiji',
    'Ireland',
    'Philippines',
    'Nepal',
    'Thailand',
    'Japan',
    'China',
    'Russia',
    'United Kingdom',
    'United States',
    'Brazil',
    'Argentina',
    'Spain',
    'Egypt',
    'Yemen',
    'Jordan',
    'Malta',
    'Malaysia',
    'Oman',
    'Syria',
    'South Korea',
    'North Korea',
    'Hong Kong',
    'South Africa',
  ];

  @override
  void dispose() {
    nameController.dispose();
    emailController.dispose();
    passwordController.dispose();
    dateController.dispose();
    super.dispose();
  }

  Future<void> selectDate() async {
    DateTime? date = await showDatePicker(
      context: context,
      initialDate: DateTime(2000, 1, 1),
      firstDate: DateTime(1910),
      lastDate: DateTime.now(),
    );

    if (date != null && mounted) {
      setState(() {
        dateController.text = '${date.day}/${date.month}/${date.year}';
      });
    }
  }

  void switchScreen() {
    setState(() {
      isLogin = !isLogin;

      nameController.clear();
      emailController.clear();
      passwordController.clear();
      dateController.clear();

      selectedCountry = null;
      formKey.currentState?.reset();
    });
  }

  Future<void> submitForm() async {
    if (!formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      isLoading = true;
    });

    try {
      if (isLogin) {
        await Supabase.instance.client.auth.signInWithPassword(
          email: emailController.text.trim(),
          password: passwordController.text,
        );

        if (mounted) {
          ScaffoldMessenger.of(context)
              .showSnackBar(const SnackBar(content: Text('Login successful!')));
        }
      } else {
        final response = await Supabase.instance.client.auth.signUp(
          email: emailController.text.trim(),
          password: passwordController.text,
          data: {
            'full_name': nameController.text.trim(),
            'date_of_birth': dateController.text,
            'country': selectedCountry,
          },
        );

        if (mounted && response.session == null) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text(
                'Registration successful! Please verify your email.',
              ),
            ),
          );
        }
      }
    } on AuthException catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text(error.message)));
      }
    } catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text(error.toString())));
      }
    } finally {
      if (mounted) {
        setState(() {
          isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 420),
              child: Form(
                key: formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Icon(
                      Icons.menu_book_rounded,
                      size: 65,
                      color: Appcolors.goldColor,
                    ),

                    const SizedBox(height: 10),

                    Text(
                      'AUDIYO',
                      textAlign: TextAlign.center,
                      style: GoogleFonts.lora(
                        fontSize: 38,
                        fontWeight: FontWeight.bold,
                        color: Appcolors.navyColor,
                      ),
                    ),

                    const SizedBox(height: 5),

                    Text(
                      'Collection Of Creative Poems',
                      textAlign: TextAlign.center,
                      style: GoogleFonts.lora(
                        fontSize: 13,
                        color: Theme.of(context).colorScheme.onSurface,
                      ),
                    ),

                    const SizedBox(height: 35),

                    if (!isLogin) ...[
                      TextFormField(
                        controller: nameController,
                        decoration: const InputDecoration(
                          labelText: 'Full Name',
                          prefixIcon: Icon(Icons.person_outline),
                        ),
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'Please enter your name';
                          }

                          return null;
                        },
                      ),

                      const SizedBox(height: 16),
                    ],

                    TextFormField(
                      controller: emailController,
                      keyboardType: TextInputType.emailAddress,
                      decoration: const InputDecoration(
                        labelText: 'Email',
                        hintText: 'Enter your email',
                        prefixIcon: Icon(Icons.alternate_email),
                      ),
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Please enter your email';
                        }

                        final emailRegex = RegExp(
                          r'^[^@\s]+@[^@\s]+\.[^@\s]+$',
                        );

                        if (!emailRegex.hasMatch(value.trim())) {
                          return 'Please enter a valid email';
                        }

                        return null;
                      },
                    ),

                    const SizedBox(height: 16),

                    TextFormField(
                      controller: passwordController,
                      obscureText: hidePassword,
                      decoration: InputDecoration(
                        labelText: 'Password',
                        hintText: 'Enter password',
                        prefixIcon: const Icon(Icons.lock_outline),
                        suffixIcon: IconButton(
                          onPressed: () {
                            setState(() {
                              hidePassword = !hidePassword;
                            });
                          },
                          icon: Icon(
                            hidePassword
                                ? Icons.visibility_off
                                : Icons.visibility,
                          ),
                        ),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter password';
                        }

                        if (value.length < 6) {
                          return 'Password must be at least 6 characters';
                        }

                        return null;
                      },
                    ),

                    if (!isLogin) ...[
                      const SizedBox(height: 16),

                      TextFormField(
                        controller: dateController,
                        readOnly: true,
                        onTap: selectDate,
                        decoration: const InputDecoration(
                          labelText: 'Date Of Birth',
                          hintText: 'Select your date of birth',
                          prefixIcon: Icon(Icons.calendar_month_outlined),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please select your birth date';
                          }

                          return null;
                        },
                      ),

                      const SizedBox(height: 16),

                      DropdownButtonFormField<String>(
                        value: selectedCountry,
                        decoration: const InputDecoration(
                          labelText: 'Country',
                          prefixIcon: Icon(Icons.public),
                        ),
                        items: countries.map((country) {
                          return DropdownMenuItem(
                            value: country,
                            child: Text(country),
                          );
                        }).toList(),
                        onChanged: (value) {
                          setState(() {
                            selectedCountry = value;
                          });
                        },
                        validator: (value) {
                          if (value == null) {
                            return 'Please select your country';
                          }

                          return null;
                        },
                      ),
                    ],

                    const SizedBox(height: 28),

                    FilledButton(
                      onPressed: isLoading ? null : submitForm,
                      style: FilledButton.styleFrom(
                        backgroundColor: isLogin
                            ? Appcolors.navyColor
                            : Appcolors.burgundyColor,
                      ),
                      child: isLoading
                          ? const SizedBox(
                              height: 22,
                              width: 22,
                              child: CircularProgressIndicator(
                                color: Colors.white,
                                strokeWidth: 2,
                              ),
                            )
                          : Text(
                              isLogin ? 'Sign In' : 'Register',
                              style: GoogleFonts.lora(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                    ),

                    const SizedBox(height: 18),

                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          isLogin
                              ? "Don't have an account?"
                              : 'Already have an account?',
                        ),

                        TextButton(
                          onPressed: switchScreen,
                          child: Text(
                            isLogin ? 'Register' : 'Sign In',
                            style: TextStyle(
                              color: Appcolors.burgundyColor,
                              fontWeight: FontWeight.bold,
                            ),
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
      ),
    );
  }
}
