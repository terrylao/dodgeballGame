unit DBUnit;//ドッジ試合中のコード  Code in a dodge match

interface
uses                                                                                                                     
    Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
    Dialogs,  MMsystem, IniFiles, StrUtils,
    Math,DBClass;
    //描画一式
    procedure DBBlt;
    //キー入力 Key input
    procedure DBKeyInput;
    //カーソルがついていないキャラのオート移動  Auto move characters without cursor
    procedure DBNPC(i:integer;i2:integer);
    //現在のキャラの状態  current character state
    procedure DBMotionType;
    //状態による動作 action by state
    procedure DBMove;
    //ジャンプ  jump
    procedure Jumping(i:integer;i2:integer);
    //ダメージ damage
    procedure Damage(i:integer;i2:integer);
    //シュートなどのアクション  Actions such as shooting
    procedure DBAction;
    //ボールの動き  ball movement
    procedure DBBallAction;
    //判定 judgement
    procedure DBJudge;

implementation

uses Main,CPUUnit,VarUnit,Types;

//**共通でつかうもの**  ** Commonly used items **

//スリップ時の変数初期化  Variable initialization during slip
procedure SetSLP(i:integer;i2:integer);
begin
    with P[i2].DBC[i] do begin
        Motion := SLP;
        Slip_f := Dash_f;
        Slip_f2:= None;
        Slip_c := 100;
        Slip_c2:= 1;
        Boost := 1;
        Dash_f := None;
        mNo_c := 0;
    end;
end;
//上下の向きによるグラフィックの補正  Correction of graphics by vertical orientation
procedure RevMuki2(i:integer;i2:integer);
begin
    with P[i2].DBC[i] do begin
        if Muki2 = Ue    then inc(mNo,100);
        if Muki2 = Shita then dec(mNo,100);
    end;
end;
//全員死亡時の処理
procedure AllDead();
begin
    BGMStop;
    GameSet_c := 500;
end;

//描画用//****************************************************************************//
procedure DBBlt;
const
    CharY = 15;
    SpinW = 100;
    CurMax = 20;
    tgMax = 6;
    SPFlash = 100;
    BunAni = 24;
    BunAni2 = BunAni div 6;
    CameraMove  = 150;
    HPDY = 8;
    HPBY = 8;
var
    i       :Integer;
    i2      :Integer;
    r2      : TRect;
    r2r     : TRect;
    r3      : TRect;
    r4      : TRect;
    r5      : TRect;
    rCS     : TRect;//キャラ影  character shadow
    rBS     : TRect;//球影
    rEgl    : TRect;//天使画像
    cX      :integer;
    cY      :integer;
    TempRevX:integer;
    bltX    :integer;
    bltY    :integer;
    bltDX    :integer;
    bltDY    :integer;
    RevMap  :integer;

    SortDt:array[0..12] of SortData;//12人＋ボール 12 players + ball
    TempSDt:SortData;
    j2:integer;
    j3:integer;
    j4:integer;
    j5:integer;
    BallRevX:integer;
    BallRevY:integer;
    PlayerNo:integer;
    CharNo:integer;
    HPBer :integer;
    Mir_f:MirrorFlag;
    procedure BallRevSet(rX:integer;rY:integer);
    begin
        BallRevX := BallRevX + rX;
        BallRevY := BallRevY + rY;
    end;
    procedure Flash(var tr:TRect);
    begin
        tr.top := tr.top - Ball.BColor;
        tr.Bottom := tr.Bottom - Ball.BColor;
    end;
    procedure r3Set();
    begin
        r3 := Bounds(48*cX,32*cY,48,32);
    end;
    //外人用
    procedure r3SetB(tL,tT,tW,tH:integer);
    begin
        r3 := Bounds(tL,tT,tW,tH);
    end;
    //外人用
    procedure r3SetC(tL,tT,tW,tH:integer);
    begin
        r3 := Bounds(tL,tT,tW,tH);
    end;
begin
    //影
    rCS := Bounds(144, 144, 16, 8);
    rBS := Bounds(144, 152, 16, 8);
    rEgl:= Bounds(128, 144, 16, 16);
    //画面スクロール用の何か
    {
    If Ball.X < 16000 Then begin
        r2.Left := 0;
    end else If Ball.X > ((432-160)*100) Then begin
        r2.Left := (432-320);
    end Else begin
        r2.Left := (Ball.X - 16000) div 100;
    end;
    }

    //カメラワーク
    if (GameSet_c = 0)and (Pause_f = 0) then begin
        if (Ball.Motion = BFree) or (Ball.Motion = BBound)
        or ((Ball.Motion = BHold)
        and (((Ball.HoldChar div 10 = 0)
        and (P[Ball.HoldChar div 10].DBC[Ball.HoldChar mod 10].Muki = Hidari))
        or  ((Ball.HoldChar div 10 = 1)
        and (P[Ball.HoldChar div 10].DBC[Ball.HoldChar mod 10].Muki = Migi)))) then begin
            if Camera >= Ball.X then begin
                Camera := (Camera - CameraMove);
                if Camera <= Ball.X then Camera := Ball.X;
            end else begin
                Camera := (Camera + CameraMove);
                if Camera >= Ball.X then Camera := Ball.X;
            end;
        end else begin
            if Ball.HoldChar div 10 = 0 then begin
                Camera := (Camera + CameraMove);
                if Camera >= Ball.X + 14000 then Camera := Ball.X + 14000;
            end else begin
                Camera := (Camera - CameraMove);
                if Camera <= Ball.X - 14000 then Camera := Ball.X - 14000;
            end;
        end;
    end;
    if (Camera div 100) < (160) then begin
        Camera := 16000;
        //r2.Left := 0;
    end else if (Camera div 100) > (432-160) then begin
        Camera := (432-160)*100;
        //r2.Left := (432-320);
    end else begin
        //r2.Left := (Camera - 16000) div 100;
    end;

    Camera := 16000;
    RevMap := -((Camera - 16000) div 100);

    //リング
    //AL.DrawTexLT(AT.DBCourt[Stage],-RevMap,0,320,192,0,48,DEFPRI);
    //AL.DrawTexLT(AT.DBCourt,-RevMap,0,320,192,0,48,DEFPRI);
    AL.DrawTexLT(AT.DBCourt,-RevMap,0,432,240,0,0,DEFPRI);


    for i := 0 to 2 do begin
        //カーソルキャラ
        if (P[0].PNo = i)
        and (P[0].DBC[i].Dead_f = False)
        and (P[0].DBC[i].Dam_f  = None)
        and (P[0].DBC[i].Groggy_c = 0) then begin
            //r2 := Bounds(80, 152, 8, 8);
            //DDDraw(104,12+(9*i),r2,AT.DBItemtx,True);

            AL.DrawTexLT(AT.DBItemtx,80, 152, 8, 8,104+WD,HPBY+(HPDY*i),DEFPRI+1);
        end;
        //名前
        CharNo := ((P[0].DBC[i].dNo div 10)*6) + (P[0].DBC[i].dNo mod 10);
        //r2 := Bounds((CharNo div 30)*40,(CharNo mod 30)*8,40,8);
        //DDDraw(,r2,,True);
        AL.DrawTexLT(AT.DBNametx,(CharNo div 30)*40,(CharNo mod 30)*8,40,8,112+WD,HPBY+(HPDY*i),DEFPRI+2);

        //ＨＰ
        if P[0].DBC[i].dHP > 64 then begin
            //r2 := Bounds(0,144,64,8);
            //DDDraw(40,12+(9*i),r2,AT.DBItemtx,False);
            AL.DrawTexLT(AT.DBItemtx,0,144,64,8,40+WD,12+(HPDY*i),DEFPRI+2);
            HPBer := (P[0].DBC[i].dHP -64 + GC.DBETC.HPBER-1) div GC.DBETC.HPBER;
            //r2 := Bounds(64,144,(HPBer * 4),8);
            //DDDraw(40+(64-(HPBer * 4)),12+(9*i),r2,AT.DBItemtx,False);
            AL.DrawTexLT(AT.DBItemtx,64,144,(HPBer * 4),8,40+(64-(HPBer * 4))+WD,HPBY+(HPDY*i),DEFPRI+3);
        end else begin
            HPBer := (P[0].DBC[i].dHP + GC.DBETC.HPBER-1) div GC.DBETC.HPBER;
            //r2 := Bounds(0,144,(HPBer * 4),8);
            //DDDraw(40+(64-(HPBer * 4)),12+(9*i),r2,AT.DBItemtx,False);
            AL.DrawTexLT(AT.DBItemtx,0,144,(HPBer * 4),8,40+(64-(HPBer * 4))+WD,HPBY+(HPDY*i),DEFPRI+3);
        end;

    end;
    for i := 0 to 2 do begin
        //カーソルキャラ
        if (P[1].PNo = i)
        and (P[1].DBC[i].Dead_f = False)
        and (P[1].DBC[i].Dam_f  = None)
        and (P[1].DBC[i].Groggy_c = 0) then begin
            If CPU_f = False then begin
                //r2 := Bounds(88, 152, 8, 8);
                AL.DrawTexLT(AT.DBItemtx,88, 152, 8, 8,208+WD,HPBY+(HPDY*i),DEFPRI+4);
            end else begin
                //r2 := Bounds(96, 152, 8, 8);
                AL.DrawTexLT(AT.DBItemtx,96, 152, 8, 8,208+WD,HPBY+(HPDY*i),DEFPRI+4);
            end;
            //DDDraw(208,12+(9*i),r2,AT.DBItem,True);
        end;
        //名前
        CharNo := ((P[1].DBC[i].dNo div 10)*6) + (P[1].DBC[i].dNo mod 10);
        //r2 := Bounds((CharNo div 30)*40,(CharNo mod 30)*8,40,8);
        //DDDraw(168,12+(9*i),r2,AT.DBName,True);
        AL.DrawTexLT(AT.DBNametx,(CharNo div 30)*40,(CharNo mod 30)*8,40,8,168+WD,HPBY+(HPDY*i),DEFPRI+5);

        //ＨＰ
        if P[1].DBC[i].dHP > 64 then begin
            //r2 := Bounds(0,144,64,8);
            //DDDraw(216,12+(9*i),r2,AT.DBItem,False);
            AL.DrawTexLT(AT.DBItemtx,0,144,64,8,216+WD,HPBY+(HPDY*i),DEFPRI+5);

            HPBer := (P[1].DBC[i].dHP -64 + GC.DBETC.HPBER-1) div GC.DBETC.HPBER;
            //r2 := Bounds(64,144,(HPBer * 4),8);
            //DDDraw(216,12+(9*i),r2,AT.DBItem,False);
            AL.DrawTexLT(AT.DBItemtx,64,144,(HPBer * 4),8,216+WD,HPBY+(HPDY*i),DEFPRI+5);
        end else begin
            HPBer := (P[1].DBC[i].dHP + GC.DBETC.HPBER-1) div GC.DBETC.HPBER;
            //r2 := Bounds(0,144,(HPBer * 4),8);
            //DDDraw(216,12+(9*i),r2,AT.DBItem,False);
            AL.DrawTexLT(AT.DBItemtx,0,144,(HPBer * 4),8,216+WD,HPBY+(HPDY*i),DEFPRI+5);
        end;

    end;

    //カーソルの点滅用カウンタ
    inc(Cur_c);
    if Cur_c > CurMax then begin
        Cur_c := 0;
    end;
    inc(tg_c);
    if tg_c > tgMax then begin
        tg_c := 0;
    end;

    for j3 := 0 to 11 do begin
        SortDt[j3].Dt1 := P[j3 div 6].DBC[j3 mod 6].Z;
        SortDt[j3].BaseNo := j3;
    end;
    //ボール
    SortDt[12].Dt1 := Ball.Z;
    SortDt[12].BaseNo := 12;
    for j2 := 0 to 11 do begin
        for j3 := 0 to 11 do begin
            if SortDt[j3].Dt1 < SortDt[j3+1].Dt1 then begin
                TempSDt := SortDt[j3];
                SortDt[j3] := SortDt[j3+1];
                SortDt[j3+1] := TempSDt;
            end;
        end;
    end;

    //⑤キャラの選択
    for j2 := 0 to 12 do begin

        j3 := (SortDt[j2].BaseNo);
        //ボール
        if (j3 = 12) and (Ball.Motion <> BHold) then begin
            //通常
            if Ball.SType = None then begin

                //影
                //DDDraw(((Ball.X div 100)-7+RevMap),((240-(Ball.Z div 100)-5)),rBS,AT.DBItem,True);
                {
                //影
                rCS := Bounds(144, 144, 16, 8);
                rBS := Bounds(144, 152, 16, 8);
                rEgl:= Bounds(128, 144, 16, 16);
                }
                AL.DrawTexLT(AT.DBItemtx,144, 152, 16, 8,((Ball.X div 100)-7+RevMap),((240-(Ball.Z div 100)-5)),DEFPRI+7);

                //ボール
                if Ball.Spin_c >= (SpinW * 8) then Ball.Spin_c := 0;
                if Ball.Spin_c < 0            then Ball.Spin_c := (SpinW * 8)-1;

                if Ball.Y > 9600 then begin
                    r4 := Bounds((Ball.Spin_c div SpinW)*16,32+Ball.BColor, 16, 16);
                end else if Ball.Y > 4800 then begin
                    r4 := Bounds((Ball.Spin_c div SpinW)*16,16+Ball.BColor, 16, 16);
                end else begin
                    r4 := Bounds((Ball.Spin_c div SpinW)*16,Ball.BColor, 16, 16);
                end;

                bltX := ((Ball.X div 100) - 7)+RevMap;
                bltY := ((240 - ((Ball.Z div 100)+15) - (Ball.Y div 100)));
                //DDDraw(bltX,bltY,r4,AT.DBItem,True);
                AL.DrawTexLT(AT.DBItemtx,r4.Left,r4.Top,16, 16,bltX,bltY,DEFPRI+9);
            end else begin

                if Ball.SType <> Swaa then begin
                    //影
                    //DDDraw(((Ball.X div 100)-7+RevMap),((240-(Ball.Z div 100)-5)),rBS,AT.DBItem,True);
                    AL.DrawTexLT(AT.DBItemtx,144, 152, 16, 8,((Ball.X div 100)-7+RevMap),((240-(Ball.Z div 100)-5)),DEFPRI+7);
                end;
                //ボール
                if Ball.Spin_c >= (SpinW * 8) then Ball.Spin_c := 0;
                if Ball.Spin_c < 0            then Ball.Spin_c := (SpinW * 8)-1;

                if Ball.Y > 9600 then begin
                    r4 := Bounds((Ball.Spin_c div SpinW)*16,32+Ball.BColor, 16, 16);
                end else if Ball.Y > 4800 then begin
                    r4 := Bounds((Ball.Spin_c div SpinW)*16,16+Ball.BColor, 16, 16);
                end else begin
                    r4 := Bounds((Ball.Spin_c div SpinW)*16,Ball.BColor, 16, 16);
                end;
                
                case Ball.SType of
                    //ナッツ
                    Snat:begin
                        If Ball.dX >= 0 then begin
                            r4 := Bounds(128, 0+Ball.BColor, 16, 16);
                        end else begin
                            r4 := Bounds(144, 0+Ball.BColor, 16, 16);
                        end;
                        //地上からのナッツ
                        if Ball.dY = 0 then r4 := Bounds(128, 16+Ball.BColor, 16, 16);
                        if Ball.Spin_c mod SPFlash < (SPFlash div 2) then begin
                            Flash(r4);
                        end;
                    end;
                    //分裂
                    Sbun:begin
                        if Ball.SP_c mod BunAni < BunAni2 * 1 then begin
                            if Ball.Spin_c mod SPFlash < (SPFlash div 2) then begin
                                Flash(r4);
                            end;
                        end else if (Ball.SP_c mod BunAni < BunAni2 * 2) then begin
                            r4 := Bounds(128, 32+Ball.BColor, 16, 16);
                        end else if (Ball.SP_c mod BunAni < BunAni2 * 3) then begin
                            r4 := Bounds(144, 16+Ball.BColor, 16, 16);
                            if Ball.Spin_c mod SPFlash < (SPFlash div 2) then begin
                                Flash(r4);
                            end;
                            //上下の二つ
                            bltX := ((Ball.X div 100) - 7)+RevMap;
                            bltY := ((240 - ((Ball.Z div 100)+15) - (Ball.Y div 100)));
                            //DDDraw(bltX,bltY-8,r4,AT.DBItem,True);
                            //DDDraw(bltX,bltY+8,r4,AT.DBItem,True);
                            AL.DrawTexLT(AT.DBItemtx,r4.Left,r4.Top, 16, 16,bltX,bltY-8,DEFPRI+9);
                            AL.DrawTexLT(AT.DBItemtx,r4.Left,r4.Top, 16, 16,bltX,bltY+8,DEFPRI+9);
                        end else if Ball.SP_c mod BunAni < BunAni2 * 4 then begin
                            r4 := Bounds(144, 16+Ball.BColor, 16, 16);
                            if Ball.Spin_c mod SPFlash < (SPFlash div 2) then begin
                                Flash(r4);
                            end;
                            //上下の二つ
                            bltX := ((Ball.X div 100) - 7)+RevMap;
                            bltY := ((240 - ((Ball.Z div 100)+15) - (Ball.Y div 100)));
                            AL.DrawTexLT(AT.DBItemtx,r4.Left,r4.Top, 16, 16,bltX,bltY-11,DEFPRI+9);
                            AL.DrawTexLT(AT.DBItemtx,r4.Left,r4.Top, 16, 16,bltX,bltY+11,DEFPRI+9);
                        end else if Ball.SP_c mod BunAni < BunAni2 * 5 then begin
                            r4 := Bounds(144, 16+Ball.BColor, 16, 16);
                            if Ball.Spin_c mod SPFlash < (SPFlash div 2) then begin
                                Flash(r4);
                            end;
                            //上下の二つ
                            bltX := ((Ball.X div 100) - 7)+RevMap;
                            bltY := ((240 - ((Ball.Z div 100)+15) - (Ball.Y div 100)));
                            AL.DrawTexLT(AT.DBItemtx,r4.Left,r4.Top, 16, 16,bltX,bltY-8,DEFPRI+9);
                            AL.DrawTexLT(AT.DBItemtx,r4.Left,r4.Top, 16, 16,bltX,bltY+8,DEFPRI+9);
                        end else if Ball.SP_c mod BunAni < BunAni2 * 6 then begin
                            r4 := Bounds(128, 32+Ball.BColor, 16, 16);
                        end;
                        if (Ball.SP_c mod BunAni = BunAni2 * 6) then Ball.SP_c := 0;
                    end;
                    //圧縮
                    Sass:begin
                        If Ball.SP_c < 24 then begin
                            //最初ぶよぶよ
                            if Ball.Spin_c mod (SPFlash * 2) < (SPFlash) then begin
                                if Ball.Spin_c mod SPFlash < (SPFlash div 2) then begin
                                    Flash(r4);
                                end;
                            end else begin
                                r4 := Bounds(144, 16+Ball.BColor, 16, 16);
                                if Ball.Spin_c mod SPFlash < (SPFlash div 2) then begin
                                    Flash(r4);
                                end;
                            end;
                        end else begin
                            r4 := Bounds(144, 16+Ball.BColor, 16, 16);
                            if Ball.Spin_c mod SPFlash < (SPFlash div 2) then begin
                                Flash(r4);
                            end;
                        end;
                    end;
                    //ぶよぶよ
                    Sbuy:begin
                        if Ball.Spin_c mod (SPFlash * 2) < (SPFlash) then begin
                            r4 := Bounds((Ball.Spin_c div SpinW)*16,32+Ball.BColor, 16, 16);
                            if Ball.Spin_c mod SPFlash < (SPFlash div 2) then begin
                                Flash(r4);
                            end;
                        end else begin
                            r4 := Bounds(144, 16+Ball.BColor, 16, 16);
                            if Ball.Spin_c mod SPFlash < (SPFlash div 2) then begin
                                Flash(r4);
                            end;
                        end;
                    end;
                    //貫通
                    Skan:begin
                        r4 := Bounds(128, 16+Ball.BColor, 16, 16);
                        //空中からの貫通
                        if Ball.dY <> 0 then begin
                            If Ball.dX >= 0 then begin
                                r4 := Bounds(128, 0+Ball.BColor, 16, 16);
                            end else begin
                                r4 := Bounds(144, 0+Ball.BColor, 16, 16);
                            end;
                        end;
                        if Ball.Spin_c mod SPFlash < (SPFlash div 2) then begin
                            Flash(r4);
                        end;
                    end;
                    //ワープ
                    Swaa:begin

                        if (Ball.SP_c < 6)
                        or ((Ball.SP_c < 24)  and (Ball.SP_c mod 6 >= 3))
                        or ((Ball.SP_c >= 24) and (Ball.SP_c mod 12 <= 1)) then begin

                            //影
                            //DDDraw(((Ball.X div 100)-7+RevMap),((240-(Ball.Z div 100)-5)),rBS,AT.DBItem,True);
                            AL.DrawTexLT(AT.DBItemtx,144, 152, 16, 8,((Ball.X div 100)-7+RevMap),((240-(Ball.Z div 100)-5)),DEFPRI+7);

                            if (Ball.SP_c < 6) then begin
                                Flash(r4);
                            end;

                            bltX := ((Ball.X div 100) - 7)+RevMap;
                            bltY := ((240 - ((Ball.Z div 100)+15) - (Ball.Y div 100)));
                            //DDDraw(bltX,bltY,r4,AT.DBItem,True);
                            AL.DrawTexLT(AT.DBItemtx,r4.Left,r4.Top, 16, 16,bltX,bltY,DEFPRI+9);

                        end;
                    end;
                    //おぶおぶ
                    Sobu:begin
                        if Ball.Spin_c mod (SPFlash * 2) < (SPFlash) then begin
                            r4 := Bounds(128, Ball.BColor, 16, 16);
                            if Ball.Spin_c mod SPFlash < (SPFlash div 2) then begin
                                Flash(r4);
                            end;
                        end else begin
                            r4 := Bounds(144, Ball.BColor, 16, 16);
                            if Ball.Spin_c mod SPFlash < (SPFlash div 2) then begin
                                Flash(r4);
                            end;
                        end;
                    end;
                    else begin
                        if Ball.Spin_c mod SPFlash < (SPFlash div 2) then begin
                            Flash(r4);
                        end;
                    end;
                end;
                if Ball.SType <> Swaa then begin
                    bltX := ((Ball.X div 100) - 7)+RevMap;
                    bltY := ((240 - ((Ball.Z div 100)+15) - (Ball.Y div 100)));
                    //DDDraw(bltX,bltY,r4,AT.DBItem,True);
                    AL.DrawTexLT(AT.DBItemtx,r4.Left,r4.Top, 16, 16,bltX,bltY,DEFPRI+9);
                end;
            end;

        //ヒト
        end else if (j3 <= 11) then begin
        
            PlayerNo := j3 div 6;
            CharNo := j3 mod 6;
            if (P[PlayerNo].DBC[CharNo].Muki = Hidari) then begin
                Mir_f := mirLR;
            end else begin
                Mir_f := mirNone;
            end;

            with P[PlayerNo].DBC[CharNo] do begin
                if Dead_f = False then begin
                    //試合中
                    if ((GameSet_c = 0) or (GameSet_c > 380)) then begin
                        //強引な位置補正
                        if X < 0 then X := 0;
                        if X > 43200 then X := 43200;
                        if Z > 11200 then Z := 11200;
                        if Z < 0 then Z := 0;

                        //影
                        //DDDraw(((X div 100)-7+RevMap),((240-(Z div 100)-5)),rCS,AT.DBItem,True);
                        AL.DrawTexLT(AT.DBItemtx,144, 144, 16, 8,((X div 100)-7+RevMap),((240-(Z div 100)-5)),DEFPRI+8);

                        //ヒト
                        cX := (mNo div 100);
                        cY := (mNo mod 100);
                        mRevX := DBMNo[cX,cY,1];
                        mRevY := DBMNo[cX,cY,2];
                        TempRevX := mRevX;

                        r3Set;
                        if Muki = Hidari then TempRevX := -(TempRevX);//補正が必要

                        bltX := ((X div 100) - 23 + TempRevX)+RevMap;
                        bltY := ((240 - ((Z div 100)+32) - (Y div 100)) + mRevY);

                        BallRevX := 8;
                        BallRevY := 10;
                        //ボール位置補正
                        case mNo of
                              1:BallRevSet( -2, 0);
                              3:BallRevSet(-16,-8);
                            103:BallRevSet(-16,-8);
                            203:BallRevSet(-16,-8);
                              4:BallRevSet(-16,-16);
                            104:BallRevSet(-20,-16);
                            204:BallRevSet(  0,-20);
                              9:BallRevSet(-16,-8);
                            109:BallRevSet(-16,-8);
                            209:BallRevSet(-16,-8);
                             10:BallRevSet(-16,-16);
                            110:BallRevSet(-20,-16);
                            210:BallRevSet(  0,-20);
                        end;

                        r4 := Bounds(0,Ball.BColor, 16, 16);
                        //ボールを奥に描画
                        if (Ball_f = True) and (DBMNo[cX,cY,0] = 1) then begin
                            //DDDraw(bltX+16+(BallRevX*Muki),bltY+BallRevY,r4,AT.DBItem,True);
                            AL.DrawTexLT(AT.DBItemtx,r4.Left,r4.Top, 16, 16,bltX+16+(BallRevX*Muki),bltY+BallRevY,DEFPRI+9);

                        end;

                        //tg点滅
                        if (Ready_c > 0) or (GameSet_c > 0)
                        or (Ball.tgNo <> (PlayerNo*10 + CharNo))
                        or ((tg_c mod tgMax) < (tgMax div 2)) then begin

                            //ヒト描画
                            //ガイジンキャプテン
                            If (FaceType <> 0) then begin
                                //あおむけ
                                if (mNo = 308) then begin     
                                    //胴体
                                    //DDDraw(bltX,bltY,r3,AT.DBBody[(dNo div 10)],True);
                                    AL.DrawTexLT(AT.DBBody[(dNo div 10)],r3.Left,r3.Top,48,32,bltX,bltY,DEFPRI+9,
                                    $FF,$FFFFFF,BM_NORMAL,Mir_f);

                                    //顔
                                    r3SetB(96+((FaceType-1)*16), 192, 16, 16);
                                    if Muki = Migi then begin
                                        //DDDraw(bltX-1,bltY+16,r3,AT.DBBodyB[(dNo div 10)],True);
                                        AL.DrawTexLT(AT.DBBodyB[(dNo div 10)],r3.Left,r3.Top,16, 16,bltX-1,bltY+16,DEFPRI+9);
                                    end else begin
                                        //DDDraw(bltX+33,bltY+16,r3,AT.DBBodyB[(dNo div 10)],True);
                                        AL.DrawTexLT(AT.DBBodyB[(dNo div 10)],r3.Left,r3.Top,16, 16,bltX+33,bltY+16,DEFPRI+9);
                                    end;

                                //吹っ飛び（後転）
                                end else if (mNo = 405) then begin
                                    r3SetB(96, (FaceType-1)*32, 48, 32);
                                    //DDDraw(bltX,bltY,r3,AT.DBBodyB[(dNo div 10)],True);
                                    AL.DrawTexLT(AT.DBBodyB[(dNo div 10)],r3.Left,r3.Top,48, 32,bltX,bltY,DEFPRI+9);
                                //吹っ飛び（前転）
                                end else if (mNo = 406) then begin
                                    r3SetB(96,96+((FaceType-1)*32), 48, 32);
                                    //DDDraw(bltX,bltY,r3,AT.DBBodyB[(dNo div 10)],True);
                                    AL.DrawTexLT(AT.DBBodyB[(dNo div 10)],r3.Left,r3.Top,48, 32,bltX,bltY,DEFPRI+9);
                                //転がり、うつぶせ
                                end else if ((mNo >= 400) and (mNo <= 404)) then begin
                                    //r3SetB(96,32+((FaceType-1)*32), 48, 32);
                                    //もるどふ
                                    if (FaceType = 3) then begin
                                        //描画元画像一個右にシフト
                                        cX := cX + 1;
                                        r3Set;
                                        cX := cX - 1;
                                    end;

                                    //DDDraw(bltX,bltY,r3,AT.DBBody[(dNo div 10)],True);

                                    AL.DrawTexLT(AT.DBBody[(dNo div 10)],r3.Left,r3.Top,48, 32,bltX,bltY,DEFPRI+9,
                                    $FF,$FFFFFF,BM_NORMAL,Mir_f);
                                //グロッキー
                                end else if ((mNo = 309) or (mNo = 310)) then begin
                                    //顔
                                    r3SetB(96+((FaceType-1)*16), 208, 16, 16);
                                    //DDDraw(bltX+16+(4*Muki),bltY,r3,AT.DBBodyB[(dNo div 10)],True);

                                    AL.DrawTexLT(AT.DBBodyB[(dNo div 10)],r3.Left,r3.Top,16, 16,bltX+16+(4*Muki),bltY,DEFPRI+9);

                                    //描画元画像２個下にシフト
                                    cY := cY + 2;
                                    r3Set;
                                    cY := cY - 2;
                                    //DDDraw(bltX,bltY,r3,AT.DBBody[(dNo div 10)],True);
                                    AL.DrawTexLT(AT.DBBody[(dNo div 10)],r3.Left,r3.Top,48, 32,bltX,bltY,DEFPRI+9,
                                    $FF,$FFFFFF,BM_NORMAL,Mir_f);
                                end else begin
                                    //もるどふ(奥向きはノーマルキャラと同じ)
                                    if (FaceType = 3) and ((mNo div 100 <> 2) or ((mNo = 203) or (mNo = 209))) then begin
                                        //下16ドット
                                        r3.Top := r3.Top + 16;
                                        //DDDraw(bltX,bltY+16,r3,AT.DBBody[(dNo div 10)],True);
                                        AL.DrawTexLT(AT.DBBody[(dNo div 10)],r3.Left,r3.Top,48, 32,bltX,bltY+16,DEFPRI+9,
                                        $FF,$FFFFFF,BM_NORMAL,Mir_f);

                                        //上16ドット（もるどふ顔）
                                        //右上シュート
                                        if ((mNo = 203) or (mNo = 209)) then begin
                                            r3SetB(96, 224, 48, 16);
                                        //歩き＆ダッシュ
                                        end else if ((mNo >= 300) and (mNo <= 307)) then begin
                                            r3SetB(48, 0, 48, 16);
                                        end else begin
                                            r3SetB(48*cX,16*cY, 48, 16);
                                        end;
                                        //DDDraw(bltX,bltY,r3,AT.DBBodyB[(dNo div 10)],True);
                                        AL.DrawTexLT(AT.DBBodyB[(dNo div 10)],r3.Left,r3.Top,48, 16,bltX,bltY,DEFPRI+9);
                                    //その他
                                    end else begin
                                        //顔先描画
                                        if (DBMNo[cX,cY,3] div 10 = 1) then begin
                                            FaceDraw(CharNo,PlayerNo,bltX,bltY,(DBMNo[cX,cY,3] mod 10));
                                        end;

                                        //描画
                                        //DDDraw(bltX,bltY,r3,AT.DBBody[(dNo div 10)],True);
                                        AL.DrawTexLT(AT.DBBody[(dNo div 10)],r3.Left,r3.Top,48, 32,bltX,bltY,DEFPRI+9,
                                        $FF,$FFFFFF,BM_NORMAL,Mir_f);
                                        //顔後描画
                                        if (DBMNo[cX,cY,3] div 10 = 0) then begin
                                            FaceDraw(CharNo,PlayerNo,bltX,bltY,(DBMNo[cX,cY,3] mod 10));
                                        end;
                                    end;
                                end;

                            end else begin
                                //顔先描画
                                if (DBMNo[cX,cY,3] div 10 = 1)
                                or ((DBMNo[cX,cY,3] div 10 = 2)
                                and (((Face mod 10 <> 1) and (Face mod 10 <> 4))
                                and ((Name <> 'むはまど') and (Name <> 'ひろし２')))
                                //or ((Name = 'むはまど') or (Name = 'ひろし２'))
                                ) then begin
                                    FaceDraw(CharNo,PlayerNo,bltX,bltY+DBMNo[cX,cY,4],(DBMNo[cX,cY,3] mod 10));
                                end;
                                {
                                //いちろう(転がり、うつぶせ、吹っ飛び)
                                if (Face mod 10 = 3) and (mNo >= 400) and (mNo <= 406) then begin
                                    //描画元画像一個右にシフト
                                    cY := cY + 7;
                                    r3Set;
                                    cY := cY - 7;
                                end;
                                }

                                //描画
                                //DDDraw(bltX,bltY,r3,AT.DBBody[(dNo div 10)],True);

                                AL.DrawTexDBLT(AT.DBBody[(dNo div 10)],r3,bltX,bltY,DEFPRI+9,Mir_f);

                                //顔後描画
                                if (DBMNo[cX,cY,3] div 10 = 0)
                                or ((DBMNo[cX,cY,3] div 10 = 2)
                                and (((Face mod 10 = 1)or(Face mod 10 = 4)) or ((Name = 'むはまど') or (Name = 'ひろし２')))
                                //and ((Name <> 'むはまど') and (Name <> 'ひろし２'))
                                ) then begin
                                    FaceDraw(CharNo,PlayerNo,bltX,bltY+DBMNo[cX,cY,4],(DBMNo[cX,cY,3] mod 10));
                                end;
                            end;

                        end;

                        //ボールを手前に描画
                        if (Ball_f = True) and (DBMNo[cX,cY,0] = 0) then begin
                            //DDDraw(bltX+16+(BallRevX*Muki),bltY+BallRevY,r4,AT.DBItem,True);
                            AL.DrawTexLT(AT.DBItemtx,r4.Left,r4.Top,16,16,bltX+16+(BallRevX*Muki),bltY+BallRevY,DEFPRI+9);
                        end;
                    //勝ちポーズ＆外野負けポーズ
                    end else begin
                        //一応浮いてる場合も無理矢理着地
                        Y := 0;
                        Ball.Y := 0;
                        If PlayerNo = 0 then begin
                            Muki := Migi;
                        end else begin
                            Muki := Hidari;
                        end;
                        //外野は向き逆
                        If Pos <> 1 then Muki := -Muki;

                        //影
                        //DDDraw(((X div 100)-7+RevMap),((240-(Z div 100)-5)),rCS,AT.DBItem,True);
                        AL.DrawTexLT(AT.DBItemtx,144, 144, 16, 8,((X div 100)-7+RevMap),((240-(Z div 100)-5)),DEFPRI+9);


                        bltX := ((X div 100) - 23)+RevMap;
                        bltY := ((240 - ((Z div 100)+32) - (Y div 100)));

                        //勝ちチーム
                        if P[PlayerNo].Dead_c < 3 then begin
                            If (GameSet_c mod 80) < 40 then begin
                                r3SetC(144, 352+(FaceType * 32), 48, 32);
                            end else begin
                                r3SetC(144, 384+(FaceType * 32), 48, 32);
                            end;

                            //ジャンプする分の補正
                            if FaceType = 0 then begin
                                If (GameSet_c mod 80) < 40 then begin
                                    bltY := bltY + 5;
                                end else begin
                                    bltY := bltY - 8;
                                end;
                                //顔描画
                                FaceDraw(CharNo,PlayerNo,bltX,bltY,6);//笑い顔
                            end;

                            //DDDraw(bltX,bltY,r3,AT.DBBody[(dNo div 10)],True);
                            AL.DrawTexDBLT(AT.DBBody[(dNo div 10)],r3,bltX,bltY,DEFPRI+9,Mir_f);
                        //負けチーム
                        end else begin
                            If (GameSet_c mod 80) < 40 then begin
                                r3SetC(144, 416+(FaceType * 32), 48, 32);
                            end else begin
                                r3SetC(144, 448+(FaceType * 32), 48, 32);
                                bltY := bltY + 1;
                            end;
                            if FaceType = 0 then begin
                                bltY := bltY + 9;
                                //顔描画
                                FaceDraw(CharNo,PlayerNo,bltX,bltY,2);//笑い顔
                            end;
                            //DDDraw(bltX,bltY,r3,AT.DBBody[(dNo div 10)],True);
                            //AL.DrawTexLT(AT.DBItemtx,144, 144, 16, 8,bltX,bltY,DEFPRI+9);
                            AL.DrawTexDBLT(AT.DBBody[(dNo div 10)],r3,bltX,bltY,DEFPRI+9,Mir_f);
                        end;

                    end;
                end else begin
                    //天使表示
                    if ((GameSet_c = 0) or (GameSet_c > 380)) and (Pos = 1) and (Holy_c > 0) then begin
                        inc(Holy_c);
                        if Holy_c >= 480 then begin
                            Holy_c := 0;     
                        end else begin
                            if (Holy_c mod 120) < 60 then begin
                                bltDX := (((HolyX) div 100))+RevMap+((Holy_c mod 60) div 2)-15;
                            end else begin
                                bltDX := (((HolyX) div 100))+RevMap+30-((Holy_c mod 60) div 2)-15;
                            end;
                            bltDY := ((240 - ((HolyZ div 100)+24+(Holy_c div 2)) - (HolyY div 100)));
                            //DDDraw(bltDX-4,bltDY,rEgl,AT.DBItem,True);
                            AL.DrawTexLT(AT.DBItemtx,128, 144, 16, 16,bltDX-4,bltDY,DEFPRI+9);

                        end;
                    end;
                end;
            end;
        end;

    end;


    if ((GameSet_c = 0) or (GameSet_c > 380)) then begin
        //⑤キャラの選択
        for j2 := 0 to 12 do begin

            j3 := (SortDt[j2].BaseNo);

            //ヒト
            if (j3 <= 11) then begin
                PlayerNo := j3 div 6;
                CharNo := j3 mod 6;
                with P[PlayerNo].DBC[CharNo] do begin

                    //ヒト
                    cX := (mNo div 100);
                    cY := (mNo mod 100);
                    mRevX := DBMNo[cX,cY,1];
                    mRevY := DBMNo[cX,cY,2];
                    TempRevX := mRevX;

                    if Muki = Migi then begin

                        r3 := Bounds(48*cX,32*cY,48,32);

                    end else if Muki = Hidari then begin//補正が必要

                        r3 := Bounds(((AT.DBBody[(dNo div 10)].Width div Mag)-(48*cX)-48),32*(cY+CharY),48,32);
                        TempRevX := -(TempRevX);

                    end;

                    bltX := (((X) div 100) - 23 + TempRevX)+RevMap;
                    bltY := ((240 - ((Z div 100)+32) - (Y div 100)) + mRevY);

                    //ダメージ表示
                    if (Pos = 1) and (dam_c > 0) then begin
                        dec(dam_c);
                        r5 := Bounds(8*(damDt div 10),152, 8, 8);
                        bltDX := (((damX) div 100) + TempRevX)+RevMap;
                        bltDY := ((240 - ((damZ div 100)+24-(dam_c div 2)) - (damY div 100)));
                        //DDDraw(bltDX-4,bltDY,r5,AT.DBItem,True);
                        //AL.DrawTexLT(AT.DBItemtx,r5.Left,r5.Right,48,32,bltDX-4,bltDY,DEFPRI+10);
                        AL.DrawTexDBLT(AT.DBItemtx,r5,bltDX-4,bltDY,DEFPRI+10);
                        r5 := Bounds(8*(damDt mod 10),152, 8, 8);
                        bltDX := (((damX) div 100) + TempRevX)+RevMap;
                        bltDY := ((240 - ((damZ div 100)+24-(dam_c div 2)) - (damY div 100)));
                        //DDDraw(bltDX+4,bltDY,r5,AT.DBItem,True);
                        //AL.DrawTexLT(AT.DBItemtx,r5.Left,r5.Right,8, 8,bltDX+4,bltDY,DEFPRI+10);
                        AL.DrawTexDBLT(AT.DBItemtx,r5,bltDX+4,bltDY,DEFPRI+10);
                    end;

                    if Dead_f = False then begin
                        //キャラナンバー
                        if (GameSet_c = 0) and (Ready_c = 0) and ((CPU_f = False) or (PlayerNo = 0)) then begin
                            if (P[PlayerNo].PNo = CharNo)
                            and (Dam_f = None) and (Groggy_c = 0)
                            and (Cur_c < (CurMax div 2)) then begin
                                r5 := Bounds(8*(PlayerNo+1),152, 8, 8);
                                //DDDraw(bltX+24-4,bltY-10,r5,AT.DBItem,True);
                                AL.DrawTexDBLT(AT.DBItemtx,r5,bltX+24-4,bltY-10,DEFPRI+10);
                            end;
                        end;
                    end;
                end;
            end;
        end;
    end;
