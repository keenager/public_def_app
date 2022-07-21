import 'package:get/get.dart';
import '../model/messages.dart';

class MessageController extends GetxController {
  var displayText = ''.obs;
  late Messages messages;

  @override
  void onInit() {
    super.onInit();
    messages = Messages();
    displayText.value = '국선 사건관리시스템 ID&PW를 입력하세요';
  }

  void changeText(String keyword) {
    displayText.value = keyword;
  }
}
