ユニット NkMemIniFile のリファレンス

ユニットの説明
  ////////
   NkMemIniFile ユニット
  
   TNkmemIniFile: 拡張版 TMemIniFile
  　 Coded By T. Nakamura
     Ver 0.1 2006/07/02
     Ver 0.2 2006/07/02
     Ver 0.3 2006/07/16
  
    TNkMemIniFile は TMemIniFile の拡張版です。
    次の特徴を備えています。
    1) 名前と値に日本語が使用できます。
    2) 名前にコメントを付加できます。
    3) セクションにコメントを付加できます。
    4) 名前/値ペアの参照が高速です。
       セクションと名前をハッシュで高速に検索します。
       速度は TmemIniFile とほど同等ですが TIniFileよりはるかに高速です。
    5) 名前/値ペアの更新、追加、削除が TMemIniFileに比べ百倍高速です。
    6) 値に引用符をサポートしています。値が空白を含む場合や、
       引用符が含まれる場合、値は 引用符で囲まれて書き込まれます。
       値の中の引用符が２つの引用符に置き換わります(CSVと同じ)。
  
    使用の詳細はメソッドの説明を見てください。
  
    TMemIniFile との性能比較
    測定条件 Windows XP SP2, Celeron 2.4GHz, メモリ 512MHz, Delphi 7
  
     TMemIniFile
      Load(10万キー)       Time =     0.36 Sec
      Read(10万キー)       Time =     0.58 Sec
      Update(10万キー)     Time =   370.20 Sec
      Delete(10万キー)     Time =   145.59 Sec
      Add(10万キー)        Time =   156.84 Sec
      UpdateFile(10万キー) Time =     0.16 Sec
  
     TNkMemIniFile
      Load(10万キー)       Time =     1.30 Sec
      Read(10万キー)       Time =     0.91 Sec
      Update(10万キー)     Time =     0.84 Sec
      Delete(10万キー)     Time =     1.22 Sec
      Add(10万キー)        Time =     1.38 Sec
      UpdateFile(10万キー) Time =     0.30 Sec
  
    本ソフトウェアの使用、配布や改変に一切の制限を
    設けません。商用利用も出来ますし、利用に際して著作権
    表示も不要です。ご自由にお使いください。
    なお、これらの使用によって生じた不具合の責任は一切負
    いません。予めご了承ください。


1. ユニット NkMemIniFile の クラス

1.1 ENkMemIniFileInvalidName クラス

宣言
  ENkMemIniFileInvalidName = class(Exception)

説明
  名前の異常を表す例外です。


1.2 ENkMemIniFileInvalidSection クラス

宣言
  ENkMemIniFileInvalidSection = class(Exception)

説明
  セクション名の異常を表す例外です。


1.3 ENkMemIniFileInvalidValue クラス

宣言
  ENkMemIniFileInvalidValue = class(Exception)

説明
  値の異常を表す例外です。


1.4 TNkMemIniFile クラス

宣言
  TNkMemIniFile = class(TCustomIniFile)

説明
   Iniファイル操作用クラス
   TMemIniFile の代替クラスです。
  
   TMemIniFile は以下の様に Iniファイルをパースします。
  
   1) 空白行(トリムした結果文字の無い行)は無視します。
   2) 行をトリムした結果先頭の文字が ; の場合、コメントとみなします。
      コメントはトリム前のものが取り込まれます。
   3) 行をトリムした結果、先頭が'['で最後の文字が']'の場合セクションの始まりと
      みなします。'['と']'を除いた部分をセクション名とみなします。
      但しセクション名が空文字列の場合は無視します。
   4) セクションの始まりではなく、行が'=' を含む行は名前/値ペアとしてパースします。
      名前は名前部分('='より前の部分)の前後の空白はトリムされ取り出されます。
      値は値の部分('='より後の部分)の前後の空白はトリムされ取り出されます。
      取り出された値が 引用符(")で囲まれている場合は、引用符が取り除かれ、
      ２重の引用符("")は 引用符(")に変換されます。
      名前が空文字列になった場合は名前/値ペアは無視されます。
   5) セクションの始まりではなく、行が'=' を含まない行は、行全体を名前とみなします。
      値は空文字列になります。
   6) セクションの前の一連のコメントはセクションのコメントになります。
      セクションのコメントは ReadSectionCommentメソッドで取得できます。
   7) 名前/値ペアの前の一連のコメントは名前/値ペアのコメントになります。
      名前のコメントは ReadCommentメソッドで取得できます。
   8) 最後のセクションの最後の名前/値ペアより後の一連のコメントは
      「無名」のセクションのコメントになります。このコメントは
      ReadSectionComment('')
      で取得できます。
   9) 「無名」のセクションは常に作成されます。
  
   注意) 空白とは コード$20 以下の全ての半角文字のことです。