end;

//カーソルの付いてないキャラ
procedure DBNPC(i:integer;i2:integer);
    var
        ENo:integer;
    procedure Pos14(j:integer;j2:integer);
    begin
        with P[j2].DBC[j] do begin
            if Z > Ball.Z +600  then begin
                KeyD3 := True;
                KeyU3 := False;
            end else if Z < Ball.Z then begin
                KeyD3 := False;
            end;
            if Z < Ball.Z -600 then begin
                KeyU3 := True;
                KeyD3 := False;
            end else if Z > Ball.Z then begin
                KeyU3 := False;
            end;

            if KeyU3 = True then begin
                KeyU2 := True;
                Move_f := True;
            end else if KeyD3 = True then begin
                KeyD2 := True;
                Move_f := True;
            end else begin
                Move_f := False;
            end;
            Muki2 := None;
        end;
    end;
    procedure Pos23(j:integer;j2:integer);
    begin
        with P[j2].DBC[j] do begin
            if X > Ball.X +600 then begin
                KeyL3 := True;
                KeyR3 := False;
            end else if X < Ball.X then begin
                KeyL3 := False;
            end;
            if X < Ball.X -600  then begin
                KeyR3 := True;
                KeyL3 := False;
            end else if X > Ball.X then begin
                KeyR3 := False;
            end;

            if KeyR3 = True then begin
                KeyR2 := True;
                Muki := Migi;
                Move_f := True;
            end else if KeyL3 = True then begin
                KeyL2 := True;
                Muki := Hidari;
                Move_f := True;
            end else begin
                Move_f := False;
            end;
        end;
    end;
    //フォーメーション移動
    procedure SetFormSet;
    begin
        with P[i2].DBC[i] do begin

            if i2 = 0 then begin
                ENo := 1;
            end else begin
                ENo := 0;
            end;

            FormChange_f := True;

            if (Ball.Motion = BPass) then begin
                FormNo := P[ENo].DBC[Ball.ptgNo].Pos;
            end else if (Ball.Motion = BHold) then begin
                FormNo := P[ENo].DBC[Ball.HoldChar mod 10].Pos;
            end;

            case FormNo of
                1:begin
                    tfX := 5000+Random(1000);
                    tfZ := 3000+Random(6000);
                end;
                2:begin
                    tfX := 5000+Random(15000);
                    tfZ := 3000+Random(1000);
                end;
                3:begin
                    tfX := 5000+Random(15000);
                    tfZ := 8000+Random(1000);
                end;
                4:begin
                    tfX := 20000+Random(1000);
                    tfZ := 3000+Random(6000);
                end;
            end;
            if i2 = 1 then tfX := 43200 - tfX;
        end;
    end;
    //フォーメーション移動
    procedure SetForm;
    const
        fX2 = 1500;
        fZ2 = 1500;
        fX3 = 3000;
    begin
        with P[i2].DBC[i] do begin

            //敵番号
            if i2 = 0 then begin
                ENo := 1;
            end else begin
                ENo := 0;
            end;

            //フォーメーション変更
            if (Ball.Motion = BHold) and (Pos = 1)
            and (FormNo <> P[ENo].DBC[Ball.HoldChar mod 10].Pos) then begin
                SetFormSet;
            end;

            if X < tfX-fX2 then begin
                KeyR2 := True;
                Muki := Migi;
                Muki2 := None;
                Move_f := True;
                Dash_f := None;
            end else if X > tfX+fX2 then begin
                KeyL2 := True;
                Muki := Hidari;
                Muki2 := None;
                Move_f := True;
                Dash_f := None;
            end;
            if X < tfX-fX3 then begin
                Dash_f := Migi;
                Muki := Migi;
                Muki2 := None;
                //mNo_c := 0;
            end else if X > tfX+fX3 then begin
                Dash_f := Hidari;
                Muki := Hidari;
                Muki2 := None;
                //mNo_c := 0;
            end;

            if Z > tfZ+fZ2 then begin
                KeyD2 := True;
                Muki2 := Shita;
                Move_f := True;
            end else if Z < tfZ-fZ2 then begin
                KeyU2 := True;
                Muki2 := Ue;
                Move_f := True;
            end;
            if Pos = 1 then begin
                if Move_f = False then begin
                    case FormNo of
                        1:begin
                            if Move_f = False then begin
                                Muki := Migi;
                                Muki2 := None;
                                if i2 = 1 then Muki := -Muki;
                            end;
                        end;
                        2:begin
                            if Move_f = False then begin
                                Muki2 := Ue;
                                if Ball.X < X - 1000 then begin
                                    Muki := Hidari;
                                end else if Ball.X > X + 1000 then begin
                                    Muki := Migi;
                                end;
                            end;
                        end;
                        3:begin
                            if Move_f = False then begin
                                Muki2 := Shita;
                                if Ball.X < X - 1000 then begin
                                    Muki := Hidari;
                                end else if Ball.X > X + 1000 then begin
                                    Muki := Migi;
                                end;
                            end;
                        end;
                        4:begin
                            if Move_f = False then begin
                                Muki := Hidari;
                                Muki2 := None;
                                if i2 = 1 then Muki := -Muki;
                            end;
                        end;
                    end;
                end;
            //外野
            end else begin
                if Move_f = False then begin

                    If Ball.X < X - 600 then begin
                        Muki := Hidari;
                    end else If Ball.X > X + 600 then begin
                        Muki := Migi;
                    end;

                    if Pos = 2 then begin
                        Muki2 := Shita;
                    end else if Pos = 3 then begin
                        Muki2 := Ue;
                    end;
                end;
            end;

            if Jump_f <> None then Dash_f := None;

        end;
    end;
    //ノンカーソルのオートしゃがみよけ
    procedure Kaihi();
    begin
         with P[i2].DBC[i] do begin

            Dash_f := None;

            //しゃがむ
            if (X + 4800 > Ball.X) and (X - 4800 < Ball.X)
            and (Z + 3200 > Ball.Z) and (Z - 3200 < Ball.Z)
            and (Act_f <> Ca) and (Per100(10)) then begin
                Act_f := Crm;
            end;
            { 一応別のところに作った
            //しゃがみ続ける
            if (X + 4800 > Ball.X) and (X - 4800 < Ball.X)
            and (Z + 3200 > Ball.Z) and (Z - 3200 < Ball.Z)
            and (Act_f = Cr) and (P[i2].DBC[i].Act_c > 6)then begin
                P[i2].DBC[i].Act_c := 6;//しゃがみ続ける
            end;
            }
            FormChange_f := False;
        end;
    end;
    //パスキャッチジャンプ
    procedure PCJump();
    begin
        with P[i2].DBC[i] do begin

            JMuki := None;
            JMuki2 := None;
            if (PCJump_c >= 1) then begin
                //パスキャッチジャンプ
                Dec(PCJump_c);
                if PCJump_c = 0 then begin
                    Jump_f := J1;
                    Jump_c := 0;
                end;
            end else if (PCJump_c <= -1) then begin
                Jump_f := J1;
                Jump_c := 0;
                PCJump_c := 0;
            end;
            if (PC_c >= 1) then begin
                //パスキャッチ
                Dec(PC_c);
                if (PC_c = 0) and (PCJump_c = 0) then begin
                    if Jump_f = J2 then begin
                        Act_f := JCa;
                    end else if Jump_f = J1 then begin
                        PC_c := 1;
                    end else begin
                        Act_f := Ca;
                    end;
                    Act_c := 0;
                end;
            end;
        end;
    end;

