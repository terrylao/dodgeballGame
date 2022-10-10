unit VarUnit;//変数、定数、構造体宣言用

interface

uses
    Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
    Dialogs, IniFiles,StrUtils;


Type DodgeChar = record //実際のキャラデータ
    Dead_f:boolean;//
    //ステータス
    Face :integer; //顔チップ
    FaceType :integer; //顔(0:ノーマル　1:へいる顔　2:らおち顔　3:もるど顔)
    Name : String; //名前
    dNo :integer;
    dHP :integer; //体力
    dBP :integer; //ぼーるぱわー
    dST :integer; //しゅーとてく
    dTK :integer; //たまのきれ
    dSp :integer; //すばやさ
    dCT :integer; //きゃっちてく
    dGu :integer; //うたれづよさ
    dDSP:integer; //だっしゅひっさつ
    dJSP:integer; //じゃんぷひっさつ
    mNo:integer;  //現在のグラフィック
    mNo_c:integer;//グラフィックカウンタ
    mRevX:integer;//Ｘ座標補正
    mRevY:integer;//Ｙ座標補正
    NotKey_f :Boolean;//キー入力不可状態
    Pos: integer;//ポジション
    Auto_f :boolean;
    Auto_f2 :boolean;
    AutoMuki:integer;
    AutoMuki2:integer;
    //向き
    Muki  :integer;//左　右
    Muki2 :integer;//上　横　下
    //座標
    X : integer;
    Y : integer;
    Z : integer;
    //座標変化量
    dX : integer;
    dY : integer;
    dZ : integer;
    //ダメージ表示座標
    damDt: integer;
    dam_c: integer;
    damX : integer;
    damY : integer;
    damZ : integer;
    //天使グラフィック用カウンタ
    Holy_c  :integer;      
    HolyX : integer;
    HolyY : integer;
    HolyZ : integer;
    //ターゲット座標
    tgX : integer;
    tgY : integer;
    tgZ : integer;
    tgNo: integer;
    //ターゲット座標
    ptgX : integer;
    ptgY : integer;
    ptgZ : integer;
    ptgNo: integer;
    //フォーメーション移動予定座標
    tfX  : integer;
    tfY  : integer;
    tfZ  : integer;
    FormChange_f : boolean;
    FormNo :integer;

    //状態　＃＃＃＃＃＃＃＃＃＃＃＃＃＃＃
    Motion :integer; //動作の種類
    Jump_f :integer; //ジャンプ
    Jump_c :integer; //ジャンプカウンタ
    JMuki  :integer; //ジャンプ向き左右
    JMuki2 :integer; //ジャンプ向き上下
    Act_f  :integer; //動作の状態
    Act_c  :integer; //動作の状態カウンタ
    Dash_f :integer; //ダッシュ
    Clay_c :integer; //アフリカコートの最高速度までの時間
    Step_c :integer; //歩数
    Dam_f  :integer; //ダメージ

    DamLv  :integer; //0:普通 1:着地後回転 2:世界一周
    Groggy_c:integer;//グローキーカウンタ
    RefWall_f:boolean;//壁にぶつかった
    RollMuki:integer; //回転方向
    Slip_f :integer; //スリップ左右
    Slip_f2:integer; //スリップ上下
    Slip_c :integer; //スリップカウンタ
    Slip_c2:integer; //スリップカウンタ
    Boost  :integer; //逆ブースト(あいすらんどのスリップ減少）
    Move_f :boolean; //動いているかどうか
    Ball_f :Boolean; //ボールを持っているかどうか
    OnBall_f:boolean;//ボールに乗っているかどうか
    Take_f :boolean; //ボールを拾える
    Catch_c:integer; //ボールをキャッチできるカウンタ
    LockOn_f:boolean;//ロックオンフラグ
    PCJump_c:integer;//ジャンプパスをキャッチするまでの時間（ジャンプ用）
    PC_c:integer;//パスをキャッチするまでの時間（キャッチ用）
    Kurai:TRect;

    //押しているかどうか
    KeyU3  : Boolean;
    KeyD3 : Boolean;
    KeyL3 : Boolean;
    KeyR3 : Boolean;
    //押しているかどうか
    KeyU2  : Boolean;
    KeyD2 : Boolean;
    KeyL2 : Boolean;
    KeyR2 : Boolean;
    KeyJ2 : Boolean;
    KeyP2 : Boolean;
    KeyK2 : Boolean;
    //押した瞬間かどうか
    KeyU  : Boolean;
    KeyD : Boolean;
    KeyL : Boolean;
    KeyR : Boolean;
    KeyJ : Boolean;
    KeyP : Boolean;
    KeyK : Boolean;
    TwoHit : integer;//連打   