1.4.1. クラス TNkMemIniFile の Public 部

1.4.1.1. TNkMemIniFile クラスの Public 部の プロパティ

1.4.1.1.1 CaseSensitive プロパティ

宣言
  property CaseSensitive: Boolean read GetCaseSensitive write SetCaseSensitive;

説明
  名前の大小を区別する
  詳細
    セクション名、名前で検索を行うとき、大文字小文字を区別するかを指定します。
    このプロパティはいつでも変更できますが、Trueから False に変更するとき
    注意が必要です。Trueから False に変更すると、大文字/小文字だけが
    異なるセクション名や名前は同名とみなされるようになります。
    同名となったセクションや名前は「あと」の方のもので上書きされます。
    デフォルトは False です。


1.4.1.2. TNkMemIniFile クラスの Public 部の メソッド

1.4.1.2.1 Clear メソッド

宣言
  procedure Clear;

説明
  クリア
  詳細
    TNkMemIniFileに保持されている全てのセクションと名前/値ペアを削除します。
    セクションのコメントや名前のコメントも全て削除されます。


1.4.1.2.2 Create メソッド

宣言
  constructor Create(const FileName: string);

説明
  コンストラクタ
  パラメータ
    FileName: Iniファイルのファイル名です。
  詳細
    Iniファイルを読み込み TNkMemIniFileのインスタンスを作成します。


1.4.1.2.3 DeleteKey メソッド

宣言
  procedure DeleteKey(const Section, Ident: String); override;

説明
  名前の削除
  パラメータ
    Section: セクション名。前後の空白は無視されます。
             CaseSensitive プロパティが True のときは Section の
             文字の大小は区別されます。falseの時は区別されません。
    Ident:   名前です。前後の空白は無視されます。
             CaseSensitive プロパティが True のときは Ident の
             文字の大小は区別されます。falseの時は区別されません。
  詳細
    セクションと名前で指定された名前を削除します。
    名前に関連付けられたコメントも削除されます。
    存在しない名前が指定されたときは何もしません。
    セクション、名前が不正な場合も何もしません。


1.4.1.2.4 Destroy メソッド

宣言
  destructor Destroy; override;

説明
  デストラクタ
  詳細
    TNkMemIniFile を破棄します。


1.4.1.2.5 EraseSection メソッド

宣言
  procedure EraseSection(const Section: string); override;

説明
  セクションを削除
  パラメータ
    Section: セクション名。前後の空白は無視されます。
             CaseSensitive プロパティが True のときは Section の
             文字の大小は区別されます。falseの時は区別されません。
  詳細
    指定されたセクションを削除します。セクションに関連付けられた
    コメントも削除されます。
    無名セクションを削除しようとすると ENkMemIniFileInvalidSection
    例外が起きます。


1.4.1.2.6 GetStrings メソッド

宣言
  procedure GetStrings(List: TStrings);

説明
  ファイルイメージの取得
  パラメータ
    List: TStringsの下位クラスのインスタンス
  詳細
    TNkMemIniFileがIniファイルへ書き出すテキストイメージを取得します。
    GetStrings は List にテキストイメージを「加えます」。加える前に
    Listをクリアしないので注意してください。
    List は作成済みの TStringsの下位クラスのインスタンスを指定してください。
    作成されるテキストイメージに関しては UpdateFileメソッドの詳細を
    参照してください。


1.4.1.2.7 ReadComment メソッド

宣言
  function  ReadComment(const Section, Ident: string): string; overload;

