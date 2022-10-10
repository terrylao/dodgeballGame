unit DBClass;

interface

uses
    Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
    Dialogs,  MMsystem, IniFiles, StrUtils,
    Math,  Sockets,VarUnit,ExtCtrls,NkMemIniFile;

const
    TEAMNUM = 1;
    COURTNUM = 9;
    INITDINUM = 1024;
type
//合成方法
BLENDMODE = (
  BM_NORMAL,      //通常転送
  BM_ADD,         //加色
  BM_MODULATE,    //乗算
  BM_SUB,         //減算
  BM_FLASH,       //通常転送だがColorを加算(Voodoo系非対応)
  BM_NOT,         //反転
  BM_SUBADD,      //減算してから加算
  BM_DIV          //GIMPではDivide (Dodge)
);
    TALTexture=TBITMAP;
    MirrorFlag=boolean;
    RollFlag=boolean;
    TGlobalDB = class//(TGlobal)
      public
        //クラスポインタ  class pointer
        //ADI :TADIDB;
        //procedure CfgBtn;
        i:integer;
    end;

    //DB用入力関係  input relation
    TDIDB = class//(TGenDI)
    protected
    public
        constructor Create({tDIDEX:TDDIDEX;}tPNo:integer;tDT:integer);
        procedure Scan(WrtBuf_f:boolean);//override;
        function CheckJump: boolean;
        function CheckJump2: boolean;
    end;

    TAlpha32DB = class
    private
        Glb:TGlobalDB;
        CamX,CamY:integer;
    protected
        procedure DrawTexDBBGLT(src: TALTexture; sx1, sy1, sw, sh, dx1, dy1,
          Pri: Integer; alp: byte; col: DWORD; BM: BLENDMODE; Mirror_f: MirrorFlag;
          Roll_f: RollFlag);

    public
        constructor Create({tQD: TDDDD; tPC: TProcCounter;}UseDDraw_f:boolean; TrueColTex_f: boolean; tGlb: TGlobalDB; tMag,
          count: Integer);
        procedure SetCam(tCX, tCY: integer);

        //単形テクスチャ転送（拡大縮小回転無し）
        procedure DrawTexDB(src: TALTexture; sx1, sy1, sw, sh, dx1, dy1, Pri: Integer;
                              alp: byte; col: DWORD; BM: BLENDMODE;Mirror_f :MirrorFlag;
                              Roll_f:RollFlag);

        //単形テクスチャ転送（拡大縮小回転無し）
        procedure DrawTexDBLT(src: TALTexture; sr:TRect; dx1, dy1, Pri: Integer;Mirror_f: MirrorFlag{ = mirNone});

        {
        //単形テクスチャ転送（拡大縮小回転無し）
        procedure DrawTexDBLT(src: TALTexture; sx1, sy1, sw, sh, dx1, dy1, Pri: Integer;
                              alp: byte; col: DWORD; BM: BLENDMODE;Mirror_f :MirrorFlag;
                              Roll_f:RollFlag);overload;
        }

    end;




    TADIDB = class//(TGenADI)
    private

    public
        SlotNo:integer;
        Glb:TGlobalDB;//ポインタ
        //RpSt:ReplayState;
        CPUNUM:integer;//CPU人数0~4
        SCANNUM:integer;//DI[SCANNUM] までScan -1(Scanしない)~3

        DI:array [0..INITDINUM] of TDIDB;

        constructor Create({tDIDEX:TDDIDEX;}tGlb:TGlobalDB;tFScr_f:boolean); // コンストラクタ
        destructor Destroy;override;
        procedure Init(msc_f:boolean);
        procedure Scan(WrtBuf_f:boolean);//override;
        function LoadReplay:boolean;
        procedure SaveReplay(AutoSave_f:boolean);
        procedure StopReplay;
        procedure EndReplay;
        function CheckAnyBtn: boolean;
        //function CheckBtn(tBtn: BtnType): boolean;
        procedure SetCPUNUM(tCPUNUM:integer);
    end;

    //テクスチャ管理統括クラス
    TAllTx = class(TObject)
    private
        //クラスポインタ
        AL     :TAlpha32DB;
        Glb    :TGlobalDB;
        //procedure CheckJpgPng(MAXNUM:integer;BmpPath:string;pInt:PInteger;tx:array of TALTexture);
    public

        OPtx,
        Endingtx,
        MSLtx,
        PSLtx,
        TSLtx,
        HDCtx,
        CSLtx,
        VStx,
        Fonttx,
        DBItemtx,
        DBNametx,
        DBFacetx,
        DBEtctx,
        DBEtc2tx
        :TALTexture;

        //DBCourt: array [0..COURTNUM] of TALTexture;
        DBCourt: TALTexture;
        DBBody : array [0..TEAMNUM] of TALTexture;
        DBBodyB: array [0..TEAMNUM] of TALTexture;

        constructor Create(tAL:TAlpha32DB;tGlb:TGlobalDB);  // コンストラクタ
        destructor Destroy; override;
        procedure LoadBtl(P0No,P1No:integer);
        procedure LoadTx;
    end;



    CstDBMove = record//環境変数(定数)
        DSBX,
        DSSR,
        DSZRATIO,
        DSFRIC,
        WKBX,
        WKBZ,
        WKSR
        :integer;
    end;

    CstDBJump = record//環境変数(定数)
        PACAJPTIME
        :integer;
    end;
    CstDBBall = record//環境変数(定数)
        BWGRV,
        PAGRV,
        PASPD,
        STSPD,
        STSPDnat, //ナッツ
        STSPDbun, //分裂
        STSPDina, //稲妻
        STSPDmoz, //百舌落とし
        STSPDass, //圧縮
        STSPDkas, //加速
        STSPDbuy, //ぶよぶよ
        STSPDhoe, //ほえほえ

        STSPDkan, //貫通
        STSPDsun, //スネーク
        STSPDsuk, //スクリュー
        STSPDkak, //かっくん
        STSPDobu, //おぶおぶ
        STSPDapp, //アッパー
        STSPDwaa, //ワープ
        STSPDbuu, //ブーメラン
        STSPDenn,  //円輪
        STSPDkasRATE,//加速率
        STSPDkasDOWNSP,//加速下降速度
        STSPDmozMOVESP,//移動速度
        STSPDmozDOWNSP//下降速度
        :integer;
    end;

    CstDBCa = record//環境変数(定数)
        CASTTIME,
        CABF,
        CASF
        :integer;
    end;
    CstDBSt = record//環境変数(定数)
        DSSSTEP,
        DNSSTEP,
        JNSY,
        JNSY2,
        DJSSY,
        DJSSY2,
        DJNSY,
        DJNSY2
        :integer;
    end;
    CstDBCPU = record//環境変数(定数)
        THINKTIME,
        ATCPARATIO,
        ATCPAIRATIO,
        ATCJPRATIO,
        ATCJS1RATIO,
        ATCJS2RATIO,
        ATCJS3RATIO,
        DEFCARATIO,
        DEFDGRATIO,
        DEFJPRATIO
        :integer;
    end;

    CstDBETC = record//環境変数(定数)
        DOWNTIME,
        HPBER
        :integer;
    end;

    //定数管理クラス
    TGlbConst= class(TObject)
    private
    protected
        CommentRead_f:boolean;
        NKIni:TNkMemIniFile;
    public
        DBMOV:CstDBMove;
        DBJP:CstDBJump;
        DBB:CstDBBall;

        DBCA:CstDBCa;
        DBST:CstDBSt;
        DBCPU:CstDBCPU;
        DBETC:CstDBETC;

        constructor Create;
        procedure IOIni(Load_f:boolean);
        destructor Destroy;override;
    end;

