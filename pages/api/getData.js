// import puppeteer from "puppeteer";
import { google } from "googleapis";
import createClient from "../../lib/createClient";

let chrome = {};
let puppeteer;

if (process.env.VERCEL) {
  // running on the Vercel platform.
  chrome = require("chrome-aws-lambda");
  puppeteer = require("puppeteer-core");
} else {
  // running locally.
  puppeteer = require("puppeteer");
}

const calendar = google.calendar("v3");
const HOW_MANY_WEEKS = 10;

export default async function GetData(req, res) {
  const USER_ID = req.body.ID;
  const USER_PW = req.body.PW;
  const CODE = req.body.CODE;
  try {
    //클라이언트 생성, 토큰 획득
    const oAuth2Client = createClient();
    oAuth2Client.getToken(CODE, (err, token) => {
      if (err) throw "Error retrieving access token: " + err;
      oAuth2Client.setCredentials(token);
    });

    google.options({ auth: oAuth2Client });
    let schedules = await NockingWebsite(USER_ID, USER_PW);
    // result = await calendar.calendarList.list();
    await insertEvent(schedules);
    res.redirect("/complete");
  } catch (err) {
    console.error(err);
    res.writeHead(200, { "Content-Type": "text/plain;charset=utf-8" });
    res.write(err);
    res.end();
  }
}

const NockingWebsite = async (id, pw) => {
  // const browser = await puppeteer.launch({ headless: true });
  const browser = await puppeteer.launch({
    args: [...chrome.args, "--hide-scrollbars", "--disable-web-security"],
    defaultViewport: chrome.defaultViewport,
    executablePath: await chrome.executablePath,
    headless: true,
    ignoreHTTPSErrors: true,
  });

  const page = await browser.newPage();
  await page.goto("https://case.publicdef.net");

  const loginElem = await page.$("div.navbar > a");
  await loginElem.click();

  const userNameElem = await page.$("input#id_username");
  await userNameElem.type(id);

  const passwordElem = await page.$("input#id_password");
  await passwordElem.type(pw);

  const loginButton = await page.$("input#loginbutton");
  await Promise.all([page.waitForNavigation(), loginButton.click()]);
  if (page.url().includes("login")) {
    throw "로그인에 실패하였습니다.";
  }

  const monthlySchedule = await page.$("div.navbar > a");
  await Promise.all([page.waitForNavigation(), monthlySchedule.click()]);

  const weeklySchedule = await page.$(".fc-listWeek-button");
  await weeklySchedule.click();

  let schedules = await getSchedules(page);
  for (let i = 0; i < HOW_MANY_WEEKS; i++) {
    const next = await page.$(".fc-next-button");
    await next.click();
    let temp = await getSchedules(page);
    schedules = [...schedules, ...temp];
  }
  return schedules;
};

const getSchedules = async (page) => {
  let result = await page.$$eval(".fc-list-table > tbody > tr", (trs) => {
    let date;
    let arr = [];
    for (tr of trs) {
      if (tr.className === "fc-list-heading") {
        date = tr.dataset.date;
        continue;
      }
      const content = tr.querySelector("td.fc-list-item-title").textContent;
      if (content.includes("기일표")) {
        continue;
      }
      const time = tr.querySelector("td.fc-list-item-time").textContent;
      arr.push({ date, time, content });
    }
    return arr;
  });
  return result;
};

async function insertEvent(schedules) {
  try {
    let oldCalendars = (await calendar.calendarList.list()).data.items;
    if (oldCalendars !== null) {
      let oldGookseons = oldCalendars.filter((item) => item.summary === "국선");
      for (let e of oldGookseons) {
        calendar.calendars.delete({ calendarId: e.id });
      }
    }
    const newCalendar = await calendar.calendars.insert({
      requestBody: {
        summary: "국선",
        timeZone: "Asia/Seoul",
      },
    });

    // let tasks = schedules.map(async (schedule) => {
    //   let event = { start: {}, end: {}, summary: "" };
    //   event.summary = schedule.content;
    //   if (schedule.time == "종일") {
    //     event.start.date = schedule.date;
    //     event.end.date = schedule.date;
    //   } else {
    //     event.start.dateTime = new Date(schedule.date + " " + schedule.time);
    //     event.end.dateTime = new Date(schedule.date + " " + schedule.time);
    //   }
    //   await sleep(500);
    //   return calendar.events.insert({
    //     calendarId: newCalendar.data.id,
    //     requestBody: event,
    //   });
    // });
    // await Promise.all(tasks);
    // console.log("완료!!!");

    for (let i = 0; i < schedules.length; i++) {
      let event = { start: {}, end: {}, summary: "" };

      event.summary = schedules[i]["content"];
      if (schedules[i].time == "종일") {
        event.start.date = schedules[i].date;
        event.end.date = schedules[i].date;
      } else {
        event.start.dateTime = new Date(
          schedules[i].date + " " + schedules[i].time
        );
        event.end.dateTime = new Date(
          schedules[i].date + " " + schedules[i].time
        );
      }
      console.log(event);
      let createEvent = await calendar.events.insert({
        calendarId: newCalendar.data.id,
        requestBody: event,
      });
      if (createEvent.statusText == "OK") {
        console.log("사건 일정이 구글캘린더에 추가되었습니다.");
      } else {
        console.log("사건 일정을 구글캘린더에 추가하는 데 실패하였습니다.");
      }
    }
  } catch (e) {
    console.error(e);
  }
}
