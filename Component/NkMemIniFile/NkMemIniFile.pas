{$A8,B-,H+,I+,J-,K-,L+,M-,N+,P+,Q-,R-,T-,U-,V+,W-,X+,Y+,Z1}

//////////
// NkMemIniFile ���j�b�g
//
// TNkmemIniFile: �g���� TMemIniFile
//�@ Coded By T. Nakamura
//   Ver 0.1 2006/07/02
//   Ver 0.2 2006/07/02
//   Ver 0.3 2006/07/16
//
//  TNkMemIniFile �� TMemIniFile �̊g���łł��B
//  ���̓���������Ă��܂��B
//  1) ���O�ƒl�ɓ��{�ꂪ�g�p�ł��܂��B
//  2) ���O�ɃR�����g��t���ł��܂��B
//  3) �Z�N�V�����ɃR�����g��t���ł��܂��B
//  4) ���O/�l�y�A�̎Q�Ƃ������ł��B
//     �Z�N�V�����Ɩ��O���n�b�V���ō����Ɍ������܂��B
//     ���x�� TmemIniFile �ƂقǓ����ł��� TIniFile���͂邩�ɍ����ł��B
//  5) ���O/�l�y�A�̍X�V�A�ǉ��A�폜�� TMemIniFile�ɔ�וS�{�����ł��B
//  6) �l�Ɉ��p�����T�|�[�g���Ă��܂��B�l���󔒂��܂ޏꍇ��A
//     ���p�����܂܂��ꍇ�A�l�� ���p���ň͂܂�ď������܂�܂��B
//     �l�̒��̈��p�����Q�̈��p���ɒu�������܂�(CSV�Ɠ���)�B
//
//  �g�p�̏ڍׂ̓��\�b�h�̐��������Ă��������B
//
//  TMemIniFile �Ƃ̐��\��r
//  ������� Windows XP SP2, Celeron 2.4GHz, ������ 512MHz, Delphi 7
//
//   TMemIniFile
//    Load(10���L�[)       Time =     0.36 Sec
//    Read(10���L�[)       Time =     0.58 Sec
//    Update(10���L�[)     Time =   370.20 Sec
//    Delete(10���L�[)     Time =   145.59 Sec
//    Add(10���L�[)        Time =   156.84 Sec
//    UpdateFile(10���L�[) Time =     0.16 Sec
//
//   TNkMemIniFile
//    Load(10���L�[)       Time =     1.30 Sec
//    Read(10���L�[)       Time =     0.91 Sec
//    Update(10���L�[)     Time =     0.84 Sec
//    Delete(10���L�[)     Time =     1.22 Sec
//    Add(10���L�[)        Time =     1.38 Sec
//    UpdateFile(10���L�[) Time =     0.30 Sec
//
//  �{�\�t�g�E�F�A�̎g�p�A�z�z����ςɈ�؂̐�����
//  �݂��܂���B���p���p���o���܂����A���p�ɍۂ��Ē��쌠
//  �\�����s�v�ł��B�����R�ɂ��g�����������B
//  �Ȃ��A�����̎g�p�ɂ���Đ������s��̐ӔC�͈�ؕ�
//  ���܂���B�\�߂��������������B


unit NkMemIniFile;

interface

uses
  Classes, SysUtils, IniFIles, Contnrs, NkStringList;

