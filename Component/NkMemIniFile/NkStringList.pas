{$A8,B-,H+,I+,J-,K-,L+,M-,N+,P+,Q-,R-,T-,U-,V+,W-,X+,Y+,Z1}

//////////
// NkStringList ユニット
//
// TNkmemIniFile: の補助クラス TNkStringList を提供するユニットです。
//　 Coded By T. Nakamura
//   Ver 0.3 2006/07/16
//
//  本ソフトウェアの使用、配布や改変に一切の制限を
//  設けません。商用利用も出来ますし、利用に際して著作権
//  表示も不要です。ご自由にお使いください。
//  なお、これらの使用によって生じた不具合の責任は一切負
//  いません。予めご了承ください。

unit NkStringList;

interface
  uses Classes, ContNrs, SysUtils;

type
  TNkHashedStringList = class;

  // TNkHashedStringList の文字列を保持するクラス
  TNkStringItem = class
  private
    // 親クラス(CaseSensitive を求めるのに使う)
    FOwner: TNkHashedStringList;
    // オブジェクトを保持
    FObject: TObject;

    // オブジェクトを設定する。
    procedure SetObject(const Value: TObject);
  public
    // 文字列
    Str: string;
    // 名前
    Name: string;

    // コンストラクタ
    constructor Create(Owner: TNkHashedStringList; AStr, AName: string; o: TObject);
    // デストラクタ
    destructor Destroy; override;

    // オブジェクトを参照/設定するプロパティ
    // このプロパティがオブジェクトの自動破棄を担当する。
    property Obj: TObject read FObject write SetObject;
  end;

  // TNkHashedStringListの文字列用ハッシュ
  TNkStringHash = class(TCustomBucketList)
  private
    // 大小文字の区別
    FCaseSensitive: Boolean;
  protected
    // キーによるバケツの選択　
    function BucketFor(AItem: Pointer): Integer; override;
    // キーによる検索。結果はバケツとインデックス。
    function FindItem(AItem: Pointer; out ABucket: Integer;
      out AIndex: Integer): Boolean; override;
  public
    // コンストラクタ
    constructor Create;
    // デストラクタ
    property CaseSensitive: Boolean read FCaseSensitive
                                    write FCaseSensitive;
  end;

  // キー重複例外
  ENkSTringListDuplicateException = class(Exception)
  end;

  // ハッシュ高速化版 TStrings(具象クラス)
  // この文字列リストは　同じ名前や同じ文字列を2個挿入できないことに注意。
  // このクラスは TNkMemIniFile用に作りました。
  // 詳しいドキュメントは作っていません。
  // 他に流用されたい方は内容をよく吟味してから使ってください。
  TNkHashedStringList = class(TStrings)
  private
    // キーハッシュ
    FKeyHash: TNkStringHash;
    // 文字列リスト
    FList: TObjectList;
    // オブジェクト自動削除フラグ
    FHasObjects: Boolean;
    // 名前で文字の大小を区別するかを示す。
    FCaseSensitive: Boolean;
    FUseNameAsKey: Boolean;

    // ハッシュでValueを高速検索
    // 名前が存在しない場合は '' を返す。
    function GetValuesByName(Name: string): string;
    // ハッシュで高速検索してValueをセット
    // 名前が存在していない場合は新たに文字列が作られる。
    procedure SetValuesByName(Name: string; const Value: string);
    // ハッシュで Object を高速検索
    // 名前が存在しない場合は Nil を返す。
    function GetObjectsByName(Name: string): TObject;
    // ハッシュで高速検索してObjectをセット
    procedure SetObjectsByName(Name: string; const Value: TObject);
    // 名前で文字の大小を区別するかを設定する。
    procedure SetCaseSensitive(const Value: Boolean);
    // ハッシュの再構築
    procedure RebuildHash;
    // 文字列でオブジェクトを検索
    function GetObjectsByString(Str: string): TObject;
    // 文字列で検索してオブジェクトを設定
    // 名前が存在していない場合は何もしない。
    procedure SetObjectsByString(Str: string; const Value: TObject);
    // ハッシュのキーとして名前を使う
    procedure SetUseNameAsKey(const Value: Boolean);
  protected
    // Index番目の文字列を取得
    function Get(Index: Integer): String; override;
    // Index番目のオブジェクトを取得
    function GetObject(Index: Integer): TObject; override;
    // Index番目のオブジェクトを設定
    procedure PutObject(Index: Integer; AObject: TObject); override;
    // Index番目の文字列を設定
    procedure Put(Index: Integer; const S: String); override;
    // 行数を取得
    function GetCount: Integer; override;
  public
    // Index番目に文字列を挿入
    procedure Insert(Index: Integer; const S: string); override;
    // コンストラクタ
    constructor Create(
      HasObjects: Boolean = True  // オブジェクトを自動破棄
    );
    // デストラクタ
    destructor Destroy; override;
    // 文字列リストをクリア
    procedure Clear; override;
    // Index番目の文字列を削除
    procedure Delete(Index: Integer); override;
    // オブジェクトの自動破棄
    property HasObjects: Boolean read FHasObjects write FHasObjects;
    // CurIndex番目の文字列を NewIndex番目に移動
    procedure Move(CurIndex: Integer; NewIndex: Integer); override;
    // 文字列で検索してインデックスを得る
    // 遅いので注意。高速検索には ValuesByStr や ObjectsByStr プロパティを
    // 推奨
    function IndexOf(const S: string): Integer; override;
    // 名前で検索してインデックスを得る
    // 遅いので注意。高速検索には ValuesByName や ObjectsByName プロパティを
    // 推奨
    function IndexOfName(const Name: String): Integer; override;
    // 名前が文字列リスト中に存在するかを返す。
    function NameExists(Name: string): Boolean;
    // 名前が文字列リスト中に存在するかを返す。
    function StrExists(Str: string): Boolean;
    // 名前で値を取得/設定するプロパティ。高速です。
    property ValuesByName[Name: string]: string
             read GetValuesByName write SetValuesByName;
    // 名前でオブジェクトを取得/設定するプロパティ。高速です。
    property ObjectsByName[Name: string]: TObject
             read GetObjectsByName write SetObjectsByName;
    // 文字列でオブジェクトを取得/設定するプロパティ。高速です。
    property ObjectsByString[Str: string]: TObject
             read GetObjectsByString write SetObjectsByString;
    // 名前で大文字/小文字を区別するかを示すフラグ
    property CaseSensitive: Boolean read FCaseSensitive write SetCaseSensitive;
    // 名前のハッシュを作るか、文字列のハッシュを作るかを決めるプロパティ
    // 変更すると文字列が全て破棄されることに注意！
    property UseNameAsKey: Boolean read FUseNameAsKey write SetUseNameAsKey;
  end;

