import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:trachcare/style/design_system.dart';
import 'package:trachcare/style/responsive.dart';

/// Soft elevated surface used across every screen.
class TcCard extends StatelessWidget {
  const TcCard({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(AppSpacing.xl),
    this.onTap,
    this.gradient,
    this.color,
    this.borderRadius = AppRadius.card,
    this.shadows = AppShadows.card,
    this.border,
  });

  final Widget child;
  final EdgeInsetsGeometry padding;
  final VoidCallback? onTap;
  final Gradient? gradient;
  final Color? color;
  final BorderRadius borderRadius;
  final List<BoxShadow>? shadows;
  final BoxBorder? border;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: gradient == null ? (color ?? AppColors.surface) : null,
        gradient: gradient,
        borderRadius: borderRadius,
        boxShadow: shadows,
        border: border,
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: borderRadius,
          child: Padding(padding: padding, child: child),
        ),
      ),
    );
  }
}

/// Uppercase eyebrow + title + optional trailing action.
class TcSectionHeader extends StatelessWidget {
  const TcSectionHeader({
    super.key,
    this.eyebrow,
    required this.title,
    this.subtitle,
    this.trailing,
  });

  final String? eyebrow;
  final String title;
  final String? subtitle;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.md),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (eyebrow != null) ...[
                  Text(eyebrow!.toUpperCase(), style: AppType.eyebrow),
                  SizedBox(height: AppSize.s(6)),
                ],
                Text(title, style: Theme.of(context).textTheme.titleLarge),
                if (subtitle != null) ...[
                  SizedBox(height: AppSize.s(4)),
                  Text(
                    subtitle!,
                    style: Theme.of(context)
                        .textTheme
                        .bodySmall
                        ?.copyWith(color: AppColors.inkMuted),
                  ),
                ],
              ],
            ),
          ),
          if (trailing != null) trailing!,
        ],
      ),
    );
  }
}

/// Compact metric tile used on dashboards.
class TcStatTile extends StatelessWidget {
  const TcStatTile({
    super.key,
    required this.icon,
    required this.label,
    required this.value,
    this.accent = AppColors.teal,
    this.accentSoft = AppColors.mintSoft,
    this.trailing,
  });

  final IconData icon;
  final String label;
  final String value;
  final Color accent;
  final Color accentSoft;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    return TcCard(
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: Row(
        children: [
          Container(
            width: AppSize.s(44),
            height: AppSize.s(44),
            decoration: BoxDecoration(
              color: accentSoft,
              borderRadius: AppRadius.thumb,
            ),
            child: Icon(icon, color: accent, size: AppSize.s(22)),
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  label.toUpperCase(),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: AppSize.s(10.5),
                    fontWeight: FontWeight.w700,
                    letterSpacing: AppSize.s(0.8),
                    color: AppColors.inkMuted,
                  ),
                ),
                const SizedBox(height: 3),
                Text(value, style: Theme.of(context).textTheme.titleMedium),
              ],
            ),
          ),
          if (trailing != null) trailing!,
        ],
      ),
    );
  }
}

/// Status pill — attended / pending / alert etc.
class TcBadge extends StatelessWidget {
  const TcBadge({
    super.key,
    required this.label,
    this.color = AppColors.teal,
    this.background = AppColors.mintSoft,
    this.icon,
  });

