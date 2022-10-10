unit Main;//メイン部分のコード

interface

uses
    Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
    Dialogs, MMsystem, IniFiles, StrUtils,VarUnit,ExtCtrls,DBClass
    Math;
type

    TForm1 = class(TForm)
        DDDD1: TDDDD;
        DDIDEX1: TDDIDEX;
        DDSD1: TDDSD;
    PC1: TProcCounter;
        procedure DDDD1Init(Sender: TObject; fNeedChange: Boolean);
        procedure DDDD1Destroy(Sender: TObject);
        procedure FormCreate(Sender: TObject);
        procedure FormKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
        procedure FormKeyUp(Sender: TObject; var Key: Word; Shift: TShiftState);
        procedure FormDestroy(Sender: TObject);
    private
        TW              :TAnti_DelX;
        //SC              :TSceneCtrl;
        FD              :TFontDraw;
       
        st,et,ov        :Cardinal;//ループ制御用
        st1000,et1000   :integer;
        FPS_c           :integer;
        //メインループ
        procedure MainLoop(Sender: TObject; var Done: Boolean);
        procedure DBINILoad;
        procedure DXINILoad;
    public
        //サーフェイス解放
        procedure SfFree(ddsf:TDDDDSurface);
        //システムメモリにＢＭＰをロード
        procedure LoadBMPs(var ddsf:TDDDDSurface;FileName:String;Wid:integer;Hei:integer);
        //ビデオメモリにＢＭＰをロード
        procedure LoadBMPv(var ddsf:TDDDDSurface;FileName:String;Wid:integer;Hei:integer);
        procedure INISet;//ＩＮＩファイル読み込み
        //procedure KeyState;//キー入力の読み込み
        procedure LoopOP;//オープニング
        procedure LoopMSL;//ゲームモード選択
        procedure LoopTSL;//チームセレクト
        procedure LoopPSL;//ポジション変更
        procedure LoopVS;//マッチアップ
        procedure LoopDB;//試合
        procedure LoopHDC;//ハンディキャップ
        procedure LoopCSL;//コートセレクト
        procedure LoopNAMENNAYO;//リセット


        procedure LoopOPDraw;//オープニング
        procedure LoopMSLDraw;//ゲームモード選択
        procedure LoopTSLDraw;//チームセレクト
        procedure LoopPSLDraw;//ポジション変更
        procedure LoopVSDraw;//マッチアップ
        procedure LoopDBDraw;//試合
        procedure LoopHDCDraw;//ハンディキャップ
        procedure LoopCSLDraw;//コートセレクト
        procedure LoopNAMENNAYODraw;//リセット
    end;
    //画面の色変え
    procedure ColorChange(ccc:TColor);
    //画像の描画
    procedure DDDraw(xxx:integer;yyy:integer;sr:TRect;ddsf:TDDDDSurface;Mask_f:boolean);
    //顔の描画
    procedure FaceDraw(i:integer;i2:integer;xxx:integer;yyy:integer;ftype:integer);
    //文字の描画
    procedure StrDraw(xxx:integer;yyy:integer;DStr:Widestring);
    //ＳＥをならす
    procedure SE(SENo:integer);
    //ＢＧＭをならす
    procedure SYSBGM(SYSNo:integer);
    //試合ＢＧＭをならす
    procedure BGM(BGMNo:integer);
    //ＢＧＭ一時停止（ポーズ中）
    procedure BGMStopSt(BGMNo:integer);
    //ＢＧＭ一時停止解除
    procedure BGMPlaySt(BGMNo:integer);
    //ＢＧＭストップ
    procedure BGMStop;
    //ＳＥすべてストップ
    procedure SEStop;
    //ＳＥ指定してストップ
    procedure SEStop2(SENo:integer);
    //引数／１００でTrueを返す
    function  Per100(i:integer):boolean ;
    //引数／αでTrueを返す（難易度によって変化する）
    function  LvPer100(i:integer):boolean;

const
    //FrameRate = 1 / 60;
    //PNUM = 0;
    MAG = 2;//倍率
    DEFFPS  = 16;
    REPUNIT = 120;
    MAXGSP = 3;
    //ＳＥとＢＧＭのかず
    SENum = 38;
    SYSNum = 1;
    BGMNum = 10;
    CurColMax = 30;//カーソル点滅のカウンタ上限
    CurColHalf = 15;//その半分
    FRate = 18;//18/1000秒に１フレーム
    WD = 56;
type
    PauseType = (ptNone,ptPause,ptSbS);
var
    Form1: TForm1;//フォーム
    //fx:DDBLTFX;//ddBlt用構造体
    KB : array[0..1] of integer;
    UseKB : integer;
    //フレームレート計算用
    fps1 : Integer;
    fps2 : Integer;
    temptime : LongInt;
    temptime2 : LongInt;
    FPSSkip_c:integer;//FPSスキップ
    St_time:integer;
    Ed_time:integer;
    Sp_time:integer;
    //TwoHit（左右の連打）用の変数
    NowKey  : array[0..3] of integer;//今のキー
    LastKey : array[0..3] of integer;//直前のキー
    TLag    : array[0..3] of integer;//その間隔
    WaitTime: integer;//リセット時などの待ち時間
    BGMwait : integer;//ＢＧＭの待ち時間
    //OP
    OPBGM_c :integer;
    MSLPicNo:integer;
    //TSL
    Key_f   : Boolean; //fの時だけキー入力ＯＫ
    CurCol : array[0..1] of integer;//カーソルの点滅
    CurPos : array[0..1] of integer; //カーソルの位置
    //PSL
    PSLCol : array[0..1] of integer;
    GetReady_c :integer;//DBまでの間
    CPSL_c :integer;//ko
    CPSLMember:integer;
    PSLNo: array[0..1] of integer; //何人目を選択しているか
    PSLData : array[0..1,0..5] of integer;//変更後のポジション[プレーヤー、ポジション]＝人
    PSLData2 : array[0..1,0..5] of integer;//変更後のポジション2[プレーヤー、人]＝ポジション
    //VS
    VS_c:integer;//待ち時間
    StBer_c: array[0..1] of integer;

    GameMode    :integer;//ゲームモード（ループの選択）

    PNum        :integer;//プレイヤー人数
    UseDev      :array[0..3] of integer;
    //ポーズボタンが押されたフラグ
    JoyPBtn_f :boolean;
    KeyPBtn_f :boolean;
    //ini
    FSc_f : Boolean;//フルスクリーン
    FPS_f :boolean; //フレームレートを表示する
    TBP_f :boolean;//timebeginperiodをつかう
    FPS30_f:boolean; //描画スキップ
    HalfSize_f :boolean;//320*240
    //Mag:integer;//画面倍率を入れておくための変数

    //音
    //dsSYS       : array[0..SYSNum] of TDirectSoundBuffer;//BGM
    //dsBGM       : array[0..BGMNum] of TDirectSoundBuffer;//試合BGM
    //dsSE        : array[0..SENum]  of TDirectSoundBuffer;//SE

    Init_f : boolean; //初期化フラグ

    ppal      :P_PaletteData;

    FormHalt_f:boolean = False;
    F5_f      :boolean = False;
    Pause     :PauseType = ptNone;
    FPSWaitB  :cardinal= DEFFPS;
    GameSpeed :integer = 0;
    FPS30_c   :integer = 0;

    DebugTxt_f :boolean = True;
    TCol_f:boolean;
    FScr_f:boolean;
    FileVer   :string;
    rp_al     :string;



implementation

uses DBUnit;

{$R *.dfm}

procedure TForm1.DXINILoad;
begin
    //空に
    ZeroMemory(@(Glb.DXINI),sizeof(TDXINI));
    //ファイルの読み込み file loading
    DtLoading(BDCOM + '\dxini.sai',@(Glb.DXINI),sizeof(TDXINI));
end;
procedure TForm1.DBINILoad;
begin
    //空に
    ZeroMemory(@(Glb.DBINI),sizeof(TDBINI));
    //ファイルの読み込み file loading
    DtLoading(BDCOM + '\dbini.sai',@(Glb.DBINI),sizeof(TDBINI));
end;

procedure DataReset();
var
    i:integer;
    i2:integer;
begin

    PNum := 1;
    WaitTime  := 0;
    PauseAble_f := False;
    Pause_f   := 0;
    OP_f      := False;
    OPBGM_c   := 0;
    JoyPBtn_f := False;
    KeyPBtn_f := False;
    FPSSkip_c := 0;
    CurCol[0] := 0;
    CurCol[1] := 0;
    FPSSkip_c := 0;//こうして無理やりＮＯＷＬＯＡＤＩＮＧ表示
    BGMStop;
    SEStop;
    //データ初期化
    for i2 := 0 to 1 do begin
        P[i2] := InitP;
    end;
    //データ初期化
    for i := 0 to 5 do begin
        C[i] := InitC;
    end;
    Ball := InitBall;
end;

//フォームクリエイト
procedure TForm1.FormCreate(Sender: TObject);
begin

    //*************

    timeBeginPeriod(1);

    //Randomize;
    //Ｇｌｂ生成
    Glb := TGlobalDB.Create(Form1);
    GC := TGlbConst.Create;

    DDDD_Msg('★フォーム生成開始');
    //Glb.PC := PC1;

    //定数
    //GC := TGlbConst.Create;

    //↓コレがあるとデバッグログが上手く生成できない  If there is this, the debug log cannot be generated well
    //FileMode := fmOpenRead or fmShareDenyWrite;//ファイルモード変更（読込専用）

    Self.ClientHeight := DDDD_HEIGHT * MAG;
    Self.ClientWidth  := DDDD_WIDTH  * MAG;
    //エラーフラグ初期化  Error flag initialization
    FPS_c := 0;
    //FileVer := GetExeVer;


    DXINILoad;
    //デバッグファイルの書き出しはddddと同じで  Writing a debug file is the same as dddd.
    DDDD_DebugMessage := (Glb.DXINI.DbgLog = 0);
    AL32_DebugMode    := DDDD_DebugMessage;
    
    DDDD_Msg('★DXINILoad');


    DDDD_Msg('★DBINILoad');
    DBINILoad;

    DDDD_Msg('★TOggDataCtrl.Create');

    //OC生成
    OC  := TOggDataCtrl.Create(DDSD1,Glb.DXINI.DSBufSize);
    Glb.OC := OC;//Glbにも持たせる


    Form1.Show;

    Glb.InitMsg('DDDD初期化',0);

    DDDD1Init(nil,False);
    
end;

//システムメモリにロード
procedure TForm1.LoadBMPs(var ddsf:TDDDDSurface;FileName:String;Wid:integer;Hei:integer);
begin

end;

//ビデオメモリにロード
procedure TForm1.LoadBMPv(var ddsf:TDDDDSurface;FileName:String;Wid:integer;Hei:integer);
begin

end;

//DDraw初期化
procedure TForm1.DDDD1Init(Sender: TObject; fNeedChange: Boolean);
var
    i:integer;
    Wid:integer;
    Hei:integer;
begin

    //PC1.Start(1);
    if Glb.DXINI.UseRAM = 1 then begin
        DDDD1.SurfaceLocation := smtSystemMemory;
    end;

    DDDD1.Use3D := (Glb.DXINI.UseD3D = 0);

    //16bit
    TCol_f := (Glb.DXINI.TexFmt = 1);
    //FullScr
    FScr_f := (Glb.DXINI.ScreenType = 1);
    if FScr_f then begin
        //フルスクリーン
        DDDD1.FullScreenMode2(MAG,TCol_f,False);
    end else begin
        //QVGAウインドウ
        DDDD1.WindowMode(DDDD_WIDTH*MAG,DDDD_HEIGHT*MAG);
    end;
    Glb.InitMsg('Window初期化',1);

    //ＡＬ生成
    AL  := TAlpha32DB.Create(DDDD1,PC1,(not DDDD1.Use3D),TCol_f,Glb,MAG,10000);
    //補正
    AL.POINTTEXELFIX := (Glb.DXINI.TexelFix / 100);
    AL.SetAspect(1,False);
    //行進曲は0,0にしとく
    AL.aspcX := 0;
    AL.aspcY := 0;
    //AL.LoadCirTx('font\cir.png');

    //ＴＷ生成
    TW := TAnti_DelX.Create(AL,'汎用',0,0,0,0);
    Glb.TW := TW;//Glbにも持たせる

    //ＡＤＩ生成
    ADI := TADIDB.Create(DDIDEX1,Glb,FScr_f);
    Glb.ADI := ADI;//Glbにも持たせる

    Glb.InitMsg('DDID初期化',2);

    //ＦＤ生成
    FD  := TFontDraw.Create(AL);
    Glb.FD := FD;//Glbにも持たせる


    //F5Reset(True,False);
    Randomize;
    Glb.RandSeed := RandSeed;

    //ＳＣ生成
    ///SC  := TSceneCtrl.Create(DDDD1,AL,TW,ADI,OC,Glb,Form1);
    ///SC.CfgBtn;

    //キーコンフィグ key configuration
    Glb.CfgBtn;

    AT := TAllTx.Create(AL,Glb);


    //ADI初期化（scenectrlでコマンド用変数を読み込むためここで。
    //saiでは要らない
    //ADI.Init(Glb.BC.BC2.CmdTimeBase,Glb.BC.BC2.CmdTimeKey,Glb.BC.BC2.AboutCmd);

    //PC1.Stop(1);
    Glb.SetInf('初期化完了'+SpTime(PC1.GetTime(1)));

    Init_f := True;

    INISet;

    DataReset;
    HardClear := -1;
    MSLPicNo := -1;
    GameLv := 1;

    //メインループの取り付け
    Application.OnIdle := MainLoop;

    GameMode := NAMENNAYO;


end;


//サーフェイスの解放
procedure TForm1.SfFree(ddsf:TDDDDSurface);
begin
    ddsf.Free;
    ddsf := nil;
end;

//DDraw消滅
procedure TForm1.DDDD1Destroy(Sender: TObject);
begin
    FreeAndNil(AT);
    FreeAndNil(FD);
    FreeAndNil(ADI);
    FreeAndNil(TW);
    FreeAndNil(AL);

end;

//*******************************************************************************
//メインループ
//*****************************************************************************)
procedure TForm1.MainLoop(Sender: TObject; var Done: Boolean);
    procedure Drawing;
    begin
        //SC.OnDraw;
        case GameMode of
            OP      : LoopOPDraw;
            MSL     : LoopMSLDraw;
            VS      : LoopVSDraw;
            TSL     : LoopTSLDraw;
            PSL     : LoopPSLDraw;
            HDC     : LoopHDCDraw;
            CSL     : LoopCSLDraw;
            DB      : LoopDBDraw;
            NAMENNAYO : LoopNAMENNAYODraw;
        end;
        AL.Rendering;
        DDDD1.Flip;
    end;

    procedure Moving;
    begin

        //スキャン
        ADI.Scan(False);
        AL.Clear(0);
        //ループ
        case GameMode of
            OP      : LoopOP;
            MSL     : LoopMSL;
            VS      : LoopVS;
            TSL     : LoopTSL;
            PSL     : LoopPSL;
            HDC     : LoopHDC;
            CSL     : LoopCSL;
            DB      : LoopDB;
            NAMENNAYO : LoopNAMENNAYO;
        end;
    end;