var
    AL      :TAlpha32DB;
    AT      :TAllTx;
    ADI     :TADIDB;
    Glb     :TGlobalDB;
    //OC      :TOggDataCtrl;
    GC      :TGlbConst;
const
    DEFPRI = 100;

implementation


constructor TDIDB.Create(tDIDEX:TDDIDEX;tPNo:integer;tDT:integer);
begin
    inherited Create(tDIDEX,tPNo);
    DHTIME := tDT;
end;
//スキャン
procedure TDIDB.Scan(WrtBuf_f:boolean);
begin
  inherited;
  DHKey := DHit();
end;
//ジャンプチェック
function TDIDB.CheckJump: boolean;
begin
    if (CheckBtn2(bA) and CheckBtn(bB))
    or (CheckBtn2(bB) and CheckBtn(bA)) then begin
    //or CheckBtn(bC) then begin
        Result := True;
    end else begin
        Result := False;
    end;
end;
//ジャンプチェック
function TDIDB.CheckJump2: boolean;
begin
    if (CheckBtn2(bA) and CheckBtn2(bB)) then begin
    //or CheckBtn2(bC) then begin
        Result := True;
    end else begin
        Result := False;
    end;
end;

{ TADIDB }
//生成
constructor TADIDB.Create({tDIDEX: TDDIDEX;tGlb:TGlobalDB;} tFScr_f: boolean);
var
    i:integer;
