import 'package:flutter/material.dart';
import 'package:puppeteer/puppeteer.dart' as ppt;
import 'package:googleapis_auth/auth_io.dart';
import 'package:googleapis/calendar/v3.dart' as cal;
import 'package:url_launcher/url_launcher_string.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

Future main() async {
  await dotenv.load(fileName: '.env');
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      title: 'PublicDef Schedule Importer',
      home: MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key}) : super(key: key);

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

const howManyWeeks = 10;

class _MyHomePageState extends State<MyHomePage> {
  String displayText = '국선 사건관리시스템 ID&PW를 입력하세요';
  final c1 = TextEditingController();
  final c2 = TextEditingController();
  bool isLoading = false;

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
                  if (!isLoading) mainProcess();
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
                  if (!isLoading) mainProcess();
                },
              ),
            ),
            const SizedBox(
              height: 20,
            ),
            if (!isLoading)
              ElevatedButton(
                child: const Text('시작'),
                onPressed: mainProcess,
              ),
            const SizedBox(
              height: 20,
            ),
            Text(
              displayText,
              style: const TextStyle(
                fontSize: 20,
              ),
            ),
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

  Future<void> mainProcess() async {
    setState(() {
      isLoading = true;
      displayText = '국선 사건관리시스템에 접속합니다.';
    });
    List<dynamic>? schedules = await getData(id: c1.text, password: c2.text);
    if (schedules == null) {
      setState(() {
        isLoading = false;
        displayText = '일정을 가져오지 못했습니다.\n아이디 또는 비밀번호를 확인해주세요.';
      });
    } else {
      await Future.delayed(const Duration(seconds: 2));
      await insertEvent(schedules);
      setState(() {
        isLoading = false;
        displayText = '구글캘린더 추가 완료!!!';
      });
    }
  }

  Future<List<dynamic>?> getData(
      {required String id, required String password}) async {
    var browser = await ppt.puppeteer.launch(headless: true);
    var myPage = await browser.newPage();
    await myPage.goto('https://case.publicdef.net');
    var loginElem = await myPage.$('div.navbar > a');
    await loginElem.click();
    var userNameElem = await myPage.$('input#id_username');
    await userNameElem.type(id);
    var passwordElem = await myPage.$('input#id_password');
    await passwordElem.type(password);
    var loginButton = await myPage.$('input#loginbutton');
    await Future.wait(
      [myPage.waitForNavigation(), loginButton.click()],
    );
    if (myPage.url!.contains('login')) {
      setState(() {
        displayText = '로그인에 실패하였습니다.';
      });
      return null;
    }
    setState(() {
      displayText = '로그인에 성공하였습니다.';
    });

    var monthlySchedule = await myPage.$('div.navbar > a');
    await Future.wait(
      [myPage.waitForNavigation(), monthlySchedule.click()],
    );

    var weeklySchedule = await myPage.$('.fc-listWeek-button');
    await weeklySchedule.click();

    setState(() {
      displayText = '일정을 불러오는 중입니다.';
    });

    List<dynamic> schedules = await getSchedules(myPage);
    for (int i = 0; i < howManyWeeks; i++) {
      var next = await myPage.$('.fc-next-button');
      await next.click();
      var temp = await getSchedules(myPage);
      schedules = [...schedules, ...temp];
    }
    for (var i = 0; i < schedules.length; i++) {
      if (schedules[i]['link'] == null) {
        continue;
      }
      await Future.wait([
        myPage.waitForNavigation(),
        myPage.goto(schedules[i]['link']),
        myPage.waitForSelector('tbody.casedetail_td')
      ]);
      String courtroom = await myPage.$eval('tbody.casedetail_td', r'''
        node => {
          var arr = node.innerText.match(/제?\d+호 ?법정/g);
          return arr[arr.length - 1];
          }
      ''');
      RegExp exp = RegExp(r'\d+호');
      courtroom = '[' + (exp.stringMatch(courtroom) ?? '?') + ']';
      schedules[i]['courtroom'] = courtroom;
    }

    setState(() {
      displayText = '국선 사건관리시스템에서 데이터를 성공적으로 불러왔습니다.\n구글캘린더 접근에 동의해주세요.';
    });

    // for (final elem in schedules) {
    //   print(elem);
    // }

    return schedules;
  }

  Future<List<dynamic>> getSchedules(ppt.Page page) async {
    List<dynamic> result = await page.$$eval('.fc-list-table > tbody > tr', '''
    function (trs) { 
      var date;
      var arr = [];
      for(tr of trs) {
        if(tr.className === 'fc-list-heading') {
          date = tr.dataset.date;
          continue;
        }
        var content = tr.querySelector('td.fc-list-item-title').textContent;
        if(content.includes('기일표')) {
          continue;
        }
        var time = tr.querySelector('td.fc-list-item-time').textContent;
        var link = content.includes('의견서') ? null : tr.querySelector('a').href;
        arr.push({date, time, content, link});
      }
      return arr;
    }
    ''');

    return result;
  }

  void prompt(String urlString) async {
    if (await canLaunchUrlString(urlString)) {
      await launchUrlString(urlString);
    } else {
      throw 'Could not launch $urlString';
    }
  }

  Future<void> insertEvent(List<dynamic> schedules) async {
    var _clientId = ClientId(
      dotenv.get('CLIENT_ID'),
      dotenv.get('CLIENT_SECRET'),
    );
    const _scopes = [cal.CalendarApi.calendarScope];
    try {
      var client = await clientViaUserConsent(_clientId, _scopes, prompt);
      cal.CalendarApi calendarApi = cal.CalendarApi(client);
      List<cal.CalendarListEntry>? oldCalendars =
          (await calendarApi.calendarList.list()).items;
      if (oldCalendars != null) {
        var oldGookseon = oldCalendars.where((el) => el.summary == '국선');
        for (var e in oldGookseon) {
          calendarApi.calendars.delete(e.id!);
        }
      }
      var newCalendar = await calendarApi.calendars.insert(
        cal.Calendar(
          summary: '국선',
          timeZone: 'Asia/Seoul',
        ),
      );
      for (int i = 0; i < schedules.length; i++) {
        cal.Event event = cal.Event();
        event.summary =
            (schedules[i]['courtroom'] ?? '') + schedules[i]['content'];
        cal.EventDateTime edt = cal.EventDateTime();
        if (schedules[i]['time'] == '종일') {
          edt.date = DateTime.parse(schedules[i]['date']);
        } else {
          edt.dateTime =
              DateTime.parse(schedules[i]['date'] + ' ' + schedules[i]['time']);
        }
        event.start = edt;
        event.end = edt;
        cal.Event createEvent = await calendarApi.events
            .insert(event, newCalendar.id ?? 'no Id...');
        if (createEvent.status == 'confirmed') {
          setState(() {
            displayText =
                '사건 일정($howManyWeeks주)을 구글캘린더에 추가하고 있습니다.\n 30초 정도 걸립니다.';
          });
        } else {
          setState(() {
            displayText = '사건 일정을 구글캘린더에 추가하는 데 실패하였습니다.';
          });
        }
      }
    } catch (e) {
      setState(() {
        displayText = '에러가 생겼습니다.\n 에러 내용: $e';
      });
    }
  }
}