  final String label;
  final Color color;
  final Color background;
  final IconData? icon;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: AppSize.s(10), vertical: AppSize.s(5)),
      decoration:
          BoxDecoration(color: background, borderRadius: AppRadius.chip),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(icon, size: AppSize.s(13), color: color),
            SizedBox(width: AppSize.s(4)),
          ],
          Text(
            label,
            style: GoogleFonts.plusJakartaSans(
              fontSize: AppSize.s(11.5),
              fontWeight: FontWeight.w700,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}

/// Ring-bordered avatar with optional online dot.
class TcAvatar extends StatelessWidget {
  const TcAvatar({
    super.key,
    this.imageUrl,
    this.localImage,
    this.fallbackIcon = Icons.person_rounded,
    this.size = 52,
    this.ring = true,
  });

  final String? imageUrl;

  /// Unencoded local filesystem path, for a photo picked but not yet uploaded.
  final String? localImage;
  final IconData fallbackIcon;
  final double size;
  final bool ring;

  @override
  Widget build(BuildContext context) {
    final fallback =
        Icon(fallbackIcon, size: size * 0.46, color: AppColors.inkMuted);
    final local = localImage;
    final remote = imageUrl;
    ImageProvider? provider;
    if (local != null) {
      provider = FileImage(File(local));
    } else if (remote != null && remote.isNotEmpty) {
      provider = NetworkImage(remote);
    }

    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: AppColors.surfaceAlt,
        border: ring
            ? Border.all(color: AppColors.surface, width: size * 0.06)
            : null,
        boxShadow: ring ? AppShadows.card : null,
      ),
      clipBehavior: Clip.antiAlias,
      child: provider == null
          ? fallback
          : Image(
              image: provider,
              fit: BoxFit.cover,
              errorBuilder: (_, __, ___) => fallback),
    );
  }
}

/// Full-width gradient CTA.
class TcButton extends StatelessWidget {
  const TcButton({
    super.key,
    required this.label,
    this.onPressed,
    this.icon,
    this.gradient = AppColors.brandGradient,
    this.height = 54,
    this.expand = true,
  });

  final String label;
  final VoidCallback? onPressed;
  final IconData? icon;
  final Gradient? gradient;
  final double height;
  final bool expand;