begin
    inherited Create(tDIDEX,tFScr_f);
    //Glb := tGlb;
    SlotNo := 0;
    SetCPUNUM(1);
    //SetCPUNUM(0);
    for i := 0 to INITDINUM do DI[i] := TDIDB.Create(tDIDEX,i,DEFDHTIME);
end;
procedure TADIDB.Init(msc_f:boolean);
var
    i:integer;
begin
    if msc_f then begin
        RpSt := rpsNone;
    end;
    for i := 0 to INITDINUM do DI[i].Init(msc_f);
end;
//全員Scan
procedure TADIDB.Scan(WrtBuf_f:boolean);
var
    i:Integer;
begin
    //マウス状態
    DI[0].MScan(MSt,FScr_f);
    //リプレイ中

    if RpSt = rpsLoad then begin
        for i := 0 to SCANNUM do DI[i].Scan(WrtBuf_f);
        //リプレイ終了を受け取る
        if DI[0].RpSt = rpsEnd then RpSt := rpsEnd;
    end else begin
        for i := 0 to SCANNUM do DI[i].Scan(WrtBuf_f);
    end;

end;

procedure TADIDB.SetCPUNUM(tCPUNUM: integer);
begin
    CPUNUM := Between(tCPUNUM,0,INITDINUM+1);
    SCANNUM := INITDINUM - CPUNUM;
end;

//誰かがxボタンを押したとき
function TADIDB.CheckBtn(tBtn: BtnType): boolean;
var
    i:integer;
begin
    Result := False;

    for i := 0 to SCANNUM do begin
        if (DI[i].Key and BITBTNMASK and BITBTN[Ord(tBtn)]) <> BITEMP then begin
            Result := True;
            Exit;
        end;
    end;
end;
//誰かがボタンを押したとき
function TADIDB.CheckAnyBtn: boolean;
var
    i:integer;
begin
    Result := False;
    for i := 0 to SCANNUM do begin
        if (DI[i].Key and BITBTNMASK) <> BITEMP then begin
            Result := True;
            Exit;
        end;
    end;
end;

//破棄（リプレイ保存
destructor TADIDB.Destroy;
var
    i:Integer;
begin
    If RpSt <> rpsLoad then SaveReplay(True);

    for i := 0 to INITDINUM do FreeAndNil(DI[i]);

    inherited;
end;

//リプレイ読込
function TADIDB.LoadReplay:boolean;
var
    i:integer;
    RepName:&string;
    LoadRep:TMemoryStream;
    SeedStm:TMemoryStream;
begin

    RepName := REPDIR +REPFILEBASE +inttostr(SlotNo) +REPFILEEXT;
    //リプレイの読込
    if FileExists(RepName) then begin
        RpSt := rpsLoad;
        LoadRep := TMemoryStream.Create;
        LoadRep.LoadFromFile(RepName);

        SeedStm := ExtractFromQDAStream(LoadRep,REPRNDSEED);
        SeedStm.Read(RandSeed,SizeOf(RandSeed));
        Glb.RandSeed := RandSeed;

        for i := 0 to INITDINUM do begin
            LoadRep.Position := 0;
            DI[i].LoadReplay(LoadRep);
        end;
        FreeAndNil(LoadRep);
        FreeAndNil(SeedStm);
        Result :=True;
    end else begin
        Result := False;
    end;