begin

    with P[i2].DBC[i] do begin

        if Auto_f2 = True then begin
            Auto_f := False;
        end;

        if (Auto_f = False) and (Auto_f2 = False) and (Groggy_c = 0) then begin
            if i2 = 0 then begin
                //パス待ち
                case Pos of
                    1:begin
                        //味方ボール
                        if (Ball.HoldChar div 10 = i2) then begin
                            if (Ball.Motion = BShoot) and (Ball.ZShoot_f = False)
                            and (Ball.dX <= 0) then begin
                                if Ball.X < X + 12800 then begin

                                    Pos14(i,i2);

                                end;
                            end else if (Ball.Motion = BPass) then begin

                                PCJump;
                                //FormChange_f := False;
                            end else if (Ball.Motion = BHold) then begin
                                if (P[i2].DBC[Ball.HoldChar mod 10].Pos = 2) then begin
                                    Muki2 := Ue;
                                    Muki := Migi;
                                end else if (P[i2].DBC[Ball.HoldChar mod 10].Pos = 3) then begin
                                    Muki2 := Shita;
                                    Muki := Migi;
                                end else begin
                                    if Ball.X < X - 600 then begin
                                        Muki := Hidari;
                                    end else if Ball.X > X + 600 then begin
                                        Muki := Migi;
                                    end;
                                    if Ball.Z < Z - 600 then begin
                                        Muki2 := Shita;
                                    end else if Ball.Z > Z + 600 then begin
                                        Muki2 := Ue;
                                    end else begin
                                        Muki2 := None;
                                    end;
                                end;
                            end;

                            Dash_f := None;
                            
                        //敵ボール
                        end else begin
                            if (Ball.Motion = BPass)
                            or (Ball.Motion = BHold) then begin

                                //フォームチェンジの初期設定
                                if FormChange_f = False then begin

                                    SetFormSet;
                                    
                                end;

                                SetForm;

                            end else if (Ball.Motion = BShoot) then begin

                                Kaihi;

                            end else begin

                                FormChange_f := False;

                            end;
                        end;
                    end;
                    2:begin
                        if (Ball.Motion = BShoot) and (Ball.ZShoot_f = True)
                        and (Ball.dZ >= 0) then begin
                            if Ball.Z > Z - 6400 then begin

                                Pos23(i,i2);

                            end;
                            FormChange_f := False;
                        end else if (Ball.Motion = BPass) then begin

                            PCJump;
                            //FormChange_f := False;

                        end else if (Ball.Motion = BHold) then begin
                            //味方が持ってる
                            if (Ball.HoldChar div 10 = i2) then begin
                            if (P[i2].DBC[Ball.HoldChar mod 10].Act_f = None) then
                                //フォームチェンジの初期設定
                                if FormChange_f = False then begin

                                    FormChange_f := True;
                                    tfX := 13000+Random(1000);
                                    tfZ := Z;

                                    tfX := 43200 - tfX;

                                end;

                                if (P[i2].DBC[Ball.HoldChar mod 10].Act_f = None) then begin
                                    SetForm;
                                end;
                            //敵が持ってる
                            end else begin
                                //フォームチェンジの初期設定
                                if FormChange_f = False then begin

                                    FormChange_f := True;
                                    tfX := 5000+Random(1000);
                                    tfZ := Z;

                                    tfX := 43200 - tfX;

                                end;

                                SetForm;

                            end;
                        end else begin
                            FormChange_f := False;
                        end;
                    end;
                    3:begin
                        if (Ball.Motion = BShoot) and (Ball.ZShoot_f = True)
                        and (Ball.dZ < 0) then begin
                            if Ball.Z < Z + 6400 then begin

                                Pos23(i,i2);
                                FormChange_f := False;
                            end;
                        end else if (Ball.Motion = BPass) then begin

                            PCJump;
                            //FormChange_f := False;
                        end else if (Ball.Motion = BHold) then begin
                            if (Ball.HoldChar div 10 = i2) then begin
                                //フォームチェンジの初期設定
                                if FormChange_f = False then begin

                                    FormChange_f := True;
                                    tfX := 12000+Random(1000);
                                    tfZ := Z;

                                    tfX := 43200 - tfX;

                                end;
                                if (P[i2].DBC[Ball.HoldChar mod 10].Act_f = None) then begin
                                    SetForm;
                                end;
                            end else begin
                                //フォームチェンジの初期設定
                                if FormChange_f = False then begin

                                    FormChange_f := True;
                                    tfX := 4000+Random(1000);
                                    tfZ := Z;

                                    tfX := 43200 - tfX;

                                end;

                                SetForm;

                            end;
                        end else begin
                            FormChange_f := False;
                        end;
                    end;
                    4:begin
                        if (Ball.Motion = BShoot) and (Ball.ZShoot_f = False)
                        and (Ball.dX > 0) then begin
                            if Ball.X > X - 9600 then begin

                                Pos14(i,i2);

                            end;
                        end else if (Ball.Motion = BPass) then begin

                            PCJump;

                        end else if (Ball.Motion = BHold) and (Ball.HoldChar div 10 = i2) then begin
                            //向き変える
                            Muki := Hidari;
                            if (P[i2].DBC[Ball.HoldChar mod 10].Pos = 2) then begin
                                Muki2 := Ue;
                            end else if (P[i2].DBC[Ball.HoldChar mod 10].Pos = 3) then begin
                                Muki2 := Shita;
                            end else begin
                                Muki2:= None;
                            end;
                        end;
                    end;
                end;
            end else if i2 = 1 then begin
                case Pos of
                    1:begin
                        //味方ボール
                        if (Ball.HoldChar div 10 = i2) then begin
                            if (Ball.Motion = BShoot) and (Ball.ZShoot_f = False)
                            and (Ball.dX >= 0) then begin
                                if Ball.X > X - 12800 then begin

                                    Pos14(i,i2);

                                end;
                            end else if (Ball.Motion = BPass) then begin

                                PCJump;
                                //FormChange_f := False;
                            end else if (Ball.Motion = BHold) then begin
                                if (P[i2].DBC[Ball.HoldChar mod 10].Pos = 2) then begin
                                    Muki2 := Ue;
                                    Muki := Hidari;
                                end else if (P[i2].DBC[Ball.HoldChar mod 10].Pos = 3) then begin
                                    Muki2 := Hidari;
                                end else begin
                                    if Ball.X < X - 600 then begin
                                        Muki := Hidari;
                                    end else if Ball.X > X + 600 then begin
                                        Muki := Migi;
                                    end;
                                    if Ball.Z < Z - 600 then begin
                                        Muki2 := Shita;
                                    end else if Ball.Z > Z + 600 then begin
                                        Muki2 := Ue;
                                    end else begin
                                        Muki2 := None;
                                    end;
                                end;
                            end;

                            FormChange_f := False;
                            Dash_f := None;

                        //敵ボール
                        end else begin
                            if (Ball.Motion = BPass)
                            or (Ball.Motion = BHold) then begin

                                //フォームチェンジの初期設定
                                if FormChange_f = False then begin

                                    SetFormSet;

                                end;

                                SetForm;

                            end else if (Ball.Motion = BShoot) then begin

                                Kaihi;
                            end else begin

                                FormChange_f := False;

                            end;
                        end;
                    end;
                    2:begin
                        if (Ball.Motion = BShoot) and (Ball.ZShoot_f = True)
                        and (Ball.dZ >= 0) then begin
                            if Ball.Z > Z - 6400 then begin

                                Pos23(i,i2);
                                FormChange_f := False;
                            end;
                        end else if (Ball.Motion = BPass) then begin

                            PCJump;
                            //FormChange_f := False;
                        end else if (Ball.Motion = BHold) then begin
                            //味方が持ってる
                            if (Ball.HoldChar div 10 = i2) then begin
                                //フォームチェンジの初期設定
                                if FormChange_f = False then begin

                                    FormChange_f := True;
                                    tfX := 13000+Random(1000);
                                    tfZ := Z;
                                end;

                                if (P[i2].DBC[Ball.HoldChar mod 10].Act_f = None) then begin
                                    SetForm;
                                end;
                            //敵が持ってる
                            end else begin
                                //フォームチェンジの初期設定
                                if FormChange_f = False then begin

                                    FormChange_f := True;
                                    tfX := 5000+Random(1000);
                                    tfZ := Z;
                                end;

                                SetForm;

                            end;
                        end else begin
                            FormChange_f := False;
                        end;
                    end;
                    3:begin
                        if (Ball.Motion = BShoot) and (Ball.ZShoot_f = True)
                        and (Ball.dZ < 0) then begin
                            if Ball.Z < Z + 6400 then begin

                                Pos23(i,i2);
                                FormChange_f := False;
                            end;
                        end else if (Ball.Motion = BPass) then begin

                            PCJump;
                            //FormChange_f := False;
                        end else if (Ball.Motion = BHold) then begin
                            if (Ball.HoldChar div 10 = i2) then begin
                                //フォームチェンジの初期設定
                                if FormChange_f = False then begin

                                    FormChange_f := True;
                                    tfX := 12000+Random(1000);
                                    tfZ := Z;

                                end;

                                if (P[i2].DBC[Ball.HoldChar mod 10].Act_f = None) then begin
                                    SetForm;
                                end;

                            end else begin
                                //フォームチェンジの初期設定
                                if FormChange_f = False then begin

                                    FormChange_f := True;
                                    tfX := 4000+Random(1000);
                                    tfZ := Z;

                                end;

                                SetForm;

                            end;
                        end else begin
                            FormChange_f := False;
                        end;
                    end;
                    4:begin
                        if (Ball.Motion = BShoot) and (Ball.ZShoot_f = False)
                        and (Ball.dX < 0) then begin
                            if Ball.X < X + 9600 then begin

                                Pos14(i,i2);

                            end;
                        end else if (Ball.Motion = BPass) then begin

                            PCJump;

                        end else if (Ball.Motion = BHold) and (Ball.HoldChar div 10 = i2) then begin
                            //向き変える
                            Muki := Migi;
                            if (P[i2].DBC[Ball.HoldChar mod 10].Pos = 2) then begin
                                Muki2 := Ue;
                            end else if (P[i2].DBC[Ball.HoldChar mod 10].Pos = 3) then begin
                                Muki2 := Shita;
                            end else begin
                                Muki2:= None;
                            end;
                        end;
                    end;
                end;
            end;

        //オート移動フラグがたっているとき
        end else if Auto_f = True then begin
            case Pos of
                1:begin
                    If (Act_f = None) then begin

                        KeyU2 := False;
                        KeyD2 := False;
                        KeyL2 := False;
                        KeyR2 := False;

                        if AutoMuki = Migi then begin
                            Dash_f := Migi;
                            Muki := Migi;
                        end else if AutoMuki = Hidari then begin
                            Dash_f := Hidari;
                            Muki := Hidari;
                        end;

                        if AutoMuki2 = Ue then begin
                            KeyU2 := True;
                            Muki2 := Ue;
                            Move_f := True;
                        end else if AutoMuki2 = Shita then begin
                            KeyD2 := True;
                            Muki2 := Shita;
                            Move_f := True;
                        end;
                        if i2 = 0 then begin
                            if ((X > 4000 + (((Z-2000)* 2) div 9)+800)
                            and (X < 20800-800))
                            and ((Z <= 9200) and (Z >= 2000)) then begin

                                Auto_f := False;
                                if Dash_f <> None then begin
                                    SetSLP(i,i2);
                                end;

                            end;
                        end else if i2 = 1 then begin
                            if ((X < (43200-4000) - (((Z-2000)* 2) div 9)-800)
                            and (X > 22400+800))
                            and ((Z <= 9200) and (Z >= 2000)) then begin

                                Auto_f := False;
                                if Dash_f <> None then begin
                                    SetSLP(i,i2);
                                end;

                            end;
                        end;
                    end;
                end;
                else begin
                    //追っかけ
                    if (Ball.Motion = BFree) or (Ball.Motion = BBound) then begin

                        if X > Ball.X +600 then begin
                            KeyL3 := True;
                            KeyR3 := False;
                        end else if X < Ball.X then begin
                            KeyL3 := False;
                        end;
                        if X < Ball.X -600 then begin
                            KeyR3 := True;
                            KeyL3 := False;
                        end else if X > Ball.X then begin
                            KeyR3 := False;
                        end;

                        if KeyR3 = True then begin
                            KeyR2 := True;
                            Muki := Migi;
                            Move_f := True;
                            Dash_f := None;
                            if X < Ball.X -1600 then begin
                                Dash_f := Migi;
                            end;
                        end else if KeyL3 = True then begin
                            KeyL2 := True;
                            Muki := Hidari;
                            Move_f := True;
                            Dash_f := None;
                            if X > Ball.X +1600 then begin
                                Dash_f := Hidari;
                            end;
                        end else begin
                            Dash_f := None;
                        end;

                        if Z > Ball.Z +600  then begin
                            KeyD3 := True;
                            KeyU3 := False;
                        end else if Z < Ball.Z then begin
                            KeyD3 := False;
                        end;
                        if Z < Ball.Z -600 then begin
                            KeyU3 := True;
                            KeyD3 := False;
                        end else if Z > Ball.Z then begin
                            KeyU3 := False;
                        end;

                        if KeyU3 = True then begin
                            KeyU2 := True;
                            Move_f := True;
                        end else if KeyD3 = True then begin
                            KeyD2 := True;
                            Move_f := True;
                        end;

                        if  (Act_f = None)
                        and ((Ball.Z div 100) <= (Z div 100) + 6)
                        and ((Ball.Z div 100) >= (Z div 100) - 6)
                        and ((Ball.X div 100) <= (X div 100) + 6)
                        and ((Ball.X div 100) >= (X div 100) - 6) then begin

                            if Ball.Motion = BFree then begin
                                Act_f := TCr;
                            end else if Ball.Motion = BBound then begin
                                if Ball.Y <= 2400 then begin
                                    Act_f := Ca;
                                end;
                            end;
                            if Move_f = True then Muki2 := None;

                            Act_c := 0;
                            Dash_f := None;
                            
                        end;

                    //帰還
                    end else begin
                        Dash_f := None;
                        case Pos of
                            2:begin
                                if i2 = 0 then begin
                                    if X < 22400 then begin
                                        KeyR2 := True;
                                        Muki := Migi;
                                        Muki2 := None;
                                    end else if X > 38400 then begin
                                        KeyL2 := True;
                                        Muki := Hidari;
                                        Muki2 := None;
                                    end;
                                end else if i2 = 1 then begin
                                    if X < 4800 then begin
                                        KeyR2 := True;
                                        Muki := Migi;
                                        Muki2 := None;
                                    end else if X > 20800 then begin
                                        KeyL2 := True;
                                        Muki := Hidari;
                                        Muki2 := None;
                                    end;
                                end;
                                if Z > 10000+100 then begin
                                    KeyD2 := True;
                                    Muki2 := Shita;
                                end else if Z < 10000-100 then begin
                                    KeyU2 := True;
                                    Muki2 := Ue;
                                end else begin
                                    Z := 10000;
                                end;
                            end;
                            3:begin
                                if i2 = 0 then begin
                                    if X < 22400 then begin
                                        KeyR2 := True;
                                        Muki := Migi;
                                        Muki2 := None;
                                    end else if X > 40000 then begin
                                        KeyL2 := True;
                                        Muki := Hidari;
                                        Muki2 := None;
                                    end;
                                end else if i2 = 1 then begin
                                    if X < 3200 then begin
                                        KeyR2 := True;
                                        Muki := Migi;
                                        Muki2 := None;
                                    end else if X > 20800 then begin
                                        KeyL2 := True;
                                        Muki := Hidari;
                                        Muki2 := None;
                                    end;
                                end;
                                if Z > 800+100 then begin
                                    KeyD2 := True;
                                    Muki2 := Shita;
                                end else if Z < 800-100 then begin
                                    KeyU2 := True;
                                    Muki2 := Ue;
                                end else begin
                                    Z := 800;
                                end;
                            end;
                            4:begin
                                if i2 = 0 then begin
                                    if X < 41600 - (((Z-2000)* 2) div 9) - 100 then begin
                                        KeyR2 := True;
                                        Muki := Migi;
                                        Muki2 := None;
                                    end else if X > 41600 - (((Z-2000)* 2) div 9) + 100 then begin
                                        KeyL2 := True;
                                        Muki := Hidari;
                                        Muki2 := None;
                                    end else begin
                                        X := 41600 - (((Z-2000)* 2) div 9);
                                    end;
                                end else if i2 = 1 then begin
                                    if X < 1600 + (((Z-2000)* 2) div 9) - 100 then begin
                                        KeyR2 := True;
                                        Muki := Migi;
                                        Muki2 := None;
                                    end else if X > 1600 + (((Z-2000)* 2) div 9) + 100 then begin
                                        KeyL2 := True;
                                        Muki := Hidari;
                                        Muki2 := None;
                                    end else begin
                                        X := 1600 + (((Z-2000)* 2) div 9);
                                    end;
                                end;
                                if Z > 9200 then begin
                                    KeyD2 := True;
                                    Muki2 := Shita;
                                end else if Z < 2000 then begin
                                    KeyU2 := True;
                                    Muki2 := Ue;
                                end;
                            end;
                        end;

                        if (KeyU2 = False) and (KeyD2 = False)
                        and (KeyL2 = False) and (KeyR2 = False) then begin
                            Auto_f := False;
                            Move_f := False;
                            //向きを戻す
                            case Pos of
                                2:begin
                                    Muki2 := Shita;
                                end;
                                3:begin
                                    Muki2 := Ue;
                                end;
                                4:begin
                                    if i2 = 0 then begin
                                        Muki := Hidari;
                                    end else begin
                                        Muki := Migi;
                                    end;
                                end;
                            end;
                        end else begin
                            Move_f := True;
                        end;
                        Dash_f := None;
                    end;
                end;
            end;
        //オートフラグ２（定位置に戻る）がたっているとき
        end else if Auto_f2 = True then begin
            Dash_f := None;
            case Pos of
                2:begin
                    if i2 = 0 then begin
                        if X < 22400 then begin
                            KeyR2 := True;
                            Muki := Migi;
                            Muki2 := None;
                        end else if X > 38400 then begin
                            KeyL2 := True;
                            Muki := Hidari;
                            Muki2 := None;
                        end;
                    end else if i2 = 1 then begin
                        if X < 4800 then begin
                            KeyR2 := True;
                            Muki := Migi;
                            Muki2 := None;
                        end else if X > 20800 then begin
                            KeyL2 := True;
                            Muki := Hidari;
                            Muki2 := None;
                        end;
                    end;
                    if Z > 10000+100 then begin
                        KeyD2 := True;
                        Muki2 := Shita;
                    end else if Z < 10000-100 then begin
                        KeyU2 := True;
                        Muki2 := Ue;
                    end else begin
                        Z := 10000;
                    end;
                end;
                3:begin
                    if i2 = 0 then begin
                        if X < 22400 then begin
                            KeyR2 := True;
                            Muki := Migi;
                            Muki2 := None;
                        end else if X > 40000 then begin
                            KeyL2 := True;
                            Muki := Hidari;
                            Muki2 := None;
                        end;
                    end else if i2 = 1 then begin
                        if X < 3200 then begin
                            KeyR2 := True;
                            Muki := Migi;
                            Muki2 := None;
                        end else if X > 20800 then begin
                            KeyL2 := True;
                            Muki := Hidari;
                            Muki2 := None;
                        end;
                    end;
                    if Z > 800+100 then begin
                        KeyD2 := True;
                        Muki2 := Shita;
                    end else if Z < 800-100 then begin
                        KeyU2 := True;
                        Muki2 := Ue;
                    end else begin
                        Z := 800;
                    end;
                end;
                4:begin
                    if i2 = 0 then begin
                        if X < 41600 - (((Z-2000)* 2) div 9) - 100 then begin
                            KeyR2 := True;
                            Muki := Migi;
                            Muki2 := None;
                        end else if X > 41600 - (((Z-2000)* 2) div 9) + 100 then begin
                            KeyL2 := True;
                            Muki := Hidari;
                            Muki2 := None;
                        end else begin
                            X := 41600 - (((Z-2000)* 2) div 9);
                        end;
                    end else if i2 = 1 then begin
                        if X < 1600 + (((Z-2000)* 2) div 9) - 100 then begin
                            KeyR2 := True;
                            Muki := Migi;
                            Muki2 := None;
                        end else if X > 1600 + (((Z-2000)* 2) div 9) + 100 then begin
                            KeyL2 := True;
                            Muki := Hidari;
                            Muki2 := None;
                        end else begin
                            X := 1600 + (((Z-2000)* 2) div 9);
                        end;
                    end;
                    if Z > 9200 then begin
                        KeyD2 := True;
                        Muki2 := Shita;
                    end else if Z < 2000 then begin
                        KeyU2 := True;
                        Muki2 := Ue;
                    end;
                end;
            end;

            if (KeyU2 = False) and (KeyD2 = False)
            and (KeyL2 = False) and (KeyR2 = False) then begin
                Auto_f2 := False;
                Move_f := False;
                //向きを戻す
                case Pos of
                    2:begin
                        Muki2 := Shita;
                    end;
                    3:begin
                        Muki2 := Ue;
                    end;
                    4:begin
                        if i2 = 0 then begin
                            Muki := Hidari;
                        end else begin
                            Muki := Migi;
                        end;
                    end;
                end;
            end else begin
                Move_f := True;
            end;
            
        end;
    end;
end;
//キーから動作を判定//****************************************************************************//
procedure DBKeyInput;
var
    i         : integer;
    i2        : integer;
    i3        : integer;
    OnChar    : array[0..3] of integer;
    OnChar_f  : Boolean;
    OnChar2_f : Boolean;//fmi
    OnCharNo  : integer;
    OnItem    : array[0..3] of integer;
    OnItem_f  : Boolean;
    OnItemNo  : integer;
    DistX     : integer;
    DistZ     : integer;
    DistY     : integer;
    Outside   : integer;
    Inside    : integer;
    BallDist  : array[0..3] of integer;
    NearDist  : integer;
    NearPNo   : integer;

