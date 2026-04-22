import 'dart:math' as math;
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/auth_controller.dart';
import '../../../core/theme.dart';
import '../../../core/global_styles.dart';

class AuthView extends GetView<AuthController> {
  const AuthView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.bgColor,
      body: Stack(
        children: [
          const _AnimatedBackground(),
          SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 28),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const SizedBox(height: 60),
                  const _LogoSection(),
                  const SizedBox(height: 52),
                  const _LoginCard(),
                  const SizedBox(height: 24),
                  _SignUpLink(),
                  const SizedBox(height: 32),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Animated Background with floating particles ─────────────────────────────
class _AnimatedBackground extends StatefulWidget {
  const _AnimatedBackground();
  @override
  State<_AnimatedBackground> createState() => _AnimatedBackgroundState();
}

class _AnimatedBackgroundState extends State<_AnimatedBackground>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(vsync: this, duration: const Duration(seconds: 12))
      ..repeat();
  }

  @override
  void dispose() { _ctrl.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _ctrl,
      builder: (_, __) => CustomPaint(
        painter: _BgPainter(_ctrl.value),
        child: Container(
          decoration: const BoxDecoration(
            gradient: RadialGradient(
              center: Alignment(-0.3, -0.5),
              radius: 1.2,
              colors: [Color(0xFF0D1F2D), AppTheme.bgColor],
            ),
          ),
        ),
      ),
    );
  }
}

class _BgPainter extends CustomPainter {
  final double t;
  _BgPainter(this.t);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..style = PaintingStyle.fill;

    // Glow orbs
    final orbs = [
      (Offset(size.width * 0.8, size.height * 0.15), AppTheme.primaryColor, 120.0),
      (Offset(size.width * 0.1, size.height * 0.7), AppTheme.accentColor, 100.0),
      (Offset(size.width * 0.5, size.height * 0.9), AppTheme.primaryColor, 80.0),
    ];

    for (final orb in orbs) {
      final (offset, color, radius) = orb;
      final animated = offset + Offset(
        math.sin(t * math.pi * 2) * 20,
        math.cos(t * math.pi * 2) * 15,
      );
      paint.shader = RadialGradient(
        colors: [color.withOpacity(0.08), Colors.transparent],
      ).createShader(Rect.fromCircle(center: animated, radius: radius));
      canvas.drawCircle(animated, radius, paint);
    }

    // Grid lines
    final gridPaint = Paint()
      ..color = AppTheme.borderColor.withOpacity(0.3)
      ..strokeWidth = 0.5;
    const spacing = 40.0;
    for (double x = 0; x < size.width; x += spacing) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), gridPaint);
    }
    for (double y = 0; y < size.height; y += spacing) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), gridPaint);
    }
  }

  @override
  bool shouldRepaint(_BgPainter old) => old.t != t;
}

// ── Logo Section ─────────────────────────────────────────────────────────────
class _LogoSection extends StatefulWidget {
  const _LogoSection();
  @override
  State<_LogoSection> createState() => _LogoSectionState();
}

class _LogoSectionState extends State<_LogoSection>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _fade, _scale;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 900));
    _fade = CurvedAnimation(parent: _ctrl, curve: Curves.easeOut);
    _scale = Tween(begin: 0.7, end: 1.0)
        .animate(CurvedAnimation(parent: _ctrl, curve: Curves.elasticOut));
    _ctrl.forward();
  }

  @override
  void dispose() { _ctrl.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _fade,
      child: ScaleTransition(
        scale: _scale,
        child: Column(
          children: [
            GlowPulse(
              color: AppTheme.primaryColor,
              child: Container(
                width: 88, height: 88,
                decoration: BoxDecoration(
                  gradient: AppTheme.primaryGradient,
                  borderRadius: BorderRadius.circular(26),
                  boxShadow: [
                    BoxShadow(
                      color: AppTheme.primaryColor.withOpacity(0.3),
                      blurRadius: 30,
                      offset: const Offset(0, 10),
                    ),
                  ],
                ),
                child: const Icon(Icons.inventory_2_rounded, color: Colors.black, size: 42),
              ),
            ),
            const SizedBox(height: 24),
            const Text(
              'ZENITH STOCK',
              style: TextStyle(
                fontFamily: 'Sora',
                fontSize: 28,
                fontWeight: FontWeight.w800,
                color: Colors.white,
                letterSpacing: 5,
              ),
            ),
            const SizedBox(height: 8),
            ShaderMask(
              shaderCallback: (bounds) => AppTheme.primaryGradient.createShader(bounds),
              child: const Text(
                'PREMIUM INVENTORY SYSTEM',
                style: TextStyle(
                  fontFamily: 'Inter',
                  fontSize: 10,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 3,
                  color: Colors.white,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Login Card ────────────────────────────────────────────────────────────────
class _LoginCard extends GetView<AuthController> {
  const _LoginCard();

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(28),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
        child: Container(
          padding: const EdgeInsets.all(28),
          decoration: BoxDecoration(
            color: AppTheme.cardColor.withOpacity(0.85),
            borderRadius: BorderRadius.circular(28),
            border: Border.all(
              color: Colors.white.withOpacity(0.07),
              width: 1,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Đăng nhập',
                style: AppTheme.headlineStyle.copyWith(fontSize: 22),
              ),
              const SizedBox(height: 6),
              Text('Chào mừng trở lại 👋', style: AppTheme.captionStyle),
              const SizedBox(height: 28),
              TextField(
                onChanged: (v) => controller.email.value = v,
                keyboardType: TextInputType.emailAddress,
                style: const TextStyle(color: Colors.white, fontFamily: 'Inter'),
                decoration: const InputDecoration(
                  labelText: 'Email',
                  prefixIcon: Icon(Icons.email_outlined, size: 18),
                ),
              ),
              const SizedBox(height: 16),
              Obx(() => TextField(
                onChanged: (v) => controller.password.value = v,
                obscureText: !controller.showPassword.value,
                style: const TextStyle(color: Colors.white, fontFamily: 'Inter'),
                decoration: InputDecoration(
                  labelText: 'Mật khẩu',
                  prefixIcon: const Icon(Icons.lock_outline, size: 18),
                  suffixIcon: IconButton(
                    icon: Icon(
                      controller.showPassword.value
                          ? Icons.visibility_off_outlined
                          : Icons.visibility_outlined,
                      size: 18,
                    ),
                    onPressed: controller.togglePasswordVisibility,
                  ),
                ),
              )),
              const SizedBox(height: 32),
              Obx(() => ZenithButton(
                label: 'VÀO HỆ THỐNG',
                icon: Icons.arrow_forward_rounded,
                isLoading: controller.isLoading.value,
                onPressed: controller.isLoading.value ? null : controller.login,
              )),
            ],
          ),
        ),
      ),
    );
  }
}

class _SignUpLink extends GetView<AuthController> {
  @override
  Widget build(BuildContext context) {
    return TextButton(
      onPressed: controller.signUp,
      child: RichText(
        text: const TextSpan(
          text: 'Chưa có tài khoản? ',
          style: TextStyle(color: Color(0xFF546E7A), fontFamily: 'Inter', fontSize: 13),
          children: [
            TextSpan(
              text: 'Đăng ký ngay',
              style: TextStyle(
                color: AppTheme.primaryColor,
                fontWeight: FontWeight.w700,
                decoration: TextDecoration.underline,
                decorationColor: AppTheme.primaryColor,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
