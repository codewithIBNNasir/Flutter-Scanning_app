import 'dart:io';
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:scanner/UI/camera/camera_view_model.dart';
import 'package:scanner/UI/components/Nexus_widgets/nexus_widgets.dart';
import 'package:scanner/UI/theme/app_theme.dart';
import 'package:stacked/stacked.dart';


class CameraView extends StatelessWidget {
  const CameraView({super.key});

  @override
  Widget build(BuildContext context) {
    return ViewModelBuilder<CameraViewModel>.reactive(
      viewModelBuilder: () => CameraViewModel(),
      builder: (context, viewModel, child) {
        return _CameraContent(viewModel: viewModel);
      },
    );
  }
}

class _CameraContent extends StatefulWidget {
  final CameraViewModel viewModel;

  const _CameraContent({required this.viewModel});

  @override
  State<_CameraContent> createState() => _CameraContentState();
}

class _CameraContentState extends State<_CameraContent>
    with SingleTickerProviderStateMixin {
  late AnimationController _scanController;

  @override
  void initState() {
    super.initState();
    _scanController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat();
  }

  @override
  void dispose() {
    _scanController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final vm = widget.viewModel;

    return Scaffold(
      backgroundColor: AppTheme.background,
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(),
            Expanded(
              child: vm.capturedImagePath != null
                  ? _buildCapturedView(vm)
                  : _buildCameraSection(vm),
            ),
            _buildBottomControls(vm),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 0),
      child: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: AppTheme.cameraColor.withOpacity(0.15),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(
                  color: AppTheme.cameraColor.withOpacity(0.4), width: 1),
            ),
            child: const Icon(Icons.camera_alt,
                color: AppTheme.cameraColor, size: 18),
          ),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('CAMERA SCAN',
                  style: GoogleFonts.orbitron(
                    color: AppTheme.textPrimary,
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 2,
                  )),
              Text('Vision Module Active',
                  style: GoogleFonts.rajdhani(
                    color: AppTheme.cameraColor,
                    fontSize: 11,
                    letterSpacing: 1,
                  )),
            ],
          ),
          const Spacer(),
          NexusStatusDot(
            color: widget.viewModel.isReady
                ? AppTheme.neonGreen
                : AppTheme.neonOrange,
            label: widget.viewModel.isReady ? 'LIVE' : 'STANDBY',
          ),
        ],
      ),
    );
  }

  Widget _buildCameraSection(CameraViewModel vm) {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          const SizedBox(height: 8),
          Expanded(
            child: NexusCard(
              glowColor: AppTheme.cameraColor,
              padding: EdgeInsets.zero,
              borderRadius: 20,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(20),
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    // Camera preview or placeholder
                    if (vm.isReady && vm.cameraController != null)
                      CameraPreview(vm.cameraController!)
                    else
                      _buildCameraPlaceholder(vm),

                    // Corner brackets overlay
                    Padding(
                      padding: const EdgeInsets.all(24),
                      child: CustomPaint(
                        painter: CornerBracketPainter(
                          color: AppTheme.cameraColor,
                          strokeWidth: 3,
                        ),
                        child: Container(),
                      ),
                    ),

                    // Scan line animation
                    if (vm.isReady)
                      AnimatedBuilder(
                        animation: _scanController,
                        builder: (context, _) => CustomPaint(
                          painter: ScanLinePainter(
                            progress: _scanController.value,
                            color: AppTheme.cameraColor,
                          ),
                          child: Container(),
                        ),
                      ),

                    // Flash/switch controls
                    if (vm.isReady)
                      Positioned(
                        top: 12,
                        right: 12,
                        child: Column(
                          children: [
                            _IconBtn(
                              icon: vm.flashEnabled
                                  ? Icons.flash_on
                                  : Icons.flash_off,
                              color: vm.flashEnabled
                                  ? AppTheme.neonOrange
                                  : AppTheme.textMuted,
                              onTap: vm.toggleFlash,
                            ),
                            const SizedBox(height: 8),
                            _IconBtn(
                              icon: Icons.cameraswitch,
                              color: AppTheme.cameraColor,
                              onTap: vm.switchCamera,
                            ),
                          ],
                        ),
                      ),

                    // Status badge
                    Positioned(
                      bottom: 12,
                      left: 12,
                      right: 12,
                      child: Center(
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 14, vertical: 6),
                          decoration: BoxDecoration(
                            color: Colors.black.withOpacity(0.65),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            vm.statusMessage,
                            style: GoogleFonts.rajdhani(
                              color: AppTheme.cameraColor,
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              letterSpacing: 0.5,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCameraPlaceholder(CameraViewModel vm) {
    return Container(
      color: const Color(0xFF0A1520),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              vm.state == CameraState.error
                  ? Icons.error_outline
                  : Icons.camera_alt_outlined,
              color: AppTheme.cameraColor.withOpacity(0.4),
              size: 64,
            ),
            const SizedBox(height: 16),
            Text(
              vm.state == CameraState.initializing
                  ? 'INITIALIZING...'
                  : 'CAMERA OFFLINE',
              style: GoogleFonts.orbitron(
                color: AppTheme.textMuted,
                fontSize: 12,
                letterSpacing: 2,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCapturedView(CameraViewModel vm) {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          const SizedBox(height: 8),
          Expanded(
            child: NexusCard(
              glowColor: AppTheme.neonGreen,
              padding: EdgeInsets.zero,
              borderRadius: 20,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(20),
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    Image.file(
                      File(vm.capturedImagePath!),
                      fit: BoxFit.cover,
                    ),
                    Positioned(
                      top: 12,
                      left: 12,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 5),
                        decoration: BoxDecoration(
                          color: AppTheme.neonGreen.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                              color: AppTheme.neonGreen.withOpacity(0.5)),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(Icons.check_circle,
                                color: AppTheme.neonGreen, size: 14),
                            const SizedBox(width: 6),
                            Text('CAPTURED',
                                style: GoogleFonts.rajdhani(
                                  color: AppTheme.neonGreen,
                                  fontSize: 11,
                                  fontWeight: FontWeight.w700,
                                  letterSpacing: 1.5,
                                )),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: NexusButton(
                  label: 'Retake',
                  color: AppTheme.textMuted,
                  icon: Icons.refresh,
                  onTap: vm.clearCapture,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: NexusButton(
                  label: 'Save',
                  color: AppTheme.neonGreen,
                  icon: Icons.save_alt,
                  onTap: () {},
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildBottomControls(CameraViewModel vm) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
      child: !vm.isReady && vm.capturedImagePath == null
          ? NexusButton(
              label: vm.state == CameraState.initializing
                  ? 'Initializing...'
                  : 'Initialize Camera',
              color: AppTheme.cameraColor,
              icon: Icons.camera_alt,
              isLoading: vm.state == CameraState.initializing,
              onTap: vm.state == CameraState.idle ||
                      vm.state == CameraState.error
                  ? vm.initCamera
                  : null,
            )
          : vm.capturedImagePath == null
              ? GestureDetector(
                  onTap: vm.captureImage,
                  child: Container(
                    height: 70,
                    decoration: BoxDecoration(
                      shape: BoxShape.rectangle,
                      borderRadius: BorderRadius.circular(35),
                      border: Border.all(
                          color: AppTheme.cameraColor.withOpacity(0.5),
                          width: 2),
                    ),
                    child: Center(
                      child: Container(
                        width: 52,
                        height: 52,
                        decoration: BoxDecoration(
                          color: AppTheme.cameraColor,
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: AppTheme.cameraColor.withOpacity(0.5),
                              blurRadius: 16,
                              spreadRadius: 2,
                            ),
                          ],
                        ),
                        child: const Icon(Icons.camera_alt,
                            color: Colors.black, size: 24),
                      ),
                    ),
                  ),
                )
              : const SizedBox.shrink(),
    );
  }
}

class _IconBtn extends StatelessWidget {
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  const _IconBtn(
      {required this.icon, required this.color, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 38,
        height: 38,
        decoration: BoxDecoration(
          color: Colors.black.withOpacity(0.6),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: color.withOpacity(0.4)),
        ),
        child: Icon(icon, color: color, size: 18),
      ),
    );
  }
}