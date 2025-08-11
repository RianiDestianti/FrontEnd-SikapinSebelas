import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:skoring/models/introduction.dart';
import 'package:skoring/screens/login.dart';

class IntroductionScreen extends StatefulWidget {
  const IntroductionScreen({Key? key}) : super(key: key);

  @override
  State<IntroductionScreen> createState() => _IntroductionScreenState();
}

class _IntroductionScreenState extends State<IntroductionScreen> with TickerProviderStateMixin {
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
      image: 'assets/apk.png',
      title: 'Selamat Datang di Aplikasi SMK',
      description: 'Kelola prestasi dan pelanggaran siswa dengan mudah dan efisien.',
    ),
    PageData(
      icon: Icons.search_rounded,
      title: 'Cari dan Monitor Siswa',
      description: 'Gunakan fitur pencarian untuk menemukan siswa berdasarkan nama atau kelas, dan pantau perkembangan mereka.',
    ),
    PageData(
      icon: Icons.admin_panel_settings_rounded,
      title: 'Pilih Peran Anda',
      description: 'Pilih peran sebagai Kepala Program Keahlian atau Wali Kelas untuk mengelola tugas sesuai kebutuhan.',
    ),
    PageData(
      image: 'assets/backpack.png',
      title: 'Learn anything\nAnytime anywhere',
      description: 'Lorem ipsum dolor sit amet, consectetur adipiscing elit. Sed euismod, nunc ut tristique luctus, nunc lorem molestie mauris.',
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
    _slideAnimation = Tween<Offset>(begin: const Offset(0, 0.5), end: Offset.zero).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeOutBack),
    );
    _scaleAnimation = Tween<double>(begin: 0.8, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeOutCubic),
    );
    _swipeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _swipeController, curve: Curves.easeOut),
    );
    _loginSlideAnimation = Tween<Offset>(begin: const Offset(0, 1), end: Offset.zero).animate(
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
    } else {
      _navigateToRoleSelection();
    }
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

  void _navigateToRoleSelection() {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => const RoleSelectionScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _currentPage == _pages.length - 1 ? const Color(0xFF1E6BB8) : const Color(0xFFF8FAFC),
      body: SafeArea(
        child: Stack(
          children: [
            Column(
              children: [
                Expanded(
                  child: PageView.builder(
                    controller: _pageController,
                    itemCount: _pages.length,
                    itemBuilder: (context, index) => index == _pages.length - 1
                        ? FinalPage(
                            pageData: _pages[index],
                            scaleAnimation: _scaleAnimation,
                            fadeAnimation: _fadeAnimation,
                            swipeAnimation: _swipeAnimation,
                            swipeOffset: _swipeOffset,
                            onPanUpdate: _onPanUpdate,
                            onPanEnd: _onPanEnd,
                          )
                        : RegularPage(
                            pageData: _pages[index],
                            fadeAnimation: _fadeAnimation,
                            slideAnimation: _slideAnimation,
                            scaleAnimation: _scaleAnimation,
                          ),
                  ),
                ),
                if (_currentPage != _pages.length - 1)
                  BottomNavigation(
                    currentPage: _currentPage,
                    pagesLength: _pages.length,
                    onNext: _nextPage,
                  ),
              ],
            ),
            if (_currentPage != _pages.length - 1)
              SkipButton(onSkip: _navigateToRoleSelection),
            if (_showLoginOverlay)
              LoginOverlay(
                loginController: _loginController,
                loginFadeAnimation: _loginFadeAnimation,
                loginSlideAnimation: _loginSlideAnimation,
                onClose: _hideLogin,
                onLogin: _navigateToRoleSelection,
              ),
          ],
        ),
      ),
    );
  }
}

class RegularPage extends StatelessWidget {
  final PageData pageData;
  final Animation<double> fadeAnimation;
  final Animation<Offset> slideAnimation;
  final Animation<double> scaleAnimation;

