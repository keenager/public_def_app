// import fs from "fs";
import path from "path";
import { google } from "googleapis";

// const PATH = path.resolve(__dirname, "../../../..", "client_secret.json");

export default function createClient() {
  try {
    // const client_secret_file = fs.readFileSync(PATH);
    // const json = JSON.parse(client_secret_file);
    // const { client_id, client_secret } = json.web;
    // console.log("아이디: ", client_id, ", 시크릿: ", client_secret);
    const oAuth2Client = new google.auth.OAuth2(
      process.env.CLIENT_ID,
      process.env.CLIENT_SECRET, 
      process.env.REDIRECT_URI,
    );
    return oAuth2Client;
  } catch (err) {
    console.error(err);
    throw err;
  }
}