説明
  セクション名/キー名で指定したキーのコメントを読む
  パラメータ
    Section: セクション名。前後の空白は無視されます。
             CaseSensitive プロパティが True のときは Section の
             文字の大小は区別されます。falseの時は区別されません。
    Ident:   名前です。前後の空白は無視されます。
             CaseSensitive プロパティが True のときは Ident の
             文字の大小は区別されます。falseの時は区別されません。
  戻り値
    コメントが文字列として返されます。
  詳細
    指定された名前のコメントを返します。
    コメントが無い場合や、名前が無い場合は ''(空文字列)が返ります。
    コメントは';'付きです。不要な場合はアプリケーション側で取り除いてください。
    コメントが複数行になる時は戻り値は #13#10を含みます。
    コメントの最後に #13#10が付くことはありません。


1.4.1.2.8 ReadComment メソッド

宣言
  procedure ReadComment(const Section, Ident: string; Comment: TStrings); overload;

説明
  セクション名/キー名で指定したキーのコメントを読む
  パラメータ
    Section: セクション名。前後の空白は無視されます。
             CaseSensitive プロパティが True のときは Section の
             文字の大小は区別されます。falseの時は区別されません。
    Ident:   名前です。前後の空白は無視されます。
             CaseSensitive プロパティが True のときは Ident の
             文字の大小は区別されます。falseの時は区別されません。
    Comment: コメントが入る TStringsの下位クラスのインスタンス
  詳細
    指定されたセクションの指定された名前のコメントを Comment に返します。
    Commentはコメントが入る前にクリアされます。
    コメントが無い場合や、名前が無い場合は 0 行のコメントが返ります。
    コメントは';'付きです。不要な場合はアプリケーション側で取り除いてください。


1.4.1.2.9 ReadSection メソッド

宣言
  procedure ReadSection(const Section: string; KeyNames: TStrings); override;

説明
  セクション内のキーの一覧の取得。
  パラメータ
    Section:  セクション名。前後の空白は無視されます。
              CaseSensitive プロパティが True のときは Section の
              文字の大小は区別されます。falseの時は区別されません。
    KeyNames: 名前のリストが入る TStringsの下位クラスのインスタンス
  詳細
    指定されたセクション内の名前の一覧を返します。名前は KeyNamesの１行に
    １個ずつ入ります。
    KeyNamesは名前のリストが入る前にクリアされます。
    KeyNames は作成済みの TStringsの下位クラスのインスタンスを指定してください。
    無名セクションの名前の一覧は常に空です。


1.4.1.2.10 ReadSectionComment メソッド

宣言
  function  ReadSectionComment(const Section: string): string; overload;

説明
  セクションのコメントを読む
  パラメータ
    Section: セクション名。前後の空白は無視されます。
             CaseSensitive プロパティが True のときは Section の
             文字の大小は区別されます。falseの時は区別されません。
             空文字列を指定すると無名のセクションのコメントが読めます。
  戻り値
    コメントが文字列として返されます。
  詳細
    指定されたセクションのコメントを返します。
    コメントが無い場合や、セクションが無い場合は ''(空文字列)が返ります。
    コメントは';'付きです。不要な場合はアプリケーション側で取り除いてください。
    コメントが複数行になる時は戻り値は #13#10を含みます。
    コメントの最後に #13#10が付くことはありません。
    Sectionの前後の空白をトリムした結果が空文字列の場合、
    無名のセクションを指定したことになります。


1.4.1.2.11 ReadSectionComment メソッド

宣言
  procedure ReadSectionComment(const Section: string; Comment: TStrings); overload;

説明
  セクションのコメントを読む
  パラメータ
    Section: セクション名。前後の空白は無視されます。
             CaseSensitive プロパティが True のときは Section の
             文字の大小は区別されます。falseの時は区別されません。
             空文字列を指定すると無名のセクションのコメントが読めます。
    Comment: コメントが入る TStringsの下位クラスのインスタンス
  詳細
    指定されたセクションのコメントを Comment に返します。
    Commentはコメントが入る前にクリアされます。
    コメントが無い場合や、セクションが無い場合は 0 行のコメントが返ります。
    コメントは';'付きです。不要な場合はアプリケーション側で取り除いてください。
    Sectionの前後の空白をトリムした結果が空文字列の場合、
    無名のセクションを指定したことになります。


1.4.1.2.12 ReadSections メソッド

宣言
  procedure ReadSections(SectionNames: TStrings); override;