  @override
  Widget build(BuildContext context) {
    final enabled = onPressed != null;
    return SizedBox(
      width: expand ? double.infinity : null,
      height: height,
      child: DecoratedBox(
        decoration: BoxDecoration(
          gradient: enabled ? gradient : null,
          color: enabled ? null : AppColors.surfaceAlt,
          borderRadius: AppRadius.button,
          boxShadow: enabled ? AppShadows.raised : null,
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: onPressed,
            borderRadius: AppRadius.button,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xl),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (icon != null) ...[
                    Icon(icon,
                        size: AppSize.s(20),
                        color: enabled ? Colors.white : AppColors.inkMuted),
                    const SizedBox(width: AppSpacing.sm),
                  ],
                  Flexible(
                    child: Text(
                      label,
                      overflow: TextOverflow.ellipsis,
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: AppSize.s(15),
                        fontWeight: FontWeight.w700,
                        color: enabled ? Colors.white : AppColors.inkMuted,
                      ),
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

/// Floating pill bottom navigation shared by all three roles.
class TcNavBar extends StatelessWidget {
  const TcNavBar({
    super.key,
    required this.items,
    required this.currentIndex,
    required this.onSelected,
  });

  final List<TcNavItem> items;
  final int currentIndex;
  final ValueChanged<int> onSelected;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.fromLTRB(
          AppSpacing.page, 0, AppSpacing.page, AppSpacing.lg),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: AppRadius.chip,
        boxShadow: AppShadows.nav,
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: AppSize.s(6), vertical: AppSize.s(6)),
          child: Row(
            children: [
              for (var i = 0; i < items.length; i++)
                Expanded(
                  child: _TcNavTab(
                    item: items[i],
                    selected: i == currentIndex,
                    onTap: () => onSelected(i),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class TcNavItem {
  const TcNavItem(
      {required this.icon, required this.activeIcon, required this.label});

  final IconData icon;
  final IconData activeIcon;
  final String label;
}

class _TcNavTab extends StatelessWidget {
  const _TcNavTab({
    required this.item,
    required this.selected,
    required this.onTap,
  });

  final TcNavItem item;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 220),
      curve: Curves.easeOutCubic,
      decoration: BoxDecoration(
        gradient: selected ? AppColors.brandGradient : null,
        borderRadius: AppRadius.chip,
        boxShadow: selected ? AppShadows.raised : null,
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: AppRadius.chip,
          child: SizedBox(
            height: AppSize.s(50),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  selected ? item.activeIcon : item.icon,
                  size: AppSize.s(20),
                  color: selected ? Colors.white : AppColors.inkMuted,
                ),
                AnimatedSize(
                  duration: const Duration(milliseconds: 220),
                  child: selected
                      ? Padding(
                          padding: EdgeInsets.only(left: AppSize.s(7)),
                          child: Text(
                            item.label,
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: AppSize.s(13.5),
                              fontWeight: FontWeight.w700,
                              color: Colors.white,
                            ),
                          ),
                        )
                      : const SizedBox.shrink(),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Header block with a tinted gradient band behind the page title.
class TcPageHeader extends StatelessWidget {
  const TcPageHeader({
    super.key,
    required this.title,
    this.subtitle,
    this.leading,
    this.actions,
    this.child,
    this.gradient = AppColors.brandGradient,
  });

  final String title;
  final String? subtitle;
  final Widget? leading;
  final List<Widget>? actions;
  final Widget? child;
  final Gradient gradient;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: gradient,
        borderRadius: BorderRadius.vertical(bottom: Radius.circular(AppSize.s(30))),
        boxShadow: AppShadows.raised,
      ),
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(
              AppSpacing.page, AppSpacing.md, AppSpacing.page, AppSpacing.xxl),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  if (leading != null) leading!,
                  if (leading != null) const SizedBox(width: AppSpacing.sm),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          title,
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: AppSize.s(22),
                            fontWeight: FontWeight.w800,
                            color: Colors.white,
                          ),
                        ),
                        if (subtitle != null)
                          Text(
                            subtitle!,
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: AppSize.s(12.5),
                              fontWeight: FontWeight.w500,
                              color: Colors.white.withValues(alpha: 0.82),
                            ),
                          ),
                      ],
                    ),
                  ),
                  if (actions != null) ...actions!,
                ],
              ),
              if (child != null) ...[
                const SizedBox(height: AppSpacing.xl),
                child!,
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class TcEmptyState extends StatelessWidget {
  const TcEmptyState({
    super.key,
    this.icon = Icons.inbox_rounded,
    required this.title,
    this.message,
    this.action,
  });

  final IconData icon;
  final String title;
  final String? message;
  final Widget? action;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.xxxl),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: AppSize.s(78),
              height: AppSize.s(78),
              decoration: const BoxDecoration(
                color: AppColors.surfaceAlt,
                shape: BoxShape.circle,
              ),
              child: Icon(icon, size: AppSize.s(32), color: AppColors.tealLight),
            ),
            const SizedBox(height: AppSpacing.xl),
            Text(title, style: Theme.of(context).textTheme.titleMedium),
            if (message != null) ...[
              SizedBox(height: AppSize.s(6)),
              Text(
                message!,
                textAlign: TextAlign.center,
                style: Theme.of(context)
                    .textTheme
                    .bodySmall
                    ?.copyWith(color: AppColors.inkMuted),
              ),
            ],
            if (action != null) ...[
              const SizedBox(height: AppSpacing.xl),
              action!,
            ],
          ],
        ),
      ),
    );
  }
}

/// Skeleton shimmer block for loading states.
class TcSkeleton extends StatelessWidget {
  const TcSkeleton({super.key, this.height = 16, this.width, this.radius = 8});

  final double height;
  final double? width;
  final double radius;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width ?? double.infinity,
      height: height,
      decoration: BoxDecoration(
        color: AppColors.surfaceAlt,
        borderRadius: BorderRadius.circular(radius),
      ),
    );
  }
}

/// Frosted circular icon button used in headers.
class TcIconButton extends StatelessWidget {
  const TcIconButton({
    super.key,
    required this.icon,
    this.onPressed,
    this.size = 42,
    this.background,
    this.color = AppColors.ink,
    this.badge = false,
  });

