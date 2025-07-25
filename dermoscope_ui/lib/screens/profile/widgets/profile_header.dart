import 'package:dermoscope_ui/core/theme/app_colors.dart';
import 'package:dermoscope_ui/screens/profile/widgets/card_container.dart';
import 'package:flutter/material.dart';

class ProfileHeader extends StatelessWidget {
  const ProfileHeader({super.key});

  void _showPhotoOptions(BuildContext context) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'Profil Fotoğrafı',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _PhotoOption(
                    icon: Icons.camera_alt,
                    label: 'Kamera',
                    onTap: () {
                      // TODO: Kamera işlemi
                      Navigator.pop(context);
                    },
                  ),
                  _PhotoOption(
                    icon: Icons.photo,
                    label: 'Galeri',
                    onTap: () {
                      // TODO: Galeri işlemi
                      Navigator.pop(context);
                    },
                  ),
                  _PhotoOption(
                    icon: Icons.delete,
                    label: 'Kaldır',
                    onTap: () {
                      // TODO: Fotoğrafı kaldır
                      Navigator.pop(context);
                    },
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return CardContainer(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            GestureDetector(
              onTap: () => _showPhotoOptions(context),
              child: Stack(
                alignment: Alignment.bottomRight,
                children: [
                  const CircleAvatar(
                    radius: 48,
                    backgroundImage: AssetImage(
                      'assets/images/profile_placeholder.png',
                    ),
                  ),
                  Container(
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: AppColors.primary,
                    ),
                    padding: const EdgeInsets.all(6),
                    child: const Icon(
                      Icons.camera_alt,
                      size: 18,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            const Text(
              "Fotoğrafı değiştirmek için dokunun",
              style: TextStyle(color: AppColors.textSecondary),
            ),
          ],
        ),
      ),
    );
  }
}

class _PhotoOption extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _PhotoOption({
    required this.icon,
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
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.secondary.withOpacity(0.1),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Icon(icon, size: 28, color: AppColors.primary),
          ),
          const SizedBox(height: 8),
          Text(label),
        ],
      ),
    );
  }
}
