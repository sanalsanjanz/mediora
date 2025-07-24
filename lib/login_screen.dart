import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:icons_plus/icons_plus.dart';
import 'package:mediora/apis/patients/organization/organization_helper.dart';
import 'package:mediora/apis/patients/preference_controller.dart';
import 'package:mediora/organizations/doctors_landing_screen.dart';
import 'package:mediora/patients/views/patient_landing_screen.dart';
import 'package:mediora/patients/views/pharmacy_home_screen.dart';
import 'package:mediora/pharmacy/pharmacy_home.dart';
import 'package:mediora/widgets/loading_dialog.dart';
import 'package:mediora/widgets/location_picker.dart';

class MedicalLoginScreen extends StatefulWidget {
  const MedicalLoginScreen({super.key, required this.fcmTocken});
  final String fcmTocken;
  @override
  State<MedicalLoginScreen> createState() => _MedicalLoginScreenState();
}

class _MedicalLoginScreenState extends State<MedicalLoginScreen>
    with TickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _ageController = TextEditingController();
  final _genderController = TextEditingController();
  final _location = TextEditingController();
  final latCtrl = TextEditingController();
  final longCtrl = TextEditingController();

  bool _isLogin = true;
  bool _obscurePassword = true;
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  // Color scheme
  static const Color medicalBlue = Color.fromARGB(255, 35, 33, 158);
  static const Color calmTeal = Color.fromARGB(100, 35, 33, 158);
  static const Color lightBlue = Color(0xFF45B7D1);

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _nameController.dispose();
    _phoneController.dispose();
    _ageController.dispose();
    _genderController.dispose();
    _location.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        toolbarHeight: 0,
        systemOverlayStyle: SystemUiOverlayStyle(
          statusBarColor: medicalBlue.withOpacity(0.1),
        ),
      ),
      body: Container(
        height: MediaQuery.of(context).size.height,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              medicalBlue.withOpacity(0.1),
              calmTeal.withOpacity(0.1),
              lightBlue.withOpacity(0.1),
            ],
          ),
        ),
        child: Center(
          child: FadeTransition(
            opacity: _fadeAnimation,
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                children: [
                  const SizedBox(height: 40),
                  _buildHeader(),
                  const SizedBox(height: 40),
                  _buildLoginCard(),
                  const SizedBox(height: 24),

                  // _buildGuestOption(),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Column(
      children: [
        Container(
          width: 80,
          height: 80,
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [medicalBlue, calmTeal],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: medicalBlue.withOpacity(0.3),
                blurRadius: 20,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: Image.asset("assets/pharmacy_logo.png"),
        ),
        const SizedBox(height: 16),
        ShaderMask(
          shaderCallback: (bounds) => const LinearGradient(
            colors: [medicalBlue, calmTeal],
          ).createShader(bounds),
          child: const Text(
            'MEDIORA',
            style: TextStyle(
              fontSize: 32,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'Care that Connect',
          style: TextStyle(
            fontSize: 16,
            color: Colors.grey[600],
            fontWeight: FontWeight.w500,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildLoginCard() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: medicalBlue.withOpacity(0.1),
            blurRadius: 30,
            offset: const Offset(0, 15),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          children: [
            // _buildTabSwitcher(),
            const SizedBox(height: 24),
            _buildForm(),
            const SizedBox(height: 24),
            _buildSubmitButton(),
            /*  if (_isLogin) ...[ */
            const SizedBox(height: 16),
            _buildForgotPassword(),
            /*     ], */
          ],
        ),
      ),
    );
  }

  Widget _buildTabSwitcher() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Expanded(
            child: GestureDetector(
              onTap: () => setState(() => _isLogin = true),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                padding: const EdgeInsets.symmetric(vertical: 16),
                decoration: BoxDecoration(
                  gradient: _isLogin
                      ? const LinearGradient(colors: [medicalBlue, calmTeal])
                      : null,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: _isLogin
                      ? [
                          BoxShadow(
                            color: medicalBlue.withOpacity(0.3),
                            blurRadius: 10,
                            offset: const Offset(0, 4),
                          ),
                        ]
                      : null,
                ),
                child: Text(
                  'Doctor',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: _isLogin ? Colors.white : Colors.grey[600],
                    fontWeight: FontWeight.w600,
                    fontSize: 16,
                  ),
                ),
              ),
            ),
          ),
          Expanded(
            child: GestureDetector(
              onTap: () => setState(() => _isLogin = false),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                padding: const EdgeInsets.symmetric(vertical: 16),
                decoration: BoxDecoration(
                  gradient: !_isLogin
                      ? const LinearGradient(colors: [medicalBlue, calmTeal])
                      : null,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: !_isLogin
                      ? [
                          BoxShadow(
                            color: medicalBlue.withOpacity(0.3),
                            blurRadius: 10,
                            offset: const Offset(0, 4),
                          ),
                        ]
                      : null,
                ),
                child: Text(
                  'Clinic/Hostpital',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: !_isLogin ? Colors.white : Colors.grey[600],
                    fontWeight: FontWeight.w600,
                    fontSize: 16,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildForm() {
    return Form(
      key: _formKey,
      child: Column(
        children: [
          /*  if (!_isLogin) ...[
            _buildTextField(
              controller: _nameController,
              label: 'Full Name',
              icon: Icons.person_outline,
              validator: (value) {
                if (value?.isEmpty ?? true) {
                  return 'Please enter your full name';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            _buildTextField(
              controller: _phoneController,
              label: 'Phone Number',
              icon: Icons.phone_outlined,
              keyboardType: TextInputType.phone,
              validator: (value) {
                if (value?.isEmpty ?? true) {
                  return 'Please enter your phone number';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: RadioListTile<String>(
                    title: const Text('Male'),
                    value: 'Male',
                    groupValue: _genderController.text,
                    onChanged: (value) {
                      setState(() {
                        _genderController.text = value!;
                      });
                    },
                  ),
                ),
                Expanded(
                  child: RadioListTile<String>(
                    title: const Text('Female'),
                    value: 'Female',
                    groupValue: _genderController.text,
                    onChanged: (value) {
                      setState(() {
                        _genderController.text = value!;
                      });
                    },
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
          ], */
          _buildTextField(
            controller: _emailController,
            label: 'Username',
            icon: Icons.email_outlined,
            keyboardType: TextInputType.emailAddress,
            validator: (value) {
              if (value?.isEmpty ?? true) {
                return 'Please enter your username';
              }
              /* if (!RegExp(
                r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$',
              ).hasMatch(value!)) {
                return 'Please enter a valid email';
              } */
              return null;
            },
          ),
          const SizedBox(height: 16),
          /*   if (!_isLogin)
            _buildTextField(
              controller: _ageController,
              label: 'Age',
              icon: Icons.email_outlined,
              keyboardType: TextInputType.number,
              validator: (value) {
                if (value?.isEmpty ?? true) {
                  return 'Please enter your age';
                }
                /* if (!RegExp(
                r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$',
              ).hasMatch(value!)) {
                return 'Please enter a valid email';
              } */
                return null;
              },
            ),
          if (!_isLogin) const SizedBox(height: 16),
          if (!_isLogin)
            _buildTextField(
              readOnly: true,
              controller: _location,
              label: 'Location',
              icon: Icons.location_on_outlined,
              keyboardType: TextInputType.emailAddress,
              validator: (value) {
                if (value?.isEmpty ?? true) {
                  return 'Please select your location';
                }
                return null;
              },
            ), */
          const SizedBox(height: 16),
          _buildTextField(
            controller: _passwordController,
            label: 'Password',
            icon: Icons.lock_outline,
            obscureText: _obscurePassword,
            suffixIcon: IconButton(
              icon: Icon(
                _obscurePassword ? Icons.visibility_off : Icons.visibility,
                color: Colors.grey[600],
              ),
              onPressed: () =>
                  setState(() => _obscurePassword = !_obscurePassword),
            ),
            validator: (value) {
              if (value?.isEmpty ?? true) {
                return 'Please enter your password';
              }
              if (value!.length < 6) {
                return 'Password must be at least 6 characters';
              }
              return null;
            },
          ),
        ],
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    bool obscureText = false,
    bool readOnly = false,
    TextInputType? keyboardType,
    Widget? suffixIcon,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      onTap: readOnly
          ? () async {
              LocationResult location = await Navigator.of(
                context,
              ).push(MaterialPageRoute(builder: (_) => LocationPicker()));

              latCtrl.text = location.latitude.toString();
              longCtrl.text = location.longitude.toString();
              _location.text = location.locationName.toString();
            }
          : null,
      readOnly: readOnly,
      controller: controller,
      obscureText: obscureText,
      keyboardType: keyboardType,
      validator: validator,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, color: medicalBlue),
        suffixIcon: suffixIcon,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: Colors.grey[300]!),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: medicalBlue, width: 2),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: Colors.grey[300]!),
        ),
        filled: true,
        fillColor: Colors.grey[50],
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 16,
        ),
      ),
    );
  }

  Widget _buildSubmitButton() {
    return Container(
      width: double.infinity,
      height: 50,
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [medicalBlue, calmTeal],
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: medicalBlue.withOpacity(0.3),
            blurRadius: 15,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: ElevatedButton(
        onPressed: _handleSubmit,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.transparent,
          shadowColor: Colors.transparent,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              _isLogin ? 'Login' : 'Login',
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: Colors.white,
              ),
            ),
            const SizedBox(width: 8),
            const Icon(Icons.arrow_forward, color: Colors.white, size: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildForgotPassword() {
    return TextButton(
      onPressed: () {
        // Handle forgot password
      },
      child: Text(
        'Forgot Password?',
        style: TextStyle(color: medicalBlue, fontWeight: FontWeight.w500),
      ),
    );
  }

  Widget _buildGuestOption() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: lightBlue.withOpacity(0.3)),
        boxShadow: [
          BoxShadow(
            color: lightBlue.withOpacity(0.1),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        children: [
          Icon(Icons.person_outline, color: lightBlue, size: 32),
          const SizedBox(height: 12),
          const Text(
            'Continue as Guest',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Browse services • View information\nLogin required for booking',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[600],
              height: 1.4,
            ),
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            height: 48,
            child: OutlinedButton(
              onPressed: _handleGuestContinue,
              style: OutlinedButton.styleFrom(
                side: BorderSide(color: lightBlue, width: 2),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: Text(
                'Continue',
                style: TextStyle(
                  color: lightBlue,
                  fontWeight: FontWeight.w600,
                  fontSize: 16,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _handleSubmit() async {
    if (_formKey.currentState?.validate() ?? false) {
      // Handle login/signup

      /*  if (_isLogin) { */
      (bool, String) res = await OrganizationHelper.loginPharmacy(
        userName: _emailController.text.trim(),
        password: _passwordController.text.trim(),
        fcm: widget.fcmTocken.trim(),
        isDoctor: _isLogin,
        context: context,
      );

      if (res.$1) {
        // Navigate to main app
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(
            builder: (c) =>
                PharmacyHome(pharmacy: PatientController.pharmacyModel!),
          ),
          (_) => false,
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(res.$2),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
      /*  } else {
        final fcmnew = await NotificationService.getFcmToken();
        (bool, String) res = await ApiHelpers.signupPatient(
          details: {
            "username": _emailController.text,
            "password": _passwordController.text.trim(),
            "name": _nameController.text.trim(),
            "age": _ageController.text.trim(),
            "gender": _genderController.text.trim(),
            "mobile": _phoneController.text.trim(),
            "lat": latCtrl.text.trim(),
            "lon": longCtrl.text.trim(),
            "location": _location.text.trim(),
            "fcm_token": fcmnew ?? "".trim(),
          },

          /* userName: _emailController.text.trim(),
          password: _passwordController.text.trim(), */
        );

        if (res.$1) {
          // Navigate to main app
          Navigator.of(
            context,
          ).push(MaterialPageRoute(builder: (c) => PatientLandingScreen()));
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(res.$2),
              backgroundColor: Colors.red,
              behavior: SnackBarBehavior.floating,
            ),
          );
        }
      } */
    }
  }

  void _handleGuestContinue() {
    loadingDialogue(context);
    // Navigate to main app with limited access
    Future.delayed(Duration(seconds: 3), () {
      Navigator.of(
        context,
      ).push(MaterialPageRoute(builder: (c) => PatientLandingScreen()));
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text(
          'Continuing as guest. Login required for booking services.',
        ),
        backgroundColor: lightBlue,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }
}