end;
Type DodgePlayer = record //プレーヤーのデータ
    TeamNo:integer;//チーム
    CNo:integer;//キャラナンバー
    TNo:integer;//ターゲットナンバー
    PNo:integer;//パスキャラナンバー

    //ptg_c:integer;//パス待ちアクション用
    TwoHit : integer;//連打
    Steps :integer;//歩数
    CapNo:integer;//キャプテンフラグ
    Cap_f:boolean;//キャプテン生存フラグ
    Dead_c:integer;//死亡人数
    DBC : array[0..5] of DodgeChar;
end;
Type LoadDodgeChar = record //ロードデータ
    DBC : array[0..5] of DodgeChar;
end;
Type DodgeBall = record

    Motion:integer;
    HoldChar:integer;
    tgNo:integer;
    ptgNo:integer;
    ptg_c:integer;
    mNo:integer;
    Spin_c:integer;//回転カウンタ
    Spin:integer;//スピン方向＆スピン速度
    BColor:integer;
    //座標
    X : integer;
    Y : integer;
    Z : integer;
    //座標変化量
    dX : integer;
    dY : integer;
    dZ : integer;
    //座標変化量(必殺用)
    dX2 : integer;
    dY2 : integer;
    dZ2 : integer;

    Pow : integer;  //威力
    PowLv:integer;
    Speed:integer;
    Curve :integer;//変化
    Curve_c :integer;//変化カウンタ
    CType :integer;//変化タイプ（上下キー反転かそうでないか）
    SType :integer;//必殺シュート
    SP_c  :integer;//必殺用カウンタ
    Nice_f:boolean;//ナイスシュートフラグ
    ZShoot_f:boolean;//Z軸方向へのシュート（左右の変化）
    //S_c :integer;  //シュートカウント（点滅や回転）
    NextBount_f :boolean;
    Atari:TRect;
end;
//ソート用構造体
Type SortData  = record
    BaseNo :integer;//選手番号
    Dt1:integer;//ステータス１
    Dt2:integer;//ステータス２
    Fl1:boolean;//フラグ１
end;
//ＣＰＵ思考入れておく構造体
Type CPUData  = record
    Order:integer;
    Order2:integer;
    Order3:integer;
    Move_c:integer;
    STiming:integer;
end;

