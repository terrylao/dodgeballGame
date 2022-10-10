{$A8,B-,H+,I+,J-,K-,L+,M-,N+,P+,Q-,R-,T-,U-,V+,W-,X+,Y+,Z1}

//////////
// NkMemIniFile ユニット
//
// TNkmemIniFile: 拡張版 TMemIniFile
//　 Coded By T. Nakamura
//   Ver 0.1 2006/07/02
//   Ver 0.2 2006/07/02
//   Ver 0.3 2006/07/16
//
//  TNkMemIniFile は TMemIniFile の拡張版です。
//  次の特徴を備えています。
//  1) 名前と値に日本語が使用できます。
//  2) 名前にコメントを付加できます。
//  3) セクションにコメントを付加できます。
//  4) 名前/値ペアの参照が高速です。
//     セクションと名前をハッシュで高速に検索します。
//     速度は TmemIniFile とほど同等ですが TIniFileよりはるかに高速です。
//  5) 名前/値ペアの更新、追加、削除が TMemIniFileに比べ百倍高速です。
//  6) 値に引用符をサポートしています。値が空白を含む場合や、
//     引用符が含まれる場合、値は 引用符で囲まれて書き込まれます。
//     値の中の引用符が２つの引用符に置き換わります(CSVと同じ)。
//
//  使用の詳細はメソッドの説明を見てください。
//
//  TMemIniFile との性能比較
//  測定条件 Windows XP SP2, Celeron 2.4GHz, メモリ 512MHz, Delphi 7
//
//   TMemIniFile
//    Load(10万キー)       Time =     0.36 Sec
//    Read(10万キー)       Time =     0.58 Sec
//    Update(10万キー)     Time =   370.20 Sec
//    Delete(10万キー)     Time =   145.59 Sec
//    Add(10万キー)        Time =   156.84 Sec
//    UpdateFile(10万キー) Time =     0.16 Sec
//
//   TNkMemIniFile
//    Load(10万キー)       Time =     1.30 Sec
//    Read(10万キー)       Time =     0.91 Sec
//    Update(10万キー)     Time =     0.84 Sec
//    Delete(10万キー)     Time =     1.22 Sec
//    Add(10万キー)        Time =     1.38 Sec
//    UpdateFile(10万キー) Time =     0.30 Sec
//
//  本ソフトウェアの使用、配布や改変に一切の制限を
//  設けません。商用利用も出来ますし、利用に際して著作権
//  表示も不要です。ご自由にお使いください。
//  なお、これらの使用によって生じた不具合の責任は一切負
//  いません。予めご了承ください。


unit NkMemIniFile;

interface

uses
  Classes, SysUtils, IniFIles, Contnrs, NkStringList;

