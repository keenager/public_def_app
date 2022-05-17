import { useState } from "react";
import Layout from "../lib/layout";
import utilStyles from '../styles/util.module.css';

export default function home() {
  const [curState, setCurState] = useState("구글 계정에 대한 접근 권한을 얻습니다. 시작하려면 버튼을 누르세요.");
  async function handleClick() {
    try {
      const res = await fetch("/api/authUrl");
      const text = await res.text();
      if (text.includes("err")) {
        setCurState("OAuth2 Client 생성 과정에서 오류가 생겼습니다.");
      } else {
        console.log(text);
        window.open(text); // authUrl로 이동 -> redirectUri로 이동
      }
    } catch (err) {
      console.error(err);
    }
  }
  return (
    <Layout>
      <button className={utilStyles.button} onClick={handleClick}>시작</button>
      <p>{curState}</p>
    </Layout>
  );
}