end;

procedure TADIDB.SaveReplay(AutoSave_f:boolean);
var
    i:Integer;
    RepmsList:TList;
    RepIDList:TStringList;
    SeedStm:TMemoryStream;
    fn:&string;
begin

    Exit;
    
    //リプレイＱＤＡ保存
    RepmsList := TList.Create;
    RepIDList := TStringList.Create;
    SeedStm := TMemoryStream.Create;
    SeedStm.Write(Glb.RandSeed,SizeOf(Glb.RandSeed));

    RepmsList.Add(SeedStm);
    RepIDList.Add(REPRNDSEED);
    for i := 0 to INITDINUM do begin
        RepmsList.Add(DI[i].msRep);
        RepIDList.Add(REPID+inttostr(i));
    end;

    if AutoSave_f then begin
        fn := FormatDateTime('yymmdd_hhmmss',Now)+REPFILEEXT;
    end else begin
        fn := inttostr(SlotNo)+REPFILEEXT;
    end;

    CreateQDAFile(REPDIR + REPFILEBASE + fn ,RepmsList,RepIDList,True);
    //CreateQDAFile(REPDIR+REPFILEBASE,RepmsList,RepIDList,False);
    FreeandNil(RepmsList);
    FreeandNil(RepIDList);
    FreeAndNil(SeedStm);
end;
procedure TADIDB.StopReplay;
var
    i:integer;
begin
    RpSt := rpsNone;
    for i := 0 to INITDINUM do DI[i].StopReplay;
end;
procedure TADIDB.EndReplay;
var
    i:integer;
begin
    RpSt := rpsEnd;
    for i := 0 to INITDINUM do DI[i].EndReplay;
end;

{ TAlpha32DB }
constructor TAlpha32DB.Create(tQD: TDDDD;tPC:TProcCounter;UseDDraw_f:boolean; TrueColTex_f: boolean; tGlb: TGlobalDB; tMag,
  count: Integer);
begin
    inherited Create(tQD,tPC,UseDDraw_f,TrueColTex_f,tMag,count);
    Glb := tGlb;
end;
procedure TAlpha32DB.DrawTexDB(src: TALTexture; sx1, sy1, sw, sh, dx1, dy1, Pri: Integer;
  alp: byte; col: DWORD; BM: BLENDMODE;Mirror_f :MirrorFlag;Roll_f:RollFlag);
begin
    DrawTexEx(src,sx1,sy1,sw,sh,dx1-CamX,dy1+CamY,Pri,alp,col,BM,Mirror_f,False,1.0,1.0,Roll_f,0.0,nil);
end;

procedure TAlpha32DB.DrawTexDBLT(src: TALTexture; sr: TRect; dx1, dy1,
  Pri: Integer;Mirror_f: MirrorFlag = mirNone);
begin
    DrawTexLTEx(src,sr.Left,sr.Top,(sr.Right-sr.Left),(sr.Bottom-sr.Top),
                dx1-CamX,dy1+CamY,Pri,$FF,$FFFFFF,BM_NORMAL,Mirror_f);