説明
  セクション名の一覧を取得
  パラメータ
    SectioNames: セクション名のリストが入る TStringsの下位クラスのインスタンス
  詳細
    セクション名の一覧を返します。セクション名は SectionNamesの１行に
    １個ずつ入ります。
    SectionNamesは名前のリストが入る前にクリアされます。
    SectionNames は作成済みの TStringsの下位クラスのインスタンスを指定してください。
    セクション名の一覧には無名セクションは含まれません。


1.4.1.2.13 ReadSectionValues メソッド

宣言
  procedure ReadSectionValues(const Section: string; KeyValues: TStrings); override;

説明
  セクション内の 名前=値　のリストを取得
  パラメータ
    Section:   セクション名。前後の空白は無視されます。
               CaseSensitive プロパティが True のときは Section の
               文字の大小は区別されます。falseの時は区別されません。
    KeyValues: キー/値ペアのリストが入る TStringsの下位クラスのインスタンス
  詳細
    指定されたセクションの名前/値ペアの一覧を取得します。
    名前/値ペアは KeyValuesの１行に１個ずつ入ります。
    名前/値ペアはIniファイル上のテキスト表現と同じになります。
    値が 空白を含む場合や引用符を含む場合は、値は引用符で囲まれます。
    引用符は２重引用符に変換されます(CSVと同じ)。
    KeyValesは名前のリストが入る前にクリアされます。
    KeyVales は作成済みの TStringsの下位クラスのインスタンスを指定してください。
    無名セクションの名前/値ペアの一覧は常に空です。


1.4.1.2.14 ReadString メソッド

宣言
  function ReadString(const Section, Ident, Default: string): string; override;

説明
  値の読み込み
  パラメータ
    Section: セクション名。前後の空白は無視されます。
             CaseSensitive プロパティが True のときは Section の
             文字の大小は区別されます。falseの時は区別されません。
    Ident:   名前です。前後の空白は無視されます。
             CaseSensitive プロパティが True のときは Ident の
             文字の大小は区別されます。falseの時は区別されません。
    Default: セクションに名前が存在しなかったとき ReadString が返す値です。
  戻り値
     読み取った値が文字列として返されます。
  詳細
    指定されたセクションの指定された名前の値を返します。
    値が存在しなかった場合は Default を返します。


1.4.1.2.15 UpdateFile メソッド

宣言
  procedure UpdateFile; override;