type
  // ���O�ُ̈��\����O�ł��B
  ENkMemIniFileInvalidName = class(Exception)
  end;

  // �Z�N�V�������ُ̈��\����O�ł��B
  ENkMemIniFileInvalidSection = class(Exception)
  end;

  // �l�ُ̈��\����O�ł��B
  ENkMemIniFileInvalidValue = class(Exception)
  end;


  // �L�[�̃R�����g��\���N���X�ł��B
  // �A�v���P�[�V�����̒��ł͎g��Ȃ��ł��������B
  TNkComment = class
  private
    // �R�����g��ێ�����t�B�[���h
    FComment: TStringList;
  public
    // �R���X�g���N�^
    constructor Create;
    // �f�X�g���N�^
    destructor Destroy; override;
    // �R�����g
    property Comment: TStringList read FComment write FComment;
  end;

  // �Z�N�V������\���N���X�ł��B
  // �A�v���P�[�V�����̒��ł͎g��Ȃ��ł��������B
  TNkMemIniSection = class;


  // Ini�t�@�C������p�N���X
  // TMemIniFile �̑�փN���X�ł��B
  //
  // TMemIniFile �͈ȉ��̗l�� Ini�t�@�C�����p�[�X���܂��B
  //
  // 1) �󔒍s(�g�����������ʕ����̖����s)�͖������܂��B
  // 2) �s���g�����������ʐ擪�̕����� ; �̏ꍇ�A�R�����g�Ƃ݂Ȃ��܂��B
  //    �R�����g�̓g�����O�̂��̂���荞�܂�܂��B
  // 3) �s���g�����������ʁA�擪��'['�ōŌ�̕�����']'�̏ꍇ�Z�N�V�����̎n�܂��
  //    �݂Ȃ��܂��B'['��']'���������������Z�N�V�������Ƃ݂Ȃ��܂��B
  //    �A���Z�N�V���������󕶎���̏ꍇ�͖������܂��B
  // 4) �Z�N�V�����̎n�܂�ł͂Ȃ��A�s��'=' ���܂ލs�͖��O/�l�y�A�Ƃ��ăp�[�X���܂��B
  //    ���O�͖��O����('='���O�̕���)�̑O��̋󔒂̓g����������o����܂��B
  //    �l�͒l�̕���('='����̕���)�̑O��̋󔒂̓g����������o����܂��B
  //    ���o���ꂽ�l�� ���p��(")�ň͂܂�Ă���ꍇ�́A���p������菜����A
  //    �Q�d�̈��p��("")�� ���p��(")�ɕϊ�����܂��B
  //    ���O���󕶎���ɂȂ����ꍇ�͖��O/�l�y�A�͖�������܂��B
  // 5) �Z�N�V�����̎n�܂�ł͂Ȃ��A�s��'=' ���܂܂Ȃ��s�́A�s�S�̂𖼑O�Ƃ݂Ȃ��܂��B
  //    �l�͋󕶎���ɂȂ�܂��B
  // 6) �Z�N�V�����̑O�̈�A�̃R�����g�̓Z�N�V�����̃R�����g�ɂȂ�܂��B
  //    �Z�N�V�����̃R�����g�� ReadSectionComment���\�b�h�Ŏ擾�ł��܂��B
  // 7) ���O/�l�y�A�̑O�̈�A�̃R�����g�͖��O/�l�y�A�̃R�����g�ɂȂ�܂��B
  //    ���O�̃R�����g�� ReadComment���\�b�h�Ŏ擾�ł��܂��B
  // 8) �Ō�̃Z�N�V�����̍Ō�̖��O/�l�y�A����̈�A�̃R�����g��
  //    �u�����v�̃Z�N�V�����̃R�����g�ɂȂ�܂��B���̃R�����g��
  //    ReadSectionComment('')
  //    �Ŏ擾�ł��܂��B
  // 9) �u�����v�̃Z�N�V�����͏�ɍ쐬����܂��B
  //
  // ����) �󔒂Ƃ� �R�[�h$20 �ȉ��̑S�Ă̔��p�����̂��Ƃł��B

  TNkMemIniFile = class(TCustomIniFile)
  private
    // �Z�N�V�����̃��X�g
    FSections: TNkHashedStringList;
    // �Z�N�V������ǉ�����B
    function AddSection(const Section: string): TNkMemIniSection;
    // �Z�N�V����������Z�N�V�����𓾂�B
    function GetSection(const Section: string): TNkMemIniSection;
    // �����̑召��ʂ𓾂�
    function GetCaseSensitive: Boolean;
    // �����̑召��ʂ�ݒ肷��
    procedure SetCaseSensitive(Value: Boolean);
    // �S�ẴL�[/�l�̓ǂݍ���
    procedure LoadValues;
    // �����񃊃X�g���� TNkMemIniFile��������
    procedure SetStrings(List: TStringList);
  public
    // �R���X�g���N�^
    // �p�����[�^
    //   FileName: Ini�t�@�C���̃t�@�C�����ł��B
    // �ڍ�
    //   Ini�t�@�C����ǂݍ��� TNkMemIniFile�̃C���X�^���X���쐬���܂��B
    constructor Create(const FileName: string);
    // �f�X�g���N�^
    // �ڍ�
    //   TNkMemIniFile ��j�����܂��B
    destructor Destroy; override;
    // �N���A
    // �ڍ�
    //   TNkMemIniFile�ɕێ�����Ă���S�ẴZ�N�V�����Ɩ��O/�l�y�A���폜���܂��B
    //   �Z�N�V�����̃R�����g�▼�O�̃R�����g���S�č폜����܂��B
    procedure Clear;
    // ���O�̍폜
    // �p�����[�^
    //   Section: �Z�N�V�������B�O��̋󔒂͖�������܂��B
    //            CaseSensitive �v���p�e�B�� True �̂Ƃ��� Section ��
    //            �����̑召�͋�ʂ���܂��Bfalse�̎��͋�ʂ���܂���B
    //   Ident:   ���O�ł��B�O��̋󔒂͖�������܂��B
    //            CaseSensitive �v���p�e�B�� True �̂Ƃ��� Ident ��
    //            �����̑召�͋�ʂ���܂��Bfalse�̎��͋�ʂ���܂���B
    // �ڍ�
    //   �Z�N�V�����Ɩ��O�Ŏw�肳�ꂽ���O���폜���܂��B
    //   ���O�Ɋ֘A�t����ꂽ�R�����g���폜����܂��B
    //   ���݂��Ȃ����O���w�肳�ꂽ�Ƃ��͉������܂���B
    //   �Z�N�V�����A���O���s���ȏꍇ���������܂���B
    procedure DeleteKey(const Section, Ident: String); override;
    // �Z�N�V�������폜
    // �p�����[�^
    //   Section: �Z�N�V�������B�O��̋󔒂͖�������܂��B
    //            CaseSensitive �v���p�e�B�� True �̂Ƃ��� Section ��
    //            �����̑召�͋�ʂ���܂��Bfalse�̎��͋�ʂ���܂���B
    // �ڍ�
    //   �w�肳�ꂽ�Z�N�V�������폜���܂��B�Z�N�V�����Ɋ֘A�t����ꂽ
    //   �R�����g���폜����܂��B
    //   �����Z�N�V�������폜���悤�Ƃ���� ENkMemIniFileInvalidSection
    //   ��O���N���܂��B
    procedure EraseSection(const Section: string); override;
    // �t�@�C���C���[�W�̎擾
    // �p�����[�^
    //   List: TStrings�̉��ʃN���X�̃C���X�^���X
    // �ڍ�
    //   TNkMemIniFile��Ini�t�@�C���֏����o���e�L�X�g�C���[�W���擾���܂��B
    //   GetStrings �� List �Ƀe�L�X�g�C���[�W���u�����܂��v�B������O��
    //   List���N���A���Ȃ��̂Œ��ӂ��Ă��������B
    //   List �͍쐬�ς݂� TStrings�̉��ʃN���X�̃C���X�^���X���w�肵�Ă��������B
    //   �쐬�����e�L�X�g�C���[�W�Ɋւ��Ă� UpdateFile���\�b�h�̏ڍׂ�
    //   �Q�Ƃ��Ă��������B
    procedure GetStrings(List: TStrings);
    // �Z�N�V�������̃L�[�̈ꗗ�̎擾�B
    // �p�����[�^
    //   Section:  �Z�N�V�������B�O��̋󔒂͖�������܂��B
    //             CaseSensitive �v���p�e�B�� True �̂Ƃ��� Section ��
    //             �����̑召�͋�ʂ���܂��Bfalse�̎��͋�ʂ���܂���B
    //   KeyNames: ���O�̃��X�g������ TStrings�̉��ʃN���X�̃C���X�^���X
    // �ڍ�
    //   �w�肳�ꂽ�Z�N�V�������̖��O�̈ꗗ��Ԃ��܂��B���O�� KeyNames�̂P�s��
    //   �P������܂��B
    //   KeyNames�͖��O�̃��X�g������O�ɃN���A����܂��B
    //   KeyNames �͍쐬�ς݂� TStrings�̉��ʃN���X�̃C���X�^���X���w�肵�Ă��������B
    //   �����Z�N�V�����̖��O�̈ꗗ�͏�ɋ�ł��B
    procedure ReadSection(const Section: string; KeyNames: TStrings); override;
    // �Z�N�V�������̈ꗗ���擾
    // �p�����[�^
    //   SectioNames: �Z�N�V�������̃��X�g������ TStrings�̉��ʃN���X�̃C���X�^���X
    // �ڍ�
    //   �Z�N�V�������̈ꗗ��Ԃ��܂��B�Z�N�V�������� SectionNames�̂P�s��
    //   �P������܂��B
    //   SectionNames�͖��O�̃��X�g������O�ɃN���A����܂��B
    //   SectionNames �͍쐬�ς݂� TStrings�̉��ʃN���X�̃C���X�^���X���w�肵�Ă��������B
    //   �Z�N�V�������̈ꗗ�ɂ͖����Z�N�V�����͊܂܂�܂���B
    procedure ReadSections(SectionNames: TStrings); override;
    // �Z�N�V�������� ���O=�l�@�̃��X�g���擾
    // �p�����[�^
    //   Section:   �Z�N�V�������B�O��̋󔒂͖�������܂��B
    //              CaseSensitive �v���p�e�B�� True �̂Ƃ��� Section ��
    //              �����̑召�͋�ʂ���܂��Bfalse�̎��͋�ʂ���܂���B
    //   KeyValues: �L�[/�l�y�A�̃��X�g������ TStrings�̉��ʃN���X�̃C���X�^���X
    // �ڍ�
    //   �w�肳�ꂽ�Z�N�V�����̖��O/�l�y�A�̈ꗗ���擾���܂��B
    //   ���O/�l�y�A�� KeyValues�̂P�s�ɂP������܂��B
    //   ���O/�l�y�A��Ini�t�@�C����̃e�L�X�g�\���Ɠ����ɂȂ�܂��B
    //   �l�� �󔒂��܂ޏꍇ����p�����܂ޏꍇ�́A�l�͈��p���ň͂܂�܂��B
    //   ���p���͂Q�d���p���ɕϊ�����܂�(CSV�Ɠ���)�B
    //   KeyVales�͖��O�̃��X�g������O�ɃN���A����܂��B
    //   KeyVales �͍쐬�ς݂� TStrings�̉��ʃN���X�̃C���X�^���X���w�肵�Ă��������B
    //   �����Z�N�V�����̖��O/�l�y�A�̈ꗗ�͏�ɋ�ł��B
    procedure ReadSectionValues(const Section: string; KeyValues: TStrings); override;
    // �l�̓ǂݍ���
    // �p�����[�^
    //   Section: �Z�N�V�������B�O��̋󔒂͖�������܂��B
    //            CaseSensitive �v���p�e�B�� True �̂Ƃ��� Section ��
    //            �����̑召�͋�ʂ���܂��Bfalse�̎��͋�ʂ���܂���B
    //   Ident:   ���O�ł��B�O��̋󔒂͖�������܂��B
    //            CaseSensitive �v���p�e�B�� True �̂Ƃ��� Ident ��
    //            �����̑召�͋�ʂ���܂��Bfalse�̎��͋�ʂ���܂���B
    //   Default: �Z�N�V�����ɖ��O�����݂��Ȃ������Ƃ� ReadString ���Ԃ��l�ł��B
    // �߂�l
    //    �ǂݎ�����l��������Ƃ��ĕԂ���܂��B
    // �ڍ�
    //   �w�肳�ꂽ�Z�N�V�����̎w�肳�ꂽ���O�̒l��Ԃ��܂��B
    //   �l�����݂��Ȃ������ꍇ�� Default ��Ԃ��܂��B
    function ReadString(const Section, Ident, Default: string): string; override;
    // �Z�N�V�����̃R�����g��ǂ�
    // �p�����[�^
    //   Section: �Z�N�V�������B�O��̋󔒂͖�������܂��B
    //            CaseSensitive �v���p�e�B�� True �̂Ƃ��� Section ��
    //            �����̑召�͋�ʂ���܂��Bfalse�̎��͋�ʂ���܂���B
    //            �󕶎�����w�肷��Ɩ����̃Z�N�V�����̃R�����g���ǂ߂܂��B
    //   Comment: �R�����g������ TStrings�̉��ʃN���X�̃C���X�^���X
    // �ڍ�
    //   �w�肳�ꂽ�Z�N�V�����̃R�����g�� Comment �ɕԂ��܂��B
    //   Comment�̓R�����g������O�ɃN���A����܂��B
    //   �R�����g�������ꍇ��A�Z�N�V�����������ꍇ�� 0 �s�̃R�����g���Ԃ�܂��B
    //   �R�����g��';'�t���ł��B�s�v�ȏꍇ�̓A�v���P�[�V�������Ŏ�菜���Ă��������B
    //   Section�̑O��̋󔒂��g�����������ʂ��󕶎���̏ꍇ�A
    //   �����̃Z�N�V�������w�肵�����ƂɂȂ�܂��B
    procedure ReadSectionComment(const Section: string; Comment: TStrings); overload;
    // �Z�N�V�����̃R�����g��ǂ�
    // �p�����[�^
    //   Section: �Z�N�V�������B�O��̋󔒂͖�������܂��B
    //            CaseSensitive �v���p�e�B�� True �̂Ƃ��� Section ��
    //            �����̑召�͋�ʂ���܂��Bfalse�̎��͋�ʂ���܂���B
    //            �󕶎�����w�肷��Ɩ����̃Z�N�V�����̃R�����g���ǂ߂܂��B
    // �߂�l
    //   �R�����g��������Ƃ��ĕԂ���܂��B
    // �ڍ�
    //   �w�肳�ꂽ�Z�N�V�����̃R�����g��Ԃ��܂��B
    //   �R�����g�������ꍇ��A�Z�N�V�����������ꍇ�� ''(�󕶎���)���Ԃ�܂��B
    //   �R�����g��';'�t���ł��B�s�v�ȏꍇ�̓A�v���P�[�V�������Ŏ�菜���Ă��������B
    //   �R�����g�������s�ɂȂ鎞�͖߂�l�� #13#10���܂݂܂��B
    //   �R�����g�̍Ō�� #13#10���t�����Ƃ͂���܂���B
    //   Section�̑O��̋󔒂��g�����������ʂ��󕶎���̏ꍇ�A
    //   �����̃Z�N�V�������w�肵�����ƂɂȂ�܂��B
    function  ReadSectionComment(const Section: string): string; overload;
    // �Z�N�V������/�L�[���Ŏw�肵���L�[�̃R�����g��ǂ�
    // �p�����[�^
    //   Section: �Z�N�V�������B�O��̋󔒂͖�������܂��B
    //            CaseSensitive �v���p�e�B�� True �̂Ƃ��� Section ��
    //            �����̑召�͋�ʂ���܂��Bfalse�̎��͋�ʂ���܂���B
    //   Ident:   ���O�ł��B�O��̋󔒂͖�������܂��B
    //            CaseSensitive �v���p�e�B�� True �̂Ƃ��� Ident ��
    //            �����̑召�͋�ʂ���܂��Bfalse�̎��͋�ʂ���܂���B
    //   Comment: �R�����g������ TStrings�̉��ʃN���X�̃C���X�^���X
    // �ڍ�
    //   �w�肳�ꂽ�Z�N�V�����̎w�肳�ꂽ���O�̃R�����g�� Comment �ɕԂ��܂��B
    //   Comment�̓R�����g������O�ɃN���A����܂��B
    //   �R�����g�������ꍇ��A���O�������ꍇ�� 0 �s�̃R�����g���Ԃ�܂��B
    //   �R�����g��';'�t���ł��B�s�v�ȏꍇ�̓A�v���P�[�V�������Ŏ�菜���Ă��������B
    procedure ReadComment(const Section, Ident: string; Comment: TStrings); overload;
    // �Z�N�V������/�L�[���Ŏw�肵���L�[�̃R�����g��ǂ�
    // �p�����[�^
    //   Section: �Z�N�V�������B�O��̋󔒂͖�������܂��B
    //            CaseSensitive �v���p�e�B�� True �̂Ƃ��� Section ��
    //            �����̑召�͋�ʂ���܂��Bfalse�̎��͋�ʂ���܂���B
    //   Ident:   ���O�ł��B�O��̋󔒂͖�������܂��B
    //            CaseSensitive �v���p�e�B�� True �̂Ƃ��� Ident ��
    //            �����̑召�͋�ʂ���܂��Bfalse�̎��͋�ʂ���܂���B
    // �߂�l
    //   �R�����g��������Ƃ��ĕԂ���܂��B
    // �ڍ�
    //   �w�肳�ꂽ���O�̃R�����g��Ԃ��܂��B
    //   �R�����g�������ꍇ��A���O�������ꍇ�� ''(�󕶎���)���Ԃ�܂��B
    //   �R�����g��';'�t���ł��B�s�v�ȏꍇ�̓A�v���P�[�V�������Ŏ�菜���Ă��������B
    //   �R�����g�������s�ɂȂ鎞�͖߂�l�� #13#10���܂݂܂��B
    //   �R�����g�̍Ō�� #13#10���t�����Ƃ͂���܂���B
    function  ReadComment(const Section, Ident: string): string; overload;
    // �Z�N�V�����ɃR�����g����������
    // �p�����[�^
    //   Section: �Z�N�V�������B�O��̋󔒂͖�������܂��B
    //            CaseSensitive �v���p�e�B�� True �̂Ƃ��� Section ��
    //            �����̑召�͋�ʂ���܂��Bfalse�̎��͋�ʂ���܂���B
    //            �󕶎�����w�肷��Ɩ����̃Z�N�V�����ɃR�����g��ݒ�ł��܂��B
    //   Comment: �ݒ肷��R�����g�ł��B TStrings�̉��ʃN���X�̃C���X�^���X��
    //            ���Ă��܂��B�e�s�̐擪�� ';' ���t���Ă���K�v�͂���܂���B
    //            ';' �͕K�v�ɉ����Ď����I�ɕt������܂��B
    // �ڍ�
    //   �w�肳�ꂽ�Z�N�V�����ɃR�����g��ݒ肵�܂��B
    //   �Z�N�V�����������ꍇ�͉������܂���B
    //   �R�����g�̊e�s�̐擪�� ';' ���t���Ă���K�v�͂���܂���B
    //            ';' �͕K�v�ɉ����Ď����I�ɕt������܂��B
    //   Section�̑O��̋󔒂��g�����������ʂ��󕶎���̏ꍇ�A
    //   �����̃Z�N�V�������w�肵�����ƂɂȂ�܂��B
    procedure WriteSectionComment(const Section: string; Comment: TStrings); overload;
    // �Z�N�V�����ɃR�����g����������
    // �p�����[�^
    //   Section: �Z�N�V�������B�O��̋󔒂͖�������܂��B
    //            CaseSensitive �v���p�e�B�� True �̂Ƃ��� Section ��
    //            �����̑召�͋�ʂ���܂��Bfalse�̎��͋�ʂ���܂���B
    //   Comment: �ݒ肷��R�����g�ł��B ������Ŏw�肵�܂��B������͕����s�ł�
    //            ��肠��܂���B�R�����g�̊e�s�̐擪�� ';' ���t���Ă���
    //            �K�v�͂���܂���B';' �͕K�v�ɉ����Ď����I�ɕt������܂��B
    // �ڍ�
    //   �w�肳�ꂽ�Z�N�V�����ɃR�����g��ݒ肵�܂��B
    //   �Z�N�V�����������ꍇ�͉������܂���B
    //   �R�����g�̊e�s�̐擪�� ';' ���t���Ă���K�v�͂���܂���B
    //            ';' �͕K�v�ɉ����Ď����I�ɕt������܂��B
    //   Section�̑O��̋󔒂��g�����������ʂ��󕶎���̏ꍇ�A
    //   �����̃Z�N�V�������w�肵�����ƂɂȂ�܂��B
    procedure WriteSectionComment(const Section, Comment: string); overload;
    // �Z�N�V������/�L�[���Ŏw�肵���L�[�ɃR�����g����������
    // �p�����[�^
    //   Section: �Z�N�V�������B�O��̋󔒂͖�������܂��B
    //            CaseSensitive �v���p�e�B�� True �̂Ƃ��� Section ��
    //            �����̑召�͋�ʂ���܂��Bfalse�̎��͋�ʂ���܂���B
    //   Ident:   ���O�ł��B�O��̋󔒂͖�������܂��B
    //            CaseSensitive �v���p�e�B�� True �̂Ƃ��� Ident ��
    //            �����̑召�͋�ʂ���܂��Bfalse�̎��͋�ʂ���܂���B
    //   Comment: �ݒ肷��R�����g�ł��B TStrings�̉��ʃN���X�̃C���X�^���X��
    //            ���Ă��܂��B�e�s�̐擪�� ';' ���t���Ă���K�v�͂���܂���B
    //            ';' �͕K�v�ɉ����Ď����I�ɕt������܂��B
    // �ڍ�
    //   �w�肳�ꂽ�Z�N�V�����̎w�肳�ꂽ���O�ɃR�����g��ݒ肵�܂��B
    //   �w�肵�����O�������ꍇ�͉������܂���B
    //   �R�����g�̊e�s�̐擪�� ';' ���t���Ă���K�v�͂���܂���B
    //            ';' �͕K�v�ɉ����Ď����I�ɕt������܂��B
    procedure WriteComment(const Section, Ident: string; Comment: TStrings); overload;
    // �Z�N�V������/�L�[���Ŏw�肵���L�[�ɃR�����g����������
    // �p�����[�^
    //   Section: �Z�N�V�������B�O��̋󔒂͖�������܂��B
    //            CaseSensitive �v���p�e�B�� True �̂Ƃ��� Section ��
    //            �����̑召�͋�ʂ���܂��Bfalse�̎��͋�ʂ���܂���B
    //   Ident:   ���O�ł��B�O��̋󔒂͖�������܂��B
    //            CaseSensitive �v���p�e�B�� True �̂Ƃ��� Ident ��
    //            �����̑召�͋�ʂ���܂��Bfalse�̎��͋�ʂ���܂���B
    //   Comment: �ݒ肷��R�����g�ł��B ������Ŏw�肵�܂��B������͕����s�ł�
    //            ��肠��܂���B�R�����g�̊e�s�̐擪�� ';' ���t���Ă���
    //            �K�v�͂���܂���B';' �͕K�v�ɉ����Ď����I�ɕt������܂��B
    // �ڍ�
    //   �w�肳�ꂽ�Z�N�V�����̎w�肳�ꂽ���O�ɃR�����g��ݒ肵�܂��B
    //   �w�肳�ꂽ���O�������ꍇ�͉������܂���B
    //   �R�����g�̊e�s�̐擪�� ';' ���t���Ă���K�v�͂���܂���B
    //            ';' �͕K�v�ɉ����Ď����I�ɕt������܂��B
    procedure WriteComment(const Section, Ident, Comment: string); overload;
    // �t�@�C�����X�V����B
    // �ڍ�
    //   TNkMemIniFile���̃Z�N�V�����Ɩ��O/�l�y�A��Ini�t�@�C���ɏ������݂܂��B
    //   Ini�t�@�C���̓R���X�g���N�^�Ŏw�肵�����̂ł��B
    //   Ini�t�@�C���͈ȉ��̗l�ɏ������܂�܂��B
    //
    //   1) �Z�N�V�������̃R�����g�̓Z�N�V�����̑O�ɏ������܂�܂��B
    //   2) �Z�N�V������
    //
    //      [�Z�N�V������]
    //
    //      �Ƃ����悤�ɏ������܂�܂��B�Z�N�V�������̑O�ɃC���f���g��
    //      �}������܂���B
    //   3) �e���O/�l�y�A�̑O�ɁA���O/�l�y�A�̃R�����g��������܂��B
    //   4) �e���O/�l�y�A��
    //
    //      ���O=�l
    //
    //      �Ƃ����`���ŏ�����܂��B
    //      ���O�̑O�ɃC���f���g�͑}������܂���B
    //      ���O��=, = �ƒl�̊Ԃɂ͋󔒂͑}������܂���B
    //      �l�� �󔒂𕞖��ꍇ��A���p��(")���܂ޏꍇ�A�l�� ���p����
    //      �͂܂�ď������܂�܂��B�l�����p��(")���܂ޏꍇ�� ("")�ɕϊ������
    //      �������܂�܂�(CSV�Ƃ��Ȃ�)�B���̎d�l�� TMemIniFile �� TIni�t�@�C���Ƃ�
    //      ���ƂȂ�̂Œ��ӂ��Ă��������B
    //
    //      TIniFile�ł͑O��ɋ󔒂��܂ޒl�����p���ň͂�ŏ������݂܂����A
    //      ���p���� ("")�ɕϊ����܂���B
    //      TMemIniFile �͈��p���𖳎����ĕ��ʂ̕�����Ƃ��Ĉ����܂��B
    //      �܂��A�l�̑O��ɋ󔒂��܂܂�Ă���ꍇ�̓g�������Ă��珑�����݂܂��B
    procedure UpdateFile; override;
    // �Z�N�V������/�L�[���Ŏw�肵���L�[�ɒl����������
    // �p�����[�^
    //   Section: �Z�N�V�������B�O��̋󔒂͖�������܂��B
    //            CaseSensitive �v���p�e�B�� True �̂Ƃ��� Section ��
    //            �����̑召�͋�ʂ���܂��Bfalse�̎��͋�ʂ���܂���B
    //   Ident:   ���O�ł��B�O��̋󔒂͖�������܂��B
    //            CaseSensitive �v���p�e�B�� True �̂Ƃ��� Ident ��
    //            �����̑召�͋�ʂ���܂��Bfalse�̎��͋�ʂ���܂���B
    //   Value:   �������ޒl�ł��B
    // �ڍ�
    //   �w�肳�ꂽ�Z�N�V�����̎w�肳�ꂽ�l���X�V���܂��B
    //   �w�肳�ꂽ�Z�N�V������������΍���܂��B�w�肳�ꂽ���O���������
    //   ����܂��B
    //   Section�̑O��̋󔒂��g����������̕����񂪋󕶎���̂Ƃ�
    //   ENkMemIniFileInvalidSection��O���N���܂��B
    //   Ident�̑O��̋󔒂��g����������̕����񂪋󕶎���̏ꍇ�� '=' ��
    //   �܂ޏꍇ�� ENkMemIniFileInvalidName��O���N���܂��B
    //   Value �͂��̂܂܏������܂�܂��B�O��ɋ󔒂������Ă����̂܂܏������܂�܂��B
    //   �A��Value�� CR �� LF ���܂ޏꍇ��ENkMemIniFileInvalidValue��O���N���܂��B
    procedure WriteString(const Section, Ident, Value: String); override;

    // ���O�̑召����ʂ���
    // �ڍ�
    //   �Z�N�V�������A���O�Ō������s���Ƃ��A�啶������������ʂ��邩���w�肵�܂��B
    //   ���̃v���p�e�B�͂��ł��ύX�ł��܂����ATrue���� False �ɕύX����Ƃ�
    //   ���ӂ��K�v�ł��BTrue���� False �ɕύX����ƁA�啶��/������������
    //   �قȂ�Z�N�V�������▼�O�͓����Ƃ݂Ȃ����悤�ɂȂ�܂��B
    //   �����ƂȂ����Z�N�V�����▼�O�́u���Ɓv�̕��̂��̂ŏ㏑������܂��B
    //   �f�t�H���g�� False �ł��B
    property CaseSensitive: Boolean read GetCaseSensitive write SetCaseSensitive;
  end;

  // �Z�N�V������ێ�����I�u�W�F�N�g
  // ���̃N���X�̓A�v���P�[�V�����ł͎g�p���Ȃ��ł��������B
  TNkMemIniSection = class
  private
    // �R�����g
    FComment: TStringList;
    // �L�[�ƒl�̃��X�g
    FKeys: TNkhashedStringList;
    // �L�[�̃R�����g�I�u�W�F�N�g���擾
    function GetCommentObj(Ident: string): TNkComment;
  public
    // �R���X�g���N�^
    constructor Create;
    // �f�X�g���N�^
    destructor Destroy; override;
    // �L�[�ƒl�����ׂăN���A
    procedure Clear;
    // ����̃L�[�ƒl���N���A
    procedure DeleteKey(Ident: string);
    // �Z�N�V�����̓��e�𕶎��񃊃X�g�Ɏ擾
    procedure GetStrings(List: TStrings);
    // �Z�N�V�������̃L�[/�l��ǂ�
    function  ReadString(const Ident, Default: string): string;
    // �Z�N�V�������̃L�[�̃R�����g��ǂ�
    procedure ReadComment(const Ident:string; Comment: TStrings);
    // �Z�N�V�����ɃL�[/�l������
    procedure WriteString(Ident, Value: string);
    // �Z�N�V�����̃L�[�ɃR�����g��������
    procedure WriteComment(Ident: string; Comment: TStrings);
    // �Z�N�V�����̃R�����g
    property Comment: TStringList read FComment;
    // �Z�N�V�������̃L�[�ƒl�̃��X�g
    property Keys: TNkhashedStringList read FKeys;
  end;

