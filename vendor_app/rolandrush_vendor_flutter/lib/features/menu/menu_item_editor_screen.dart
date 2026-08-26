import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import '../../core/media_upload_service.dart';
import '../../core/theme.dart';
import '../../models/vendor_menu_item.dart';
import '../../widgets/app_button.dart';
import '../../widgets/app_field.dart';
import '../../widgets/app_screen.dart';
import '../../widgets/primitives.dart';
import '../dashboard/providers/vendor_session_provider.dart';
import 'providers/menu_manager_provider.dart';

const _prepOptions = [10, 15, 20, 25, 30, 45];
const _defaultCategories = ['Rice & grains', 'Grills', 'Swallow', 'Wraps', 'Drinks', 'Small chops'];

/// Resolves [itemId] against the already-loaded menu list (MenuManager
/// always loads before this route is reachable) so the router only needs
/// to pass a path param, not a whole object.
class MenuItemEditorScreen extends ConsumerWidget {
  final String? itemId;
  const MenuItemEditorScreen({super.key, this.itemId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final vendorId = ref.watch(vendorSessionProvider)?.id ?? '';
    VendorMenuItem? existing;
    if (itemId != null && vendorId.isNotEmpty) {
      final items = ref.watch(menuManagerProvider(vendorId)).items;
      try {
        existing = items.firstWhere((i) => i.id == itemId);
      } catch (_) {}
    }
    return _MenuItemEditorForm(existing: existing);
  }
}

class _MenuItemEditorForm extends ConsumerStatefulWidget {
  final VendorMenuItem? existing;
  const _MenuItemEditorForm({this.existing});

  @override
  ConsumerState<_MenuItemEditorForm> createState() => _MenuItemEditorScreenState();
}

class _MenuItemEditorScreenState extends ConsumerState<_MenuItemEditorForm> {
  late final name = TextEditingController(text: widget.existing?.name ?? '');
  late final description = TextEditingController(text: widget.existing?.description ?? '');
  late final price = TextEditingController(text: widget.existing?.price != null && widget.existing!.price > 0 ? widget.existing!.price.toStringAsFixed(0) : '');
  late String category = widget.existing?.category ?? _defaultCategories.first;
  late int prepTime = widget.existing?.preparationTime ?? 20;
  late bool available = widget.existing?.isAvailable ?? true;
  bool saving = false;
  bool uploading = false;

  File? pickedImage;
  File? pickedVideo;
  final _picker = ImagePicker();

  bool get valid => name.text.trim().length > 1 && (double.tryParse(price.text) ?? 0) > 0;

  Future<void> _pickImage() async {
    final file = await _picker.pickImage(source: ImageSource.gallery, imageQuality: 85);
    if (file != null) setState(() => pickedImage = File(file.path));
  }

  Future<void> _pickVideo() async {
    final file = await _picker.pickVideo(source: ImageSource.gallery);
    if (file != null) setState(() => pickedVideo = File(file.path));
  }