//#####　定数  #####//====================================================================
Const

  //共通0
  None = 0;
  //ジャンプ状態
  J1 = 1;
  J2 = 2;
  J3 = 3;
  //ダメージ状態
  D1 = 1;
  D2 = 2;
  D3 = 3;
  D4 = 4;
  D5 = 5;
  D6 = 6;
  //ボールの色
  BCol1 = 48;
  BCol2 = 48*2;
  //重力
  Grv = 15;
  //PassGrv = 10;

  //向き
  Migi = 1;
  Hidari = -1;
  Ue = 2;
  Shita = -2;
  Zenten = 3;
  Bakuten = -3;

  //状態
  WWW = 1; //歩き
  DDD = 2; //ダッシュ
  JJJ = 3; //ジャンプ
  SLP = 4;//スリップ
  DAM = 5; //ダメージ
  DFLY = 6; //吹っ飛び
  DOWN = 7; //ダウン
  SLP2 = 8; //キャッチ滑り

  

  //動作
  //守備
  Ca = 1;//キャッチ
  Crm = 2;//しゃがみ
  JCa = 4;//Ｊキャッチ
  //攻撃
  Sh = 5;//シュート
  Pa = 6;//パス
  DSh = 7;//Ｄシュート
  DPa = 8;//Ｄパス
  JSh = 9;//Ｊシュート
  JPa = 10;//Ｊパス
  //その他
  TCr = 11;//拾い
  //SLP = 11;//スリップ

  //モーションナンバー
  mMain = 0;
  mJump = 1;
  mDash = 2;
  mPunch = 3;
  mKick = 4;
  mItem = 5;
  mDam = 6;
  mDrink = 7;

  //必殺データ
  Snat = 1; //ナッツ
  Sbun = 2; //分裂
  Sina = 3; //稲妻
  Smoz = 4; //百舌落とし
  Sass = 5; //圧縮
  Skas = 6; //加速
  Sbuy = 7; //ぶよぶよ
  Shoe = 8; //ほえほえ

  Skan = 9; //貫通
  Ssun = 10; //スネーク
  Ssuk = 11; //スクリュー
  Skak = 12; //かっくん
  Sobu = 13; //おぶおぶ
  Sapp = 14; //アッパー
  Swaa = 15; //ワープ
  Sbuu = 16; //ブーメラン
  Senn = 17; //円輪

  //軌道
  Orb0 = 0; //ストレート（木刀、指輪、ドリンク、サック、杖）
  Orb1 = 1; //チェンジアップ（鉄アレイ）
  Orb2 = 2; //スローカーブ（タイヤ）
  Orb3 = 3; //超天井（まいぼうる）

  //ボール状態
  BFree = 0;//落ちてる
  BHold = 1;//持たれている
  BShoot= 2;//しゅーと
  BPass = 3;//パス
  BBound= 4;//バウンド

  //ゲームモードGameMode
  OP = 1;
  MSL = 2;
  TSL = 3;
  PSL = 4;
  DB = 5;
  Ending = 6;
  INIT = 7;
  NAMENNAYO = 8;
  VS = 9;
  HDC = 10;
  CSL = 11;


  DBMNo : array[0..4,0..14,0..4] of Integer =
  (  //ボールを奥に描写、Ｘ、Ｙ、
     //絵の後ろに顔を描画10 ＋ 顔の種類（屈み20　めがねキャラ補正）
     //無し0 正1 横2 倒3 勝4 後5 正面6
     //顔位置Ｙ
   (//右下
    (0,0,0,11,0),
    (0,0,0,11,0),
    (0,1,0,11,-1),
    (0,-10,0,11,0),
    (0,0,1,11,0),
    (0,6,8,11,0),
    (0,0,1,11,0),
    (0,0,0,11,0),//J
    (0,-1,0,11,0),
    (0,-10,0,11,0),
    (0,0,1,11,0),
    (0,6,8,11,0),
    (0,0,0,11,0),
    (0,2,6,11,0),
    (0,3,9,11,0)
   ),
   (//右
    (1,3,0,12,0),
    (1,3,2,12,0),
    (1,4,0,12,-1),
    (0,-8,0,1,0),
    (0,0,0,12,0),
    (0,11,3,12,0),
    (0,5,0,12,0),
    (1,6,0,12,0),//J
    (1,3,0,12,0),
    (0,-8,0,1,0),
    (0,0,1,12,0),
    (0,11,8,12,0),
    (0,3,0,12,0),
    (1,5,5,12,0),
    (1,5,9,12,0)
   ),
   (//右上
    (1,1,0,15,0),
    (1,1,1,15,0),
    (1,2,0,15,-1),
    (0,-6,4,2,0),
    (0,-3,2,15,0),
    (1,7,8,15,0),
    (1,2,2,15,0),
    (1,1,0,15,0),
    (1,1,0,15,0),
    (0,-6,4,2,0),
    (0,-3,2,15,0),
    (1,7,8,15,0),
    (1,1,0,15,0),
    (1,5,5,15,0),
    (1,6,9,15,0)
   ),
   (//移動
    (1,3,1,2,0),
    (1,3,0,2,0),
    (1,3,1,2,0),
    (1,3,0,2,0),
    (1,3,-1,2,0),
    (1,3,0,2,0),
    (1,3,-1,2,0),
    (1,3,0,2,0),
    (1,3,0,3,0),
    (0,3,1,22,0),
    (0,4,2,22,0),
    (0,3,0,0,0),
    (0,3,0,0,0),
    (0,3,0,0,0),
    (0,3,2,0,0)
   ),
   (//その他
    (0,0,0,0,0),
    (0,0,0,0,0),
    (0,0,0,0,0),
    (0,0,0,0,0),
    (0,0,0,0,0),
    (0,0,0,0,0),
    (0,0,0,0,0),
    (0,0,0,0,0),
    (0,0,0,0,0),
    (0,0,0,0,0),
    (0,0,0,0,0),
    (0,0,0,0,0),
    (0,0,0,0,0),
    (0,0,0,0,0),
    (0,0,0,0,0)
   )
  );

  //文字描画用
  Moji :array[0..221] of WideString =
  ('０','１','２','３','４','５','６','７','８','９'//0..9
  
  ,'Ａ','Ｂ','Ｃ','Ｄ','Ｅ','Ｆ','Ｇ','Ｈ','Ｉ','Ｊ','Ｋ','Ｌ','Ｍ'
  ,'Ｎ','Ｏ','Ｐ','Ｑ','Ｒ','Ｓ','Ｔ','Ｕ','Ｖ','Ｗ','Ｘ','Ｙ','Ｚ'//10..35

  ,'あ','い','う','え','お','か','き','く','け','こ'//45
  ,'さ','し','す','せ','そ','た','ち','つ','て','と'//55
  ,'な','に','ぬ','ね','の','は','ひ','ふ','へ','ほ'//65
  ,'ま','み','む','め','も','や','ゆ','よ','ら','り'//75
  ,'る','れ','ろ','わ','を','ん','ぁ','ぃ','ぅ','ぇ'//85
  ,'ぉ','っ','ゃ','ゅ','ょ'//90

  ,'が','ぎ','ぐ','げ','ご','ざ','じ','ず','ぜ','ぞ'//91..濁音
  ,'だ','ぢ','づ','で','ど','ば','び','ぶ','べ','ぼ'//..110
  ,'ぱ','ぴ','ぷ','ぺ','ぽ'//111..115半濁音

  ,'ア','イ','ウ','エ','オ','カ','キ','ク','ケ','コ'//116..
  ,'サ','シ','ス','セ','ソ','タ','チ','ツ','テ','ト'
  ,'ナ','ニ','ヌ','ネ','ノ','ハ','ヒ','フ','ヘ','ホ'//136
  ,'マ','ミ','ム','メ','モ','ヤ','ユ','ヨ','ラ','リ'
  ,'ル','レ','ロ','ワ','ヲ','ン','ァ','ィ','ゥ','ェ'//156
  ,'ォ','ッ','ャ','ュ','ョ'//..170

  ,'ガ','ギ','グ','ゲ','ゴ','ザ','ジ','ズ','ゼ','ゾ'//171..濁音
  ,'ダ','ヂ','ヅ','デ','ド','バ','ビ','ブ','ベ','ボ'//..190
  ,'パ','ピ','プ','ペ','ポ'//..195半濁音

  ,'ー','！','？','、','。','○','●','～','・','，'//196..
  ,'／','：','…','（','）','「','」','↑','↓','←'
  ,'→','＆','＜','＞'//..219

  ,'　'//220

  ,'＠'//221
  );

  //ＣＰＵ命令
  CForm = 1;//フォーメーション移動
  CTake = 2;//ボール拾い
  CDef  = 3;//守備
  CPCut = 4;//パスカット
  CAtc  = 5;//攻撃
  CPass = 6;//パス
  //ＣＰＵ命令２段階目
  C2S   =7;//シュート
  C2DS  =8;//Dシュート
  C2DJS =9;//DJシュート
  C2P   =10;//パス
  C2DP  =11;//Dパス
  C2DJP =12;//DJパス
  C2Ca  =13;//キャッチ
  C2Cr  =14;//しゃがみよけ
  C2Jp  =15;//ジャンプよけ
  C2NG  =99;//ノーガード
  //ＣＰＵ命令３段階目
  C3St1 =16;//速攻シュート
  C3St2 =17;//頂点シュート
  C3St3 =18;//チェンジアップシュート
  C3StS =19;//必殺シュート
  C3Pt1 =20;//内野パス
  C3Pt2 =21;//２番パス
  C3Pt3 =22;//３番パス
  C3Pt4 =23;//４番パス

  //フォーメーション
  CFP : array[0..9] of Integer = //前1後2キャプのみ後ろ3
