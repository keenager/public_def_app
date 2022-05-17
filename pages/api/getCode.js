import fs from "fs";
// import { google } from "googleapis";
import createClient from "../../lib/createClient";

const CODE_PATH = __dirname + "/code.txt";
const TOKEN_PATH = __dirname + "/token.json";

// let client_secret_file = "test";
// try {
//   client_secret_file = fs.readFileSync(__dirname + "/client_secret.json");
// } catch (err) {
//   console.log("Error loading client secret file: ", err);
// }

// const json = JSON.parse(client_secret_file);

// const { client_id, client_secret } = json.web;
// const redirect_uri = "http://localhost:3000/api/auth/getCode";
// const oAuth2Client = new google.auth.OAuth2(
//   client_id,
//   client_secret,
//   redirect_uri
// );

export default function getCode(req, res) {
  const oAuth2Client = createClient();
  const code = req.query.code;
  try {
    fs.writeFileSync(CODE_PATH, code);
    console.log("코드를 저장하였습니다: " + CODE_PATH);
    oAuth2Client.getToken(code, (err, token) => {
      if (err) throw "Error retrieving access token: " + err;
      oAuth2Client.setCredentials(token);
      console.log(token);
      // try {
        fs.writeFileSync(TOKEN_PATH, JSON.stringify(token));
        console.log("Token stored to: ", TOKEN_PATH);
      // } catch (err) {
        // return console.error(err);
      // }
      //   callback(oAuth2Client);
      
    });
    res.redirect("/schedule");
  } catch (err) {
    console.error(err);
    res.writeHead(200, { "Content-Type": "text/plain;charset=utf-8" });
    res.write(err);
    res.end();
  }
}
