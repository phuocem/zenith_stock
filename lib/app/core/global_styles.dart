import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'theme.dart';

class ZenithCard extends StatefulWidget {
  final Widget child;
  final EdgeInsetsGeometry? padding;
  final Color? borderColor;
  final double borderRadius;
  final VoidCallback? onTap;
  final bool animated;

  const ZenithCard({
    super.key,
    required this.child,
    this.padding,
    this.borderColor,
    this.borderRadius = 16,
    this.onTap,
    this.animated = false,
  });

  @override
  State<ZenithCard> createState() => _ZenithCardState();
}

class _ZenithCardState extends State<ZenithCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _scale;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 120),
      lowerBound: 0.0,
      upperBound: 0.03,
    );
    _scale = Tween(begin: 1.0, end: 0.97).animate(
      CurvedAnimation(parent: _ctrl, curve: Curves.easeOut),
    );
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final card = AnimatedBuilder(
      animation: _scale,
      builder: (_, child) => Transform.scale(
        scale: _scale.value,
        child: child,
      ),
      child: Container(
        padding: widget.padding ?? const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppTheme.cardColor,
          borderRadius: BorderRadius.circular(widget.borderRadius),
          border: Border.all(
            color: widget.borderColor ?? AppTheme.borderColor,
            width: 1,
          ),
        ),
        child: widget.child,
      ),
    );

    if (widget.onTap == null) return card;

    return GestureDetector(
      onTapDown: (_) => _ctrl.forward(),
      onTapUp: (_) {
        _ctrl.reverse();
        widget.onTap?.call();
      },
      onTapCancel: () => _ctrl.reverse(),
      child: card,
    );
  }
}

class ZenithButton extends StatefulWidget {
  final String label;
  final VoidCallback? onPressed;
  final bool isLoading;
  final IconData? icon;
  final Gradient? gradient;
  final Color? color;

  const ZenithButton({
    super.key,
    required this.label,
    this.onPressed,
    this.isLoading = false,
    this.icon,
    this.gradient,
    this.color,
  });

  @override
  State<ZenithButton> createState() => _ZenithButtonState();
}

