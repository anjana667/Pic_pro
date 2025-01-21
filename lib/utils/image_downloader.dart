import 'dart:io';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:image_gallery_saver/image_gallery_saver.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';

class ImageDownloader {
  static Future<void> downloadImage(String url, String fileName) async {
    try {
      String devicePathToSaveImage = "";
      var time = DateTime.now().microsecondsSinceEpoch; 
      if (Platform.isAndroid) {
        var status = await Permission.storage.request();
        if (!status.isGranted) {
          print("Storage permission denied");
          return;
        }
        devicePathToSaveImage = "/storage/emulated/0/Download/image-$time.jpg";
      } else {  
        var downloadDirectoryPath = await getApplicationDocumentsDirectory();
        devicePathToSaveImage = "${downloadDirectoryPath.path}/image-$time.jpg";
      }


      File file = File(devicePathToSaveImage);
      print('File path: $devicePathToSaveImage');

      var res = await http.get(Uri.parse(url));
      if (res.statusCode == 200) {
        await file.writeAsBytes(res.bodyBytes);
        ImageGallerySaver.saveFile(devicePathToSaveImage);
         Get.snackbar("Download Complete", "Image saved to gallery.");
        print("Image saved successfully to $devicePathToSaveImage");
      } else {
         Get.snackbar("Download Failed", "Failed to download image. Status code: ${res.statusCode}");
        print("Failed to download image. Status code: ${res.statusCode}");
      }
    } catch (error) {
      print("Error: $error");
    }
  }
}
