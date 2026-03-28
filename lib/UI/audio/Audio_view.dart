import 'dart:math';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:scanner/UI/audio/Audio_view_model.dart';
import 'package:scanner/UI/components/Nexus_widgets/nexus_widgets.dart';
import 'package:scanner/UI/theme/app_theme.dart';
import 'package:stacked/stacked.dart';

class AudioView extends StatelessWidget {
  const AudioView({super.key});

  @override
  Widget build(BuildContext context) {
    return ViewModelBuilder<AudioViewModel>.reactive(
      viewModelBuilder: () => AudioViewModel(),
      builder: (context, viewModel, child) {
        return _AudioContent(viewModel: viewModel);
      },
    );
  }
}

class _AudioContent extends StatelessWidget {
  final AudioViewModel viewModel;

  const _AudioContent({required this.viewModel});

  @override
  Widget build(BuildContext context) {
    final vm = viewModel;

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
              _buildWaveformCard(vm),
              const SizedBox(height: 16),
              _buildTimerDisplay(vm),
              const SizedBox(height: 24),
              _buildControls(vm),
              const SizedBox(height: 24),
              _buildRecordingsList(vm),
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
            color: AppTheme.audioColor.withOpacity(0.15),
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
                color: AppTheme.audioColor.withOpacity(0.4), width: 1),
          ),
          child:
              const Icon(Icons.mic, color: AppTheme.audioColor, size: 18),
        ),
        const SizedBox(width: 12),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('AUDIO REC',
                style: GoogleFonts.orbitron(
                  color: AppTheme.textPrimary,
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 2,
                )),
            Text('Sound Capture Module',
                style: GoogleFonts.rajdhani(
                  color: AppTheme.audioColor,
                  fontSize: 11,
                  letterSpacing: 1,
                )),
          ],
        ),
        const Spacer(),
        NexusStatusDot(
          color: viewModel.isRecording
              ? AppTheme.neonGreen
              : AppTheme.textMuted,
          label: viewModel.isRecording
              ? viewModel.isPaused
                  ? 'PAUSED'
                  : 'REC'
              : 'IDLE',
        ),
      ],
    );
  }

  Widget _buildWaveformCard(AudioViewModel vm) {
    return NexusCard(
      glowColor: AppTheme.audioColor,
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('WAVEFORM',
              style: GoogleFonts.rajdhani(
                color: AppTheme.textMuted,
                fontSize: 10,
                letterSpacing: 2,
              )),
          const SizedBox(height: 12),
          SizedBox(
            height: 80,
            child: CustomPaint(
              painter: _WaveformPainter(
                bars: vm.waveformBars,
                color: AppTheme.audioColor,
                isActive: vm.isRecording && !vm.isPaused,
              ),
              size: const Size(double.infinity, 80),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTimerDisplay(AudioViewModel vm) {
    return Center(
      child: Text(
        vm.formattedDuration,
        style: GoogleFonts.orbitron(
          color: vm.isRecording ? AppTheme.audioColor : AppTheme.textMuted,
          fontSize: 48,
          fontWeight: FontWeight.w700,
          letterSpacing: 4,
        ),
      ),
    );
  }

  Widget _buildControls(AudioViewModel vm) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        if (vm.isRecording) ...[
          // Pause/Resume
          _CircleBtn(
            icon: vm.isPaused ? Icons.play_arrow : Icons.pause,
            color: AppTheme.neonOrange,
            onTap: vm.isPaused ? vm.resumeRecording : vm.pauseRecording,
          ),
          const SizedBox(width: 20),
        ],

        // Main record/stop button
        GestureDetector(
          onTap: vm.isRecording ? vm.stopRecording : vm.startRecording,
          child: Container(
            width: 72,
            height: 72,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: vm.isRecording
                  ? AppTheme.neonOrange.withOpacity(0.2)
                  : AppTheme.audioColor.withOpacity(0.2),
              border: Border.all(
                color: vm.isRecording
                    ? AppTheme.neonOrange
                    : AppTheme.audioColor,
                width: 2,
              ),
              boxShadow: [
                BoxShadow(
                  color: vm.isRecording
                      ? AppTheme.neonOrange.withOpacity(0.3)
                      : AppTheme.audioColor.withOpacity(0.3),
                  blurRadius: 20,
                  spreadRadius: 3,
                ),
              ],
            ),
            child: Icon(
              vm.isRecording ? Icons.stop : Icons.mic,
              color: vm.isRecording ? AppTheme.neonOrange : AppTheme.audioColor,
              size: 32,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildRecordingsList(AudioViewModel vm) {
    if (vm.recordings.isEmpty) {
      return Expanded(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.music_note,
                  color: AppTheme.textMuted.withOpacity(0.3), size: 48),
              const SizedBox(height: 12),
              Text('No recordings yet',
                  style: GoogleFonts.rajdhani(
                    color: AppTheme.textMuted,
                    fontSize: 14,
                    letterSpacing: 1,
                  )),
            ],
          ),
        ),
      );
    }

    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('RECORDINGS (${vm.recordings.length})',
              style: GoogleFonts.rajdhani(
                color: AppTheme.textMuted,
                fontSize: 10,
                letterSpacing: 2,
              )),
          const SizedBox(height: 8),
          Expanded(
            child: ListView.builder(
              itemCount: vm.recordings.length,
              itemBuilder: (context, index) {
                final rec = vm.recordings[index];
                return _RecordingTile(
                  recording: rec,
                  index: index,
                  onDelete: () => vm.deleteRecording(index),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _CircleBtn extends StatelessWidget {
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  const _CircleBtn(
      {required this.icon, required this.color, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 52,
        height: 52,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: color.withOpacity(0.15),
          border: Border.all(color: color.withOpacity(0.5), width: 1.5),
        ),
        child: Icon(icon, color: color, size: 24),
      ),
    );
  }
}

class _RecordingTile extends StatelessWidget {
  final AudioRecording recording;
  final int index;
  final VoidCallback onDelete;

  const _RecordingTile({
    required this.recording,
    required this.index,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: NexusCard(
        glowColor: AppTheme.audioColor,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          children: [
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: AppTheme.audioColor.withOpacity(0.15),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(Icons.audio_file,
                  color: AppTheme.audioColor, size: 18),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(recording.fileName,
                      style: GoogleFonts.rajdhani(
                        color: AppTheme.textPrimary,
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                      ),
                      overflow: TextOverflow.ellipsis),
                  Text(recording.formattedDuration,
                      style: GoogleFonts.orbitron(
                        color: AppTheme.audioColor,
                        fontSize: 11,
                      )),
                ],
              ),
            ),
            IconButton(
              icon: const Icon(Icons.play_circle_outline,
                  color: AppTheme.audioColor),
              onPressed: () {},
              iconSize: 24,
              padding: EdgeInsets.zero,
            ),
            IconButton(
              icon: const Icon(Icons.delete_outline,
                  color: AppTheme.textMuted),
              onPressed: onDelete,
              iconSize: 20,
              padding: EdgeInsets.zero,
            ),
          ],
        ),
      ),
    );
  }
}

class _WaveformPainter extends CustomPainter {
  final List<double> bars;
  final Color color;
  final bool isActive;

  _WaveformPainter(
      {required this.bars, required this.color, required this.isActive});

  @override
  void paint(Canvas canvas, Size size) {
    final barWidth = size.width / bars.length;
    final centerY = size.height / 2;
    final maxHeight = size.height / 2;

    for (int i = 0; i < bars.length; i++) {
      final barHeight = isActive
          ? max(2.0, bars[i] * maxHeight)
          : 2.0;

      final paint = Paint()
        ..shader = LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            color.withOpacity(0.9),
            color.withOpacity(0.3),
          ],
        ).createShader(
          Rect.fromLTWH(
            i * barWidth + barWidth * 0.1,
            centerY - barHeight,
            barWidth * 0.8,
            barHeight * 2,
          ),
        )
        ..style = PaintingStyle.fill;

      final rrect = RRect.fromRectAndRadius(
        Rect.fromLTWH(
          i * barWidth + barWidth * 0.15,
          centerY - barHeight,
          barWidth * 0.7,
          barHeight * 2,
        ),
        const Radius.circular(2),
      );
      canvas.drawRRect(rrect, paint);
    }
  }

  @override
  bool shouldRepaint(_WaveformPainter oldDelegate) =>
      oldDelegate.bars != bars || oldDelegate.isActive != isActive;
}