type
  // 名前の異常を表す例外です。
  ENkMemIniFileInvalidName = class(Exception)
  end;

  // セクション名の異常を表す例外です。
  ENkMemIniFileInvalidSection = class(Exception)
  end;

  // 値の異常を表す例外です。
  ENkMemIniFileInvalidValue = class(Exception)
  end;


  // キーのコメントを表すクラスです。
  // アプリケーションの中では使わないでください。
  TNkComment = class
  private
    // コメントを保持するフィールド
    FComment: TStringList;
  public
    // コンストラクタ
    constructor Create;
    // デストラクタ
    destructor Destroy; override;
    // コメント
    property Comment: TStringList read FComment write FComment;
  end;

  // セクションを表すクラスです。
  // アプリケーションの中では使わないでください。
  TNkMemIniSection = class;


  // Iniファイル操作用クラス
  // TMemIniFile の代替クラスです。
  //
  // TMemIniFile は以下の様に Iniファイルをパースします。
  //
  // 1) 空白行(トリムした結果文字の無い行)は無視します。
  // 2) 行をトリムした結果先頭の文字が ; の場合、コメントとみなします。
  //    コメントはトリム前のものが取り込まれます。
  // 3) 行をトリムした結果、先頭が'['で最後の文字が']'の場合セクションの始まりと
  //    みなします。'['と']'を除いた部分をセクション名とみなします。
  //    但しセクション名が空文字列の場合は無視します。
  // 4) セクションの始まりではなく、行が'=' を含む行は名前/値ペアとしてパースします。
  //    名前は名前部分('='より前の部分)の前後の空白はトリムされ取り出されます。
  //    値は値の部分('='より後の部分)の前後の空白はトリムされ取り出されます。
  //    取り出された値が 引用符(")で囲まれている場合は、引用符が取り除かれ、
  //    ２重の引用符("")は 引用符(")に変換されます。
  //    名前が空文字列になった場合は名前/値ペアは無視されます。
  // 5) セクションの始まりではなく、行が'=' を含まない行は、行全体を名前とみなします。
  //    値は空文字列になります。
  // 6) セクションの前の一連のコメントはセクションのコメントになります。
  //    セクションのコメントは ReadSectionCommentメソッドで取得できます。
  // 7) 名前/値ペアの前の一連のコメントは名前/値ペアのコメントになります。
  //    名前のコメントは ReadCommentメソッドで取得できます。
  // 8) 最後のセクションの最後の名前/値ペアより後の一連のコメントは
  //    「無名」のセクションのコメントになります。このコメントは
  //    ReadSectionComment('')
  //    で取得できます。
  // 9) 「無名」のセクションは常に作成されます。
  //
  // 注意) 空白とは コード$20 以下の全ての半角文字のことです。

  TNkMemIniFile = class(TCustomIniFile)
  private
    // セクションのリスト
    FSections: TNkHashedStringList;
    // セクションを追加する。
    function AddSection(const Section: string): TNkMemIniSection;
    // セクション名からセクションを得る。
    function GetSection(const Section: string): TNkMemIniSection;
    // 文字の大小区別を得る
    function GetCaseSensitive: Boolean;
    // 文字の大小区別を設定する
    procedure SetCaseSensitive(Value: Boolean);
    // 全てのキー/値の読み込む
    procedure LoadValues;
    // 文字列リストから TNkMemIniFileを初期化
    procedure SetStrings(List: TStringList);
  public
    // コンストラクタ
    // パラメータ
    //   FileName: Iniファイルのファイル名です。
    // 詳細
    //   Iniファイルを読み込み TNkMemIniFileのインスタンスを作成します。
    constructor Create(const FileName: string);
    // デストラクタ
    // 詳細
    //   TNkMemIniFile を破棄します。
    destructor Destroy; override;
    // クリア
    // 詳細
    //   TNkMemIniFileに保持されている全てのセクションと名前/値ペアを削除します。
    //   セクションのコメントや名前のコメントも全て削除されます。
    procedure Clear;
    // 名前の削除
    // パラメータ
    //   Section: セクション名。前後の空白は無視されます。
    //            CaseSensitive プロパティが True のときは Section の
    //            文字の大小は区別されます。falseの時は区別されません。
    //   Ident:   名前です。前後の空白は無視されます。
    //            CaseSensitive プロパティが True のときは Ident の
    //            文字の大小は区別されます。falseの時は区別されません。
    // 詳細
    //   セクションと名前で指定された名前を削除します。
    //   名前に関連付けられたコメントも削除されます。
    //   存在しない名前が指定されたときは何もしません。
    //   セクション、名前が不正な場合も何もしません。
    procedure DeleteKey(const Section, Ident: String); override;
    // セクションを削除
    // パラメータ
    //   Section: セクション名。前後の空白は無視されます。
    //            CaseSensitive プロパティが True のときは Section の
    //            文字の大小は区別されます。falseの時は区別されません。
    // 詳細
    //   指定されたセクションを削除します。セクションに関連付けられた
    //   コメントも削除されます。
    //   無名セクションを削除しようとすると ENkMemIniFileInvalidSection
    //   例外が起きます。
    procedure EraseSection(const Section: string); override;
    // ファイルイメージの取得
    // パラメータ
    //   List: TStringsの下位クラスのインスタンス
    // 詳細
    //   TNkMemIniFileがIniファイルへ書き出すテキストイメージを取得します。
    //   GetStrings は List にテキストイメージを「加えます」。加える前に
    //   Listをクリアしないので注意してください。
    //   List は作成済みの TStringsの下位クラスのインスタンスを指定してください。
    //   作成されるテキストイメージに関しては UpdateFileメソッドの詳細を
    //   参照してください。
    procedure GetStrings(List: TStrings);
    // セクション内のキーの一覧の取得。
    // パラメータ
    //   Section:  セクション名。前後の空白は無視されます。
    //             CaseSensitive プロパティが True のときは Section の
    //             文字の大小は区別されます。falseの時は区別されません。
    //   KeyNames: 名前のリストが入る TStringsの下位クラスのインスタンス
    // 詳細
    //   指定されたセクション内の名前の一覧を返します。名前は KeyNamesの１行に
    //   １個ずつ入ります。
    //   KeyNamesは名前のリストが入る前にクリアされます。
    //   KeyNames は作成済みの TStringsの下位クラスのインスタンスを指定してください。
    //   無名セクションの名前の一覧は常に空です。
    procedure ReadSection(const Section: string; KeyNames: TStrings); override;
    // セクション名の一覧を取得
    // パラメータ
    //   SectioNames: セクション名のリストが入る TStringsの下位クラスのインスタンス
    // 詳細
    //   セクション名の一覧を返します。セクション名は SectionNamesの１行に
    //   １個ずつ入ります。
    //   SectionNamesは名前のリストが入る前にクリアされます。
    //   SectionNames は作成済みの TStringsの下位クラスのインスタンスを指定してください。
    //   セクション名の一覧には無名セクションは含まれません。
    procedure ReadSections(SectionNames: TStrings); override;
    // セクション内の 名前=値　のリストを取得
    // パラメータ
    //   Section:   セクション名。前後の空白は無視されます。
    //              CaseSensitive プロパティが True のときは Section の
    //              文字の大小は区別されます。falseの時は区別されません。
    //   KeyValues: キー/値ペアのリストが入る TStringsの下位クラスのインスタンス
    // 詳細
    //   指定されたセクションの名前/値ペアの一覧を取得します。
    //   名前/値ペアは KeyValuesの１行に１個ずつ入ります。
    //   名前/値ペアはIniファイル上のテキスト表現と同じになります。
    //   値が 空白を含む場合や引用符を含む場合は、値は引用符で囲まれます。
    //   引用符は２重引用符に変換されます(CSVと同じ)。
    //   KeyValesは名前のリストが入る前にクリアされます。
    //   KeyVales は作成済みの TStringsの下位クラスのインスタンスを指定してください。
    //   無名セクションの名前/値ペアの一覧は常に空です。
    procedure ReadSectionValues(const Section: string; KeyValues: TStrings); override;
    // 値の読み込み
    // パラメータ
    //   Section: セクション名。前後の空白は無視されます。
    //            CaseSensitive プロパティが True のときは Section の
    //            文字の大小は区別されます。falseの時は区別されません。
    //   Ident:   名前です。前後の空白は無視されます。
    //            CaseSensitive プロパティが True のときは Ident の
    //            文字の大小は区別されます。falseの時は区別されません。
    //   Default: セクションに名前が存在しなかったとき ReadString が返す値です。
    // 戻り値
    //    読み取った値が文字列として返されます。
    // 詳細
    //   指定されたセクションの指定された名前の値を返します。
    //   値が存在しなかった場合は Default を返します。
    function ReadString(const Section, Ident, Default: string): string; override;
    // セクションのコメントを読む
    // パラメータ
    //   Section: セクション名。前後の空白は無視されます。
    //            CaseSensitive プロパティが True のときは Section の
    //            文字の大小は区別されます。falseの時は区別されません。
    //            空文字列を指定すると無名のセクションのコメントが読めます。
    //   Comment: コメントが入る TStringsの下位クラスのインスタンス
    // 詳細
    //   指定されたセクションのコメントを Comment に返します。
    //   Commentはコメントが入る前にクリアされます。
    //   コメントが無い場合や、セクションが無い場合は 0 行のコメントが返ります。
    //   コメントは';'付きです。不要な場合はアプリケーション側で取り除いてください。
    //   Sectionの前後の空白をトリムした結果が空文字列の場合、
    //   無名のセクションを指定したことになります。
    procedure ReadSectionComment(const Section: string; Comment: TStrings); overload;
    // セクションのコメントを読む
    // パラメータ
    //   Section: セクション名。前後の空白は無視されます。
    //            CaseSensitive プロパティが True のときは Section の
    //            文字の大小は区別されます。falseの時は区別されません。
    //            空文字列を指定すると無名のセクションのコメントが読めます。
    // 戻り値
    //   コメントが文字列として返されます。
    // 詳細
    //   指定されたセクションのコメントを返します。
    //   コメントが無い場合や、セクションが無い場合は ''(空文字列)が返ります。
    //   コメントは';'付きです。不要な場合はアプリケーション側で取り除いてください。
    //   コメントが複数行になる時は戻り値は #13#10を含みます。
    //   コメントの最後に #13#10が付くことはありません。
    //   Sectionの前後の空白をトリムした結果が空文字列の場合、
    //   無名のセクションを指定したことになります。
    function  ReadSectionComment(const Section: string): string; overload;
    // セクション名/キー名で指定したキーのコメントを読む
    // パラメータ
    //   Section: セクション名。前後の空白は無視されます。
    //            CaseSensitive プロパティが True のときは Section の
    //            文字の大小は区別されます。falseの時は区別されません。
    //   Ident:   名前です。前後の空白は無視されます。
    //            CaseSensitive プロパティが True のときは Ident の
    //            文字の大小は区別されます。falseの時は区別されません。
    //   Comment: コメントが入る TStringsの下位クラスのインスタンス
    // 詳細
    //   指定されたセクションの指定された名前のコメントを Comment に返します。
    //   Commentはコメントが入る前にクリアされます。
    //   コメントが無い場合や、名前が無い場合は 0 行のコメントが返ります。
    //   コメントは';'付きです。不要な場合はアプリケーション側で取り除いてください。
    procedure ReadComment(const Section, Ident: string; Comment: TStrings); overload;
    // セクション名/キー名で指定したキーのコメントを読む
    // パラメータ
    //   Section: セクション名。前後の空白は無視されます。
    //            CaseSensitive プロパティが True のときは Section の
    //            文字の大小は区別されます。falseの時は区別されません。
    //   Ident:   名前です。前後の空白は無視されます。
    //            CaseSensitive プロパティが True のときは Ident の
    //            文字の大小は区別されます。falseの時は区別されません。
    // 戻り値
    //   コメントが文字列として返されます。
    // 詳細
    //   指定された名前のコメントを返します。
    //   コメントが無い場合や、名前が無い場合は ''(空文字列)が返ります。
    //   コメントは';'付きです。不要な場合はアプリケーション側で取り除いてください。
    //   コメントが複数行になる時は戻り値は #13#10を含みます。
    //   コメントの最後に #13#10が付くことはありません。
    function  ReadComment(const Section, Ident: string): string; overload;
    // セクションにコメントを書きこむ
    // パラメータ
    //   Section: セクション名。前後の空白は無視されます。
    //            CaseSensitive プロパティが True のときは Section の
    //            文字の大小は区別されます。falseの時は区別されません。
    //            空文字列を指定すると無名のセクションにコメントを設定できます。
    //   Comment: 設定するコメントです。 TStringsの下位クラスのインスタンスを
    //            してします。各行の先頭に ';' が付いている必要はありません。
    //            ';' は必要に応じて自動的に付加されます。
    // 詳細
    //   指定されたセクションにコメントを設定します。
    //   セクションが無い場合は何もしません。
    //   コメントの各行の先頭に ';' が付いている必要はありません。
    //            ';' は必要に応じて自動的に付加されます。
    //   Sectionの前後の空白をトリムした結果が空文字列の場合、
    //   無名のセクションを指定したことになります。
    procedure WriteSectionComment(const Section: string; Comment: TStrings); overload;
    // セクションにコメントを書きこむ
    // パラメータ
    //   Section: セクション名。前後の空白は無視されます。
    //            CaseSensitive プロパティが True のときは Section の
    //            文字の大小は区別されます。falseの時は区別されません。
    //   Comment: 設定するコメントです。 文字列で指定します。文字列は複数行でも
    //            問題ありません。コメントの各行の先頭に ';' が付いている
    //            必要はありません。';' は必要に応じて自動的に付加されます。
    // 詳細
    //   指定されたセクションにコメントを設定します。
    //   セクションが無い場合は何もしません。
    //   コメントの各行の先頭に ';' が付いている必要はありません。
    //            ';' は必要に応じて自動的に付加されます。
    //   Sectionの前後の空白をトリムした結果が空文字列の場合、
    //   無名のセクションを指定したことになります。
    procedure WriteSectionComment(const Section, Comment: string); overload;
    // セクション名/キー名で指定したキーにコメントを書き込む
    // パラメータ
    //   Section: セクション名。前後の空白は無視されます。
    //            CaseSensitive プロパティが True のときは Section の
    //            文字の大小は区別されます。falseの時は区別されません。
    //   Ident:   名前です。前後の空白は無視されます。
    //            CaseSensitive プロパティが True のときは Ident の
    //            文字の大小は区別されます。falseの時は区別されません。
    //   Comment: 設定するコメントです。 TStringsの下位クラスのインスタンスを
    //            してします。各行の先頭に ';' が付いている必要はありません。
    //            ';' は必要に応じて自動的に付加されます。
    // 詳細
    //   指定されたセクションの指定された名前にコメントを設定します。
    //   指定した名前が無い場合は何もしません。
    //   コメントの各行の先頭に ';' が付いている必要はありません。
    //            ';' は必要に応じて自動的に付加されます。
    procedure WriteComment(const Section, Ident: string; Comment: TStrings); overload;
    // セクション名/キー名で指定したキーにコメントを書き込む
    // パラメータ
    //   Section: セクション名。前後の空白は無視されます。
    //            CaseSensitive プロパティが True のときは Section の
    //            文字の大小は区別されます。falseの時は区別されません。
    //   Ident:   名前です。前後の空白は無視されます。
    //            CaseSensitive プロパティが True のときは Ident の
    //            文字の大小は区別されます。falseの時は区別されません。
    //   Comment: 設定するコメントです。 文字列で指定します。文字列は複数行でも
    //            問題ありません。コメントの各行の先頭に ';' が付いている
    //            必要はありません。';' は必要に応じて自動的に付加されます。
    // 詳細
    //   指定されたセクションの指定された名前にコメントを設定します。
    //   指定された名前が無い場合は何もしません。
    //   コメントの各行の先頭に ';' が付いている必要はありません。
    //            ';' は必要に応じて自動的に付加されます。
    procedure WriteComment(const Section, Ident, Comment: string); overload;
    // ファイルを更新する。
    // 詳細
    //   TNkMemIniFile内のセクションと名前/値ペアをIniファイルに書き込みます。
    //   Iniファイルはコンストラクタで指定したものです。
    //   Iniファイルは以下の様に書き込まれます。
    //
    //   1) セクション名のコメントはセクションの前に書き込まれます。
    //   2) セクションは
    //
    //      [セクション名]
    //
    //      というように書き込まれます。セクション名の前にインデントは
    //      挿入されません。
    //   3) 各名前/値ペアの前に、名前/値ペアのコメントが書かれます。
    //   4) 各名前/値ペアは
    //
    //      名前=値
    //
    //      という形式で書かれます。
    //      名前の前にインデントは挿入されません。
    //      名前と=, = と値の間には空白は挿入されません。
    //      値が 空白を服務場合や、引用符(")を含む場合、値は 引用符で
    //      囲まれて書き込まれます。値が引用符(")を含む場合は ("")に変換されて
    //      書き込まれます(CSVとおなじ)。この仕様は TMemIniFile や TIniファイルとは
    //      ことなるので注意してください。
    //
    //      TIniFileでは前後に空白を含む値を引用符で囲んで書き込みますが、
    //      引用符を ("")に変換しません。
    //      TMemIniFile は引用符を無視して普通の文字列として扱います。
    //      また、値の前後に空白が含まれている場合はトリムしてから書き込みます。
    procedure UpdateFile; override;
    // セクション名/キー名で指定したキーに値を書き込む
    // パラメータ
    //   Section: セクション名。前後の空白は無視されます。
    //            CaseSensitive プロパティが True のときは Section の
    //            文字の大小は区別されます。falseの時は区別されません。
    //   Ident:   名前です。前後の空白は無視されます。
    //            CaseSensitive プロパティが True のときは Ident の
    //            文字の大小は区別されます。falseの時は区別されません。
    //   Value:   書き込む値です。
    // 詳細
    //   指定されたセクションの指定された値を更新します。
    //   指定されたセクションが無ければ作られます。指定された名前が無ければ
    //   作られます。
    //   Sectionの前後の空白をトリムした後の文字列が空文字列のとき
    //   ENkMemIniFileInvalidSection例外が起きます。
    //   Identの前後の空白をトリムした後の文字列が空文字列の場合や '=' を
    //   含む場合は ENkMemIniFileInvalidName例外が起きます。
    //   Value はぞのまま書き込まれます。前後に空白があってもそのまま書き込まれます。
    //   但しValueが CR や LF を含む場合はENkMemIniFileInvalidValue例外が起きます。
    procedure WriteString(const Section, Ident, Value: String); override;

    // 名前の大小を区別する
    // 詳細
    //   セクション名、名前で検索を行うとき、大文字小文字を区別するかを指定します。
    //   このプロパティはいつでも変更できますが、Trueから False に変更するとき
    //   注意が必要です。Trueから False に変更すると、大文字/小文字だけが
    //   異なるセクション名や名前は同名とみなされるようになります。
    //   同名となったセクションや名前は「あと」の方のもので上書きされます。
    //   デフォルトは False です。
    property CaseSensitive: Boolean read GetCaseSensitive write SetCaseSensitive;
  end;

  // セクションを保持するオブジェクト
  // このクラスはアプリケーションでは使用しないでください。
  TNkMemIniSection = class
  private
    // コメント
    FComment: TStringList;
    // キーと値のリスト
    FKeys: TNkhashedStringList;
    // キーのコメントオブジェクトを取得
    function GetCommentObj(Ident: string): TNkComment;
  public
    // コンストラクタ
    constructor Create;
    // デストラクタ
    destructor Destroy; override;
    // キーと値をすべてクリア
    procedure Clear;
    // 特定のキーと値をクリア
    procedure DeleteKey(Ident: string);
    // セクションの内容を文字列リストに取得
    procedure GetStrings(List: TStrings);
    // セクション内のキー/値を読む
    function  ReadString(const Ident, Default: string): string;
    // セクション内のキーのコメントを読む
    procedure ReadComment(const Ident:string; Comment: TStrings);
    // セクションにキー/値を書く
    procedure WriteString(Ident, Value: string);
    // セクションのキーにコメントを加える
    procedure WriteComment(Ident: string; Comment: TStrings);
    // セクションのコメント
    property Comment: TStringList read FComment;
    // セクション内のキーと値のリスト
    property Keys: TNkhashedStringList read FKeys;
  end;

