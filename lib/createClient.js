import fs from 'fs';
import { google } from 'googleapis';

export default function createClient() {
  // let client_secret_file = "test";
  try {
    const client_secret_file = fs.readFileSync(
      __dirname + "/client_secret.json"
    );
    const json = JSON.parse(client_secret_file);

    const { client_id, client_secret } = json.web;
    const redirect_uri = "http://localhost:3000/api/getCode";
    console.log("아이디: ", client_id, ", 시크릿: ", client_secret);
    const oAuth2Client = new google.auth.OAuth2(
      client_id,
      client_secret,
      redirect_uri
    );
    return oAuth2Client;
  } catch (err) {
    console.error(err);
    throw err;
  }
}
