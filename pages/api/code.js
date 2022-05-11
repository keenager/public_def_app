const code = (req, res) => {
  return res.send(`
    <html>
    <form action="https://oauth2.googleapis.com/token" method="post" enctype="application/x-www-form-urlencoded">
        code: <input type='text' name="code" value=''><br>
        client_id: <input type='text' name="client_id" value='850040068289-gshv3nt5g98npo3s7v7nm8h6h28hhk23.apps.googleusercontent.com'><br>
        client_secret: <input type='text' name="client_secret" value='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'><br>
        redirect_uri: <input type='text' name="redirect_uri" value='http://localhost:3000/api/code'><br>
        grant_type: <input type='text' name="grant_type" value='authorization_code'><br>
        <input type="submit">
    </form>
    </html>
    `);
};

export default code;