begin

    for i2 := 0 to 1 do begin
        for i := 0 to 5 do begin
            with P[i2].DBC[i] do begin
                if Dead_f = False then begin
                    KeyU := False;
                    KeyD := False;
                    KeyL := False;
                    KeyR := False;
                    KeyP := False;
                    KeyK := False;
                    KeyJ := False;
                    KeyU2:= False;
                    KeyD2:= False;
                    KeyL2:= False;
                    KeyR2:= False;
                    KeyP2:= False;
                    KeyK2:= False;
                    KeyJ2:= False;
                    Move_f := False;
                    TwoHit:= None;

                    If Ball_f = True then begin
                        P[i2].PNo := i;
                    end;
                end;
            end;

        end;

    end;

    for i2 := 0 to 1 do begin

        for i3 := 0 to 2 do begin
            if (P[i2].DBC[i3].Dam_f = None)
            and (P[i2].DBC[i3].Groggy_c = 0)
            and (P[i2].DBC[i3].Dead_f = False) then begin
                BallDist[i3] := Trunc(Hypot((P[i2].DBC[i3].X-Ball.X),(P[i2].DBC[i3].Z-Ball.Z)));
            end else begin
                BallDist[i3] := 100000;
            end;
        end;
        NearDist := BallDist[0];
        NearPNo  := 0;
        for i3 := 1 to 2 do begin
            if BallDist[i3] < NearDist then begin
                NearDist := BallDist[i3];
                NearPNo  := i3;
            end;
        end;
        //カーソルキャラが死んだ瞬間に他のキャラに変更
        if Not((P[i2].DBC[P[i2].PNo].Dam_f = None)
        and (P[i2].DBC[P[i2].PNo].Groggy_c = 0)
        and (P[i2].DBC[P[i2].PNo].Dead_f = False)) then begin
        //If P[i2].DBC[P[i2].PNo].Dead_f = True then begin
            //カーソルが変わった場合ダッシュフラグ消す
            if P[i2].PNo <> NearPNo then begin
                P[i2].PNo := NearPNo;
                P[i2].DBC[NearPNo].Dash_f := None;
            end;
        end;

        for i := 0 to 5 do begin
            with P[i2].DBC[i] do begin
                if (Dead_f = False) and (Dam_f = None) then begin

                    //ボール拾い
                    if (Ball.Motion = BFree) then begin
                        if i2 = 0 then begin
                            case Pos of
                                1:begin
                                    if (Not((P[i2].DBC[P[i2].PNo].Dam_f = None)
                                    and (P[i2].DBC[P[i2].PNo].Groggy_c = 0)
                                    and (P[i2].DBC[P[i2].PNo].Dead_f = False)))
                                    or (P[i2].PNo > 2) then begin
                                    //if  or (P[i2].DBC[P[i2].PNo].Dam_f <> None) then begin
                                        //カーソルが変わった場合ダッシュフラグ消す
                                        if P[i2].PNo <> NearPNo then begin
                                            P[i2].PNo := NearPNo;
                                            P[i2].DBC[NearPNo].Dash_f := None;
                                        end;
                                    end;
                                end;
                                2:begin
                                    if (Ball.X >= 21600) and (Ball.Z > 9200) then begin
                                        Auto_f := True;
                                    end else begin
                                        Auto_f := False;
                                        Auto_f2 := True;
                                    end;
                                end;
                                3:begin
                                    if (Ball.X >= 21600) and (Ball.Z < 2000) then begin
                                        Auto_f := True;
                                    end else begin
                                        Auto_f := False;
                                        Auto_f2 := True;
                                    end;
                                end;
                                4:begin
                                    if (Ball.Z < 9200) and (Ball.Z > 2000)
                                    and (Ball.X > (43200-4000) - (((Ball.Z-2000)* 2) div 9)) then begin
                                        Auto_f := True;
                                    end else begin
                                        Auto_f := False;
                                        Auto_f2 := True;
                                    end;
                                end;
                            end;
                        end else if i2 = 1 then begin
                            case Pos of
                                1:begin
                                    if (Not((P[i2].DBC[P[i2].PNo].Dam_f = None)
                                    and (P[i2].DBC[P[i2].PNo].Groggy_c = 0)
                                    and (P[i2].DBC[P[i2].PNo].Dead_f = False)))
                                    or (P[i2].PNo > 2) then begin
                                    //if (P[i2].PNo > 2) or (P[i2].DBC[P[i2].PNo].Dam_f <> None) then begin
                                        //カーソルが変わった場合ダッシュフラグ消す
                                        if P[i2].PNo <> NearPNo then begin
                                            P[i2].PNo := NearPNo;
                                            P[i2].DBC[NearPNo].Dash_f := None;
                                        end;
                                    end;
                                end;
                                2:begin
                                    if (Ball.X <= 21600) and (Ball.Z > 9200) then begin
                                        Auto_f := True;
                                    end else begin
                                        Auto_f := False;
                                        Auto_f2 := True;
                                    end;
                                end;
                                3:begin
                                    if (Ball.X <= 21600) and (Ball.Z < 2000) then begin
                                        Auto_f := True;
                                    end else begin
                                        Auto_f := False;
                                        Auto_f2 := True;
                                    end;
                                end;
                                4:begin
                                    if (Ball.Z < 9200) and (Ball.Z > 2000)
                                    and (Ball.X < 4000 + (((Ball.Z-2000)* 2) div 9)) then begin
                                        Auto_f := True;
                                    end else begin
                                        Auto_f := False;
                                        Auto_f2 := True;
                                    end;
                                end;
                            end;
                        end;
                    //ボール拾い
                    end else if (Ball.Motion = BBound) then begin
                        if i2 = 0 then begin
                            case Pos of
                                1:begin
                                    if (Not((P[i2].DBC[P[i2].PNo].Dam_f = None)
                                    and (P[i2].DBC[P[i2].PNo].Groggy_c = 0)
                                    and (P[i2].DBC[P[i2].PNo].Dead_f = False)))
                                    or (P[i2].PNo > 2) then begin
                                    //if (P[i2].PNo > 2) or (P[i2].DBC[P[i2].PNo].Dam_f <> None) then begin
                                        //カーソルが変わった場合ダッシュフラグ消す
                                        if P[i2].PNo <> NearPNo then begin
                                            P[i2].PNo := NearPNo;
                                            P[i2].DBC[NearPNo].Dash_f := None;
                                        end;
                                    end;
                                end;
                                2:begin
                                    if (Ball.X > 21600) and (Ball.Z > 9600) then begin
                                        Auto_f := True;
                                    end else begin
                                        Auto_f := False;
                                        Auto_f2 := True;
                                    end;
                                end;
                                3:begin
                                    if (Ball.X > 21600) and (Ball.Z < 1600) then begin
                                        Auto_f := True;
                                    end else begin
                                        Auto_f := False;
                                        Auto_f2 := True;
                                    end;
                                end;
                                4:begin
                                    if (Ball.Z < 9600) and (Ball.Z > 1600)
                                    and (Ball.X > (43200-3200) - (((Ball.Z-2000)* 2) div 9)) then begin
                                        Auto_f := True;
                                    end else begin
                                        Auto_f := False;
                                        Auto_f2 := True;
                                    end;
                                end;
                            end;
                        end else if i2 = 1 then begin
                            case Pos of
                                1:begin
                                    if (Not((P[i2].DBC[P[i2].PNo].Dam_f = None)
                                    and (P[i2].DBC[P[i2].PNo].Groggy_c = 0)
                                    and (P[i2].DBC[P[i2].PNo].Dead_f = False)))
                                    or (P[i2].PNo > 2) then begin
                                    //if (P[i2].PNo > 2) or (P[i2].DBC[P[i2].PNo].Dam_f <> None) then begin
                                        //カーソルが変わった場合ダッシュフラグ消す
                                        if P[i2].PNo <> NearPNo then begin
                                            P[i2].PNo := NearPNo;
                                            P[i2].DBC[NearPNo].Dash_f := None;
                                        end;
                                    end;
                                end;
                                2:begin
                                    if (Ball.X <= 21600) and (Ball.Z > 9600) then begin
                                        Auto_f := True;
                                    end else begin
                                        Auto_f := False;
                                        Auto_f2 := True;
                                    end;
                                end;
                                3:begin
                                    if (Ball.X <= 21600) and (Ball.Z < 1600) then begin
                                        Auto_f := True;
                                    end else begin
                                        Auto_f := False;
                                        Auto_f2 := True;
                                    end;
                                end;
                                4:begin
                                    if (Ball.Z < 9600) and (Ball.Z > 1600)
                                    and (Ball.X < 3200 + (((Ball.Z-2000)* 2) div 9)) then begin
                                        Auto_f := True;
                                    end else begin
                                        Auto_f := False;
                                        Auto_f2 := True;
                                    end;
                                end;
                            end;
                        end;
                    end else begin

                        //敵がボールを持った瞬間のカーソルキャラ変更
                        if (Ball.Motion = BHold) and (P[i2].PNo > 2)
                        and (Ball.HoldChar div 10 <> i2) then begin
                            //カーソルが変わった場合ダッシュフラグ消す
                            if P[i2].PNo <> NearPNo then begin
                                P[i2].PNo := NearPNo;
                                P[i2].DBC[NearPNo].Dash_f := None;
                            end;
                        end;

                        //帰還
                        case Pos of
                            2:begin
                                if i2 = 0 then begin
                                    if X < 22400 then begin
                                        Auto_f2 := True;
                                    end else if X > 38400 then begin
                                        Auto_f2 := True;
                                    end;
                                end else if i2 = 1 then begin
                                    if X < 4800 then begin
                                        Auto_f2 := True;
                                    end else if X > 20800 then begin
                                        Auto_f2 := True;
                                    end;
                                end;
                                if Z > 10000+100 then begin
                                    Auto_f2 := True;
                                end else if Z < 10000-100 then begin
                                    Auto_f2 := True;
                                end else begin
                                    Z := 10000;
                                end;
                            end;
                            3:begin
                                if i2 = 0 then begin
                                    if X < 22400 then begin
                                        Auto_f2 := True;
                                    end else if X > 40000 then begin
                                        Auto_f2 := True;
                                    end;
                                end else if i2 = 1 then begin
                                    if X < 3200 then begin
                                        Auto_f2 := True;
                                    end else if X > 20800 then begin
                                        Auto_f2 := True;
                                    end;
                                end;
                                if Z > 800+100 then begin
                                    Auto_f2 := True;
                                end else if Z < 800-100 then begin
                                    Auto_f2 := True;
                                end else begin
                                    Z := 800;
                                end;
                            end;
                            4:begin
                                if i2 = 0 then begin
                                    if X < 41600 - (((Z-2000)* 2) div 9) - 100 then begin
                                        Auto_f2 := True;
                                    end else if X > 41600 - (((Z-2000)* 2) div 9) + 100 then begin
                                        Auto_f2 := True;
                                    end else begin
                                        X := 41600 - (((Z-2000)* 2) div 9);
                                    end;
                                end else if i2 = 1 then begin
                                    if X < 1600 + (((Z-2000)* 2) div 9) - 100 then begin
                                        Auto_f2 := True;
                                    end else if X > 1600 + (((Z-2000)* 2) div 9) + 100 then begin
                                        Auto_f2 := True;
                                    end else begin
                                        X := 1600 + (((Z-2000)* 2) div 9);
                                    end;
                                end;
                                if Z > 9200 then begin
                                    Auto_f2 := True;
                                end else if Z < 2000 then begin
                                    Auto_f2 := True;
                                end;
                            end;
                        end;
                    end;

                    if (Auto_f = False) and (Auto_f2 = False)
                    and (Groggy_c = 0) then begin


                        if (CPU_f = True) and (i2 = 1) then begin

                            If (NotKey_f = False) and (Act_f = None)
                            and (Motion <> SLP) and (Motion <> SLP2) then begin

                                If Dash_f = None then Clay_c := 0;

                                //CPU
                                CPUSet(i,i2,dNo div 10);

                                //上でダッシュ命令が出た直後
                                if (Dash_f <> None) and (Clay_c = 0) then begin
                                    If Stage = 7 then begin
                                        Clay_c := 10;
                                    end else begin
                                        Clay_c := 100;
                                    end;
                                end;
                            end;

                            //しゃがみ続ける
                            if (Ball.Motion = BShoot)
                            and (X + 4800 > Ball.X) and (X - 4800 < Ball.X)
                            and (Z + 3200 > Ball.Z) and (Z - 3200 < Ball.Z)
                            and (Act_f = Crm) and (Act_c > 6)then begin

                                Act_c := 6;//しゃがみ続ける

                            end;

                        end else begin
                             //操作可能キャラ
                            if P[i2].PNo = i then begin
                                with P[i2] do begin
                                    DBC[i].KeyU := ADI.DI[i2].CheckCrs(cU);
                                    DBC[i].KeyD := ADI.DI[i2].CheckCrs(cD);
                                    DBC[i].KeyL := ADI.DI[i2].CheckCrs(cL);
                                    DBC[i].KeyR := ADI.DI[i2].CheckCrs(cR);
                                    DBC[i].KeyP := ADI.DI[i2].CheckBtn(bA);
                                    DBC[i].KeyK := ADI.DI[i2].CheckBtn(bB);
                                    DBC[i].KeyJ := ADI.DI[i2].CheckJump;
                                    DBC[i].KeyU2:= ADI.DI[i2].CheckCrs2(cU);
                                    DBC[i].KeyD2:= ADI.DI[i2].CheckCrs2(cD);
                                    DBC[i].KeyL2:= ADI.DI[i2].CheckCrs2(cL);
                                    DBC[i].KeyR2:= ADI.DI[i2].CheckCrs2(cR);
                                    DBC[i].KeyP2:= ADI.DI[i2].CheckBtn2(bA);
                                    DBC[i].KeyK2:= ADI.DI[i2].CheckBtn2(bB);
                                    DBC[i].KeyJ2:= ADI.DI[i2].CheckJump2;
                                    if (ADI.DI[i2].DHKey = dL) then begin
                                        DBC[i].TwoHit:= Hidari;
                                    end else if (ADI.DI[i2].DHKey = dR) then begin
                                        DBC[i].TwoHit:= Migi;
                                    end else begin
                                        DBC[i].TwoHit:= 0;
                                    end;
                                end;
                                //オート追っかけで外野がダッシュして拾ったとき
                                if Pos <> 1 then Dash_f := None;

                                If (NotKey_f = False) and (Dam_f = None)
                                and (Motion <> SLP) and (Motion <> SLP2)
                                and (Act_f = None) then begin

                                    case Jump_f of
                                        None:begin
                                            If (Dash_f = None) and (Act_f = None) and (Pos = 1) then begin
                                                If TwoHit = Hidari then begin
                                                    Dash_f := Hidari;
                                                    TwoHit := None;
                                                    Muki := Hidari;
                                                    Muki2 := None;
                                                    If Stage = 7 then begin
                                                        Clay_c := 10;
                                                    end else begin
                                                        Clay_c := 100;
                                                    end;
                                                    mNo_c := 0;
                                                end else if TwoHit = Migi then begin
                                                    Dash_f := Migi;
                                                    TwoHit := None;
                                                    Muki := Migi;
                                                    Muki2 := None;
                                                    If Stage = 7 then begin
                                                        Clay_c := 10;
                                                    end else begin
                                                        Clay_c := 100;
                                                    end;
                                                    mNo_c := 0;
                                                end;
                                            end;
                                            TwoHit := None;
                                            //左右
                                            if Pos <> 4 then begin
                                                if ((KeyL2 = True) and (KeyR2 = True))
                                                or ((KeyL2 = False) and (KeyR2 = False)) then begin

                                                end else If (KeyL2 = True) and (Act_f = None) and (Dash_f <> Hidari) then begin
                                                    If (Dash_f = Migi) then begin  //スリップ
                                                        SetSLP(i,i2);
                                                    end Else begin //左に歩く
                                                        Move_f := True;
                                                        Dash_f := None;
                                                        Muki := Hidari;
                                                    end;
                                                end else if (KeyR2 = True) and (Act_f = None) and (Dash_f <> Migi) then begin
                                                    If (Dash_f = Hidari) then begin
                                                        SetSLP(i,i2);
                                                    end Else begin
                                                        Move_f := True;
                                                        Dash_f := None;
                                                        Muki := Migi;
                                                    end;
                                                end;
                                            end else begin
                                                if (i2 = 0) then begin
                                                    Muki := Hidari;
                                                    If (KeyL2 = True) and (Act_f = None) then begin
                                                        Muki2 := None;
                                                    end;
                                                end else begin
                                                    Muki := Migi;
                                                    if (KeyR2 = True) and (Act_f = None) then begin
                                                        Muki2 := None;
                                                    end;
                                                end;
                                            end;
                                            //上下
                                            if (Pos <> 2) and (Pos <> 3) then begin
                                                if ((KeyU2 = True) and (KeyD2 = True))
                                                or ((KeyU2 = False) and (KeyD2 = False)) then begin

                                                end else If (KeyU2 = True) and (Act_f = None) then begin
                                                    Move_f := True;
                                                    Muki2 := Ue;
                                                    if Slip_f <> None then Slip_f2:= Ue;
                                                end else If (KeyD2 = True) and (Act_f = None) then begin
                                                    Move_f := True;
                                                    Muki2 := Shita;
                                                    if Slip_f <> None then Slip_f2:= Shita;
                                                end;
                                            end else if (Pos = 2) then begin
                                                If (KeyD2 = True) and (Act_f = None) then begin
                                                    Muki2 := Shita;
                                                end;
                                            end else if (Pos = 3) then begin
                                                If (KeyU2 = True) and (Act_f = None) then begin
                                                    Muki2 := Ue;
                                                end;
                                            end;

                                            //ジャンプ
                                            If (Act_f = None) then begin

                                                If (KeyJ = True) then begin
                                                    Jump_f := J1;
                                                    Jump_c := 0;
                                                    if (Dash_f <> None) then begin
                                                        JMuki := Dash_f;
                                                        JMuki2:= None;
                                                    end else begin
                                                        if ((KeyL2 = True) and (KeyR2 = True))
                                                        or ((KeyL2 = False) and (KeyR2 = False))
                                                        or (Pos <> 1) then begin
                                                            JMuki := None;
                                                        end else If (KeyL2 = True) then begin
                                                            JMuki := Hidari;
                                                        end else if (KeyR2 = True) then begin
                                                            JMuki := Migi;
                                                        end;
                                                        JMuki2 := None;
                                                        if ((KeyU2 = True) and (KeyD2 = True))
                                                        or ((KeyU2 = False) and (KeyD2 = False))
                                                        or (Pos <> 1) then begin
                                                            JMuki2 := None;
                                                        end else If (KeyU2 = True) then begin
                                                            JMuki2 := Ue;
                                                        end else If (KeyD2 = True) then begin
                                                            JMuki2 := Shita;
                                                        end;
                                                    end;

                                                end else begin
                                                    //持たず
                                                    If (Ball_f = False) then begin
                                                        //常に拾う
                                                        if Ball.Motion = BFree then begin
                                                            //しゃがみ
                                                            If (KeyP = True)
                                                            or (KeyK = True) then begin
                                                                //ダッシュの時
                                                                If Dash_f <> None then begin
                                                                    Act_f := TCr;
                                                                    Act_c := 0;
                                                                    Muki2 := None;
                                                                    SetSLP(i,i2);
                                                                end else begin
                                                                    if Move_f = True then Muki2 := None;
                                                                    Act_f := TCr;
                                                                    Act_c := 0;
                                                                end;
                                                            end;
                                                        //常にキャッチ
                                                        end else if (Ball.Motion = BBound) or (Ball.Motion = BPass) then begin
                                                            If (KeyP = True)
                                                            or (KeyK = True) then begin
                                                                //ダッシュの時
                                                                If Dash_f <> None then begin
                                                                    Act_f := Ca;
                                                                    Act_c := 0;
                                                                    Muki2 := None;
                                                                    SetSLP(i,i2);
                                                                end else begin
                                                                    if Move_f = True then Muki2 := None;
                                                                    Act_f := Ca;
                                                                    Act_c := 0;
                                                                end;
                                                            end;
                                                        //守備動作
                                                        end else begin
                                                            //しゃがみ
                                                            If KeyP = True then begin
                                                                //ダッシュの時
                                                                If Dash_f <> None then begin
                                                                    Act_f := Crm;
                                                                    Act_c := 0;
                                                                    Muki2 := None;
                                                                    SetSLP(i,i2);
                                                                end else begin
                                                                    if Move_f = True then Muki2 := None;
                                                                    Act_f := Crm;
                                                                    Act_c := 0;
                                                                end;
                                                            end;

                                                            //キャッチ
                                                            If KeyK = True then begin
                                                                //ダッシュの時
                                                                If Dash_f <> None then begin
                                                                    Act_f := Ca;
                                                                    Act_c := 0;
                                                                    Muki2 := None;
                                                                    SetSLP(i,i2);
                                                                end else begin
                                                                    if Move_f = True then Muki2 := None;
                                                                    Act_f := Ca;
                                                                    Act_c := 0;
                                                                end;
                                                            end;
                                                        end;
                                                    //ボール持ち
                                                    end else begin
                                                        //パス
                                                        If KeyP = True then begin
                                                            Act_f := Pa;
                                                            Act_c := 0;
                                                        end;
                                                        //シュート
                                                        If KeyK = True then begin
                                                            Act_f := Sh;
                                                            Act_c := 0;
                                                        end;
                                                    end;
                                                end;
                                            end;
                                        end;
                                        J2:begin
                                            if dY <= 300 then begin
                                                if Not ((i2 = 0) and (Pos = 4)) then begin
                                                    //右
                                                    If (KeyR2 = True) and (Act_f = None) then begin
                                                        Muki := Migi;
                                                        Muki2 := None;
                                                    end;
                                                end;
                                                if Not ((i2 = 1) and (Pos = 4)) then begin
                                                    //左
                                                    If (KeyL2 = True) and (Act_f = None) then begin
                                                        Muki := Hidari;
                                                        Muki2 := None;
                                                    end;
                                                end;
                                                if Pos <> 2 then begin
                                                    //上
                                                    If (KeyU2 = True) and (Act_f = None) then begin
                                                        Muki2 := Ue;
                                                    end;
                                                end;
                                                if Pos <> 3 then begin
                                                    //下
                                                    If (KeyD2 = True) and (Act_f = None) then begin
                                                        Muki2 := Shita;
                                                    end;
                                                end;
                                            end;

                                            If (Act_f = None) then begin
                                                //持たず
                                                If (Ball_f = False) then begin
                                                    //キャッチ
                                                    If KeyK = True then begin
                                                        Act_f := JCa;
                                                        Act_c := 0;
                                                    end;
                                                //ボール持ち
                                                end else begin
                                                    //パス
                                                    If KeyP = True then begin
                                                        Act_f := JPa;
                                                        Act_c := 0;
                                                    end;
                                                    //シュート
                                                    If KeyK = True then begin
                                                        Act_f := JSh;
                                                        Act_c := 0;
                                                    end;
                                                end;
                                            end;
                                        end;
                                    end;
                                    //全ボタン押してなかった時
                                    If  (KeyU2 = False) and (KeyD2 = False)
                                    and (KeyR2 = False) and (KeyL2 = False)
                                    and (Dash_f = None) then begin
                                        Move_f := False;
                                    end;

                                end else if (KeyP2 = True) and (Act_f = Crm)
                                and (Act_c > 6) then begin

                                    Act_c := 6;//しゃがみ続ける

                                //キャンセルジャンプ
                                end else if (Act_f <> None) and (Jump_f = None)
                                and (Act_c < 3) then begin

                                    //ジャンプ
                                    If (KeyJ = True) then begin
                                        Jump_f := J1;
                                        Jump_c := 0;
                                        Motion := None;
                                        Act_f := None;
                                        Act_c := 0;

                                        if Dash_f <> None then begin
                                            JMuki := Dash_f;
                                            JMuki2:= None;
                                        end else if Slip_f <> None then begin
                                            Dash_f := Slip_f;
                                            JMuki := Slip_f;
                                            JMuki2:= None;
                                        end else begin
                                            if ((KeyL2 = True) and (KeyR2 = True))
                                            or ((KeyL2 = False) and (KeyR2 = False)) then begin
                                                JMuki := None;
                                            end else If (KeyL2 = True) then begin
                                                JMuki := Hidari;
                                            end else if (KeyR2 = True) then begin
                                                JMuki := Migi;
                                            end;
                                            JMuki2 := None;
                                            if ((KeyU2 = True) and (KeyD2 = True))
                                            or ((KeyU2 = False) and (KeyD2 = False)) then begin
                                                JMuki2 := None;
                                            end else If (KeyU2 = True) then begin
                                                JMuki2 := Ue;
                                            end else If (KeyD2 = True) then begin
                                                JMuki2 := Shita;
                                            end;
                                        end;
                                    end;
                                end;
                            //カーソル付いてないキャラ
                            end else begin

                                //if (Pos <> 1) then Dash_f := None;

                                If Dash_f = None then Clay_c := 0;

                                If (NotKey_f = False) and (Act_f = None)
                                and (Motion <> SLP) and (Motion <> SLP2) then begin

                                    DBNPC(i,i2);

                                end;

                                //上でダッシュ命令が出た直後
                                if (Dash_f <> None) and (Clay_c = 0) then begin
                                    If Stage = 7 then begin
                                        Clay_c := 10;
                                    end else begin
                                        Clay_c := 100;
                                    end;
                                end;
                                //しゃがみ続ける
                                if (Ball.Motion = BShoot)
                                and (X + 4800 > Ball.X) and (X - 4800 < Ball.X)
                                and (Z + 3200 > Ball.Z) and (Z - 3200 < Ball.Z)
                                and (Act_f = Crm) and (Act_c > 6)then begin

                                    Act_c := 6;//しゃがみ続ける

                                end;
                            end;
                        end;

                    end else begin

                        If (NotKey_f = False) and (Act_f = None)
                        and (Motion <> SLP) and (Motion <> SLP2) then begin

                            If Dash_f = None then Clay_c := 0;

                            DBNPC(i,i2);

                            //上でダッシュ命令が出た直後
                            if (Dash_f <> None) and (Clay_c = 0) then begin
                                If Stage = 7 then begin
                                    Clay_c := 10;
                                end else begin
                                    Clay_c := 100;
                                end;
                            end;
                        end;
                        //しゃがみ続ける
                        if (Ball.Motion = BShoot)
                        and (X + 4800 > Ball.X) and (X - 4800 < Ball.X)
                        and (Z + 3200 > Ball.Z) and (Z - 3200 < Ball.Z)
                        and (Act_f = Crm) and (Act_c > 6)then begin

                            Act_c := 6;//しゃがみ続ける

                        end;
                    end;
                end;
            end;
        end;

        P[i2].TwoHit := None;

    end;

end;

//****************************************************************************//
procedure DBMotionType;
var
    i :integer;
    i2:integer;
begin

    for i2 := 0 to 1 do begin
        for i := 0 to 5 do begin
            //状態の判定
            with P[i2].DBC[i] do begin
            if Dead_f = False then begin
                If Dam_f <> None then begin

                    Motion := DAM;
                    FormChange_f := True;
                end else If Jump_f <> None then begin

                    Motion := JJJ;  //ジャンプ

                end else if Motion = SLP then begin
                end else if Motion = SLP2 then begin
                end else begin

                    if Dash_f <> None then begin

                        Motion := DDD; //ダッシュ

                    end else begin
                        If Move_f <> False then begin

                            Motion := WWW; //歩き

                        end else begin

                            Motion := None; //立ち

                        end;
                    end;
                end;
            end;
        end;
        end;
    end;
end;

//****************************************************************************//
procedure DBMove;
var
    i : integer;
    i2 : integer;
    i3 : integer;
    sltgX  : array [0..2] of integer;
    sltgZ  : array [0..2] of integer;
    sltgXZ : array [0..2] of Real;
    sltg_f : array [0..2] of boolean;
    sltgA  : array [0..2] of integer;
    sltgXZ2 :Real;
    LOMuki:integer;//ラインオーバー時の手放す方向
    LOMuki2:integer;
    ENo:integer;
const
    baseSp      = 1; //基本速度
    baseSp2     = 2; //基本速度
    AniW_D      = 4;
    AniW_W      = 8;
    WalkWait    = 1;
    WalkWait2   = 2;
    WalkWait3   = 3;
    WalkWait4   = 4;
    StopTime    = 300;
    TakingTime  = 5;
    TakingTime_D= 6;
    procedure ptgSet(ttgNo:integer);
    var
        i3:integer;
        i4:integer;
        SortDt:array[0..2] of SortData;//内野３人
        TempSDt:SortData;
    begin
        with P[i2].DBC[i] do begin
            //内野へのパス
            if ttgNo = 0 then begin
                for i3 := 0 to 2 do begin
                    SortDt[i3].BaseNo := i3;
                    SortDt[i3].Dt1 := P[i2].DBC[i3].X;
                    //捕れない状態
                    if (P[i2].DBC[i3].Dead_f = True)
                    or (P[i2].DBC[i3].Dam_f <> None)
                    or (P[i2].DBC[i3].Groggy_c <> 0) then begin
                        SortDt[i3].Fl1 := True;
                    end else begin
                        SortDt[i3].Fl1 := False;
                    end;
                    //SortDt[i3].Fl1 := P[i2].DBC[i3].Dead_f;
                end;
                if i2 = 0 then begin
                    //ソート大きい順
                    for i4 := 0 to 1 do begin
                        for i3 := 0 to 1 do begin
                            if SortDt[i3].Dt1 < SortDt[i3+1].Dt1 then begin
                                TempSDt := SortDt[i3];
                                SortDt[i3] := SortDt[i3+1];
                                SortDt[i3+1] := TempSDt;
                            end;
                        end;
                    end;
                end else begin
                    //ソート小さい順
                    for i4 := 0 to 1 do begin
                        for i3 := 0 to 1 do begin
                            if SortDt[i3].Dt1 > SortDt[i3+1].Dt1 then begin
                                TempSDt := SortDt[i3];
                                SortDt[i3] := SortDt[i3+1];
                                SortDt[i3+1] := TempSDt;
                            end;
                        end;
                    end;                
                end;
                //ソートdead_f
                for i4 := 0 to 1 do begin
                    for i3 := 0 to 1 do begin
                        if (SortDt[i3].Fl1 = True) then begin
                            TempSDt := SortDt[i3];
                            SortDt[i3] := SortDt[i3+1];
                            SortDt[i3+1] := TempSDt;
                        end;
                    end;
                end;

                ttgNo := SortDt[0].BaseNo;

            //内野同士のパス
            end else if ttgNo = 1 then begin
                for i3 := 0 to 2 do begin
                    ttgNo := (i + i3 + 1) mod 3;
                    if i3 = 2 then begin
                        ttgNo := 5;
                    end else begin
                        if (P[i2].DBC[ttgNo].Dead_f = False)
                        and (P[i2].DBC[ttgNo].Dam_f = None)
                        and (P[i2].DBC[ttgNo].Groggy_c = 0) then begin
                            Break;
                        end;
                    end;
                end;

            end;

            //パスターゲットが変わったらパス待ちアニメーションカウンタをリセット
            if (ptgNo <> ttgNo) then begin
                Ball.ptg_c := AniW_W * 6;
            end;
            
            ptgNo := ttgNo;
            ptgX := P[i2].DBC[ttgNo].X;
            ptgY := P[i2].DBC[ttgNo].Y;
            ptgZ := P[i2].DBC[ttgNo].Z;
        end;
    end;

    //ラインオーバーでボールを手放す処理
    procedure LineOver();
    begin
        with P[i2].DBC[i] do begin
            Act_f := None;
            Act_c := 0;
            Ball_f := False;
            Ball.Motion := BBound;
            Ball.X  := X;
            Ball.Y  := Y + 1800;
            Ball.Z  := Z;
            Ball.dX  := -(AutoMuki * 100);
            Ball.dY  := 200;
            Ball.dZ  := -(AutoMuki2 * 100);
        end;
    end;