  const RegularPage({
    Key? key,
    required this.pageData,
    required this.fadeAnimation,
    required this.slideAnimation,
    required this.scaleAnimation,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: fadeAnimation,
      child: SlideTransition(
        position: slideAnimation,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SizedBox(height: MediaQuery.of(context).size.height * 0.1),
              ScaleTransition(
                scale: scaleAnimation,
                child: pageData.icon != null
                    ? CircleIcon(
                        icon: pageData.icon!,
                        size: 180,
                        iconSize: 90,
                      )
                    : LayeredImage(image: pageData.image!),
              ),
              const SizedBox(height: 40),
              Text(
                pageData.title,
                style: GoogleFonts.poppins(
                  fontSize: 28,
                  fontWeight: FontWeight.w700,
                  color: const Color(0xFF1F2937),
                  height: 1.2,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              DescriptionBox(description: pageData.description),
              SizedBox(height: MediaQuery.of(context).size.height * 0.1),
            ],
          ),
        ),
      ),
    );
  }
}

class FinalPage extends StatelessWidget {
  final PageData pageData;
  final Animation<double> scaleAnimation;
  final Animation<double> fadeAnimation;
  final Animation<double> swipeAnimation;
  final double swipeOffset;
  final Function(DragUpdateDetails) onPanUpdate;
  final Function(DragEndDetails) onPanEnd;

  const FinalPage({
    Key? key,
    required this.pageData,
    required this.scaleAnimation,
    required this.fadeAnimation,
    required this.swipeAnimation,
    required this.swipeOffset,
    required this.onPanUpdate,
    required this.onPanEnd,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: RadialGradient(
          center: Alignment.center,
          radius: 1.0,
          colors: [Color(0xFF4A90E2), Color(0xFF1E6BB8), Color(0xFF0F4A8C)],
          stops: [0.3, 0.7, 1.0],
        ),
      ),
      child: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SizedBox(height: MediaQuery.of(context).size.height * 0.05),
              ScaleTransition(
                scale: scaleAnimation,
                child: LayeredImage(image: pageData.image!),
              ),
              const SizedBox(height: 40),
              FadeTransition(
                opacity: fadeAnimation,
                child: Text(
                  pageData.title,
                  style: GoogleFonts.poppins(
                    fontSize: 32,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                    height: 1.2,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
              const SizedBox(height: 20),
              FadeTransition(
                opacity: fadeAnimation,
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Text(
                    pageData.description,
                    style: GoogleFonts.poppins(
                      fontSize: 16,
                      fontWeight: FontWeight.w400,
                      color: Colors.white.withOpacity(0.8),
                      height: 1.5,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
              const SizedBox(height: 60),
              SwipeUpButton(
                swipeOffset: swipeOffset,
                swipeAnimation: swipeAnimation,
                onPanUpdate: onPanUpdate,
                onPanEnd: onPanEnd,
              ),
              SizedBox(height: MediaQuery.of(context).size.height * 0.05),
            ],
          ),
        ),
      ),
    );
  }
}

class CircleIcon extends StatelessWidget {
  final IconData icon;
  final double size;
  final double iconSize;

  const CircleIcon({
    Key? key,
    required this.icon,
    required this.size,
    required this.iconSize,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF61B8FF), Color(0xFF0083EE)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF0083EE).withOpacity(0.3),
            blurRadius: 30,
            offset: const Offset(0, 10),
          ),
          BoxShadow(
            color: const Color(0xFF61B8FF).withOpacity(0.2),
            blurRadius: 40,
            offset: const Offset(0, 15),
          ),
        ],
      ),
      child: Icon(icon, size: iconSize, color: Colors.white),
    );
  }
}

class LayeredImage extends StatelessWidget {
  final String image;