class _ZenithButtonState extends State<ZenithButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _scale;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 100),
      lowerBound: 0, upperBound: 1,
    );
    _scale = Tween(begin: 1.0, end: 0.96).animate(
      CurvedAnimation(parent: _ctrl, curve: Curves.easeOut),
    );
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final disabled = widget.onPressed == null || widget.isLoading;
    final gradient = widget.gradient ?? AppTheme.primaryGradient;

    return GestureDetector(
      onTapDown: disabled ? null : (_) => _ctrl.forward(),
      onTapUp: disabled ? null : (_) {
        _ctrl.reverse();
        widget.onPressed?.call();
      },
      onTapCancel: () => _ctrl.reverse(),
      child: AnimatedBuilder(
        animation: _scale,
        builder: (_, child) => Transform.scale(scale: _scale.value, child: child),
        child: AnimatedOpacity(
          opacity: disabled ? 0.5 : 1.0,
          duration: const Duration(milliseconds: 200),
          child: Container(
            height: 52,
            decoration: BoxDecoration(
              gradient: widget.color != null
                  ? LinearGradient(colors: [widget.color!, widget.color!])
                  : gradient,
              borderRadius: BorderRadius.circular(14),
              boxShadow: disabled ? [] : [
                BoxShadow(
                  color: (widget.gradient?.colors.first ??
                      AppTheme.primaryColor).withOpacity(0.25),
                  blurRadius: 16,
                  offset: const Offset(0, 6),
                ),
              ],
            ),
            child: Center(
              child: widget.isLoading
                  ? const SizedBox(
                      width: 20, height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2.5, color: Colors.black,
                      ),
                    )
                  : Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        if (widget.icon != null) ...[
                          Icon(widget.icon, size: 18, color: Colors.black),
                          const SizedBox(width: 8),
                        ],
                        Text(
                          widget.label,
                          style: const TextStyle(
                            fontFamily: 'Sora',
                            fontWeight: FontWeight.w700,
                            fontSize: 13,
                            letterSpacing: 1.5,
                            color: Colors.black,
                          ),
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

class ZenithBadge extends StatelessWidget {
  final String label;
  final Color color;
  final bool dot;

  const ZenithBadge({
    super.key,
    required this.label,
    required this.color,
    this.dot = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.12),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withOpacity(0.3), width: 1),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (dot) ...[
            Container(
              width: 5, height: 5,
              decoration: BoxDecoration(color: color, shape: BoxShape.circle),
            ),
            const SizedBox(width: 5),
          ],
          Text(
            label,
            style: TextStyle(
              color: color,
              fontSize: 10,
              fontWeight: FontWeight.w700,
              letterSpacing: 0.8,
              fontFamily: 'Inter',
            ),
          ),
        ],
      ),
    );
  }
}

class ZenithStatCard extends StatefulWidget {
  final String title;
  final String value;
  final IconData icon;
  final Color color;
  final String? subtitle;
  final String? trend;
  final VoidCallback? onTap;

  const ZenithStatCard({
    super.key,
    required this.title,
    required this.value,
    required this.icon,
    required this.color,
    this.subtitle,
    this.trend,
    this.onTap,
  });

  @override
  State<ZenithStatCard> createState() => _ZenithStatCardState();
}

class _ZenithStatCardState extends State<ZenithStatCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _fade;
  late Animation<Offset> _slide;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 600));
    _fade = CurvedAnimation(parent: _ctrl, curve: Curves.easeOut);
    _slide = Tween(begin: const Offset(0, 0.15), end: Offset.zero)
        .animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeOutCubic));
    _ctrl.forward();
  }

  @override
  void dispose() { _ctrl.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: widget.onTap,
      child: FadeTransition(
        opacity: _fade,
        child: SlideTransition(
          position: _slide,
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppTheme.cardColor,
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: widget.color.withOpacity(0.15), width: 1),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(
                      width: 38, height: 38,
                      decoration: BoxDecoration(
                        color: widget.color.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(widget.icon, color: widget.color, size: 20),
                    ),
                    if (widget.trend != null)
                      ZenithBadge(label: widget.trend!, color: widget.color),
                  ],
                ),
                const Spacer(),
                Text(
                  widget.value,
                  style: AppTheme.numberStyle.copyWith(
                    color: widget.color, fontSize: 26,
                  ),
                ),
                const SizedBox(height: 4),
                Text(widget.title, style: AppTheme.labelStyle),
                if (widget.subtitle != null)
                  Padding(
                    padding: const EdgeInsets.only(top: 4),
                    child: Text(
                      widget.subtitle!,
                      style: AppTheme.captionStyle.copyWith(fontSize: 11),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class FadeSlideItem extends StatefulWidget {
  final Widget child;
  final int index;
  final Duration? delay;

  const FadeSlideItem({
    super.key,
    required this.child,
    this.index = 0,
    this.delay,
  });

  @override
  State<FadeSlideItem> createState() => _FadeSlideItemState();
}

class _FadeSlideItemState extends State<FadeSlideItem>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _fade;
  late Animation<Offset> _slide;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 400));
    _fade = CurvedAnimation(parent: _ctrl, curve: Curves.easeOut);
    _slide = Tween(begin: const Offset(0, 0.12), end: Offset.zero)
        .animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeOutCubic));

    final d = widget.delay ?? Duration(milliseconds: 40 * widget.index);
    Future.delayed(d, () {
      if (mounted) _ctrl.forward();
    });
  }

  @override
  void dispose() { _ctrl.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _fade,
      child: SlideTransition(position: _slide, child: widget.child),
    );
  }
}

class EmptyState extends StatefulWidget {
  final String message;
  final IconData icon;
  final String? actionLabel;
  final VoidCallback? onAction;

  const EmptyState({
    super.key,
    required this.message,
    required this.icon,
    this.actionLabel,
    this.onAction,
  });

  @override
  State<EmptyState> createState() => _EmptyStateState();
}

