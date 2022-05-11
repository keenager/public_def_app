import fs from "fs";

const CODE_PATH = __dirname + "/code.txt";

export default (req, res) => {
  const code = req.query.code;
  try {
    fs.writeFileSync(CODE_PATH, code);
    console.log("코드를 저장하였습니다: " + CODE_PATH);
  } catch (err) {
      console.error(err);
  }
  res.writeHead(200, { "Content-Type": "text/html; charset=utf-8" });
  res.end("redirect 페이지 입니다. code = " + code + "\n 탭을 닫아주세요.");
};
