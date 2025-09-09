import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:skoring/models/introduction.dart';
import 'package:skoring/screens/introduction/swipeup.dart';
import 'package:skoring/screens/kaprog/student.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class IntroductionScreen extends StatefulWidget {
  const IntroductionScreen({super.key});

  @override
  State<IntroductionScreen> createState() => _IntroductionScreenState();
}

class _IntroductionScreenState extends State<IntroductionScreen>
    with TickerProviderStateMixin {
  late final AnimationController _animationController;
  late final AnimationController _swipeController;
  late final AnimationController _loginController;
  late final Animation<double> _fadeAnimation;
  late final Animation<Offset> _slideAnimation;
  late final Animation<double> _scaleAnimation;
  late final Animation<double> _swipeAnimation;
  late final Animation<Offset> _loginSlideAnimation;
  late final Animation<double> _loginFadeAnimation;
  final PageController _pageController = PageController();
  int _currentPage = 0;
  double _swipeOffset = 0.0;
  bool _showLoginOverlay = false;

  final List<PageData> _pages = [
    PageData(
      image: 'assets/batang.png',
      title: 'Selamat Datang di Sistem Skoring!',
      description:
          'Kelola pencatatan, penilaian, hingga laporan dalam satu aplikasi praktis.Nikmati kemudahan mengelola penilaian secara cepat.',
    ),
    PageData(
      image: 'assets/lingkaran.png',
      title: 'Penilaian Lebih Cepat & Akurat',
      description:
          'Tidak perlu hitung manual. Sistem kami memproses penilaian secara otomatis dan real-time.',
    ),
    PageData(
      image: 'assets/apk.png',
      title: 'Laporan Lengkap di Ujung Jari',
      description:
          'Pantau perkembangan, pelanggaran, dan apresiasi siswa melalui laporan interaktif yang mudah dibaca.',
    ),
    PageData(
      image: 'assets/backpack.png',
      title: 'Sikapin Sebelas',
      description:
          'Siap untuk mulai?\nGeser ke atas untuk masuk ke sistem dan kelola penilaian siswa dengan mudah!',
    ),
  ];

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
    _pageController.addListener(_updateCurrentPage);
    _animationController.forward();
  }

  void _initializeAnimations() {
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );
    _swipeController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _loginController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.5),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeOutBack),
    );
    _scaleAnimation = Tween<double>(begin: 0.8, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeOutCubic),
    );
    _swipeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _swipeController, curve: Curves.easeOut));
    _loginSlideAnimation = Tween<Offset>(
      begin: const Offset(0, 1),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(parent: _loginController, curve: Curves.easeOutCubic),
    );
    _loginFadeAnimation = Tween<double>(begin: 0.0, end: 0.5).animate(
      CurvedAnimation(parent: _loginController, curve: Curves.easeInOut),
    );
  }

  void _updateCurrentPage() {
    setState(() {
      _currentPage = _pageController.page?.round() ?? 0;
    });
  }

  @override
  void dispose() {
    _animationController.dispose();
    _swipeController.dispose();
    _loginController.dispose();
    _pageController.dispose();
    super.dispose();
  }

  void _nextPage() {
    if (_currentPage < _pages.length - 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  void _skipToFinalPage() {
    _pageController.animateToPage(
      _pages.length - 1,
      duration: const Duration(milliseconds: 500),
      curve: Curves.easeInOut,
    );
  }

  void _showLogin() {
    setState(() => _showLoginOverlay = true);
    _loginController.forward();
  }

  void _hideLogin() {
    _loginController.reverse().then((_) {
      setState(() => _showLoginOverlay = false);
    });
  }

  void _onPanUpdate(DragUpdateDetails details) {
    setState(() {
      _swipeOffset += details.delta.dy;
      _swipeOffset = _swipeOffset.clamp(-100.0, 0.0);
    });
  }

  void _onPanEnd(DragEndDetails details) {
    if (_swipeOffset < -50) {
      _swipeController.forward().then((_) {
        _showLogin();
        _swipeController.reset();
        setState(() => _swipeOffset = 0.0);
      });
    } else {
      _swipeController.reverse();
      setState(() => _swipeOffset = 0.0);
    }
  }

  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.dark,
        statusBarBrightness: Brightness.light,
      ),
    );

    return Scaffold(
      backgroundColor:
          _currentPage == _pages.length - 1
              ? const Color(0xFF1E6BB8)
              : Colors.white,
      body: SafeArea(
        top: false,
        child: Stack(
          children: [
            Column(
              children: [
                Expanded(
                  child: PageView.builder(
                    controller: _pageController,
                    itemCount: _pages.length,
                    itemBuilder:
                        (context, index) =>
                            index == _pages.length - 1
                                ? _FinalPage(
                                  pageData: _pages[index],
                                  scaleAnimation: _scaleAnimation,
                                  fadeAnimation: _fadeAnimation,
                                  swipeAnimation: _swipeAnimation,
                                  swipeOffset: _swipeOffset,
                                  onPanUpdate: _onPanUpdate,
                                  onPanEnd: _onPanEnd,
                                )
                                : _RegularPage(
                                  pageData: _pages[index],
                                  fadeAnimation: _fadeAnimation,
                                  slideAnimation: _slideAnimation,
                                  scaleAnimation: _scaleAnimation,
                                ),
                  ),
                ),
                if (_currentPage != _pages.length - 1)
                  _BottomNavigation(
                    currentPage: _currentPage,
                    pagesLength: _pages.length,
                    onNext: _nextPage,
                  ),
              ],
            ),
            if (_currentPage != _pages.length - 1)
              _SkipButton(onSkip: _skipToFinalPage),
            if (_showLoginOverlay)
              _LoginOverlay(
                loginController: _loginController,
                loginFadeAnimation: _loginFadeAnimation,
                loginSlideAnimation: _loginSlideAnimation,
                onClose: _hideLogin,
                onLogin: () {},
              ),
          ],
        ),
      ),
    );
  }
}