implementation

uses
  StrUtils;


{ TNkMemIniFile }

// 全セクションを破棄する
procedure TNkMemIniFile.Clear;
begin FSections.Clear; end;

constructor TNkMemIniFile.Create(const FileName: string);
begin
  inherited Create(FileName);
  FSections := TNkHashedStringList.Create;
  FSections.HasObjects := True;

  // 無名セクションを作る。
  AddSection('');

  LoadValues;
end;

// セクションとキー名を指定してキーを削除する
procedure TNkMemIniFile.DeleteKey(const Section, Ident: String);
var
  IniSection: TNkMemIniSection;
begin
  IniSection := GetSection(Trim(Section));
  if IniSection <> Nil then
    IniSection.DeleteKey(Trim(Ident));
end;

destructor TNkMemIniFile.Destroy;
begin
  FSections.Free;
  inherited;
end;


// セクションを削除する。
procedure TNkMemIniFile.EraseSection(const Section: string);
var
  SectionIndex: Integer;
  s: string;
begin
  s := Trim(Section);
  if s = '' then
    ENkMemIniFileInvalidSection.Create('無名セクションは削除できません');
  SectionIndex := FSections.IndexOf(s);
  if SectionIndex >= 0 then
    FSections.Delete(SectionIndex);
end;

function TNkMemIniFile.GetCaseSensitive: Boolean;
begin Result := FSections.CaseSensitive; end;

