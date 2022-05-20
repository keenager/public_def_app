import createClient from "../../lib/createClient";

const SCOPES = ["https://www.googleapis.com/auth/calendar"];

export default function redirectToAuthUrl(req, res) {
  try {
    const oAuth2Client = createClient();
    const authUrl = oAuth2Client.generateAuthUrl({
      access_type: "offline",
      scope: SCOPES,
    });
    res.send(authUrl);
  } catch (err) {
    console.error(err);
    res.writeHead(200, { "Content-Type": "text/plain;charset=utf-8" });
    res.write(err);
    res.end();
  }
}
