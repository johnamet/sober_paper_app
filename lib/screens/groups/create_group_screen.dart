import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_text_styles.dart';
import '../../core/constants/app_spacing.dart';
import '../../core/widgets/paper_card.dart';
import '../../domain/entities/group.dart';
import '../../providers/providers.dart';

/// Screen for creating a new support group
/// 
/// Features:
/// - Enter group name and description
/// - Select group category (Support, Prayer, Discussion)
/// - Toggle private/public visibility
/// - Set max members
class CreateGroupScreen extends ConsumerStatefulWidget {
  const CreateGroupScreen({super.key});

  @override
  ConsumerState<CreateGroupScreen> createState() => _CreateGroupScreenState();
}

class _CreateGroupScreenState extends ConsumerState<CreateGroupScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();
  
  GroupCategory _selectedCategory = GroupCategory.support;
  bool _isPrivate = false;
  int _maxMembers = 50;
  bool _isCreating = false;

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _createGroup() async {
    if (!_formKey.currentState!.validate()) return;
    if (_isCreating) return;

    setState(() => _isCreating = true);

    try {
      final currentUserId = ref.read(currentUserIdProvider);
      
      if (currentUserId == null) {
        throw Exception('Please log in to create a group');
      }

      final group = await ref.read(createGroupProvider)(
        name: _nameController.text.trim(),
        description: _descriptionController.text.trim(),
        createdBy: currentUserId,
        category: _selectedCategory,
        isPrivate: _isPrivate,
        maxMembers: _maxMembers,
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${group.name} created successfully!'),
            backgroundColor: AppColors.graceGreen,
          ),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to create group: ${e.toString()}'),
            backgroundColor: AppColors.panicRed,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isCreating = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.paperCream,
      appBar: AppBar(
        title: Text('Create Group', style: AppTextStyles.h1),
        backgroundColor: Colors.transparent,
        foregroundColor: AppColors.inkBlack,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSpacing.screenPadding),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _buildInfoCard(),
              const SizedBox(height: AppSpacing.lg),
              _buildNameField(),
              const SizedBox(height: AppSpacing.md),
              _buildDescriptionField(),
              const SizedBox(height: AppSpacing.lg),
              _buildCategorySelector(),
              const SizedBox(height: AppSpacing.lg),
              _buildPrivacyToggle(),
              const SizedBox(height: AppSpacing.md),
              _buildMaxMembersSlider(),
              const SizedBox(height: AppSpacing.xl),
              _buildCreateButton(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInfoCard() {
    return PaperCard(
      backgroundColor: AppColors.holyBlue.withOpacity(0.1),
      child: Row(
        children: [
          Icon(
            Icons.info_outline,
            color: AppColors.holyBlue,
            size: 24,
          ),
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            child: Text(
              'Create a space for others to find support, share prayers, or discuss recovery topics.',
              style: AppTextStyles.bodySmall.copyWith(
                color: AppColors.inkBrown,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNameField() {
    return PaperCard(
      padding: const EdgeInsets.all(AppSpacing.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Group Name', style: AppTextStyles.h3),
          const SizedBox(height: AppSpacing.sm),
          TextFormField(
            controller: _nameController,
            decoration: InputDecoration(
              hintText: 'e.g., Daily Prayer Warriors',
              hintStyle: AppTextStyles.bodyMedium.copyWith(
                color: AppColors.inkFaded,
              ),
              filled: true,
              fillColor: AppColors.paperCream,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide(color: AppColors.paperEdge),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide(color: AppColors.paperEdge),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide(color: AppColors.holyBlue, width: 2),
              ),
            ),
            style: AppTextStyles.bodyMedium,
            maxLength: 50,
            validator: (value) {
              if (value == null || value.trim().isEmpty) {
                return 'Please enter a group name';
              }
              if (value.trim().length < 3) {
                return 'Name must be at least 3 characters';
              }
              return null;
            },
          ),
        ],
      ),
    );
  }

  Widget _buildDescriptionField() {
    return PaperCard(
      padding: const EdgeInsets.all(AppSpacing.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Description', style: AppTextStyles.h3),
          const SizedBox(height: AppSpacing.sm),
          TextFormField(
            controller: _descriptionController,
            decoration: InputDecoration(
              hintText: 'Describe your group\'s purpose and who it\'s for...',
              hintStyle: AppTextStyles.bodyMedium.copyWith(
                color: AppColors.inkFaded,
              ),
              filled: true,
              fillColor: AppColors.paperCream,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide(color: AppColors.paperEdge),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide(color: AppColors.paperEdge),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide(color: AppColors.holyBlue, width: 2),
              ),
            ),
            style: AppTextStyles.bodyMedium,
            maxLines: 4,
            maxLength: 300,
            validator: (value) {
              if (value == null || value.trim().isEmpty) {
                return 'Please enter a description';
              }
              if (value.trim().length < 10) {
                return 'Description must be at least 10 characters';
              }
              return null;
            },
          ),
        ],
      ),
    );
  }

  Widget _buildCategorySelector() {
    return PaperCard(
      padding: const EdgeInsets.all(AppSpacing.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Category', style: AppTextStyles.h3),
          const SizedBox(height: AppSpacing.md),
          Row(
            children: GroupCategory.values.map((category) {
              final isSelected = _selectedCategory == category;
              return Expanded(
                child: Padding(
                  padding: EdgeInsets.only(
                    right: category != GroupCategory.values.last ? 8.0 : 0,
                  ),
                  child: _CategoryChip(
                    category: category,
                    isSelected: isSelected,
                    onTap: () {
                      setState(() => _selectedCategory = category);
                    },
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildPrivacyToggle() {
    return PaperCard(
      padding: const EdgeInsets.all(AppSpacing.md),
      child: Row(
        children: [
          Icon(
            _isPrivate ? Icons.lock_outline : Icons.public,
            color: _isPrivate ? AppColors.warningAmber : AppColors.graceGreen,
            size: 24,
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _isPrivate ? 'Private Group' : 'Public Group',
                  style: AppTextStyles.h3,
                ),
                Text(
                  _isPrivate
                      ? 'Only invited members can join'
                      : 'Anyone can find and join this group',
                  style: AppTextStyles.caption,
                ),
              ],
            ),
          ),
          Switch(
            value: _isPrivate,
            onChanged: (value) {
              setState(() => _isPrivate = value);
            },
            activeColor: AppColors.warningAmber,
            inactiveThumbColor: AppColors.graceGreen,
            inactiveTrackColor: AppColors.graceGreen.withOpacity(0.3),
          ),
        ],
      ),
    );
  }

  Widget _buildMaxMembersSlider() {
    return PaperCard(
      padding: const EdgeInsets.all(AppSpacing.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Maximum Members', style: AppTextStyles.h3),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.holyBlue.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  '$_maxMembers',
                  style: AppTextStyles.h3.copyWith(color: AppColors.holyBlue),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.sm),
          Slider(
            value: _maxMembers.toDouble(),
            min: 5,
            max: 100,
            divisions: 19,
            activeColor: AppColors.holyBlue,
            inactiveColor: AppColors.holyBlue.withOpacity(0.2),
            onChanged: (value) {
              setState(() => _maxMembers = value.round());
            },
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('5', style: AppTextStyles.caption),
              Text('100', style: AppTextStyles.caption),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildCreateButton() {
    return ElevatedButton(
      onPressed: _isCreating ? null : _createGroup,
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.holyBlue,
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(vertical: 16),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        disabledBackgroundColor: AppColors.inkFaded,
      ),
      child: _isCreating
          ? const SizedBox(
              width: 24,
              height: 24,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
              ),
            )
          : Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.add_circle_outline),
                const SizedBox(width: 8),
                Text('Create Group', style: AppTextStyles.button),
              ],
            ),
    );
  }
}

/// Category chip for selecting group type
class _CategoryChip extends StatelessWidget {
  final GroupCategory category;
  final bool isSelected;
  final VoidCallback onTap;

  const _CategoryChip({
    required this.category,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    IconData icon;
    String label;
    Color color;

    switch (category) {
      case GroupCategory.support:
        icon = Icons.favorite_outline;
        label = 'Support';
        color = AppColors.panicRed;
        break;
      case GroupCategory.prayer:
        icon = Icons.church_outlined;
        label = 'Prayer';
        color = AppColors.crossGold;
        break;
      case GroupCategory.discussion:
        icon = Icons.forum_outlined;
        label = 'Discussion';
        color = AppColors.holyBlue;
        break;
    }

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: isSelected ? color.withOpacity(0.15) : Colors.transparent,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: isSelected ? color : AppColors.paperEdge,
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Column(
          children: [
            Icon(
              icon,
              color: isSelected ? color : AppColors.inkFaded,
              size: 24,
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: AppTextStyles.caption.copyWith(
                color: isSelected ? color : AppColors.inkFaded,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