implementation

// ハッシュのバケツ数
const NumBucketsForTNkStringHash = 1024;

{ TNkHashedStringList }

// リストのクリア
procedure TNkHashedStringList.Clear;
begin
  // ハッシュをクリア
  FKeyHash.Clear;
  // リストをクリア
  // TObjectListは TNkStringItemを自動削除する。
  // TNkStringItem は HasObjects が True ならオブジェクトを削除する。
  FList.Clear;
end;

// コンストラクタ
constructor TNkHashedStringList.Create(
  HasObjects: Boolean = True);// オブジェクトを自動削除する。
begin
  // ハッシュを初期化する
  FKeyHash := TNkStringHash.Create;
  // 文字列リストを初期化する
  FList := TObjectList.Create;

  // オプションフラグをデフォルト設定する。
  // 自動削除=する。名前で大文字小文字は区別しない。
  FHasObjects := HasObjects;
  FCaseSensitive := False;
  FUseNameAsKey := False;
  FKeyHash.CaseSensitive := FCaseSensitive;
end;

// 文字列の削除
procedure TNkHashedStringList.Delete(Index: Integer);
var
  Item: TNkStringItem;
begin
  inherited;
  // インデックスから文字列を求める。
  Item := FList[Index] as TNkStringItem;

  if FUseNameAsKey then
  begin
    // 文字列をハッシュから外す。
    if Item.Name <> '' then
      FKeyHash.Remove(@Item.Name);
  end;
  FKeyHash.Remove(@Item.Str);

  // 文字列をリストから削除する
  // (TNkStringItem とオブジェクトの自動破棄が行われる)
  FList.Delete(Index);