implementation

uses
  StrUtils;


{ TNkMemIniFile }

// �S�Z�N�V������j������
procedure TNkMemIniFile.Clear;
begin FSections.Clear; end;

constructor TNkMemIniFile.Create(const FileName: string);
begin
  inherited Create(FileName);
  FSections := TNkHashedStringList.Create;
  FSections.HasObjects := True;

  // �����Z�N�V���������B
  AddSection('');

  LoadValues;
end;

// �Z�N�V�����ƃL�[�����w�肵�ăL�[���폜����
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


// �Z�N�V�������폜����B
procedure TNkMemIniFile.EraseSection(const Section: string);
var
  SectionIndex: Integer;
  s: string;
begin
  s := Trim(Section);
  if s = '' then
    ENkMemIniFileInvalidSection.Create('�����Z�N�V�����͍폜�ł��܂���');
  SectionIndex := FSections.IndexOf(s);
  if SectionIndex >= 0 then
    FSections.Delete(SectionIndex);
end;

function TNkMemIniFile.GetCaseSensitive: Boolean;
begin Result := FSections.CaseSensitive; end;

// Ini�t�@�C���̃e�L�X�g�C���[�W���擾����B
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
    
    // �����Z�N�V�����̃R�����g�̂ݏo��
    IniSection := GetSection('');
    if IniSection <> Nil then
      for j := 0 to IniSection.Comment.Count-1 do
        List.Add(IniSection.Comment[j]);
  finally
    List.EndUpdate;
  end;