  final IconData icon;
  final VoidCallback? onPressed;
  final double size;
  final Color? background;
  final Color color;
  final bool badge;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: background ?? Colors.white.withValues(alpha: 0.18),
          shape: BoxShape.circle,
          border:
              Border.all(color: Colors.white.withValues(alpha: 0.28), width: 1),
        ),
        child: Stack(
          children: [
            Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: onPressed,
                customBorder: const CircleBorder(),
                child: Icon(icon, size: size * 0.46, color: color),
              ),
            ),
            if (badge)
              Positioned(
                right: AppSize.s(9),
                top: AppSize.s(9),
                child: Container(
                  width: AppSize.s(9),
                  height: AppSize.s(9),
                  decoration: BoxDecoration(
                    color: AppColors.coral,
                    shape: BoxShape.circle,
                    border: Border.all(color: AppColors.surface, width: AppSize.s(1.5)),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

/// Patient identity banner shown at the top of records screens.
/// Replaces the `Namecard` helper that was duplicated across roles.
class TcPatientHeader extends StatelessWidget {
  const TcPatientHeader({
    super.key,
    required this.name,
    required this.patientId,
    required this.imagePath,
    this.localImage,
    this.fallbackIcon,
    this.trailing,
  });

  final String name;
  final String patientId;
  final String imagePath;
  final String? localImage;
  final IconData? fallbackIcon;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    return TcCard(
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: Row(
        children: [
          TcAvatar(
            imageUrl: imagePath,
            localImage: localImage,
            fallbackIcon: fallbackIcon ?? Icons.person_rounded,
            size: AppSize.s(54),
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: 3),
                TcBadge(
                  label: 'ID $patientId',
                  color: AppColors.teal,
                  background: AppColors.mintSoft,
                  icon: Icons.badge_outlined,
                ),
              ],
            ),
          ),
          if (trailing != null) trailing!,
        ],
      ),
    );
  }
}

/// Themed text field used by every edit form in the app.
class TcField extends StatelessWidget {
  const TcField({
    super.key,
    required this.label,
    required this.controller,
    this.icon,
    this.validator,
    this.keyboardType,
    this.obscure = false,
    this.textInputAction,
    this.onFieldSubmitted,
    this.onSaved,
    this.suffix,
    this.enabled = true,
    this.maxLines = 1,
    this.maxChars,
  });

  final String label;
  final TextEditingController controller;
  final IconData? icon;
  final String? Function(String?)? validator;
  final TextInputType? keyboardType;
  final bool obscure;
  final TextInputAction? textInputAction;
  final ValueChanged<String>? onFieldSubmitted;
  final ValueChanged<String?>? onSaved;
  final Widget? suffix;
  final bool enabled;
  final int maxLines;

  /// Hard character cap, mirroring the column width the API writes to.
  final int? maxChars;

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      validator: validator,
      keyboardType: keyboardType,
      obscureText: obscure,
      enabled: enabled,
      maxLines: obscure ? 1 : maxLines,
      textInputAction: textInputAction,
      onFieldSubmitted: onFieldSubmitted,
      inputFormatters: maxChars == null
          ? null
          : [LengthLimitingTextInputFormatter(maxChars)],
      onSaved: onSaved,
      cursorColor: AppColors.teal,
      style: Theme.of(context)
          .textTheme
          .bodyLarge
          ?.copyWith(color: AppColors.ink, fontWeight: FontWeight.w600),
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: icon == null
            ? null
            : Icon(icon, size: AppSize.s(20), color: AppColors.inkMuted),
        suffixIcon: suffix,
      ),
    );
  }
}

/// Label/value row for detail and profile screens.
class TcDetailRow extends StatelessWidget {
  const TcDetailRow({
    super.key,
    required this.label,
    required this.value,
    this.icon,
    this.valueColor,
  });

