import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:scanner/UI/audio/Qrcode_view_model.dart';
import 'package:scanner/UI/components/Nexus_widgets/nexus_widgets.dart';
import 'package:scanner/UI/theme/app_theme.dart';
import 'package:stacked/stacked.dart';



class QrScannerView extends StatelessWidget {
  const QrScannerView({super.key});

  @override
  Widget build(BuildContext context) {
    return ViewModelBuilder<QrScannerViewModel>.reactive(
      viewModelBuilder: () => QrScannerViewModel(),
      builder: (context, viewModel, child) {
        return _QrContent(viewModel: viewModel);
      },
    );
  }
}

class _QrContent extends StatefulWidget {
  final QrScannerViewModel viewModel;
  const _QrContent({required this.viewModel});

  @override
  State<_QrContent> createState() => _QrContentState();
}

class _QrContentState extends State<_QrContent>
    with SingleTickerProviderStateMixin {
  late AnimationController _scanLineController;

  @override
  void initState() {
    super.initState();
    _scanLineController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat();
  }

  @override
  void dispose() {
    _scanLineController.dispose();
    super.dispose();
  }

  Color get _stateColor {
    switch (widget.viewModel.state) {
      case QrState.found:
        return AppTheme.neonGreen;
      case QrState.error:
        return AppTheme.neonOrange;
      default:
        return AppTheme.qrColor;
    }
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
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: _buildScannerFrame(vm),
            ),
            const SizedBox(height: 12),
            _buildStatusBadge(vm),
            const SizedBox(height: 12),
            _buildControls(vm),
            const SizedBox(height: 12),
            Expanded(child: _buildResultsList(vm)),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(QrScannerViewModel vm) {
    return Row(
      children: [
        Container(
          width: 36,
          height: 36,
          decoration: BoxDecoration(
            color: AppTheme.qrColor.withOpacity(0.15),
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
                color: AppTheme.qrColor.withOpacity(0.4), width: 1),
          ),
          child: const Icon(Icons.qr_code_scanner,
              color: AppTheme.qrColor, size: 18),
        ),
        const SizedBox(width: 12),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('QR SCANNER',
                style: GoogleFonts.orbitron(
                  color: AppTheme.textPrimary,
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 2,
                )),
            Text('Decode Module Active',
                style: GoogleFonts.rajdhani(
                  color: AppTheme.qrColor,
                  fontSize: 11,
                  letterSpacing: 1,
                )),
          ],
        ),
        const Spacer(),
        NexusStatusDot(
          color: vm.isScanning ? AppTheme.neonGreen : AppTheme.textMuted,
          label: vm.isScanning ? 'LIVE' : 'IDLE',
        ),
      ],
    );
  }

  Widget _buildScannerFrame(QrScannerViewModel vm) {
    return AspectRatio(
      aspectRatio: 1,
      child: NexusCard(
        glowColor: _stateColor,
        padding: EdgeInsets.zero,
        borderRadius: 20,
        child: ClipRRect(
          borderRadius: BorderRadius.circular(20),
          child: Stack(
            fit: StackFit.expand,
            children: [
              // Scanner or placeholder
              if (vm.isScanning)
                MobileScanner(
                  controller: vm.scannerController,
                  onDetect: vm.onDetect,
                )
              else
                Container(
                  color: const Color(0xFF0A0F18),
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.qr_code_2,
                          color: AppTheme.qrColor.withOpacity(0.25),
                          size: 80,
                        ),
                        const SizedBox(height: 16),
                        Text('TAP SCAN TO BEGIN',
                            style: GoogleFonts.orbitron(
                              color: AppTheme.textMuted,
                              fontSize: 11,
                              letterSpacing: 2,
                            )),
                      ],
                    ),
                  ),
                ),

              // Scan line animation
              if (vm.isScanning)
                AnimatedBuilder(
                  animation: _scanLineController,
                  builder: (context, _) => CustomPaint(
                    painter: ScanLinePainter(
                      progress: _scanLineController.value,
                      color: _stateColor,
                    ),
                    child: Container(),
                  ),
                ),

              // Corner brackets
              Padding(
                padding: const EdgeInsets.all(20),
                child: CustomPaint(
                  painter:
                      CornerBracketPainter(color: _stateColor, strokeWidth: 3),
                  child: Container(),
                ),
              ),

              // Camera controls overlay
              if (vm.isScanning)
                Positioned(
                  top: 12,
                  right: 12,
                  child: Column(
                    children: [
                      _QrIconBtn(
                        icon: vm.torchOn ? Icons.flash_on : Icons.flash_off,
                        color: vm.torchOn
                            ? AppTheme.neonOrange
                            : AppTheme.textMuted,
                        onTap: vm.toggleTorch,
                      ),
                      const SizedBox(height: 8),
                      _QrIconBtn(
                        icon: Icons.cameraswitch,
                        color: AppTheme.qrColor,
                        onTap: vm.switchCamera,
                      ),
                    ],
                  ),
                ),

              // Found overlay flash
              if (vm.state == QrState.found)
                Container(
                  decoration: BoxDecoration(
                    border: Border.all(
                      color: AppTheme.neonGreen.withOpacity(0.6),
                      width: 3,
                    ),
                    borderRadius: BorderRadius.circular(20),
                    color: AppTheme.neonGreen.withOpacity(0.05),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatusBadge(QrScannerViewModel vm) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: AppTheme.cardBg,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: _stateColor.withOpacity(0.3)),
        ),
        child: Row(
          children: [
            Icon(
              vm.state == QrState.found
                  ? Icons.check_circle
                  : Icons.info_outline,
              color: _stateColor,
              size: 16,
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                vm.statusMessage,
                style: GoogleFonts.rajdhani(
                  color: AppTheme.textSecondary,
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            Text(
              '${vm.results.length} scanned',
              style: GoogleFonts.rajdhani(
                color: AppTheme.textMuted,
                fontSize: 11,
                letterSpacing: 0.5,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildControls(QrScannerViewModel vm) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        children: [
          Expanded(
            child: NexusButton(
              label: vm.isScanning ? 'Stop Scan' : 'Start Scan',
              color: vm.isScanning ? AppTheme.neonOrange : AppTheme.qrColor,
              icon: vm.isScanning ? Icons.stop : Icons.qr_code_scanner,
              onTap: vm.isScanning ? vm.stopScanning : vm.startScanning,
            ),
          ),
          if (vm.results.isNotEmpty) ...[
            const SizedBox(width: 10),
            GestureDetector(
              onTap: vm.clearResults,
              child: Container(
                height: 48,
                width: 48,
                decoration: BoxDecoration(
                  color: AppTheme.cardBg,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                      color: AppTheme.textMuted.withOpacity(0.3), width: 1),
                ),
                child: const Icon(Icons.delete_sweep_outlined,
                    color: AppTheme.textMuted, size: 20),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildResultsList(QrScannerViewModel vm) {
    if (vm.results.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.document_scanner_outlined,
                color: AppTheme.textMuted.withOpacity(0.3), size: 40),
            const SizedBox(height: 10),
            Text('No codes scanned yet',
                style: GoogleFonts.rajdhani(
                  color: AppTheme.textMuted,
                  fontSize: 14,
                )),
          ],
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 0, 20, 8),
          child: Text('SCAN HISTORY',
              style: GoogleFonts.rajdhani(
                color: AppTheme.textMuted,
                fontSize: 10,
                letterSpacing: 2,
              )),
        ),
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            itemCount: vm.results.length,
            itemBuilder: (context, index) {
              final result = vm.results[index];
              return Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: NexusCard(
                  glowColor: index == 0 && vm.state == QrState.found
                      ? AppTheme.neonGreen
                      : AppTheme.qrColor,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                  child: Row(
                    children: [
                      Container(
                        width: 36,
                        height: 36,
                        decoration: BoxDecoration(
                          color: AppTheme.qrColor.withOpacity(0.15),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Icon(Icons.qr_code,
                            color: AppTheme.qrColor, size: 18),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(result.value,
                                style: GoogleFonts.rajdhani(
                                  color: AppTheme.textPrimary,
                                  fontSize: 13,
                                  fontWeight: FontWeight.w600,
                                ),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis),
                            const SizedBox(height: 2),
                            Text(result.formatName,
                                style: GoogleFonts.rajdhani(
                                  color: AppTheme.qrColor,
                                  fontSize: 10,
                                  letterSpacing: 1,
                                )),
                          ],
                        ),
                      ),
                      // Copy button
                      GestureDetector(
                        onTap: () {
                          Clipboard.setData(
                              ClipboardData(text: result.value));
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('Copied to clipboard',
                                  style: GoogleFonts.rajdhani()),
                              backgroundColor: AppTheme.qrColor,
                              duration: const Duration(seconds: 1),
                            ),
                          );
                        },
                        child: const Padding(
                          padding: EdgeInsets.symmetric(horizontal: 6),
                          child: Icon(Icons.copy,
                              color: AppTheme.qrColor, size: 16),
                        ),
                      ),
                      GestureDetector(
                        onTap: () => vm.deleteResult(index),
                        child: const Icon(Icons.close,
                            color: AppTheme.textMuted, size: 16),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}

class _QrIconBtn extends StatelessWidget {
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  const _QrIconBtn(
      {required this.icon, required this.color, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 36,
        height: 36,
        decoration: BoxDecoration(
          color: Colors.black.withOpacity(0.6),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: color.withOpacity(0.4)),
        ),
        child: Icon(icon, color: color, size: 18),
      ),
    );
  }
}