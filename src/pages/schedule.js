import { useState } from "react";
import Layout from "../components/layout";
import utilStyles from "../../styles/util.module.css";
import { useRouter } from "next/router";

// export async function getServerSideProps() {
//   const res = await fetch("http://localhost:3000/api/getData");
//   const json = res.json();
//   return {
//     props: json,
//   };
// }

function inform() {
  alert(
    `  짧은 시간에 다수의 요청을 보낼 경우 구글 서버에서 에러를 내버려서 현재로서는 부득이 시간이 다소 걸리는 방식을 택했습니다. 
  언제가 될진 모르겠지만, 혹시 해결책을 발견하면 반영하겠습니다.
  오류 발견, 요청 사항 있으시면 심 변호사님에게 말씀해주세요 :)`
  );
}

export default function Schedule() {
  const curStateText = {
    wait: "사건관리시스템의 아이디, 비밀번호를 입력하세요.",
    check: "아이디 또는 비번을 입력하지 않았습니다.",
    loggedIn: "로그인 성공.",
    loading: "스케줄 로딩 중입니다.",
    loaded: "로딩 완료!",
  };
  const [currentState, setCurrentState] = useState(curStateText.wait);
  const [schedules, setSchedules] = useState([]);

  const [inputValueID, setInputValueID] = useState("");
  const [inputValuePW, setInputValuePW] = useState("");

  function handleSubmit(event) {
    if (inputValueID.length === 0 || inputValuePW.length === 0) {
      setCurrentState(curStateText.check);
      event.preventDefault();
    } else {
      setCurrentState(curStateText.loading);
    }
  }

  //파라미터에서 코드 획득
  const router = useRouter();
  const code = router.query.code;

  return (
    <Layout>
      <form
        action="/api/getData"
        method="post"
        className={utilStyles.align}
        onSubmit={handleSubmit}
      >
        <div>
          <input
            type="text"
            name="ID"
            placeholder="ID"
            className={utilStyles.input}
            onChange={(event) => setInputValueID(event.target.value)}
          />
        </div>
        <div>
          <input
            type="password"
            name="PW"
            placeholder="PW"
            className={utilStyles.input}
            onChange={(event) => setInputValuePW(event.target.value)}
          />
        </div>
        <input type="hidden" name="CODE" value={code} />
        <input type="submit" className={utilStyles.button} />
      </form>
      <div>
        <p style={{ textAlign: "center" }}>{currentState}</p>
        <ul>
          {schedules.map((schedule, index) => (
            <li
              key={index}
            >{`날짜: ${schedule.date}, 시각: ${schedule.time}, 내용: ${schedule.content}`}</li>
          ))}
        </ul>
        <p>
          완료되기까지 40~50초 정도 걸리니 참고하세요(
          <span className={utilStyles.click} onClick={inform}>
            클릭
          </span>
          ).
        </p>
      </div>
    </Layout>
  );
}
