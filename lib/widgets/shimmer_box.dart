import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

Widget shimmerBox({double height = 20, double width = double.infinity}) {
  return Shimmer.fromColors(
    baseColor: Colors.grey.shade300,
    highlightColor: Colors.grey.shade100,
    child: Container(
      height: height,
      width: width,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
      ),
    ),
  );
}