var
    Msg_f:boolean;
    rp_m,
    rp_s,
    i:integer;
    rp_nw:string;
    PlaySp:string;
    FPSWait2:cardinal;//FPS30

begin




  if Glb.Halt_f = False then begin
    try
        if FPS30_c = 0 then begin
            FPSWait2 := FPSWaitB;
        end else begin
            FPSWait2 := FPSWaitB * 2;
        end;

        st := TimeGetTime;// - ov;

        //ポーズ Pause
        if Glb.ADI.DI[0].CheckBtn(bSL) then begin
            if Pause = ptNone then begin
                Pause := ptPause ;
                Glb.SetInf('止まれー');
            end else begin
                Pause := ptNone;
                Glb.SetInf('動けー');
            end;
        end;

        //瞬時に表示したい場合 If you want instant display
        if (DebugTxt_f) then begin
            for i := 0 to High(Glb.DbgTxt) do begin
                if Glb.DbgTxt[i] <> '' then begin

                    Form1.Canvas.FillRect(Bounds(2,2+(i*20),200,20));
                    Form1.Canvas.TextOut(2,2+(i*20),Glb.DbgTxt[i]);
                end;
            end;
        end;

        if (ADI.RpSt = rpsEnd) then begin
            Glb.SetInf('リプレイ終了 PUSH F5 or F9');
            Drawing;
        //ポーズ Pause
        end else if (Pause = ptPause) then begin
            //リプレイ中はスキャンしない（コマ送りの時おかしくなる  Don't scan during replay (breaks frame-by-frame)
            if ADI.RpSt = rpsNone then ADI.Scan(False);
            //Drawing;
        end else begin

            //PC1.Start64(0);

            //スロー、通常再生
            if GameSpeed <= 0 then begin
                //SC.OnMove;
                Moving;
            //倍速
            end else begin
                for i := 0 to GameSpeed do begin
                    //SC.OnMove;
                    Moving;
                end;
            end;

            if FPS30_c >= 0 then begin
                Drawing;
            end;

            if Pause = ptSbS then Pause := ptPause;

            //SC.OnJump;

            if FPS30_c < 0 then begin
                FPS30_c := -FPS30_c;
                Done := False;
                Exit;
            end else begin
                FPS30_c := -FPS30_c;
            end;

            //PC1.Stop64(0);

            //Glb.LoopTime := PC1.GetTime64(0);

            Sleep(1);
            et := TimeGetTime;

            while (cardinal(et-st) < FPSWait2) do begin
                et := TimeGetTime;
                Application.ProcessMessages;
                //Sleep(1);
            end;

            //オーバー時間 over time
            ov := (et-st) - FPSWait2;

            //スキップ  skip
            for i := 0 to 31 do begin
                if ov > FPSWait2 then begin
                    //1f進める advance 1f
                    //SC.OnMove;
                    Moving;
                    //返済
                    st := st + FPSWait2;//1f進んだところ 1f advanced
                    et := TimeGetTime;  //終わり時間は更新 end time updated
                    ov := (et-st) - FPSWait2;
                end else begin
                    Break;
                end;
            end;

            //FPS計測用
            if FPS30_c = 0 then begin
                UpToR(FPS_c,60);
            end else begin
                UpToR(FPS_c,30);
            end;


            et1000 := TimeGetTime;

        end;

        //警告灯
        Msg_f := False;

        if (AL.AlertMsg <> '') then begin
            Form1.Caption := AL.AlertMsg;
            Msg_f := True;
        end;

        if (Glb.AlertMsg <> '') and (Msg_f = False) then begin
            Form1.Caption := Glb.AlertMsg;
            Msg_f := True;
        end;

        if (Glb.IdleInf) and (Msg_f = False) then begin
            Form1.Caption := Glb.InfMsg;
            Msg_f := True;
        end;

        if (ADI.RpSt = rpsLoad) and (Msg_f = False)  then begin
            //rp_f := (ADI.DI[0].msRep.Position mod REPUNIT) div 2;
            rp_s := ADI.DI[0].msRep.Position div REPUNIT;
            rp_m := rp_s div 60;
            rp_s := rp_s mod 60;
            if rp_s < 10 then begin
                rp_nw:= ':0' + inttostr(rp_s);
            end else begin
                rp_nw:= ':' + inttostr(rp_s);
            end;
            rp_nw:= inttostr(rp_m) + rp_nw;

            if Pause = ptNone then begin
                case GameSpeed of
                    -1:PlaySp := '>>　';
                     0:PlaySp := '＞　';
                     1:PlaySp := '>1　';
                     2:PlaySp := '>2　';
                     3:PlaySp := '>3　';
                    else PlaySp := '■　';
                end;
            end else begin
                PlaySp := '||　'
            end;


            Form1.Caption := 'リプレイ再生中　' + PlaySp
                            + rp_nw+ '／' + rp_al;
            Msg_f := True;
            st1000 := et1000;
        end;

        if (et1000 - st1000) > 1000 then begin
            if DebugTxt_f then begin
              if (FScr_f = False) and (Msg_f = False) then begin

                  Form1.Caption := 'DtDodgeball';

                  {
                  if (not DDDD1.Use3D) then begin
                      Form1.Caption := '- ドッジ 07/07/22 '
                                       + FileVer
                                       + ' - DirectDrawで描画 '
                                       + ' - FPS ' + IntToStr(FPS_c)
                                       + ' - ms' + IntToStr(PC1.GetTime64M(0)) + 'μ秒/Loop'
                                       //+ '  ov' + IntToStr(ov)
                                       //+ ' - Rp #'+ inttostr(ADI.SlotNo)
                                       ;
                  end else begin
                      Form1.Caption := '- ドッジ 07/07/22'
                                       + FileVer
                                       + ' - Direct3Dで描画 '
                                       + ' - FPS ' + IntToStr(FPS_c)
                                       + ' - ms' + IntToStr(PC1.GetTime64M(0)) + 'μ秒/Loop'
                                       //+ '  ov' + IntToStr(ov)
                                       //+ ' - Rp #'+ inttostr(ADI.SlotNo)
                                       ;
                  end;
                  }
              end;
            end;
            FPS_c := 1;
            st1000 := et1000;
        end;

        Done := False;
    except
        Glb.Halt_f := True;
    end;
  end else begin
      Application.OnIdle := nil;//ループを止める stop the loop
      ADI.SlotNo := random(1000)+10;
      ADI.SaveReplay(True);//取れるのか？ can i get it?
      DDDD1.WindowMode(DDDD_WIDTH,DDDD_HEIGHT);
      ShowMessage('エラーですな（'+ Glb.ErrMsg +':'+ IntToStr(Glb.ErrNo)+ '）');
      Application.Terminate;
  end;
end;