end;

// デストラクタ
destructor TNkHashedStringList.Destroy;
begin
  // 文字列リストを破棄
  FList.Free;
  // ハッシュを破棄
  FKeyHash.Free;

  inherited;
end;

// 指定された「名前」の文字列が存在しているかを返す。
// 文字列の取得
function TNkHashedStringList.Get(Index: Integer): String;
begin
  Result := (FList[Index] as TNkSTringItem).Str;
end;

// 文字列数の取得
function TNkHashedStringList.GetCount: Integer;
begin
  Result := FList.Count;
end;

// オブジェクトの取得
function TNkHashedStringList.GetObject(Index: Integer): TObject;
var
  Item: TNkStringItem;
begin
  Item := FList[Index] as TNkSTringItem;
  Result := Item.Obj;
end;

// オブジェクトを名前で取得
function TNkHashedStringList.GetObjectsByName(Name: string): TObject;
var
  Data: Pointer;
  Index: Integer;
begin
  Result := Nil;

  if FUseNameAsKey then
  begin
    if FKeyHash.Find(@Name, Data) then
      Result := TNkStringItem(Data).Obj;
  end
  else
  begin
    Index := IndexOfName(Name);
    if Index >= 0 then
      Result := (FList[Index] as TNkStringItem).FObject;
  end;
end;

// オブジェクトを名前で取得
function TNkHashedStringList.GetObjectsByString(Str: string): TObject;
var
  Data: Pointer;
  Index: Integer;
begin
  Result := Nil;
  if not FUseNameAsKey then
  begin
    if FKeyHash.Find(@Str, Data) then
      Result := TNkStringItem(Data).Obj;
  end
  else
  begin
    Index := IndexOf(Str);
    if Index >= 0 then
      Result := (FList[Index] as TNkStringItem).FObject;
  end;
end;

// 値を名前で取得
// 名前が存在しない場合は '' を返す。
function TNkHashedStringList.GetValuesByName(Name: string): string;
var
  Data: Pointer;
  Index: Integer;
begin
  Result := '';

  if FUseNameAsKey then
  begin
    if FKeyHash.Find(@Name, Data) then
    begin
      Result := Copy(TNkStringItem(Data).Str, Length(Name) + 2, MaxInt);
    end;
  end
  else
  begin
    Index := IndexOfName(Name);
    Result := Copy((FList[Index] as TNkStringItem).Str, Length(Name) + 2, MaxInt);
  end;
end;

// 文字列インデックスを文字列で取得(リニアサーチなので低速)
function TNkHashedStringList.IndexOf(const S: string): Integer;
var
  Data: Pointer;
  i: Integer;
  Item: TNkStringItem;
begin
  Result := -1;

  if not FUseNameAskey then
  begin
  if FkeyHash.Find(@S, Data) then
    Result := FList.IndexOf(TObject(Data));
  end
  else
  begin
    for i := 0 to Count-1 do
    begin
      Item := FList[i] as TNkStringItem;
      if FCaseSensitive then
      begin
        if AnsiCompareStr(Get(Result), Item.Str) = 0 then
        begin
          Result := i;
          Exit;
        end;
      end
      else
      begin
        if AnsiCompareText(Get(Result), Item.Str) = 0 then
        begin
          Result := i;
          Exit;
        end;
      end;
    end;
   Result := -1;
  end;
end;

function TNkHashedStringList.IndexOfName(const Name: String): Integer;
var
  Data: Pointer;
  i: Integer;
  Item: TNkStringItem;