begin
    for i2 := 0 to 1 do begin
        if i2 = 0 then begin
            ENo := 1;
        end else begin
            ENo := 0;
        end;
        For i := 0 To 5 do begin
            with P[i2].DBC[i] do begin
                if Dead_f = False then begin
                    case Motion of
                        DAM:begin

                            Damage(i,i2);

                        end;
                        JJJ:begin
                            //敵コート着地瞬間にジャンプしようとしたときのキャンセル
                            if Jump_f = J1 then begin
                                if Pos = 1 then begin
                                    if i2 = 0 then begin
                                        if X < 3500 + (((Z-2000)* 2) div 9) then begin
                                            Auto_f := True;
                                            AutoMuki := Migi;
                                            AutoMuki2 := None;
                                        end else if X > 20800 then begin
                                            Auto_f := True;
                                            AutoMuki := Hidari;
                                            AutoMuki2 := None;
                                        end;
                                    end else if i2 = 1 then begin
                                        if X > 43200-3500 - (((Z-2000)* 2) div 9) then begin
                                            Auto_f := True;
                                            AutoMuki := Hidari;
                                            AutoMuki2 := None;
                                        end else if X < 22400 then begin
                                            Auto_f := True;
                                            AutoMuki := Migi;
                                            AutoMuki2 := None;
                                        end;
                                    end;
                                    if Z > 9200 then begin
                                        Auto_f := True;
                                        AutoMuki2 := Shita;
                                        if i2 = 0 then begin
                                            if X < 12000 then begin
                                                AutoMuki := Migi;
                                                AutoMuki2 := None;
                                            end else begin
                                                AutoMuki := Hidari;
                                                AutoMuki2 := None;
                                            end;
                                        end else begin
                                            if X > 31200 then begin
                                                AutoMuki := Hidari;
                                                AutoMuki2 := None;
                                            end else begin
                                                AutoMuki := Migi;
                                                AutoMuki2 := None;
                                            end;
                                        end;
                                    end else if Z < 2000 then begin
                                        Auto_f := True;
                                        AutoMuki2 := Ue;
                                        if i2 = 0 then begin
                                            if X < 12000 then begin
                                                AutoMuki := Migi;
                                                AutoMuki2 := None;
                                            end else begin
                                                AutoMuki := Hidari;
                                                AutoMuki2 := None;
                                            end;
                                        end else begin
                                            if X > 31200 then begin
                                                AutoMuki := Hidari;
                                                AutoMuki2 := None;
                                            end else begin
                                                AutoMuki := Migi;
                                                AutoMuki2 := None;
                                            end;
                                        end;                              
                                    end;
                                    //ラインオーバーでボールを手放す
                                    if (Auto_f = True) then begin
                                        Jump_f := None;
                                        if (Ball_f = True) then begin
                                            LineOver;
                                        end;
                                    end;
                                end;
                            end;

                            Jumping(i,i2);
                        end;
                        SLP:begin//ダッシュ後のスリップ

                            //アイスランドステージのスリップ
                            if Stage <> 4 then begin
                                inc(Slip_c,10);
                            end else begin
                                if (GameLv = 2) and (i2 = 1) then begin
                                    inc(Slip_c,10);
                                end else begin
                                    inc(Slip_c,2);
                                end;
                            end;

                            dX := dX * 100 div Slip_c;
                            dZ := dZ * 100 div Slip_c;

                            X := X + dX;
                            //スリップによる上下オーバーラインの防止
                            if (dZ > 0) and ((Z + dZ) > 9200) then begin
                                Z := 9200;
                            end else if (dZ < 0) and ((Z + dZ) < 2000) then begin
                                Z := 2000;
                            end else begin
                                Z := Z + dZ;
                            end;

                            if ((Abs(dX) < 100) and (Abs(dZ) < 100)) then begin
                                Motion := None;
                                TwoHit := None;
                            end;
                        
                        end;
                        SLP2:begin //キャッチ後のスリップ

                            dX := dX * 100 div Slip_c;
                            dZ := dZ * 100 div Slip_c;
                            //アイスランドステージのスリップ(地上)
                            if (Stage = 4) and (Jump_f = None) then begin
                                //逆ブースト
                                If Boost < 10 then begin
                                    if Muki2 = None then begin
                                        if ((Muki = Migi) and (KeyR = True))
                                        or ((Muki = Hidari) and (KeyL = True)) then begin
                                            inc(Boost,2);
                                        end;
                                    end else if Muki2 = Ue then begin

                                        if (KeyU = True) then inc(Boost,2);

                                    end else if Muki2 = Shita then begin

                                        if (KeyD = True) then inc(Boost,2);

                                    end;
                                    if (CPU_f = True) and (i2 = 1) and (LvPer100(20)) then begin
                                        inc(Boost);
                                    end;
                                end;
                                inc(Slip_c,Boost);
                            end else begin
                                inc(Slip_c,15);
                            end;

                            X := X + dX;
                            Z := Z + dZ;

                            if ((Abs(dX) < 100) and (Abs(dZ) < 100)) then begin
                                Motion := None;
                                TwoHit := None;
                            end;

                        end;
                        DDD:begin
                            if Pos = 1 then begin
                                //オーバーライン
                                if i2 = 0 then begin
                                    if X < 4000 + (((Z-2000)* 2) div 9)-1600 then begin
                                        Auto_f := True;
                                        AutoMuki := Migi;
                                        AutoMuki2 := None;
                                    end else if X > 20800+1600 then begin
                                        Auto_f := True;
                                        AutoMuki := Hidari;
                                        AutoMuki2 := None;
                                    end;
                                    if Z > 9200 then begin
                                        Auto_f := True;
                                        AutoMuki2 := Shita;
                                    end else if Z < 2000 then begin
                                        Auto_f := True;
                                        AutoMuki2 := Ue;
                                    end;
                                end else if i2 = 1 then begin
                                    if X < 22400-1600 then begin
                                        Auto_f := True;
                                        AutoMuki := Migi;
                                        AutoMuki2 := None;
                                    end else if X > 43200-4000 - (((Z-2000)* 2) div 9)+1600 then begin
                                        Auto_f := True;
                                        AutoMuki := Hidari;
                                        AutoMuki2 := None;
                                    end;
                                    if Z > 9200 then begin
                                        Auto_f := True;
                                        AutoMuki2 := Shita;
                                    end else if Z < 2000 then begin
                                        Auto_f := True;
                                        AutoMuki2 := Ue;
                                    end;
                                end;
                                //ラインオーバーでボールを手放す
                                if (Ball_f = True) and (Auto_f = True) then begin
                                    LineOver;
                                end;
                            end;
                            dX := 0;
                            dY := 0;
                            dZ := 0;

                            //上下
                            If (KeyU2 = True) and (KeyD2 = True) then begin
                                Move_f := False;
                            end else if (KeyU2 = True) and (Act_f = None) then begin
                                dZ :=  (GC.DBMOV.DSBX-Clay_c+ dSp*GC.DBMOV.DSSR) * GC.DBMOV.DSZRATIO div 100 * Clay_c div 100;
                                //dZ := (222-Clay_c+dSp*7) div 4 * Clay_c div 100;
                            end else if (KeyD2 = True) and (Act_f = None) then begin
                                dZ := -(GC.DBMOV.DSBX-Clay_c+ dSp*GC.DBMOV.DSSR) * GC.DBMOV.DSZRATIO div 100 * Clay_c div 100;
                            end;


                            //左右
                            if (Dash_f = Migi) then begin
                                //向き補正（ダッシュパスの時はのぞく）
                                if (Act_f = None) then Muki := Migi;
                                dX :=  (GC.DBMOV.DSBX+ dSp) * Clay_c div 100;
                            end else if (Dash_f = Hidari) then begin
                                if (Act_f = None) then Muki := Hidari;
                                dX := -(GC.DBMOV.DSBX+ dSp) * Clay_c div 100;
                            end;
                            
                            //アフリカコートの抵抗
                            if Clay_c < 100 then inc(Clay_c,3);

                            X := X + dX;
                            Y := Y + dY;
                            Z := Z + dZ;

                            if Pos = 1 then begin
                                if Auto_f = False then begin
                                    if Z > 9200 then Z := 9200;
                                    if Z < 2000 then Z := 2000;
                                end;
                            end;
                        end;
                        WWW:begin
                            if Pos = 1 then begin
                                if i2 = 0 then begin
                                    if X < 3500 + (((Z-2000)* 2) div 9) then begin
                                        Auto_f := True;
                                        AutoMuki := Migi;
                                        AutoMuki2 := None;
                                    end else if X > 20800 then begin
                                        Auto_f := True;
                                        AutoMuki := Hidari;
                                        AutoMuki2 := None;
                                    end;
                                    if Z > 9200 then begin
                                        Auto_f := True;
                                        AutoMuki2 := Shita;
                                    end else if Z < 2000 then begin
                                        Auto_f := True;
                                        AutoMuki2 := Ue;
                                    end;
                                end else if i2 = 1 then begin
                                    if X < 22400 then begin
                                        Auto_f := True;
                                        AutoMuki := Migi;
                                        AutoMuki2 := None;
                                    end else if X > 43200-3500 - (((Z-2000)* 2) div 9) then begin
                                        Auto_f := True;
                                        AutoMuki := Hidari;
                                        AutoMuki2 := None;
                                    end;
                                    if Z > 9200 then begin
                                        Auto_f := True;
                                        AutoMuki2 := Shita;
                                    end else if Z < 2000 then begin
                                        Auto_f := True;
                                        AutoMuki2 := Ue;
                                    end;
                                end;
                                //ラインオーバーでボールを手放す
                                if (Ball_f = True) and (Auto_f = True) then begin
                                    LineOver;
                                end;
                            end;
                            dX := 0;
                            dY := 0;
                            dZ := 0;
                            if ((Pos <> 2) and (Pos <> 3))
                            or (Auto_f = True) or (Auto_f2 = True) then begin
                                //上下
                                If (KeyU2 = True) and (KeyD2 = True) then begin
                                    Move_f := False;
                                end else if (KeyU2 = True) and (Act_f = None) then begin
                                    dZ := (GC.DBMOV.WKBZ + dSp*GC.DBMOV.WKSR);
                                end else if (KeyD2 = True) and (Act_f = None) then begin
                                    dZ := -(GC.DBMOV.WKBZ + dSp*GC.DBMOV.WKSR);
                                end;
                            end;
                            if (Pos <> 4) or (Auto_f = True) or (Auto_f2 = True) then begin
                                //左右
                                If (KeyR2 = True) and (KeyL2 = True) then begin
                                    Move_f := False;
                                end else if (KeyR2 = True) and (Act_f = None) then begin
                                    dX := (GC.DBMOV.WKBX + dSp*GC.DBMOV.WKSR);
                                end else if (KeyL2 = True) and (Act_f = None) then begin
                                    dX := -(GC.DBMOV.WKBX + dSp*GC.DBMOV.WKSR);
                                end;
                            end;
                            X := X + dX;
                            Y := Y + dY;
                            Z := Z + dZ;
                            //移動制限
                            if (Auto_f = False) and (Auto_f2 = False) then begin
                                if i2 = 0 then begin
                                    case Pos of
                                        1:begin
                                            if X < 3600 + (((Z-2000)* 2) div 9) then X := (3600 + (((Z-2000)* 2) div 9));
                                            if X > 20800 then X := 20800;
                                            if Z > 9200 then Z := 9200;
                                            if Z < 2000 then Z := 2000;
                                        end;
                                        2:begin
                                            if X < 22400 then X := 22400;
                                            if X > 38400 then X := 38400;
                                        end;
                                        3:begin
                                            if X < 22400 then X := 22400;
                                            if X > 40000 then X := 40000;
                                        end;
                                        4:begin
                                            if Z > 9200 then Z := 9200;
                                            if Z < 2000 then Z := 2000;
                                            X := 41600 - (((Z-2000)* 2) div 9);
                                        end;
                                    end;
                                end else if i2 = 1 then begin
                                    case Pos of
                                        1:begin
                                            if X > 43200-3600 - (((Z-2000)* 2) div 9) then begin
                                                X := 43200-3600 - (((Z-2000)* 2) div 9);
                                            end;
                                            if X < 22400 then X := 22400;
                                            if Z > 9200 then Z := 9200;
                                            if Z < 2000 then Z := 2000;
                                        end;
                                        2:begin
                                            if X > 20800 then X := 20800;
                                            if X < 4800 then X := 4800;
                                        end;
                                        3:begin
                                            if X > 20800 then X := 20800;
                                            if X < 3200 then X := 3200;
                                        end;
                                        4:begin
                                            if Z > 9200 then Z := 9200;
                                            if Z < 2000 then Z := 2000;
                                            X := 1600 + (((Z-2000)* 2) div 9);
                                        end;
                                    end;
                                end;
                            end;
                        end;
                        None:begin
                            dX := 0;
                            dY := 0;
                            dZ := 0;
                            Slip_f := None;
                            //X := X div 100 * 100;
                            //Y := Y div 100 * 100;
                            //Z := Z div 100 * 100;
                            //*/*
                            if Pos = 1 then begin
                                if i2 = 0 then begin
                                    if X < 3500 + (((Z-2000)* 2) div 9) then begin
                                        Auto_f := True;
                                        AutoMuki := Migi;
                                        AutoMuki2 := None;
                                    end else if X > 20800 then begin
                                        Auto_f := True;
                                        AutoMuki := Hidari;
                                        AutoMuki2 := None;
                                    end;
                                end else if i2 = 1 then begin
                                    if X > 43200-3500 - (((Z-2000)* 2) div 9) then begin
                                        Auto_f := True;
                                        AutoMuki := Hidari;
                                        AutoMuki2 := None;
                                    end else if X < 22400 then begin
                                        Auto_f := True;
                                        AutoMuki := Migi;
                                        AutoMuki2 := None;
                                    end;
                                end;
                                if Z > 9200 then begin
                                    Auto_f := True;
                                    AutoMuki2 := Shita;
                                    if i2 = 0 then begin
                                        if X < 12000 then begin
                                            AutoMuki := Migi;
                                            AutoMuki2 := None;
                                        end else begin
                                            AutoMuki := Hidari;
                                            AutoMuki2 := None;
                                        end;
                                    end else begin
                                        if X > 31200 then begin
                                            AutoMuki := Hidari;
                                            AutoMuki2 := None;
                                        end else begin
                                            AutoMuki := Migi;
                                            AutoMuki2 := None;
                                        end;
                                    end;
                                end else if Z < 2000 then begin
                                    Auto_f := True;
                                    AutoMuki2 := Ue;
                                    if i2 = 0 then begin
                                        if X < 12000 then begin
                                            AutoMuki := Migi;
                                            AutoMuki2 := None;
                                        end else begin
                                            AutoMuki := Hidari;
                                            AutoMuki2 := None;
                                        end;
                                    end else begin
                                        if X > 31200 then begin
                                            AutoMuki := Hidari;
                                            AutoMuki2 := None;
                                        end else begin
                                            AutoMuki := Migi;
                                            AutoMuki2 := None;
                                        end;
                                    end;                              
                                end;
                                //ラインオーバーでボールを手放す
                                if (Ball_f = True) and (Auto_f = True) then begin
                                    LineOver;
                                end;
                            end else begin
                                //上下外野は基本的に一定向き
                                {
                                if Pos = 2 then begin
                                    Muki2 := Shita;
                                end else if Pos = 3 then begin
                                    Muki2 := Ue;
                                end;
                                }
                            end;
                        end;
                    end;

                    //走り以外歩数リセット
                    if Motion <> DDD then Step_c := 0;

                    if Act_f = None then begin
                        case Motion of
                            DAM:begin

                            end;
                            SLP:begin
                                mNo := 100;
                                mNo_c := 0;
                            end;
                            SLP2:begin
                                mNo := 101;
                                RevMuki2(i,i2);
                            end;
                            DDD:begin //歩きのアニメーション
                                Muki2 := None;
                                Case mNo_c of
                                    AniW_D * 0:begin
                                        mNo := 304;
                                        SE(10);
                                        Inc(Step_c);
                                    end;
                                    AniW_D * 1:begin
                                        mNo := 305;
                                    end;
                                    AniW_D * 2:begin
                                        mNo := 306;
                                        SE(10);
                                        Inc(Step_c);
                                    end;
                                    AniW_D * 3:begin
                                        mNo := 307;
                                    end;
                                end;
                                inc(mNo_c);
                                If mNo_c >= (AniW_D * 4) then mNo_c := 0;
                            end;
                            WWW:begin //歩きのアニメーション
                                Case mNo_c of
                                    AniW_W * 0:begin
                                        mNo := 300;
                                        if (KeyU2 = False)
                                        and (KeyD2 = False) then Muki2 := None;
                                    end;
                                    AniW_W * 1:begin
                                        mNo := 301;
                                        if (KeyU2 = False)
                                        and (KeyD2 = False) then Muki2 := None;
                                    end;
                                    AniW_W * 2:begin
                                        mNo := 302;
                                        if (KeyU2 = False)
                                        and (KeyD2 = False) then Muki2 := None;
                                    end;
                                    AniW_W * 3:begin
                                        mNo := 303;
                                        if (KeyU2 = False)
                                        and (KeyD2 = False) then Muki2 := None;
                                    end;
                                end;
                                inc(mNo_c);
                                If mNo_c >= (AniW_W * 4) then mNo_c := 0;
                            end;
                            None:begin //止まっているとき
                                if Groggy_c = 0 then begin
                                    If Act_f = None then begin
                                        //パス待ちのアニメーション
                                        if (Ball.Motion = BHold)
                                        //and (P[i2].DBC[Ball.HoldChar mod 10].Act_f = None)
                                        and (i2 = Ball.HoldChar div 10)
                                        and (i = P[i2].DBC[Ball.HoldChar mod 10].ptgNo) then begin
                                            if Ball.ptg_c mod (AniW_W*2) < AniW_W then begin
                                                mNo := 100;
                                                RevMuki2(i,i2);
                                            end else begin
                                                mNo := 102;
                                                RevMuki2(i,i2);
                                            end;
                                            //カウンタ減少
                                            if (Ball.ptg_c > 0) then dec(Ball.ptg_c);
                                        end else begin
                                            mNo := 100;
                                            RevMuki2(i,i2);
                                        end;
                                        mNo_c := 0;
                                    end;
                                end else begin
                                    if Groggy_c mod 40 < 20 then begin
                                        mNo := 309;
                                    end else begin
                                        mNo := 310;
                                    end;
                                    Dec(Groggy_c);
                                end;
                            end;
                        end;
                    end else begin
                        //シュートモーション中も歩数カウント入る
                        if (Motion = DDD) and (Act_f = Sh) and (Act_c < 6) then begin
                            Muki2 := None;
                            Case mNo_c of
                                AniW_D * 0:begin
                                    SE(10);
                                    Inc(Step_c);
                                end;
                                AniW_D * 1:begin
                                end;
                                AniW_D * 2:begin
                                    SE(10);
                                    Inc(Step_c);
                                end;
                                AniW_D * 3:begin
                                end;
                            end;
                            inc(mNo_c);
                            If mNo_c >= (AniW_D * 4) then mNo_c := 0;
                        end;
                    end;


                    if Ball_f = True then begin
                        //シュートターゲット
                        if  (Ball.Motion = BHold)
                        and (i2 = (Ball.HoldChar div 10))
                        and (i = (Ball.HoldChar mod 10)) then begin
                            //敵内野全員との角度を取る
                            tgNo := 99;//タゲ無し
                            sltgXZ2 := 43200;
                            for i3 := 0 to 2 do begin
                                sltgX[i3] := 0;
                                sltgZ[i3] := 0;
                                sltg_f[i3] := True;
                                //距離
                                if i2 = 0 then begin
                                    sltgX[i3] := (P[1].DBC[i3].X - X);
                                    sltgZ[i3] := (P[1].DBC[i3].Z - Z) * 15 div 10;
                                    if P[1].DBC[i3].Dead_f = True then sltg_f[i3] := False;
                                end else if i2 = 1 then begin
                                    sltgX[i3] := (P[0].DBC[i3].X - X);
                                    sltgZ[i3] := (P[0].DBC[i3].Z - Z) * 15 div 10;
                                    if P[0].DBC[i3].Dead_f = True then sltg_f[i3] := False;
                                end;
                                sltgXZ[i3] := Hypot(sltgX[i3],sltgZ[i3]);
                                //角度
                                if Abs(sltgX[i3]) > Abs(sltgZ[i3]) then begin
                                    sltgA[i3] := None;
                                end else begin
                                    if sltgZ[i3] > 0 then begin
                                        sltgA[i3] := Ue;
                                    end else begin
                                        sltgA[i3] := Shita;
                                    end;
                                end;

                                //補正
                                //sltgXZ[i3] := sltgXZ[i3];

                                //角度によるタゲ外し
                                if (Muki2 <> sltgA[i3]) and ((Pos = 1) or (Pos = 4)) then sltg_f[i3] := False;

                                //Mukiによるタゲ外し(ジャンプで飛び越したときとか)
                                if Muki2 = None then begin

                                    if Muki = Migi then begin
                                        if sltgX[i3] < 0 then sltg_f[i3] := False;
                                    end else begin
                                        if sltgX[i3] > 0 then sltg_f[i3] := False;
                                    end;

                                end;
                        
                                if sltg_f[i3] = True then begin
                                    tgNo := i3;
                                    sltgXZ2 := sltgXZ[i3];
                                end;
                            end;

                            //投げる向きによる優先順位
                            for i3 := 0 to 2 do begin
                                if sltg_f[i3] = True then begin
                                    if sltgXZ[i3] < sltgXZ2 then begin
                                        tgNo := i3;
                                        sltgXZ2 := sltgXZ[i3];
                                    end;
                                end;
                            end;

                            //ターゲット
                            tgNo := (ENo * 10) + tgNo;
                            tgX := P[ENo].DBC[tgNo mod 10].X;
                            tgY := P[ENo].DBC[tgNo mod 10].Y;
                            tgZ := P[ENo].DBC[tgNo mod 10].Z;

                            Ball.tgNo := tgNo;
                        end;

                        case Pos of
                            1:begin
                                if Act_f = None then begin //直前で変わるのを防ぐため
                                //パスターゲット
                                    if i2 = 0 then begin
                                        if Muki = Hidari then begin
                                            ptgSet(1);
                                        end else if Muki = Migi then begin
                                            if (Dash_f = None) or (Jump_f <> None) then begin
                                                if Muki2 = Ue then begin
                                                    ptgSet(3);
                                                end else if Muki2 = Shita then begin
                                                    ptgSet(4);
                                                end else if Muki2 = None then begin
                                                    ptgSet(5);
                                                end;
                                            //ダッシュ中は向きではなく押してるキーに依存
                                            end else begin
                                                if KeyU2 = True then begin
                                                    ptgSet(3);
                                                end else if KeyD2 = True then begin
                                                    ptgSet(4);
                                                end else begin
                                                    ptgSet(5);
                                                end;
                                            end;
                                        end;
                                    end else if i2 = 1 then begin
                                        if Muki = Hidari then begin
                                            if (Dash_f = None) and (Jump_f = None) then begin
                                                if Muki2 = Ue then begin
                                                    ptgSet(3);
                                                end else if Muki2 = Shita then begin
                                                    ptgSet(4);
                                                end else if Muki2 = None then begin
                                                    ptgSet(5);
                                                end;
                                            //ダッシュ中は向きではなく押してるキーに依存
                                            end else begin
                                                if KeyU2 = True then begin
                                                    ptgSet(3);
                                                end else if KeyD2 = True then begin
                                                    ptgSet(4);
                                                end else begin
                                                    ptgSet(5);
                                                end;
                                            end;
                                        end else if Muki = Migi then begin
                                            ptgSet(1);
                                        end;
                                    end;
                                end;
                            end;
                            2:begin
                                //ターゲット
                                if Muki2 = Shita then begin
                                    ptgSet(4);
                                end else if Muki2 = None then begin
                                    if i2 = 0 then begin
                                        if Muki = Hidari then begin
                                            ptgSet(0);
                                        end else if Muki = Migi then begin
                                            ptgSet(5);
                                        end;
                                    end else if i2 = 1 then begin
                                        if Muki = Hidari then begin
                                            ptgSet(5);
                                        end else if Muki = Migi then begin
                                            ptgSet(0);
                                        end;
                                    end;
                                end;
                            end;
                            3:begin
                                //ターゲット
                                if Muki2 = Ue then begin
                                    ptgSet(3);
                                end else if Muki2 = None then begin
                                    if i2 = 0 then begin
                                        if Muki = Hidari then begin
                                            ptgSet(0);
                                        end else if Muki = Migi then begin
                                            ptgSet(5);
                                        end;
                                    end else if i2 = 1 then begin
                                        if Muki = Hidari then begin
                                            ptgSet(5);
                                        end else if Muki = Migi then begin
                                            ptgSet(0);
                                        end;
                                    end;
                                end;
                            end;
                            4:begin
                                //ターゲット
                                if Muki2 = Ue then begin
                                    ptgSet(3);
                                end else if Muki2 = Shita then begin
                                    ptgSet(4);
                                end else if Muki2 = None then begin
                                    ptgSet(0);
                                end;
                            end;
                        end;
                    end;
                end;
            end;
        end;
    end;
end;

//ジャンプ//****************************************************************************//
procedure Jumping(i:integer;i2:integer);
const
    JdX = 16*2;
    JdX2= 14*2;
    DJdX= 60*2;
    JdZ = 8*2;
    JdZ2= 7*2;
begin

    with P[i2].DBC[i] do begin
        case Jump_f of
            J1:begin //ジャンプかいし
                If (Jump_c >= 6) and (Dash_f <> None) then begin
                    SE(3);
                    mNo := 114;
                    dY := 400;
                    Muki2 := None;
                    Jump_f := J2;
                    Jump_c := 0;
                    Y := Y + 100;
                end else If (Jump_c >= 4) and (Dash_f = None)  then begin
                    SE(3);
                    mNo := 114;
                    dY := 368;
                    RevMuki2(i,i2);
                    Jump_f := J2;
                    Jump_c := 0;
                    Y := Y + 100;
                end else begin
                    Act_f := None;
                    Act_c := 0;
                    inc(Jump_c);
                    mNo := 114;
                    if Dash_f <> None then begin
                        Muki2 := None;
                    end else begin
                        RevMuki2(i,i2);
                    end;
                    dX := 0;
                    dZ := 0;
                end;
            end;
            J2:begin //ジャンプ中
                if Act_f = None then begin
                    mNo := 107;
                    RevMuki2(i,i2);
                end;
                if Pos = 1 then begin
                    if Dash_f = Migi then begin
                        X := X + DJdX;
                    end else if Dash_f = Hidari then begin
                        X := X - DJdX;
                    end else begin
                        if JMuki2 = Ue then begin
                            if JMuki = Migi then begin
                                X := X + JdX2;
                                Z := Z + JdZ2;
                            end else if JMuki = Hidari then begin
                                X := X - JdX2;
                                Z := Z + JdZ2;
                            end else begin
                                Z := Z + JdZ;
                            end;
                        end else if JMuki2 = Shita then begin
                            if JMuki = Migi then begin
                                X := X + JdX2;
                                Z := Z - JdZ2;
                            end else if JMuki = Hidari then begin
                                X := X - JdX2;
                                Z := Z - JdZ2;
                            end else begin
                                Z := Z - JdZ;
                            end;
                        end else begin
                            if JMuki = Migi then begin
                                X := X + JdX;
                            end else if JMuki = Hidari then begin
                                X := X - JdX;
                            end;
                        end;
                    end;
                end;
                Y := Y + dY;
                dec(dY,Grv);
                if Y <= 0 then begin
                    Jump_f := J3;
                    Y := 0;
                    dY := 0;
                end;
            end;
            J3:begin //着地
                Act_f := None;
                Act_c := 0;
                Take_f := False;
                
                if (Dash_f <> None) then begin
                    If (Jump_c >= 10) then begin
                        mNo := 114;
                        RevMuki2(i,i2);
                        Jump_f := None;
                        Jump_c := 0;
                        Motion := None;
                        Dash_f := None;
                    end else begin
                        inc(Jump_c);
                        mNo := 113;
                        If (Jump_c >= 2) then mNo := 114;
                        RevMuki2(i,i2);
                        dX := 0;
                        dZ := 0;
                        dY := 0;
                    end;
                end else begin
                    If (Jump_c >= 4) then begin
                        mNo := 113;
                        RevMuki2(i,i2);
                        Jump_f := None;
                        Jump_c := 0;
                        Motion := None;
                        Dash_f := None;
                    end else begin
                        inc(Jump_c);
                        mNo := 113;
                        RevMuki2(i,i2);
                        dX := 0;
                        dZ := 0;
                        dY := 0;
                    end;
                end;
            end;
        end;
    end;
end;

//吹っ飛び//****************************************************************************//
procedure Damage(i:integer;i2:integer);
const
    AniW = 8;
begin

    with P[i2].DBC[i] do begin
        case Dam_f of
            D2:begin //吹っ飛び中
                if RollMuki = Zenten then begin
                    mNo := 406;
                end else begin
                    mNo := 405;
                end;
                X := X + dX;
                Y := Y + dY;
                Z := Z + dZ;
                if RefWall_f = False then begin
                    dec(dY,Grv);
                end else begin

                    dec(dY,GC.DBB.PAGRV);
                end;
                //壁にぶつかったとき
                if DamLv < 2 then begin
                    if (X > 43200 - 800) or (X < 0 + 800) then begin
                        if (X > 43200 - 800) then begin
                            X := 43200 - 800;
                        end else if (X < 0 + 800) then begin
                            X := 0 + 800;
                        end;
                        RefWall_f := True;
                        RollMuki := -RollMuki;
                        dZ := 0;
                        dX := -(dX div 5);
                        dY := 150;

                        DamLv := 0;
                    end else if (Z > 11200) or (Z < 0) then begin
                        if (Z > 11200) then begin
                            Z := 11200;
                        end else if (Z < 0) then begin
                            Z := 0;
                        end;
                        //RefWall_f := True;
                        //RollMuki := -RollMuki;
                        dZ := -(dZ div 3);
                        dX := (dX div 5);
                        dY := 170;

                        DamLv := 0;
                    end;
                //世界一周
                end else begin
                    if (X > 43200) or (X < 0) then begin
                        if (X > 43200 - 800) then begin
                            X := 0;
                        end else if (X < 0 + 800) then begin
                            X := 43200;
                        end;
                    end else if (Z > 11200) or (Z < 0) then begin
                        if (Z > 11200) then begin
                            Z := 11200;
                        end else if (Z < 0) then begin
                            Z := 0;
                        end;
                        dZ := -(dZ);
                    end;
                end;
                if Y <= 0 then begin
                    Y := 0;
                    if (DamLv >= 1) and (Stage <> 4) then begin
                        Dam_f := D3;
                        dX := dX div 4;
                        dZ := dZ div 4;
                        dY := 0;
                        mNo_c := 0;
                    end else begin
                        if dHP = 0 then begin
                            if i2 = 0 then NODead_f := False;//ラスボスへの挑戦権消滅
                            Dead_f := True;//
                            Holy_c := 30;
                            HolyX := X;
                            HolyY := Y-1000;
                            HolyZ := Z;
                            SE(11);
                            inc(P[i2].Dead_c);
                            //全滅
                            if P[i2].Dead_c >= 3 then AllDead;
                        end else begin
                            SE(8);
                            Dam_f := D4;
                            Slip_c := 1000;
                            //dX := dX div 4;
                            //dZ := dZ div 4;
                            dY := 0;
                            mNo_c := 0;

                            //P[i2].Dead_c := 4;
                            //AllDead;
                        end;
                    end;
                end;
            end;
            D3:begin //着地
                If mNo_c = (AniW * 6) then begin
                    if dHP = 0 then begin
                        if i2 = 0 then NODead_f := False;//ラスボスへの挑戦権消滅
                        Dead_f := True;//
                        Holy_c := 30;
                        HolyX := X;
                        HolyY := Y-1000;
                        HolyZ := Z;
                        SE(11);
                        inc(P[i2].Dead_c);
                        if P[i2].Dead_c >= 3 then AllDead;
                    end else begin
                        SE(8);
                        //SEStop;
                        mNo := 308;
                        if RollMuki = Zenten then mNo := 404;
                        Dam_f := D4;
                        Slip_c := 1000;
                        mNo_c := 0;
                    end;
                end else begin
                    X := X + dX;
                    Y := Y + dY;
                    Z := Z + dZ;
                    if RollMuki = Zenten then begin
                        Case mNo_c of
                            AniW * 0:begin
                                mNo := 400;
                                SE(9);
                            end;
                            AniW * 1:begin
                                mNo := 401;
                            end;
                            AniW * 2:begin
                                mNo := 402;
                            end;
                            AniW * 3:begin
                                mNo := 403;
                            end;
                            AniW * 4:begin
                                mNo := 400;
                            end;
                            AniW * 5:begin
                                mNo := 401;
                            end;
                        end;
                        inc(mNo_c);
                    end else if RollMuki = Bakuten then begin
                        Case mNo_c of
                            AniW * 0:begin
                                mNo := 403;
                                SE(9);
                            end;
                            AniW * 1:begin
                                mNo := 402;
                            end;
                            AniW * 2:begin
                                mNo := 401;
                            end;
                            AniW * 3:begin
                                mNo := 400;
                            end;
                            AniW * 4:begin
                                mNo := 403;
                            end;
                            AniW * 5:begin
                                mNo := 402;
                            end;
                        end;
                        inc(mNo_c);
                    end;
                end;
            end;
            D4:begin
                //アイスランドステージのスリップ(地上)
                if Stage = 4 then begin
                    dX := dX * 1000 div Slip_c;
                    dZ := dZ * 1000 div Slip_c;
                    inc(Slip_c,5);
                    X := X + dX;
                    Z := Z + dZ;
                end;

                if mNo_c = 0 then begin
                    mNo := 308;
                    if RollMuki = Zenten then mNo := 404;
                end else if (mNo_c = GC.DBETC.DOWNTIME) then begin
                    Muki2 := None;
                    mNo := 114;
                end else if (mNo_c = GC.DBETC.DOWNTIME + AniW) then begin
                    Act_f := None;
                    Motion := None;
                    Dash_f := None;
                    Dam_f := None;
                    DamLv := 0;
                    Catch_c := 0;
                    dX := 0;
                    dZ := 0;
                    dY := 0;
                end;

                inc(mNo_c);

                if (mNo_c > GC.DBETC.DOWNTIME + AniW) then mNo_c := 0;
                {
                case mNo_c of
                    AniW * 0:begin
                        mNo := 308;
                        if RollMuki = Zenten then mNo := 404;
                    end;

                    DOWNTIME:begin
                        Muki2 := None;
                        mNo := 114;
                    end;
                    DOWNTIME + AniW:begin
                        Act_f := None;
                        Motion := None;
                        Dash_f := None;
                        Dam_f := None;
                        DamLv := 0;
                        Catch_c := 0;
                        dX := 0;
                        dZ := 0;
                        dY := 0;
                    end;
                end;
                inc(mNo_c);
                if mNo_c > (AniW * 6) then mNo_c := 0;
                }
            end;
            D5:begin //パスヒット
                case mNo_c of
                    AniW * 0:begin
                        mNo := 405;

                    end;
                    AniW * 4:begin
                        Act_f := None;
                        Motion := None;
                        Dash_f := None;
                        Dam_f := None;
                        DamLv := 0;
                        Catch_c := 0;
                        dX := 0;
                        dZ := 0;
                        dY := 0;
                    end;
                end;
                inc(mNo_c);
                if mNo_c > (AniW * 4) then mNo_c := 0;
            end;
        end;
    end;
