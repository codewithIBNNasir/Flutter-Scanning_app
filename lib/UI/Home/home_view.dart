import 'package:flutter/material.dart';
import 'package:scanner/UI/Home/home_view_model.dart';
import 'package:scanner/UI/theme/app_theme.dart';
import 'package:stacked/stacked.dart';
import 'package:google_fonts/google_fonts.dart';


class HomeView extends StatelessWidget {
  const HomeView({super.key});

  @override
  Widget build(BuildContext context) {
    return ViewModelBuilder<HomeViewModel>.reactive(
      viewModelBuilder: () => HomeViewModel(),
      builder: (context, viewModel, child) {
        return Scaffold(
          backgroundColor: AppTheme.background,
          extendBody: true,
          body: IndexedStack(
            index: viewModel.currentIndex,
            children: viewModel.pages,
          ),
          bottomNavigationBar: _NexusBottomNav(
            currentIndex: viewModel.currentIndex,
            onTap: viewModel.setIndex,
          ),
        );
      },
    );
  }
}

class _NexusBottomNav extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int> onTap;

  const _NexusBottomNav({
    required this.currentIndex,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final items = [
      _NavItem(
        icon: Icons.camera_alt_outlined,
        activeIcon: Icons.camera_alt,
        label: 'Camera',
        color: AppTheme.cameraColor,
      ),
      _NavItem(
        icon: Icons.fingerprint_outlined,
        activeIcon: Icons.fingerprint,
        label: 'Biometric',
        color: AppTheme.fingerprintColor,
      ),
      _NavItem(
        icon: Icons.mic_none_outlined,
        activeIcon: Icons.mic,
        label: 'Audio',
        color: AppTheme.audioColor,
      ),
      _NavItem(
        icon: Icons.videocam_outlined,
        activeIcon: Icons.videocam,
        label: 'Video',
        color: AppTheme.videoColor,
      ),
      _NavItem(
        icon: Icons.qr_code_scanner_outlined,
        activeIcon: Icons.qr_code_scanner,
        label: 'QR Scan',
        color: AppTheme.qrColor,
      ),
    ];

    return Container(
      decoration: BoxDecoration(
        color: AppTheme.surface,
        border: Border(
          top: BorderSide(
            color: AppTheme.border,
            width: 1,
          ),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.4),
            blurRadius: 24,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: SafeArea(
        child: SizedBox(
          height: 64,
          child: Row(
            children: List.generate(items.length, (index) {
              final item = items[index];
              final isActive = currentIndex == index;

              return Expanded(
                child: GestureDetector(
                  onTap: () => onTap(index),
                  behavior: HitTestBehavior.opaque,
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 250),
                    curve: Curves.easeOutCubic,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        AnimatedContainer(
                          duration: const Duration(milliseconds: 250),
                          width: isActive ? 44 : 36,
                          height: isActive ? 44 : 36,
                          decoration: BoxDecoration(
                            color: isActive
                                ? item.color.withOpacity(0.15)
                                : Colors.transparent,
                            borderRadius: BorderRadius.circular(12),
                            border: isActive
                                ? Border.all(
                                    color: item.color.withOpacity(0.4),
                                    width: 1,
                                  )
                                : null,
                            boxShadow: isActive
                                ? [
                                    BoxShadow(
                                      color: item.color.withOpacity(0.25),
                                      blurRadius: 12,
                                      spreadRadius: 0,
                                    ),
                                  ]
                                : null,
                          ),
                          child: Icon(
                            isActive ? item.activeIcon : item.icon,
                            color: isActive
                                ? item.color
                                : AppTheme.textMuted,
                            size: isActive ? 22 : 20,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          item.label,
                          style: GoogleFonts.rajdhani(
                            color: isActive ? item.color : AppTheme.textMuted,
                            fontSize: 9,
                            fontWeight: isActive
                                ? FontWeight.w700
                                : FontWeight.w500,
                            letterSpacing: 0.8,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            }),
          ),
        ),
      ),
    );
  }
}

class _NavItem {
  final IconData icon;
  final IconData activeIcon;
  final String label;
  final Color color;

  const _NavItem({
    required this.icon,
    required this.activeIcon,
    required this.label,
    required this.color,
  });
}