// N H B I I C S A A 謎
  (1,1,1,2,1,2,3,2,1,1);

  //シュートパターン
  CSP : array[0..9] of Integer =//(DSの確率（○割）残りはDJS)
// NeHaBrInIcChSoAfUs謎
  (5,7,3,7,3,8,6,2,5,6);
  //シュートパターン（キャプテン）
  CSPc : array[0..9] of Integer =//(DSの確率（○割）残りはDJS)
// NeHaBrInIcChSoAfUs謎
  (5,8,3,7,8,7,3,6,6,6);

  //キャッチパターン
  CCaP : array[0..9] of Integer =//(キャッチの確率（○割）残りはよけ)
// NeHaBrInIcChSoAfUs謎
  (7,8,6,2,9,9,9,3,6,7);
  //避けパターン
  CCrP : array[0..9] of Integer =//(しゃがみの確率（○割）残りはジャンプ)
// NeHaBrInIcChSoAfUs謎
  (5,8,5,5,8,8,7,8,6,5);

  //パスパターン（パスの確率残りはシュート）
  CPP : array[0..9] of Integer =
// NeHaBrInIcChSoAfUs謎
  (2,7,1,7,1,7,10,1,3,2);
  //パスパターン（キャプテン）
  CPPc : array[0..9] of Integer =
