import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:scanner/UI/components/Nexus_widgets/nexus_widgets.dart';
import 'package:scanner/UI/theme/app_theme.dart';
import 'package:scanner/UI/vidio/vidio_view_model.dart';
import 'package:stacked/stacked.dart';


class VideoView extends StatelessWidget {
  const VideoView({super.key});

  @override
  Widget build(BuildContext context) {
    return ViewModelBuilder<VideoViewModel>.reactive(
      viewModelBuilder: () => VideoViewModel(),
      builder: (context, viewModel, child) {
        return _VideoContent(viewModel: viewModel);
      },
    );
  }
}

class _VideoContent extends StatefulWidget {
  final VideoViewModel viewModel;
  const _VideoContent({required this.viewModel});

  @override
  State<_VideoContent> createState() => _VideoContentState();
}

class _VideoContentState extends State<_VideoContent>
    with SingleTickerProviderStateMixin {
  late AnimationController _recDotController;

  @override
  void initState() {
    super.initState();
    _recDotController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _recDotController.dispose();
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
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 0),
              child: _buildHeader(vm),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: _buildVideoSection(vm),
              ),
            ),
            _buildBottomPanel(vm),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(VideoViewModel vm) {
    return Row(
      children: [
        Container(
          width: 36,
          height: 36,
          decoration: BoxDecoration(
            color: AppTheme.videoColor.withOpacity(0.15),
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
                color: AppTheme.videoColor.withOpacity(0.4), width: 1),
          ),
          child: const Icon(Icons.videocam,
              color: AppTheme.videoColor, size: 18),
        ),
        const SizedBox(width: 12),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('VIDEO REC',
                style: GoogleFonts.orbitron(
                  color: AppTheme.textPrimary,
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 2,
                )),
            Text('Visual Capture Module',
                style: GoogleFonts.rajdhani(
                  color: AppTheme.videoColor,
                  fontSize: 11,
                  letterSpacing: 1,
                )),
          ],
        ),
        const Spacer(),
        if (vm.isRecording)
          AnimatedBuilder(
            animation: _recDotController,
            builder: (context, _) => Row(
              children: [
                Container(
                  width: 8,
                  height: 8,
                  decoration: BoxDecoration(
                    color: Colors.red
                        .withOpacity(0.5 + _recDotController.value * 0.5),
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 6),
                Text('REC',
                    style: GoogleFonts.orbitron(
                      color: Colors.red,
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                    )),
              ],
            ),
          )
        else
          NexusStatusDot(
            color: vm.isReady ? AppTheme.neonGreen : AppTheme.textMuted,
            label: vm.isReady ? 'READY' : 'OFFLINE',
          ),
      ],
    );
  }

  Widget _buildVideoSection(VideoViewModel vm) {
    return NexusCard(
      glowColor: vm.isRecording ? Colors.red : AppTheme.videoColor,
      padding: EdgeInsets.zero,
      borderRadius: 20,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: Stack(
          fit: StackFit.expand,
          children: [
            // Camera preview
            if (vm.isReady || vm.isRecording || vm.isPaused)
              if (vm.cameraController != null &&
                  vm.cameraController!.value.isInitialized)
                CameraPreview(vm.cameraController!)
              else
                _placeholder(vm)
            else
              _placeholder(vm),

            // Duration overlay when recording
            if (vm.isRecording || vm.isPaused)
              Positioned(
                top: 16,
                left: 16,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.7),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                        color: Colors.red.withOpacity(0.5), width: 1),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (vm.isRecording)
                        AnimatedBuilder(
                          animation: _recDotController,
                          builder: (context, _) => Container(
                            width: 6,
                            height: 6,
                            decoration: BoxDecoration(
                              color: Colors.red.withOpacity(
                                  0.5 + _recDotController.value * 0.5),
                              shape: BoxShape.circle,
                            ),
                          ),
                        )
                      else
                        const Icon(Icons.pause,
                            color: AppTheme.neonOrange, size: 10),
                      const SizedBox(width: 6),
                      Text(
                        vm.formattedDuration,
                        style: GoogleFonts.orbitron(
                          color: Colors.white,
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                ),
              ),

            // Corner brackets
            Padding(
              padding: const EdgeInsets.all(16),
              child: CustomPaint(
                painter: CornerBracketPainter(
                  color: vm.isRecording
                      ? Colors.red.withOpacity(0.7)
                      : AppTheme.videoColor.withOpacity(0.5),
                ),
                child: Container(),
              ),
            ),

            // Flash toggle
            if (vm.isReady || vm.isRecording)
              Positioned(
                top: 12,
                right: 12,
                child: GestureDetector(
                  onTap: vm.toggleFlash,
                  child: Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.6),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: vm.flashEnabled
                            ? AppTheme.neonOrange
                            : AppTheme.textMuted.withOpacity(0.3),
                      ),
                    ),
                    child: Icon(
                      vm.flashEnabled ? Icons.flash_on : Icons.flash_off,
                      color: vm.flashEnabled
                          ? AppTheme.neonOrange
                          : AppTheme.textMuted,
                      size: 18,
                    ),
                  ),
                ),
              ),

            // Status bar
            Positioned(
              bottom: 12,
              left: 12,
              right: 12,
              child: Center(
                child: Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 14, vertical: 6),
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.6),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    vm.statusMessage,
                    style: GoogleFonts.rajdhani(
                      color: AppTheme.videoColor,
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _placeholder(VideoViewModel vm) {
    return Container(
      color: const Color(0xFF0A1015),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.videocam_off_outlined,
              color: AppTheme.videoColor.withOpacity(0.3),
              size: 64,
            ),
            const SizedBox(height: 12),
            Text(
              vm.isInitializing ? 'INITIALIZING...' : 'VIDEO OFFLINE',
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

  Widget _buildBottomPanel(VideoViewModel vm) {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 20),
      child: Column(
        children: [
          // Controls
          if (!vm.isReady && !vm.isRecording && !vm.isPaused)
            NexusButton(
              label: vm.isInitializing ? 'Initializing...' : 'Init Camera',
              color: AppTheme.videoColor,
              icon: Icons.videocam,
              isLoading: vm.isInitializing,
              onTap: vm.state == VideoState.idle || vm.state == VideoState.error
                  ? vm.initCamera
                  : null,
            )
          else
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (vm.isRecording || vm.isPaused) ...[
                  _CtrlBtn(
                    icon: vm.isPaused ? Icons.play_arrow : Icons.pause,
                    color: AppTheme.neonOrange,
                    label: vm.isPaused ? 'Resume' : 'Pause',
                    onTap: vm.isPaused
                        ? vm.resumeRecording
                        : vm.pauseRecording,
                  ),
                  const SizedBox(width: 16),
                ],
                GestureDetector(
                  onTap: vm.isRecording || vm.isPaused
                      ? vm.stopRecording
                      : vm.startRecording,
                  child: Container(
                    width: 68,
                    height: 68,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: vm.isRecording
                          ? Colors.red.withOpacity(0.2)
                          : AppTheme.videoColor.withOpacity(0.2),
                      border: Border.all(
                        color: vm.isRecording ? Colors.red : AppTheme.videoColor,
                        width: 2,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: vm.isRecording
                              ? Colors.red.withOpacity(0.3)
                              : AppTheme.videoColor.withOpacity(0.3),
                          blurRadius: 20,
                          spreadRadius: 2,
                        ),
                      ],
                    ),
                    child: Icon(
                      vm.isRecording || vm.isPaused
                          ? Icons.stop
                          : Icons.fiber_manual_record,
                      color: vm.isRecording ? Colors.red : AppTheme.videoColor,
                      size: 30,
                    ),
                  ),
                ),
              ],
            ),

          // Recordings list
          if (vm.recordings.isNotEmpty) ...[
            const SizedBox(height: 16),
            SizedBox(
              height: 72,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                itemCount: vm.recordings.length,
                separatorBuilder: (_, __) => const SizedBox(width: 8),
                itemBuilder: (context, i) {
                  final rec = vm.recordings[i];
                  return Container(
                    width: 110,
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: AppTheme.cardBg,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                          color: AppTheme.videoColor.withOpacity(0.3)),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            const Icon(Icons.video_file,
                                color: AppTheme.videoColor, size: 14),
                            const Spacer(),
                            GestureDetector(
                              onTap: () => vm.deleteRecording(i),
                              child: const Icon(Icons.close,
                                  color: AppTheme.textMuted, size: 12),
                            ),
                          ],
                        ),
                        const Spacer(),
                        Text(rec.formattedDuration,
                            style: GoogleFonts.orbitron(
                              color: AppTheme.videoColor,
                              fontSize: 12,
                              fontWeight: FontWeight.w700,
                            )),
                      ],
                    ),
                  );
                },
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _CtrlBtn extends StatelessWidget {
  final IconData icon;
  final Color color;
  final String label;
  final VoidCallback onTap;

  const _CtrlBtn({
    required this.icon,
    required this.color,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: color.withOpacity(0.15),
              border: Border.all(color: color.withOpacity(0.5), width: 1.5),
            ),
            child: Icon(icon, color: color, size: 22),
          ),
          const SizedBox(height: 4),
          Text(label,
              style: GoogleFonts.rajdhani(
                color: color,
                fontSize: 10,
                letterSpacing: 0.5,
              )),
        ],
      ),
    );
  }
}