  const LayeredImage({Key? key, required this.image}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 300,
      height: 300,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: Colors.white.withOpacity(0.15),
      ),
      child: Container(
        margin: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: Colors.white.withOpacity(0.2),
        ),
        child: Container(
          margin: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: Colors.white.withOpacity(0.25),
          ),
          child: Center(
            child: Image.asset(
              image,
              width: 180,
              height: 180,
              fit: BoxFit.contain,
            ),
          ),
        ),
      ),
    );
  }
}

class DescriptionBox extends StatelessWidget {
  final String description;

  const DescriptionBox({Key? key, required this.description}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
      decoration: BoxDecoration(
        color: const Color(0xFF61B8FF).withOpacity(0.1),
        borderRadius: BorderRadius.circular(25),
        border: Border.all(color: const Color(0xFF61B8FF).withOpacity(0.2), width: 1),
      ),
      child: Text(
        description,
        style: GoogleFonts.poppins(
          fontSize: 16,
          fontWeight: FontWeight.w400,
          color: const Color(0xFF6B7280),
        ),
        textAlign: TextAlign.center,
      ),
    );
  }
}

class SwipeUpButton extends StatelessWidget {
  final double swipeOffset;
  final Animation<double> swipeAnimation;
  final Function(DragUpdateDetails) onPanUpdate;
  final Function(DragEndDetails) onPanEnd;

