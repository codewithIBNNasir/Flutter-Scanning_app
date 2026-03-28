import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:scanner/UI/components/Nexus_widgets/nexus_widgets.dart';
import 'package:scanner/UI/fingerprint/fingerPrint_view_model.dart';
import 'package:scanner/UI/theme/app_theme.dart';
import 'package:stacked/stacked.dart';


class FingerprintView extends StatelessWidget {
  const FingerprintView({super.key});

  @override
  Widget build(BuildContext context) {
    return ViewModelBuilder<FingerprintViewModel>.reactive(
      viewModelBuilder: () => FingerprintViewModel(),
      onViewModelReady: (vm) => vm.checkBiometrics(),
      builder: (context, viewModel, child) {
        return _FingerprintContent(viewModel: viewModel);
      },
    );
  }
}

class _FingerprintContent extends StatefulWidget {
  final FingerprintViewModel viewModel;

  const _FingerprintContent({required this.viewModel});

  @override
  State<_FingerprintContent> createState() => _FingerprintContentState();
}

class _FingerprintContentState extends State<_FingerprintContent>
    with TickerProviderStateMixin {
  late AnimationController _pulseController;
  late AnimationController _rippleController;
  late Animation<double> _pulseAnim;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat(reverse: true);

    _rippleController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2000),
    );

    _pulseAnim = Tween<double>(begin: 0.9, end: 1.1).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _pulseController.dispose();
    _rippleController.dispose();
    super.dispose();
  }

  Color get _stateColor {
    switch (widget.viewModel.state) {
      case FingerprintState.scanning:
        return AppTheme.fingerprintColor;
      case FingerprintState.success:
        return AppTheme.neonGreen;
      case FingerprintState.failure:
        return AppTheme.neonOrange;
      case FingerprintState.unavailable:
        return AppTheme.textMuted;
      default:
        return AppTheme.fingerprintColor;
    }
  }

  IconData get _stateIcon {
    switch (widget.viewModel.state) {
      case FingerprintState.success:
        return Icons.check_circle;
      case FingerprintState.failure:
        return Icons.cancel;
      case FingerprintState.unavailable:
        return Icons.fingerprint;
      default:
        return Icons.fingerprint;
    }
  }

  @override
  Widget build(BuildContext context) {
    final vm = widget.viewModel;

    if (vm.isScanning && !_rippleController.isAnimating) {
      _rippleController.repeat();
    } else if (!vm.isScanning && _rippleController.isAnimating) {
      _rippleController.stop();
    }

    return Scaffold(
      backgroundColor: AppTheme.background,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHeader(),
              const SizedBox(height: 24),
              _buildScannerArea(vm),
              const SizedBox(height: 24),
              _buildStatsRow(vm),
              const SizedBox(height: 24),
              _buildStatusCard(vm),
              const Spacer(),
              _buildScanButton(vm),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
      children: [
        Container(
          width: 36,
          height: 36,
          decoration: BoxDecoration(
            color: AppTheme.fingerprintColor.withOpacity(0.15),
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
                color: AppTheme.fingerprintColor.withOpacity(0.4), width: 1),
          ),
          child: const Icon(Icons.fingerprint,
              color: AppTheme.fingerprintColor, size: 18),
        ),
        const SizedBox(width: 12),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('BIOMETRIC',
                style: GoogleFonts.orbitron(
                  color: AppTheme.textPrimary,
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 2,
                )),
            Text('Auth Module',
                style: GoogleFonts.rajdhani(
                  color: AppTheme.fingerprintColor,
                  fontSize: 11,
                  letterSpacing: 1,
                )),
          ],
        ),
        const Spacer(),
        NexusStatusDot(
          color: widget.viewModel.biometricAvailable
              ? AppTheme.neonGreen
              : AppTheme.textMuted,
          label: widget.viewModel.biometricAvailable ? 'READY' : 'N/A',
        ),
      ],
    );
  }

  Widget _buildScannerArea(FingerprintViewModel vm) {
    return Center(
      child: SizedBox(
        width: 240,
        height: 240,
        child: Stack(
          alignment: Alignment.center,
          children: [
            // Outer ripple rings
            if (vm.isScanning)
              ...List.generate(3, (i) {
                return AnimatedBuilder(
                  animation: _rippleController,
                  builder: (context, _) {
                    final delay = i * 0.33;
                    final progress =
                        (_rippleController.value + delay) % 1.0;
                    return Container(
                      width: 100 + progress * 140,
                      height: 100 + progress * 140,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: _stateColor
                              .withOpacity(0.6 * (1 - progress)),
                          width: 1.5,
                        ),
                      ),
                    );
                  },
                );
              }),

            // Main circle
            AnimatedBuilder(
              animation: vm.isScanning ? _pulseAnim : _pulseController,
              builder: (context, child) => Transform.scale(
                scale: vm.isScanning ? _pulseAnim.value : 1.0,
                child: child,
              ),
              child: Container(
                width: 160,
                height: 160,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: _stateColor.withOpacity(0.08),
                  border: Border.all(
                    color: _stateColor.withOpacity(0.5),
                    width: 2,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: _stateColor.withOpacity(0.2),
                      blurRadius: 30,
                      spreadRadius: 5,
                    ),
                  ],
                ),
                child: Icon(
                  _stateIcon,
                  color: _stateColor,
                  size: 80,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatsRow(FingerprintViewModel vm) {
    return Row(
      children: [
        Expanded(
          child: NexusCard(
            glowColor: AppTheme.fingerprintColor,
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('SCAN COUNT',
                    style: GoogleFonts.rajdhani(
                      color: AppTheme.textMuted,
                      fontSize: 10,
                      letterSpacing: 1.5,
                    )),
                const SizedBox(height: 4),
                Text('${vm.scanCount}',
                    style: GoogleFonts.orbitron(
                      color: AppTheme.fingerprintColor,
                      fontSize: 28,
                      fontWeight: FontWeight.w700,
                    )),
              ],
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: NexusCard(
            glowColor: vm.lastAuthResult ? AppTheme.neonGreen : AppTheme.neonOrange,
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('LAST RESULT',
                    style: GoogleFonts.rajdhani(
                      color: AppTheme.textMuted,
                      fontSize: 10,
                      letterSpacing: 1.5,
                    )),
                const SizedBox(height: 4),
                Text(
                  vm.scanCount == 0
                      ? '---'
                      : vm.lastAuthResult
                          ? 'PASS'
                          : 'FAIL',
                  style: GoogleFonts.orbitron(
                    color: vm.scanCount == 0
                        ? AppTheme.textMuted
                        : vm.lastAuthResult
                            ? AppTheme.neonGreen
                            : AppTheme.neonOrange,
                    fontSize: 28,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildStatusCard(FingerprintViewModel vm) {
    return NexusCard(
      glowColor: _stateColor,
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: _stateColor.withOpacity(0.15),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(
              vm.isScanning ? Icons.sensors : Icons.info_outline,
              color: _stateColor,
              size: 20,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              vm.statusMessage,
              style: GoogleFonts.rajdhani(
                color: AppTheme.textSecondary,
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildScanButton(FingerprintViewModel vm) {
    return NexusButton(
      label: vm.isScanning ? 'Scanning...' : 'Scan Biometric',
      color: AppTheme.fingerprintColor,
      icon: Icons.fingerprint,
      isLoading: vm.isScanning,
      onTap: vm.isScanning ? null : vm.authenticate,
    );
  }
}