//キーダウン
procedure TForm1.FormKeyDown(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin

    //ＥＳＣで終了
    if Key=VK_ESCAPE then begin

        Application.Terminate;
        Key:=0;
    //ポーズ
    end else if (Key = VK_F3) then begin
        if (KeyPBtn_f = False) and (PauseAble_f = True) then begin
            if Pause_f = 0 then begin
                Pause_f := 1;
            end else begin
                Pause_f := 3;
            end;
            Key:=0;
        end;
        KeyPBtn_f := True;
    //リセット
    end else if (Key=VK_F1) and (GameMode <> OP)then begin

        DataReset;
        GameMode := NAMENNAYO;
        Key:=0;
    end else if (Key=VK_F5) then begin
        Glb.SetInf('ini読み込み');
        GC.IOIni(True);
    end;

end;
//キーアップ
procedure TForm1.FormKeyUp(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin
    if Key=VK_F3 then begin
        KeyPBtn_f := False;
        Key := 0;
    end;
end;
//フォーム消滅
procedure TForm1.FormDestroy(Sender: TObject);
var
    i:integer;
begin



    FreeAndNil(OC);
    FreeAndNil(GC);
    FreeAndNil(Glb);

    Application.OnIdle := nil;
    if ppal <> nil then Dispose(ppal);//パレット
    timeEndPeriod(1);

end;

////ループども//====================================================================
//キーコンフィグ//====================================================================
procedure TForm1.INISet;
var
    i:integer;
    i2:Integer;
    ////キーコード読み込み//--------------------------------------------------------------------
    procedure LoadCFG;
    var
        IniFile: TIniFile;
        i: integer;
    begin
        //iniファイル読み込み
        IniFile := TIniFile.Create(ExtractFilePath(Application.ExeName)+'config.ini');
        //キーコード読み込み
        KeyCode[0,0] := IniFile.ReadInteger('Key0','U',87);
        KeyCode[0,1] := IniFile.ReadInteger('Key0','D',83);
        KeyCode[0,2] := IniFile.ReadInteger('Key0','L',65);
        KeyCode[0,3] := IniFile.ReadInteger('Key0','R',68);
        KeyCode[0,4] := IniFile.ReadInteger('Key0','A',66);
        KeyCode[0,5] := IniFile.ReadInteger('Key0','B',86);
        KeyCode[0,6] := IniFile.ReadInteger('Key0','C',78);
        KeyCode[0,7] := IniFile.ReadInteger('Key0','ST',77);
        KeyCode[1,0] := IniFile.ReadInteger('Key1','U',38);
        KeyCode[1,1] := IniFile.ReadInteger('Key1','D',40);
        KeyCode[1,2] := IniFile.ReadInteger('Key1','L',37);
        KeyCode[1,3] := IniFile.ReadInteger('Key1','R',39);
        KeyCode[1,4] := IniFile.ReadInteger('Key1','A',98);
        KeyCode[1,5] := IniFile.ReadInteger('Key1','B',97);
        KeyCode[1,6] := IniFile.ReadInteger('Key1','C',99);
        KeyCode[1,7] := IniFile.ReadInteger('Key1','ST',100);

        //ゲームパッド読み込み
        for i := 0 to 3 do begin
            JoyCode[i,0] := IniFile.ReadInteger('Joy' + IntToStr(i),'A',1);
            JoyCode[i,1] := IniFile.ReadInteger('Joy' + IntToStr(i),'B',2);
            JoyCode[i,2] := IniFile.ReadInteger('Joy' + IntToStr(i),'C',3);
            JoyCode[i,3] := IniFile.ReadInteger('Joy' + IntToStr(i),'ST',4);
            JoyCode[i,4] := IniFile.ReadInteger('Joy' + IntToStr(i),'U',5);
            JoyCode[i,5] := IniFile.ReadInteger('Joy' + IntToStr(i),'D',6);
            JoyCode[i,6] := IniFile.ReadInteger('Joy' + IntToStr(i),'L',7);
            JoyCode[i,7] := IniFile.ReadInteger('Joy' + IntToStr(i),'R',8);
            CBtn_f[i]    := IniFile.ReadBool('Joy' + IntToStr(i),'+',False);
        end;
        //フルスクリーン
        FSc_f := IniFile.ReadBool('System','FullScreen',True);
        //フレームレート表示
        FPS_f := IniFile.ReadBool('System','FPS',False);
        //timebeginperiod
        TBP_f := IniFile.ReadBool('System','TBP',False);
        //描画スキップ
        FPS30_f:= IniFile.ReadBool('System','FPS30',False);
        //320*240
        HalfSize_f := IniFile.ReadBool('System','Half',False);
        //iniファイル解放
        IniFile.Free;
    end;
    ////キャラデータセット//--------------------------------------------------------------------
    procedure SetDt(sTNo,sNo:integer;sName:string;sFace,sFT,sHP,sBP,sST,sTK,sSp,sCT,sGu,sJSP,sDSP:integer);
    begin
        with LoadDt[sTNo].DBC[sNo] do begin
            //ステータス
            Face := (sTNo*10)+sFace;
            FaceType := sFT;
            Name := sName;
            dNo := (sTNo*10)+sNo;
            dHP := sHP;
            dBP := sBP;
            dST := sST;
            dTK := sTK;
            dSp := sSp - 5;
            dCT := sCT;
            dGu := sGu;
            dJSp:= sJSP;
            dDSp:= sDSP;
        end;
        //チームステータスの平均
        TeamData[sTNo,0] := TeamData[sTNo,0]+sHP;
        TeamData[sTNo,1] := TeamData[sTNo,1]+sBP;
        TeamData[sTNo,2] := TeamData[sTNo,2]+sST;
        TeamData[sTNo,3] := TeamData[sTNo,3]+sTK;
        TeamData[sTNo,4] := TeamData[sTNo,4]+sSp;
        TeamData[sTNo,5] := TeamData[sTNo,5]+sCT;
        TeamData[sTNo,6] := TeamData[sTNo,6]+sGu;

        TeamData2[sTNo,sNo,0] := sHP;
        TeamData2[sTNo,sNo,1] := sBP;
        TeamData2[sTNo,sNo,2] := sST;
        TeamData2[sTNo,sNo,3] := sTK;
        TeamData2[sTNo,sNo,4] := sSp;
        TeamData2[sTNo,sNo,5] := sCT;
        TeamData2[sTNo,sNo,6] := sGu;
        TeamData2[sTNo,sNo,7] := sJSP;
        TeamData2[sTNo,sNo,8] := sDSP;

    end;
    {
    procedure KBSet(DXI:TDXInput;PNo:integer);
    var
        i:integer;
    begin
        with DXI.Keyboard do begin
            for i := 0 to 2 do begin
                KeyAssigns[isup,i]      :=0;
                KeyAssigns[isdown,i]    :=0;
                KeyAssigns[isleft,i]    :=0;
                KeyAssigns[isright,i]   :=0;
                KeyAssigns[isbutton1,i] :=0;
                KeyAssigns[isbutton2,i] :=0;
                KeyAssigns[isbutton3,i] :=0;
                KeyAssigns[isbutton4,i] :=0;
            end;
        end;
        if (UseKB < 2) and (DXI.Joystick.ButtonCount = 0) then begin
            KB[UseKB]:=PNo;
            inc(UseKB);
            JoyCode[PNo,0] := 1;
            JoyCode[PNo,1] := 2;
            JoyCode[PNo,2] := 3;
            JoyCode[PNo,3] := 4;
        end;
    end;
    procedure KBSet2(tSetNo:integer;DXI:TDXInput);
    begin
        with DXI.Keyboard do begin
            KeyAssigns[isup,0]      :=KeyCode[tSetNo,0];
            KeyAssigns[isdown,0]    :=KeyCode[tSetNo,1];
            KeyAssigns[isleft,0]    :=KeyCode[tSetNo,2];
            KeyAssigns[isright,0]   :=KeyCode[tSetNo,3];
            KeyAssigns[isbutton1,0] :=KeyCode[tSetNo,4];
            KeyAssigns[isbutton2,0] :=KeyCode[tSetNo,5];
            KeyAssigns[isbutton3,0] :=KeyCode[tSetNo,6];
            KeyAssigns[isbutton4,0] :=KeyCode[tSetNo,7];
        end;
    end;
    }
begin
    //乱数初期化
    Randomize;

    //INIT読み込み
    LoadCFG;
    {
    //キーボードセット
    KB[0]:=-1;
    KB[1]:=-1;
    UseKB:= 0;

    
    KBSet(DXInput1,0);
    KBSet(DXInput2,1);
    KBSet(DXInput3,2);
    KBSet(DXInput4,3);

    //キーボードiにキーを設定
    for i := 0 to 1 do begin
        case KB[i] of
            0:KBSet2(i,DXInput1);
            1:KBSet2(i,DXInput2);
            2:KBSet2(i,DXInput3);
            3:KBSet2(i,DXInput4);
        end;
    end;
    }

    //ステータスセット
  //SetDt(T,C,'名前'      ,F,FT,HP,BP,ST,TK,Sp,CT,Gu, JSP, DSP);
    SetDt(0,0,'くにお'    ,0, 0,40,12, 9, 7, 7, 8, 7,Snat,Skan);
    SetDt(0,1,'ひろし'    ,1, 0,28, 7, 7, 9, 8, 9,12,Sbun,Ssun);
    SetDt(0,2,'こうじ'    ,2, 0,28, 7, 7, 9, 9,12, 8,Sina,Ssuk);
    SetDt(0,3,'いちろう'  ,3, 0,32, 8, 7, 9,12, 8, 7,Smoz,Skak);
    SetDt(0,4,'しんいち'  ,4, 0,32, 8, 9,12, 8, 7, 7,Sass,Sobu);
    SetDt(0,5,'みつひろ'  ,5, 0,36, 9,12, 8, 7, 7, 7,Skas,Sapp);
  //SetDt(T,C,'名前'      ,F,FT,HP,BP,ST,TK,Sp,CT,Gu, JSP, DSP);
    SetDt(1,0,'りき'      ,0, 0,36,12, 6, 8, 5, 6, 7,Sbun,Sapp);
    SetDt(1,1,'とおる'    ,5, 0,28, 8,10,10, 5, 5, 7,Sbuy,Skan);
    SetDt(1,2,'あきら'    ,3, 0,24, 7, 4,11,12, 6, 6,Snat,Ssuk);
    SetDt(1,3,'まさひこ'  ,2, 0,20, 6, 3,11, 8,11, 8,Skas,Sbuu);//obu
    SetDt(1,4,'なりたか'  ,1, 0,16, 5, 5,11, 7, 7,13,Sbuy,Swaa);
    SetDt(1,5,'しんたろう',4, 0,24, 7, 6,15, 7, 4, 7,Shoe,Skak);
  //SetDt(T,C,'名前'      ,F,FT,HP,BP,ST,TK,Sp,CT,Gu, JSP, DSP);
    SetDt(2,0,'じえむす'  ,0, 1,48,11,12, 4, 4, 6, 4,Sina,Ssun);
    SetDt(2,1,'すこっと'  ,2, 0,36, 6,10, 6, 6,10, 5,Shoe,Skan);
    SetDt(2,2,'はわあど'  ,5, 0,44, 8,15, 5, 4, 5, 4,Smoz,Ssuk);
    SetDt(2,3,'じおじ'    ,4, 0,40, 7,12, 9, 5, 5, 4,Sbun,Sbuu);
    SetDt(2,4,'ろばあと'  ,1, 0,36, 6,10, 6, 5, 7, 9,Snat,Sobu);
    SetDt(2,5,'りちあど'  ,3, 0,40, 7,10, 6, 9, 6, 4,Sbuy,Sapp);
  //SetDt(T,C,'名前'      ,F,FT,HP,BP,ST,TK,Sp,CT,Gu, JSP, DSP);
    SetDt(3,0,'らはまあん',0, 3,20, 9, 7,10,11, 5,13,Shoe,Sobu);
    SetDt(3,1,'むはまど'  ,1, 0,16, 6, 7,10,11, 5,16,Sbun,Skan);
    SetDt(3,2,'さったある',3, 0,16, 6, 7,10,14, 5,13,Smoz,Ssun);
    SetDt(3,3,'へっだ'    ,2, 0,16, 6, 7,10,11, 8,13,Sina,Sbuu);
    SetDt(3,4,'あふだら'  ,4, 0,16, 6, 7,13,11, 5,13,Sass,Skak);
    SetDt(3,5,'するたあん',5, 0,16, 6,10,10,11, 5,13,Skas,Swaa);
  //SetDt(T,C,'名前'      ,F,FT,HP,BP,ST,TK,Sp,CT,Gu, JSP, DSP);
    SetDt(4,0,'へいるまん',0, 1,64,14, 9, 3, 3, 7, 8,Smoz,Swaa);
    SetDt(4,1,'りむっそん',4, 0,52, 9, 9,10, 5, 5, 8,Shoe,Sapp);
    SetDt(4,2,'よあんせん',5, 0,56,10,13, 5, 3, 6, 8,Sbuy,Sobu);
    SetDt(4,3,'ないまん'  ,3, 0,52, 9, 7, 6,10, 7, 7,Snat,Sbuu);
    SetDt(4,4,'とろっせん',1, 0,44, 7, 8, 6, 5, 8,14,Sass,Ssun);
    SetDt(4,5,'けっこねん',2, 0,48, 8, 6, 6, 6,12, 9,Skas,Skak);
  //SetDt(T,C,'名前'      ,F,FT,HP,BP,ST,TK,Sp,CT,Gu, JSP, DSP);
    SetDt(5,0,'らおちぇん',0, 2,40,11,10, 7,10,13, 6,Sbuy,Skak);
    SetDt(5,1,'うぇんはお',3, 0,36, 8,10, 7,13,13, 6,Sbun,Sobu);
    SetDt(5,2,'りいふぁん',2, 0,36, 8,10, 7,10,16, 6,Shoe,Swaa);
    SetDt(5,3,'たあうぇい',1, 0,36, 8,10, 7,10,13, 9,Snat,Sapp);
    SetDt(5,4,'しゃおちん',5, 0,36, 8,13, 7,10,13, 6,Smoz,Sbuu);
    SetDt(5,5,'ゆんつぁい',4, 0,36, 8,10,10,10,13, 6,Sina,Skan);
  //SetDt(T,C,'名前'      ,F,FT,HP,BP,ST,TK,Sp,CT,Gu, JSP, DSP);
    SetDt(6,0,'もるどふ'  ,0, 3,56,16, 8, 7, 4,10, 8,Sass,Ssuk);
    SetDt(6,1,'こりあのふ',2, 0,40,10, 5,10, 7,15, 9,Sbun,Swaa);
    SetDt(6,2,'みれいにん',5, 0,48,12,12, 9, 4, 9, 8,Skas,Sbuu);
    SetDt(6,3,'いるちょふ',3, 0,44,11, 6,10,11,10, 7,Sina,Sapp);
    SetDt(6,4,'ろふすきい',4, 0,44,11, 8,14, 6, 8, 8,Smoz,Skan);
    SetDt(6,5,'まれんこふ',1, 0,36, 9, 7,10, 6,11,14,Sbuy,Ssun);
  //SetDt(T,C,'名前'      ,F,FT,HP,BP,ST,TK,Sp,CT,Gu, JSP, DSP);
    SetDt(7,0,'んじょも'  ,0, 2,44,13, 9, 5,11, 9, 9,Sbuy,Sbuu);
    SetDt(7,1,'むば'      ,4, 0,36, 9, 9,10,12, 8, 9,Snat,Swaa);
    SetDt(7,2,'びりまな'  ,1, 0,32, 8, 7, 7,12,10,14,Smoz,Sobu);
    SetDt(7,3,'みこんべ'  ,5, 0,40,10,12, 6,11, 8, 9,Shoe,Ssuk);
    SetDt(7,4,'にぱれれ'  ,2, 0,32, 8, 7, 7,13,13,10,Sass,Sapp);
    SetDt(7,5,'もっきい'  ,3, 0,36, 9, 7, 7,16, 9, 9,Skas,Skan);
  //SetDt(T,C,'名前'      ,F,FT,HP,BP,ST,TK,Sp,CT,Gu, JSP, DSP);
    SetDt(8,0,'ういりあむ',0, 1,60,15, 8, 8, 7,11,10,Skas,Ssuk);
    SetDt(8,1,'じょん'    ,1, 0,56,12, 8, 8, 7,11,13,Snat,Ssun);
    SetDt(8,2,'まいける'  ,2, 0,56,12, 8, 8, 7,14,10,Shoe,Sbuu);
    SetDt(8,3,'らんでい'  ,4, 0,56,12, 8,11, 7,11,10,Sbun,Skak);
    SetDt(8,4,'びる'      ,3, 0,56,12, 8, 8,10,11,10,Sbuy,Swaa);
    SetDt(8,5,'すていぶ'  ,5, 0,56,12,11, 8, 7,11,10,Sina,Sobu);
  //SetDt(T,C,'名前'      ,F,FT,HP,BP,ST,TK,Sp,CT,Gu, JSP, DSP);
    SetDt(9,0,'くにお'    ,0, 0,56,14,12,12,12,12,12,Snat,Skan);
    SetDt(9,1,'ひろし２'  ,1, 0,44,12,12,12,12,12,14,Sbun,Ssun);
    SetDt(9,2,'こうじ'    ,2, 0,44,12,12,12,12,14,12,Sina,Ssuk);
    SetDt(9,3,'いちろう'  ,3, 0,48,12,12,12,14,12,12,Smoz,Skak);
    SetDt(9,4,'しんいち'  ,4, 0,48,12,12,14,12,12,12,Sass,Sobu);
    SetDt(9,5,'みつひろ'  ,5, 0,52,12,14,12,12,12,12,Skas,Sapp);

    //チームステータスの表示に使う値（全員の平均値）
    for i2 := 0 to 8 do begin
        for i := 0 to 6 do begin
            if i = 0 then begin
                //HP
                TeamData[i2,i] := TeamData[i2,i] * 2 div 24;
            end else begin
                TeamData[i2,i] := TeamData[i2,i] * 2 div 6 ;
            end;
        end;
    end;

end;

//リセット//====================================================================
procedure TForm1.LoopNamennayo;
var
    SrcRect: TRect;
begin

    {    サーフェースのどの部分をコピーするか計算    }
    //暗転
    //
    //SrcRect := Bounds(136,88,24,16);
    //DDDraw(296,224,SrcRect,ddsfFont,True);
    WaitTime  := 30;
    OPBGM_c := 25;
    GameMode := OP;
    //なめんなよ
    {
    if Per100(50) then begin
        SE(37);
    end else begin
        SE(36);
    end;
    }

end;
procedure TForm1.LoopNAMENNAYODraw;
begin
    DDDD1.BackBuffer.FillRect(Bounds(0,0,320*Mag,240*Mag),0);
end;

//オープニング//====================================================================
procedure TForm1.LoopOP;
var
    SrcRect: TRect;
begin

    {    サーフェースのどの部分をコピーするか計算    }
    {
    if (OPBGM_c = 26) and (Init_f = True) then begin
        SYSBGM(0);
        OPBGM_c := 27;
    end else if (OPBGM_c < 26) then begin
        //スタートまで若干間を持たす
        inc(OPBGM_c);
    end else begin

        if ADI.DI[0].CheckAnyBtn then begin
        //if P[0].KeyP = True then begin
            OP_f := False;
            GameMode  := MSL;
            SYSBGM(0);
            PNum := 0;
            CurCol[0] := 0;
            CurCol[1] := 0;
            CurPos[0] := 0;
            CurPos[1] := GameLv;

            inc(MSLPicNo);//MSLの画像
            if MSLPicNo > 12 then MSLPicNo := 1;
            //SE(1);
        end;
    end;
    }
            OP_f := False;
            GameMode  := MSL;
            SYSBGM(0);
            PNum := 0;
            CurCol[0] := 0;
            CurCol[1] := 0;
            CurPos[0] := 0;
            CurPos[1] := GameLv;

            inc(MSLPicNo);//MSLの画像
            if MSLPicNo > 12 then MSLPicNo := 1;
            //SE(1);
end;
procedure TForm1.LoopOPDraw;
begin
    {    サーフェースのどの部分をコピーするか計算   Calculate which part of the surface to copy }
    if (OPBGM_c = 26) and (Init_f = True) then begin
        AL.DrawTexLT(AT.OPtx,0,0,432,240,0,0,DEFPRI);
    end else if (OPBGM_c < 26) then begin

    end else begin

        AL.DrawTexLT(AT.OPtx,0,0,432,240,0,0,DEFPRI);
    end;
end;

//ゲームモード選択//====================================================================
procedure TForm1.LoopMSL;
var
    SrcRect : TRect;
    r3: TRect;
    i       :Integer;
    i2      :integer;
    BX :integer;
    BY :integer;
    DX :integer;
    DY :integer;
begin

    if ADI.DI[0].CheckCrs(cU) then begin
        SE(0);
        if CurPos[0] > 0 then Dec(CurPos[0]);
    end else if ADI.DI[0].CheckCrs(cD) then begin
        SE(0);
        if CurPos[0] < 1 then Inc(CurPos[0]);
    end;

    if ADI.DI[0].CheckCrs(cL) then begin
        SE(0);
        if CurPos[1] > 0 then Dec(CurPos[1]);
    end else if ADI.DI[0].CheckCrs(cR) then begin
        SE(0);
        if CurPos[1] < 2 then Inc(CurPos[1]);
    end;

    if ADI.DI[0].CheckBtn(bA) then begin
        VS_c := 0;
        StBer_c[0] := 0;
        StBer_c[1] := 0;
        BGMStop;
        Ball.BColor := BCol1;
        GameLv := CurPos[1];//なんいど012
        NODead_f:= True;

        for i2 := 0 to 1 do begin
            for i := 0 to 2 do begin
                HDCDt[i2,i] := 0;//ハンデなし
            end;
        end;


            Ensei_f := True;
            Stage := 1;

            //if ADI.DI[1].CheckJump2 = True then Stage := 9;
            //if P[1].KeyJ2 = True then Stage := 9;

            SE(17);
            GameMode  := VS;
            //GameMode  := CSL;

            CPU_f := True;
            P[0].TeamNo := 0;//一応いまのところ熱血のみ
            P[1].TeamNo := Stage;//兼ステージ
            //やさしいのときはひっさつたいみんぐハンデやさしいと同じ
            if GameLv = 0 then begin
                HDCDt[0,2] := 1;
            end;

            if CurPos[0] = 1 then begin
                CPU_f := False;
            end;
        {
        if CurPos[0] = 0 then begin
            Ensei_f := True;
            Stage := 1;

            //if ADI.DI[1].CheckJump2 = True then Stage := 9;
            //if P[1].KeyJ2 = True then Stage := 9;

            SE(17);
            GameMode  := VS;
            //GameMode  := CSL;

            CPU_f := True;
            P[0].TeamNo := 0;//一応いまのところ熱血のみ
            P[1].TeamNo := Stage;//兼ステージ
            //やさしいのときはひっさつたいみんぐハンデやさしいと同じ
            if GameLv = 0 then begin
                HDCDt[0,2] := 1;
            end;

        //対抗試合
        end else begin
            Ensei_f := False;
            Stage := 0;
            GameMode  := TSL;
            SYSBGM(1);
            CPU_f := False;
            if CurPos[0] = 1 then CPU_f := True;//VSCPU
            
            for i2 := 0 to 1 do begin
                P[i2].TeamNo := -1;//未決定状態
                CurCol[i2] := 0;
                CurPos[i2] := 0;
            end;
        end;
        }

    end;
    //カーソル点滅
    inc(CurCol[0]);
    if CurCol[0] >= CurColMax then CurCol[0] := 0;

end;

procedure TForm1.LoopMSLDraw;
var
    SrcRect : TRect;
    r3: TRect;
    i       :Integer;
    i2      :integer;
    BX :integer;
    BY :integer;
    DX :integer;
    DY :integer;

    procedure BDSet(tBX:integer;tBY:integer;tDX:integer;tDY:integer);
    begin
        BX := tBX;
        BY := tBY;
        DX := tDX;
        DY := tDY;
    end;
    //ショートコント用描画（ボール）
    procedure MSLBDraw(dX,dY,bNo:integer);
    begin
        //ボールの形
        case bNo mod 10 of
            0:r3 := Bounds(0, 0, 16, 16);//●
            1:r3 := Bounds(128, 0, 16, 16);//　＼
            2:r3 := Bounds(144, 0, 16, 16);//　／
            3:r3 := Bounds(128, 16, 16, 16);//　ー
            4:r3 := Bounds(144, 16, 16, 16);//　・
        end;
        //必殺じゃないとき
        if bNo div 10 = 1 then begin
            r3.Top := r3.Top + 48;
            r3.Bottom := r3.Bottom + 48;
        end;
        //DDDraw(dX,dY,r3,ddsfDBItem,True);

        AL.DrawTexLT(AT.DBItemtx,r3.Left,r3.Top,16,16,dX,dY,DEFPRI);


    end;
    //ショートコント用描画（キャラ）
    procedure MSLDraw(dX,dY,fNo,mNo,Muki:integer;tNo:integer = 0);
    const
        CharY = 15;
    var
        cX      :integer;
        cY      :integer;
        mRevX :integer;
        mRevY :integer;
        bltX:integer;
        bltY:integer;
        //顔
        procedure r3Set();
        begin
            if Muki = Migi then begin
                r3 := Bounds(48*cX,32*cY,48,32);
            end else if Muki = Hidari then begin//補正が必要

                //r3 := Bounds(((ddsfDBBody[tNo].Width div Mag)-(48*cX)-48),32*(cY+CharY),48,32);
                r3 := Bounds(((AT.DBBody[tNo].Width div Mag)-(48*cX)-48),32*(cY+CharY),48,32);
            end;
        end;
        procedure MSLFDraw(ftype:integer);
        var
            sr :TRect;
            dr :TRect;
            RevX :integer;
            RevY :integer;
            procedure srSet(tL,tW:integer);
            begin
                if Muki = Migi then begin
                    sr.Left := tL;
                    sr.Right:= tL+tW;
                end else if Muki = Hidari then begin
                    sr.Right:= 144-tL;
                    sr.Left := 144-tL-tW;
                end;
            end;
        begin
            if FPSSkip_c = 0 then begin
                RevX:= 17;
                RevY:= 0;
                if (ftype >= 1) and (ftype <= 5) then begin
                    sr.Top := (10 * fNo) + (60 * tNo);
                    sr.Bottom := sr.Top+10;
                    case ftype of
                        1:begin//正面
                            srSet(0,16);
                        end;
                        2:begin//横
                            srSet(16,16);
                            //屈み
                            if (mNo = 309) then begin
                                sr.Bottom := sr.Top+9;
                            end else if (mNo = 310) then begin
                                sr.Bottom := sr.Top+8;
                            end;
                        end;
                        3:begin//倒れ、飲み
                            RevX:= 0;
                            RevY:= 16;
                            srSet(32,8);
                        end;
                        4:begin//勝ち
                            srSet(56,16);
                        end;
                        5:begin//後ろ
                            srSet(40,16);
                        end;
                    end;
                    if Muki = Hidari then begin
                        RevX := 48 - RevX - (sr.Right-sr.Left);
                    end;
                    sr := Rect(sr.Left,sr.Top,sr.Right,sr.Bottom);
                    dr := Bounds((bltX+RevX),(bltY+RevY),sr.Right-sr.Left,sr.Bottom-sr.Top);
                    //ddsfDBFace.Put(dr,sr,DDBLT_WAIT or DDBLT_KEYSRC,fx);
                    //AT.DBFacetx
                    AL.DrawTexLT(AT.DBFacetx,sr.Left,sr.Top,sr.Right-sr.Left,sr.Bottom-sr.Top,dr.Left+WD,dr.Top,DEFPRI);
                end;
            end;
        end;

    begin
        cX := (mNo div 100);
        cY := (mNo mod 100);
        mRevX := DBMNo[cX,cY,1];
        mRevY := DBMNo[cX,cY,2];
        bltX := dX+(mRevX*Muki);
        bltY := dY+mRevY;

        //顔先描画
        if (DBMNo[cX,cY,3] div 10 = 1)
        or ((DBMNo[cX,cY,3] div 10 = 2) and ((fNo <> 1)and(fNo <> 4))) then begin
            MSLFDraw((DBMNo[cX,cY,3] mod 10));
        end;

        //いちろう(転がり、うつぶせ、吹っ飛び)
        if (fNo = 3) and (mNo >= 400) and (mNo <= 406) then begin
            //描画元画像一個右にシフト
            cX := cX + 1;
            r3Set;
            cX := cX - 1;
        end else begin
            r3Set;
        end;

        //描画
        //DDDraw(bltX,bltY,r3,ddsfDBBody[tNo],True);

        AL.DrawTexLT(AT.DBBody[tNo],r3.Left,r3.Top,48,32,bltX+WD,bltY,DEFPRI);

        //顔後描画
        if (DBMNo[cX,cY,3] div 10 = 0)
        or ((DBMNo[cX,cY,3] div 10 = 2) and ((fNo = 1)or(fNo = 4))) then begin
            MSLFDraw((DBMNo[cX,cY,3] mod 10));
        end;
    end;
begin

    //背景
    AL.DrawTexLT(at.MSLtx,0,0,432,240,0,0,DEFPRI);

    //カーソル点滅
    if CurCol[0] < CurColHalf then begin
        //SrcRect := Bounds(120, 88, 8, 8);
        //BDSet(64,56,0,16);
        BDSet(64,56,0,16);
        //カーソル描画
        //DDDraw(BX,BY+(CurPos[0])*DY,SrcRect,ddsfFont,True);

        AL.DrawTexLT(AT.Fonttx,120, 88, 8, 8,BX+WD,BY+(CurPos[0])*DY,DEFPRI);

        BDSet(64,200,64,0);
        //カーソル描画
        //DDDraw(BX+(CurPos[1])*DX,BY,SrcRect,ddsfFont,True);
        AL.DrawTexLT(AT.Fonttx,120, 88, 8, 8,BX+(CurPos[1])*DX+WD,BY,DEFPRI);
    end;

    //ショートコント風キャラ表示
    for i := 0 to 5 do begin
        MSLDraw(16+(48*i),128,(5-i),304,Migi);
    end;
end;

//マッチアップ
procedure TForm1.LoopVS;
var
    //画像表示用
    SrcRect : TRect;
    BX :integer;
    BY :integer;
    DX :integer;
    DY :integer;
    //ステータスバー用
    StBerData:integer;
    //ループ用
    i       :Integer;
    i2      :integer;
    //描画用変数の代入を楽にするもの
    procedure BDSet(tBX:integer;tBY:integer;tDX:integer;tDY:integer);
    begin
        BX := tBX;
        BY := tBY;
        DX := tDX;
        DY := tDY;
    end;

begin

    //背景
    inc(VS_c);
    if StBer_c[0] < 64 then begin
        inc(StBer_c[0]);
        StBer_c[1] := StBer_c[0];
    end;


    //チームステータス

    //ポジション変更へ
    if (VS_c > 380) or (ADI.DI[0].CheckBtn(bA)) then begin
        GameMode  :=PSL;//ポジションセレクトへ
        CPSL_c := -30;//PSLでＣＰＵのカーソルが動くまでの間
        CPSLMember := Random(5);//ＣＰＵオート選択
        If Stage = 1 then begin
            if Not((CPSLMember >= 2) and (CPSLMember <= 4)) then begin
                //なりたかを入れやすく
                CPSLMember := Random(5);//ＣＰＵオート選択
            end;
        end else If (Stage = 3) or (Stage = 8) then begin
            if ((CPSLMember >= 1) and (CPSLMember <= 3))  then begin
                //むはまどorじょんを入れやすく
                CPSLMember := Random(5);//ＣＰＵオート選択
            end;
        end;
        //データ初期化
        for i2 := 0 to 1 do begin
            for i := 0 to 5 do begin
                PSLData[i2,i] := -1;
                PSLData2[i2,i] := -1;
            end;
            StBer_c[i2] := 0;
            CurCol[i2] := 0;
            CurPos[i2] := 0;
            PSLNo[i2] := 0;
            PSLCol[i2] := 0;
        end;
        SEStop;
        SYSBGM(1);
    end;

end;

procedure TForm1.LoopVSDraw;
var
    //画像表示用
    SrcRect : TRect;
    BX :integer;
    BY :integer;
    DX :integer;
    DY :integer;
    //ステータスバー用
    StBerData:integer;
    //ループ用
    i       :Integer;
    i2      :integer;
    //描画用変数の代入を楽にするもの
    procedure BDSet(tBX:integer;tBY:integer;tDX:integer;tDY:integer);
    begin
        BX := tBX;
        BY := tBY;
        DX := tDX;
        DY := tDY;
    end;

begin

    //背景

    AL.DrawTexLT(AT.VStx,0,0,432,240,0,0,DEFPRI);

    //ステージ
    SrcRect := Bounds(((Stage) * 8), 0, 8, 8);
    //DDDraw(184,56,SrcRect,ddsfFont,True);
    AL.DrawTexDBLT(AT.Fonttx,SrcRect,184+WD,56,DEFPRI);

    //チームステータス

    //HPは1/4にしておく　データ入れ終わった時点で1/6にしておく
    for i2 := 0 to 1 do begin
        BDSet(112,144,136,8);
        for i := 0 to 6 do begin
            //謎の軍団の難易度によるステータス変更
            if (i2 = 1) and (Stage = 9) and (GameLv <> 2) then begin
                //やさしい
                if GameLv = 0 then begin
                    StBerData := TeamData[0,i];//ノーマル熱血と同じ
                //ふつう
                end else begin
                    if i <> 0 then begin
                        StBerData := TeamData[0,i];//ノーマル熱血と同じ
                    end else begin
                        StBerData := TeamData[P[i2].TeamNo,i];
                    end;
                end;
            end else begin
                StBerData := TeamData[P[i2].TeamNo,i];
            end;

            if (StBer_c[0] div 3) <= StBerData then begin
                SrcRect := Bounds(120, 184, StBer_c[0] div 3, 8);
            end else begin
                SrcRect := Bounds(120, 184, StBerData, 8);
            end;
            //DDDraw(BX+(i2*DX),BY+(i*DY),SrcRect,ddsfDBEtc,True);

            AL.DrawTexDBLT(AT.DBEtctx,SrcRect,BX+(i2*DX)+WD,BY+(i*DY),DEFPRI);
        end;

        BDSet(56,112,128,0);
        //国旗+チーム名
        SrcRect := Bounds(80,96+((P[i2].TeamNo)*8), 80, 8);
        //DDDraw(BX+(i2*DX),BY,SrcRect,ddsfDBEtc,True);
        AL.DrawTexDBLT(AT.DBEtctx,SrcRect,BX+(i2*DX)+WD,BY,DEFPRI);
        //キャプテン画像
        {
        BDSet(80,104,136,0);
        SrcRect := Bounds(((P[i2].TeamNo div 7)*80)+(i2*32),((P[i2].TeamNo mod 7) * 32), 32, 32);
        //DDDraw(BX+(i2*DX),BY,SrcRect,ddsfDBEtc,True);
        AL.DrawTexDBLT(AT.DBEtctx,SrcRect,BX+(i2*DX),BY,DEFPRI);
        }
    end;

end;

//ポジション変更/====================================================================
procedure TForm1.LoopPSL;
var
    //画像描画用
    SrcRect : TRect;
    i       :Integer;
    i2      :integer;
    BX :integer;
    BY :integer;
    DX :integer;
    DY :integer;
    //選手名前描画用
    NameS:integer;
    NameSX:integer;
    NameSY:integer;
    //顔の転送元座標
    F1 :integer;
    F2 :integer;
    //ステータスバー用
    StBerData:integer;
    Mir_f:MirrorFlag;

    DINo:integer;

    OKBtn_f:boolean;
    KEYR_f:boolean;

    //画像転送するための変数への代入を楽にするような感じのもの
    procedure BDSet(tBX:integer;tBY:integer;tDX:integer;tDY:integer);
    begin
        BX := tBX;
        BY := tBY;
        DX := tDX;
        DY := tDY;
    end;
    //その２
    procedure BSet(tBX:integer;tBY:integer);
    begin
        BY := tBY;
        if i2 = 0 then begin
            BX := tBX;
        end else begin
            BX := (320 - tBX)-8;
        end;
    end;
    //その３
    procedure BSet2(tBX:integer;tBY:integer);
    begin
        BY := tBY + 1;
        if i2 = 0 then begin
            BX := tBX-1;
        end else begin
            BX := (320 - tBX)-16+1;
        end;
    end;
    //じゅんびＯＫ
    procedure GetReady;
    var
        i       :Integer;
        i2      :integer;
    begin
        for i2 := 0 to 1 do begin
            for i := 0 to 5 do begin
                P[i2].DBC[i] := LoadDt[P[i2].TeamNo].DBC[PSLData[i2,i]];
                //謎の軍団の難易度によるステータス変更
                if (i2 = 1) and (Stage = 9) and (GameLv <> 2) then begin
                    //やさしい
                    if GameLv = 0 then begin
                        //ノーマル熱血と同じ
                        P[i2].DBC[i] := LoadDt[0].DBC[PSLData[i2,i]];
                        P[i2].DBC[i].Face := LoadDt[P[i2].TeamNo].DBC[PSLData[i2,i]].Face;
                        P[i2].DBC[i].dNo := LoadDt[P[i2].TeamNo].DBC[PSLData[i2,i]].dNo;
                    //ふつう
                    end else begin
                        //ＨＰのみ謎と同じ
                        P[i2].DBC[i] := LoadDt[0].DBC[PSLData[i2,i]];
                        P[i2].DBC[i].Face := LoadDt[P[i2].TeamNo].DBC[PSLData[i2,i]].Face;
                        P[i2].DBC[i].dNo := LoadDt[P[i2].TeamNo].DBC[PSLData[i2,i]].dNo;
                        P[i2].DBC[i].dHP := LoadDt[P[i2].TeamNo].DBC[PSLData[i2,i]].dHP;
                    end;
                end;

                //ＨＰ増加ハンディキャップ
                if HDCDt[i2,0] = 1 then begin
                    //150%
                    P[i2].DBC[i].dHP := P[i2].DBC[i].dHP * 3 div 2;
                end else if HDCDt[i2,0] = 2 then begin
                    //200%
                    P[i2].DBC[i].dHP := P[i2].DBC[i].dHP * 2;
                end;

                //キャプテンナンバー
                if P[i2].DBC[i].dNo mod 10 = 0 then P[i2].CapNo := i;
                P[i2].Cap_f := True;

                //初期配置
                if i = 3 then begin
                    if i2 = 0 then begin
                        P[i2].DBC[i].X := 300*100;
                    end else begin
                        P[i2].DBC[i].X := 132*100;
                    end;
                    P[i2].DBC[i].Z := 100*100;
                    P[i2].DBC[i].Muki := Hidari;
                    P[i2].DBC[i].Muki2 := Shita;
                    P[i2].DBC[i].Pos := 2;
                end else if i = 4 then begin
                    if i2 = 0 then begin
                        P[i2].DBC[i].X := 320*100;
                    end else begin
                        P[i2].DBC[i].X := 112*100;
                    end;
                    P[i2].DBC[i].Z := 8*100;
                    P[i2].DBC[i].Muki := Hidari;
                    P[i2].DBC[i].Muki2 := Ue;
                    P[i2].DBC[i].Pos := 3;
                end else if i = 5 then begin
                    if i2 = 0 then begin
                        P[i2].DBC[i].X := 408*100;
                    end else begin
                        P[i2].DBC[i].X := 24*100;
                    end;
                    P[i2].DBC[i].Z := 56*100;
                    P[i2].DBC[i].Muki := Hidari;
                    P[i2].DBC[i].Muki2 := None;
                    P[i2].DBC[i].Pos := 4;
                end else begin
                    P[i2].DBC[i].Muki := Migi;
                    P[i2].DBC[i].Muki2 := None;

                    case i of
                        0:begin
                            P[i2].DBC[i].X := 14000;
                            P[i2].DBC[i].Z := 5600;
                        end;
                        1:begin
                            P[i2].DBC[i].X := 9000;
                            P[i2].DBC[i].Z := 8000;
                        end;
                        2:begin
                            P[i2].DBC[i].X := 8000;
                            P[i2].DBC[i].Z := 3200;
                        end;
                    end;
                    if i2 = 1 then begin
                        P[i2].DBC[i].X := 43200-P[i2].DBC[i].X;
                    end;
                    P[i2].DBC[i].Pos := 1;
                end;

                if i2 = 1 then P[i2].DBC[i].Muki := -P[i2].DBC[i].Muki;

            end;

        end;
        P[0].pNo := 0;
        P[1].pNo := 0;
        //ボールデータの初期化
        with Ball do begin
            Motion := BBound;
            HoldChar := 20;
            X := 21500;
            Z := 5600;
            Y := 0;
            dZ := 0;
            dX := 0;
            dY := 500+Random(200);
        end;
        BGMStop;

        Ready_c := 180;
        GameSet_c := 0;
        Camera := 21600;
        GameMode  :=DB;

    end;
begin

    OKBtn_f := False;
    KEYR_f := False;

    for i2 := 0 to 1 do begin
        if (i2 = 1) and (CPU_f = True) then begin
            //謎の軍団以外
            if Stage <> 9 then begin
                //CPUオート選択
                Inc(CPSL_c);
                if CPSL_c = -1 then begin
                    OKBtn_f := True;
                end else if (CPSL_c >= 10) and (CPSLMember > 0) then begin
                    KEYR_f := True;
                    dec(CPSLMember);
                    CPSL_c := 0;
                    if CPSLMember = 0 then CPSL_c := 20;
                end else if CPSL_c >= 30 then begin
                    OKBtn_f := True;
                    CPSL_c := 0;
                end;
            //謎の軍団
            end else begin
                //１Ｐと完全にリンク（メンバー同じになる）
            end;
        end;

        if (i2 = 1) and CPU_f then begin
            //キー入力
            if (PSLNo[i2] <= 5) then begin
                if KEYR_f then begin
                    SE(0);
                    CurCol[i2] := 0;
                    StBer_c[i2] := 0;
                    for i := 0 to 5 do begin
                        Inc(CurPos[i2]);
                        if CurPos[i2] > 5 then CurPos[i2] := 0;
                        if PSLData2[i2,CurPos[i2]] = -1 then Break;
                    end;
                end;
            end;
            if OKBtn_f then begin
                if PSLNo[i2] < 6 then begin
                    PSLData[i2,PSLNo[i2]] := CurPos[i2];
                    PSLData2[i2,CurPos[i2]] := PSLNo[i2];
                    Inc(PSLNo[i2]);
                    CurCol[i2] := 0;
                    SE(38);
                    if PSLNo[i2] < 6 then begin
                        StBer_c[i2] := 0;
                        for i := 0 to 5 do begin
                            if PSLData2[i2,(CurPos[i2] + i) mod 6] = -1 then begin
                                CurPos[i2] := (CurPos[i2] + i) mod 6;
                                Break;
                            end;
                        end;
                    end;
                end;
            end;
        end else begin
            DINo := i2;

            //キー入力
            if (PSLNo[i2] <= 5) then begin
                if ADI.DI[DINo].CheckCrs(cU) then begin
                    SE(0);
                    CurCol[i2] := 0;
                    if CurPos[i2] > 2 then begin
                        if PSLData2[i2,(CurPos[i2]-3)] = -1 then begin
                            Dec(CurPos[i2],3);
                            StBer_c[i2] := 0;
                        end;
                    end;
                end else if ADI.DI[DINo].CheckCrs(cD) then begin
                    SE(0);
                    CurCol[i2] := 0;
                    if CurPos[i2] < 3 then begin
                        if PSLData2[i2,(CurPos[i2]+3)] = -1 then begin
                            Inc(CurPos[i2],3);
                            StBer_c[i2] := 0;
                        end;
                    end;
                end else if ADI.DI[DINo].CheckCrs(cL) then begin
                    SE(0);
                    CurCol[i2] := 0;
                    StBer_c[i2] := 0;
                    for i := 0 to 5 do begin
                        Dec(CurPos[i2]);
                        if CurPos[i2] < 0 then CurPos[i2] := 5;
                        if PSLData2[i2,CurPos[i2]] = -1 then Break;
                    end;
                end else if ADI.DI[DINo].CheckCrs(cR) or KEYR_f then begin
                    SE(0);
                    CurCol[i2] := 0;
                    StBer_c[i2] := 0;
                    for i := 0 to 5 do begin
                        Inc(CurPos[i2]);
                        if CurPos[i2] > 5 then CurPos[i2] := 0;
                        if PSLData2[i2,CurPos[i2]] = -1 then Break;
                    end;
                end;
            end;
            if ADI.DI[DINo].CheckBtn(bA) or OKBtn_f then begin
                if PSLNo[i2] < 6 then begin
                    PSLData[i2,PSLNo[i2]] := CurPos[i2];
                    PSLData2[i2,CurPos[i2]] := PSLNo[i2];
                    Inc(PSLNo[i2]);
                    CurCol[i2] := 0;
                    SE(38);
                    if PSLNo[i2] < 6 then begin
                        StBer_c[i2] := 0;
                        for i := 0 to 5 do begin
                            if PSLData2[i2,(CurPos[i2] + i) mod 6] = -1 then begin
                                CurPos[i2] := (CurPos[i2] + i) mod 6;
                                Break;
                            end;
                        end;
                    end;
                end;
            end else if ADI.DI[DINo].CheckBtn(bB) then begin
                //全決定後のキャンセルは初期化
                if PSLNo[i2] = 6 then begin
                    SE(38);
                    PSLNo[i2] := 0;
                    CurPos[i2] := 0;
                    CurCol[i2] := 0;
                    StBer_c[i2] := 0;
                    for i := 0 to 5 do begin
                        PSLData[i2,i] := -1;
                        PSLData2[i2,i] := -1;
                    end;
                end else if PSLNo[i2] > 0 then begin
                    Dec(PSLNo[i2]);
                    StBer_c[i2] := 0;
                    CurCol[i2] := 0;
                    CurPos[i2] := PSLData[i2,PSLNo[i2]];
                    PSLData[i2,PSLNo[i2]] := -1;
                    PSLData2[i2,CurPos[i2]] := -1;
                end;
            end;
        end;

    end;

    for i2 := 0 to 1 do begin

        //カーソル点滅
        inc(CurCol[i2]);
        if CurCol[i2] >= CurColMax then CurCol[i2] := 0;

        //ポジション番号点滅
        inc(PSLCol[i2]);
        if PSLCol[i2] >= CurColMax then PSLCol[i2] := 0;
    end;

    //キャラステータス
    for i2 := 0 to 1 do begin
        if StBer_c[i2] < 32 then begin
            inc(StBer_c[i2]);
        end;
    end;

    if (PSLNo[0] = 6) and (PSLNo[1] = 6) then begin
        inc(GetReady_c);
        if GetReady_c >= 60 then begin
            GetReady;
        end;
    end else begin
        GetReady_c := 0;
    end;

end;

procedure TForm1.LoopPSLDraw;
var
    //画像描画用
    SrcRect : TRect;
    i       :Integer;
    i2      :integer;
    BX :integer;
    BY :integer;
    DX :integer;
    DY :integer;
    //選手名前描画用
    NameS:integer;
    NameSX:integer;
    NameSY:integer;
    //顔の転送元座標
    F1 :integer;
    F2 :integer;
    //ステータスバー用
    StBerData:integer;
    Mir_f:MirrorFlag;

    //画像転送するための変数への代入を楽にするような感じのもの
    procedure BDSet(tBX:integer;tBY:integer;tDX:integer;tDY:integer);
    begin
        BX := tBX;
        BY := tBY;
        DX := tDX;
        DY := tDY;
    end;
    //その２
    procedure BSet(tBX:integer;tBY:integer);
    begin
        BY := tBY;
        if i2 = 0 then begin
            BX := tBX;
        end else begin
            BX := (320 - tBX)-8;
        end;
    end;
    //その３
    procedure BSet2(tBX:integer;tBY:integer);
    begin
        BY := tBY + 1;
        if i2 = 0 then begin
            BX := tBX-1;
        end else begin
            BX := (320 - tBX)-16+1;
        end;
    end;
    //じゅんびＯＫ
    procedure GetReady;
    var
        i       :Integer;
        i2      :integer;
    begin
        for i2 := 0 to 1 do begin
            for i := 0 to 5 do begin
                P[i2].DBC[i] := LoadDt[P[i2].TeamNo].DBC[PSLData[i2,i]];
                //謎の軍団の難易度によるステータス変更
                if (i2 = 1) and (Stage = 9) and (GameLv <> 2) then begin
                    //やさしい
                    if GameLv = 0 then begin
                        //ノーマル熱血と同じ
                        P[i2].DBC[i] := LoadDt[0].DBC[PSLData[i2,i]];
                        P[i2].DBC[i].Face := LoadDt[P[i2].TeamNo].DBC[PSLData[i2,i]].Face;
                        P[i2].DBC[i].dNo := LoadDt[P[i2].TeamNo].DBC[PSLData[i2,i]].dNo;
                    //ふつう
                    end else begin
                        //ＨＰのみ謎と同じ
                        P[i2].DBC[i] := LoadDt[0].DBC[PSLData[i2,i]];
                        P[i2].DBC[i].Face := LoadDt[P[i2].TeamNo].DBC[PSLData[i2,i]].Face;
                        P[i2].DBC[i].dNo := LoadDt[P[i2].TeamNo].DBC[PSLData[i2,i]].dNo;
                        P[i2].DBC[i].dHP := LoadDt[P[i2].TeamNo].DBC[PSLData[i2,i]].dHP;
                    end;
                end;

                //ＨＰ増加ハンディキャップ
                if HDCDt[i2,0] = 1 then begin
                    //150%
                    P[i2].DBC[i].dHP := P[i2].DBC[i].dHP * 3 div 2;
                end else if HDCDt[i2,0] = 2 then begin
                    //200%
                    P[i2].DBC[i].dHP := P[i2].DBC[i].dHP * 2;
                end;

                //キャプテンナンバー
                if P[i2].DBC[i].dNo mod 10 = 0 then P[i2].CapNo := i;
                P[i2].Cap_f := True;

                //初期配置
                if i = 3 then begin
                    if i2 = 0 then begin
                        P[i2].DBC[i].X := 300*100;
                    end else begin
                        P[i2].DBC[i].X := 132*100;
                    end;
                    P[i2].DBC[i].Z := 100*100;
                    P[i2].DBC[i].Muki := Hidari;
                    P[i2].DBC[i].Muki2 := Shita;
                    P[i2].DBC[i].Pos := 2;
                end else if i = 4 then begin
                    if i2 = 0 then begin
                        P[i2].DBC[i].X := 320*100;
                    end else begin
                        P[i2].DBC[i].X := 112*100;
                    end;
                    P[i2].DBC[i].Z := 8*100;
                    P[i2].DBC[i].Muki := Hidari;
                    P[i2].DBC[i].Muki2 := Ue;
                    P[i2].DBC[i].Pos := 3;
                end else if i = 5 then begin
                    if i2 = 0 then begin
                        P[i2].DBC[i].X := 408*100;
                    end else begin
                        P[i2].DBC[i].X := 24*100;
                    end;
                    P[i2].DBC[i].Z := 56*100;
                    P[i2].DBC[i].Muki := Hidari;
                    P[i2].DBC[i].Muki2 := None;
                    P[i2].DBC[i].Pos := 4;
                end else begin
                    P[i2].DBC[i].Muki := Migi;
                    P[i2].DBC[i].Muki2 := None;

                    case i of
                        0:begin
                            P[i2].DBC[i].X := 14000;
                            P[i2].DBC[i].Z := 5600;
                        end;
                        1:begin
                            P[i2].DBC[i].X := 9000;
                            P[i2].DBC[i].Z := 8000;
                        end;
                        2:begin
                            P[i2].DBC[i].X := 8000;
                            P[i2].DBC[i].Z := 3200;
                        end;
                    end;
                    if i2 = 1 then begin
                        P[i2].DBC[i].X := 43200-P[i2].DBC[i].X;
                    end;
                    P[i2].DBC[i].Pos := 1;
                end;

                if i2 = 1 then P[i2].DBC[i].Muki := -P[i2].DBC[i].Muki;

            end;

        end;
        P[0].pNo := 0;
        P[1].pNo := 0;
        //ボールデータの初期化
        with Ball do begin
            Motion := BBound;
            HoldChar := 20;
            X := 21500;
            Z := 5600;
            Y := 0;
            dZ := 0;
            dX := 0;
            dY := 500+Random(200);
        end;
        BGMStop;

        Ready_c := 180;
        GameSet_c := 0;
        Camera := 21600;
        GameMode  :=DB;

    end;
begin
    //背景
    SrcRect := Bounds(0,0,432,240);
    //DDDraw(0,0,SrcRect,ddsfPSL,False);
    AL.DrawTexDBLT(AT.PSLtx,SrcRect,0,0,DEFPRI);

    for i2 := 0 to 1 do begin

        if (PSLNo[i2] <= 5) and (CurCol[i2] < CurColHalf) then begin
            SrcRect := Bounds(120, 88, 8, 8);
            if i2 = 0 then begin
                BDSet(16,112,48,8);
            end else begin
                BDSet(168,112,48,8);
            end;
            AL.DrawTexDBLT(AT.Fonttx,SrcRect,BX+(CurPos[i2] mod 3)*DX+WD,BY+(CurPos[i2] div 3)*DY,DEFPRI);
        end;

        //ポジション番号点滅
        for i := 0 to 5 do begin
            if (PSLNo[i2] <> i) 
            or (PSLCol[i2] < CurColHalf) then begin
                case i of
                    0:begin
                        SrcRect := Bounds(24, 88, 8, 8);
                        BSet(144, 72);
                    end;
                    1:begin
                        SrcRect := Bounds(24, 88, 8, 8);
                        BSet(120, 72);
                    end;
                    2:begin
                        SrcRect := Bounds(24, 88, 8, 8);
                        BSet(96, 72);
                    end;
                    3:begin
                        SrcRect := Bounds(24+8, 88, 8, 8);
                        BSet(208, 48);
                    end;
                    4:begin
                        SrcRect := Bounds(24+16, 88, 8, 8);
                        BSet(216, 96);
                    end;
                    5:begin
                        SrcRect := Bounds(24+24, 88, 8, 8);
                        BSet(272, 72);
                    end;
                end;
                //番号描画
                AL.DrawTexDBLT(AT.Fonttx,SrcRect,BX+WD,BY,DEFPRI);
            end;
            //決定済みキャラの描画
            if PSLData[i2,i] <> -1 then begin
                case i of
                    0:begin
                        BSet2(128, 64);
                    end;
                    1:begin
                        BSet2(104, 64);
                    end;
                    2:begin
                        BSet2(80, 64);
                    end;
                    3:begin
                        BSet2(192, 40);
                    end;
                    4:begin
                        BSet2(200, 88);
                    end;
                    5:begin
                        BSet2(256, 64);
                    end;
                end;

                F1 := (60 *(LoadDt[P[i2].TeamNo].DBC[PSLData[i2,i]].Face div 10));
                F2 := (10 *(LoadDt[P[i2].TeamNo].DBC[PSLData[i2,i]].Face mod 10));

                //下部
                if LoadDt[P[i2].TeamNo].DBC[PSLData[i2,i]].FaceType = 3 then begin
                    SrcRect := Bounds(64+((P[i2].TeamNo div 7)*80),((P[i2].TeamNo mod 7)*32)+(i2*16)+8, 16, 8);
                end else begin
                    SrcRect := Bounds(64+((P[i2].TeamNo div 7)*80),((P[i2].TeamNo mod 7)*32)+(i2*16), 16, 8);
                end;
                //DDDraw(BX,BY+8,SrcRect,ddsfDBEtc,True);
                AL.DrawTexDBLT(AT.DBEtctx,SrcRect,BX+WD,BY+8,DEFPRI);

                //上部
                SrcRect := Bounds(0,(F1 + F2), 16,10);

                if i2 = 1 then begin
                    Mir_f := mirLR;
                end else begin
                    Mir_f := mirNone;
                end;
                //DDDraw(BX,BY,SrcRect,ddsfDBFace,True);
                AL.DrawTexDBLT(AT.DBFacetx,SrcRect,BX+WD,BY,DEFPRI,Mir_f);


                //名前横決定済みの場合ポジション表示
                if i2 = 0 then begin
                    BDSet(24, 112,48, 8);
                end else begin
                    BDSet(176, 112,48, 8);
                end;
                if i <= 2 then begin
                    SrcRect := Bounds(8, 0, 8, 8);
                end else begin
                    SrcRect := Bounds(8*(i-1), 0, 8, 8);
                end;
                //DDDraw(BX+((PSLData[i2,i] mod 3)*DX)-8,BY+((PSLData[i2,i] div 3)*DY),SrcRect,ddsfFont,True);
                AL.DrawTexDBLT(AT.Fonttx,SrcRect,BX+((PSLData[i2,i] mod 3)*DX)-8+WD,BY+((PSLData[i2,i] div 3)*DY),DEFPRI);
            end;
        end
    end;

    //HPは1/4にしておく　データ入れ終わった時点で1/6にしておく
    for i2 := 0 to 1 do begin

        BDSet(56,24,128,0);
        //国旗+チーム名
        SrcRect := Bounds(80,96+((P[i2].TeamNo)*8), 80, 8);
        //DDDraw(BX+(i2*DX),BY,SrcRect,ddsfDBEtc,True);
        AL.DrawTexDBLT(AT.DBEtctx,SrcRect,BX+(i2*DX)+WD,BY,DEFPRI);
        //全員の名前
        for i := 0 to 5 do begin

            if i2 = 0 then begin
                BDSet(24, 112,48, 8);
            end else begin
                BDSet(176, 112,48, 8);
            end;

            NameS := (P[i2].TeamNo * 6) + i;
            NameSX := (NameS div 30)*40;
            NameSY := (NameS mod 30)*8;

            SrcRect := Bounds(NameSX,NameSY,40,8);
            //DDDraw(BX+((i mod 3)*DX),BY+((i div 3)*DY),SrcRect,ddsfDBName,True);
            AL.DrawTexDBLT(AT.DBNametx,SrcRect,BX+((i mod 3)*DX)+WD,BY+((i div 3)*DY),DEFPRI);

            //選択キャラの名前
            if i = CurPos[i2] then begin
                //DDDraw(BX,160,SrcRect,ddsfDBName,True);
                AL.DrawTexDBLT(AT.DBNametx,SrcRect,BX+WD,160,DEFPRI);
                //選択キャラの顔
                BDSet(23, 145,154, 0);

                F1 := (60 *(LoadDt[P[i2].TeamNo].DBC[i].Face div 10));
                F2 := (10 *(LoadDt[P[i2].TeamNo].DBC[i].Face mod 10));

                //下部
                if LoadDt[P[i2].TeamNo].DBC[i].FaceType = 3 then begin
                    SrcRect := Bounds(64+((P[i2].TeamNo div 7)*80),((P[i2].TeamNo mod 7)*32)+(i2*16)+8, 16, 8);
                end else begin
                    SrcRect := Bounds(64+((P[i2].TeamNo div 7)*80),((P[i2].TeamNo mod 7)*32)+(i2*16), 16, 8);
                end;
                //DDDraw(BX+(i2*DX),BY+8,SrcRect,ddsfDBEtc,True);
                AL.DrawTexDBLT(AT.DBEtctx,SrcRect,BX+(i2*DX)+WD,BY+8,DEFPRI);
                if i2 = 1 then begin
                    Mir_f := mirLR;
                end else begin
                    Mir_f := mirNone;
                end;
                //上部
                SrcRect := Bounds(0,(F1 + F2), 16,10);
                //DDDraw(BX+(i2*DX),BY,SrcRect,ddsfDBFace,True);
                AL.DrawTexDBLT(AT.DBFacetx,SrcRect,BX+(i2*DX)+WD,BY,DEFPRI,Mir_f);
            end;

        end;

        //バー
        BDSet(120, 176,152, 8);
        for i := 0 to 6 do begin

            //謎の軍団の難易度によるステータス変更
            if (i2 = 1) and (Stage = 9) and (GameLv <> 2) then begin
                //やさしい
                if GameLv = 0 then begin
                    StBerData := TeamData2[0,CurPos[i2],i];//ノーマル熱血と同じ
                //ふつう
                end else begin
                    if i <> 0 then begin
                        StBerData := TeamData2[0,CurPos[i2],i];//ノーマル熱血と同じ
                    end else begin
                        StBerData := TeamData2[P[i2].TeamNo,CurPos[i2],i];
                    end;
                end;
            end else begin
                StBerData := TeamData2[P[i2].TeamNo,CurPos[i2],i];
            end;

            //ＨＰ増加ハンディキャップ
            If (i = 0) then begin
                if HDCDt[i2,0] = 1 then begin
                    //150%
                    StBerData := StBerData * 3 div 2;
                end else if HDCDt[i2,0] = 2 then begin
                    //200%
                    StBerData := StBerData * 2;
                end;
            end;

            //64オーバーの時も64で打ち止め
            if StBerData > 64 then StBerData := 64;
            //ＨＰとその他のステータス
            if i = 0 then begin
                if (StBer_c[i2]*2) <= StBerData then begin
                    SrcRect := Bounds(120, 184, StBer_c[i2], 8);
                end else begin
                    SrcRect := Bounds(120, 184, StBerData div 2, 8);
                end;
            end else begin
                if (StBer_c[i2]) <= (StBerData*2) then begin
                    SrcRect := Bounds(120, 184, StBer_c[i2], 8);
                end else begin
                    SrcRect := Bounds(120, 184, StBerData*2, 8);
                end;
            end;
            //DDDraw(BX+(i2*DX),BY+(i*DY),SrcRect,ddsfDBEtc,True);
            AL.DrawTexDBLT(AT.DBEtctx,SrcRect,BX+(i2*DX)+WD,BY+(i*DY),DEFPRI);
        end;

        //数値
        BDSet(96, 176,152, 8);
        for i := 0 to 6 do begin
            //謎の軍団の難易度によるステータス変更
            if (i2 = 1) and (Stage = 9) and (GameLv <> 2) then begin
                //やさしい
                if GameLv = 0 then begin
                    StBerData := TeamData2[0,CurPos[i2],i];//ノーマル熱血と同じ
                //ふつう
                end else begin
                    if i <> 0 then begin
                        StBerData := TeamData2[0,CurPos[i2],i];//ノーマル熱血と同じ
                    end else begin
                        StBerData := TeamData2[P[i2].TeamNo,CurPos[i2],i];
                    end;
                end;
            end else begin
                StBerData := TeamData2[P[i2].TeamNo,CurPos[i2],i];
            end;
            //ＨＰ増加ハンディキャップ
            If (i = 0) then begin
                if HDCDt[i2,0] = 1 then begin
                    //150%
                    StBerData := StBerData * 3 div 2;
                end else if HDCDt[i2,0] = 2 then begin
                    //200%
                    StBerData := StBerData * 2;
                end;
            end;

            //100の位
            if (StBerData div 100) > 0 then begin
                SrcRect := Bounds((StBerData div 100)*8,0,8,8);
                //DDDraw(BX+(i2*DX)-8,BY+(i*DY),SrcRect,ddsfFont,True);
                AL.DrawTexDBLT(AT.Fonttx,SrcRect,BX+(i2*DX)-8+WD,BY+(i*DY),DEFPRI);
            end;

            //10の位
            if ((StBerData mod 100 div 10) > 0)
            or ((StBerData div 100) > 0) then begin
                SrcRect := Bounds((StBerData mod 100 div 10)*8,0,8,8);
                //DDDraw(BX+(i2*DX),BY+(i*DY),SrcRect,ddsfFont,True);
                AL.DrawTexDBLT(AT.Fonttx,SrcRect,BX+(i2*DX)+WD,BY+(i*DY),DEFPRI);
            end;

            //1の位
            SrcRect := Bounds((StBerData mod 10)*8,0,8,8);
            //DDDraw(BX+(i2*DX)+8,BY+(i*DY),SrcRect,ddsfFont,True);
            AL.DrawTexDBLT(AT.Fonttx,SrcRect,BX+(i2*DX)+8+WD,BY+(i*DY),DEFPRI);
        end;

        //必殺シュート
        BDSet(96,152,152, 8);
        //ジャンプとダッシュ
        for i := 0 to 1 do begin
            SrcRect := Bounds(80,((TeamData2[P[i2].TeamNo,CurPos[i2],(i+7)]-1)*8),48,8);
            //DDDraw(BX+(i2*DX),BY+(i*DY),SrcRect,ddsfDBName,True);
            AL.DrawTexDBLT(AT.DBNametx,SrcRect,BX+(i2*DX)+WD,BY+(i*DY),DEFPRI);
        end;

    end;

end;

//チームセレクト//====================================================================
procedure TForm1.LoopTSL;
const
    BaseX2 = 8;
    BaseX3 = 8;
var
    //画像描画用
    SrcRect : TRect;
    BX :integer;
    BY :integer;
    DX :integer;
    DY :integer;
    //ループ用
    i       :Integer;
    i2      :integer;
    //変数への代入を楽にするもの
    procedure BDSet(tBX:integer;tBY:integer;tDX:integer;tDY:integer);
    begin
        BX := tBX;
        BY := tBY;
        DX := tDX;
        DY := tDY;
    end;
    //準備ＯＫ
    procedure GetReady();
    var
        j :integer;
        j2 :integer;
    begin
        GameMode  :=HDC;

        for j2 := 0 to 1 do begin
            for j := 0 to 5 do begin
                PSLData[j2,j] := -1;
                PSLData2[j2,j] := -1;
            end;
            StBer_c[j2] := 0;
            CurCol[j2] := 0;
            CurPos[j2] := 0;
            PSLNo[j2] := 0;
            PSLCol[j2] := 0;

        end;
        //SEStop;
        //SYSBGM(1);
        GetReady_c := 0;
    end;

begin

    SrcRect := Bounds(0,0,320,240);
    //DDDraw(0,0,SrcRect,ddsfTSL,False);
    AL.DrawTexDBLT(AT.TSLtx,SrcRect,0,0,DEFPRI);

    //キー入力
    //2P対戦
    if CPU_f = False then begin
        SrcRect := Bounds(96, 216, 16, 8);
        //DDDraw(232,48,SrcRect,ddsfDBEtc,True);
        AL.DrawTexDBLT(AT.DBEtctx,SrcRect,232,48,DEFPRI);

        for i2 := 0 to 1 do begin
            if P[i2].TeamNo = -1 then begin

                if ADI.DI[i2].CheckCrs(cU) then begin
                    SE(0);
                    Dec(CurPos[i2]);
                    StBer_c[i2] := 0;
                    if CurPos[i2] < 0 then CurPos[i2] := 8;
                    CurCol[i2] := 0;
                end else if ADI.DI[i2].CheckCrs(cD) then begin
                    SE(0);
                    Inc(CurPos[i2]);
                    StBer_c[i2] := 0;
                    if CurPos[i2] > 8 then CurPos[i2] := 0;
                    CurCol[i2] := 0;
                end;
            end;
            if ADI.DI[i2].CheckBtn(bA) then begin
                if P[i2].TeamNo = -1 then begin
                    P[i2].TeamNo := CurPos[i2];
                    SE(38);
                end;
            end else if ADI.DI[i2].CheckBtn(bB) then begin
                P[i2].TeamNo := -1;
            end;
        end;
    //VSCPU
    end else begin
        SrcRect := Bounds(112, 216, 24, 8);
        //DDDraw(232,48,SrcRect,ddsfDBEtc,True);
        AL.DrawTexDBLT(AT.DBEtctx,SrcRect,232,48,DEFPRI);
        if P[0].TeamNo = -1 then begin
            i2 := 0;
        end else begin
            i2 := 1;
        end;

        if ADI.DI[0].CheckCrs(cU) then begin
            SE(0);
            Dec(CurPos[i2]);
            StBer_c[i2] := 0;
            if CurPos[i2] < 0 then CurPos[i2] := 8;
            CurCol[i2] := 0;
        end else if ADI.DI[0].CheckCrs(cD) then begin
            SE(0);
            Inc(CurPos[i2]);
            StBer_c[i2] := 0;
            if CurPos[i2] > 8 then CurPos[i2] := 0;
            CurCol[i2] := 0;
        end;

        if ADI.DI[0].CheckBtn(bA) then begin
            P[i2].TeamNo := CurPos[i2];
            SE(38);
        end else if ADI.DI[0].CheckBtn(bB) then begin
            if P[1].TeamNo <> -1 then begin
                P[1].TeamNo := -1;
            end else begin
                P[0].TeamNo := -1;
            end;
        end;
    end;


    for i2 := 0 to 1 do begin
        //カーソル点滅
        inc(CurCol[i2]);
        if CurCol[i2] >= CurColMax then CurCol[i2] := 0;
        if Not((CPU_f = True) and (i2 = 1) and (P[0].TeamNo = -1)) then begin
            if (CurCol[i2] < CurColHalf) or (P[i2].TeamNo <> -1) then begin
                SrcRect := Bounds(128-(8*i2), 88, 8, 8);
                BDSet(72, 72,168, 16);
                //カーソル描画
                //DDDraw(BX+(DX*i2),BY+(CurPos[i2])*DY,SrcRect,ddsfFont,True);
                AL.DrawTexDBLT(AT.Fonttx,SrcRect,BX+(DX*i2),BY+(CurPos[i2])*DY,DEFPRI);
            end;
        end;
        //チームステータス
        if StBer_c[i2] < 32 then begin
            inc(StBer_c[i2]);
        end;
        //HPは1/4にしておく　データ入れ終わった時点で1/6にしておく

        for i := 0 to 6 do begin
            if i2 = 0 then begin
                BDSet(119,144+8,0,8);
                if (StBer_c[i2]) <= (TeamData[CurPos[i2],i]) then begin
                    SrcRect := Rect(111-(StBer_c[i2]),184,111,192);
                    //DDDraw(BX-(StBer_c[i2]),BY+(DY*i),SrcRect,ddsfDBEtc,True);
                    AL.DrawTexDBLT(AT.DBEtctx,SrcRect,BX-(StBer_c[i2]),BY+(DY*i),DEFPRI);
                end else begin
                    SrcRect := Rect(111-(TeamData[CurPos[i2],i]),184,111,192);
                    //DDDraw(BX-(TeamData[CurPos[i2],i]),BY+(DY*i),SrcRect,ddsfDBEtc,True);
                    AL.DrawTexDBLT(AT.DBEtctx,SrcRect,BX-(TeamData[CurPos[i2],i]),BY+(DY*i),DEFPRI);
                end;
            end else begin
                BDSet(200,144+8,0,8);
                if (StBer_c[i2]) <= (TeamData[CurPos[i2],i]) then begin
                    SrcRect := Bounds(120, 184, StBer_c[i2], 8);
                end else begin
                    SrcRect := Bounds(120, 184, TeamData[CurPos[i2],i], 8);
                end;
                //DDDraw(BX,BY+(DY*i),SrcRect,ddsfDBEtc,True);
                AL.DrawTexDBLT(AT.DBEtctx,SrcRect,BX,BY+(DY*i),DEFPRI);
            end;
        end;
        BDSet(80,104-24,80,0);
        //国旗+チーム名
        SrcRect := Bounds(80,96+(CurPos[i2]*8), 80, 8);
        //DDDraw(BX+(i2*DX),BY,SrcRect,ddsfDBEtc,True);

        AL.DrawTexDBLT(AT.DBEtctx,SrcRect,BX+(i2*DX),BY,DEFPRI);

        //キャプテン画像
        BDSet(104,104,80,0);
        SrcRect := Bounds(((CurPos[i2] div 7)*80)+(i2*32),((CurPos[i2] mod 7) * 32), 32, 32);
        //DDDraw(BX+(i2*DX),BY,SrcRect,ddsfDBEtc,True);
        AL.DrawTexDBLT(AT.DBEtctx,SrcRect,BX+(i2*DX),BY,DEFPRI);
    end;

    if (P[0].TeamNo <> -1) and (P[1].TeamNo <> -1) then begin
        inc(GetReady_c);
        if GetReady_c >= 30 then begin
            GetReady;
        end;
    end else begin
        GetReady_c := 0;
    end;

end;
procedure TForm1.LoopTSLDraw;
begin

end;

//ハンディキャップ選択//====================================================================
procedure TForm1.LoopHDC;
const
    BaseX2 = 8;
    BaseX3 = 8;
var
    //画像描画用
    SrcRect : TRect;
    BX :integer;
    BY :integer;
    DX :integer;
    DY :integer;
    //ループ用
    i       :Integer;
    i2      :integer;
    procedure BDSet(tBX:integer;tBY:integer;tDX:integer;tDY:integer);
    begin
        BX := tBX;
        BY := tBY;
        DX := tDX;
        DY := tDY;
    end;
    procedure GetReady();
    var
        j2 :integer;
    begin
        GameMode  :=CSL;
        GetReady_c := 0;
        for j2 := 0 to 1 do begin
            StBer_c[j2] := 0;
            CurCol[j2] := 0;
            CurPos[j2] := 0;
        end;
        //SYSBGM(1);
    end;

begin

    SrcRect := Bounds(0,0,320,240);
    //DDDraw(0,0,SrcRect,ddsfHDC,False);
    AL.DrawTexDBLT(AT.HDCtx,SrcRect,0,0,DEFPRI);

    //キー入力
    if CPU_f = False then begin
        SrcRect := Bounds(96, 216, 16, 8);
        //DDDraw(232,48,SrcRect,ddsfDBEtc,True);
        AL.DrawTexDBLT(AT.DBEtctx,SrcRect,232,48,DEFPRI);

        for i2 := 0 to 1 do begin
            if CurPos[i2] < 3 then begin

                if ADI.DI[i2].CheckCrs(cL) then begin
                    SE(0);
                    if HDCDt[i2,CurPos[i2]] > 0 then Dec(HDCDt[i2,CurPos[i2]]);
                    CurCol[i2] := 0;
                end else if ADI.DI[i2].CheckCrs(cR) then begin
                    SE(0);
                    if HDCDt[i2,CurPos[i2]] < 2 then Inc(HDCDt[i2,CurPos[i2]]);
                    CurCol[i2] := 0;
                end;
            end;
            if ADI.DI[i2].CheckBtn(bA) then begin
                if CurPos[i2] < 3 then begin
                    inc(CurPos[i2]);
                    CurCol[i2] := 0;
                    SE(38);
                end;
            end else if ADI.DI[i2].CheckBtn(bB) then begin
                if CurPos[i2] > 0 then begin
                    dec(CurPos[i2]);
                    CurCol[i2] := 0;
                    //SE(38);
                end;
            end;
        end;
    end else begin
        SrcRect := Bounds(112, 216, 24, 8);
        //DDDraw(232,48,SrcRect,ddsfDBEtc,True);
        AL.DrawTexDBLT(AT.DBEtctx,SrcRect,232,48,DEFPRI);

        if CurPos[0] = 3 then begin
            i2 := 1;
        end else begin
            i2 := 0;
        end;
        if CurPos[i2] < 3 then begin
            if ADI.DI[i2].CheckCrs(cL) then begin
                SE(0);
                if HDCDt[i2,CurPos[i2]] > 0 then Dec(HDCDt[i2,CurPos[i2]]);
                CurCol[i2] := 0;
            end else if ADI.DI[i2].CheckCrs(cR) then begin
                SE(0);
                if HDCDt[i2,CurPos[i2]] < 2 then Inc(HDCDt[i2,CurPos[i2]]);
                CurCol[i2] := 0;
            end;
        end;
        if ADI.DI[i2].CheckBtn(bA) then begin
            if CurPos[i2] < 3 then begin
                inc(CurPos[i2]);
                CurCol[i2] := 0;
                SE(38);
            end;
        end else if ADI.DI[i2].CheckBtn(bB) then begin
            if CurPos[i2] > 0 then begin
                dec(CurPos[i2]);
                CurCol[i2] := 0;
                //SE(38);
            end else begin
                if i2 = 1 then begin
                    CurPos[0] := 2;
                end;
            end;
        end;
    end;
    for i2:= 0 to 1 do begin
        //カーソル点滅
        inc(CurCol[i2]);
        if CurCol[i2] >= CurColMax then CurCol[i2] := 0;
        //選択中
        if CurPos[i2] < 3 then begin
            if Not((CPU_f = True) and (i2 = 1) and (CurPos[0] < 3)) then begin
                if (CurCol[i2] < CurColHalf) then begin
                    SrcRect := Bounds(128-8, 88, 8, 8);
                    BDSet(8, 112,160, 40);
                    //カーソル描画
                    //DDDraw(BX+(HDCDt[i2,CurPos[i2]]*48)+(i2*DX),BY+(CurPos[i2])*DY,SrcRect,ddsfFont,True);
                    AL.DrawTexDBLT(AT.Fonttx,SrcRect,BX+(HDCDt[i2,CurPos[i2]]*48)+(i2*DX),BY+(CurPos[i2])*DY,DEFPRI);
                end;
            end;
        //ＯＫ！
        end else begin

            SrcRect := Bounds(80, 216, 16, 8);
            BDSet(72, 216,160, 0);
            //DDDraw(BX+(i2*DX),BY,SrcRect,ddsfDBEtc,True);
            AL.DrawTexDBLT(AT.DBEtctx,SrcRect,BX+(i2*DX),BY,DEFPRI);
        end;

        //点灯文字（３列）
        BDSet(16, 112,160, 40);
        for i := 0 to 2 do begin
            SrcRect := Bounds(80+(HDCDt[i2,i]*32), 192+(i*8), 32, 8);
            //DDDraw(BX+(HDCDt[i2,i]*48)+(i2*DX),BY+(i*DY),SrcRect,ddsfDBEtc,True);
            AL.DrawTexDBLT(AT.DBEtctx,SrcRect,BX+(HDCDt[i2,i]*48)+(i2*DX),BY+(i*DY),DEFPRI);
        end;

        BDSet(40,72,160,0);
        //国旗+チーム名
        SrcRect := Bounds(80,96+(P[i2].TeamNo*8), 80, 8);
        //DDDraw(BX+(i2*DX),BY,SrcRect,ddsfDBEtc,True);
        AL.DrawTexDBLT(AT.DBEtctx,SrcRect,BX+(i2*DX),BY,DEFPRI);
    end;

    if (CurPos[0] = 3) and (CurPos[1] = 3)  then begin
        inc(GetReady_c);
        if GetReady_c >= 30 then begin
            GetReady;
        end;
    end else begin
        GetReady_c := 0;
    end;
    
end;
procedure TForm1.LoopHDCDraw;
begin

end;

//コート選択//====================================================================
procedure TForm1.LoopCSL;
const
    BaseX2 = 8;
    BaseX3 = 8;
var
    //画像描画用
    SrcRect : TRect;
    BX :integer;
    BY :integer;
    DX :integer;
    DY :integer;

    procedure BDSet(tBX:integer;tBY:integer;tDX:integer;tDY:integer);
    begin
        BX := tBX;
        BY := tBY;
        DX := tDX;
        DY := tDY;
    end;
    procedure GetReady();
    var
        j2 :integer;
    begin
        GameMode  :=PSL;
        Stage := ((CurPos[0] div 10) * 3) + (CurPos[0] mod 10);
        for j2 := 0 to 1 do begin
            StBer_c[j2] := 0;
            CurCol[j2] := 0;
            CurPos[j2] := 0;
        end;
        SYSBGM(1);
    end;

begin

    SrcRect := Bounds(0,0,320,240);
    //DDDraw(0,0,SrcRect,ddsfCSL,False);
    AL.DrawTexDBLT(AT.CSLtx,SrcRect,0,0,DEFPRI);

    //キー入力

    if ADI.DI[0].CheckCrs(cU) then begin
        SE(0);
        CurCol[0] := 0;
        if CurPos[0] div 10 > 0 then dec(CurPos[0],10);
    end else if ADI.DI[0].CheckCrs(cD) then begin
        SE(0);
        CurCol[0] := 0;
        if CurPos[0] div 10 < 2 then inc(CurPos[0],10);
    end else if ADI.DI[0].CheckCrs(cL) then begin
        SE(0);
        CurCol[0] := 0;
        if CurPos[0] mod 10 > 0 then dec(CurPos[0]);
    end else if ADI.DI[0].CheckCrs(cR) then begin
        SE(0);
        CurCol[0] := 0;
        if CurPos[0] mod 10 < 2 then inc(CurPos[0]);
    end;

    if (ADI.DI[0].CheckBtn(bA)) and (GetReady_c = 0) then begin
        SE(38);
        GetReady_c := 1;
    end else if (ADI.DI[0].CheckBtn(bB)) then begin
        GetReady_c := 0;
    end;

    //カーソル点滅
    inc(CurCol[0]);
    if CurCol[0] >= CurColMax then CurCol[0] := 0;
    if (CurCol[0] < CurColHalf) or (GetReady_c >= 1) then begin
        SrcRect := Bounds(128-8, 88, 8, 8);
        BDSet(24, 80,104, 72);
        //カーソル描画
        //DDDraw(BX+((CurPos[0] mod 10)*DX),BY+((CurPos[0] div 10)*DY),SrcRect,ddsfFont,True);
        AL.DrawTexDBLT(AT.Fonttx,SrcRect,BX+((CurPos[0] mod 10)*DX),BY+((CurPos[0] div 10)*DY),DEFPRI);

    end;

    if GetReady_c >= 1 then begin
        inc(GetReady_c);
        if GetReady_c >= 30 then begin
            GetReady;
        end;
    end else begin
        GetReady_c := 0;
    end;

end;
procedure TForm1.LoopCSLDraw;
begin

end;

//ドッジ試合//====================================================================
procedure TForm1.LoopDB;
var
    i  : integer;
begin

    //スタート
    If Ready_c > 0 then begin
        if Ready_c = 174 then SE(18);
        dec(Ready_c);
        //if Ready_c = 0 then BGM(Stage);
        if Ready_c = 0 then BGM(2);
        for i := 0 to 1 do begin
            P[i].TwoHit := None;
        end;
        //DBKeyInput;
        DBMotionType;
        DBMove;
        DBAction;
        //DBBallAction;
        //DBJudge;
        //DBBlt;
        PauseAble_f := False;

    //勝ち＆負け
    end else If GameSet_c > 0 then begin
        dec(GameSet_c);
        if GameSet_c = 380 then begin
            if P[1].Dead_c >= 3 then begin
                Camera := 16000;
                //対ＣＰＵ
                if Ensei_f = True then begin
                    if ((Stage = 8) and (NODead_f = False))
                    or (Stage = 9) then begin
                        SE(21);//優勝
                        //パスワード
                        if Stage = 9 then begin
                            HardClear:=GameLv;
                        end;
                    end else begin
                        SE(19);
                    end;
                end else begin
                    SE(19);
                end;
            end else if P[0].Dead_c >= 3 then begin
                Camera := (432-160)*100;
                if CPU_f = True then begin
                    SE(20);//敗北音
                end else begin
                    SE(19);//勝利音
                end;
            end;
        end else if GameSet_c < 380 then begin
            if  (ADI.DI[0].CheckBtn(bA))
            or ((ADI.DI[1].CheckBtn(bA)) and (CPU_f = True)) then begin//対ＣＰＵじゃないときは２Ｐでも可
                GameSet_c := 0;
                SEStop;
            end;
        end;
        if GameSet_c = 0 then begin
            //遠征試合＆勝ち
            {
            if (Ensei_f = True) and (P[1].Dead_c >= 3)
            and ((Stage < 8) or ((Stage = 8) and (NODead_f = True))) then begin
                //データ初期化
                for i := 0 to 1 do begin
                    StBer_c[i] := 0;
                    P[i] := InitP;
                    //おしっぱにするとそのままＶＳも飛ばしてしまうので
                    //P[i].KeyP2 := True;
                end;
                //データ初期化
                for i := 0 to 5 do begin
                    C[i] := InitC;
                end;
                inc(Stage);
                //ボールの色
                if Stage = 2 then begin
                    Ball.BColor := BCol2;
                end else begin
                    Ball.BColor := BCol1;
                end;
                P[1].TeamNo := Stage;
                GameMode  := VS;
                VS_c := 0;

                BGMStop;

                SE(17);
            end else begin
                DataReset;
                GameMode := NAMENNAYO;
            end;
            }
            //無理矢理負け
                DataReset;
                GameMode := NAMENNAYO;
        end else begin
            //DBMotionType;
            //DBMove;
            //DBAction;
            DBBallAction;
            //DBBlt;
        end;

        PauseAble_f := False;
        
    //試合中
    end else begin
        DBKeyInput;
        DBMotionType;
        DBMove;
        DBAction;
        DBBallAction;
        DBJudge;
        //DBBlt;

        PauseAble_f := True;
    end;
    
end;

procedure TForm1.LoopDBDraw;
begin

    //スタート
    If Ready_c > 0 then begin

        DBBlt;

    //勝ち＆負け
    end else If GameSet_c > 0 then begin

        if GameSet_c = 0 then begin

        end else begin

            DBBlt;
        end;

    //試合中
    end else begin

        DBBlt;

    end;

end;

//画像の描画
procedure DDDraw(xxx:integer;yyy:integer;sr:TRect;ddsf:TDDDDSurface;Mask_f:boolean);
begin

    {
    if FPSSkip_c = 0 then begin
        sr := Rect(sr.Left*Mag,sr.Top*Mag,sr.Right*Mag,sr.Bottom*Mag);
        dr := Bounds(xxx*Mag,yyy*Mag,sr.Right-sr.Left,sr.Bottom-sr.Top);
        if Mask_f = True then begin
            ddsf.Put(dr,sr,DDBLT_WAIT or DDBLT_KEYSRC,fx)
        end else begin
            ddsf.Put(dr,sr,DDBLT_WAIT,fx)
        end;
    end;
    }
end;
//画面の色変え
procedure ColorChange(ccc:TColor);
begin
    //暗転
    Form1.DDDD1.BackBuffer.FillRect(Bounds(0,0,320*Mag,240*Mag),Form1.DDDD1.BackBuffer.ColorMatch(ccc));
end;

//文字描画
procedure StrDraw(xxx:integer;yyy:integer;DStr:Widestring);
var
    //i:integer;
    i:integer;
    i2:integer;
    SrcRect:TRect;
    //Draw_f :Boolean;
begin

    for i := 0 to 31 do begin//最長１６文字

        if DStr[i+1] = Moji[221] then break;//end

        if DStr[i+1] <> Moji[220] then begin//スペース
            for i2 := 0 to 219 do begin//もじ
                if DStr[i+1] = Moji[i2] then begin
                    SrcRect := Bounds(8*(i2 mod 20),8*(i2 div 20),8,8);
                    //DDDraw(xxx+(8*i),yyy,SrcRect,ddsfFont,True);
                    AL.DrawTexDBLT(AT.Fonttx,SrcRect,xxx+(8*i),yyy,DEFPRI);

                    //濁音
                    if ((i2 >= 91) and (i2 <= 110))
                    or ((i2 >= 171) and (i2 <= 190)) then begin
                        SrcRect := Bounds(0,88,8,8);
                        //DDDraw(xxx+(8*i),yyy-8,SrcRect,ddsfFont,True);
                        AL.DrawTexDBLT(AT.Fonttx,SrcRect,xxx+(8*i),yyy-8,DEFPRI);

                    //半濁音
                    end else if ((i2 >= 111) and (i2 <= 115))
                    or ((i2 >= 191) and (i2 <= 195)) then begin
                        SrcRect := Bounds(8,88,8,8);
                        //DDDraw(xxx+(8*i),yyy-8,SrcRect,ddsfFont,True);
                        AL.DrawTexDBLT(AT.Fonttx,SrcRect,xxx+(8*i),yyy-8,DEFPRI);

                    end;
                    break;
                end;
            end;
        end;
    end;
end;
//顔描画
procedure FaceDraw(i:integer;i2:integer;xxx:integer;yyy:integer;ftype:integer);
var
    //描画用
    sr :TRect;
    dr :TRect;
    //顔転送元用
    F1:integer;
    F2:integer;
    //顔の種類ごとの補正
    RevX :integer;
    RevY :integer;
    Mir_f:MirrorFlag;
    //向きによる転送元の補正
    procedure srSet(tL,tW:integer);
    begin
        sr.Left := tL;
        sr.Right:= tL+tW;
    end;
begin
    if FPSSkip_c = 0 then begin
        RevX:= 16;
        RevY:= 0;
        if (ftype >= 1) and (ftype <= 6) then begin

            F1 := (60 *(P[i2].DBC[i].Face div 10));
            F2 := (10 *(P[i2].DBC[i].Face mod 10));

            sr.Top := F1+F2;
            sr.Bottom := sr.Top+10;

            case ftype of
                1:begin//正面
                    srSet(0,16);
                end;
                2:begin//横
                    srSet(16,16);
                    //屈み
                    if (P[i2].DBC[i].mNo = 309) then begin

                        sr.Bottom := sr.Top+9;

                    end else if (P[i2].DBC[i].mNo = 310) then begin

                        sr.Bottom := sr.Top+8;

                    end;

                end;
                3:begin//倒れ、飲み
                    RevX:= 0;
                    RevY:= 16;
                    srSet(32,8);
                    if P[i2].DBC[i].Muki = Hidari then begin
                        RevX := 48 - RevX - (sr.Right-sr.Left);
                    end;
                end;
                4:begin//勝ち
                    srSet(56,16);
                end;
                5:begin//後ろ
                    srSet(40,16);
                end;
                6:begin//後ろ
                    srSet(72,16);
                end;
            end;
            if P[i2].DBC[i].Muki = Hidari then begin
                //RevX := 48 - RevX - (sr.Right-sr.Left);
                Mir_f := mirLR;
            end else begin
                Mir_f := mirNone;
            end;


            sr := Rect(sr.Left,sr.Top,sr.Right,sr.Bottom);
            dr := Bounds((xxx+RevX),(yyy+RevY),sr.Right-sr.Left,sr.Bottom-sr.Top);
            //ddsfDBFace.Put(dr,sr,DDBLT_WAIT or DDBLT_KEYSRC,fx);
            AL.DrawTexDBLT(AT.DBFacetx,sr,(xxx+RevX),(yyy+RevY),DEFPRI+9,Mir_f);
            //AL.DrawTexLT(AT.DBFacetx,sr.Left,sr.Top,sr.Right-sr.Left,sr.Bottom-sr.Top,(xxx+RevX),(yyy+RevY),DEFPRI+9);

            //屈み
            if ((P[i2].DBC[i].mNo = 309) or (P[i2].DBC[i].mNo = 310))
            and ((P[i2].DBC[i].Name = 'むはまど') or (P[i2].DBC[i].Name = 'ひろし２')) then begin
                sr.Top := F1+F2;
                sr.Bottom := sr.Top+10;
                srSet(16,16);
                if P[i2].DBC[i].Muki = Migi then begin
                    sr.Left := sr.Left+8;
                end else begin
                    sr.Right := sr.Right-8;
                end;
                RevX:= 17+8;
                RevY:= 0;
                if P[i2].DBC[i].Muki = Hidari then begin
                    RevX := 48 - RevX - (sr.Right-sr.Left);
                end;
                sr := Rect(sr.Left,sr.Top,sr.Right,sr.Bottom);
                dr := Bounds((xxx+RevX)*Mag,(yyy+RevY)*Mag,sr.Right-sr.Left,sr.Bottom-sr.Top);

                //ddsfDBFace.Put(dr,sr,DDBLT_WAIT or DDBLT_KEYSRC,fx);
                AL.DrawTexDBLT(AT.DBFacetx,sr,(xxx+RevX),(yyy+RevY),DEFPRI+9);
            end;
        end;
    end;
end;

//ＳＥをならす
procedure SE(SENo:integer);
begin
    OC.SEPlay(SENo);
    {
    if Form1.DXSound.Initialized = False then Exit;
    dsSE[SENo].Stop;
    dsSE[SENo].Position := 0;
    dsSE[SENo].Play(False);
    }
end;

//ＢＧＭを再生する
procedure BGM(BGMNo:integer);
begin
    OC.JglLoopPlay(BGMNo);
    //OC.LoadBGMNo(BGMNo);
    //OC.BGMPlay(True);
    {
    if Form1.DXSound.Initialized = False then Exit;
    dsBGM[BGMNo].Stop;
    dsBGM[BGMNo].Position := 0;
    dsBGM[BGMNo].Play(True);
    }
end;

//ＢＧＭ一時停止（ポーズ時）
procedure BGMStopSt(BGMNo:integer);
begin
    {
    if Form1.DXSound.Initialized = False then Exit;
    dsBGM[BGMNo].Stop;
    }
end;

//ＢＧＭ一時停止解除（ポーズ時）
procedure BGMPlaySt(BGMNo:integer);
begin
    {
    if Form1.DXSound.Initialized = False then Exit;
    dsBGM[BGMNo].Play(True);
    }
end;

//ＢＧＭをならす
procedure SYSBGM(SYSNo:integer);
var
    i:integer;
begin
    //OC.LoadBGMNo(SYSNo);
    //OC.BGMPlay(True);
    OC.JglLoopPlay(SYSNo);
    {
    if Form1.DXSound.Initialized = False then Exit;
    for i := 0 to SYSNum do begin
        dsSYS[SYSNo].Stop;
    end;
    dsSYS[SYSNo].Position := 0;
    dsSYS[SYSNo].Play(True);
    }
end;

//ＢＧＭストップ
procedure BGMStop;
var
    i:integer;
begin
    OC.BGMStop;
    OC.JglStop;
    {
    for i := 0 to SYSNum do begin
        dsSYS[i].Stop;
    end;
    for i := 0 to BGMNum do begin
        dsBGM[i].Stop;
    end;
    }
end;

//ＳＥストップ
procedure SEStop;
var
    i:integer;
begin
    OC.SEStop;
    {
    for i := 0 to SENum do begin
        dsSE[i].Stop;
    end;
    }
end;

//ＳＥストップ（個別）
procedure SEStop2(SENo:integer);
begin
    OC.SEStop(SENo);
    {
    dsSE[SENo].Stop;
    }
end;

//パーセント//****************************************************************************//
function Per100(i:integer):boolean;
begin
    if Random(100) < i then Result := True
    else Result := False;
end;

//難易度によるパーセント//****************************************************************************//
function LvPer100(i:integer):boolean;
begin
    //やさしい
    If GameLv = 0 then begin
        if Random(200) < i then Result := True
        else Result := False;
    //ふつう
    end else If GameLv = 1 then begin
        if Random(150) < i then Result := True
        else Result := False;
    //むずい
    end else begin
        if Random(100) < i then Result := True
        else Result := False;
    end;
end;

end.


