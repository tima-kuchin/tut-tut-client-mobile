import 'package:flutter/material.dart';
import '../models/route_card.dart';

class RouteCardItem extends StatelessWidget {
  final RouteCard route;
  final VoidCallback onTap;

  const RouteCardItem({
    Key? key,
    required this.route,
    required this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 200,
        margin: const EdgeInsets.only(bottom: 16),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          image: DecorationImage(
            image: route.thumbnailUrl != null
                ? NetworkImage(route.thumbnailUrl!)
                : const AssetImage('assets/images/route_placeholder.jpg')
            as ImageProvider,
            fit: BoxFit.cover,
            colorFilter: ColorFilter.mode(
              Colors.black.withOpacity(0.3),
              BlendMode.darken,
            ),
          ),
        ),
        child: Stack(
          children: [
            Positioned(
              left: 16, top: 16, right: 16,
              child: Text(
                route.name,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            Positioned(
              left: 16, top: 42,
              child: Text(
                route.location,
                style: const TextStyle(
                  color: Colors.white70,
                  fontSize: 14,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            Positioned(
              left: 16, bottom: 16,
              child: Row(
                children: [
                  const Icon(Icons.favorite_border, color: Colors.white, size: 18),
                  const SizedBox(width: 4),
                  Text('${route.likesCount}', style: const TextStyle(color: Colors.white)),
                  const SizedBox(width: 16),
                  const Icon(Icons.comment, color: Colors.white, size: 18),
                  const SizedBox(width: 4),
                  Text('${route.commentsCount}', style: const TextStyle(color: Colors.white)),
                  const SizedBox(width: 16),
                  Icon(
                    route.isFavorite ? Icons.bookmark : Icons.bookmark_border,
                    color: Colors.white, size: 18,
                  ),
                ],
              ),
            ),
            Positioned(
              right: 16, bottom: 16,
              child: Row(
                children: [
                  const Icon(Icons.star, color: Colors.amber, size: 18),
                  const SizedBox(width: 4),
                  Text(
                    route.avgRating.toStringAsFixed(1),
                    style: const TextStyle(color: Colors.white),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