end;

// �啶������������ʂ��邩�Z�b�g����
procedure TNkMemIniFile.SetCaseSensitive(Value: Boolean);
var
  List: TStringList;
begin
  if FSections.CaseSensitive <> Value then
  begin
    List := TStringList.Create;
    try
      // ���̓��e���z���o���B
      GetStrings(List);
      // Ini ���N���A���A�啶���������̋�ʂ�ݒ肷��
      Clear;
      FSections.CaseSensitive := Value;
      // Ini���č\�z����B
      SetStrings(List);
    finally
      List.Free;
    end;
  end;
end;

// �Z�N�V�����ƃL�[���w�肵�Ēl����������
procedure TNkMemIniFile.WriteString(const Section, Ident, Value: String);
var
  IniSection: TNkMemIniSection;
  s: string;
begin
  s := Trim(Section);
  if s = '' then
    raise ENkMemIniFileInvalidSection.Create('��̃Z�N�V������');
  if AnsiPos(#13, Value) > 0 then
    raise ENkMemIniFileInvalidValue.Create('�l�� CR ���܂�');
  if AnsiPos(#10, Value) > 0 then
    raise ENkMemIniFileInvalidValue.Create('�l�� LF ���܂�');
  IniSection := GetSection(s);
  if IniSection = Nil then
    IniSection := AddSection(s);
  IniSection.WriteString(Ident, Value);
end;

// �Z�N�V�����𑝂₷
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

// �Z�N�V�����ƃL�[���w�肵�Ēl��ǂ�
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

// �Z�N�V�����̑S�ẴL�[���� Strings �ɓǂݍ���
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

// �S�Z�N�V�������� Strings �ɓǂݍ���
procedure TNkMemIniFile.ReadSections(SectionNames: TStrings);
var
  i: Integer;
begin
  SectionNames.BeginUpdate;
  try
    SectionNames.Clear;

    for i := 0 to FSections.Count-1 do
      if FSections[i] <> '' then       // �����Z�N�V�����͑ΏۊO
        SectionNames.Add(FSections[i]);
  finally
    SectionNames.EndUpdate;
  end;
end;

// �Z�N�V�����̓��e�� Strings�ɓǂݍ���
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

// �R�����g�̃R�s�[
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

// �����񃊃X�g���� TNkMemIniFile������������
// ���ӁI�@�����Z�N�V�������쐬�ς݂ł��邱�ƁB
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
          // �Z�N�V���������o�I

          // �Z�N�V�������𓾂�B
          s := Trim(Copy(s, 2, Length(s)-2));

          if s = '' then // �����Z�N�V�����͓ǂݔ�΂�
            continue;

          // �����Z�N�V�����Ȃ�Z�N�V�������}�[�W�A
          // �����łȂ���ΐV�K�Z�N�V���������
          if FSections.StrExists(S) then
            IniSection := GetSection(S)
          else
            IniSection := AddSection(Trim(s));

          // �R�����g�͌㏟���Ƃ���B
          if Comment.Count > 0 then
            CopyComment(Comment, IniSection.Comment);
          Comment.Clear;
        end
        else
        begin

          // �Z�N�V�����ł͂Ȃ�
          if IniSection <> nil then
          begin
            // �L�[/�l�y�A�����
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

            // �����̖��O�͖���
            if Ident = '' then Continue;

            // �Z�N�V�����ɓo�^(�����̃L�[���L��Ό㏟��)
            IniSection.WriteString(Ident, Value);

            // �R�����g���o�^(�㏟��)
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

// �t�@�C������ǂݍ���
procedure TNkMemIniFile.LoadValues;
var
  List: TStringList;
begin
  if (FileName <> '') and FileExists(FileName) then
  begin
    List := TStringList.Create;
    try
      // �t�@�C����ǂݍ���
      List.LoadFromFile(FileName);
      SetStrings(List);
    finally
      List.Free;
    end;
  end;
end;

// �t�@�C���ɏ�������
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

// �Z�N�V�����̃R�����g��ǂ�
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

// �Z�N�V�����̃R�����g��ǂ�
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

// �R�����g��ǂ�
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

// �R�����g��ǂ�
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

// �R�����g������
procedure TNkMemIniFile.WriteComment(const Section, Ident: string;
                                     Comment: TStrings);
var
  IniSection: TNkMemIniSection;
begin
  IniSection := GetSection(Trim(Section));
  if IniSection <> Nil then
    IniSection.WriteComment(Ident, Comment);
end;

// �R�����g������
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

// �Z�N�V�����̃R�����g������
procedure TNkMemIniFile.WriteSectionComment(const Section: string;
  Comment: TStrings);
var
  IniSection: TNkMemIniSection;
begin
  IniSection := GetSection(Trim(Section));
  if IniSection <> Nil then
    CopyComment(Comment, IniSection.Comment);
end;

// �Z�N�V�����̃R�����g������
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

// �Z�N�V�����̓��e�𕶎���ɂ��ă��X�g�ɉ�����
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

// �Z�N�V����������Z�N�V�����𓾂�B
function TNkMemIniFile.GetSection(const Section: string): TNkMemIniSection;
begin
  Result := FSections.ObjectsByString[Section] as TNkMemIniSection;
end;

// �Z�N�V�������N���A����B
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

// �Z�N�V��������L�[/�l���폜
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

// �R�����g�I�u�W�F�N�g�𓾂�B
function TNkMemIniSection.GetCommentObj(Ident: string): TNkComment;
begin
  Result := Keys.ObjectsByName[Ident] as TNkComment;
end;

// �L�[/�l��ǂ�
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

// �L�[/�l����������
procedure TNkMemIniSection.WriteString(Ident, Value: string);
var
  s: string;
begin
  s := Trim(Ident);
  if s = '' then
    raise ENkMemIniFileInvalidName.Create('��̖��O');
  if AnsiPos('=', s) > 0 then
    raise ENkMemIniFileInvalidName.Create('���O�� "=" ���܂�ł���');
  if s[1] = ';' then
    raise ENkMemIniFileInvalidName.Create('���O�̐擪�� ";"');
  Keys.ValuesByName[s] := Value;
end;

// �L�[�ɃR�����g��t����B
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

// �L�[�̃R�����g���擾����B
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