end;

//アクション全般//****************************************************************************//
procedure DBAction;
const
    ActW = 3;
    ActW2 = 2;
    //baseSp = 32;
var
    i:integer;
    i2:integer;
    i3:integer;

    tX:integer;//ターゲットの座標
    tY:integer;
    tZ:integer;
    tt60_f :boolean;
    ENo:integer;//敵プレーヤー番号
    eta:Integer;

    //動作終了
    procedure ActEnd;
    begin

        with P[i2].DBC[i] do begin
            Act_f := None;
            mNo_c := 0;
            if Motion <> SLP2 then Motion := None;
        end;

    end;

    //シュートの角度
    procedure SAngle(var mX:integer;var mY:integer;var mZ:integer;rrr:integer);
    var
        d  : Real;
        j: Real;
        eX : Real;
        eY : Real;
        eZ : Real;

    begin

        //45度以上鋭角のシュートにはならないようにする
        if P[i2].DBC[i].Muki2 = None then begin

            //近すぎ補正
            if mX <= 100 then begin
                mX := 100;
                mZ := 0;
            end;

            if Abs(mX) < Abs(mY) then begin
                mX := -mY;
            end;

        end else begin

            //近すぎ補正
            if mZ <= 100 then begin
                mZ := 100;
            end;

            //いらないっぽい
            //if Abs(mZ) < Abs(mY) then begin
                //mY := -mZ;
                //mX := 0;
            //end;

        end;

        d := Hypot(mX,mY);//斜辺の長さ
        j := Hypot(d,mZ);

        if j <> 0 then begin

            eZ := ((mZ * rrr) / j);
            eX := ((mX * rrr) / j);
            eY := ((mY * rrr) / j);

            mX := Trunc(eX);
            mY := Trunc(eY);
            mZ := Trunc(eZ);

        end else begin

            mX := rrr;
            mY := 0;
            mZ := 0;

        end;

    end;
    //パスの角度
    function PAngle(var mX:integer;var mY:integer;var mZ:integer;t60_f:Boolean):integer;
    var
        j: Real;
        eX : Real;
        eY : Real;
        eZ : Real;
        eJ : Real;
        Sin2Theta :Real;
        Theta :Real;

        v0 :Real;

    begin

        j := Hypot(mX,mZ);
        if j = 0 then j := 1;

        Sin2Theta := j * (GC.DBB.PAGRV / Sqr(GC.DBB.PASPD));
        if (Sin2Theta <= 1) and (Sin2Theta >= -1) and (t60_f = False) then begin

            Theta := ArcSin(Sin2Theta) / 2;
            eJ := Cos(Theta) * GC.DBB.PASPD;
            eY := Sin(Theta) * GC.DBB.PASPD;

        end else begin

            //初速調節
            v0 := (Sqrt((j * (GC.DBB.PAGRV / 0.866))));//60°
            eJ := 0.5   * v0;
            eY := 0.866 * v0;

        end;

        eX := (eJ * (mX / j));
        eZ := (eJ * (mZ / j));

        mX := Trunc(eX);
        mY := Trunc(eY);
        mZ := Trunc(eZ);

        Result := Trunc(j / eJ);

    end;
    //シュートパワー＆スピード
    procedure ShootPow;
    const
        addSP = 2;
    begin

        with P[i2].DBC[i] do begin

            Ball.Pow := dBP * 100;

            if (Jump_f <> None) and (Dash_f <> None) then begin
                Ball.Pow := Ball.Pow;
            end else if (Dash_f <> None) then begin
                Ball.Pow := ((Ball.Pow-100) div 4)+((Ball.Pow+100) div 2)+25;
            end else if (Jump_f <> None) then begin
                Ball.Pow := (Ball.Pow+100) div 2;
            end else begin
                Ball.Pow := (Ball.Pow div 4 + 90);
            end;

            Ball.Pow := (Ball.Pow div 100);

            //ナイスシュート
            if Ball.Nice_f = True then Ball.Pow := (Ball.Pow * 2);

            //シュートスピード
            if Ball.Pow <= 2 then begin
                Ball.Speed := (9+addSP) * GC.DBB.STSPD;
                Ball.PowLv := 0;
            end else if Ball.Pow <= 4 then begin
                Ball.Speed := (11+addSP) * GC.DBB.STSPD;
                Ball.PowLv := 1;
            end else if Ball.Pow <= 7 then begin
                Ball.Speed := (13+addSP) * GC.DBB.STSPD;
                Ball.PowLv := 2;
            end else if Ball.Pow <= 11 then begin
                Ball.Speed := (15+addSP) * GC.DBB.STSPD;
                Ball.PowLv := 3;
            end else if Ball.Pow <= 15 then begin
                Ball.Speed := (17+addSP) * GC.DBB.STSPD;
                Ball.PowLv := 4;
            end else begin
                Ball.Speed := (19+addSP) * GC.DBB.STSPD;
                Ball.PowLv := 4;
            end;

            If Jump_f <> None then Ball.Speed := Ball.Speed + GC.DBB.STSPD;

            Ball.Spin := -Muki * (Ball.Speed div GC.DBB.STSPD);
            if dTK <= 3 then begin
                Ball.Curve := -((i2 * 100) + (10));
            end else begin
                Ball.Curve := (i2 * 100) + (dTK);
            end;


        end;

    end;
    //シュートパワー＆スピード
    procedure SPShootPow;
        procedure SetDt(tPow:integer;tSp:integer);
        begin
            Ball.Pow := tPow;
            Ball.Speed := tSp * GC.DBB.STSPD;
        end;
    begin

        with P[i2].DBC[i] do begin

            Ball.PowLv := 4;
            Ball.Curve := (i2 * 100) + 0;
            Ball.Spin := -Muki * 16;
            Ball.SP_c := 0;
            case Ball.SType of
                Skan:begin //貫通
                    SetDt(12,GC.DBB.STSPDkan);
                    Ball.Curve := (i2 * 100) + (dTK);
                end;
                Ssun:begin //スネーク
                    SetDt(15,GC.DBB.STSPDsun);
                    Ball.SP_c := 8;
                end;
                Ssuk:begin //スクリュー
                    SetDt(16,GC.DBB.STSPDsuk);
                    Ball.SP_c := 8;
                end;
                Skak:begin //かっくん
                    SetDt(15,GC.DBB.STSPDkak);
                end;
                Sobu:begin //おぶおぶ
                    SetDt(19,GC.DBB.STSPDobu);
                end;
                Sapp:begin //アッパー
                    SetDt(18,GC.DBB.STSPDapp);
                end;
                Swaa:begin //ワープ
                    SetDt(15,GC.DBB.STSPDwaa);
                end;
                Sbuu:begin //ブーメラン
                    Ball.PowLv := 5;
                    SetDt(23,GC.DBB.STSPDbuu);
                end;
                Senn:begin //円輪
                    SetDt(10,GC.DBB.STSPDenn);
                end;
                
                //ジャンプ系
                Snat:begin //ナッツ
                    SetDt(20,GC.DBB.STSPDnat);
                end;
                Sbun:begin //分裂
                    Ball.Curve := (i2 * 100) + (dTK);
                    SetDt(18,GC.DBB.STSPDbun);
                end;
                Sina:begin //稲妻
                    SetDt(16,GC.DBB.STSPDina);
                    Ball.SP_c := 8;
                end;
                Smoz:begin //百舌落とし
                    SetDt(17,GC.DBB.STSPDmoz);
                end;
                Sass:begin //圧縮
                    Ball.PowLv := 5;
                    SetDt(21,GC.DBB.STSPDass);
                end;
                Skas:begin //加速
                    SetDt(19,GC.DBB.STSPDkas);
                end;
                Sbuy:begin //ぶよぶよ
                    Ball.Curve := (i2 * 100) + (dTK);
                    SetDt(18,GC.DBB.STSPDbuy);
                end;
                Shoe:begin //ほえほえ
                    Ball.PowLv := 5;
                    Ball.Curve := (i2 * 100) + (dTK);
                    SetDt(26,GC.DBB.STSPDhoe);
                end;
            end;

        end;

    end;
    procedure PaCurChange;
    var
        i3:integer;
        i4:integer;
        CurChange:integer;//パスによる敵のカーソル変更
        CurChangeNo:integer;
        SortDt:array[0..2] of SortData;//内野３人
        TempSDt:SortData;
    begin
        with P[i2].DBC[i] do begin
            CurChange := 0;
            CurChangeNo := 0;
            if i2 = 0 then begin
                case P[i2].DBC[ptgNo].Pos of
                    1:CurChange := Hidari;
                    2:CurChange := Ue;
                    3:CurChange := Shita;
                    4:CurChange := Migi;
                end;
            end else begin
                case P[i2].DBC[ptgNo].Pos of
                    1:CurChange := Migi;
                    2:CurChange := Ue;
                    3:CurChange := Shita;
                    4:CurChange := Hidari;
                end;
            end;
            //データセット
            for i3 := 0 to 2 do begin
                if (CurChange = Migi) or (CurChange = Hidari) then begin
                    SortDt[i3].Dt1 := P[ENo].DBC[i3].X;
                end else begin
                    SortDt[i3].Dt1 := P[ENo].DBC[i3].Z;
                end;
                SortDt[i3].BaseNo := i3;
                //パスカットにいけない状態
                if (P[ENo].DBC[i3].Dead_f = True) or (P[ENo].DBC[i3].Dam_f <> None)
                or (P[ENo].DBC[i3].Groggy_c <> 0) then begin
                    SortDt[i3].Fl1 := True;
                end else begin
                    SortDt[i3].Fl1 := False;
                end;
            end;

            if (CurChange = Migi) or (CurChange = Ue) then begin
                //ソート大きい順
                for i4 := 0 to 1 do begin
                    for i3 := 0 to 1 do begin
                        if SortDt[i3].Dt1 < SortDt[i3+1].Dt1 then begin
                            TempSDt := SortDt[i3];
                            SortDt[i3] := SortDt[i3+1];
                            SortDt[i3+1] := TempSDt;
                        end;
                    end;
                end;
            end else begin
                //ソート小さい順
                for i4 := 0 to 1 do begin
                    for i3 := 0 to 1 do begin
                        if SortDt[i3].Dt1 > SortDt[i3+1].Dt1 then begin
                            TempSDt := SortDt[i3];
                            SortDt[i3] := SortDt[i3+1];
                            SortDt[i3+1] := TempSDt;
                        end;
                    end;
                end;
            end;
            //ソート
            for i4 := 0 to 1 do begin
                for i3 := 0 to 1 do begin
                    if (SortDt[i3].Fl1 = True) then begin
                        TempSDt := SortDt[i3];
                        SortDt[i3] := SortDt[i3+1];
                        SortDt[i3+1] := TempSDt;
                    end;
                end;
            end;

            CurChangeNo := SortDt[0].BaseNo;
            //カーソルが変わった場合ダッシュフラグ消す
            if P[ENo].PNo <> CurChangeNo then begin
                P[ENo].PNo := CurChangeNo;
                P[ENo].DBC[P[ENo].PNo].Dash_f := None;
            end;


        end;
    end;
    procedure CaSound;
    begin
        case P[i2].DBC[i].Face of
            3:SE(29);
            1:SE(30);
            4:SE(32);
            5:SE(33);
            2:SE(34);
            else SE(31);
        end;
    end;
    procedure STypeSet;
    var
        MozDt:integer;
    begin
        with P[i2].DBC[i] do begin
            if Ball.SType <> None then begin
                //すくりゅう
                if (Ball.SType = Ssuk) then begin
                    Ball.dY := Ball.dY * 3 div 4;
                //いなづま
                end else if (Ball.SType = Sina) then begin
                    Ball.dY := Ball.dY * 3 div 4;
                //もずおとし
                end else if (Ball.SType = Smoz) then begin
                    if tgNo < 20 then begin
                        MozDt := Trunc(Hypot(Abs(tgX-Ball.X),Abs(tgZ-Ball.Z))) div 400;
                        Ball.SP_c := -(MozDt ) - random(MozDt);//斜辺の長さ
                    end else begin
                        Ball.SP_c := -600;
                    end;
                //あっぱー(地上で出したもののみ)
                end else if (Ball.SType = Sapp) then begin
                    if Jump_f = None then Ball.Y  := Y + 100;
                //かそく
                end else if (Ball.SType = Skas) then begin
                    Ball.SP_c := 10;
                //かっくん
                end else if (Ball.SType = Skak) then begin
                    Ball.SP_c := -25-Random(11);
                end;
                Ball.dX2 := Ball.dX;
                Ball.dY2 := Ball.dY;
                Ball.dZ2 := Ball.dZ;
            end;
        end;
    end;
    procedure ptgMukiSet(tptgNo:integer);
    begin
        with P[i2].DBC[tptgNo] do begin
            //タゲキャラの向き補正
            if (P[i2].DBC[i].Pos = 2) then begin
                Muki2 := Ue;
            end else if (P[i2].DBC[i].Pos = 3) then begin
                Muki2 := Shita;
            end else begin
                if Ball.Z < Z - 600 then begin
                    Muki2 := Shita;
                end else if Ball.Z > Z + 600 then begin
                    Muki2 := Ue;
                end else begin
                    Muki2 := None;
                end;
            end;
            if Ball.X < X - 600 then begin
                Muki := Hidari;
            end else if Ball.X > X + 600 then begin
                Muki := Migi;
            end;

        end;
    end;

