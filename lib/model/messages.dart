class Messages {
  final String init,
      access,
      notLoaded,
      notLogined,
      logined,
      loading,
      oauth,
      inserting,
      success,
      fail,
      error;

  Messages({
    this.init = '국선 사건관리시스템 ID&PW를 입력하세요',
    this.access = '국선 사건관리시스템에 접속합니다.',
    this.notLoaded = '일정을 가져오지 못했습니다.\n아이디 또는 비밀번호를 확인해주세요.',
    this.notLogined = '로그인에 실패하였습니다.',
    this.logined = '로그인에 성공하였습니다.',
    this.loading = '일정을 불러오는 중입니다.',
    this.oauth = '국선 사건관리시스템에서 데이터를 성공적으로 불러왔습니다.\n구글캘린더 접근에 동의해주세요.',
    this.inserting = '사건 일정을 구글캘린더에 추가하고 있습니다.\n 30초 정도 걸립니다.',
    this.success = '구글캘린더 추가 완료!!!',
    this.fail = '사건 일정을 구글캘린더에 추가하는 데 실패하였습니다.',
    this.error = '에러가 생겼습니다.\n 에러 내용: ',
  });
}