class _EmptyStateState extends State<EmptyState> with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _pulse;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2000),
    )..repeat(reverse: true);
    _pulse = Tween(begin: 0.85, end: 1.0).animate(
      CurvedAnimation(parent: _ctrl, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() { _ctrl.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          AnimatedBuilder(
            animation: _pulse,
            builder: (_, child) => Transform.scale(
              scale: _pulse.value, child: child,
            ),
            child: Container(
              width: 80, height: 80,
              decoration: BoxDecoration(
                color: AppTheme.accentColor.withOpacity(0.06),
                shape: BoxShape.circle,
                border: Border.all(color: AppTheme.accentColor.withOpacity(0.15)),
              ),
              child: Icon(widget.icon, size: 36, color: AppTheme.accentColor.withOpacity(0.5)),
            ),
          ),
          const SizedBox(height: 20),
          Text(
            widget.message,
            style: AppTheme.captionStyle.copyWith(height: 1.6),
            textAlign: TextAlign.center,
          ),
          if (widget.actionLabel != null && widget.onAction != null) ...[
            const SizedBox(height: 20),
            SizedBox(
              width: 160,
              child: ZenithButton(
                label: widget.actionLabel!,
                onPressed: widget.onAction,
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class SectionHeader extends StatelessWidget {
  final String title;
  final Widget? trailing;

  const SectionHeader({super.key, required this.title, this.trailing});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(width: 3, height: 16, decoration: BoxDecoration(
          gradient: AppTheme.primaryGradient,
          borderRadius: BorderRadius.circular(2),
        )),
        const SizedBox(width: 10),
        Expanded(
          child: Text(
            title.toUpperCase(),
            style: AppTheme.labelStyle.copyWith(
              color: Colors.white60, letterSpacing: 1.5,
            ),
          ),
        ),
        if (trailing != null) trailing!,
      ],
    );
  }
}

class GlowPulse extends StatefulWidget {
  final Widget child;
  final Color color;

  const GlowPulse({super.key, required this.child, required this.color});

  @override
  State<GlowPulse> createState() => _GlowPulseState();
}

class _GlowPulseState extends State<GlowPulse> with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(vsync: this, duration: const Duration(seconds: 2))..repeat();
  }

  @override
  void dispose() { _ctrl.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _ctrl,
      builder: (_, child) {
        final t = math.sin(_ctrl.value * math.pi * 2) * 0.5 + 0.5;
        return Container(
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: widget.color.withOpacity(0.1 + t * 0.15),
                blurRadius: 12 + t * 8,
                spreadRadius: t * 3,
              ),
            ],
          ),
          child: child,
        );
      },
      child: widget.child,
    );
  }
}

class ShimmerBox extends StatefulWidget {
  final double width;
  final double height;
  final double radius;

  const ShimmerBox({
    super.key,
    required this.width,
    required this.height,
    this.radius = 8,
  });

  @override
  State<ShimmerBox> createState() => _ShimmerBoxState();
}

class _ShimmerBoxState extends State<ShimmerBox> with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _shimmer;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 1200))..repeat();
    _shimmer = Tween(begin: -1.0, end: 2.0).animate(
      CurvedAnimation(parent: _ctrl, curve: Curves.linear),
    );
  }

  @override
  void dispose() { _ctrl.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _shimmer,
      builder: (_, __) => Container(
        width: widget.width,
        height: widget.height,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(widget.radius),
          gradient: LinearGradient(
            begin: Alignment(_shimmer.value - 1, 0),
            end: Alignment(_shimmer.value, 0),
            colors: const [
              Color(0xFF1A2333),
              Color(0xFF243040),
              Color(0xFF1A2333),
            ],
          ),
        ),
      ),
    );
  }
}

class ZenithDivider extends StatelessWidget {
  final EdgeInsetsGeometry? margin;
  const ZenithDivider({super.key, this.margin});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: margin ?? const EdgeInsets.symmetric(vertical: 12),
      height: 1,
      decoration: const BoxDecoration(
        gradient: LinearGradient(colors: [
          Colors.transparent, AppTheme.borderColor, Colors.transparent,
        ]),
      ),
    );
  }
}

class ZenithProgressBar extends StatefulWidget {
  final double value;
  final Color color;
  final double height;

  const ZenithProgressBar({
    super.key,
    required this.value,
    required this.color,
    this.height = 4,
  });

  @override
  State<ZenithProgressBar> createState() => _ZenithProgressBarState();
}

class _ZenithProgressBarState extends State<ZenithProgressBar>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _anim;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 800));
    _anim = Tween(begin: 0.0, end: widget.value)
        .animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeOutCubic));
    _ctrl.forward();
  }

  @override
  void dispose() { _ctrl.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _anim,
      builder: (_, __) => Container(
        height: widget.height,
        decoration: BoxDecoration(
          color: widget.color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(widget.height),
        ),
        child: FractionallySizedBox(
          widthFactor: _anim.value.clamp(0, 1),
          child: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(colors: [widget.color, widget.color.withOpacity(0.7)]),
              borderRadius: BorderRadius.circular(widget.height),
              boxShadow: [BoxShadow(color: widget.color.withOpacity(0.4), blurRadius: 4)],
            ),
          ),
        ),
      ),
    );
  }
}