end;
{
procedure TAlpha32DB.DrawTexDBLT(src: TALTexture; sx1, sy1, sw, sh, dx1, dy1,
  Pri: Integer; alp: byte; col: DWORD; BM: BLENDMODE; Mirror_f: MirrorFlag;
  Roll_f: RollFlag);
begin
    DrawTexLTEx(src,sx1,sy1,sw,sh,dx1-CamX,dy1+CamY,Pri,alp,col,BM,Mirror_f,False,1.0,1.0,Roll_f,0.0,nil);
end;
}
{
  src 源紋理
sx1,sy1.... 源坐標。
sx1,sy1 是左上坐標
sx2,sy2 是右下坐標
dx1,dy1... 目標中心坐標。
sw 橫向膨脹比（1.0 倍率相同）
sh 縱向膨脹/收縮率（與1.0大小相同）
r 旋轉角度（1.0 時 360 度）
col 顏色 (ARGB) 32Bit
BM合成法
Pri Draw 優先順序。 數字越大，顯示得越近。

Mirror_f 反轉
Roll_f 旋轉
}
procedure TAlpha32DB.DrawTexDBBGLT(src: TALTexture; sx1, sy1, sw, sh, dx1, dy1,
  Pri: Integer; alp: byte; col: DWORD; BM: BLENDMODE; Mirror_f: MirrorFlag;
  Roll_f: RollFlag);
begin
    DrawTexLTEx(src,sx1,sy1,sw,sh,dx1-CamX,dy1+CamY,Pri,alp,col,BM,Mirror_f,False,1.0,1.0,Roll_f,0.0,nil);
end;

procedure TAlpha32DB.SetCam(tCX,tCY: integer);
begin
    CamX := tCX;
    CamY := tCY;
end;


constructor TAllTx.Create(tAL: TAlpha32DB; tGlb: TGlobalDB);
begin
    AL := tAL;
    Glb := tGlb;

    //テクスチャ読込
    LoadTx;
end;

destructor TAllTx.Destroy;
var
    i:integer;
begin

    //for i := COURTNUM downto 0 do begin
        AL.FreeTexture(DBCourt);
    //end;
    for i := TEAMNUM downto 0 do begin
        AL.FreeTexture(DBBodyB[i]);
        AL.FreeTexture(DBBody[i]);
    end;
    //AL.FreeTexture(DBEtc2tx);
    AL.FreeTexture(DBEtctx);
    AL.FreeTexture(DBFacetx);
    AL.FreeTexture(DBNametx);
    AL.FreeTexture(DBItemtx);
    AL.FreeTexture(Fonttx);
    AL.FreeTexture(VStx);
    //AL.FreeTexture(CSLtx);
    //AL.FreeTexture(HDCtx);
    //AL.FreeTexture(TSLtx);
    AL.FreeTexture(PSLtx);
    AL.FreeTexture(MSLtx);
    AL.FreeTexture(Endingtx);
    AL.FreeTexture(OPtx);
    
    inherited;
end;


procedure TAllTx.LoadTx;
var
    pal:Integer;
    i:integer;
begin

    
    //テクスチャ読込
    //AL.LoadTextureEx(OPtx,'bmp\op.png',False,False,False,ckNone,NGNUM);
    //AL.LoadTextureEx(Endingtx,'bmp\ending.png',False,False,False,ckNone,NGNUM);
    AL.LoadTextureEx(MSLtx,'bmp\msl.png',False,False,False,ckNone,NGNUM);
    AL.LoadTextureEx(PSLtx,'bmp\psl.png',False,False,False,ckNone,NGNUM);
    //AL.LoadTextureEx(TSLtx,'bmp\tsl.png',False,False,ckNone,NGNUM);
    //AL.LoadTextureEx(HDCtx,'bmp\hdc.png',False,False,ckNone,NGNUM);
    //AL.LoadTextureEx(CSLtx,'bmp\csl.png',False,False,ckNone,NGNUM);
    AL.LoadTextureEx(VStx,'bmp\vs.png',False,False,False,ckNone,NGNUM);
    AL.LoadTexture(Fonttx,'bmp\font.png');
    AL.LoadTextureLR(DBItemtx,'bmp\dbitem.png');
    AL.LoadTexture(DBNametx,'bmp\dbname.png');
    AL.LoadTextureLR(DBFacetx,'bmp\dbface.png');
    AL.LoadTextureLR(DBEtctx,'bmp\dbetc.png');
    //AL.LoadTexture(DBEtc2tx,'bmp\dbetc2.png');
    for i := 0 to TEAMNUM do begin
        pal := AL.PalLoad('bmp\body'+inttostr(i)+'.pal');
        AL.LoadTextureEx(DBBody[i],'bmp\dbbody.png',False,True,False,ckPalNo0,pal);
        AL.LoadTextureEx(DBBodyB[i],'bmp\dbbodyb.png',False,True,False,ckPalNo0,pal);
    end;
    //for i := 0 to COURTNUM do begin
        AL.LoadTextureEx(DBCourt,'bmp\dbcourt.png',False,False,False,ckNone,NGNUM);
    ///end;
