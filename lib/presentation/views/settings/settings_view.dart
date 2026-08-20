import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import '../../../core/constants/colors.dart';
import '../../../core/constants/radii.dart';
import '../../../core/constants/spacing.dart';
import '../../../core/constants/typography.dart';
import '../../../core/database/app_database.dart';
import '../../../core/services/export_import_service.dart';
import '../../../core/services/toast_service.dart';
import '../../state/workspace_controller.dart';
import '../../widgets/glass/glass_button.dart';
import '../../widgets/glass/glass_card.dart';
import '../../widgets/glass/glass_surface.dart';
import '../../widgets/modals/confirm_dialog.dart';

class SettingsView extends StatefulWidget {
  final WorkspaceController controller;

  const SettingsView({super.key, required this.controller});

  @override
  State<SettingsView> createState() => _SettingsViewState();
}

class _SettingsViewState extends State<SettingsView> {
  final _exportImportService = ExportImportService();
  bool _isExporting = false;
  bool _isImporting = false;

  Future<void> _handleExport() async {
    setState(() => _isExporting = true);
    try {
      final jsonString = await _exportImportService.exportToJsonString();

      final timestamp = DateTime.now().toIso8601String().replaceAll(':', '-').split('.').first;
      final defaultFileName = 'burn_shut_backup_$timestamp.json';

      final outputFile = await FilePicker.platform.saveFile(
        dialogTitle: 'Save Workspace Backup',
        fileName: defaultFileName,
        type: FileType.custom,
        allowedExtensions: ['json'],
      );

      if (outputFile != null) {
        final file = File(outputFile);
        await file.writeAsString(jsonString);
        ToastService.instance.show('Workspace exported successfully');
      } else {
        // Fallback: save into downloads or documents
        final docDir = await getApplicationDocumentsDirectory();
        final fallbackPath = '${docDir.path}/$defaultFileName';
        final file = File(fallbackPath);
        await file.writeAsString(jsonString);
        ToastService.instance.show('Backup saved to $fallbackPath');
      }
    } catch (e) {
      ToastService.instance.show('Export failed: $e');
    } finally {
      if (mounted) setState(() => _isExporting = false);
    }
  }

