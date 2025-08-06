import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:skoring/screens/login.dart';

class IntroductionScreen extends StatefulWidget {
  const IntroductionScreen({Key? key}) : super(key: key);

  @override
  State<IntroductionScreen> createState() => _IntroductionScreenState();
}

class _IntroductionScreenState extends State<IntroductionScreen>
    with TickerProviderStateMixin {
  late AnimationController _animationController;
  late AnimationController _swipeController;
  late AnimationController _loginController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _scaleAnimation;
  late Animation<double> _swipeAnimation;
  late Animation<Offset> _loginSlideAnimation;
  late Animation<double> _loginFadeAnimation;
  final PageController _pageController = PageController();
  int _currentPage = 0;
  double _swipeOffset = 0.0;
  bool _showLoginOverlay = false;

  final List<Map<String, dynamic>> _pages = [
    {
      'icon': Icons.school_rounded,
      'title': 'Selamat Datang di Aplikasi SMK',
      'description':
          'Kelola prestasi dan pelanggaran siswa dengan mudah dan efisien.',
    },
    {
      'icon': Icons.search_rounded,
      'title': 'Cari dan Monitor Siswa',
      'description':
          'Gunakan fitur pencarian untuk menemukan siswa berdasarkan nama atau kelas, dan pantau perkembangan mereka.',
    },
    {
      'icon': Icons.admin_panel_settings_rounded,
      'title': 'Pilih Peran Anda',
      'description':
          'Pilih peran sebagai Kepala Program Keahlian atau Wali Kelas untuk mengelola tugas sesuai kebutuhan.',
    },
    {
      'image': 'assets/backpack.png',
      'title': 'Learn anything\nAnytime anywhere',
      'description':
          'Lorem ipsum dolor sit amet, consectetur adipiscing elit. Sed euismod, nunc ut tristique luctus, nunc lorem molestie mauris.',
    },
  ];

  @override
  void initState() {
    super.initState();
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

    _pageController.addListener(() {
      setState(() {
        _currentPage = _pageController.page?.round() ?? 0;
      });
    });
    _animationController.forward();
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
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const RoleSelectionScreen()),
      );
    }
  }

  void _showLogin() {
    setState(() {
      _showLoginOverlay = true;
    });
    _loginController.forward();
  }

  void _hideLogin() {
    _loginController.reverse().then((_) {
      setState(() {
        _showLoginOverlay = false;
      });
    });
  }

  void _onPanUpdate(DragUpdateDetails details) {
    setState(() {
      _swipeOffset += details.delta.dy;
      if (_swipeOffset > 0) _swipeOffset = 0;
      if (_swipeOffset < -100) _swipeOffset = -100;
    });
  }

  void _onPanEnd(DragEndDetails details) {
    if (_swipeOffset < -50) {
      _swipeController.forward().then((_) {
        _showLogin();
        _swipeController.reset();
        setState(() {
          _swipeOffset = 0.0;
        });
      });
    } else {
      _swipeController.reverse();
      setState(() {
        _swipeOffset = 0.0;
      });
    }
  }

  Widget _buildLoginOverlay() {
    return AnimatedBuilder(
      animation: _loginController,
      builder: (context, child) {
        return Stack(
          children: [
            FadeTransition(
              opacity: _loginFadeAnimation,
              child: GestureDetector(
                onTap: _hideLogin,
                child: Container(
                  width: double.infinity,
                  height: double.infinity,
                  color: Colors.black,
                ),
              ),
            ),
            SlideTransition(
              position: _loginSlideAnimation,
              child: Align(
                alignment: Alignment.bottomCenter,
                child: Container(
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
                      // Handle bar
                      GestureDetector(
                        onTap: _hideLogin,
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
                      ),

                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.all(24.0),
                          child: Column(
                            children: [
                              const SizedBox(height: 20),
                              Container(
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
                                          borderRadius: BorderRadius.circular(
                                            15,
                                          ),
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
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
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
                              ),

                              const SizedBox(height: 40),

                              Container(
                                decoration: BoxDecoration(
                                  color: Colors.grey[50],
                                  borderRadius: BorderRadius.circular(15),
                                  border: Border.all(
                                    color: Colors.grey[200]!,
                                    width: 1,
                                  ),
                                ),
                                child: TextField(
                                  decoration: InputDecoration(
                                    hintText: 'Masukkan username anda',
                                    hintStyle: GoogleFonts.poppins(
                                      fontSize: 14,
                                      color: Colors.grey[500],
                                    ),
                                    prefixIcon: Icon(
                                      Icons.person_outline,
                                      color: Colors.grey[400],
                                    ),
                                    border: InputBorder.none,
                                    contentPadding: const EdgeInsets.symmetric(
                                      horizontal: 16,
                                      vertical: 16,
                                    ),
                                  ),
                                ),
                              ),

                              const SizedBox(height: 20),

                              Container(
                                decoration: BoxDecoration(
                                  color: Colors.grey[50],
                                  borderRadius: BorderRadius.circular(15),
                                  border: Border.all(
                                    color: Colors.grey[200]!,
                                    width: 1,
                                  ),
                                ),
                                child: TextField(
                                  obscureText: true,
                                  decoration: InputDecoration(
                                    hintText: 'Masukkan password anda',
                                    hintStyle: GoogleFonts.poppins(
                                      fontSize: 14,
                                      color: Colors.grey[500],
                                    ),
                                    prefixIcon: Icon(
                                      Icons.lock_outline,
                                      color: Colors.grey[400],
                                    ),
                                    suffixIcon: Icon(
                                      Icons.visibility_off_outlined,
                                      color: Colors.grey[400],
                                    ),
                                    border: InputBorder.none,
                                    contentPadding: const EdgeInsets.symmetric(
                                      horizontal: 16,
                                      vertical: 16,
                                    ),
                                  ),
                                ),
                              ),

                              const SizedBox(height: 30),

                              GestureDetector(
                                onTap: () {
                                  Navigator.pushReplacement(
                                    context,
                                    MaterialPageRoute(
                                      builder:
                                          (context) =>
                                              const RoleSelectionScreen(),
                                    ),
                                  );
                                },
                                child: Container(
                                  width: double.infinity,
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 18,
                                  ),
                                  decoration: BoxDecoration(
                                    gradient: const LinearGradient(
                                      colors: [
                                        Color(0xFF61B8FF),
                                        Color(0xFF0083EE),
                                      ],
                                      begin: Alignment.topLeft,
                                      end: Alignment.bottomRight,
                                    ),
                                    borderRadius: BorderRadius.circular(15),
                                    boxShadow: [
                                      BoxShadow(
                                        color: const Color(
                                          0xFF0083EE,
                                        ).withOpacity(0.3),
                                        blurRadius: 15,
                                        offset: const Offset(0, 5),
                                      ),
                                    ],
                                  ),
                                  child: Text(
                                    'Login',
                                    style: GoogleFonts.poppins(
                                      fontSize: 18,
                                      fontWeight: FontWeight.w600,
                                      color: Colors.white,
                                    ),
                                    textAlign: TextAlign.center,
                                  ),
                                ),
                              ),

                              const SizedBox(height: 20),

                              GestureDetector(
                                onTap: () {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text(
                                        'Fitur lupa password akan segera hadir',
                                      ),
                                    ),
                                  );
                                },
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
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildRegularPage(int index) {
    return FadeTransition(
      opacity: _fadeAnimation,
      child: SlideTransition(
        position: _slideAnimation,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SizedBox(height: MediaQuery.of(context).size.height * 0.1),

              ScaleTransition(
                scale: _scaleAnimation,
                child: Container(
                  width: 180,
                  height: 180,
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
                  child: Icon(
                    _pages[index]['icon'],
                    size: 90,
                    color: Colors.white,
                  ),
                ),
              ),
              const SizedBox(height: 40),

              Text(
                _pages[index]['title'],
                style: GoogleFonts.poppins(
                  fontSize: 28,
                  fontWeight: FontWeight.w700,
                  color: const Color(0xFF1F2937),
                  height: 1.2,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),

              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 14,
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
                  _pages[index]['description'],
                  style: GoogleFonts.poppins(
                    fontSize: 16,
                    fontWeight: FontWeight.w400,
                    color: const Color(0xFF6B7280),
                  ),
                  textAlign: TextAlign.center,
                ),
              ),

              SizedBox(height: MediaQuery.of(context).size.height * 0.1),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFinalPage(int index) {
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
                scale: _scaleAnimation,
                child: Container(
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
                          'backpack.png',
                          width: 180,
                          height: 180,
                          fit: BoxFit.contain,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 40),

              FadeTransition(
                opacity: _fadeAnimation,
                child: Text(
                  _pages[index]['title'],
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
                opacity: _fadeAnimation,
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Text(
                    _pages[index]['description'],
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

              GestureDetector(
                onPanUpdate: _onPanUpdate,
                onPanEnd: _onPanEnd,
                child: AnimatedBuilder(
                  animation: _swipeAnimation,
                  builder: (context, child) {
                    return Transform.translate(
                      offset: Offset(
                        0,
                        _swipeOffset * (1 - _swipeAnimation.value),
                      ),
                      child: Column(
                        children: [
                          AnimatedContainer(
                            duration: const Duration(milliseconds: 300),
                            child: Column(
                              children: [
                                AnimatedOpacity(
                                  opacity: _swipeOffset < -20 ? 0.3 : 0.7,
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
                                    opacity: _swipeOffset < -20 ? 0.7 : 1.0,
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
                            opacity: _swipeOffset < -30 ? 0.0 : 0.8,
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
              ),

              SizedBox(height: MediaQuery.of(context).size.height * 0.05),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor:
          _currentPage == _pages.length - 1
              ? const Color(0xFF1E6BB8)
              : const Color(0xFFF8FAFC),
      body: SafeArea(
        child: Stack(
          children: [
            Column(
              children: [
                Expanded(
                  child: PageView.builder(
                    controller: _pageController,
                    itemCount: _pages.length,
                    itemBuilder: (context, index) {
                      if (index == _pages.length - 1) {
                        return _buildFinalPage(index);
                      } else {
                        return _buildRegularPage(index);
                      }
                    },
                  ),
                ),
                if (_currentPage != _pages.length - 1)
                  Padding(
                    padding: const EdgeInsets.all(24.0),
                    child: Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: List.generate(_pages.length, (index) {
                            return AnimatedContainer(
                              duration: const Duration(milliseconds: 300),
                              margin: const EdgeInsets.symmetric(horizontal: 4),
                              width: _currentPage == index ? 12 : 8,
                              height: 8,
                              decoration: BoxDecoration(
                                color:
                                    _currentPage == index
                                        ? const Color(0xFF0083EE)
                                        : const Color(0xFF9CA3AF),
                                borderRadius: BorderRadius.circular(4),
                              ),
                            );
                          }),
                        ),
                        const SizedBox(height: 24),
                        GestureDetector(
                          onTap: _nextPage,
                          child: Container(
                            width: double.infinity,
                            padding: const EdgeInsets.symmetric(vertical: 18),
                            decoration: BoxDecoration(
                              gradient: const LinearGradient(
                                colors: [Color(0xFF61B8FF), Color(0xFF0083EE)],
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                              ),
                              borderRadius: BorderRadius.circular(20),
                              boxShadow: [
                                BoxShadow(
                                  color: const Color(
                                    0xFF0083EE,
                                  ).withOpacity(0.3),
                                  blurRadius: 15,
                                  offset: const Offset(0, 5),
                                ),
                              ],
                            ),
                            child: Text(
                              'Lanjut',
                              style: GoogleFonts.poppins(
                                fontSize: 18,
                                fontWeight: FontWeight.w600,
                                color: Colors.white,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
              ],
            ),
            if (_currentPage != _pages.length - 1)
              Positioned(
                top: 16,
                right: 16,
                child: GestureDetector(
                  onTap: () {
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const RoleSelectionScreen(),
                      ),
                    );
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
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
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: const Color(0xFF0083EE),
                      ),
                    ),
                  ),
                ),
              ),
            if (_showLoginOverlay) _buildLoginOverlay(),
          ],
        ),
      ),
    );
  }
}