end;


procedure TAllTx.LoadBtl(P0No,P1No:integer);
begin


end;

{ TGlobalDB }

procedure TGlobalDB.CfgBtn;
var
    i:integer;
begin
    for i := 0 to INITDINUM do begin
        //本当はGlb.DXINI.JSBtn[i]
        ADI.DI[i].SettingBtn(Glb.DXINI.JSBtn[0][0],
                             Glb.DXINI.JSBtn[0][1],
                             Glb.DXINI.JSBtn[0][2],
                             Glb.DXINI.JSBtn[0][3],
                             Glb.DXINI.JSBtn[0][4],
                             Glb.DXINI.JSBtn[0][5],
                             Glb.DXINI.JSBtn[0][6],
                             Glb.DXINI.JSBtn[0][7]
                             );
    end;
end;



{ TGlbConst }

constructor TGlbConst.Create;
begin
    CommentRead_f := False;

    IOIni(True);
end;


destructor TGlbConst.Destroy;
begin
    IOIni(False);
    NKIni.UpdateFile;
    
    NKIni.Free;
    inherited;
end;

procedure TGlbConst.IOIni(Load_f:boolean);
var
    NowSection:string;
    procedure SetSeciton(const Sec:string;const Comment:string);
    begin
        NowSection := Sec;
        if  (CommentRead_f = False) then begin
            NKIni.WriteSectionComment(NowSection,'◆ '+Comment+' ◆');
        end;
    end;
    procedure IO(var Dt:integer;const Ident: string;const Comment:string;Def:integer = 100);
    begin
        if Load_f then begin
            Dt := NKIni.ReadInteger(NowSection,Ident,Def);
        end else begin
            NKIni.WriteInteger(NowSection,Ident,Dt);
            if  (CommentRead_f = False)
            and (Comment <> '') then begin
                NKIni.WriteComment(NowSection,Ident,Comment);
            end;
        end;
    end;