class _RegularPage extends StatelessWidget {
  final PageData pageData;
  final Animation<double> fadeAnimation;
  final Animation<Offset> slideAnimation;
  final Animation<double> scaleAnimation;

  const _RegularPage({
    required this.pageData,
    required this.fadeAnimation,
    required this.slideAnimation,
    required this.scaleAnimation,
  });

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;
    final isWeb = screenWidth > 800;

    return FadeTransition(
      opacity: fadeAnimation,
      child: SlideTransition(
        position: slideAnimation,
        child: LayoutBuilder(
          builder: (context, constraints) {
            return SingleChildScrollView(
              child: ConstrainedBox(
                constraints: BoxConstraints(minHeight: constraints.maxHeight),
                child: Container(
                  padding: EdgeInsets.fromLTRB(
                    isWeb ? screenWidth * 0.1 : 24.0,
                    MediaQuery.of(context).padding.top + 20,
                    isWeb ? screenWidth * 0.1 : 24.0,
                    24.0,
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      SizedBox(height: screenHeight * 0.05),
                      ScaleTransition(
                        scale: scaleAnimation,
                        child: _LayeredImage(
                          image: pageData.image!,
                          size: isWeb ? 400 : screenWidth * 0.85,
                        ),
                      ),
                      SizedBox(height: isWeb ? 60 : 40),
                      Text(
                        pageData.title,
                        style: GoogleFonts.poppins(
                          fontSize: isWeb ? 32 : screenWidth * 0.07,
                          fontWeight: FontWeight.w700,
                          color: const Color(0xFF1F2937),
                          height: 1.2,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      SizedBox(height: isWeb ? 24 : 16),
                      _DescriptionBox(
                        description: pageData.description,
                        isWeb: isWeb,
                        screenWidth: screenWidth,
                      ),
                      SizedBox(height: screenHeight * 0.05),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

class _FinalPage extends StatelessWidget {
  final PageData pageData;
  final Animation<double> scaleAnimation;
  final Animation<double> fadeAnimation;
  final Animation<double> swipeAnimation;
  final double swipeOffset;
  final Function(DragUpdateDetails) onPanUpdate;
  final Function(DragEndDetails) onPanEnd;

  const _FinalPage({
    required this.pageData,
    required this.scaleAnimation,
    required this.fadeAnimation,
    required this.swipeAnimation,
    required this.swipeOffset,
    required this.onPanUpdate,
    required this.onPanEnd,
  });

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;
    final isWeb = screenWidth > 800;

    return Container(
      decoration: const BoxDecoration(
        gradient: RadialGradient(
          center: Alignment.center,
          radius: 1.0,
          colors: [Color(0xFF4A90E2), Color(0xFF1E6BB8), Color(0xFF0F4A8C)],
          stops: [0.3, 0.7, 1.0],
        ),
      ),
      child: LayoutBuilder(
        builder: (context, constraints) {
          return SingleChildScrollView(
            child: ConstrainedBox(
              constraints: BoxConstraints(minHeight: constraints.maxHeight),
              child: Container(
                padding: EdgeInsets.fromLTRB(
                  isWeb ? screenWidth * 0.1 : 24.0,
                  MediaQuery.of(context).padding.top + 20,
                  isWeb ? screenWidth * 0.1 : 24.0,
                  24.0,
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    SizedBox(height: screenHeight * 0.05),
                    ScaleTransition(
                      scale: scaleAnimation,
                      child: _LayeredImage(
                        image: pageData.image!,
                        size: isWeb ? 400 : screenWidth * 0.85,
                      ),
                    ),
                    SizedBox(height: isWeb ? 60 : 40),
                    FadeTransition(
                      opacity: fadeAnimation,
                      child: Text(
                        pageData.title,
                        style: GoogleFonts.poppins(
                          fontSize: isWeb ? 36 : screenWidth * 0.08,
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                          height: 1.2,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                    SizedBox(height: isWeb ? 32 : 20),
                    FadeTransition(
                      opacity: fadeAnimation,
                      child: Container(
                        constraints: BoxConstraints(
                          maxWidth: isWeb ? 600 : double.infinity,
                        ),
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        child: Text(
                          pageData.description,
                          style: GoogleFonts.poppins(
                            fontSize: isWeb ? 18 : 16,
                            fontWeight: FontWeight.w400,
                            color: Colors.white.withOpacity(0.8),
                            height: 1.5,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ),
                    SizedBox(height: isWeb ? 80 : 60),
                    SwipeUpButton(
                      swipeOffset: swipeOffset,
                      swipeAnimation: swipeAnimation,
                      onPanUpdate: onPanUpdate,
                      onPanEnd: onPanEnd,
                    ),
                    SizedBox(height: screenHeight * 0.05),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

class _LayeredImage extends StatelessWidget {
  final String image;
  final double size;

  const _LayeredImage({required this.image, required this.size});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: Colors.white.withOpacity(0.15),
      ),
      child: Container(
        margin: EdgeInsets.all(size * 0.07),
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: Colors.white.withOpacity(0.2),
        ),
        child: Container(
          margin: EdgeInsets.all(size * 0.07),
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: Colors.white.withOpacity(0.25),
          ),
          child: Center(
            child: Image.asset(
              image,
              width: size * 0.6,
              height: size * 0.6,
              fit: BoxFit.contain,
            ),
          ),
        ),
      ),
    );
  }
}

class _DescriptionBox extends StatelessWidget {
  final String description;
  final bool isWeb;
  final double screenWidth;

  const _DescriptionBox({
    required this.description,
    required this.isWeb,
    required this.screenWidth,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: BoxConstraints(maxWidth: isWeb ? 600 : double.infinity),
      padding: EdgeInsets.symmetric(
        horizontal: isWeb ? 32 : 20,
        vertical: isWeb ? 20 : 14,
      ),
      decoration: BoxDecoration(
        color: const Color(0xFF61B8FF).withOpacity(0.1),
        borderRadius: BorderRadius.circular(25),
        border: Border.all(
          color: const Color(0xFF61B8FF).withOpacity(0.2),
          width: 1,
        ),
      ),
      child: Text(
        description,
        style: GoogleFonts.poppins(
          fontSize: isWeb ? 18 : 16,
          fontWeight: FontWeight.w400,
          color: const Color(0xFF6B7280),
        ),
        textAlign: TextAlign.center,
      ),
    );
  }
}

class _BottomNavigation extends StatelessWidget {
  final int currentPage;
  final int pagesLength;
  final VoidCallback onNext;

  const _BottomNavigation({
    required this.currentPage,
    required this.pagesLength,
    required this.onNext,
  });

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isWeb = screenWidth > 800;

    return Container(
      padding: EdgeInsets.all(isWeb ? 40.0 : 24.0),
      constraints: BoxConstraints(maxWidth: isWeb ? 400 : double.infinity),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(pagesLength, (index) {
              return AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                margin: const EdgeInsets.symmetric(horizontal: 4),
                width: currentPage == index ? 12 : 8,
                height: 8,
                decoration: BoxDecoration(
                  color:
                      currentPage == index
                          ? const Color(0xFF0083EE)
                          : const Color(0xFF9CA3AF),
                  borderRadius: BorderRadius.circular(4),
                ),
              );
            }),
          ),
          SizedBox(height: isWeb ? 32 : 24),
          _GradientButton(text: 'Lanjut', onTap: onNext, isWeb: isWeb),
        ],
      ),
    );
  }
}

class _SkipButton extends StatelessWidget {
  final VoidCallback onSkip;

  const _SkipButton({required this.onSkip});

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isWeb = screenWidth > 800;

    return Positioned(
      top: MediaQuery.of(context).padding.top + (isWeb ? 24 : 16),
      right: isWeb ? 40 : 16,
      child: GestureDetector(
        onTap: onSkip,
        child: Container(
          padding: EdgeInsets.symmetric(
            horizontal: isWeb ? 20 : 16,
            vertical: isWeb ? 12 : 8,
          ),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: const Color(0xFF61B8FF).withOpacity(0.2),
              width: 1,
            ),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF0083EE).withOpacity(0.1),
                blurRadius: 10,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Text(
            'Skip',
            style: GoogleFonts.poppins(
              fontSize: isWeb ? 16 : 14,
              fontWeight: FontWeight.w500,
              color: const Color(0xFF0083EE),
            ),
          ),
        ),
      ),
    );
  }
}

class _LoginOverlay extends StatelessWidget {
  final AnimationController loginController;
  final Animation<double> loginFadeAnimation;
  final Animation<Offset> loginSlideAnimation;
  final VoidCallback onClose;
  final VoidCallback onLogin;

  const _LoginOverlay({
    required this.loginController,
    required this.loginFadeAnimation,
    required this.loginSlideAnimation,
    required this.onClose,
    required this.onLogin,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: loginController,
      builder: (context, child) {
        return Stack(
          children: [
            FadeTransition(
              opacity: loginFadeAnimation,
              child: GestureDetector(
                onTap: onClose,
                child: Container(
                  width: double.infinity,
                  height: double.infinity,
                  color: Colors.black,
                ),
              ),
            ),
            SlideTransition(
              position: loginSlideAnimation,
              child: Align(
                alignment: Alignment.bottomCenter,
                child: _LoginForm(onClose: onClose, onLogin: onLogin),
              ),
            ),
          ],
        );
      },
    );
  }
}

class _LoginForm extends StatefulWidget {
  final VoidCallback onClose;
  final VoidCallback onLogin;

  const _LoginForm({required this.onClose, required this.onLogin});

  @override
  State<_LoginForm> createState() => _LoginFormState();
}

class _LoginFormState extends State<_LoginForm> {
  final TextEditingController _nipController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _isPasswordVisible = false;

  void _showSnackBar(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
  }

  void _handleLogin() async {
    String nip = _nipController.text.trim();
    String password = _passwordController.text.trim();

    if (nip.isEmpty || password.isEmpty) {
      _showSnackBar(context, "Harap isi NIP dan password");
      return;
    }

    try {
      final response = await http.post(
        Uri.parse("http://10.0.2.2:8000/api/login"),
        body: {"nip": nip, "password": password},
      );

      final data = jsonDecode(response.body);

      if (response.statusCode == 200 && data['status'] == true) {
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('walikelas_id', data['detail']['nip_walikelas'].toString());
        await prefs.setString('role', data['role'].toString());
        await prefs.setString('name', data['detail']['nama_walikelas'] ?? data['user']['username']);
        await prefs.setString('email', data['user']['email'] ?? 'Unknown');
        await prefs.setString('phone', 'Unknown'); // API doesn't provide phone, so default to 'Unknown'
        await prefs.setString('joinDate', data['detail']['created_at'] ?? 'Unknown');
        await prefs.setString('id_kelas', data['detail']['id_kelas'] ?? 'Unknown');

        String role = data['role'].toString();

        if (role == '3') {
          Navigator.pushNamed(context, '/walikelas');
        } else if (role == '4') {
          Navigator.pushNamed(context, '/kaprog');
        } else {
          _showSnackBar(context, "Role tidak dikenali");
        }
      } else {
        _showSnackBar(context, data['message'] ?? 'Login gagal');
      }
    } catch (e) {
      _showSnackBar(context, "Terjadi kesalahan: $e");
    }

    widget.onLogin();
  }

  @override
  void dispose() {
    _nipController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    final isWeb = screenWidth > 800;

    return Container(
      width: double.infinity,
      constraints: BoxConstraints(
        maxWidth: isWeb ? 500 : double.infinity,
        maxHeight: screenHeight * 0.85,
      ),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(30),
          topRight: Radius.circular(30),
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _HandleBar(onTap: widget.onClose),
          Expanded(
            child: SingleChildScrollView(
              padding: EdgeInsets.all(isWeb ? 32.0 : 24.0),
              child: Column(
                children: [
                  SizedBox(height: isWeb ? 32 : 20),
                  _LoginHeader(isWeb: isWeb),
                  SizedBox(height: isWeb ? 48 : 40),
                  _LoginTextField(
                    hintText: 'Masukkan NIP anda',
                    icon: Icons.person_outline,
                    controller: _nipController,
                    isWeb: isWeb,
                  ),
                  SizedBox(height: isWeb ? 24 : 20),
                  _LoginTextField(
                    hintText: 'Masukkan password anda',
                    icon: Icons.lock_outline,
                    obscureText: !_isPasswordVisible,
                    suffixIcon: _isPasswordVisible ? Icons.visibility_outlined : Icons.visibility_off_outlined,
                    controller: _passwordController,
                    isWeb: isWeb,
                    onSuffixIconTap: () {
                      setState(() {
                        _isPasswordVisible = !_isPasswordVisible;
                      });
                    },
                  ),
                  SizedBox(height: isWeb ? 40 : 30),
                  _GradientButton(
                    text: 'Login',
                    onTap: _handleLogin,
                    isWeb: isWeb,
                  ),
                  SizedBox(height: isWeb ? 24 : 20),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
class _HandleBar extends StatelessWidget {
  final VoidCallback onTap;

  const _HandleBar({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        child: Container(
          width: 50,
          height: 4,
          decoration: BoxDecoration(
            color: Colors.grey[300],
            borderRadius: BorderRadius.circular(2),
          ),
        ),
      ),
    );
  }
}

class _LoginHeader extends StatelessWidget {
  final bool isWeb;

  const _LoginHeader({required this.isWeb});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(isWeb ? 24.0 : 20.0),
      child: Row(
        children: [
          Container(
            width: isWeb ? 120 : 100,
            height: isWeb ? 120 : 100,
            decoration: BoxDecoration(
              color: Colors.grey[100],
              borderRadius: BorderRadius.circular(15),
            ),
            child: Padding(
              padding: const EdgeInsets.all(12.0),
              child: Image.asset('assets/smkn.png', fit: BoxFit.contain),
            ),
          ),
          SizedBox(width: isWeb ? 24 : 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Selamat Datang Kembali',
                  style: GoogleFonts.poppins(
                    fontSize: isWeb ? 26 : 22,
                    fontWeight: FontWeight.w700,
                    color: const Color(0xFF1F2937),
                  ),
                ),
                SizedBox(height: isWeb ? 12 : 8),
                Text(
                  'Yuk, lanjutkan aktivitasmu di Aplikasi Sikapin!',
                  style: GoogleFonts.poppins(
                    fontSize: isWeb ? 16 : 13,
                    fontWeight: FontWeight.w400,
                    color: const Color(0xFF6B7280),
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _LoginTextField extends StatelessWidget {
  final String hintText;
  final IconData icon;
  final bool obscureText;
  final IconData? suffixIcon;
  final TextEditingController? controller;
  final bool isWeb;
  final VoidCallback? onSuffixIconTap;

  const _LoginTextField({
    required this.hintText,
    required this.icon,
    this.obscureText = false,
    this.suffixIcon,
    this.controller,
    required this.isWeb,
    this.onSuffixIconTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: Colors.grey[200]!, width: 1),
      ),
      child: TextField(
        controller: controller,
        obscureText: obscureText,
        decoration: InputDecoration(
          hintText: hintText,
          hintStyle: GoogleFonts.poppins(
            fontSize: isWeb ? 16 : 14,
            color: Colors.grey[500],
          ),
          prefixIcon: Icon(icon, color: Colors.grey[400]),
          suffixIcon:
              suffixIcon != null
                  ? GestureDetector(
                    onTap: onSuffixIconTap,
                    child: Icon(suffixIcon, color: Colors.grey[400]),
                  )
                  : null,
          border: InputBorder.none,
          contentPadding: EdgeInsets.symmetric(
            horizontal: 16,
            vertical: isWeb ? 20 : 16,
          ),
        ),
      ),
    );
  }
}

class _GradientButton extends StatelessWidget {
  final String text;
  final VoidCallback onTap;
  final bool isWeb;

  const _GradientButton({
    required this.text,
    required this.onTap,
    required this.isWeb,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: EdgeInsets.symmetric(vertical: isWeb ? 20 : 18),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Color(0xFF61B8FF), Color(0xFF0083EE)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(15),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF0083EE).withOpacity(0.3),
              blurRadius: 15,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: Text(
          text,
          style: GoogleFonts.poppins(
            fontSize: isWeb ? 20 : 18,
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
          textAlign: TextAlign.center,
        ),
      ),
    );
  }
}
