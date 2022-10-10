unit CPUUnit;//ＣＰＵルーチン部分のコード

interface
uses
    Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
    Dialogs, MMsystem, IniFiles, StrUtils,
    Math,DBClass;

    procedure CPUSet(i:integer;i2:integer;Team:integer);

implementation

uses Main,DBUnit,VarUnit,Types;

procedure CPUSet(i:integer;i2:integer;Team:integer);
    var
        i3 :integer;
        AtOK_f:boolean;//攻撃許可

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
    var
        CPos:integer;
        CPos2:integer;
    begin
        with P[i2].DBC[i] do begin

            CPos := CFP[dNo div 10];

            if CPos = 1 then begin//前
                CPos2 := 2000;
            end else if CPos = 2 then begin//後ろ
                CPos2 := 0;
            end else begin//キャプのみ後ろ
                //キャプ
                if dNo mod 10 = 0 then begin
                    CPos2 := 0;
                //雑魚
                end else begin
                    CPos2 := 2000;
                end;
            end;

            FormChange_f := True;

            if (Ball.Motion = BPass) then begin
                FormNo := P[0].DBC[Ball.ptgNo].Pos;
            end else if (Ball.Motion = BHold) then begin
                FormNo := P[0].DBC[Ball.HoldChar mod 10].Pos;
            end;

            case FormNo of
                2:begin
                    tfX := 5000+Random(5000)+(5000 * i);
                    tfZ := 3000+Random(1000)+CPos2;
                end;
                3:begin
                    tfX := 5000+Random(5000)+(5000 * i);
                    tfZ := 8000+Random(1000)-CPos2;
                end;
                4:begin
                    tfX := 20000+Random(1000)-CPos2;
                    tfZ := 2200+Random(2000)+(2000 * i);
                end;
                else begin
                    tfX := 5000+Random(1000)+CPos2;
                    tfZ := 2200+Random(2000)+(2000 * i);
                end;
            end;

            tfX := 43200 - tfX;
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

            if (Ball.Motion = BHold) and (Pos = 1)
            and (FormNo <> P[0].DBC[Ball.HoldChar mod 10].Pos) then begin
                SetFormSet;
            end;

            C[i].Order2 := None;

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
    //回避行動
    procedure Kaihi();

    begin

        //守備行動の指定
        if C[i].Order2 = None then begin

            //キャッチ

            If Per100(GC.DBCPU.DEFCARATIO) then begin
                C[i].Order2 := C2Ca;
                If (Per100(50)) and (Ball.SType = Sbuu) then C[i].Order2 := C2Cr;
            //避け
            end else begin
                //しゃがみ
                If Per100(GC.DBCPU.DEFDGRATIO) then begin
                    C[i].Order2 := C2Cr;
                //ジャンプ
                end else If Per100(GC.DBCPU.DEFJPRATIO) then begin

                    C[i].Order2 := C2Jp;
                end else begin
                    C[i].Order2 := C2NG;
                end;
            end;
            {
            If Per100(CCaP[Team] * 10) then begin
                C[i].Order2 := C2Ca;
                If (Per100(50)) and (Ball.SType = Sbuu) then C[i].Order2 := C2Cr;
            //避け
            end else begin
                //しゃがみ
                If Per100(CCrP[Team] * 10) then begin
                    C[i].Order2 := C2Cr;
                    If Ball.dY <> 0 then begin
                        If Per100(CCaP[Team] * 10) then begin
                            C[i].Order2 := C2Ca;
                        end else begin
                            If Per100(CCrP[Team] * 10) then begin
                                C[i].Order2 := C2Cr;
                            end else begin
                                C[i].Order2 := C2Jp;
                            end;
                        end;
                    end;
                //ジャンプ
                end else begin

                    C[i].Order2 := C2Jp;

                end;
            end;
            }
        end;

        with P[i2].DBC[i] do begin

            Dash_f := None;

            if Act_f = None then begin
                if (Ball.dX > 100) and (Ball.X < X - 1000) then begin
                    Muki := Hidari;
                end else if (Ball.dX < -100) and (Ball.X > X + 1000) then begin
                    Muki := Migi;
                end;
                if Ball.dZ > 1000 then begin
                    Muki2 := Shita;
                end else if Ball.dZ < -1000 then begin
                    Muki2 := Ue;
                end;
            end;
            case C[i].Order2 of
                C2Ca:begin
                    if Stage = 9 then begin
                        //キャッチ
                        if (X + (3200 + Abs(Ball.dX)*3) > Ball.X) and (X - (3200 + Abs(Ball.dX)*3) < Ball.X)
                        and (Z + 3200 > Ball.Z) and (Z - 3200 < Ball.Z)
                        and (Y + 9600 + Abs(Ball.dY) > Ball.Y) and (Y - 9600 + Abs(Ball.dY) < Ball.Y)
                        and (Act_f = None)
                        //and (LvPer100(30))
                        then begin
                            Act_f := Ca;
                            Act_c := 0;
                            If Ball.SType = Sbuu then begin
                                if Ball.Y < 3200 then begin
                                    Muki := Migi;
                                end else begin
                                    Act_f := None;
                                end;
                            end;
                        end;
                    end else begin
                        //キャッチ
                        if (X + (3600 + Abs(Ball.dX)*2) > Ball.X) and (X - (3600 + Abs(Ball.dX)*2) < Ball.X)
                        and (Z + 3200 > Ball.Z) and (Z - 3200 < Ball.Z)
                        and (Y + 9600 > Ball.Y) and (Y - 9600 < Ball.Y)
                        and (Act_f = None)
                        //and (LvPer100(30))
                        then begin
                            Act_f := Ca;
                            Act_c := 0;
                            If Ball.SType = Sbuu then begin
                                if Ball.Y < 4800 then begin
                                    Muki := Migi;
                                end else begin
                                    Act_f := None;
                                end;
                            end;
                        end;
                    end;
                end;
                C2Cr:begin
                    //しゃがむ
                    if (X + 4800 > Ball.X) and (X - 4800 < Ball.X)
                    and (Z + 3200 > Ball.Z) and (Z - 3200 < Ball.Z)
                    and (Act_f = None)
                    //and (LvPer100(30))
                    then begin

                        Act_f := Crm;
                        Act_c := 0;

                    end;
                    //しゃがみ続ける
                    if (X + 4800 > Ball.X) and (X - 4800 < Ball.X)
                    and (Z + 3200 > Ball.Z) and (Z - 3200 < Ball.Z)
                    and (Act_f = Crm)
                    and (P[i2].DBC[i].Act_c > 6)
                    then begin

                        Act_c := 6;//しゃがみ続ける

                    end;
                end;
                C2Jp:begin
                    //ジャンプ
                    if (X + 9600 > Ball.X) and (X - 9600 < Ball.X)
                    and (Z + 6400 > Ball.Z) and (Z - 6400 < Ball.Z)
                    and (Jump_f = None)
                    //and (LvPer100(50))
                    then begin
                        Jump_f := J1;
                        Jump_c := 0;
                    end;
                    {
                    if (Jump_f = J2) then begin
                        //キャッチ
                        if (X + 3200 > Ball.X) and (X - 3200 < Ball.X)
                        and (Z + 2400 > Ball.Z) and (Z - 2400 < Ball.Z)
                        and (Y + 6400 > Ball.Y) and (Y - 6400 < Ball.Y)
                        and (Act_f = None)
                        //and (LvPer100(30))
                        then begin
                            Act_f := JCa;
                            Act_c := 0;
                            If Ball.SType = Sbuu then begin
                                if Ball.Y < 4800 then begin
                                    Muki := Migi;
                                end else begin
                                    Act_f := None;
                                end;
                            end;
                        end;
                    end;
                    }
                end;
            end;

            FormChange_f := False;
        end;
    end;
    
    //内野攻撃
    procedure Attack();
    var
        tCSP:integer;
        tCPP:integer;
        procedure C3PtSet();
        begin
            with P[i2].DBC[i] do begin
                case C[i].Order3 of
                    C3Pt1:begin
                        KeyR2 := True;
                        Muki := Migi;
                    end;
                    C3Pt2:begin
                        Muki := Hidari;
                        Muki2 := Ue;
                        KeyU2 := True;
                    end;
                    C3Pt3:begin
                        Muki := Hidari;
                        Muki2 := Shita;
                        KeyD2 := True;
                    end;
                    C3Pt4:begin
                        Muki := Hidari;
                        Muki2:= None;    
                    end;
                end;
            end;
        end;
    begin
        //キャプと雑魚による行動パターンの違い
        if P[i2].DBC[i].dNo mod 10 = 0 then begin
            tCSP:=CSPc[Team];
            tCPP:=CPPc[Team];
        end else begin
            //キャプ不在（もしくは受け取れない状態）
            if (P[i2].DBC[P[i2].CapNo].Dead_f = True)
            or (P[i2].DBC[P[i2].CapNo].Dam_f <> None)
            or (P[i2].DBC[P[i2].CapNo].Groggy_c <> 0)
            or (P[i2].DBC[P[i2].CapNo].Pos <> 1) then begin
                tCSP:=CSPc[Team];
                tCPP:=CPPc[Team];
            //通常時
            end else begin
                tCSP:=CSP[Team];
                tCPP:=CPP[Team];
            end;
        end;

        //行動の指定
        if C[i].Order2 = None then begin

            //シュートかパスか
            If Per100(GC.DBCPU.ATCPARATIO) then begin//パス

                //内野
                If Per100(GC.DBCPU.ATCPAIRATIO) then begin
                    C[i].Order2 := C2P;
                    C[i].Order3 := C3Pt1;
                //外野
                end else begin
                    //N
                    If Per100(33) then begin
                        C[i].Order2 := C2P;
                    //D
                    end else If Per100(50) then begin
                        C[i].Order2 := C2DP;
                    //DJ
                    end else begin
                        C[i].Order2 := C2DJP;
                    end;

                    //パスを出す場所
                    //2
                    If Per100(33) then begin
                        C[i].Order3 := C3Pt2;
                    //3
                    end else If Per100(50) then begin
                        C[i].Order3 := C3Pt3;
                    //4
                    end else begin
                        C[i].Order3 := C3Pt4;
                    end;
                end;
            end else begin//シュート
                //DSJ
                If Per100(GC.DBCPU.ATCJPRATIO) then begin
                    C[i].Order2 := C2DJS;
                    C[i].STiming := Random(2500);
                //DS
                end else begin
                    C[i].Order2 := C2DS;
                    C[i].STiming := Random(3500);

                end;
            end;
        end;

        with P[i2].DBC[i] do begin

            case C[i].Order2 of
                //パス
                C2P:begin

                    if C[i].Move_c = 0 then begin
                        C3PtSet;
                        //一瞬間を持たせてパスターゲットを確立する
                        C[i].Move_c := -1;
                    end else begin
                        if Act_f = None then begin
                            if Jump_f = None then begin
                                Act_f := Pa;
                            end else begin
                                //内野にパスするときはジャンプパスを使わない
                                if C[i].Order3 <> C3Pt1 then begin
                                    Act_f := JPa;
                                end;
                            end;
                            Act_c := 0;
                        end;
                    end;

                end;
                C2DP:begin
                    if X > (43200-(16000)) then begin
                        if (Dash_f = None) and (Jump_f = None) then begin
                            Dash_f := Hidari;
                            Muki2 := None;
                            mNo_c := 0;
                        end;
                    end else begin

                        if C[i].Move_c = 0 then begin
                            C3PtSet;
                            //一瞬間を持たせてパスターゲットを確立する
                            C[i].Move_c := -1;
                        end else begin
                            if Act_f = None then begin
                                if Jump_f = None then begin
                                    Act_f := Pa;
                                end else begin
                                    Act_f := JPa;
                                end;
                                Act_c := 0;
                            end;
                        end;
                    end;
                end;
                C2DJP:begin
                    if Jump_f = None then begin
                        if X > (43200-(16000)) then begin
                            if (Dash_f = None) and (Jump_f = None) then begin
                                Dash_f := Hidari;
                                Muki2 := None;
                                mNo_c := 0;
                            end;
                        end else begin
                            if Jump_f = None then begin
                                Jump_f := J1;
                                Jump_c := 0;
                            end;
                        end;
                    end else begin
                        //if ((dY = -20+(15*12)) or (dY = -7+(15*12)))
                        if ((dY = -80+(15*4)) or (dY = -52+(15*4)))
                        and (Act_f = None) then begin
                            Act_f := JPa;
                            Act_c := 0;
                        end else if (dY = -80+(15*5)) or (dY = -52+(15*5)) then begin
                            C3PtSet;
                        end;
                    end;
                end;
                //シュート
                C2DS:begin
                    if X > (43200-(18000-C[i].STiming)) then begin
                        if (Dash_f = None) and (Jump_f = None) then begin
                            Dash_f := Hidari;
                            Muki2 := None;
                            mNo_c := 0;
                        end;
                    end else begin
                        if Act_f = None then begin
                            if Jump_f = None then begin
                                Act_f := Sh;
                            end else begin
                                Act_f := JSh;
                            end;
                            Act_c := 0;
                        end;
                    end;
                end;
                C2DJS:begin
                    if Jump_f = None then begin
                        if X > (43200-(16000-C[i].STiming)) then begin
                            if (Dash_f = None) and (Jump_f = None) then begin
                                Dash_f := Hidari;
                                Muki2 := None;
                                mNo_c := 0;
                            end;
                        end else begin
                            if Jump_f = None then begin
                                Jump_f := J1;
                                Jump_c := 0;

                                if Per100(GC.DBCPU.ATCJS1RATIO) then begin
                                    C[i].Order3 := C3StS;
                                end else if Per100(GC.DBCPU.ATCJS2RATIO) then begin
                                    C[i].Order3 := C3St1;
                                end else if Per100(GC.DBCPU.ATCJS3RATIO) then begin
                                    C[i].Order3 := C3St2;
                                end else begin
                                    C[i].Order3 := C3St3;
                                end;
                                {
                                if LvPer100(80) then begin

                                    C[i].Order3 := C3StS;
                                    
                                end else begin
                                    if Per100(33) then begin
                                        C[i].Order3 := C3St1;
                                    end else if Per100(50) then begin
                                        C[i].Order3 := C3St2;
                                    end else begin
                                        C[i].Order3 := C3St3;
                                    end;
                                end;
                                }
                            end;
                        end;
                    end else begin
                        case C[i].Order3 of
                            C3StS:begin
                                if ((dY = -20+(15*12)) or (dY = -7+(15*12)))
                                and (Act_f = None) then begin
                                    Act_f := JSh;
                                    Act_c := 0;
                                end;
                            end;
                            C3St2:begin
                                if ((dY = -5+(15*12)) or (dY = 23+(15*12)))
                                and (Act_f = None) then begin
                                    Act_f := JSh;
                                    Act_c := 0;
                                end;
                            end;
                            C3St1:begin
                                if ((dY = 85+(15*20)) or (dY = 53+(15*20)))
                                and (Act_f = None) then begin
                                    Act_f := JSh;
                                    Act_c := 0;
                                end;
                            end;
                            C3St3:begin
                                if ((dY = -80+(15*4)) or (dY = -52+(15*4)))
                                and (Act_f = None) then begin
                                    Act_f := JSh;
                                    Act_c := 0;
                                end;
                            end;
                        end;
                    end;
                end;
            end;
            //ちゃんと前向いて投げるようにする
            If ((Act_f = Sh) or (Act_f = JSh)) and (Act_c = 0) then begin
                Muki2 := None;
                Muki := Hidari;
            end;
            if Dash_f <> None then begin
                Muki2 := None;
                Muki := Dash_f;
            end;
            FormChange_f := False;
        end;
    end;


    //外野攻撃
    procedure Attack2();
    var
        tCSP:integer;
        tCPP:integer;
        procedure C3PtSet();
        begin
            with P[i2].DBC[i] do begin
                //自分がタゲになってるときは内野にパス
                if ((Pos = 2) and (C[i].Order3 mod 100 = C3Pt2))
                or ((Pos = 3) and (C[i].Order3 mod 100 = C3Pt3))
                or ((Pos = 4) and (C[i].Order3 mod 100 = C3Pt4))
                or (C[i].Order3 mod 100 = C3Pt1) then begin

                    KeyR2 := True;
                    Muki := Migi;
                    Muki2:= None;
                    
                end else begin
                    case (C[i].Order3 mod 100) of
                        C3Pt2:begin
                            Muki2 := Ue;
                            KeyU2 := True;
                        end;
                        C3Pt3:begin
                            Muki2 := Shita;
                            KeyD2 := True;
                        end;
                        C3Pt4:begin
                            Muki := Hidari;
                            Muki2:= None;
                            KeyL2 := True;
                        end;
                    end;
                end;
            end;
        end;
        //ちゃんと前向いて投げるようにする
        procedure MukiSet();
        begin
            with P[i2].DBC[i] do begin
                //シュート指示の時は向き補正
                If ((C[i].Order2 = C2DS) or (C[i].Order2 = C2DJS)) then begin
                    case Pos of
                        2:begin
                            Muki2 := Shita;
                        end;
                        3:begin
                            Muki2 := Ue;
                        end;
                        4:begin
                            Muki2 := None;
                            Muki := Migi;
                        end;
                    end;
                end;
            end;
        end;
        //行動パターン
        procedure PatSet();
        begin
            //with P[i2].DBC[i] do begin
                //シュートかパスか
                //パス
                If Per100(tCPP * 10) then begin//外野パターンを使うかは後で決める

                    //通常パス
                    If Per100(50) then begin
                        C[i].Order2 := C2DJP;
                    //ジャンプパス
                    end else begin
                        C[i].Order2 := C2P;
                    end;

                    //自分と同じポジが選ばれたら内野に返す
                    //2（１０の位と１の位を使う）
                    If Per100(33) then begin
                        C[i].Order3 := C3Pt2;
                    //3
                    end else If Per100(50) then begin
                        C[i].Order3 := C3Pt3;
                    //4
                    end else begin
                        C[i].Order3 := C3Pt4;
                    end;
                    //パスのタイミング（１０００の位と１００の位を使う）
                    if Per100(33) then begin
                        C[i].Order3 := C[i].Order3 + (C3St1 * 100);
                    end else if Per100(50) then begin
                        C[i].Order3 := C[i].Order3 + (C3St2 * 100);
                    end else begin
                        C[i].Order3 := C[i].Order3 + (C3St3 * 100);
                    end;
                //シュート
                end else begin
                    //ノーマルシュート
                    If LvPer100(60) then begin
                        C[i].Order2 := C2DJS;
                    //ジャンプシュート
                    end else begin
                        C[i].Order2 := C2DS;
                    end;

                    //シュートのタイミング
                    //ナイスシュート
                    if Per100(50) then begin

                        C[i].Order3 := C3StS;

                    end else begin
                        if Per100(33) then begin
                            C[i].Order3 := C3St1;
                        end else if Per100(50) then begin
                            C[i].Order3 := C3St2;
                        end else begin
                            C[i].Order3 := C3St3;
                        end;
                    end;
                end;
            //end;
        end;
    begin

        //tCSP:=CSP[Team];
        tCPP:=CPPg[Team];

        //行動の指定
        if C[i].Order2 = None then begin
            //ソ連
            if (tCPP = 10) then begin

                //キャプ不在
                if (P[i2].DBC[P[i2].CapNo].Dead_f = True)
                or (P[i2].DBC[P[i2].CapNo].Dam_f <> None)
                or (P[i2].DBC[P[i2].CapNo].Groggy_c <> 0)
                or (P[i2].DBC[P[i2].CapNo].Pos <> 1) then begin
                
                    tCSP:=CSPc[Team];
                    tCPP:=CPPc[Team];

                    PatSet;//行動パターンセット

                //通常時
                end else begin

                    //意地でももるどふにまわす
                    C[i].Order2 := C2DJP;
                    C[i].Order3 := C3Pt1;
                    C[i].Order3 := C[i].Order3 + (C3St2 * 100);
                end;

            end else begin

                PatSet;//行動パターンセット

            end;
        end;

        with P[i2].DBC[i] do begin

            case C[i].Order2 of
                //パス
                C2P:begin
                    if C[i].Move_c = 0 then begin
                        C3PtSet;
                        //一瞬間を持たせてパスターゲットを確立する
                        C[i].Move_c := -1;
                    end else begin
                        if Act_f = None then begin
                            if Jump_f = None then begin
                                Act_f := Pa;
                            //ジャンプ下り中だった場合はノーマルパスでもジャンプパス
                            end else begin
                                Act_f := JPa;
                            end;
                            Act_c := 0;
                        end;
                    end;
                end;
                //ジャンプパス
                C2DJP:begin
                    if C[i].Move_c = 0 then begin
                        C3PtSet;
                        //一瞬間を持たせてパスターゲットを確立する
                        C[i].Move_c := -1;
                    end else begin
                        if Jump_f = None then begin
                            Jump_f := J1;
                            Jump_c := 0;
                        end else begin
                            case (C[i].Order3 div 100) of
                                C3St2:begin
                                    if (dY = 23+(15*12))
                                    and (Act_f = None) then begin
                                        Act_f := JPa;
                                        Act_c := 0;
                                    end;
                                end;
                                C3St1:begin
                                    if  (dY = 53+(15*20))
                                    and (Act_f = None) then begin
                                        Act_f := JPa;
                                        Act_c := 0;
                                    end;
                                end;
                                C3St3:begin
                                    if (dY = -52+(15*4))
                                    and (Act_f = None) then begin
                                        Act_f := JPa;
                                        Act_c := 0;
                                    end;
                                end;
                            end;
                        end;
                    end;
                end;
                //シュート
                C2DS:begin
                    if Act_f = None then begin
                        if Jump_f = None then begin
                            Act_f := Sh;
                        end else begin
                            Act_f := JSh;
                        end;
                        Act_c := 0;
                    end;
                end;
                //ジャンプシュート
                C2DJS:begin
                    if Jump_f = None then begin
                        Jump_f := J1;
                        Jump_c := 0;
                    end else begin
                        case C[i].Order3 of
                            C3StS:begin
                                if (dY = -7+(15*12))
                                and (Act_f = None) then begin
                                    Act_f := JSh;
                                    Act_c := 0;
                                end;
                            end;
                            C3St2:begin
                                if (dY = 23+(15*12))
                                and (Act_f = None) then begin
                                    Act_f := JSh;
                                    Act_c := 0;
                                end;
                            end;
                            C3St1:begin
                                if  (dY = 53+(15*20))
                                and (Act_f = None) then begin
                                    Act_f := JSh;
                                    Act_c := 0;
                                end;
                            end;
                            C3St3:begin
                                if (dY = -52+(15*4))
                                and (Act_f = None) then begin
                                    Act_f := JSh;
                                    Act_c := 0;
                                end;
                            end;
                        end;
                    end;
                end;
            end;
            
            MukiSet;

            FormChange_f := False;
        end;
    end;

    //パスキャッチジャンプ
    procedure PCJump();
    begin
        with P[i2].DBC[i] do begin
            JMuki := None;
            JMuki2 := None;
            Dash_f := None;
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
        //カーソルキャラ
        if P[i2].PNo = i then begin

            //ポジション
            If Pos = 1 then begin
                case Ball.Motion of
                    BFree:begin
                        //自分の陣地内
                        if (Ball.X > 21200)
                        and (Ball.X < 43200-(2800+((Ball.Z-2400) div 72 * 16)))
                        and (Ball.Z > 1600) and (Ball.Z < 10400) then begin
                            C[i].Order2 := None;
                            C[i].Order := CTake;
                        end else begin
                            C[i].Order := CForm;
                        end;
                    end;
                    BHold:begin
                        //自分持ち
                        if Ball.HoldChar div 10 = 1 then begin
                            //if C[i].Order <> CAtc then C[i].Order2 := None;
                            C[i].Order := CAtc;
                        end else begin
                            C[i].Order := CForm;
                        end;
                    end;
                    BShoot:begin
                        //自分持ち
                        if Ball.HoldChar div 10 = 1 then begin
                            C[i].Order := CForm;
                        end else begin
                            C[i].Order := CDef;
                        end;
                    end;
                    BPass:begin
                        //自分持ち
                        if Ball.HoldChar div 10 = 1 then begin
                            C[i].Order := CForm;
                        end else begin
                            C[i].Order := CForm;//パスカット
                        end;
                    end;
                    BBound:begin
                        //自分の陣地内
                        if (Ball.X > 21200)
                        and (Ball.X < 43200-(2800+((Ball.Z-2400) div 72 * 16)))
                        and (Ball.Z > 1600) and (Ball.Z < 10400) then begin
                            C[i].Order2 := None;
                            C[i].Order := CTake;
                        end else begin
                            C[i].Order := CForm;
                        end;
                    end;
                end;

                if C[i].Order <> CForm then FormChange_f := False;

                case C[i].Order of
                    CForm:begin
                        //フォームチェンジの初期設定
                        if FormChange_f = False then begin

                            SetFormSet;

                        end;

                        SetForm;

                    end;
                    CTake:begin
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
                        and ((Ball.X div 100) <= (X div 100) + 12)
                        and ((Ball.X div 100) >= (X div 100) - 12) then begin

                            if Ball.Motion = BFree then begin
                                Act_f := TCr;
                            end else if Ball.Motion = BBound then begin
                                if Ball.Y <= 3200 then begin
                                    If Jump_f = None then begin
                                        Act_f := Ca;
                                    end else begin
                                        Act_f := JCa;
                                    end;
                                end else begin
                                    if Jump_f = None then begin
                                        if Ball.Y <= 9600 then begin
                                            Jump_f := J1;
                                            Jump_c := 0;
                                        end;
                                    end else begin
                                        Act_f := JCa;
                                    end;
                                end;
                            end;
                            if Move_f = True then Muki2 := None;

                            Act_c := 0;
                            Dash_f := None;
                            
                        end;

                        if Jump_f <> None then Dash_f := None;
                        
                    end;
                    CDef:begin

                        Kaihi;

                    end;
                    CAtc:begin
                        //とってすぐ投げるのではなく若干間を持たす
                        if C[i].Move_c > 0 then begin

                            //一人でも相手コートから帰ってきていないときは
                            //攻撃モーションに入らない
                            AtOK_f := True;
                            if GameLv = 2 then begin
                                for i3 := 0 to 2 do begin
                                    if (P[1].DBC[i3].X < 21600)
                                    and (P[1].DBC[i3].dHP > 0) then begin
                                        AtOK_f := False;
                                    end;
                                end;
                            end;
                            if AtOK_f = True then Dec(C[i].Move_c);
                            
                            C[i].Order2 := None;
                            C[i].Order3 := None;
                        end else begin
                            Attack;
                        end;
                    end;
                end;

            end else begin
                if Ball_f = True then begin
                    //外野
                    if C[i].Move_c > 0 then begin
                        //一人でも相手コートから帰ってきていないときは
                        //攻撃モーションに入らない
                        AtOK_f := True;
                        if GameLv = 2 then begin
                            for i3 := 0 to 2 do begin
                                if (P[1].DBC[i3].X < 21600)
                                and (P[1].DBC[i3].dHP > 0) then begin
                                    AtOK_f := False;
                                end;
                            end;
                        end;
                        if AtOK_f = True then Dec(C[i].Move_c);

                        C[i].Order2 := None;
                        C[i].Order3 := None;
                    end else begin

                        Attack2;
                    end;
                end;
            end;

        //カーソルキャラ以外
        end else begin
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
                            FormChange_f := False;
                        end else if (Ball.Motion = BHold) then begin
                            if (P[i2].DBC[Ball.HoldChar mod 10].Pos = 2) then begin
                                Muki2 := Ue;
                                Muki := Hidari;
                            end else if (P[i2].DBC[Ball.HoldChar mod 10].Pos = 3) then begin
                                Muki2 := Shita;
                                Muki := Hidari;
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

                        C[i].Order2 := None;
                        
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
    end;
end;



end.
 