begin

    NKIni.Free;
    NKIni := TNkMemIniFile.Create('data\db.ini');

    with DBMOV do begin
        SetSeciton('DBMOV','ドッジ移動用定数');
        IO(DSBX,'DSBX','基本Ds移動量',200);
        IO(DSSR,'DSSR','Dsステータス倍率',7);
        IO(DSZRATIO,'DSZRATIO','Z軸倍率%',25);
        IO(DSFRIC,'DSFRIC','Ds摩擦係数',3);

        IO(WKBX,'WKBX','基本WkX移動量',100);
        IO(WKBZ,'WKBZ','基本WkZ移動量',100);
        IO(WKSR,'WKSR','Wkステータス倍率',8);
    end;

    with DBJP do begin
        SetSeciton('DBJP','ドッジジャンプ用定数');
        IO(PACAJPTIME,'PACAJPTIME','ジャンプパスキャッチタイミング',15);
    end;

    with DBB do begin
        SetSeciton('DBB','ドッジボール用定数');
        IO(BWGRV,'BWGRV','重力（バウンド）',15);
        IO(PAGRV,'PAGRV','重力（パス）',10);
        IO(PASPD,'PASPD','パススピード',300);
        IO(STSPD,'STSPD','基本シュートスピード',32);
        IO(STSPDnat,'STSPDnat','ナッツスピード',20);
        IO(STSPDbun,'STSPDbun','分裂スピード',12);
        IO(STSPDina,'STSPDina','稲妻スピード',14);
        IO(STSPDmoz,'STSPDmoz','もずスピード',10);
        IO(STSPDass,'STSPDass','圧縮スピード',16);
        IO(STSPDkas,'STSPDkas','加速スピード',20);
        IO(STSPDbuy,'STSPDbuy','ぶよぶよスピード',12);
        IO(STSPDhoe,'STSPDhoe','ほえほえスピード',2);
        IO(STSPDkan,'STSPDkan','貫通スピード',16);
        IO(STSPDsun,'STSPDsun','スネークスピード',10);
        IO(STSPDsuk,'STSPDsuk','スクリュースピード',10);
        IO(STSPDkak,'STSPDkak','かっくんスピード',10);
        IO(STSPDobu,'STSPDobu','おぶおぶスピード',8);
        IO(STSPDapp,'STSPDapp','アッパースピード',14);
        IO(STSPDwaa,'STSPDwaa','ワープスピード',6);
        IO(STSPDbuu,'STSPDbuu','ブーメランスピード',16);
        IO(STSPDenn,'STSPDenn','円輪スピード',6);
        IO(STSPDkasRATE,'STSPDkasRATE','加速シュート加速度(分母)',60);
        IO(STSPDkasDOWNSP,'STSPDkasDOWNSP','加速シュート下降速度',300);
        IO(STSPDmozMOVESP,'STSPDmozMOVESP','もず落とし移動速度(分母)',8);
        IO(STSPDmozDOWNSP,'STSPDmozDOWNSP','もず落とし下降速度',1000);
    end;

    with DBCA do begin
        SetSeciton('DBCA','ドッジキャッチ用定数');
        IO(CASTTIME,'CASTTIME','入力からキャッチ開始までの時間',3);
        IO(CABF,'CAFLAME','キャッチ有効時間（基本値）',3);
        IO(CASF,'CAFLAME2','キャッチステータス倍率',100);
    end;

    with DBST do begin
        SetSeciton('DBST','ドッジシュート用定数');
        IO(DSSSTEP,'DSSSTEP','Ｄ必殺歩数',1);
        IO(DNSSTEP,'DNSSTEP','Ｄナイス歩数',1);
        IO(JNSY,'JNSY','ＪナイスＹ座標',1);
        IO(JNSY2,'JNSY2','Ｊナイス幅',1);
        IO(DJSSY,'DJSSY','ＤＪ必殺Ｙ座標',1);
        IO(DJSSY2,'DJSSY2','ＤＪ必殺幅',1);
        IO(DJNSY,'DJNSY','ＤＪナイスＹ座標',1);
        IO(DJNSY2,'DJNSY2','ＤＪナイス幅',1);
    end;

    with DBCPU do begin
        SetSeciton('DBCPU','ドッジＣＰＵ用定数');
        IO(THINKTIME,'THINKTIME','思考時間',10);
        IO(ATCPARATIO,'ATCPARATIO','攻撃時パス%',20);
        IO(ATCPAIRATIO,'ATCPAIRATIO','攻撃時上でパス判定なったとき内野パス%',20);
        IO(ATCJPRATIO,'ATCJSRATIO','攻撃時ジャンプシュート%',50);
        IO(ATCJS1RATIO,'ATCJS1RATIO','攻撃時ジャンプシュート必殺タイミング％',30);
        IO(ATCJS2RATIO,'ATCJS2RATIO','攻撃時ジャンプシュート早めタイミング％',30);
        IO(ATCJS3RATIO,'ATCJS3RATIO','攻撃時ジャンプシュート頂点タイミング％',30);
        IO(DEFCARATIO,'DEFCARATIO','守備時キャッチ%',20);
        IO(DEFDGRATIO,'DEFDGRATIO','守備時よけ%',20);
        IO(DEFJPRATIO,'DEFJPRATIO','守備時ジャンプよけ%',20);
    end;

    with DBETC do begin
        SetSeciton('DBETC','ドッジETC用定数');
        IO(DOWNTIME,'DOWNTIME','ダウン時間',120);
        IO(HPBER,'HPBER','体力バー１コ分ＨＰ(2～4)',2);
    end;

    //書き込み時、コメント付加
    if Load_f = False then CommentRead_f := True;
end;

end.
