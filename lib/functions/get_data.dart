import 'package:get/get.dart';
import 'package:puppeteer/puppeteer.dart' as ppt;
import '../controller/message_controller.dart';

var mc = Get.find<MessageController>();

Future<List<dynamic>?> getData({
  required String id,
  required String password,
  required int howManyWeeks,
}) async {
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
    mc.changeText(mc.messages.notLoaded);
    return null;
  }
  mc.changeText(mc.messages.logined);

  var monthlySchedule = await myPage.$('div.navbar > a');
  await Future.wait(
    [myPage.waitForNavigation(), monthlySchedule.click()],
  );

  var weeklySchedule = await myPage.$('.fc-listWeek-button');
  await weeklySchedule.click();

  mc.changeText(mc.messages.loading);

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

  mc.changeText(mc.messages.oauth);

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