begin
    For i2 := 0 to 1 do begin

        if i2 = 0 then begin
            ENo := 1;
        end else begin
            ENo := 0;
        end;

        For i := 0 To 5 do begin
            //今のところカーソルキャラのみ
            //他のキャラにも対応させる
            with P[i2].DBC[i] do begin
            if (Dead_f = False) and (Dam_f = None) then begin

                If (Act_f <> Ca) and (Act_f <> JCa) then Catch_c := 0;
                if Catch_c > 0 then dec(Catch_c);

                case Act_f of
                    //拾い
                    TCr:begin
                        case Act_c of
                            ActW * 1:begin
                                CaSound;
                                mNo := 113;
                                RevMuki2(i,i2);
                            end;
                            ActW * 2:Take_f := True;
                            ActW * 4:begin
                                mNo := 100;
                                RevMuki2(i,i2);
                                Take_f := False;
                            end;
                            ActW * 5:begin
                                ActEnd;
                            end;
                        end;

                        inc(Act_c);
                        If Act_c > (ActW * 5) then Act_c := 0;
                    end;
                    //守備
                    Crm:begin
                        case Act_c of
                            ActW * 1:begin
                                CaSound;
                                mNo := 114;
                                RevMuki2(i,i2);
                            end;
                            ActW * 2:begin
                                mNo := 114;
                                RevMuki2(i,i2);
                            end;
                            ActW * 4:begin
                                mNo := 113;
                                RevMuki2(i,i2);
                            end;
                            ActW * 5:begin
                                ActEnd;
                            end;
                        end;

                        inc(Act_c);
                        If Act_c > (ActW * 5) then Act_c := 0;
                    end;
                    Ca:begin

                        //キャッチ開始
                        if Act_c = GC.DBCA.CASTTIME then begin
                            CaSound;
                            mNo := 102;
                            RevMuki2(i,i2);
                            Take_f := True;
                            Catch_c := GC.DBCA.CABF + (dCT * GC.DBCA.CASF div 100);
                        end else if Act_c = (GC.DBCA.CASTTIME + GC.DBCA.CABF + (dCT * GC.DBCA.CASF div 100)) then begin
                            Take_f := False;
                            mNo := 100;
                            RevMuki2(i,i2);
                        end else if Act_c = (GC.DBCA.CASTTIME + GC.DBCA.CABF + (dCT * GC.DBCA.CASF div 100)) + ActW then begin
                            ActEnd;
                        end;
                        inc(Act_c);
                        if Act_c > (GC.DBCA.CASTTIME + GC.DBCA.CABF + (dCT * GC.DBCA.CASF div 100)) + ActW then Act_c := 0;
                        {
                        case Act_c of
                            ActW * 1:begin
                                CaSound;
                                mNo := 102;
                                RevMuki2(i,i2);
                                Take_f := True;
                                Catch_c := dCT;
                            end;
                        end;
                        if Act_c = ((ActW * 1) + dCT) + (ActW * 1) then begin
                            Take_f := False;
                            mNo := 100;
                            RevMuki2(i,i2);
                        end;
                        if Act_c = ((ActW * 1) + dCT) + (ActW * 2) then begin
                            ActEnd;
                        end;
                        inc(Act_c);
                        If Act_c > ((ActW * 1) + dCT) + (ActW * 2) then Act_c := 0;
                        }
                    end;
                    JCa:begin

                        //キャッチ開始
                        if Act_c = GC.DBCA.CASTTIME then begin
                            CaSound;
                            mNo := 108;
                            RevMuki2(i,i2);
                            Take_f := True;
                            Catch_c := GC.DBCA.CABF + (dCT * GC.DBCA.CASF div 100);
                        end else if Act_c = (GC.DBCA.CASTTIME + GC.DBCA.CABF + (dCT * GC.DBCA.CASF div 100)) then begin
                            Take_f := False;
                            mNo := 107;
                            RevMuki2(i,i2);
                        end else if Act_c = (GC.DBCA.CASTTIME + GC.DBCA.CABF + (dCT * GC.DBCA.CASF div 100)) + (ActW*2) then begin
                            ActEnd;
                        end;
                        inc(Act_c);

                        {
                        case Act_c of
                            ActW * 1:begin
                                CaSound;
                                mNo := 108;
                                RevMuki2(i,i2);
                                Take_f := True;
                                Catch_c := dCT;   
                            end;
                        end;
                        if Act_c = ((ActW * 1) + dCT) + (ActW * 3) then begin
                            Take_f := False;
                            mNo := 107;
                            RevMuki2(i,i2);
                        end;
                        if Act_c = ((ActW * 1) + dCT) + (ActW * 5) then begin
                            ActEnd;
                        end;
                        inc(Act_c);
                        }
                    
                    end;
                    //攻撃
                    Sh:begin
                        case Act_c of
                            ActW * 1:begin
                                if tgNo < 20 then begin
                                    //真横向き以外の場合、
                                    //投げる瞬間に向き変えの可能性がある。
                                    if (Pos <> 1) and (Muki2 <> None) then begin
                                        if tgX < Ball.X then Muki := Hidari;
                                        if tgX > Ball.X then Muki := Migi;
                                    end;
                                    //外野はタゲの範囲が広いため、うまいこと向き補正する
                                    if (Pos = 2) then begin
                                        Muki2 := Shita;
                                    end else if (Pos = 3) then begin
                                        Muki2 := Ue;
                                    end;

                                end;
                                mNo := 103;
                                RevMuki2(i,i2);
                            end;
                            ActW * 3:begin
                                mNo := 104;
                                RevMuki2(i,i2);
                            end;
                            ActW * 4:begin
                                Ball.Nice_f := False;
                                Ball.SType := None;
                                {
                                if (CPU_f = True) and (i2 = 1) then begin
                                    if (dST >= 10) and (LvPer100(50))
                                    and (Step_c > 0)  then begin
                                        SE(2);
                                        Ball.Nice_f := True;
                                    end else if (Step_c > 0) and (LvPer100(70)) then begin
                                        if (Name = 'なりたか') and (Per100(50)) then begin
                                            Ball.SType := Senn;
                                        end else begin
                                            Ball.SType := dDSP;
                                            //難しいの謎の軍団の必殺はダッシュジャンプ両方出る
                                            if ((Per100(50)) and (GameLv = 2) and (Stage = 9)) then begin
                                                Ball.SType := dJSP;
                                            end;
                                        end;
                                        SE(27);
                                        SE(2);
                                    end else begin
                                        SE(1);
                                    end;
                                end else begin
                                }
                                    if Step_c = 6 then begin
                                        SE(27);
                                        SE(2);
                                        Ball.SType := dDSP;
                                    end else if (Step_c = 8) and (dST >= 10) then begin
                                        SE(2);
                                        Ball.Nice_f := True;
                                    end else if ((Step_c = 1) or (Step_c = 2))
                                    and (Name = 'なりたか') then begin
                                        SE(27);
                                        SE(2);
                                        Ball.SType := Senn;
                                    end else begin
                                        //ハンデによる補正
                                        {
                                        if ((HDCDt[0,2] >= 1) and (Step_c >= 5) and (Step_c <= 7))
                                        or ((HDCDt[0,2] >= 2) and (Step_c >= 4) and (Step_c <= 8)) then begin
                                            SE(27);
                                            SE(2);
                                            Ball.SType := dDSP;
                                        end else begin
                                            SE(1);//ノーマル
                                        end;
                                        }
                                        SE(1);//ノーマル
                                    end;
                                //end;
                                mNo := 105;
                                RevMuki2(i,i2);
                                Ball_f := False;
                                
                                //威力
                                if Ball.SType <> None then begin
                                    SPShootPow;
                                end else begin
                                    ShootPow;
                                end;

                                Ball.Motion := BShoot;
                                Ball.X  := X;
                                Ball.Y  := Y + 1800;
                                Ball.Z  := Z;
                                Ball.ZShoot_f := False;
                                
                                if Muki2 = Ue then begin
                                    Ball.Z  := Ball.Z + 800;
                                    Ball.X  := Ball.X + (800 * Muki);
                                    Ball.ZShoot_f := True;
                                end else if Muki2 = Shita then begin
                                    Ball.Z  := Ball.Z - 800;
                                    Ball.X  := Ball.X + (800 * Muki);
                                    Ball.ZShoot_f := True;
                                end else if Muki2 = None then begin
                                    Ball.X  := Ball.X + (1600 * Muki);
                                end;

                                tgX := P[ENo].DBC[tgNo mod 10].X;
                                tgY := P[ENo].DBC[tgNo mod 10].Y;
                                tgZ := P[ENo].DBC[tgNo mod 10].Z;

                                //ロックあり
                                if tgNo < 20 then begin
                                    tX := Abs(tgX-Ball.X);
                                    tY := 0;//-Ball.Y;//0;
                                    if P[tgNo div 10].DBC[tgNo mod 10].Dam_f = D4 then tY := -Ball.Y + 600;
                                    tZ := Abs(tgZ-Ball.Z);
                                    SAngle(tX,tY,tZ,Ball.Speed);
                                    Ball.dX := tX;
                                    Ball.dY := tY;
                                    Ball.dZ := tZ;
                                    if Muki2 = None then begin
                                        Ball.dX := Ball.dX * Muki;
                                        if (tgZ-Ball.Z) < 0 then Ball.dZ := -Ball.dZ;
                                    end else begin
                                        if Muki2 = Ue then begin
                                            Ball.dZ := Ball.dZ;
                                        end else if Muki2 = Shita then begin
                                            Ball.dZ := -Ball.dZ;
                                        end;
                                        if (tgX-Ball.X) < 0 then Ball.dX := -Ball.dX;
                                    end;
                                //ロックなし
                                end else begin
                                    tX := 200;
                                    tY := 0;
                                    tZ := 0;
                                    SAngle(tX,tY,tZ,Ball.Speed);
                                    Ball.dX := tX * Muki;
                                    Ball.dY := tY;
                                    Ball.dZ := tZ;
                                    if Muki2 = Shita then Ball.dZ := -Ball.dZ;

                                end;

                                Ball.tgNo := tgNo;
                                //ダメージおよびグロッキーキャラがタゲになっても
                                //カーソルは行かない（残り一人の時の処理もあとでする）
                                if (P[ENo].DBC[Ball.tgNo mod 10].Dam_f = None)
                                and (P[ENo].DBC[Ball.tgNo mod 10].Groggy_c = 0) then begin
                                    //カーソルが変わった場合ダッシュフラグ消す
                                    if P[ENo].PNo <> Ball.tgNo mod 10 then begin
                                        P[ENo].PNo := Ball.tgNo mod 10;
                                        P[ENo].DBC[P[ENo].PNo].Dash_f := None;
                                    end;
                                    
                                end;

                                STypeSet;

                            end;
                            ActW * 5:if Dash_f <> None then SetSLP(i,i2);
                            ActW * 7:begin
                                ActEnd;
                            end;
                        end;

                        inc(Act_c);
                        If Act_c > (ActW * 7) then Act_c := 0;
                    end;
                    JSh:begin
                        case Act_c of
                            ActW * 1:begin
                                if tgNo < 20 then begin
                                    {
                                    Ball.X  := X + (1600 * Muki);
                                    if Muki2 = Ue then begin
                                        Ball.X  := Ball.X - (800 * Muki);
                                    end else if Muki2 = Shita then begin
                                        Ball.X  := Ball.X - (1200 * Muki);
                                    end;
                                    }
                                    //真横向き以外の場合、
                                    //投げる瞬間に向き変えの可能性がある。
                                    if (Pos <> 1) and (Muki2 <> None) then begin
                                        if tgX < Ball.X then Muki := Hidari;
                                        if tgX > Ball.X then Muki := Migi;
                                    end;
                                    //外野はタゲの範囲が広いため、うまいこと向き補正する
                                    if (Pos = 2) then begin
                                        Muki2 := Shita;
                                    end else if (Pos = 3) then begin
                                        Muki2 := Ue;
                                    end;
                                end;
                                mNo := 109;
                                RevMuki2(i,i2);
                            end;
                            ActW * 3:begin
                                mNo := 110;
                                RevMuki2(i,i2);
                            end;
                            ActW * 4:begin
                                Ball.Nice_f := False;
                                Ball.SType := None;
                                //ダッシュフラグがたってるとき
                                if (Dash_f <> None) then begin
                                    //ダッシュジャンプ必殺（なりたかはだせない）
                                    if (dY >= -50) and (dY <= -20)
                                    and (Name <> 'なりたか') then begin
                                        SE(27);
                                        SE(2);
                                        Ball.SType := dJSP;
                                        //難しいの謎の軍団の必殺はダッシュジャンプ両方出る
                                        if (Per100(50)) and (i2 = 1)
                                        and (GameLv = 2) and (Stage = 9) then begin
                                            Ball.SType := dDSP;
                                        end;
                                    //ダッシュジャンプナイス
                                    end else if (dY >= 55) and (dY <= 85) and (dST >= 12) then begin
                                        SE(2);
                                        Ball.Nice_f := True;
                                    end else begin
                                        //ハンデによる補正
                                        if ((HDCDt[0,2] >= 1) and (dY >= -65) and (dY <= -5))
                                        or ((HDCDt[0,2] >= 2) and (dY >= -80) and (dY <= 10)) then begin
                                            SE(27);
                                            SE(2);
                                            Ball.SType := dJSP;
                                        end else begin
                                            SE(1);//ノーマル
                                        end;
                                    end;
                                end else begin
                                    //垂直ジャンプナイス(なりたかはひっさつ)
                                    if (dY >= -22) and (dY <= 8) and (dY <> 0) then begin
                                         if (Name <> 'なりたか') then begin
                                            SE(2);
                                            Ball.Nice_f := True;
                                         end else begin
                                            SE(27);
                                            SE(2);
                                            Ball.SType := dJSP;
                                         end;
                                    end else begin
                                        //ノーマル
                                        SE(1);
                                    end;
                                end;

                                mNo := 111;
                                RevMuki2(i,i2);
                                Ball_f := False;
                                //ボールの状態変更
                                //威力
                                if Ball.SType <> None then begin
                                    SPShootPow;
                                end else begin
                                    ShootPow;
                                end;
                                Ball.Motion := BShoot;

                                Ball.X  := X;
                                Ball.Y  := Y + 1800;
                                Ball.Z  := Z;
                                Ball.ZShoot_f := False;

                                if Muki2 = Ue then begin
                                    Ball.Z  := Ball.Z + 800;
                                    Ball.X  := Ball.X + (800 * Muki);
                                    Ball.ZShoot_f := True;
                                end else if Muki2 = Shita then begin
                                    Ball.Z  := Ball.Z - 800;
                                    Ball.X  := Ball.X + (800 * Muki);
                                    Ball.ZShoot_f := True;
                                end else if Muki2 = None then begin
                                    Ball.X  := Ball.X + (1600 * Muki);
                                end;

                                tgX := P[ENo].DBC[tgNo mod 10].X;
                                tgY := P[ENo].DBC[tgNo mod 10].Y;
                                tgZ := P[ENo].DBC[tgNo mod 10].Z;

                                //ロックあり
                                if tgNo < 20 then begin
                                    tX := Abs(tgX-Ball.X);
                                    tY := (tgY-Ball.Y);
                                    if tY > 0 then tY := 0;
                                    tZ := Abs(tgZ-Ball.Z);
                                    SAngle(tX,tY,tZ,Ball.Speed);
                                    Ball.dX := tX;
                                    Ball.dY := tY;
                                    Ball.dZ := tZ;
                                    if Muki2 = None then begin
                                        Ball.dX := Ball.dX * Muki;
                                        if (tgZ-Ball.Z) < 0 then Ball.dZ := -Ball.dZ;
                                    end else begin
                                        if Muki2 = Ue then begin
                                            Ball.dZ := Ball.dZ;
                                        end else if Muki2 = Shita then begin
                                            Ball.dZ := -Ball.dZ;
                                        end;
                                        if (tgX-Ball.X) < 0 then Ball.dX := -Ball.dX;
                                    end;
                                //ロックなし
                                end else begin
                                    tX := 200;
                                    tY := 0;
                                    tZ := 0;
                                    SAngle(tX,tY,tZ,Ball.Speed);
                                    Ball.dX := tX * Muki;
                                    Ball.dY := 0;
                                    Ball.dZ := tZ;
                                    if Muki2 = Shita then Ball.dZ := -Ball.dZ;
                                end;

                                Ball.tgNo := tgNo;
                                //ダメージおよびグロッキーキャラがタゲになっても
                                //カーソルは行かない（残り一人の時の処理もあとでする）
                                if (P[ENo].DBC[Ball.tgNo mod 10].Dam_f = None)
                                and (P[ENo].DBC[Ball.tgNo mod 10].Groggy_c = 0) then begin
                                    //カーソルが変わった場合ダッシュフラグ消す
                                    if P[ENo].PNo <> Ball.tgNo mod 10 then begin
                                        P[ENo].PNo := Ball.tgNo mod 10;
                                        P[ENo].DBC[P[ENo].PNo].Dash_f := None;
                                    end;
                                end;

                                STypeSet;

                            end;
                            ActW * 7:begin
                                mNo := 107;
                                RevMuki2(i,i2);
                            end;
                        end;
                        inc(Act_c);

                    end;
                    Pa:begin
                        case Act_c of
                            ActW * 1:begin
                                if ptgX < X then Muki := Hidari;
                                if ptgX > X then Muki := Migi;
                                if Pos = 1 then begin
                                    if ptgZ < Z  then Muki2 := Shita;
                                    if ptgZ > Z  then Muki2 := Ue;
                                end;
                                mNo := 103;
                                RevMuki2(i,i2);
                            end;
                            ActW * 3:begin
                                CaSound;
                                mNo := 106;
                                RevMuki2(i,i2);
                                Ball_f := False;
                                //ボールの状態変更
                                Ball.Motion := BPass;

                                Ball.X  := X;// + (1600 * Muki);
                                Ball.Y  := Y + 1800;
                                Ball.Z  := Z;
                                Ball.Spin := -Muki * 10;

                                ptgX := P[i2].DBC[ptgNo].X;
                                ptgY := P[i2].DBC[ptgNo].Y;
                                ptgZ := P[i2].DBC[ptgNo].Z;
                                tX := Abs(ptgX-Ball.X);
                                tY := 0-Ball.Y;//0;
                                tZ := Abs(ptgZ-Ball.Z);
                                //if ((Pos = 2) or (Pos = 3))
                                //and ((ptgNo = 3) or (ptgNo = 4)) then begin
                                //    tt60_f := True;
                                //end else
                                if (Pos = 1) and (ptgNo <= 2) then begin
                                    tt60_f := True;
                                end else begin
                                    tt60_f := False;
                                end;

                                //敵のカーソルキャラ変更
                                Ball.ptgNo := ptgNo;
                                PaCurChange;

                                PAngle(tX,tY,tZ,tt60_f);
                                Ball.dX := tX;
                                Ball.dY := tY;
                                Ball.dZ := tZ;
                                if (ptgX-Ball.X) < 0 then Ball.dX := -Ball.dX;
                                if (ptgZ-Ball.Z) < 0 then Ball.dZ := -Ball.dZ;

                                P[i2].DBC[ptgNo].PCJump_c := 0;
                                //キャッチ用
                                P[i2].DBC[ptgNo].PC_c  := ((2 * Ball.dY) div GC.DBB.PAGRV) -12;
                                //タゲキャラの向き補正
                                ptgMukiSet(ptgNo);

                                //フォーメーションチェンジ
                                for i3 := 0 to 2 do begin
                                    P[ENo].DBC[i3].FormChange_f := False;
                                end;

                            end;
                            ActW * 5:if Dash_f <> None then SetSLP(i,i2);
                            ActW * 7:begin
                                ActEnd;
                            end;
                        end;

                        inc(Act_c);
                        If Act_c > (ActW * 7) then Act_c := 0;
                    end;
                    JPa:begin
                        case Act_c of
                            ActW * 1:begin
                                if ptgX < X then Muki := Hidari;
                                if ptgX > X then Muki := Migi;
                                if Pos = 1 then begin
                                    if ptgZ < Z then Muki2 := Shita;
                                    if ptgZ > Z then Muki2 := Ue;
                                end;
                                mNo := 109;
                                RevMuki2(i,i2);
                            end;
                            ActW * 3:begin
                                CaSound;
                                mNo := 112;
                                RevMuki2(i,i2);
                                Ball_f := False;
                                //ボールの状態変更
                                Ball.Motion := BPass;

                                Ball.X  := X;// + (1600 * Muki);
                                Ball.Y  := Y + 1800;
                                Ball.Z  := Z;
                                Ball.Spin := -Muki * 10;
                                {
                                if Muki2 = Ue then begin
                                    Ball.X  := Ball.X + (1200 * Muki);
                                    Ball.Z  := Ball.Z + 800;
                                    Ball.ZShoot_f := True;
                                end else if Muki2 = Shita then begin
                                    Ball.X  := Ball.X - (1200 * Muki);
                                    Ball.Z  := Ball.Z - 800;
                                    Ball.ZShoot_f := True;
                                end;
                                }
                                ptgX := P[i2].DBC[ptgNo].X;
                                ptgY := P[i2].DBC[ptgNo].Y;
                                ptgZ := P[i2].DBC[ptgNo].Z;
                                tX := Abs(ptgX-Ball.X);
                                tY := 0-Ball.Y;//0;
                                tZ := Abs(ptgZ-Ball.Z);
                                if (Pos = 1) and (ptgNo <= 2) then begin
                                    tt60_f := True;
                                end else begin
                                    tt60_f := False;
                                end;

                                //敵のカーソルキャラ変更
                                Ball.ptgNo := ptgNo;
                                PaCurChange;                           

                                eta := PAngle(tX,tY,tZ,tt60_f);
                                Ball.dX := tX;
                                Ball.dY := tY;
                                Ball.dZ := tZ;
                                if (ptgX-Ball.X) < 0 then Ball.dX := -Ball.dX;
                                if (ptgZ-Ball.Z) < 0 then Ball.dZ := -Ball.dZ;

                                //地面（投げた高さ）に戻るまでの時間
                                {
                                if (4915 < Ball.Y) then begin
                                    P[i2].DBC[ptgNo].PCJump_c := ((2 * Ball.dY) div GC.DBB.PAGRV)  - (25);
                                end else begin
                                    P[i2].DBC[ptgNo].PCJump_c := ((2 * Ball.dY) div GC.DBB.PAGRV)  - (256 div (49152 div Ball.Y))+2;
                                    if P[i2].DBC[ptgNo].PCJump_c = 0 then P[i2].DBC[ptgNo].PCJump_c := -1;
                                end;
                                }
                                P[i2].DBC[ptgNo].PCJump_c := eta - GC.DBJP.PACAJPTIME;
                                if P[i2].DBC[ptgNo].PCJump_c = 0 then P[i2].DBC[ptgNo].PCJump_c := -1;

                                //キャッチ用
                                P[i2].DBC[ptgNo].PC_c  := ((2 * Ball.dY) div GC.DBB.PAGRV) -12+2;
                                //タゲキャラの向き補正
                                ptgMukiSet(ptgNo);


                                //フォーメーションチェンジ
                                for i3 := 0 to 2 do begin
                                    P[ENo].DBC[i3].FormChange_f := False;
                                end;

                            end;
                            ActW * 7:begin
                                mNo := 107;
                                RevMuki2(i,i2);
                            end;
                        end;
                        inc(Act_c);

                    end;
                    None:begin
                        Act_c := 0;
                    end;               
                end;
            end;
            end;
        end;
    end;
end;
//アクション全般//****************************************************************************//
procedure DBBallAction;
const
    ActW = 3;
    ActW2 = 2;
    AniW_W = 8;
    baseSp = 32;
    Sun_itv = 6;
    Sun_itv2 = Sun_itv * 2;
    Sun_itv4 = Sun_itv * 4;
    Sun_wav = 40;
    Suk_wav = 40;
    Ina_itv = 4;
    Ina_itv2 = Ina_itv * 2;
    Ina_itv4 = Ina_itv * 4;
    Ina_wav = 400;
    Enn_itv = 16;
    Enn_itv2 = Enn_itv * 2;
    Enn_itv4 = Enn_itv * 4;
var
    i:integer;
    i2:integer;
    tCurve:integer;
    tX:integer;//ターゲットの座標
    tY:integer;
    tZ:integer;
    EnnSin :Real;//Z
    EnnCos :Real;//SX
    EnnRad :Real;//角度
    procedure NomalShoot;
    var
        Shooter:integer;
    begin
        Shooter := Abs(Ball.Curve div 100);

        with Ball do begin
            Y := Y + dY;
            tCurve := 0;
            if ZShoot_f = False then begin//左右のショット（上下の変化）

                //キー押しから変化まで若干間を持たす
                if ADI.DI[Shooter].CheckCrs2(cU) then begin
                //if P[Abs(Curve div 100)].KeyU2 = True then begin
                    if Curve_c < 0 then Curve_c := 0;
                    if Curve_c < 6 then inc(Curve_c);
                //end else If P[Abs(Curve div 100)].KeyD2 = True then begin
                end else If ADI.DI[Shooter].CheckCrs2(cD) then begin
                    if Curve_c > 0 then Curve_c := 0;
                    if Curve_c > -6 then dec(Curve_c);
                end else begin
                    Curve_c := 0;
                end;

                If Curve_c >= 6 then tCurve :=tCurve+(Curve mod 100)*(Speed div 32);
                If Curve_c <= -6 then tCurve :=tCurve-(Curve mod 100)*(Speed div 32);

                X := X + dX;
                Z := Z + dZ + tCurve;
                //Z := Z + dZ;

            end else begin //上下のショット（左右の変化）
                if dX > 0 then begin
                    //キー押しから変化まで若干間を持たす
                    if ADI.DI[Shooter].CheckCrs2(cR)
                    or ADI.DI[Shooter].CheckCrs2(cU) then begin
                        if Curve_c < 0 then Curve_c := 0;
                        if Curve_c < 6 then inc(Curve_c);
                    end else If ADI.DI[Shooter].CheckCrs2(cL)
                    or ADI.DI[Shooter].CheckCrs2(cD) then begin
                        if Curve_c > 0 then Curve_c := 0;
                        if Curve_c > -6 then dec(Curve_c);
                    end else begin
                        Curve_c := 0;
                    end;
                end else if dX < 0 then begin
                    //キー押しから変化まで若干間を持たす
                    if ADI.DI[Shooter].CheckCrs2(cR)
                    or ADI.DI[Shooter].CheckCrs2(cD)then begin
                        if Curve_c < 0 then Curve_c := 0;
                        if Curve_c < 6 then inc(Curve_c);
                    end else If ADI.DI[Shooter].CheckCrs2(cL)
                    or ADI.DI[Shooter].CheckCrs2(cU) then begin
                        if Curve_c > 0 then Curve_c := 0;
                        if Curve_c > -6 then dec(Curve_c);
                    end else begin
                        Curve_c := 0;
                    end;
                end else begin
                    //キー押しから変化まで若干間を持たす
                    if ADI.DI[Shooter].CheckCrs2(cR) then begin
                        if Curve_c < 0 then Curve_c := 0;
                        if Curve_c < 6 then inc(Curve_c);
                    end else If ADI.DI[Shooter].CheckCrs2(cL) then begin
                        if Curve_c > 0 then Curve_c := 0;
                        if Curve_c > -6 then dec(Curve_c);
                    end else begin
                        Curve_c := 0;
                    end;
                end;

                If Curve_c >= 6 then tCurve :=tCurve+(Abs(Curve mod 100))*8;
                If Curve_c <= -6 then tCurve :=tCurve-(Abs(Curve mod 100))*8;

                X := X + dX + tCurve;
                Z := Z + dZ;

            end;

            inc(Spin_c,Spin);
        end;
    end;
    //シュートの角度
    procedure SAngle(var mX:integer;var mY:integer;var mZ:integer;rrr:integer);
    var
        d  : Real;
        j: Real;
        eX : Real;
        eY : Real;
        eZ : Real;

    begin

        d := Hypot(mX,mY);//斜辺の長さ
        j := Hypot(d,mZ);

        if j <> 0 then begin

            eZ := ((mZ * rrr) / j);
            eX := ((mX * rrr) / j);
            eY := ((mY * rrr) / j);

            mX := Trunc(eX);
            mY := Trunc(eY);
            mZ := Trunc(eZ);

        end else begin

            mX := rrr;
            mY := 0;
            mZ := 0;

        end;

    end;
begin
    with Ball do begin

        //初期化                         
        if Ball.Motion <> BShoot then Ball.SType := None;
        if Ball.Motion <> BHold then  Ball.ptg_c := AniW_W * 6;

        case Motion of
            BFree:begin//落ちてる
                tgNo := 20;
            end;
            BHold:begin//持たれている
                for i2 := 0 to 1 do begin
                    for i := 0 to 5 do begin
                        if P[i2].DBC[i].Ball_f = True then begin
                            X := P[i2].DBC[i].X;
                            Y := P[i2].DBC[i].Y + 1800;
                            Z := P[i2].DBC[i].Z;
                            Break;
                        end;
                    end;
                end;
            end;
            BShoot:begin//しゅーと

                If Ball.SType = None then begin

                    NomalShoot;

                //必殺    
                end else begin

                    Inc(SP_c); 

                    case Ball.SType of
                        Skan:begin //貫通
                            NomalShoot;
                        end;
                        Ssun:begin //スネーク
                            //Ball.dX := Ball.Speed;
                            //if Ball.HoldChar div 10 = 1 then Ball.dX := -Ball.dX;
                            
                            if SP_c mod Sun_itv2 < Sun_itv then begin
                                Ball.dZ := (((SP_c mod Sun_itv))*Sun_wav);
                            end else begin
                                Ball.dZ := ((Sun_itv-(SP_c mod Sun_itv))*Sun_wav);
                            end;
                            if SP_c mod Sun_itv4 < Sun_itv2 then begin
                                Ball.dZ := -Ball.dZ;
                            end;
                            NomalShoot;
                        end;
                        Ssuk:begin //スクリュー
                            if SP_c mod Sun_itv4 < Sun_itv2 then begin
                                if SP_c mod Sun_itv2 < Sun_itv then begin
                                    Ball.dY := Ball.dY2 + (((SP_c mod Sun_itv))*Suk_wav);
                                end else begin
                                    Ball.dY := Ball.dY2 + ((Sun_itv-(SP_c mod Sun_itv))*Suk_wav);
                                end;
                            end else begin
                                if SP_c mod Sun_itv2 < Sun_itv then begin
                                    Ball.dY := Ball.dY2 - (((SP_c mod Sun_itv))*Suk_wav);
                                end else begin
                                    Ball.dY := Ball.dY2 - ((Sun_itv-(SP_c mod Sun_itv))*Suk_wav);
                                end;
                            end;
                            NomalShoot;
                        end;
                        Skak:begin //かっくん

                                if SP_c <= 30 then begin

                                    Ball.dZ := Ball.dZ2 div 2;

                                    if (SP_c <= 0) then begin
                                        //if (SP_c = 1)
                                        //and (Abs(P[Ball.tgNo div 10].DBC[Ball.tgNo mod 10].X-Ball.X) > 10000) then begin
                                        //   SP_c := 0;
                                        //end;
                                    end else begin
                                        if SP_c <=10 then begin
                                            Ball.dX := Ball.dX2 * (10-SP_c) div 10;
                                            Ball.dY := Ball.dY2 * (10-SP_c) div 10;
                                            Ball.dZ := Ball.dZ2 * (10-SP_c) div 20;
                                        end else if SP_c < 29 then begin
                                            Ball.dX := 0;
                                            Ball.dY := 0;
                                            Ball.dZ := 0;
                                        end else if SP_c = 30 then begin
                                            tX := Abs(P[Ball.tgNo div 10].DBC[Ball.tgNo mod 10].X-Ball.X);
                                            tY := 0 - Ball.Y;//0;
                                            tZ := Abs(P[Ball.tgNo div 10].DBC[Ball.tgNo mod 10].Z-Ball.Z);
                                            SAngle(tX,tY,tZ,Ball.Speed * 20 div 10);
                                            Ball.dX := tX;
                                            Ball.dY := (1800 - Ball.Y) div 8;
                                            Ball.dZ := tZ;
                                            if (P[Ball.tgNo div 10].DBC[Ball.tgNo mod 10].X-Ball.X) < 0 then begin
                                                Ball.dX := -Ball.dX;
                                            end;
                                            if (P[Ball.tgNo div 10].DBC[Ball.tgNo mod 10].Z-Ball.Z) < 0 then begin
                                                Ball.dZ := -Ball.dZ;
                                            end;
                                            Ball.HoldChar := (Ball.HoldChar div 10) * 10 + 5;
                                        end;
                                    end;

                                    NomalShoot;
                                    
                                end else begin

                                    NomalShoot;

                                end;

                        end;
                        Sobu:begin //おぶおぶ
                            //誘導
                            if (Ball.SP_c mod 2 = 0)
                            and (((P[Ball.tgNo div 10].DBC[Ball.tgNo mod 10].X >= Ball.X) and (Ball.dX >= 0))
                            or ((P[Ball.tgNo div 10].DBC[Ball.tgNo mod 10].X <= Ball.X) and (Ball.dX <= 0))) then begin

                                tX := Abs(P[Ball.tgNo div 10].DBC[Ball.tgNo mod 10].X-Ball.X);
                                tY := 0-Ball.Y;//0;
                                tZ := Abs(P[Ball.tgNo div 10].DBC[Ball.tgNo mod 10].Z-Ball.Z);
                                SAngle(tX,tY,tZ,Ball.Speed);
                                if Ball.dX <> 0 then begin
                                    Ball.dX := tX * (Abs(Ball.dX) div Ball.dX);
                                end;
                                if (Ball.dY <> 0) and (Ball.dY < tY) then begin
                                    Ball.dY := tY;
                                end;
                                Ball.dZ := tZ;
                                if (P[Ball.tgNo div 10].DBC[Ball.tgNo mod 10].Z-Ball.Z) < 0 then begin
                                    Ball.dZ := -Ball.dZ;
                                end;
                                //カーブ限界
                                if Abs(Ball.dX) < (Abs(Ball.dX2) div 2) then begin
                                    Ball.dX := Ball.dX2 div 2;
                                end;
                                if Abs(Ball.dZ) < (Abs(Ball.dZ2) div 2) then begin
                                    Ball.dZ := Ball.dZ2 div 2;
                                end;

                            end;
                            NomalShoot;
                        end;
                        Sapp:begin //アッパー
                            
                            if ((X >= 35200) and (Ball.HoldChar div 10 = 0))
                            or ((X <=  8000) and (Ball.HoldChar div 10 = 1)) then begin
                                SP_c := 10;
                            end;

                            if SP_c < 10 then begin
                                SP_c := 0;
                            end else if SP_c >= 10 then begin
                                dY := dY + 50;
                            end;
                            
                            NomalShoot;

                            if Y >= 28000 then begin
                                Spin := -(Spin div 4);
                                SE(14);
                                dX := 0;
                                dZ := 0;
                                dY := 0;
                                Motion := BBound;
                            end;
                        end;
                        Swaa:begin //ワープ
                            NomalShoot;
                            If SP_c = 24 then begin
                                Ball.dX := Ball.dX * 4;
                                Ball.dZ := Ball.dZ * 4;
                                Ball.dY := Ball.dY * 4;
                            end;
                        end;
                        Sbuu:begin //ブーメラン
                            if SP_c = 1 then begin
                                if ((Ball.X < (43200 - 9600)) and (Ball.HoldChar div 10 = 0))
                                or ((Ball.X > (9600)) and (Ball.HoldChar div 10 = 1)) then begin
                                    Ball.dY := (12000 - Ball.Y) div 8;
                                    NomalShoot;
                                    SP_c := 0;
                                end else begin
                                    inc(Spin_c,Spin);
                                end;
                            end else if SP_c <= Enn_itv2 then begin
                                EnnRad := (2 * PI) * ((SP_c mod Enn_itv4) / Enn_itv4);
                                EnnSin := Sin(EnnRad);//X系
                                EnnCos := Cos(EnnRad);//Z系
                                Ball.dY := -Trunc(500 * EnnSin);
                                if Y <= 1900 then Ball.dY := 0;
                                Ball.dX := Trunc(Ball.dX2* EnnCos);
                                Ball.dZ := Trunc(Ball.dZ2* EnnCos);
                                Ball.HoldChar := (Ball.HoldChar div 10) * 10 + 5;
                                NomalShoot;
                            end else begin
                                Ball.dX := -Ball.dX2;
                                Ball.dZ := -Ball.dZ2;
                                Ball.dY := 0;//(1800 - Ball.Y) div 8;
                                NomalShoot;
                            end;
                        end;
                        Senn:begin //円輪
                            //現在の角度
                            EnnRad := (2 * PI) * ((SP_c mod Enn_itv4) / Enn_itv4);

                            EnnSin := Sin(EnnRad);//X系
                            if Ball.dX2 < 0 then EnnSin := -EnnSin;
                            EnnCos := Cos(EnnRad);//Z系
                            Ball.dX := Trunc(32* 8 * EnnSin);
                            if (SP_c mod Enn_itv4) < Enn_itv2 then Ball.dX := Ball.dX * 2;
                            Ball.dZ := Trunc(32* 8 * EnnCos);
                            Ball.dY := Ball.dY2 div 3;

                            NomalShoot;
                        end;
                
                        //ジャンプ系
                        Snat:begin //ナッツ
                            NomalShoot;
                        end;
                        Sbun:begin //分裂
                            NomalShoot;
                        end;
                        Sina:begin //稲妻
                            if SP_c mod Ina_itv4 < Ina_itv2 then begin
                                if SP_c mod Ina_itv2 < Ina_itv then begin
                                    Ball.dY := Ball.dY2 + Ina_wav;
                                    NomalShoot;
                                end else begin
                                    //Ball.dY := Ball.dY2 - Ina_wav;
                                end;
                            end else begin
                                if SP_c mod Ina_itv2 < Ina_itv then begin
                                    Ball.dY := Ball.dY2 - Ina_wav;
                                    NomalShoot;
                                end else begin
                                    //Ball.dY := Ball.dY2 - Ina_wav;
                                end;
                            end;                        

                        end;
                        Smoz:begin //百舌落とし all tongue drop

                            if SP_c < 0 then begin
                                if Ball.Y < 24000 then begin
                                    dec(SP_c); 
                                    Ball.dY := 600;
                                    Ball.dZ := 0;
                                    Ball.dX := 0;
                                    NomalShoot;
                                end else begin
                                    //ロックありの時 ロックありの時
                                    If Ball.tgNo < 20 then begin
                                        Ball.dY := 0;
                                        Ball.dX := ((P[Ball.tgNo div 10].DBC[Ball.tgNo mod 10].X-Ball.X) div GC.DBB.STSPDmozMOVESP);
                                        Ball.dZ := ((P[Ball.tgNo div 10].DBC[Ball.tgNo mod 10].Z-Ball.Z) div GC.DBB.STSPDmozMOVESP);
                                    //ロックなしの時は通常シュートと同じように飛ぶ  When not locked, it flies like a normal shoot
                                    end else begin
                                        Ball.dY := 0;
                                        Ball.dX := Ball.dX2;
                                        Ball.dZ := Ball.dZ2;
                                    end;
                                    
                                    NomalShoot;
                                end;
                            end else if SP_c = 0 then begin
                                Ball.dY := -GC.DBB.STSPDmozDOWNSP;
                                Ball.dX := ((P[Ball.tgNo div 10].DBC[Ball.tgNo mod 10].X-Ball.X) div 24) + P[Ball.tgNo div 10].DBC[Ball.tgNo mod 10].dX;
                                Ball.dZ := ((P[Ball.tgNo div 10].DBC[Ball.tgNo mod 10].Z-Ball.Z) div 24) + P[Ball.tgNo div 10].DBC[Ball.tgNo mod 10].dZ;
                                NomalShoot;
                            end else begin
                                Ball.dY := -GC.DBB.STSPDmozDOWNSP;
                                NomalShoot;
                            end;
                        end;
                        Sass:begin //圧縮
                            NomalShoot;
                        end;
                        Skas:begin //加速
                            if Ball.Y > 1800 then begin
                                Ball.dY := -GC.DBB.STSPDkasDOWNSP;
                                if Ball.Y - GC.DBB.STSPDkasDOWNSP < 1800 then begin
                                    Ball.dY := 1800 - Ball.Y;
                                end;
                            end else begin
                                Ball.dY := 0;
                            end;

                            Ball.dX := Ball.dX2 * SP_c div GC.DBB.STSPDkasRATE;
                            Ball.dZ := Ball.dZ2 * SP_c div GC.DBB.STSPDkasRATE;
                            NomalShoot;
                        end;
                        Sbuy:begin //ぶよぶよ Fluffy
                            NomalShoot;
                        end;
                        Shoe:begin //ほえほえ Hoehoe
                            NomalShoot;
                        end;
                    end;


                end;
                
                //着地
                If GameSet_c <> 0 then begin
                    if Y <= 0 then begin
                        Y := 0;
                        Spin := -(Spin div 4);
                        SE(14);
                        dX := dX div 10;
                        dZ := dZ div 10;
                        dY := 200;
                        NextBount_f := False;
                        Motion := BBound;
                    end;
                end;
            end;
            BPass:begin//パス path

                tgNo := 20;
                X := X + dX;
                Y := Y + dY;
                Z := Z + dZ;
                inc(Spin_c,Spin);
                if (dY > 500) and (Spin_c >= 100) then Spin_c := 99;

                if Y >= 500 then NextBount_f := True;
                dec(dY,GC.DBB.PAGRV);
                if Y <= 0 then begin
                    Y := 0;
                    Motion := BBound;
                    SE(14);
                    if NextBount_f = True then begin
                        dY := -(dY * 4 div 5)-20;
                        dX := dX div 6;
                        dZ := dZ div 6;
                        NextBount_f := False;
                    end else begin
                        dY := 0;
                        dX := 0;
                        dZ := 0;
                        Motion := BFree;
                    end;
                end;
            end;
            BBound:begin//バウンド bound
                tgNo := 20;
                X := X + dX;
                Y := Y + dY;
                Z := Z + dZ;
                inc(Spin_c,Spin);
                if (dY > 500) and (Spin_c >= 100) then Spin_c := 99;

                if Y >= 500 then NextBount_f := True;
                dec(dY,Grv);
                if Y <= 0 then begin
                    Y := 0;
                    SE(14);
                    if NextBount_f = True then begin
                        dY := -(dY * 4 div 5)-20;
                        dX := dX div 6;
                        dZ := dZ div 6;
                        NextBount_f := False;
                    end else begin
                        dY := 0;
                        dX := 0;
                        dZ := 0;
                        Motion := BFree;
                        P[0].PNo := 20;
                        P[1].PNo := 20;
                    end;
                end;
            end;
        end;
        if Motion <> BHold then begin
            //強引な位置補正  Forced position correction
            if X > 43200 then begin
                X := 43200;
                dX := -dX div 4;
                dY := 0;
                Motion := BBound;
            end;
            if X < 0 then begin
                X := 0;
                dX := -dX div 4;
                dY := 0;
                Motion := BBound;
            end;
            if Z > 11200 then begin
                Z := 11200;
                dZ := -dZ div 4;
                Motion := BBound;
            end;
            if Z < 0 then begin
                Z := 0;
                dZ := -dZ div 4;
                Motion := BBound;
            end;
        end;
    end;