// Iniファイルのテキストイメージを取得する。
procedure TNkMemIniFile.GetStrings(List: TStrings);
var
  i, j: Integer;
  IniSection: TNkMemIniSection;
begin
  List.BeginUpdate;
  try
    for i := 0 to FSections.Count - 1 do
    begin
      if FSections[i] <> '' then
      begin
        IniSection := FSections.Objects[i] as TNkMemIniSection;
        for j := 0 to IniSection.Comment.Count-1 do
          List.Add(IniSection.Comment[j]);
        List.Add('[' + FSections[i] + ']');
        List.Add('');
        IniSection.GetStrings(List);
        List.Add('');
      end;
    end;
    
    // 無名セクションのコメントのみ出力
    IniSection := GetSection('');
    if IniSection <> Nil then
      for j := 0 to IniSection.Comment.Count-1 do
        List.Add(IniSection.Comment[j]);
  finally
    List.EndUpdate;
  end;
end;

// 大文字小文字を区別するかセットする
procedure TNkMemIniFile.SetCaseSensitive(Value: Boolean);
var
  List: TStringList;
begin
  if FSections.CaseSensitive <> Value then
  begin
    List := TStringList.Create;
    try
      // 元の内容を吸い出す。
      GetStrings(List);
      // Ini をクリアし、大文字小文字の区別を設定する
      Clear;
      FSections.CaseSensitive := Value;
      // Iniを再構築する。
      SetStrings(List);
    finally
      List.Free;
    end;
  end;
