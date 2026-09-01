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
  int _eventCount = 0;

  @override
  void initState() {
    super.initState();
    _loadEventCount();
  }

  Future<void> _loadEventCount() async {
    final count = await widget.controller.intelligenceService.getEventCount();
    if (mounted) setState(() => _eventCount = count);
  }

  Future<void> _handleExport() async {
    setState(() => _isExporting = true);
    try {
      final jsonString = await _exportImportService.exportToJsonString();

      final timestamp = DateTime.now().toIso8601String().replaceAll(':', '-').split('.').first;
      final defaultFileName = 'burn_think_backup_$timestamp.json';

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
        dialogTitle: 'Select Burn Think Backup JSON',
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
          ToastService.instance.show('Invalid Burn Think backup file.');
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
          await _loadEventCount();
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
        await _loadEventCount();
        ToastService.instance.show('Local workspace has been reset.');
      }
    }
  }

  Future<void> _handleClearLearningData() async {
    final confirmed = await ConfirmDialog.show(
      context,
      title: 'Clear Intelligence Learning History?',
      message:
          'This will clear locally stored event tracking and adaptive category correction feedback. Your tasks and notes will NOT be affected.',
      confirmLabel: 'Clear Learning Data',
      isDestructive: true,
    );

    if (confirmed == true && mounted) {
      await widget.controller.intelligenceService.clearLearningData();
      await _loadEventCount();
      ToastService.instance.show('Intelligence learning history cleared.');
    }
  }

  @override
  Widget build(BuildContext context) {
    final intelligence = widget.controller.intelligenceService;
    final settings = intelligence.settings;

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
                  Expanded(
                    child: Column(
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
                  ),
                  const SizedBox(width: AppSpacing.p12),
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

            // Personal Intelligence (PRD §22, §48, §60)
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('PERSONAL INTELLIGENCE', style: AppTypography.sectionHeader),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: AppColors.glassSubtle,
                    borderRadius: AppRadii.radius8,
                    border: Border.all(color: AppColors.glassBorderSubtle, width: 0.5),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.shield_outlined, size: 11, color: AppColors.metallicWhite),
                      const SizedBox(width: 4),
                      Text(
                        '100% Local & Private',
                        style: AppTypography.caption.copyWith(
                          fontSize: 10,
                          color: AppColors.metallicWhite,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.p12),
            GlassCard(
              padding: AppSpacing.insets20,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _IntelligenceSwitchRow(
                    title: 'Smart Categorization',
                    description: 'Suggests item type in Quick Add based on text patterns and keywords',
                    value: settings.enableSmartCategorization,
                    onChanged: (val) {
                      intelligence.updateSettings(
                        settings.copyWith(enableSmartCategorization: val),
                      );
                    },
                  ),
                  const Divider(color: AppColors.glassBorderSubtle, height: 24),
                  _IntelligenceSwitchRow(
                    title: "Today's Focus Prediction",
                    description: 'Ranks high-priority and urgent tasks for immediate focus',
                    value: settings.enablePriorityPrediction,
                    onChanged: (val) {
                      intelligence.updateSettings(
                        settings.copyWith(enablePriorityPrediction: val),
                      );
                    },
                  ),
                  const Divider(color: AppColors.glassBorderSubtle, height: 24),
                  _IntelligenceSwitchRow(
                    title: 'Related & Duplicate Item Detection',
                    description: 'Identifies similar entries to prevent duplicates across categories',
                    value: settings.enableRelatedItemDetection,
                    onChanged: (val) {
                      intelligence.updateSettings(
                        settings.copyWith(enableRelatedItemDetection: val),
                      );
                    },
                  ),
                  const Divider(color: AppColors.glassBorderSubtle, height: 24),
                  _IntelligenceSwitchRow(
                    title: 'Semantic & Fuzzy Search',
                    description: 'Matches meaning and token clusters across all workspace notes and tasks',
                    value: settings.enableSemanticSearch,
                    onChanged: (val) {
                      intelligence.updateSettings(
                        settings.copyWith(enableSemanticSearch: val),
                      );
                    },
                  ),
                  const Divider(color: AppColors.glassBorderSubtle, height: 24),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Local Learning Events', style: AppTypography.itemTitle),
                            const SizedBox(height: 2),
                            Text(
                              '$_eventCount workspace events recorded locally',
                              style: AppTypography.caption.copyWith(color: AppColors.textTertiary),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: AppSpacing.p12),
                      GlassButton(
                        text: 'Clear History',
                        onPressed: _handleClearLearningData,
                      ),
                    ],
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
                      Expanded(
                        child: Column(
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
                      ),
                      const SizedBox(width: AppSpacing.p12),
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
                      Expanded(
                        child: Column(
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
                      ),
                      const SizedBox(width: AppSpacing.p12),
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
                      Expanded(
                        child: Column(
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
                      ),
                      const SizedBox(width: AppSpacing.p12),
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
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ClipRRect(
                    borderRadius: AppRadii.radius10,
                    child: Image.asset(
                      'assets/icon/app_icon.png',
                      width: 44,
                      height: 44,
                      fit: BoxFit.cover,
                    ),
                  ),
                  const SizedBox(width: AppSpacing.p16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Burn Think',
                              style: AppTypography.cardTitle.copyWith(fontWeight: FontWeight.w700),
                            ),
                            Text(
                              'Version 1.0.0 + Intelligence',
                              style: AppTypography.caption.copyWith(color: AppColors.textTertiary),
                            ),
                          ],
                        ),
                        const SizedBox(height: 6),
                        Text(
                          'Lightweight offline personal desktop workspace with local intelligence.\nTake everything that is in your head and organize it in one focused place.',
                          style: AppTypography.body.copyWith(color: AppColors.textSecondary, height: 1.4),
                        ),
                      ],
                    ),
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

class _IntelligenceSwitchRow extends StatelessWidget {
  final String title;
  final String description;
  final bool value;
  final ValueChanged<bool> onChanged;

  const _IntelligenceSwitchRow({
    required this.title,
    required this.description,
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: AppTypography.itemTitle),
              const SizedBox(height: 2),
              Text(
                description,
                style: AppTypography.caption.copyWith(color: AppColors.textTertiary),
              ),
            ],
          ),
        ),
        const SizedBox(width: AppSpacing.p12),
        Switch(
          value: value,
          activeThumbColor: AppColors.metallicWhite,
          activeTrackColor: AppColors.glassHover,
          inactiveThumbColor: AppColors.textTertiary,
          inactiveTrackColor: AppColors.glassSubtle,
          onChanged: onChanged,
        ),
      ],
    );
  }
}
