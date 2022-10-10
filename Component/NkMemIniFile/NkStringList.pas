{$A8,B-,H+,I+,J-,K-,L+,M-,N+,P+,Q-,R-,T-,U-,V+,W-,X+,Y+,Z1}

//////////
// NkStringList ���j�b�g
//
// TNkmemIniFile: �̕⏕�N���X TNkStringList ��񋟂��郆�j�b�g�ł��B
//�@ Coded By T. Nakamura
//   Ver 0.3 2006/07/16
//
//  �{�\�t�g�E�F�A�̎g�p�A�z�z����ςɈ�؂̐�����
//  �݂��܂���B���p���p���o���܂����A���p�ɍۂ��Ē��쌠
//  �\�����s�v�ł��B�����R�ɂ��g�����������B
//  �Ȃ��A�����̎g�p�ɂ���Đ������s��̐ӔC�͈�ؕ�
//  ���܂���B�\�߂��������������B

unit NkStringList;

interface
  uses Classes, ContNrs, SysUtils;

type
  TNkHashedStringList = class;

  // TNkHashedStringList �̕������ێ�����N���X
  TNkStringItem = class
  private
    // �e�N���X(CaseSensitive �����߂�̂Ɏg��)
    FOwner: TNkHashedStringList;
    // �I�u�W�F�N�g��ێ�
    FObject: TObject;

    // �I�u�W�F�N�g��ݒ肷��B
    procedure SetObject(const Value: TObject);
  public
    // ������
    Str: string;
    // ���O
    Name: string;

    // �R���X�g���N�^
    constructor Create(Owner: TNkHashedStringList; AStr, AName: string; o: TObject);
    // �f�X�g���N�^
    destructor Destroy; override;

    // �I�u�W�F�N�g���Q��/�ݒ肷��v���p�e�B
    // ���̃v���p�e�B���I�u�W�F�N�g�̎����j����S������B
    property Obj: TObject read FObject write SetObject;
  end;

  // TNkHashedStringList�̕�����p�n�b�V��
  TNkStringHash = class(TCustomBucketList)
  private
    // �召�����̋��
    FCaseSensitive: Boolean;
  protected
    // �L�[�ɂ��o�P�c�̑I���@
    function BucketFor(AItem: Pointer): Integer; override;
    // �L�[�ɂ�錟���B���ʂ̓o�P�c�ƃC���f�b�N�X�B
    function FindItem(AItem: Pointer; out ABucket: Integer;
      out AIndex: Integer): Boolean; override;
  public
    // �R���X�g���N�^
    constructor Create;
    // �f�X�g���N�^
    property CaseSensitive: Boolean read FCaseSensitive
                                    write FCaseSensitive;
  end;

  // �L�[�d����O
  ENkSTringListDuplicateException = class(Exception)
  end;

  // �n�b�V���������� TStrings(��ۃN���X)
  // ���̕����񃊃X�g�́@�������O�⓯���������2�}���ł��Ȃ����Ƃɒ��ӁB
  // ���̃N���X�� TNkMemIniFile�p�ɍ��܂����B
  // �ڂ����h�L�������g�͍���Ă��܂���B
  // ���ɗ��p���ꂽ�����͓��e���悭�ᖡ���Ă���g���Ă��������B
  TNkHashedStringList = class(TStrings)
  private
    // �L�[�n�b�V��
    FKeyHash: TNkStringHash;
    // �����񃊃X�g
    FList: TObjectList;
    // �I�u�W�F�N�g�����폜�t���O
    FHasObjects: Boolean;
    // ���O�ŕ����̑召����ʂ��邩�������B
    FCaseSensitive: Boolean;
    FUseNameAsKey: Boolean;

    // �n�b�V����Value����������
    // ���O�����݂��Ȃ��ꍇ�� '' ��Ԃ��B
    function GetValuesByName(Name: string): string;
    // �n�b�V���ō�����������Value���Z�b�g
    // ���O�����݂��Ă��Ȃ��ꍇ�͐V���ɕ����񂪍����B
    procedure SetValuesByName(Name: string; const Value: string);
    // �n�b�V���� Object ����������
    // ���O�����݂��Ȃ��ꍇ�� Nil ��Ԃ��B
    function GetObjectsByName(Name: string): TObject;
    // �n�b�V���ō�����������Object���Z�b�g
    procedure SetObjectsByName(Name: string; const Value: TObject);
    // ���O�ŕ����̑召����ʂ��邩��ݒ肷��B
    procedure SetCaseSensitive(const Value: Boolean);
    // �n�b�V���̍č\�z
    procedure RebuildHash;
    // ������ŃI�u�W�F�N�g������
    function GetObjectsByString(Str: string): TObject;
    // ������Ō������ăI�u�W�F�N�g��ݒ�
    // ���O�����݂��Ă��Ȃ��ꍇ�͉������Ȃ��B
    procedure SetObjectsByString(Str: string; const Value: TObject);
    // �n�b�V���̃L�[�Ƃ��Ė��O���g��
    procedure SetUseNameAsKey(const Value: Boolean);
  protected
    // Index�Ԗڂ̕�������擾
    function Get(Index: Integer): String; override;
    // Index�Ԗڂ̃I�u�W�F�N�g���擾
    function GetObject(Index: Integer): TObject; override;
    // Index�Ԗڂ̃I�u�W�F�N�g��ݒ�
    procedure PutObject(Index: Integer; AObject: TObject); override;
    // Index�Ԗڂ̕������ݒ�
    procedure Put(Index: Integer; const S: String); override;
    // �s�����擾
    function GetCount: Integer; override;
  public
    // Index�Ԗڂɕ������}��
    procedure Insert(Index: Integer; const S: string); override;
    // �R���X�g���N�^
    constructor Create(
      HasObjects: Boolean = True  // �I�u�W�F�N�g�������j��
    );
    // �f�X�g���N�^
    destructor Destroy; override;
    // �����񃊃X�g���N���A
    procedure Clear; override;
    // Index�Ԗڂ̕�������폜
    procedure Delete(Index: Integer); override;
    // �I�u�W�F�N�g�̎����j��
    property HasObjects: Boolean read FHasObjects write FHasObjects;
    // CurIndex�Ԗڂ̕������ NewIndex�ԖڂɈړ�
    procedure Move(CurIndex: Integer; NewIndex: Integer); override;
    // ������Ō������ăC���f�b�N�X�𓾂�
    // �x���̂Œ��ӁB���������ɂ� ValuesByStr �� ObjectsByStr �v���p�e�B��
    // ����
    function IndexOf(const S: string): Integer; override;
    // ���O�Ō������ăC���f�b�N�X�𓾂�
    // �x���̂Œ��ӁB���������ɂ� ValuesByName �� ObjectsByName �v���p�e�B��
    // ����
    function IndexOfName(const Name: String): Integer; override;
    // ���O�������񃊃X�g���ɑ��݂��邩��Ԃ��B
    function NameExists(Name: string): Boolean;
    // ���O�������񃊃X�g���ɑ��݂��邩��Ԃ��B
    function StrExists(Str: string): Boolean;
    // ���O�Œl���擾/�ݒ肷��v���p�e�B�B�����ł��B
    property ValuesByName[Name: string]: string
             read GetValuesByName write SetValuesByName;
    // ���O�ŃI�u�W�F�N�g���擾/�ݒ肷��v���p�e�B�B�����ł��B
    property ObjectsByName[Name: string]: TObject
             read GetObjectsByName write SetObjectsByName;
    // ������ŃI�u�W�F�N�g���擾/�ݒ肷��v���p�e�B�B�����ł��B
    property ObjectsByString[Str: string]: TObject
             read GetObjectsByString write SetObjectsByString;
    // ���O�ő啶��/����������ʂ��邩�������t���O
    property CaseSensitive: Boolean read FCaseSensitive write SetCaseSensitive;
    // ���O�̃n�b�V������邩�A������̃n�b�V������邩�����߂�v���p�e�B
    // �ύX����ƕ����񂪑S�Ĕj������邱�Ƃɒ��ӁI
    property UseNameAsKey: Boolean read FUseNameAsKey write SetUseNameAsKey;
  end;