end;

// セクションとキーを指定して値を書き込む
procedure TNkMemIniFile.WriteString(const Section, Ident, Value: String);
var
  IniSection: TNkMemIniSection;
  s: string;
begin
  s := Trim(Section);
  if s = '' then
    raise ENkMemIniFileInvalidSection.Create('空のセクション名');
  if AnsiPos(#13, Value) > 0 then
    raise ENkMemIniFileInvalidValue.Create('値が CR を含む');
  if AnsiPos(#10, Value) > 0 then
    raise ENkMemIniFileInvalidValue.Create('値が LF を含む');
  IniSection := GetSection(s);
  if IniSection = Nil then
    IniSection := AddSection(s);
  IniSection.WriteString(Ident, Value);
end;

// セクションを増やす
function TNkMemIniFile.AddSection(const Section: string): TNkMemIniSection;
begin
  Result := TNkMemIniSection.Create;
  try
    Result.Keys.CaseSensitive := CaseSensitive;
    FSections.AddObject(Section, Result);
  except
    Result.Free;
    raise;
  end;
end;

// セクションとキーを指定して値を読む
function TNkMemIniFile.ReadString(const Section, Ident,
                                  Default: string): string;
var
  IniSection: TNkmemIniSection;
begin
  IniSection := GetSection(Trim(Section));
  if IniSection <> Nil then
    Result := IniSection.ReadString(Ident, Default)
  else
    Result := Default;
end;

// セクションの全てのキー名を Strings に読み込む
procedure TNkMemIniFile.ReadSection(const Section: string;
                                    KeyNames: TStrings);
var
  IniSection: TNkMemIniSection;
  i: Integer;
begin
  KeyNames.BeginUpdate;
  try
    KeyNames.Clear;
    IniSection := GetSection(Trim(Section));
    if IniSection <> Nil then
      for i := 0 to IniSection.Keys.Count-1 do
        KeyNames.Add(IniSection.FKeys.Names[i]);
  finally
    KeyNames.EndUpdate;
  end;
end;

// 全セクション名を Strings に読み込む
procedure TNkMemIniFile.ReadSections(SectionNames: TStrings);
var
  i: Integer;
begin
  SectionNames.BeginUpdate;
  try
    SectionNames.Clear;

    for i := 0 to FSections.Count-1 do
      if FSections[i] <> '' then       // 無名セクションは対象外
        SectionNames.Add(FSections[i]);
  finally
    SectionNames.EndUpdate;
  end;
end;

// セクションの内容を Stringsに読み込む
procedure TNkMemIniFile.ReadSectionValues(const Section: string;
  KeyValues: TStrings);
var
  IniSection: TNkMemIniSection;
  i: Integer;
begin
  KeyValues.BeginUpdate;
  try
    KeyValues.Clear;
    IniSection := GetSection(Trim(Section));
    if IniSection <> Nil then
      for i := 0 to IniSection.Keys.Count-1 do
        keyValues.Add(IniSection.Keys[i]);
  finally
    KeyValues.EndUpdate;
  end;
end;

// コメントのコピー
procedure CopyComment(Source, Dest: TStrings);
var
  i: Integer;
  s: string;
begin
  Dest.BeginUpdate;
  try
    Dest.Clear;
    for i := 0 to Source.Count-1 do
    begin
      s := Trim(Source[i]);

      if (s = '') or ((s <> '') and (s[1] <> ';')) then
        Dest.Add(';' + Source[i])
      else
        Dest.Add(Source[i]);
    end;
  finally
    Dest.EndUpdate;
  end;
end;

// 文字列リストから TNkMemIniFileを初期化する
// 注意！　無名セクションが作成済みであること。
procedure TNkMemIniFile.SetStrings(List: TStringList);
var
  IniSection: TNkMemIniSection;
  Comment: TStringList;
  i, j: Integer;
  Ident, Value, s: string;
begin
  Comment := TStringList.Create;
  try
    //Clear;
    IniSection := nil;
    for i := 0 to List.Count - 1 do
    begin
      s := Trim(List[i]);
      if (s <> '') and (s[1] <> ';') then
      begin
        if (s[1] = '[') and AnsiEndsStr(']', s) then
        begin
          // セクションを検出！

          // セクション名を得る。
          s := Trim(Copy(s, 2, Length(s)-2));

          if s = '' then // 無名セクションは読み飛ばし
            continue;

          // 既存セクションならセクションをマージ、
          // そうでなければ新規セクションを作る
          if FSections.StrExists(S) then
            IniSection := GetSection(S)
          else
            IniSection := AddSection(Trim(s));

          // コメントは後勝ちとする。
          if Comment.Count > 0 then
            CopyComment(Comment, IniSection.Comment);
          Comment.Clear;
        end
        else
        begin

          // セクションではない
          if IniSection <> nil then
          begin
            // キー/値ペアを作る
            j := AnsiPos('=', s);
            if J > 0 then
            begin
              Ident := Trim(Copy(s, 1, J-1));
              Value := AnsiDequotedStr(Trim(Copy(s, J+1, MaxInt)), '"');
            end
            else
            begin
              Ident := s;
              Value := '';
            end;

            // 無名の名前は無視
            if Ident = '' then Continue;

            // セクションに登録(同名のキーが有れば後勝ち)
            IniSection.WriteString(Ident, Value);

            // コメントも登録(後勝ち)
            if Comment.Count > 0 then
              IniSection.WriteComment(Ident, Comment);
            Comment.Clear;
          end;
        end;
      end
      else if (s <> '') and (s[1] = ';') then
      begin
        Comment.Add(List[i]);
      end;
    end;

    if Comment.Count > 0 then
      WriteSectionComment('', Comment);
  finally
    Comment.Free;
  end;
end;

// ファイルから読み込む
procedure TNkMemIniFile.LoadValues;
var
  List: TStringList;
begin
  if (FileName <> '') and FileExists(FileName) then
  begin
    List := TStringList.Create;
    try
      // ファイルを読み込む
      List.LoadFromFile(FileName);
      SetStrings(List);
    finally
      List.Free;
    end;
  end;
end;

// ファイルに書き込む
procedure TNkMemIniFile.UpdateFile;
var
  List: TStringList;
begin
  List := TStringList.Create;
  try
    GetStrings(List);
    List.SaveToFile(FileName);
  finally
    List.Free;
  end;
end;

// セクションのコメントを読む
procedure TNkMemIniFile.ReadSectionComment(const Section: string;
                                           Comment: TStrings);
var
  IniSection: TNkMemIniSection;
begin
  Comment.BeginUpdate;
  try
    Comment.Clear;
    IniSection := GetSection(Trim(Section));
    if IniSection <> Nil then
    begin
        Comment.Assign(IniSection.FComment);
    end;
  finally
    Comment.EndUpdate;
  end;
end;

// セクションのコメントを読む
function TNkMemIniFile.ReadSectionComment(const Section: string): string;
var
  Comment: TStringList;
begin
  Result := '';
  Comment := TStringList.Create;
  try
    ReadSectionComment(Section, Comment);
    Result := Trim('@'+Comment.Text);
    Delete(Result, 1, 1);
  finally
    Comment.Free;
  end;
end;

// コメントを読む
procedure TNkMemIniFile.ReadComment(const Section, Ident: string;
  Comment: TStrings);
var
  IniSection: TNkMemIniSection;
begin
  Comment.BeginUpdate;
  try
    Comment.Clear;
    IniSection := GetSection(Trim(Section));
    if IniSection <> Nil then
    begin
        IniSection.ReadComment(Ident, Comment);
    end;
  finally
    Comment.EndUpdate;
  end;
end;

// コメントを読む
function TNkMemIniFile.ReadComment(const Section, Ident: string): string;
var
  Comment: TStringList;
begin
  Comment := TStringList.Create;
  try
    ReadComment(Section, Ident, Comment);
    Result := Trim('@'+Comment.Text);
    Delete(Result, 1, 1);
  finally
    Comment.Free;
  end;
end;

// コメントを書く
procedure TNkMemIniFile.WriteComment(const Section, Ident: string;
                                     Comment: TStrings);
var
  IniSection: TNkMemIniSection;
begin
  IniSection := GetSection(Trim(Section));
  if IniSection <> Nil then
    IniSection.WriteComment(Ident, Comment);
end;

// コメントを書く
procedure TNkMemIniFile.WriteComment(const Section, Ident,
                                     Comment: string);
var
  CommentList: TStringList;
begin
  CommentList := TStringList.Create;
  try
    CommentList.Text := Comment;
    WriteComment(Section, Ident, CommentList);
  finally
    CommentList.Free;
  end;
end;

// セクションのコメントを書く
procedure TNkMemIniFile.WriteSectionComment(const Section: string;
  Comment: TStrings);
var
  IniSection: TNkMemIniSection;
begin
  IniSection := GetSection(Trim(Section));
  if IniSection <> Nil then
    CopyComment(Comment, IniSection.Comment);
end;

// セクションのコメントを書く
procedure TNkMemIniFile.WriteSectionComment(const Section,
  Comment: string);
var
  CommentList: TStringList;
begin
  CommentList := TStringList.Create;
  try
    CommentList.Text := Comment;
    WriteSectionComment(Section, CommentList);
  finally
    CommentList.Free;
  end;
end;


{ TNkMemIniSection }

// セクションの内容を文字列にしてリストに加える
procedure TNkMemIniSection.GetStrings(List: TStrings);
var
  i, j: Integer;
  Comment: TNkComment;
begin
  List.BeginUpdate;
  try
    for i := 0 to Fkeys.Count - 1 do
    begin
      Comment := FKeys.Objects[i] as TNkComment;
      if Comment <> Nil then
        for j := 0 to Comment.Comment.Count-1 do
          List.Add(Comment.Comment[j]);
      List.Add(FKeys[i]);
    end;
  finally
    List.EndUpdate;
  end;
end;

// セクション名からセクションを得る。
function TNkMemIniFile.GetSection(const Section: string): TNkMemIniSection;
begin
  Result := FSections.ObjectsByString[Section] as TNkMemIniSection;
end;

// セクションをクリアする。
procedure TNkMemIniSection.Clear;
begin
  FKeys.Clear;
end;

constructor TNkMemIniSection.Create;
begin
  FComment := TStringList.Create;
  FKeys := TNkhashedStringList.Create;
  Fkeys.HasObjects := True;
  FKeys.UseNameAsKey := True;
end;

// セクションからキー/値を削除
procedure TNkMemIniSection.DeleteKey(Ident: string);
var
  KeyIndex: Integer;
begin
  KeyIndex := Keys.IndexOfName(Ident);
  if KeyIndex >= 0 then Keys.Delete(KeyIndex);
end;

destructor TNkMemIniSection.Destroy;
begin
  FComment.Free;
  FKeys.Free;
  inherited;
end;

// コメントオブジェクトを得る。
function TNkMemIniSection.GetCommentObj(Ident: string): TNkComment;
begin
  Result := Keys.ObjectsByName[Ident] as TNkComment;
end;

// キー/値を読む
function TNkMemIniSection.ReadString(const Ident, Default: string): string;
var
  s: string;
begin
  s := Trim(Ident);
  if not Keys.NameExists(s) then
  begin
    Result := Default;
    Exit;
  end;
  Result := Keys.ValuesByName[s];
  Result := AnsiDequotedStr(Result, '"');
end;

// キー/値を書き込む
procedure TNkMemIniSection.WriteString(Ident, Value: string);
var
  s: string;
begin
  s := Trim(Ident);
  if s = '' then
    raise ENkMemIniFileInvalidName.Create('空の名前');
  if AnsiPos('=', s) > 0 then
    raise ENkMemIniFileInvalidName.Create('名前が "=" を含んでいる');
  if s[1] = ';' then
    raise ENkMemIniFileInvalidName.Create('名前の先頭が ";"');
  Keys.ValuesByName[s] := Value;
end;

// キーにコメントを付ける。
procedure TNkMemIniSection.WriteComment(Ident: string; Comment: TStrings);
var
  CommentObj: TNkComment;
  s: string;
begin
  s := Trim(Ident);
  if Keys.NameExists(s) then
  begin
    CommentObj := TNkComment.Create;
    try
      CopyComment(Comment, CommentObj.Comment);
      Keys.ObjectsByName[s] := CommentObj;
    except
      CommentObj.Free;
      raise;
    end;
  end;
end;

// キーのコメントを取得する。
procedure TNkMemIniSection.ReadComment(const Ident: string;
  Comment: TStrings);
var
  CommentObj: TNkComment;
begin
  CommentObj := GetCommentObj(Trim(Ident));
  if CommentObj <> Nil then
    Comment.Assign(CommentObj.Comment);
end;

{ TMemIniKey }

constructor TNkComment.Create;
begin
  FComment := TStringList.Create;
end;

destructor TNkComment.Destroy;
begin
  FComment.Free;
  inherited;
end;

end.

