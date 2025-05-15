import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

class Avatar extends StatelessWidget {
  final String? imageUrl;
  final double size;
  final bool isNetworkImage;

  const Avatar({
    super.key,
    required this.imageUrl,
    this.size = 50.0,
    this.isNetworkImage = false,
  });

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(size / 2),
      child:
          (imageUrl != null && imageUrl!.isNotEmpty)
              ? (isNetworkImage
                  ? Image.network(
                    imageUrl!,
                    width: size,
                    height: size,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return _buildDefaultIcon();
                    },
                  )
                  : Image.asset(
                    imageUrl!,
                    width: size,
                    height: size,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return _buildDefaultIcon();
                    },
                  ))
              : _buildDefaultIcon(),
    );
  }

  Widget _buildDefaultIcon() {
    return Container(
      width: size,
      height: size,
      color: Colors.grey.shade200,
      child: Icon(LucideIcons.user, size: size * 0.6, color: Colors.grey),
    );
  }
}