  const SwipeUpButton({
    Key? key,
    required this.swipeOffset,
    required this.swipeAnimation,
    required this.onPanUpdate,
    required this.onPanEnd,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onPanUpdate: onPanUpdate,
      onPanEnd: onPanEnd,
      child: AnimatedBuilder(
        animation: swipeAnimation,
        builder: (context, child) {
          return Transform.translate(
            offset: Offset(0, swipeOffset * (1 - swipeAnimation.value)),
            child: Column(
              children: [
                AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  child: Column(
                    children: [
                      AnimatedOpacity(
                        opacity: swipeOffset < -20 ? 0.3 : 0.7,
                        duration: const Duration(milliseconds: 200),
                        child: Icon(
                          Icons.keyboard_arrow_up,
                          color: Colors.white.withOpacity(0.8),
                          size: 28,
                        ),
                      ),
                      Transform.translate(
                        offset: const Offset(0, -8),
                        child: AnimatedOpacity(
                          opacity: swipeOffset < -20 ? 0.7 : 1.0,
                          duration: const Duration(milliseconds: 200),
                          child: Icon(
                            Icons.keyboard_arrow_up,
                            color: Colors.white,
                            size: 32,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  'Start Now',
                  style: GoogleFonts.poppins(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 8),
                AnimatedOpacity(
                  opacity: swipeOffset < -30 ? 0.0 : 0.8,
                  duration: const Duration(milliseconds: 200),
                  child: Text(
                    'Swipe up to continue',
                    style: GoogleFonts.poppins(
                      fontSize: 14,
                      fontWeight: FontWeight.w400,
                      color: Colors.white.withOpacity(0.7),
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

class BottomNavigation extends StatelessWidget {
  final int currentPage;
  final int pagesLength;
  final VoidCallback onNext;

  const BottomNavigation({
    Key? key,
    required this.currentPage,
    required this.pagesLength,
    required this.onNext,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(24.0),
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
                  color: currentPage == index ? const Color(0xFF0083EE) : const Color(0xFF9CA3AF),
                  borderRadius: BorderRadius.circular(4),
                ),
              );
            }),
          ),
          const SizedBox(height: 24),
          GradientButton(text: 'Lanjut', onTap: onNext),
        ],
      ),
    );
  }
}

class SkipButton extends StatelessWidget {
  final VoidCallback onSkip;

  const SkipButton({Key? key, required this.onSkip}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Positioned(
      top: 16,
      right: 16,
      child: GestureDetector(
        onTap: onSkip,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: const Color(0xFF61B8FF).withOpacity(0.2), width: 1),
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
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: const Color(0xFF0083EE),
            ),
          ),
        ),
      ),
    );
  }
}

class LoginOverlay extends StatelessWidget {
  final AnimationController loginController;
  final Animation<double> loginFadeAnimation;
  final Animation<Offset> loginSlideAnimation;
  final VoidCallback onClose;
  final VoidCallback onLogin;

  const LoginOverlay({
    Key? key,
    required this.loginController,
    required this.loginFadeAnimation,
    required this.loginSlideAnimation,
    required this.onClose,
    required this.onLogin,
  }) : super(key: key);

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
                child: LoginForm(
                  onClose: onClose,
                  onLogin: onLogin,
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}

class LoginForm extends StatelessWidget {
  final VoidCallback onClose;
  final VoidCallback onLogin;

  const LoginForm({
    Key? key,
    required this.onClose,
    required this.onLogin,
  }) : super(key: key);

  void _showSnackBar(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Fitur lupa password akan segera hadir')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: MediaQuery.of(context).size.height * 0.85,
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(30),
          topRight: Radius.circular(30),
        ),
      ),
      child: Column(
        children: [
          HandleBar(onTap: onClose),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                children: [
                  const SizedBox(height: 20),
                  const LoginHeader(),
                  const SizedBox(height: 40),
                  const LoginTextField(
                    hintText: 'Masukkan username anda',
                    icon: Icons.person_outline,
                  ),
                  const SizedBox(height: 20),
                  const LoginTextField(
                    hintText: 'Masukkan password anda',
                    icon: Icons.lock_outline,
                    obscureText: true,
                    suffixIcon: Icons.visibility_off_outlined,
                  ),
                  const SizedBox(height: 30),
                  GradientButton(text: 'Login', onTap: onLogin),
                  const SizedBox(height: 20),
                  GestureDetector(
                    onTap: () => _showSnackBar(context),
                    child: Text(
                      'Lupa Password?',
                      style: GoogleFonts.poppins(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: const Color(0xFF0083EE),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class HandleBar extends StatelessWidget {
  final VoidCallback onTap;

  const HandleBar({Key? key, required this.onTap}) : super(key: key);

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

class LoginHeader extends StatelessWidget {
  const LoginHeader({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: 200,
      decoration: BoxDecoration(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Row(
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: Colors.grey[100],
                borderRadius: BorderRadius.circular(15),
              ),
              child: Padding(
                padding: const EdgeInsets.all(12.0),
                child: Image.asset(
                  'assets/smkn.png',
                  fit: BoxFit.contain,
                ),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Selamat Datang Kembali',
                    style: GoogleFonts.poppins(
                      fontSize: 22,
                      fontWeight: FontWeight.w700,
                      color: const Color(0xFF1F2937),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Yuk, masuk dan lanjutkan aktivitasmu di Aplikasi SMK!',
                    style: GoogleFonts.poppins(
                      fontSize: 13,
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
      ),
    );
  }
}

class LoginTextField extends StatelessWidget {
  final String hintText;
  final IconData icon;
  final bool obscureText;
  final IconData? suffixIcon;

  const LoginTextField({
    Key? key,
    required this.hintText,
    required this.icon,
    this.obscureText = false,
    this.suffixIcon,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: Colors.grey[200]!, width: 1),
      ),
      child: TextField(
        obscureText: obscureText,
        decoration: InputDecoration(
          hintText: hintText,
          hintStyle: GoogleFonts.poppins(fontSize: 14, color: Colors.grey[500]),
          prefixIcon: Icon(icon, color: Colors.grey[400]),
          suffixIcon: suffixIcon != null ? Icon(suffixIcon, color: Colors.grey[400]) : null,
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        ),
      ),
    );
  }
}

class GradientButton extends StatelessWidget {
  final String text;
  final VoidCallback onTap;

  const GradientButton({Key? key, required this.text, required this.onTap}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 18),
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
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
          textAlign: TextAlign.center,
        ),
      ),
    );
  }
}