  @override
  Widget build(BuildContext context) {
    final categories = {..._defaultCategories, if (widget.existing?.category != null) widget.existing!.category!}.toList();

    return Scaffold(
      backgroundColor: AppColors.canvas,
      appBar: AppScreenHeader(title: widget.existing != null ? 'Edit item' : 'New menu item', onBack: () => context.pop()),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: GestureDetector(
                          onTap: uploading ? null : _pickImage,
                          child: Container(
                            height: 112,
                            clipBehavior: Clip.antiAlias,
                            decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(AppRadius.card), border: Border.all(color: AppColors.line)),
                            alignment: Alignment.center,
                            child: pickedImage != null
                                ? Image.file(pickedImage!, fit: BoxFit.cover, width: double.infinity, height: double.infinity)
                                : widget.existing?.imageUrl != null
                                    ? Image.network(widget.existing!.imageUrl!, fit: BoxFit.cover, width: double.infinity, height: double.infinity)
                                    : const Icon(Icons.add_photo_alternate_outlined, size: 24, color: AppColors.inkSubtle),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      GestureDetector(
                        onTap: uploading ? null : _pickVideo,
                        child: Container(
                          width: 112,
                          height: 112,
                          decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(AppRadius.card), border: Border.all(color: AppColors.lineStrong)),
                          alignment: Alignment.center,
                          child: pickedVideo != null
                              ? Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    const Icon(Icons.videocam, size: 20, color: AppColors.ink),
                                    const SizedBox(height: 4),
                                    Text(pickedVideo!.path.split(Platform.pathSeparator).last, textAlign: TextAlign.center, maxLines: 1, overflow: TextOverflow.ellipsis, style: AppTheme.sans(size: 10, weight: FontWeight.w600, color: AppColors.inkMuted)),
                                  ],
                                )
                              : Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    const Icon(Icons.videocam_outlined, size: 20, color: AppColors.inkSubtle),
                                    const SizedBox(height: 4),
                                    Text(widget.existing?.videoUrl != null ? 'Replace video' : 'Add 15s video', textAlign: TextAlign.center, style: AppTheme.sans(size: 10, weight: FontWeight.w600, color: AppColors.inkMuted)),
                                  ],
                                ),
                        ),
                      ),
                    ],
                  ),
                  if (uploading) ...[
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        const SizedBox(width: 14, height: 14, child: CircularProgressIndicator(strokeWidth: 2)),
                        const SizedBox(width: 8),
                        Text('Uploading media…', style: AppTheme.sans(size: 12, color: AppColors.inkMuted)),
                      ],
                    ),
                  ],
                  const SizedBox(height: 16),
                  AppField(label: 'Item name', child: AppTextInput(controller: name, placeholder: 'e.g. Party Jollof + Chicken')),
                  const SizedBox(height: 16),
                  AppField(label: 'Description', hint: 'One clear line. Customers read this under the video.', child: AppTextArea(controller: description, rows: 3)),
                  const SizedBox(height: 16),
                  AppField(label: 'Price', child: AppMoneyInput(controller: price)),
                  const SizedBox(height: 16),
                  AppField(
                    label: 'Category',
                    child: Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: categories.map((c) => AppChip(label: c, active: category == c, onTap: () => setState(() => category = c))).toList(),
                    ),
                  ),
                  const SizedBox(height: 16),
                  AppField(
                    label: 'Prep time',
                    child: Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: _prepOptions.map((m) => AppChip(label: '$m min', active: prepTime == m, onTap: () => setState(() => prepTime = m))).toList(),
                    ),
                  ),
                  const SizedBox(height: 16),
                  AppCard(
                    child: Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('Available now', style: AppTheme.sans(size: 14, weight: FontWeight.w600)),
                              Text('Turn off when you run out today.', style: AppTheme.sans(size: 12, color: AppColors.inkMuted)),
                            ],
                          ),
                        ),
                        AppToggle(checked: available, onChanged: (v) => setState(() => available = v)),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 20),
            child: AppButton(
              full: true,
              size: AppButtonSize.lg,
              onPressed: valid && !saving && !uploading ? _save : null,
              child: saving
                  ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                  : Text(widget.existing != null ? 'Save changes' : 'Add to menu'),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _save() async {
    String? imageUrl = widget.existing?.imageUrl;
    String? videoUrl = widget.existing?.videoUrl;

    // Upload first, and stop here on failure — a failed upload must not
    // submit an item with a missing image/video, and the vendor's typed
    // fields (name/price/etc.) stay intact so they can just retry.
    if (pickedImage != null || pickedVideo != null) {
      setState(() => uploading = true);
      try {
        if (pickedImage != null) {
          imageUrl = await MediaUploadService.upload(file: pickedImage!, mediaType: 'image');
        }
        if (pickedVideo != null) {
          videoUrl = await MediaUploadService.upload(file: pickedVideo!, mediaType: 'video');
        }
      } on MediaUploadException catch (e) {
        if (!mounted) return;
        setState(() => uploading = false);
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.message)));
        return;
      } catch (_) {
        if (!mounted) return;
        setState(() => uploading = false);
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Media upload failed. Please try again.')));
        return;
      }
      if (!mounted) return;
      setState(() => uploading = false);
    }

    setState(() => saving = true);
    final vendorId = ref.read(vendorSessionProvider)?.id ?? '';
    final item = VendorMenuItem(
      id: widget.existing?.id ?? '',
      vendorId: vendorId,
      name: name.text.trim(),
      description: description.text.trim(),
      price: double.tryParse(price.text) ?? 0,
      category: category,
      imageUrl: imageUrl,
      videoUrl: videoUrl,
      isAvailable: available,
      preparationTime: prepTime,
    );
    final notifier = ref.read(menuManagerProvider(vendorId).notifier);
    final ok = widget.existing != null ? await notifier.updateItem(item) : await notifier.createItem(item);
    if (!mounted) return;
    setState(() => saving = false);
    if (ok) {
      context.pop();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Could not save item')));
    }
  }
}

/// AppChip is defined in the customer app's primitives — vendor app needs
/// its own since the two Flutter apps don't share a package.
class AppChip extends StatelessWidget {
  final String label;
  final bool active;
  final VoidCallback onTap;
  const AppChip({super.key, required this.label, required this.active, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 9),
        decoration: BoxDecoration(
          color: active ? AppColors.ink : Colors.white,
          borderRadius: BorderRadius.circular(999),
          border: active ? null : Border.all(color: AppColors.lineStrong),
        ),
        child: Text(label, style: AppTheme.sans(size: 13, weight: FontWeight.w600, color: active ? Colors.white : AppColors.inkMuted)),
      ),
    );
  }
}
