import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:pics_project/utils/image_downloader.dart';
import 'package:shimmer/shimmer.dart';
import 'package:pics_project/controller/unplash_controller.dart';

class HomeScreen extends StatelessWidget {
  final UnsplashController photoController = Get.put(UnsplashController());
  final ScrollController _scrollController = ScrollController();

  HomeScreen({super.key}) {
    _scrollController.addListener(() {
      if (_scrollController.position.pixels >=
              _scrollController.position.maxScrollExtent - 100 &&
          !photoController.isLoading.value &&
          !photoController.isDataLoadCompleted.value) {
        photoController.loadPhotos();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Popular Photos"),
        centerTitle: true,
      ),
      body: Obx(() {
        if (photoController.photos.isEmpty &&
            photoController.isLoading.isTrue) {
          return MasonryGridView.builder(
            gridDelegate: const SliverSimpleGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2),
            mainAxisSpacing: 8,
            crossAxisSpacing: 8,
            itemCount: 6,
            itemBuilder: (context, index) {
              return Shimmer.fromColors(
                baseColor: Colors.grey[300]!,
                highlightColor: Colors.grey[100]!,
                child: Container(
                  height: 150,
                  decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              );
            },
          );
        }

        if (photoController.photos.isEmpty &&
            photoController.isDataLoadCompleted.isTrue) {
          return const Center(child: Text("No photos available."));
        }

        return MasonryGridView.builder(
          controller: _scrollController,
          gridDelegate: const SliverSimpleGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2),
          mainAxisSpacing: 8,
          crossAxisSpacing: 8,
          itemCount: photoController.photos.length,
          itemBuilder: (context, index) {
            final photo = photoController.photos[index];
            var isIconsVisible = false.obs;
            var isLiked = false.obs;

            return GestureDetector(
              onTap: () {
                isIconsVisible.value = !isIconsVisible.value;
              },
              child: Obx(() {
                return Stack(
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: CachedNetworkImage(
                        imageUrl: photo.url,
                        placeholder: (context, url) => Shimmer.fromColors(
                          baseColor: Colors.grey[300]!,
                          highlightColor: Colors.grey[100]!,
                          child: Container(
                            height: 150,
                            color: Colors.grey[300],
                          ),
                        ),
                        errorWidget: (context, url, error) =>
                            const Icon(Icons.error),
                        fadeInDuration: const Duration(milliseconds: 300),
                        fit: BoxFit.cover,
                      ),
                    ),
                    if (isIconsVisible.value)
                      Positioned(
                        bottom: 10,
                        left: 10,
                        child: Row(
                          children: [
                            IconButton(
                              icon: Icon(
                                isLiked.value
                                    ? Icons.favorite
                                    : Icons.favorite_border,
                                color:
                                    isLiked.value ? Colors.red : Colors.white,
                              ),
                              onPressed: () {
                                isLiked.value = !isLiked.value;
                              },
                            ),
                            IconButton(
                              icon: const Icon(Icons.download,
                                  color: Colors.white),
                              onPressed: () async {
                                print("Download button pressed.");
                                if (photo.url != "" && photo.url.isNotEmpty) {
                                  try {
                                    await ImageDownloader.downloadImage(
                                        photo.url, 'downloaded_image.jpg');
                                    Get.snackbar(
                                      "Download Complete",
                                      "Image saved to gallery.",
                                      snackPosition: SnackPosition.BOTTOM,
                                      duration: const Duration(seconds: 3),
                                    );
                                  } catch (e) {
                                    Get.snackbar(
                                      "Download Failed",
                                      "An error occurred: $e",
                                      snackPosition: SnackPosition.BOTTOM,
                                      duration: const Duration(seconds: 3),
                                    );
                                  }
                                } else {
                                  Get.snackbar(
                                    "Download Failed",
                                    "Image URL is invalid or empty.",
                                    snackPosition: SnackPosition.BOTTOM,
                                    duration: const Duration(seconds: 3),
                                  );
                                }
                              },
                            ),
                          ],
                        ),
                      ),
                  ],
                );
              }),
            );
          },
        );
      }),
    );
  }
}
