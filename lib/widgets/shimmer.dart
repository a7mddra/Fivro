import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

class Loading extends StatelessWidget {
  final bool isLoading;
  final Widget loadingContent;
  final Widget loadedContent;

  const Loading({
    super.key,
    required this.isLoading,
    required this.loadedContent,
    required this.loadingContent,
  });

  @override
  Widget build(BuildContext context) {
    return isLoading
        ? Shimmer.fromColors(
            baseColor: Colors.grey[300]!,
            highlightColor: Colors.grey[100]!,
            child: loadingContent,
          )
        : loadedContent;
  }
}