end;

//判定//****************************************************************************//
procedure DBJudge;
const
    ActW = 3;
    ActW2 = 2;
    CPUWait = 5;
    CPUWait2= 2;
    BunAni = 24;
    BunAni2 = BunAni div 6;
var
    i:integer;
    i2:integer;
    RevXMuki:integer;
    Catch_f :boolean;
    j:integer;
    Dam :integer;
    DefLv:integer;
    procedure KuraiSet();
    begin
        with P[i2].DBC[i] do begin
            //キャラの判定  judgment of character
            Kurai := Bounds((X div 100)-7,(Y div 100),16,27);
            //しゃがみ Crouching
            if (Act_f = Crm) and ((mNo = 14) or (mNo = 114) or (mNo = 214)) then begin
                Kurai := Bounds((X div 100)-7,(Y div 100),16,17);
            end else if (Act_f = Crm) and ((mNo = 13) or (mNo = 113) or (mNo = 213)) then begin
                Kurai := Bounds((X div 100)-7,(Y div 100),16,20);
            end;
            //ダウン中の判定補正 Judgment correction while down
            if (mNo = 308) then begin
                Kurai.Bottom := Kurai.Bottom -20;
                if Muki = Migi then begin
                    Kurai.Left := Kurai.Left - 16;
                end else begin
                    Kurai.Right := Kurai.Right + 16;
                end;
            end else if (mNo = 404) then begin
                Kurai.Bottom := Kurai.Bottom -20;
                if Muki = Migi then begin
                    Kurai.Right := Kurai.Right + 16;
                end else begin
                    Kurai.Left := Kurai.Left - 16;
                end;
            end;
        end;
    end;
begin
    
    //ボールの判定 ball judgment
    Ball.Atari := Bounds((Ball.X div 100)-6,(Ball.Y div 100),12,12);
    //分裂シュートの判定補正 Judgment correction of split shoot
    if Ball.SType = Sbun then begin
        if (Ball.SP_c mod BunAni < BunAni2 * 3)
        or (Ball.SP_c mod BunAni < BunAni2 * 5) then begin
            Ball.Atari.Top := Ball.Atari.Top - 4;
            Ball.Atari.Bottom := Ball.Atari.Bottom + 4;
        end else if Ball.SP_c mod BunAni < BunAni2 * 4 then begin
            Ball.Atari.Top := Ball.Atari.Top - 8;
            Ball.Atari.Bottom := Ball.Atari.Bottom + 8;
        end;
    end;

    for i2 := 0 to 1 do begin
        for i := 0 To 5 do begin
            with P[i2].DBC[i] do begin
                if Dead_f = False then begin
                    if Dam_f <> D2 then begin
                        If ((Ball.Motion = BFree) or (Ball.Motion = BBound)
                        or ((Ball.Motion = BPass) and (Ball.HoldChar div 10 = i2))) then begin
                            //向きによる補正 Orientation Correction
                            RevXMuki := 8;
                            if Muki2 <> None then RevXMuki := (RevXMuki div 2);
                            //キャラの判定 judgment of character
                            Kurai := Bounds((X div 100)-7,(Y div 100)+11,16,16);
                            If Muki = Migi   then Kurai.Right := Kurai.Right + RevXMuki;
                            If Muki = Hidari then Kurai.Left  := Kurai.Left  - RevXMuki;

                            if (Groggy_c = 0) 
                            and ((Take_f = True) or ((Ball.Motion = BPass) and (i = Ball.ptgNo)))
                            and ((Ball.Z div 100) <= (Z div 100) + 6)
                            and ((Ball.Z div 100) >= (Z div 100) - 6)
                            and (Kurai.Left   < Ball.Atari.Right )
                            and (Kurai.Right  > Ball.Atari.Left  )
                            and (Kurai.Top    < Ball.Atari.Bottom)
                            and (Kurai.Bottom > Ball.Atari.Top   ) then begin

                                SE(12);

                                Ball.Motion := BHold;
                                //ＣＰＵの間
                                If CPU_f = True then begin
                                    {
                                    if Pos = 1 then begin

                                        C[i].Move_c := CPUWait+Random(10);
                                    end else begin
                                        C[i].Move_c := CPUWait2+Random(10);
                                    end;
                                    }

                                    C[i].Move_c := GC.DBCPU.THINKTIME;
                                end;

                                Ball_f := True;
                                Take_f := False;
                                If Act_f = Ca then begin
                                    //Act_c := ((ActW * 1) + dCT);
                                    Act_c := (GC.DBCA.CASTTIME + GC.DBCA.CABF + (dCT * GC.DBCA.CASF div 100));
                                    mNo := 100;
                                    RevMuki2(i,i2);
                                end else If Act_f = JCa then begin
                                    Act_c := 0;
                                    Act_f := None;
                                end;

                            end;
                        //パスヒット pass hit
                        end else if (Ball.Motion = BPass) then begin

                            KuraiSet;
                            
                            if (Dam_f = None)
                            and ((Ball.Z div 100) <= (Z div 100) + 6)
                            and ((Ball.Z div 100) >= (Z div 100) - 6)
                            and (Kurai.Left   < Ball.Atari.Right )
                            and (Kurai.Right  > Ball.Atari.Left  )
                            and (Kurai.Top    < Ball.Atari.Bottom)
                            and (Kurai.Bottom > Ball.Atari.Top   ) then begin

                                Catch_f := True;
                                //キャッチ判定  catch judgment
                                //モーション motion
                                if (Catch_c = 0) then Catch_f := False;
                                if Not ((Act_f = Ca) or (Act_f = JCa)) then begin
                                    Catch_f := False;
                                end;
                                //上下
                                if ((Ball.dZ >= 100)  and (Muki2 = Ue))
                                or ((Ball.dZ <= -100) and (Muki2 = Shita)) then begin
                                    Catch_f := False;
                                end;

                                //左右
                                if ((Ball.dX >= 100) and (Muki = Migi))
                                or ((Ball.dX <= -100) and (Muki = Hidari)) then begin
                                    Catch_f := False;
                                end;
                                //キャッチ catch
                                if Catch_f = True then begin

                                    SE(15);//6弱　15強　16滑り

                                    //ＣＰＵの間
                                    If CPU_f = True then begin
                                        {
                                        if Pos = 1 then begin
                                            C[i].Move_c := CPUWait+Random(10);
                                        end else begin
                                            C[i].Move_c := CPUWait2+Random(10);
                                        end;
                                        }

                                        C[i].Move_c := GC.DBCPU.THINKTIME;
                                    end;

                                    Ball.Motion := BHold;
                                    if Ball.ZShoot_f = True then begin
                                        if Ball.dZ > 0 then Muki2 := Shita;
                                        if Ball.dZ < 0 then Muki2 := Ue;
                                    end else begin
                                        Muki2 := None;
                                    end;

                                    Ball_f := True;
                                    Catch_c := 0;
                                    Take_f := False;
                                    If Act_f = Ca then begin
                                        //Act_c := ((ActW * 1) + dCT);
                                        Act_c := (GC.DBCA.CASTTIME + GC.DBCA.CABF + (dCT * GC.DBCA.CASF div 100));
                                        RevMuki2(i,i2);
                                    end else If Act_f = JCa then begin
                                        Act_c := 0;
                                        Act_f := None;
                                    end;

                                    //Motion := SLP2;
                                    mNo := 101;
                                    RevMuki2(i,i2);

                                    //dX := Ball.dX;
                                    //dZ := Ball.dZ;
                                    If Slip_f <> None then dX := (dX div 2);
                                    Slip_c := 1;
                                    Dash_f := None;

                                //ヒット  hit
                                end else begin

                                    DamLv := 0;
                                    SE(7);
                                    dX := 50;
                                    dY := 150;

                                    if Ball.dZ <> 0 then begin
                                        j := Trunc(Sqrt(Sqr(Ball.dX) + Sqr(Ball.dZ)));
                                        dZ := Abs(dX * ((Ball.dZ * 100) div j)) div 200;
                                        dX := Abs(dX * ((Ball.dX * 100) div j)) div 100;
                                    end;

                                    if Ball.dX <= 0 then dX := -dX;
                                    if Ball.dZ <= 0 then dZ := -dZ;

                                    if Jump_f = None then begin
                                        mNo := 405;
                                        Dam_f := D5;
                                    end else begin
                                        mNo := 405;
                                        RollMuki := Bakuten;
                                        if ((Ball.dX <= 0) and (Muki = Hidari))
                                        or ((Ball.dX >= 0) and (Muki = Migi)) then begin
                                            mNo := 406;
                                            RollMuki := Zenten;
                                        end;
                                        Dam_f := D2;
                                        Jump_f := None;
                                    end;
                                    if dHP <= 8 then begin
                                        Groggy_c := 120;
                                    end;
                                    Act_f := None;
                                    Act_c := 0;
                                    Catch_c := 0;
                                    Take_f := False;
                                    RefWall_f := False;
                                    Ball.Motion := BBound;
                                    Ball.dX := 0;
                                    Ball.dZ := 0;
                                    Ball.dY := 0;
                                end;

                            end;
                        end else If (Ball.Motion = BShoot) then begin

                            KuraiSet;

                            if ((Ball.Z div 100) <= (Z div 100) + 6)
                            and ((Ball.Z div 100) >= (Z div 100) - 6)
                            and (Kurai.Left   < Ball.Atari.Right )
                            and (Kurai.Right  > Ball.Atari.Left  )
                            and (Kurai.Top    < Ball.Atari.Bottom)
                            and (Kurai.Bottom > Ball.Atari.Top   ) then begin

                                //味方キャッチ ally catch
                                if (i2 = (Abs(Ball.Curve div 100))) then begin
                                    if P[i2].DBC[(Ball.HoldChar mod 10)].Pos <> Pos then begin

                                        SEStop2(2);
                                        SEStop2(27);
                                        SE(12);

                                        //ＣＰＵの間
                                        If CPU_f = True then begin
                                            {
                                            if Pos = 1 then begin
                                                C[i].Move_c := CPUWait+Random(10);
                                            end else begin
                                                C[i].Move_c := CPUWait2+Random(10);
                                            end;
                                            }

                                            C[i].Move_c := GC.DBCPU.THINKTIME;
                                        end;
                                        Ball.Motion := BHold;

                                        Ball_f := True;
                                        Take_f := False;
                                        If Act_f = Ca then begin
                                            //Act_c := ((ActW * 1) + dCT);
                                            Act_c := (GC.DBCA.CASTTIME + GC.DBCA.CABF + (dCT * GC.DBCA.CASF div 100));
                                            mNo := 100;
                                            RevMuki2(i,i2);
                                        end else If Act_f = JCa then begin
                                            Act_c := 0;
                                            Act_f := None;
                                        end;
                                    end;
                                end else begin


                                    Catch_f := True;
                                    //キャッチ判定 catch judgment
                                    //モーション motion
                                    if (Catch_c = 0) then Catch_f := False;
                                    if Not ((Act_f = Ca) or (Act_f = JCa)) then begin
                                        Catch_f := False;
                                    end;
                                    //上下
                                    if ((Ball.dZ >= 100)  and (Muki2 = Ue))
                                    or ((Ball.dZ <= -100) and (Muki2 = Shita)) then begin
                                        Catch_f := False;
                                    end;

                                    //左右
                                    if ((Ball.dX >= 100) and (Muki = Migi))
                                    or ((Ball.dX <= -100) and (Muki = Hidari)) then begin
                                        Catch_f := False;
                                    end;

                                    SEStop2(2);
                                    SEStop2(27);

                                    //キャッチ catch
                                    if Catch_f = True then begin
                                    
                                        SE(15);//6弱　15強　16滑り
                                        {
                                        if Ball.Speed >= 16 * 32 then begin
                                            SE(16);//6弱　15強　16滑り
                                        end else if Ball.Speed <= 8 * 32 then begin
                                            SE(6);//6弱　15強　16滑り
                                        end else begin
                                            SE(15);//6弱　15強　16滑り
                                        end;
                                        }
                                        //ＣＰＵの間
                                        If CPU_f = True then begin
                                            {
                                            if Pos = 1 then begin
                                                C[i].Move_c := CPUWait+Random(10);
                                            end else begin
                                                C[i].Move_c := CPUWait2+Random(10);
                                            end;
                                            }
                                            C[i].Move_c := GC.DBCPU.THINKTIME;
                                        end;

                                        Ball.Motion := BHold;
                                        
                                        if Ball.ZShoot_f = True then begin
                                            if Ball.dZ > 0 then Muki2 := Shita;
                                            if Ball.dZ < 0 then Muki2 := Ue;
                                        end else begin
                                            Muki2 := None;
                                        end;

                                        Ball_f := True;
                                        Catch_c := 0;
                                        Take_f := False;
                                        If Act_f = Ca then begin
                                            Act_c := (GC.DBCA.CASTTIME + GC.DBCA.CABF + (dCT * GC.DBCA.CASF div 100));
                                            //Act_c := ((ActW * 1) + dCT);
                                            RevMuki2(i,i2);
                                        end else If Act_f = JCa then begin
                                            Act_c := 0;
                                            Act_f := None;
                                        end;

                                        SetSLP(i,i2); 

                                        Motion := SLP2;
                                        mNo := 101;
                                        RevMuki2(i,i2);

                                        dX := Ball.dX;
                                        dZ := Ball.dZ;
                                        If Slip_f <> None then dX := (dX div 2);
                                        Slip_c := 100;
                                        Dash_f := None;

                                    //ヒット hit
                                    end else begin

                                        //ダウン中はそのまま(一定ダメ以下) While down (less than a certain amount of damage)
                                        if ((mNo <> 308) and (mNo <> 404))
                                        or (Ball.SType <> None)
                                        or (Ball.PowLv >= 3) then begin
                                        //or ((Ball.SType = Skan) or (Ball.SType = Sapp) or (Ball.SType = Senn)) then begin
                                            if (Ball.SType = Smoz)
                                            or ((Ball.dX = 0) and (Ball.dZ = 0)) then begin//止まったかっくん

                                                SE(23);
                                                dY := 700;
                                                DamLv := 1;
                                                if Ball.dZ > 0 then begin
                                                    dZ := 200;
                                                end else begin
                                                    dZ := -200;
                                                end;
                                                dX := Ball.dX;
                                                mNo := 406;
                                                RollMuki := Zenten;

                                                Dam_f := D2;
                                            
                                            end else begin
                                                DamLv := 0;
                                                case Ball.PowLv of
                                                    0:begin
                                                        SE(7);
                                                        dX := 100;
                                                        dY := 200;
                                                    end;
                                                    1:begin
                                                        SE(7);
                                                        dX := 150;
                                                        dY := 200;
                                                    end;
                                                    2:begin
                                                        SE(7);
                                                        dX := 200;
                                                        dY := 250;
                                                    end;
                                                    3:begin
                                                        SE(23);
                                                        dX := 275;
                                                        dY := 325;
                                                        DamLv := 1;
                                                    end;
                                                    4:begin
                                                        SE(23);
                                                        dX := 400;
                                                        dY := 500;
                                                        DamLv := 1;
                                                    end;
                                                    5:begin
                                                        SE(23);
                                                        dX := 500;
                                                        dY := 700;
                                                        DamLv := 2;
                                                    end;
                                                    else begin
                                                        SE(23);
                                                        dX := 350;
                                                        dY := 400;
                                                    end;
                                                end;
                                                if (Ball.SType = Sapp) then begin
                                                    dX := 230;
                                                    dY := 800;
                                                end;

                                                if Ball.dZ <> 0 then begin
                                                    j := Trunc(Sqrt(Sqr(Ball.dX) + Sqr(Ball.dZ)));
                                                    dZ := Abs(dX * ((Ball.dZ * 100) div j)) div 200;
                                                    dX := Abs(dX * ((Ball.dX * 100) div j)) div 100;
                                                end;
                                                if Ball.dX < 0 then dX := -dX;
                                                if Ball.dZ < 0 then dZ := -dZ;
                                                mNo := 405;
                                                RollMuki := Bakuten;
                                                if ((Ball.dX < 0) and (Muki = Hidari))
                                                or ((Ball.dX > 0) and (Muki = Migi)) then begin
                                                    mNo := 406;
                                                    RollMuki := Zenten;
                                                end;

                                                Dam_f := D2;

                                            end;

                                        //ダウン中ダメージ  damage while down
                                        end else begin

                                            SE(7);
                                            
                                        end;

                                        //ダメージ（Ceil切り上げ Floor切り下げ） Damage (Ceil round up Floor round down)
                                        if dGu >= 15 then begin
                                            //Dam := Trunc(Ball.Pow - Ceil(Ball.Pow*9/10));
                                            if Ball.Pow >= 17 then begin
                                                Dam := 2;
                                            end else begin
                                                Dam := 1;
                                            end;
                                        end else if dGu >= 12 then begin
                                            Dam := Trunc(Ball.Pow - Ceil(Ball.Pow*6/10));
                                        end else if dGu >= 10 then begin
                                            Dam := Trunc(Ball.Pow - Ceil(Ball.Pow*3/10));
                                        end else if dGu >= 7 then begin
                                            Dam := Ball.Pow;
                                        end else if dGu >= 5 then begin
                                            Dam := Trunc(Ball.Pow + Ceil(Ball.Pow*(1/3)));
                                        end else begin
                                            Dam := Trunc(Ball.Pow + Ceil(Ball.Pow*(2/3)));
                                        end;
                                        //ハンディ　ダメージカット（端数切り上げ) Handicap damage cut (fractions rounded up)
                                        //-30％
                                        if HDCDt[i2,1] = 1 then begin
                                            Dam := Ceil(Dam - (Dam * 0.3));
                                        //-50％
                                        end else if HDCDt[i2,1] = 2 then begin
                                            Dam := Ceil(Dam / 2);
                                        end;

                                        if Dam <= 0 then Dam := 1;

                                        if Pos = 1 then dHP := dHP - Dam;
                                        if dHP <= 0 then begin
                                            dHP := 0;
                                        end else if dHP <= 8 then begin
                                            Groggy_c := 120;
                                        end;

                                        damDt := Dam;
                                        dam_c := 40;
                                        damX := X;
                                        damY := Y + 3600;
                                        damZ := Z;

                                        Jump_f := None;
                                        Act_f := None;
                                        Act_c := 0;
                                        Catch_c := 0;
                                        Take_f := False;

                                        RefWall_f := False;
                                        if (Ball.SType <> Skan) and (Ball.SType <> Sapp)
                                        and (Ball.SType <> Senn) then begin

                                            Ball.Motion := BBound;
                                            Ball.SType := None;
                                            Ball.dX := -(Ball.dX div 6);
                                            Ball.dZ := -(Ball.dZ div 6);
                                        
                                            case Ball.PowLv of
                                                0:begin
                                                    Ball.dY := 150;
                                                end;
                                                1:begin
                                                    Ball.dY := 170;
                                                end;
                                                2:begin
                                                    Ball.dY := 190;
                                                end;
                                                3:begin
                                                    Ball.dY := 230;
                                                end;
                                                4:begin
                                                    Ball.dY := 230;
                                                end;
                                                5:begin
                                                    Ball.dY := 230;
                                                end;
                                                else begin
                                                    Ball.dY := 230;
                                                end;
                                            end;
                                        end else begin
                                            //貫通団の威力減衰 Power reduction of penetrating
                                            Ball.Pow := ((Ball.Pow * 8) div 10);                                            
                                            if (Ball.SType = Sapp) then begin
                                                Ball.SP_c := 10;
                                                Ball.dX := Ball.dX div 2;
                                                Ball.dY := Ball.dY+150;
                                            end;
                                        end;

                                        //ダウン中ダメージの場合、ここで死亡判定 In the case of down damage, death judgment here
                                        if ((mNo = 308) or (mNo = 404)) and (dHP = 0) then begin
                                            if i2 = 0 then NODead_f := False;//ラスボスへの挑戦権消滅 Lost the right to challenge the final boss
                                            Dead_f := True;//
                                            Holy_c := 30;
                                            HolyX := X;
                                            HolyY := Y-1000;
                                            HolyZ := Z;
                                            SE(11);
                                            inc(P[i2].Dead_c);
                                            if P[i2].Dead_c >= 3 then AllDead;
                                        end;


                                    end;
                                end;

                            end;
                        end;
                    end;
                end;
            end;
        end;
    end;
    for i2 := 0 to 1 do begin
        for i := 0 To 5 do begin
            with P[i2].DBC[i] do begin
                if Ball_f = True then begin
                    Ball.HoldChar := ((i2 * 10) + i);
                    Break;
                end;
            end;
        end;
    end;
    //シュートの場合ここで初めてボール着地  シュートの場合ここで初めてボール着地
    with Ball do begin
        If Motion = BShoot then begin
            if Y <= 0 then begin
                Y := 0;
                Spin := -(Spin div 4);
                SE(14);
                dX := dX div 10;
                dZ := dZ div 10;
                dY := 200;
                NextBount_f := False;
                Motion := BBound;
            end;
        end;
    end;
end;

end.