  Future<void> _handleImport() async {
    setState(() => _isImporting = true);
    try {
      final result = await FilePicker.platform.pickFiles(
        dialogTitle: 'Select Burn Shut Backup JSON',
        type: FileType.custom,
        allowedExtensions: ['json'],
      );

      if (result != null && result.files.isNotEmpty) {
        final path = result.files.first.path;
        if (path == null) return;

        final file = File(path);
        final jsonString = await file.readAsString();

        final isValid = _exportImportService.validateJson(jsonString);
        if (!isValid) {
          ToastService.instance.show('Invalid Burn Shut backup file.');
          return;
        }

        if (!mounted) return;

        // Ask user: Merge or Replace
        final replaceConfirmed = await showDialog<bool>(
          context: context,
          builder: (context) {
            return Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 440),
                child: GlassSurface(
                  level: GlassLevel.elevated,
                  borderRadius: AppRadii.radius20,
                  padding: AppSpacing.insets24,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Import Options', style: AppTypography.cardTitle.copyWith(fontSize: 17)),
                      const SizedBox(height: AppSpacing.p12),
                      Text(
                        'How would you like to restore this backup?',
                        style: AppTypography.body.copyWith(color: AppColors.textSecondary),
                      ),
                      const SizedBox(height: AppSpacing.p20),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          GlassButton(
                            text: 'Merge',
                            onPressed: () => Navigator.of(context).pop(false),
                          ),
                          const SizedBox(width: AppSpacing.p12),
                          GlassButton.destructive(
                            text: 'Replace All',
                            onPressed: () => Navigator.of(context).pop(true),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        );

        if (replaceConfirmed == null) return;

        final importResult = await _exportImportService.importFromJsonString(
          jsonString,
          replace: replaceConfirmed,
        );

        if (importResult.success) {
          await widget.controller.refreshAllData();
          ToastService.instance.show(importResult.message);
        } else {
          ToastService.instance.show('Import error: ${importResult.message}');
        }
      }
    } catch (e) {
      ToastService.instance.show('Import failed: $e');
    } finally {
      if (mounted) setState(() => _isImporting = false);
    }
  }

  Future<void> _handleResetDatabase() async {
    final confirmedFirst = await ConfirmDialog.show(
      context,
      title: 'Reset Entire Workspace?',
      message:
          'This will permanently delete all tasks, projects, workouts, notes, content ideas, and shopping items. Your data cannot be recovered without a backup.',
      confirmLabel: 'Yes, Proceed',
      isDestructive: true,
    );

    if (confirmedFirst == true && mounted) {
      final confirmedSecond = await ConfirmDialog.show(
        context,
        title: 'Final Confirmation',
        message: 'Are you absolutely sure you want to wipe all local data?',
        confirmLabel: 'Permanently Erase All Data',
        isDestructive: true,
      );

      if (confirmedSecond == true && mounted) {
        await AppDatabase.instance.resetDatabase();
        await widget.controller.refreshAllData();
        ToastService.instance.show('Local workspace has been reset.');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.p32, vertical: AppSpacing.p8),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 720),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Appearance
            const Text('APPEARANCE', style: AppTypography.sectionHeader),
            const SizedBox(height: AppSpacing.p12),
            GlassCard(
              padding: AppSpacing.insets16,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Dark Glass Theme', style: AppTypography.itemTitle),
                      const SizedBox(height: 2),
                      Text(
                        'Monochrome workspace with subtle glass materials',
                        style: AppTypography.caption.copyWith(color: AppColors.textTertiary),
                      ),
                    ],
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: AppColors.glassSubtle,
                      borderRadius: AppRadii.radius8,
                      border: Border.all(color: AppColors.glassBorderSubtle, width: 0.5),
                    ),
                    child: Text(
                      'Default',
                      style: AppTypography.caption.copyWith(color: AppColors.metallicWhite),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: AppSpacing.p28),

            // Data Management
            const Text('DATA & BACKUP', style: AppTypography.sectionHeader),
            const SizedBox(height: AppSpacing.p12),
            GlassCard(
              padding: AppSpacing.insets20,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Export Workspace', style: AppTypography.itemTitle),
                          const SizedBox(height: 2),
                          Text(
                            'Save a structured JSON backup of your offline workspace',
                            style: AppTypography.caption.copyWith(color: AppColors.textTertiary),
                          ),
                        ],
                      ),
                      GlassButton(
                        text: 'Export JSON',
                        isLoading: _isExporting,
                        onPressed: _handleExport,
                      ),
                    ],
                  ),

                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: AppSpacing.p16),
                    child: Divider(color: AppColors.glassBorderSubtle, height: 1),
                  ),

                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Import Workspace', style: AppTypography.itemTitle),
                          const SizedBox(height: 2),
                          Text(
                            'Restore or merge data from a previously saved JSON backup',
                            style: AppTypography.caption.copyWith(color: AppColors.textTertiary),
                          ),
                        ],
                      ),
                      GlassButton(
                        text: 'Import JSON',
                        isLoading: _isImporting,
                        onPressed: _handleImport,
                      ),
                    ],
                  ),

                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: AppSpacing.p16),
                    child: Divider(color: AppColors.glassBorderSubtle, height: 1),
                  ),

                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Reset All Data',
                            style: AppTypography.itemTitle.copyWith(color: AppColors.danger),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            'Permanently erase local SQLite database',
                            style: AppTypography.caption.copyWith(color: AppColors.textTertiary),
                          ),
                        ],
                      ),
                      GlassButton.destructive(
                        text: 'Reset Database',
                        onPressed: _handleResetDatabase,
                      ),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: AppSpacing.p28),

            // About
            const Text('ABOUT', style: AppTypography.sectionHeader),
            const SizedBox(height: AppSpacing.p12),
            GlassCard(
              padding: AppSpacing.insets20,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Burn Shut',
                        style: AppTypography.cardTitle.copyWith(fontWeight: FontWeight.w700),
                      ),
                      Text(
                        'Version 1.0.0',
                        style: AppTypography.caption.copyWith(color: AppColors.textTertiary),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'Lightweight offline personal desktop workspace.\nTake everything that is in your head and organize it in one focused place.',
                    style: AppTypography.body.copyWith(color: AppColors.textSecondary, height: 1.4),
                  ),
                ],
              ),
            ),

            const SizedBox(height: AppSpacing.p40),
          ],
        ),
      ),
    );
  }
}
