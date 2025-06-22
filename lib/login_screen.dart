import 'package:flutter/material.dart';

class MedioraLoginScreen extends StatefulWidget {
  const MedioraLoginScreen({Key? key}) : super(key: key);

  @override
  State<MedioraLoginScreen> createState() => _MedioraLoginScreenState();
}

class _MedioraLoginScreenState extends State<MedioraLoginScreen>
    with TickerProviderStateMixin {
  late AnimationController _animationController;
  late AnimationController _floatingController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _floatingAnimation;

  int _selectedUserType = 0;
  bool _isLoginMode = true;
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _nameController = TextEditingController();
  bool _obscurePassword = true;

  final List<UserType> _userTypes = [
    UserType(
      title: 'Patient',
      icon: Icons.person_rounded,
      description: 'Book appointments & manage health',
      gradient: [Color(0xFF3CB8B8), Color(0xFF2A9D8F)],
      canSignUp: true,
    ),
    UserType(
      title: 'Doctor',
      icon: Icons.medical_services_rounded,
      description: 'Manage practice & patients',
      gradient: [Color(0xFF457B9D), Color(0xFF1D3557)],
      canSignUp: false,
    ),
    UserType(
      title: 'Hospital',
      icon: Icons.local_hospital_rounded,
      description: 'Healthcare facility management',
      gradient: [Color(0xFF8B5CF6), Color(0xFF7C3AED)],
      canSignUp: false,
    ),
    UserType(
      title: 'Pharmacy',
      icon: Icons.local_pharmacy_rounded,
      description: 'Medication & supply services',
      gradient: [Color(0xFFE11D48), Color(0xBE123C)],
      canSignUp: false,
    ),
  ];

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );

    _floatingController = AnimationController(
      duration: const Duration(milliseconds: 3000),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );

    _slideAnimation =
        Tween<Offset>(begin: const Offset(0, 0.5), end: Offset.zero).animate(
          CurvedAnimation(
            parent: _animationController,
            curve: Curves.easeOutCubic,
          ),
        );

    _floatingAnimation = Tween<double>(begin: 0.0, end: 10.0).animate(
      CurvedAnimation(parent: _floatingController, curve: Curves.easeInOut),
    );

    _animationController.forward();
    _floatingController.repeat(reverse: true);
  }

  @override
  void dispose() {
    _animationController.dispose();
    _floatingController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _nameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final isTablet = size.shortestSide >= 600;

    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment(-0.5, -1.0),
            end: Alignment(0.5, 1.0),
            colors: [Color(0xFF3CB8B8), Color(0xFF2A9D8F), Color(0xFF333F48)],
            stops: [0.0, 0.6, 1.0],
          ),
        ),
        child: Stack(
          children: [
            // Floating background elements
            _buildFloatingElements(),

            // Main content
            SafeArea(
              child: FadeTransition(
                opacity: _fadeAnimation,
                child: SlideTransition(
                  position: _slideAnimation,
                  child: SingleChildScrollView(
                    padding: EdgeInsets.symmetric(
                      horizontal: isTablet ? 40 : 20,
                      vertical: 20,
                    ),
                    child: Column(
                      children: [
                        // Header with modern styling
                        _buildModernHeader(isTablet),

                        SizedBox(height: isTablet ? 40 : 30),

                        // Glass morphism card
                        _buildGlassMorphismCard(isTablet),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFloatingElements() {
    return AnimatedBuilder(
      animation: _floatingAnimation,
      builder: (context, child) {
        return Stack(
          children: [
            Positioned(
              top: 100 + _floatingAnimation.value,
              right: 30,
              child: Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
              ),
            ),
            Positioned(
              top: 200 - _floatingAnimation.value,
              left: 20,
              child: Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.08),
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
            Positioned(
              bottom: 150 + _floatingAnimation.value,
              right: 50,
              child: Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.06),
                  shape: BoxShape.circle,
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildModernHeader(bool isTablet) {
    return Column(
      children: [
        SizedBox(height: isTablet ? 30 : 20),
        Container(
          width: isTablet ? 100 : 80,
          height: isTablet ? 100 : 80,
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Colors.white, Color(0xFFF8F9FA)],
            ),
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 20,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: Icon(
            Icons.favorite_rounded,
            size: isTablet ? 50 : 40,
            color: const Color(0xFF3CB8B8),
          ),
        ),
        SizedBox(height: isTablet ? 20 : 16),
        Text(
          'MEDIORA',
          style: TextStyle(
            fontSize: isTablet ? 36 : 28,
            fontWeight: FontWeight.w300,
            color: Colors.white,
            letterSpacing: 4.0,
          ),
        ),
        SizedBox(height: isTablet ? 8 : 6),
        Text(
          'Care that connects',
          style: TextStyle(
            fontSize: isTablet ? 16 : 14,
            color: Colors.white.withOpacity(0.8),
            letterSpacing: 1.5,
            fontWeight: FontWeight.w300,
          ),
        ),
      ],
    );
  }

  Widget _buildGlassMorphismCard(bool isTablet) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.15),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.white.withOpacity(0.2), width: 1),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 30,
            offset: const Offset(0, 15),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(24),
        child: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Colors.white.withOpacity(0.2),
                Colors.white.withOpacity(0.1),
              ],
            ),
          ),
          child: Padding(
            padding: EdgeInsets.all(isTablet ? 32 : 24),
            child: Column(
              children: [
                // User type selection with modern cards
                _buildModernUserTypeSelection(isTablet),

                SizedBox(height: isTablet ? 32 : 24),

                // Dynamic tab selector
                _buildDynamicTabSelector(isTablet),

                SizedBox(height: isTablet ? 32 : 24),

                // Form with modern styling
                _buildModernForm(isTablet),

                SizedBox(height: isTablet ? 32 : 24),

                // Action buttons with gradient
                _buildGradientActionButtons(isTablet),

                SizedBox(height: isTablet ? 24 : 20),

                // Modern divider
                _buildModernDivider(),

                SizedBox(height: isTablet ? 24 : 20),

                // Google sign in with modern styling
                _buildModernGoogleSignIn(isTablet),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildModernUserTypeSelection(bool isTablet) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Select your role',
          style: TextStyle(
            fontSize: isTablet ? 20 : 18,
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),
        SizedBox(height: isTablet ? 20 : 16),
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            crossAxisSpacing: 16,
            mainAxisSpacing: 16,
            childAspectRatio: isTablet ? 1.4 : 1.2,
          ),
          itemCount: _userTypes.length,
          itemBuilder: (context, index) {
            final userType = _userTypes[index];
            final isSelected = _selectedUserType == index;

            return GestureDetector(
              onTap: () {
                setState(() {
                  _selectedUserType = index;
                  // If selecting non-patient and in signup mode, switch to login
                  if (!userType.canSignUp && !_isLoginMode) {
                    _isLoginMode = true;
                  }
                });
              },
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                curve: Curves.easeInOut,
                decoration: BoxDecoration(
                  gradient: isSelected
                      ? LinearGradient(colors: userType.gradient)
                      : LinearGradient(
                          colors: [
                            Colors.white.withOpacity(0.1),
                            Colors.white.withOpacity(0.05),
                          ],
                        ),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: isSelected
                        ? Colors.white.withOpacity(0.3)
                        : Colors.white.withOpacity(0.1),
                    width: isSelected ? 2 : 1,
                  ),
                  boxShadow: isSelected
                      ? [
                          BoxShadow(
                            color: userType.gradient[0].withOpacity(0.3),
                            blurRadius: 15,
                            offset: const Offset(0, 8),
                          ),
                        ]
                      : null,
                ),
                padding: EdgeInsets.all(isTablet ? 20 : 16),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      userType.icon,
                      size: isTablet ? 32 : 28,
                      color: Colors.white,
                    ),
                    SizedBox(height: isTablet ? 12 : 8),
                    Text(
                      userType.title,
                      style: TextStyle(
                        fontSize: isTablet ? 16 : 14,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    if (!userType.canSignUp) ...[
                      SizedBox(height: 4),
                      Text(
                        'Login only',
                        style: TextStyle(
                          fontSize: isTablet ? 12 : 10,
                          color: Colors.white.withOpacity(0.7),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            );
          },
        ),
      ],
    );
  }

  Widget _buildDynamicTabSelector(bool isTablet) {
    final canSignUp = _userTypes[_selectedUserType].canSignUp;

    if (!canSignUp) {
      return Container(
        width: double.infinity,
        padding: EdgeInsets.symmetric(vertical: isTablet ? 16 : 12),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Color(0xFF3CB8B8), Color(0xFF2A9D8F)],
          ),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Text(
          'Login',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: isTablet ? 18 : 16,
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),
      );
    }

    return Container(
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withOpacity(0.2)),
      ),
      child: Row(
        children: [
          Expanded(
            child: GestureDetector(
              onTap: () => setState(() => _isLoginMode = true),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                padding: EdgeInsets.symmetric(vertical: isTablet ? 16 : 12),
                decoration: BoxDecoration(
                  gradient: _isLoginMode
                      ? const LinearGradient(
                          colors: [Color(0xFF3CB8B8), Color(0xFF2A9D8F)],
                        )
                      : null,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Text(
                  'Login',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: isTablet ? 16 : 14,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ),
          Expanded(
            child: GestureDetector(
              onTap: () => setState(() => _isLoginMode = false),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                padding: EdgeInsets.symmetric(vertical: isTablet ? 16 : 12),
                decoration: BoxDecoration(
                  gradient: !_isLoginMode
                      ? const LinearGradient(
                          colors: [Color(0xFF3CB8B8), Color(0xFF2A9D8F)],
                        )
                      : null,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Text(
                  'Sign Up',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: isTablet ? 16 : 14,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildModernForm(bool isTablet) {
    return Form(
      key: _formKey,
      child: Column(
        children: [
          if (!_isLoginMode) ...[
            _buildModernTextField(
              controller: _nameController,
              label: 'Full Name',
              icon: Icons.person_outline_rounded,
              isTablet: isTablet,
            ),
            SizedBox(height: isTablet ? 20 : 16),
          ],
          _buildModernTextField(
            controller: _emailController,
            label: 'Email',
            icon: Icons.email_outlined,
            keyboardType: TextInputType.emailAddress,
            isTablet: isTablet,
          ),
          SizedBox(height: isTablet ? 20 : 16),
          _buildModernTextField(
            controller: _passwordController,
            label: 'Password',
            icon: Icons.lock_outline_rounded,
            obscureText: _obscurePassword,
            isTablet: isTablet,
            suffixIcon: IconButton(
              icon: Icon(
                _obscurePassword
                    ? Icons.visibility_off_rounded
                    : Icons.visibility_rounded,
                color: Colors.white.withOpacity(0.7),
              ),
              onPressed: () =>
                  setState(() => _obscurePassword = !_obscurePassword),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildModernTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    required bool isTablet,
    TextInputType? keyboardType,
    bool obscureText = false,
    Widget? suffixIcon,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withOpacity(0.2)),
      ),
      child: TextFormField(
        controller: controller,
        keyboardType: keyboardType,
        obscureText: obscureText,
        style: TextStyle(fontSize: isTablet ? 16 : 14, color: Colors.white),
        decoration: InputDecoration(
          labelText: label,
          labelStyle: TextStyle(color: Colors.white.withOpacity(0.8)),
          prefixIcon: Icon(icon, color: Colors.white.withOpacity(0.8)),
          suffixIcon: suffixIcon,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide.none,
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide.none,
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide(
              color: Colors.white.withOpacity(0.5),
              width: 2,
            ),
          ),
          filled: false,
        ),
        validator: (value) {
          if (value == null || value.isEmpty) {
            return 'This field is required';
          }
          return null;
        },
      ),
    );
  }

  Widget _buildGradientActionButtons(bool isTablet) {
    return Column(
      children: [
        Container(
          width: double.infinity,
          height: isTablet ? 56 : 48,
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Color(0xFF3CB8B8), Color(0xFF2A9D8F)],
            ),
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF3CB8B8).withOpacity(0.3),
                blurRadius: 15,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: ElevatedButton(
            onPressed: () {
              if (_formKey.currentState!.validate()) {
                _handleAuthAction();
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.transparent,
              foregroundColor: Colors.white,
              shadowColor: Colors.transparent,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
            ),
            child: Text(
              _isLoginMode ? 'Login' : 'Create Account',
              style: TextStyle(
                fontSize: isTablet ? 18 : 16,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ),
        if (_isLoginMode) ...[
          SizedBox(height: isTablet ? 16 : 12),
          TextButton(
            onPressed: () {
              // Handle forgot password
            },
            child: Text(
              'Forgot Password?',
              style: TextStyle(
                color: Colors.white.withOpacity(0.8),
                fontSize: isTablet ? 16 : 14,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildModernDivider() {
    return Row(
      children: [
        Expanded(
          child: Container(
            height: 1,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Colors.transparent,
                  Colors.white.withOpacity(0.3),
                  Colors.transparent,
                ],
              ),
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Text(
            'or',
            style: TextStyle(
              color: Colors.white.withOpacity(0.7),
              fontSize: 14,
              fontWeight: FontWeight.w300,
            ),
          ),
        ),
        Expanded(
          child: Container(
            height: 1,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Colors.transparent,
                  Colors.white.withOpacity(0.3),
                  Colors.transparent,
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildModernGoogleSignIn(bool isTablet) {
    return Container(
      width: double.infinity,
      height: isTablet ? 56 : 48,
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withOpacity(0.2)),
      ),
      child: OutlinedButton.icon(
        onPressed: () {
          _handleGoogleSignIn();
        },
        icon: Container(
          width: 24,
          height: 24,
          decoration: const BoxDecoration(
            color: Colors.white,
            shape: BoxShape.circle,
          ),
          child: const Icon(
            Icons.g_mobiledata,
            color: Colors.black87,
            size: 20,
          ),
        ),
        label: Text(
          'Continue with Google',
          style: TextStyle(
            fontSize: isTablet ? 16 : 14,
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),
        style: OutlinedButton.styleFrom(
          side: BorderSide.none,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
      ),
    );
  }

  void _handleAuthAction() {
    final userType = _userTypes[_selectedUserType].title;
    final email = _emailController.text;
    final password = _passwordController.text;
    final name = _nameController.text;

    print('${_isLoginMode ? 'Login' : 'Sign up'} as $userType');
    print('Email: $email');
    print('Password: $password');
    if (!_isLoginMode) print('Name: $name');

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          '${_isLoginMode ? 'Logging in' : 'Creating account'} as $userType...',
        ),
        backgroundColor: const Color(0xFF3CB8B8),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  void _handleGoogleSignIn() {
    final userType = _userTypes[_selectedUserType].title;
    print('Google sign in as $userType');

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Signing in with Google as $userType...'),
        backgroundColor: const Color(0xFF3CB8B8),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }
}

class UserType {
  final String title;
  final IconData icon;
  final String description;
  final List<Color> gradient;
  final bool canSignUp;

  UserType({
    required this.title,
    required this.icon,
    required this.description,
    required this.gradient,
    required this.canSignUp,
  });
}
