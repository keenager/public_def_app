import 'package:flutter/material.dart';
import 'package:public_def/controller/button_controller.dart';
import 'package:public_def/controller/message_controller.dart';
import 'package:public_def/model/messages.dart';
import 'package:url_launcher/url_launcher_string.dart';
import 'package:get/get.dart';
import '../functions/get_data.dart';
import '../functions/insert_events.dart';

const howManyWeeks = 10;
final c1 = TextEditingController();
final c2 = TextEditingController();
final messages = Messages();
final messageController = Get.put(MessageController());
final buttonController = Get.put(ButtonController());

class MyHomePage extends StatelessWidget {
  const MyHomePage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TextButton(
              child: const Text(
                '국선 일정 ',
                style: TextStyle(color: Colors.white),
              ),
              onPressed: () async {
                await launchUrlString('https://case.publicdef.net');
              },
            ),
            const Icon(Icons.arrow_forward_sharp),
            TextButton(
              child: const Text(
                ' 구글 캘린더',
                style: TextStyle(color: Colors.white),
              ),
              onPressed: () async {
                await launchUrlString('https://calendar.google.com');
              },
            ),
          ],
        ),
        centerTitle: true,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SizedBox(
              width: 200,
              child: TextField(
                controller: c1,
                decoration: const InputDecoration(
                  labelText: '아이디',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.all(Radius.circular(10)),
                  ),
                ),
                onSubmitted: (value) {
                  if (!buttonController.isLoading.value) mainProcess();
                },
              ),
            ),
            const SizedBox(
              height: 10,
            ),
            SizedBox(
              width: 200,
              child: TextField(
                controller: c2,
                decoration: const InputDecoration(
                  labelText: '패스워드',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.all(Radius.circular(10)),
                  ),
                ),
                obscureText: true,
                onSubmitted: (value) {
                  if (!buttonController.isLoading.value) mainProcess();
                },
              ),
            ),
            const SizedBox(
              height: 20,
            ),
            Obx(
              () => (buttonController.isLoading.value)
                  ? const SizedBox()
                  : const ElevatedButton(
                      child: Text('시작'),
                      onPressed: mainProcess,
                    ),
            ),
            const SizedBox(
              height: 20,
            ),
            Obx(() => Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      messageController.displayText.value,
                      style: const TextStyle(
                        fontSize: 20,
                      ),
                    ),
                    const SizedBox(width: 10),
                    if (messageController.displayText.value ==
                            messageController.messages.loading ||
                        messageController.displayText.value ==
                            messageController.messages.inserting)
                      const CircularProgressIndicator(),
                  ],
                )),
          ],
        ),
      ),
      bottomSheet: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          TextButton(
            child: const Text('Info.'),
            onPressed: () {
              showDialog(
                context: context,
                builder: (context) {
                  return AlertDialog(
                    content: const Text(
                        '''  - 상단 바의 '국선 일정'과 '구글 캘린더'를 클릭하면 해당 웹페이지로 이동합니다.
  - 오류 발견, 요청 사항 있으시면 심 변호사님에게 말씀해주세요 :)
  - 2022. 7. 6. 법정 표시, 알람 추가
  - 2022. 9. 11. 개인일정이 있는 경우 생기던 에러 해결, 알람 삭제 
  - 2022. 9. 28. 재판부별로 법정표시 방법이 달라 생기던 오류 해결
  '''),
                    actions: [
                      TextButton(
                        child: const Text('OK'),
                        onPressed: () {
                          Navigator.pop(context);
                        },
                      )
                    ],
                  );
                },
              );
            },
          ),
          const Text('|  '),
          RichText(
            text: const TextSpan(
              text: 'Developed by ',
              style: TextStyle(fontSize: 15, color: Colors.black),
              children: [
                TextSpan(
                  text: 'JYS',
                  style: TextStyle(fontSize: 20, color: Colors.black),
                ),
              ],
            ),
          )
        ],
      ),
    );
  }
}

Future<void> mainProcess() async {
  buttonController.isLoading.value = true;
  messageController.changeText(messages.access);
  List<dynamic>? schedules = await getData(
    id: c1.text,
    password: c2.text,
    howManyWeeks: howManyWeeks,
  );
  if (schedules == null) {
    buttonController.isLoading.value = false;
    messageController.changeText(messages.notLoaded);
  } else {
    await Future.delayed(const Duration(seconds: 2));
    await insertEvent(
      id: c1.text,
      schedules: schedules,
    );

    buttonController.isLoading.value = false;
    messageController.changeText(messages.success);
  }
}