implementation

// �n�b�V���̃o�P�c��
const NumBucketsForTNkStringHash = 1024;

{ TNkHashedStringList }

// ���X�g�̃N���A
procedure TNkHashedStringList.Clear;
begin
  // �n�b�V�����N���A
  FKeyHash.Clear;
  // ���X�g���N���A
  // TObjectList�� TNkStringItem�������폜����B
  // TNkStringItem �� HasObjects �� True �Ȃ�I�u�W�F�N�g���폜����B
  FList.Clear;
end;

// �R���X�g���N�^
constructor TNkHashedStringList.Create(
  HasObjects: Boolean = True);// �I�u�W�F�N�g�������폜����B
begin
  // �n�b�V��������������
  FKeyHash := TNkStringHash.Create;
  // �����񃊃X�g������������
  FList := TObjectList.Create;

  // �I�v�V�����t���O���f�t�H���g�ݒ肷��B
  // �����폜=����B���O�ő啶���������͋�ʂ��Ȃ��B
  FHasObjects := HasObjects;
  FCaseSensitive := False;
  FUseNameAsKey := False;
  FKeyHash.CaseSensitive := FCaseSensitive;
end;

// ������̍폜
procedure TNkHashedStringList.Delete(Index: Integer);
var
  Item: TNkStringItem;
