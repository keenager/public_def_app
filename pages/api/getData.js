import 'dotenv/config';
const puppeteer = require('puppeteer');

const getData = async (req, res) => {
    const browser = await puppeteer.launch({headless: true});
    const page = await browser.newPage();
    await page.goto('https://case.publicdef.net');

    const loginElem = await page.$('div.navbar > a');
    await loginElem.click();

    const userNameElem = await page.$('input#id_username');
    await userNameElem.type(process.env.USER_ID);

    const passwordElem = await page.$('input#id_password');
    await passwordElem.type(process.env.USER_PASSWORD);

    const loginButton = await page.$('input#loginbutton');
    await Promise.all(
      [page.waitForNavigation(), loginButton.click()]
    );
    // if (page.url().includes('login')) {
    //   setState(() {
    //     displayText = '로그인에 실패하였습니다.';
    //   });
    //   return null;
    // }
    // setState(() {
    //   displayText = '로그인에 성공하였습니다.';
    // });

    const monthlySchedule = await page.$('div.navbar > a');
    await Promise.all(
      [page.waitForNavigation(), monthlySchedule.click()]
    );

    const weeklySchedule = await page.$('.fc-listWeek-button');
    await weeklySchedule.click();

    let schedules = await getSchedules(page);
    for (let i = 0; i < 12; i++) {
      const next = await page.$('.fc-next-button');
      await next.click();
      let temp = await getSchedules(page);
      schedules = [...schedules, ...temp];
    }
    return res.status(200).json({schedules});
};

const getSchedules = async (page) => {
    let result = await page.$$eval('.fc-list-table > tbody > tr', 
    (trs) => { 
      let date;
      let arr = [];
      for(tr of trs) {
        if(tr.className === 'fc-list-heading') {
          date = tr.dataset.date;
          continue;
        }
        const content = tr.querySelector('td.fc-list-item-title').textContent;
        if(content.includes('기일표')) {
          continue;
        }
        const time = tr.querySelector('td.fc-list-item-time').textContent;
        arr.push({date, time, content});
      }
      return arr;
    }
    );
    return result;
  }

export default getData;