  final String label;
  final String value;
  final IconData? icon;
  final Color? valueColor;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: AppSize.s(9)),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (icon != null) ...[
            Icon(icon, size: AppSize.s(17), color: AppColors.inkMuted),
            const SizedBox(width: AppSpacing.sm),
          ],
          Expanded(
            flex: 2,
            child: Text(label,
                style: Theme.of(context)
                    .textTheme
                    .bodyMedium
                    ?.copyWith(color: AppColors.inkMuted)),
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            flex: 3,
            child: Text(
              value.isEmpty ? '—' : value,
              textAlign: TextAlign.end,
              style: Theme.of(context).textTheme.titleSmall?.copyWith(
                    color: valueColor ?? AppColors.ink,
                    fontWeight: FontWeight.w700,
                  ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Gradient identity banner for profile and record-detail screens.
class TcProfileHero extends StatelessWidget {
  const TcProfileHero({
    super.key,
    required this.name,
    required this.imagePath,
    this.role,
    this.idLabel,
    this.gradient = AppColors.brandGradient,
    this.fallbackIcon = Icons.person_rounded,
    this.localImage,
    this.trailing,
  });

  final String name;
  final String imagePath;
  final String? role;
  final String? idLabel;
  final Gradient gradient;
  final IconData fallbackIcon;
  final String? localImage;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        gradient: gradient,
        borderRadius: AppRadius.card,
        boxShadow: AppShadows.raised,
      ),
      padding: const EdgeInsets.fromLTRB(
          AppSpacing.xl, AppSpacing.xxl, AppSpacing.xl, AppSpacing.xl),
      child: Column(
        children: [
          Container(
            padding: EdgeInsets.all(AppSize.s(3)),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.white.withValues(alpha: 0.28),
            ),
            child: TcAvatar(
              imageUrl: imagePath,
              fallbackIcon: fallbackIcon,
              size: AppSize.s(74),
              ring: false,
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          Text(
            name,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.center,
            style: GoogleFonts.plusJakartaSans(
              fontSize: AppSize.s(20),
              fontWeight: FontWeight.w800,
              color: Colors.white,
            ),
          ),
          if (role != null) ...[
            SizedBox(height: AppSize.s(4)),
            Text(
              role!,
              textAlign: TextAlign.center,
              style: GoogleFonts.plusJakartaSans(
                fontSize: AppSize.s(12.5),
                fontWeight: FontWeight.w500,
                color: Colors.white.withValues(alpha: 0.82),
              ),
            ),
          ],
          if (idLabel != null) ...[
            const SizedBox(height: AppSpacing.md),
            Container(
              padding: EdgeInsets.symmetric(
                  horizontal: AppSpacing.md, vertical: AppSize.s(6)),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.18),
                borderRadius: AppRadius.chip,
              ),
              child: Text(
                idLabel!,
                style: GoogleFonts.plusJakartaSans(
                  fontSize: AppSize.s(11.5),
                  fontWeight: FontWeight.w700,
                  letterSpacing: AppSize.s(0.4),
                  color: Colors.white,
                ),
              ),
            ),
          ],
          if (trailing != null) ...[
            const SizedBox(height: AppSpacing.lg),
            trailing!,
          ],
        ],
      ),
    );
  }
}

/// Section label plus a single card of [TcDetailRow]s separated by hairlines.
class TcDetailGroup extends StatelessWidget {
  const TcDetailGroup({
    super.key,
    required this.title,
    required this.children,
  });

  final String title;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    final rows = <Widget>[];
    for (var i = 0; i < children.length; i++) {
      if (i > 0) rows.add(const Divider(height: 1));
      rows.add(children[i]);
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.only(left: AppSize.s(4), bottom: AppSpacing.sm),
          child: Text(title.toUpperCase(), style: AppType.eyebrow),
        ),
        TcCard(
          padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.lg, vertical: AppSpacing.sm),
          child: Column(children: rows),
        ),
      ],
    );
  }
}
