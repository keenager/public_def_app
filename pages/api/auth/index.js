import fs from "fs";
import readline from "readline";
import { google } from "googleapis";
import open from "open";

const SCOPES = ["https://www.googleapis.com/auth/calendar"];
const TOKEN_PATH = __dirname + "/token.json";
const CODE_PATH = __dirname + "/auth/code.txt";

let client_secret_file = "test";
try {
  client_secret_file = fs.readFileSync(__dirname + "/client_secret.json");
} catch (err) {
  console.log("Error loading client secret file: ", err);
}

authorize(JSON.parse(client_secret_file));

function authorize(credentials, callback) {
  const { client_id, client_secret } = credentials.web;
  const redirect_uri = "http://localhost:3000/api/auth/getCode";
  console.log("아이디: ", client_id, ", 시크릿: ", client_secret);
  const oAuth2Client = new google.auth.OAuth2(
    client_id,
    client_secret,
    redirect_uri
  );
  try {
    const token = fs.readFileSync(TOKEN_PATH);
    oAuth2Client.setCredentials(JSON.parse(token));
    callback(oAuth2Client);
  } catch (err) {
    return getAccessToken(oAuth2Client, callback);
  }
}

async function getAccessToken(oAuth2Client, callback) {
  console.log("토큰이 없네요!");
  const authUrl = oAuth2Client.generateAuthUrl({
    access_type: "offline",
    scope: SCOPES,
  });
  console.log("Authorize this app by visiting this url:", authUrl);
  await open(authUrl);
  //   const rl = readline.createInterface({
  //     input: process.stdin,
  //     output: process.stdout,
  //   });
  //   rl.question("Enter the code from that page here: ", (code) => {
  //     rl.close();
  //     oAuth2Client.getToken(code, (err, token) => {
  //       if (err) return console.error("Error retrieving access token", err);
  //       oAuth2Client.setCredentials(token);
  //       console.log(token);
  //       try {
  //         fs.writeFileSync(TOKEN_PATH, JSON.stringify(token));
  //         console.log('Token stored to: ', TOKEN_PATH);
  //       } catch (err) {
  //           return console.error(err);
  //       }
  //     //   callback(oAuth2Client);
  //     });
  //   });
  console.log("타임아웃 시작");
  setTimeout(() => {
    console.log("2초 지났음.");
    try {
      const code = fs.readFileSync(CODE_PATH, { encoding: "utf-8" });
      oAuth2Client.getToken(code, (err, token) => {
        if (err) return console.error("Error retrieving access token", err);
        oAuth2Client.setCredentials(token);
        console.log(token);
      });
    } catch (err) {
      console.error(err);
    }
  }, 2000);
}

export default (req, res) => {
  res.send("client_secret_file");
};