begin
  Result := -1;

  if FUseNameAskey then
  begin
  if FkeyHash.Find(@Name, Data) then
    Result := FList.IndexOf(TObject(Data));
  end
  else
  begin
    for i := 0 to Count-1 do
    begin
      Item := FList[i] as TNkStringItem;
      if FCaseSensitive then
      begin
        if AnsiCompareStr(Get(Result), Item.Name) = 0 then
        begin
          Result := i;
          Exit;
        end;
      end
      else
      begin
        if AnsiCompareText(Get(Result), Item.Name) = 0 then
        begin
          Result := i;
          Exit;
        end;
      end;
    end;
   Result := -1;
  end;
end;

// Index番目に挿入
procedure TNkHashedStringList.Insert(Index: Integer; const S: string);
var
  Item: TNkStringItem;
  Name: string;
begin
  Name := ExtractName(s);
  Item := TNkStringItem.Create(Self, S, Name, Nil);
  if FUseNameAsKey then
  begin
    if Name <> '' then
      FkeyHash.Add(@Item.Name, Item);
  end
  else
    FKeyHash.Add(@Item.Str, Item);
  FList.Insert(Index, Item);
end;

// 文字列の移動
procedure TNkHashedStringList.Move(CurIndex, NewIndex: Integer);
var
  TempString: string;
  TempObject: TObject;
  Item: TNkStringItem;
begin
  if CurIndex <> NewIndex then
  begin
    BeginUpdate;
    try
      Item := FList[CurIndex] as TNkStringItem;
      TempString := Item.Str;
      TempObject := Item.Obj;
      Item.Obj := Nil;
      Delete(CurIndex);
      InsertObject(NewIndex, TempString, TempObject);
    finally
      EndUpdate;
    end;
  end;
end;

// 文字列の設定
function TNkHashedStringList.NameExists(Name: string): Boolean;
begin
  if FUseNameAsKey then
    Result := FKeyHash.Exists(@Name)
  else
    Result := IndexOfname(Name) >= 0;
end;

procedure TNkHashedStringList.Put(Index: Integer; const S: String);
var
  Item: TNkSTringItem;
begin
  inherited;
  Item := FList[Index] as TNkStringItem;
  if FUseNameAsKey then
  begin
    if Item.Name <> '' then
      FKeyHash.Remove(@Item.Name);
  end
  else
    FKeyHash.Remove(@Item.Str);
  Item.Str := S;
  Item.Name := ExtractName(S);
  if FUseNameAsKey then
  begin
    if Item.Name <> '' then
      FKeyHash.Add(@Item.Name, Item);
  end
  else
    FkeyHash.Add(@Item.Str, Item);
end;

// オブジェクトの設定
procedure TNkHashedStringList.PutObject(Index: Integer; AObject: TObject);
var
  Item: TNkStringItem;
begin
  Item := Flist[Index] as TNkStringItem;
  Item.Obj := AObject;
end;

// ハッシュ再構築
procedure TNkHashedStringList.RebuildHash;
var
  i: Integer;
  Item: TNkStringItem;
begin
  FKeyHash.Clear;
  FKeyHash.CaseSensitive := CaseSensitive;
  for i := 0 to Count-1 do
  begin
    Item := Flist[i] as TNkStringItem;
    if FUseNameAskey then
    begin
      if Item.Name <> '' then
        FKeyHash.Add(@Item.Name, Item);
    end
    else
      FKeyHash.Add(@Item.Str, Item);
  end;
end;

// 大小区別の設定
procedure TNkHashedStringList.SetCaseSensitive(const Value: Boolean);
begin
  if FcaseSensitive <> Value then
  begin
    FCaseSensitive := Value;
    Clear;
    FKeyHash.CaseSensitive := FCaseSensitive;
  end;
end;

// オブジェクトを名前で検索して設定
procedure TNkHashedStringList.SetObjectsByName(Name: string; const Value: TObject);
var
  Data: Pointer;
  Index: Integer;
begin
  if FUseNameAskey then
  begin
    if FKeyHash.Find(@Name, Data) then
      TNkStringItem(Data).Obj := Value;
  end
  else
  begin
    Index := IndexOfName(Name);
    if Index >= 0 then
      (FList[Index] as TNkStringItem).Obj := Value;
  end;
