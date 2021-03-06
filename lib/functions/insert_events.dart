import 'package:googleapis_auth/auth_io.dart';
import 'package:googleapis/calendar/v3.dart' as cal;
import 'package:url_launcher/url_launcher_string.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:get/get.dart';
import '../controller/message_controller.dart';

var mc = Get.find<MessageController>();

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
      cal.Event createEvent =
          await calendarApi.events.insert(event, newCalendar.id ?? 'no Id...');
      if (createEvent.status == 'confirmed') {
        mc.changeText(mc.messages.inserting);
      } else {
        mc.changeText(mc.messages.fail);
      }
    }
  } catch (e) {
    mc.changeText(mc.messages.error + e.toString());
    // setState(() {
    //   displayText = '에러가 생겼습니다.\n 에러 내용: $e';
    // });
  }
}
