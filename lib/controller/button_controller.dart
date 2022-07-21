import 'package:get/get.dart';

class ButtonController extends GetxController {
  var isLoading = false.obs;

  void toggle(bool bool) {
    isLoading.value = bool;
  }
}