end;

// 値を名前で検索して設定
// 名前が存在していない場合は何もしない。
procedure TNkHashedStringList.SetObjectsByString(Str: string;
  const Value: TObject);
var
  Data: Pointer;
  Index: Integer;
begin
  if not FUseNameAsKey then
  begin
  if FKeyHash.Find(@Str, Data) then
    TNkStringItem(Data).Obj := Value;
  end
  else
  begin
    Index := IndexOf(Str);
    if Index >= 0 then
      (FList[Index] as TNkStringItem).Obj := Value;
  end;
end;

// ハッシュで高速検索してValueをセット
// 名前が存在していない場合は新たに文字列が作られる。
procedure TNkHashedStringList.SetUseNameAsKey(const Value: Boolean);
begin
  if FUseNameAsKey <> Value then
  begin
    FUseNameAsKey := Value;
    RebuildHash;
  end;
end;

procedure TNkHashedStringList.SetValuesByName(Name: string; const Value: string);
var
  Data: Pointer;
  Index: Integer;
  v: string;
begin
  if (Length(Value) > 0) and
     ((AnsiPos(' ', Value) > 0) or (AnsiPos('"', Value) > 0)) then
    v := AnsiQuotedStr(Value, '"')
  else
    v := Value;
  if FUseNameAsKey then
  begin
    if FKeyHash.Find(@Name, Data) then
    begin
      TNkStringItem(Data).Str :=
        Trim(Name) + '=' + v;
    end
    else
      Append(Trim(Name) + '=' + v);
  end
  else
  begin
    Index := IndexOfName(Name);
    if Index >= 0 then
      (FList[Index] as TNkStringItem).Str :=
        Trim(Name) + '=' + v
    else
      Append(Trim(Name) + '=' + v);
  end;
end;

function TNkHashedStringList.StrExists(Str: string): Boolean;
begin
  if not FUseNameAsKey then
    Result := FkeyHash.Exists(@Str)
  else
    result := IndexOf(Str) >= 0;
end;



{ TNkStringItem }

// コンストラクタ
constructor TNkStringItem.Create(Owner: TNkHashedStringList;
                                 AStr, AName: string;
                                 o: TObject);
begin
  FOwner := Owner;
  Str := AStr;
  Name := AName;
  FObject := o;
end;

// デストラクタ
destructor TNkStringItem.Destroy;
begin
  Obj := Nil;
  inherited;
end;

// オブジェクトの設定
procedure TNkStringItem.SetObject(const Value: TObject);
begin
  if FOwner.HasObjects then
    FObject.Free;
  FObject := Value;
end;

{ TNkStringHash }

// 文字列でバケツを選択
function TNkStringHash.BucketFor(AItem: Pointer): Integer;
var
  s: string;
  i: Integer;
begin
  s := PString(AItem)^;

  if Not CaseSensitive then
    s := AnsiUpperCase(s);

  Result := 0;

  for i := 1 to Length(s) do
    Result := ((Result + Ord(s[i])) * 9973) mod NumBucketsForTNkStringHash;
end;

// コンストラクタ
constructor TNkStringHash.Create;
begin
  BucketCount := NumBucketsForTNkStringHash; // バケツ数を設定
end;

// 文字列で検索
function TNkStringHash.FindItem(AItem: Pointer; out ABucket,
  AIndex: Integer): Boolean;
var
  I: Integer;
begin
  Result := False;
  ABucket := BucketFor(AItem);
  with Buckets[ABucket] do
    for I := 0 to Count - 1 do
      if CaseSensitive then
      begin
        if PString(Items[I].Item)^ = PString(AItem)^ then
        begin
          AIndex := I;
          Result := True;
          Break;
        end;
      end
      else
      begin
        if AnsiCompareText(PString(Items[I].Item)^, PString(AItem)^) = 0 then
        begin
          AIndex := I;
          Result := True;
          Break;
        end;
      end;
end;

end.