// NeHaBrInIcChSoAfUs謎
  (2,0,1,5,0,5,0,1,1,2);
  //内野へのパスパターン    残りは外野
  CPP2 : array[0..9] of Integer =
// NeHaBrInIcChSoAfUs謎
  (5,7,0,2,8,1,10,1,1,2);

  //外野パスパターン（パスの確率残りはシュート）
  CPPg : array[0..9] of Integer =
// NeHaBrInIcChSoAfUs謎
  (2,3,1,6,1,6,10,1,5,3);

//変数//====================================================================
var
  //読み込んだキーコード
  KeyCode : array[0..1,0..7] of integer;
  JoyCode : array[0..3,0..7] of integer;
  CBtn_f  : array[0..3] of boolean;
  //全選手データ
  //LoadDt : array[0..6] of DodgePlayer;
  //プレイヤー0123
  P : array[0..1] of DodgePlayer;
  //ＣＰＵ
  C : array[0..5] of CPUData;
  CPU_f :boolean;
  LoadDt : array[0..9] of LoadDodgeChar;//ロードデータ（９チーム×６人）
  TeamData : array[0..9,0..6] of integer;//チームステータス
  TeamData2 : array[0..9,0..5,0..8] of integer;//個人ステータス

  InitP: DodgePlayer;// プレーヤー（初期化用）
  InitC:CPUData;// ＣＰＵ（初期化用）
  PauseAble_f :boolean;
  Pause_f   :integer;
  OP_f      :boolean;
  //dbdb
  Ball : DodgeBall;//ボール
  InitBall:DodgeBall;//ボール（初期化用）
  Cur_c :integer;
  tg_c :integer;
  Camera:integer;//視点の保存
  Stage:integer;//遠征試合のステージ
  //PTeam:integer;//遠征試合プレーヤーチーム
  Ready_c :integer;//試合開始の合図がなってる時間
  GameSet_c:integer;//試合終了のＳＥがなってる時間
  GameLv :integer;//なんいど
  Ensei_f:boolean;//遠征試合
  HDCDt : array[0..1,0..2] of integer;//ハンディデータ（ＨＰ，ダメージ、ひっさつ）
  
  NODead_f:boolean;//誰も死ななかったフラグ＝ラスボスへの挑戦権

  HardClear:integer;

//====================================================================
implementation

uses Main;

end.