説明
   ファイルを更新する。
   詳細
     TNkMemIniFile内のセクションと名前/値ペアをIniファイルに書き込みます。
     Iniファイルはコンストラクタで指定したものです。
     Iniファイルは以下の様に書き込まれます。
  
     1) セクション名のコメントはセクションの前に書き込まれます。
     2) セクションは
  
        [セクション名]
  
        というように書き込まれます。セクション名の前にインデントは
        挿入されません。
     3) 各名前/値ペアの前に、名前/値ペアのコメントが書かれます。
     4) 各名前/値ペアは
  
        名前=値
  
        という形式で書かれます。
        名前の前にインデントは挿入されません。
        名前と=, = と値の間には空白は挿入されません。
        値が 空白を服務場合や、引用符(")を含む場合、値は 引用符で
        囲まれて書き込まれます。値が引用符(")を含む場合は ("")に変換されて
        書き込まれます(CSVとおなじ)。この仕様は TMemIniFile や TIniファイルとは
        ことなるので注意してください。
  
        TIniFileでは前後に空白を含む値を引用符で囲んで書き込みますが、
        引用符を ("")に変換しません。
        TMemIniFile は引用符を無視して普通の文字列として扱います。
        また、値の前後に空白が含まれている場合はトリムしてから書き込みます。


1.4.1.2.16 WriteComment メソッド

宣言
  procedure WriteComment(const Section, Ident, Comment: string); overload;

説明
  セクション名/キー名で指定したキーにコメントを書き込む
  パラメータ
    Section: セクション名。前後の空白は無視されます。
             CaseSensitive プロパティが True のときは Section の
             文字の大小は区別されます。falseの時は区別されません。
    Ident:   名前です。前後の空白は無視されます。
             CaseSensitive プロパティが True のときは Ident の
             文字の大小は区別されます。falseの時は区別されません。
    Comment: 設定するコメントです。 文字列で指定します。文字列は複数行でも
             問題ありません。コメントの各行の先頭に ';' が付いている
             必要はありません。';' は必要に応じて自動的に付加されます。
  詳細
    指定されたセクションの指定された名前にコメントを設定します。
    指定された名前が無い場合は何もしません。
    コメントの各行の先頭に ';' が付いている必要はありません。
             ';' は必要に応じて自動的に付加されます。


1.4.1.2.17 WriteComment メソッド

宣言
  procedure WriteComment(const Section, Ident: string; Comment: TStrings); overload;

説明
  セクション名/キー名で指定したキーにコメントを書き込む
  パラメータ
    Section: セクション名。前後の空白は無視されます。
             CaseSensitive プロパティが True のときは Section の
             文字の大小は区別されます。falseの時は区別されません。
    Ident:   名前です。前後の空白は無視されます。
             CaseSensitive プロパティが True のときは Ident の
             文字の大小は区別されます。falseの時は区別されません。
    Comment: 設定するコメントです。 TStringsの下位クラスのインスタンスを
             してします。各行の先頭に ';' が付いている必要はありません。
             ';' は必要に応じて自動的に付加されます。
  詳細
    指定されたセクションの指定された名前にコメントを設定します。
    指定した名前が無い場合は何もしません。
    コメントの各行の先頭に ';' が付いている必要はありません。
             ';' は必要に応じて自動的に付加されます。


1.4.1.2.18 WriteSectionComment メソッド

宣言
  procedure WriteSectionComment(const Section: string; Comment: TStrings); overload;

説明
  セクションにコメントを書きこむ
  パラメータ
    Section: セクション名。前後の空白は無視されます。
             CaseSensitive プロパティが True のときは Section の
             文字の大小は区別されます。falseの時は区別されません。
             空文字列を指定すると無名のセクションにコメントを設定できます。
    Comment: 設定するコメントです。 TStringsの下位クラスのインスタンスを
             してします。各行の先頭に ';' が付いている必要はありません。
             ';' は必要に応じて自動的に付加されます。
  詳細
    指定されたセクションにコメントを設定します。
    セクションが無い場合は何もしません。
    コメントの各行の先頭に ';' が付いている必要はありません。
             ';' は必要に応じて自動的に付加されます。
    Sectionの前後の空白をトリムした結果が空文字列の場合、
    無名のセクションを指定したことになります。


1.4.1.2.19 WriteSectionComment メソッド

宣言
  procedure WriteSectionComment(const Section, Comment: string); overload;

説明
  セクションにコメントを書きこむ
  パラメータ
    Section: セクション名。前後の空白は無視されます。
             CaseSensitive プロパティが True のときは Section の
             文字の大小は区別されます。falseの時は区別されません。
    Comment: 設定するコメントです。 文字列で指定します。文字列は複数行でも
             問題ありません。コメントの各行の先頭に ';' が付いている
             必要はありません。';' は必要に応じて自動的に付加されます。
  詳細
    指定されたセクションにコメントを設定します。
    セクションが無い場合は何もしません。
    コメントの各行の先頭に ';' が付いている必要はありません。
             ';' は必要に応じて自動的に付加されます。
    Sectionの前後の空白をトリムした結果が空文字列の場合、
    無名のセクションを指定したことになります。


1.4.1.2.20 WriteString メソッド

宣言
  procedure WriteString(const Section, Ident, Value: String); override;

説明
  セクション名/キー名で指定したキーに値を書き込む
  パラメータ
    Section: セクション名。前後の空白は無視されます。
             CaseSensitive プロパティが True のときは Section の
             文字の大小は区別されます。falseの時は区別されません。
    Ident:   名前です。前後の空白は無視されます。
             CaseSensitive プロパティが True のときは Ident の
             文字の大小は区別されます。falseの時は区別されません。
    Value:   書き込む値です。
  詳細
    指定されたセクションの指定された値を更新します。
    指定されたセクションが無ければ作られます。指定された名前が無ければ
    作られます。
    Sectionの前後の空白をトリムした後の文字列が空文字列のとき
    ENkMemIniFileInvalidSection例外が起きます。
    Identの前後の空白をトリムした後の文字列が空文字列の場合や '=' を
    含む場合は ENkMemIniFileInvalidName例外が起きます。
    Value はぞのまま書き込まれます。前後に空白があってもそのまま書き込まれます。
    但しValueが CR や LF を含む場合はENkMemIniFileInvalidValue例外が起きます。


