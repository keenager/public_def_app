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
            Obx(() => Text(
                  messageController.displayText.value,
                  style: const TextStyle(
                    fontSize: 20,
                  ),
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
  - 짧은 시간에 다수의 요청을 보낼 경우 구글 서버에서 에러를 내버려서 현재로서는 부득이 시간이 다소 걸리는 방식을 택했습니다(30초 정도). 
  - 언제가 될진 모르겠지만, 혹시 해결책을 발견하면 반영하겠습니다.
  - 오류 발견, 요청 사항 있으시면 심 변호사님에게 말씀해주세요 :)
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
    await insertEvent(schedules);

    buttonController.isLoading.value = false;
    messageController.changeText(messages.success);
  }
}