begin
  inherited;
  // �C���f�b�N�X���當��������߂�B
  Item := FList[Index] as TNkStringItem;

  if FUseNameAsKey then
  begin
    // ��������n�b�V������O���B
    if Item.Name <> '' then
      FKeyHash.Remove(@Item.Name);
  end;
  FKeyHash.Remove(@Item.Str);

  // ����������X�g����폜����
  // (TNkStringItem �ƃI�u�W�F�N�g�̎����j�����s����)
  FList.Delete(Index);
end;

// �f�X�g���N�^
destructor TNkHashedStringList.Destroy;
begin
  // �����񃊃X�g��j��
  FList.Free;
  // �n�b�V����j��
  FKeyHash.Free;

  inherited;
end;

// �w�肳�ꂽ�u���O�v�̕����񂪑��݂��Ă��邩��Ԃ��B
// ������̎擾
function TNkHashedStringList.Get(Index: Integer): String;
begin
  Result := (FList[Index] as TNkSTringItem).Str;
end;

// �����񐔂̎擾
function TNkHashedStringList.GetCount: Integer;
begin
  Result := FList.Count;
end;

// �I�u�W�F�N�g�̎擾
function TNkHashedStringList.GetObject(Index: Integer): TObject;
var
  Item: TNkStringItem;
begin
  Item := FList[Index] as TNkSTringItem;
  Result := Item.Obj;
end;

// �I�u�W�F�N�g�𖼑O�Ŏ擾
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

// �I�u�W�F�N�g�𖼑O�Ŏ擾
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

// �l�𖼑O�Ŏ擾
// ���O�����݂��Ȃ��ꍇ�� '' ��Ԃ��B
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

// ������C���f�b�N�X�𕶎���Ŏ擾(���j�A�T�[�`�Ȃ̂Œᑬ)
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

// Index�Ԗڂɑ}��
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

// ������̈ړ�
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

// ������̐ݒ�
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

// �I�u�W�F�N�g�̐ݒ�
procedure TNkHashedStringList.PutObject(Index: Integer; AObject: TObject);
var
  Item: TNkStringItem;
begin
  Item := Flist[Index] as TNkStringItem;
  Item.Obj := AObject;
end;

// �n�b�V���č\�z
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

// �召��ʂ̐ݒ�
procedure TNkHashedStringList.SetCaseSensitive(const Value: Boolean);
begin
  if FcaseSensitive <> Value then
  begin
    FCaseSensitive := Value;
    Clear;
    FKeyHash.CaseSensitive := FCaseSensitive;
  end;
end;

// �I�u�W�F�N�g�𖼑O�Ō������Đݒ�
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

// �l�𖼑O�Ō������Đݒ�
// ���O�����݂��Ă��Ȃ��ꍇ�͉������Ȃ��B
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

// �n�b�V���ō�����������Value���Z�b�g
// ���O�����݂��Ă��Ȃ��ꍇ�͐V���ɕ����񂪍����B
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

// �R���X�g���N�^
constructor TNkStringItem.Create(Owner: TNkHashedStringList;
                                 AStr, AName: string;
                                 o: TObject);
begin
  FOwner := Owner;
  Str := AStr;
  Name := AName;
  FObject := o;
end;

// �f�X�g���N�^
destructor TNkStringItem.Destroy;
begin
  Obj := Nil;
  inherited;
end;

// �I�u�W�F�N�g�̐ݒ�
procedure TNkStringItem.SetObject(const Value: TObject);
begin
  if FOwner.HasObjects then
    FObject.Free;
  FObject := Value;
end;

{ TNkStringHash }

// ������Ńo�P�c��I��
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

// �R���X�g���N�^
constructor TNkStringHash.Create;
begin
  BucketCount := NumBucketsForTNkStringHash; // �o�P�c����ݒ�
end;

// ������Ō���
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
