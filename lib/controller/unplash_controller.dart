import 'dart:convert'; 
import 'package:get/get.dart'; 
import 'package:http/http.dart' as http;
import 'package:pics_project/model/photo_model.dart'; 

class UnsplashController extends GetxController {
  final String accessKey = "XD6sMh8LE2c7dMfUtQ09VlIZrUHnzUWu4P5pP6TdWEo";

  var isLoading = false.obs; 
  var isDataLoadCompleted = false.obs; 
  var photos = <PhotoModel>[].obs; 
  var currentPage = 1; 

  @override
  void onInit() {
    super.onInit();
    loadPhotos(); 
  }

  Future<void> loadPhotos() async {
    if (isLoading.value || isDataLoadCompleted.value) return; 
    isLoading.value = true;
    String urlToAccessApi = "https://api.unsplash.com/photos/?client_id=$accessKey&page=$currentPage&per_page=20";
    try {
      final response = await http.get(Uri.parse(urlToAccessApi));
      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        if (data.isEmpty) {
          isDataLoadCompleted.value = true; 
        } else {
          photos.addAll(data.map((json) => PhotoModel.fromJson(json)).toList());
          currentPage++; 
        }
      } else {
        throw Exception("Failed to fetch photos: ${response.statusCode}");
      }
    } catch (e) {
      Get.snackbar("Error", "Failed to load photos: $e");
    } finally {
      isLoading.value = false;
    }
  }
}
