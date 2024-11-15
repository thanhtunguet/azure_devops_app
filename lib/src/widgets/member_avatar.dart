import 'package:azure_devops/src/router/router.dart';
import 'package:azure_devops/src/services/azure_api_service.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

class MemberAvatar extends StatelessWidget {
  const MemberAvatar({
    super.key,
    required this.userDescriptor,
    this.imageUrl,
    this.radius = 40,
    this.tappable = true,
  });

  final String? imageUrl;
  final String? userDescriptor;
  final double radius;
  final bool tappable;

  Future<void> _goToMemberDetail() async {
    await AppRouter.goToMemberDetail(userDescriptor!);
  }

  @override
  Widget build(BuildContext context) {
    if (imageUrl == null &&
        (userDescriptor == null || userDescriptor!.isEmpty)) {
      return const SizedBox();
    }

    final apiService = AzureApiServiceInherited.of(context).apiService;
    final url = imageUrl ?? apiService.getUserAvatarUrl(userDescriptor!);
    return InkWell(
      onTap: tappable ? _goToMemberDetail : null,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(100),
        child: apiService.organization.isEmpty
            ? const SizedBox()
            : CachedNetworkImage(
                imageUrl: url,
                height: radius,
                width: radius,
                httpHeaders: apiService.headers,
                errorWidget: (_, __, ___) => const SizedBox(),
                fit: BoxFit.cover,
              ),
      ),
    );
  }
}
