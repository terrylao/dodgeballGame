���j�b�g NkMemIniFile �̃��t�@�����X

���j�b�g�̐���
  ////////
   NkMemIniFile ���j�b�g
  
   TNkmemIniFile: �g���� TMemIniFile
  �@ Coded By T. Nakamura
     Ver 0.1 2006/07/02
     Ver 0.2 2006/07/02
     Ver 0.3 2006/07/16
  
    TNkMemIniFile �� TMemIniFile �̊g���łł��B
    ���̓���������Ă��܂��B
    1) ���O�ƒl�ɓ��{�ꂪ�g�p�ł��܂��B
    2) ���O�ɃR�����g��t���ł��܂��B
    3) �Z�N�V�����ɃR�����g��t���ł��܂��B
    4) ���O/�l�y�A�̎Q�Ƃ������ł��B
       �Z�N�V�����Ɩ��O���n�b�V���ō����Ɍ������܂��B
       ���x�� TmemIniFile �ƂقǓ����ł��� TIniFile���͂邩�ɍ����ł��B
    5) ���O/�l�y�A�̍X�V�A�ǉ��A�폜�� TMemIniFile�ɔ�וS�{�����ł��B
    6) �l�Ɉ��p�����T�|�[�g���Ă��܂��B�l���󔒂��܂ޏꍇ��A
       ���p�����܂܂��ꍇ�A�l�� ���p���ň͂܂�ď������܂�܂��B
       �l�̒��̈��p�����Q�̈��p���ɒu�������܂�(CSV�Ɠ���)�B
  
    �g�p�̏ڍׂ̓��\�b�h�̐��������Ă��������B
  
    TMemIniFile �Ƃ̐��\��r
    ������� Windows XP SP2, Celeron 2.4GHz, ������ 512MHz, Delphi 7
  
     TMemIniFile
      Load(10���L�[)       Time =     0.36 Sec
      Read(10���L�[)       Time =     0.58 Sec
      Update(10���L�[)     Time =   370.20 Sec
      Delete(10���L�[)     Time =   145.59 Sec
      Add(10���L�[)        Time =   156.84 Sec
      UpdateFile(10���L�[) Time =     0.16 Sec
  
     TNkMemIniFile
      Load(10���L�[)       Time =     1.30 Sec
      Read(10���L�[)       Time =     0.91 Sec
      Update(10���L�[)     Time =     0.84 Sec
      Delete(10���L�[)     Time =     1.22 Sec
      Add(10���L�[)        Time =     1.38 Sec
      UpdateFile(10���L�[) Time =     0.30 Sec
  
    �{�\�t�g�E�F�A�̎g�p�A�z�z����ςɈ�؂̐�����
    �݂��܂���B���p���p���o���܂����A���p�ɍۂ��Ē��쌠
    �\�����s�v�ł��B�����R�ɂ��g�����������B
    �Ȃ��A�����̎g�p�ɂ���Đ������s��̐ӔC�͈�ؕ�
    ���܂���B�\�߂��������������B


1. ���j�b�g NkMemIniFile �� �N���X

1.1 ENkMemIniFileInvalidName �N���X

�錾
  ENkMemIniFileInvalidName = class(Exception)

����
  ���O�ُ̈��\����O�ł��B


1.2 ENkMemIniFileInvalidSection �N���X

�錾
  ENkMemIniFileInvalidSection = class(Exception)

����
  �Z�N�V�������ُ̈��\����O�ł��B


1.3 ENkMemIniFileInvalidValue �N���X

�錾
  ENkMemIniFileInvalidValue = class(Exception)

����
  �l�ُ̈��\����O�ł��B


1.4 TNkMemIniFile �N���X

�錾
  TNkMemIniFile = class(TCustomIniFile)

����
   Ini�t�@�C������p�N���X
   TMemIniFile �̑�փN���X�ł��B
  
   TMemIniFile �͈ȉ��̗l�� Ini�t�@�C�����p�[�X���܂��B
  
   1) �󔒍s(�g�����������ʕ����̖����s)�͖������܂��B
   2) �s���g�����������ʐ擪�̕����� ; �̏ꍇ�A�R�����g�Ƃ݂Ȃ��܂��B
      �R�����g�̓g�����O�̂��̂���荞�܂�܂��B
   3) �s���g�����������ʁA�擪��'['�ōŌ�̕�����']'�̏ꍇ�Z�N�V�����̎n�܂��
      �݂Ȃ��܂��B'['��']'���������������Z�N�V�������Ƃ݂Ȃ��܂��B
      �A���Z�N�V���������󕶎���̏ꍇ�͖������܂��B
   4) �Z�N�V�����̎n�܂�ł͂Ȃ��A�s��'=' ���܂ލs�͖��O/�l�y�A�Ƃ��ăp�[�X���܂��B
      ���O�͖��O����('='���O�̕���)�̑O��̋󔒂̓g����������o����܂��B
      �l�͒l�̕���('='����̕���)�̑O��̋󔒂̓g����������o����܂��B
      ���o���ꂽ�l�� ���p��(")�ň͂܂�Ă���ꍇ�́A���p������菜����A
      �Q�d�̈��p��("")�� ���p��(")�ɕϊ�����܂��B
      ���O���󕶎���ɂȂ����ꍇ�͖��O/�l�y�A�͖�������܂��B
   5) �Z�N�V�����̎n�܂�ł͂Ȃ��A�s��'=' ���܂܂Ȃ��s�́A�s�S�̂𖼑O�Ƃ݂Ȃ��܂��B
      �l�͋󕶎���ɂȂ�܂��B
   6) �Z�N�V�����̑O�̈�A�̃R�����g�̓Z�N�V�����̃R�����g�ɂȂ�܂��B
      �Z�N�V�����̃R�����g�� ReadSectionComment���\�b�h�Ŏ擾�ł��܂��B
   7) ���O/�l�y�A�̑O�̈�A�̃R�����g�͖��O/�l�y�A�̃R�����g�ɂȂ�܂��B
      ���O�̃R�����g�� ReadComment���\�b�h�Ŏ擾�ł��܂��B
   8) �Ō�̃Z�N�V�����̍Ō�̖��O/�l�y�A����̈�A�̃R�����g��
      �u�����v�̃Z�N�V�����̃R�����g�ɂȂ�܂��B���̃R�����g��
      ReadSectionComment('')
      �Ŏ擾�ł��܂��B
   9) �u�����v�̃Z�N�V�����͏�ɍ쐬����܂��B
  
   ����) �󔒂Ƃ� �R�[�h$20 �ȉ��̑S�Ă̔��p�����̂��Ƃł��B


1.4.1. �N���X TNkMemIniFile �� Public ��

1.4.1.1. TNkMemIniFile �N���X�� Public ���� �v���p�e�B

1.4.1.1.1 CaseSensitive �v���p�e�B

�錾
  property CaseSensitive: Boolean read GetCaseSensitive write SetCaseSensitive;

����
  ���O�̑召����ʂ���
  �ڍ�
    �Z�N�V�������A���O�Ō������s���Ƃ��A�啶������������ʂ��邩���w�肵�܂��B
    ���̃v���p�e�B�͂��ł��ύX�ł��܂����ATrue���� False �ɕύX����Ƃ�
    ���ӂ��K�v�ł��BTrue���� False �ɕύX����ƁA�啶��/������������
    �قȂ�Z�N�V�������▼�O�͓����Ƃ݂Ȃ����悤�ɂȂ�܂��B
    �����ƂȂ����Z�N�V�����▼�O�́u���Ɓv�̕��̂��̂ŏ㏑������܂��B
    �f�t�H���g�� False �ł��B


1.4.1.2. TNkMemIniFile �N���X�� Public ���� ���\�b�h

1.4.1.2.1 Clear ���\�b�h

�錾
  procedure Clear;

����
  �N���A
  �ڍ�
    TNkMemIniFile�ɕێ�����Ă���S�ẴZ�N�V�����Ɩ��O/�l�y�A���폜���܂��B
    �Z�N�V�����̃R�����g�▼�O�̃R�����g���S�č폜����܂��B


1.4.1.2.2 Create ���\�b�h

�錾
  constructor Create(const FileName: string);

����
  �R���X�g���N�^
  �p�����[�^
    FileName: Ini�t�@�C���̃t�@�C�����ł��B
  �ڍ�
    Ini�t�@�C����ǂݍ��� TNkMemIniFile�̃C���X�^���X���쐬���܂��B


1.4.1.2.3 DeleteKey ���\�b�h

�錾
  procedure DeleteKey(const Section, Ident: String); override;

����
  ���O�̍폜
  �p�����[�^
    Section: �Z�N�V�������B�O��̋󔒂͖�������܂��B
             CaseSensitive �v���p�e�B�� True �̂Ƃ��� Section ��
             �����̑召�͋�ʂ���܂��Bfalse�̎��͋�ʂ���܂���B
    Ident:   ���O�ł��B�O��̋󔒂͖�������܂��B
             CaseSensitive �v���p�e�B�� True �̂Ƃ��� Ident ��
             �����̑召�͋�ʂ���܂��Bfalse�̎��͋�ʂ���܂���B
  �ڍ�
    �Z�N�V�����Ɩ��O�Ŏw�肳�ꂽ���O���폜���܂��B
    ���O�Ɋ֘A�t����ꂽ�R�����g���폜����܂��B
    ���݂��Ȃ����O���w�肳�ꂽ�Ƃ��͉������܂���B
    �Z�N�V�����A���O���s���ȏꍇ���������܂���B


1.4.1.2.4 Destroy ���\�b�h

�錾
  destructor Destroy; override;

����
  �f�X�g���N�^
  �ڍ�
    TNkMemIniFile ��j�����܂��B


1.4.1.2.5 EraseSection ���\�b�h

�錾
  procedure EraseSection(const Section: string); override;

����
  �Z�N�V�������폜
  �p�����[�^
    Section: �Z�N�V�������B�O��̋󔒂͖�������܂��B
             CaseSensitive �v���p�e�B�� True �̂Ƃ��� Section ��
             �����̑召�͋�ʂ���܂��Bfalse�̎��͋�ʂ���܂���B
  �ڍ�
    �w�肳�ꂽ�Z�N�V�������폜���܂��B�Z�N�V�����Ɋ֘A�t����ꂽ
    �R�����g���폜����܂��B
    �����Z�N�V�������폜���悤�Ƃ���� ENkMemIniFileInvalidSection
    ��O���N���܂��B


1.4.1.2.6 GetStrings ���\�b�h

�錾
  procedure GetStrings(List: TStrings);

����
  �t�@�C���C���[�W�̎擾
  �p�����[�^
    List: TStrings�̉��ʃN���X�̃C���X�^���X
  �ڍ�
    TNkMemIniFile��Ini�t�@�C���֏����o���e�L�X�g�C���[�W���擾���܂��B
    GetStrings �� List �Ƀe�L�X�g�C���[�W���u�����܂��v�B������O��
    List���N���A���Ȃ��̂Œ��ӂ��Ă��������B
    List �͍쐬�ς݂� TStrings�̉��ʃN���X�̃C���X�^���X���w�肵�Ă��������B
    �쐬�����e�L�X�g�C���[�W�Ɋւ��Ă� UpdateFile���\�b�h�̏ڍׂ�
    �Q�Ƃ��Ă��������B


1.4.1.2.7 ReadComment ���\�b�h

�錾
  function  ReadComment(const Section, Ident: string): string; overload;

����
  �Z�N�V������/�L�[���Ŏw�肵���L�[�̃R�����g��ǂ�
  �p�����[�^
    Section: �Z�N�V�������B�O��̋󔒂͖�������܂��B
             CaseSensitive �v���p�e�B�� True �̂Ƃ��� Section ��
             �����̑召�͋�ʂ���܂��Bfalse�̎��͋�ʂ���܂���B
    Ident:   ���O�ł��B�O��̋󔒂͖�������܂��B
             CaseSensitive �v���p�e�B�� True �̂Ƃ��� Ident ��
             �����̑召�͋�ʂ���܂��Bfalse�̎��͋�ʂ���܂���B
  �߂�l
    �R�����g��������Ƃ��ĕԂ���܂��B
  �ڍ�
    �w�肳�ꂽ���O�̃R�����g��Ԃ��܂��B
    �R�����g�������ꍇ��A���O�������ꍇ�� ''(�󕶎���)���Ԃ�܂��B
    �R�����g��';'�t���ł��B�s�v�ȏꍇ�̓A�v���P�[�V�������Ŏ�菜���Ă��������B
    �R�����g�������s�ɂȂ鎞�͖߂�l�� #13#10���܂݂܂��B
    �R�����g�̍Ō�� #13#10���t�����Ƃ͂���܂���B


1.4.1.2.8 ReadComment ���\�b�h

�錾
  procedure ReadComment(const Section, Ident: string; Comment: TStrings); overload;

����
  �Z�N�V������/�L�[���Ŏw�肵���L�[�̃R�����g��ǂ�
  �p�����[�^
    Section: �Z�N�V�������B�O��̋󔒂͖�������܂��B
             CaseSensitive �v���p�e�B�� True �̂Ƃ��� Section ��
             �����̑召�͋�ʂ���܂��Bfalse�̎��͋�ʂ���܂���B
    Ident:   ���O�ł��B�O��̋󔒂͖�������܂��B
             CaseSensitive �v���p�e�B�� True �̂Ƃ��� Ident ��
             �����̑召�͋�ʂ���܂��Bfalse�̎��͋�ʂ���܂���B
    Comment: �R�����g������ TStrings�̉��ʃN���X�̃C���X�^���X
  �ڍ�
    �w�肳�ꂽ�Z�N�V�����̎w�肳�ꂽ���O�̃R�����g�� Comment �ɕԂ��܂��B
    Comment�̓R�����g������O�ɃN���A����܂��B
    �R�����g�������ꍇ��A���O�������ꍇ�� 0 �s�̃R�����g���Ԃ�܂��B
    �R�����g��';'�t���ł��B�s�v�ȏꍇ�̓A�v���P�[�V�������Ŏ�菜���Ă��������B


1.4.1.2.9 ReadSection ���\�b�h

�錾
  procedure ReadSection(const Section: string; KeyNames: TStrings); override;

����
  �Z�N�V�������̃L�[�̈ꗗ�̎擾�B
  �p�����[�^
    Section:  �Z�N�V�������B�O��̋󔒂͖�������܂��B
              CaseSensitive �v���p�e�B�� True �̂Ƃ��� Section ��
              �����̑召�͋�ʂ���܂��Bfalse�̎��͋�ʂ���܂���B
    KeyNames: ���O�̃��X�g������ TStrings�̉��ʃN���X�̃C���X�^���X
  �ڍ�
    �w�肳�ꂽ�Z�N�V�������̖��O�̈ꗗ��Ԃ��܂��B���O�� KeyNames�̂P�s��
    �P������܂��B
    KeyNames�͖��O�̃��X�g������O�ɃN���A����܂��B
    KeyNames �͍쐬�ς݂� TStrings�̉��ʃN���X�̃C���X�^���X���w�肵�Ă��������B
    �����Z�N�V�����̖��O�̈ꗗ�͏�ɋ�ł��B


1.4.1.2.10 ReadSectionComment ���\�b�h

�錾
  function  ReadSectionComment(const Section: string): string; overload;

����
  �Z�N�V�����̃R�����g��ǂ�
  �p�����[�^
    Section: �Z�N�V�������B�O��̋󔒂͖�������܂��B
             CaseSensitive �v���p�e�B�� True �̂Ƃ��� Section ��
             �����̑召�͋�ʂ���܂��Bfalse�̎��͋�ʂ���܂���B
             �󕶎�����w�肷��Ɩ����̃Z�N�V�����̃R�����g���ǂ߂܂��B
  �߂�l
    �R�����g��������Ƃ��ĕԂ���܂��B
  �ڍ�
    �w�肳�ꂽ�Z�N�V�����̃R�����g��Ԃ��܂��B
    �R�����g�������ꍇ��A�Z�N�V�����������ꍇ�� ''(�󕶎���)���Ԃ�܂��B
    �R�����g��';'�t���ł��B�s�v�ȏꍇ�̓A�v���P�[�V�������Ŏ�菜���Ă��������B
    �R�����g�������s�ɂȂ鎞�͖߂�l�� #13#10���܂݂܂��B
    �R�����g�̍Ō�� #13#10���t�����Ƃ͂���܂���B
    Section�̑O��̋󔒂��g�����������ʂ��󕶎���̏ꍇ�A
    �����̃Z�N�V�������w�肵�����ƂɂȂ�܂��B


1.4.1.2.11 ReadSectionComment ���\�b�h

�錾
  procedure ReadSectionComment(const Section: string; Comment: TStrings); overload;

����
  �Z�N�V�����̃R�����g��ǂ�
  �p�����[�^
    Section: �Z�N�V�������B�O��̋󔒂͖�������܂��B
             CaseSensitive �v���p�e�B�� True �̂Ƃ��� Section ��
             �����̑召�͋�ʂ���܂��Bfalse�̎��͋�ʂ���܂���B
             �󕶎�����w�肷��Ɩ����̃Z�N�V�����̃R�����g���ǂ߂܂��B
    Comment: �R�����g������ TStrings�̉��ʃN���X�̃C���X�^���X
  �ڍ�
    �w�肳�ꂽ�Z�N�V�����̃R�����g�� Comment �ɕԂ��܂��B
    Comment�̓R�����g������O�ɃN���A����܂��B
    �R�����g�������ꍇ��A�Z�N�V�����������ꍇ�� 0 �s�̃R�����g���Ԃ�܂��B
    �R�����g��';'�t���ł��B�s�v�ȏꍇ�̓A�v���P�[�V�������Ŏ�菜���Ă��������B
    Section�̑O��̋󔒂��g�����������ʂ��󕶎���̏ꍇ�A
    �����̃Z�N�V�������w�肵�����ƂɂȂ�܂��B


1.4.1.2.12 ReadSections ���\�b�h

�錾
  procedure ReadSections(SectionNames: TStrings); override;

����
  �Z�N�V�������̈ꗗ���擾
  �p�����[�^
    SectioNames: �Z�N�V�������̃��X�g������ TStrings�̉��ʃN���X�̃C���X�^���X
  �ڍ�
    �Z�N�V�������̈ꗗ��Ԃ��܂��B�Z�N�V�������� SectionNames�̂P�s��
    �P������܂��B
    SectionNames�͖��O�̃��X�g������O�ɃN���A����܂��B
    SectionNames �͍쐬�ς݂� TStrings�̉��ʃN���X�̃C���X�^���X���w�肵�Ă��������B
    �Z�N�V�������̈ꗗ�ɂ͖����Z�N�V�����͊܂܂�܂���B


1.4.1.2.13 ReadSectionValues ���\�b�h

�錾
  procedure ReadSectionValues(const Section: string; KeyValues: TStrings); override;

����
  �Z�N�V�������� ���O=�l�@�̃��X�g���擾
  �p�����[�^
    Section:   �Z�N�V�������B�O��̋󔒂͖�������܂��B
               CaseSensitive �v���p�e�B�� True �̂Ƃ��� Section ��
               �����̑召�͋�ʂ���܂��Bfalse�̎��͋�ʂ���܂���B
    KeyValues: �L�[/�l�y�A�̃��X�g������ TStrings�̉��ʃN���X�̃C���X�^���X
  �ڍ�
    �w�肳�ꂽ�Z�N�V�����̖��O/�l�y�A�̈ꗗ���擾���܂��B
    ���O/�l�y�A�� KeyValues�̂P�s�ɂP������܂��B
    ���O/�l�y�A��Ini�t�@�C����̃e�L�X�g�\���Ɠ����ɂȂ�܂��B
    �l�� �󔒂��܂ޏꍇ����p�����܂ޏꍇ�́A�l�͈��p���ň͂܂�܂��B
    ���p���͂Q�d���p���ɕϊ�����܂�(CSV�Ɠ���)�B
    KeyVales�͖��O�̃��X�g������O�ɃN���A����܂��B
    KeyVales �͍쐬�ς݂� TStrings�̉��ʃN���X�̃C���X�^���X���w�肵�Ă��������B
    �����Z�N�V�����̖��O/�l�y�A�̈ꗗ�͏�ɋ�ł��B


1.4.1.2.14 ReadString ���\�b�h

�錾
  function ReadString(const Section, Ident, Default: string): string; override;

����
  �l�̓ǂݍ���
  �p�����[�^
    Section: �Z�N�V�������B�O��̋󔒂͖�������܂��B
             CaseSensitive �v���p�e�B�� True �̂Ƃ��� Section ��
             �����̑召�͋�ʂ���܂��Bfalse�̎��͋�ʂ���܂���B
    Ident:   ���O�ł��B�O��̋󔒂͖�������܂��B
             CaseSensitive �v���p�e�B�� True �̂Ƃ��� Ident ��
             �����̑召�͋�ʂ���܂��Bfalse�̎��͋�ʂ���܂���B
    Default: �Z�N�V�����ɖ��O�����݂��Ȃ������Ƃ� ReadString ���Ԃ��l�ł��B
  �߂�l
     �ǂݎ�����l��������Ƃ��ĕԂ���܂��B
  �ڍ�
    �w�肳�ꂽ�Z�N�V�����̎w�肳�ꂽ���O�̒l��Ԃ��܂��B
    �l�����݂��Ȃ������ꍇ�� Default ��Ԃ��܂��B


1.4.1.2.15 UpdateFile ���\�b�h

�錾
  procedure UpdateFile; override;

����
   �t�@�C�����X�V����B
   �ڍ�
     TNkMemIniFile���̃Z�N�V�����Ɩ��O/�l�y�A��Ini�t�@�C���ɏ������݂܂��B
     Ini�t�@�C���̓R���X�g���N�^�Ŏw�肵�����̂ł��B
     Ini�t�@�C���͈ȉ��̗l�ɏ������܂�܂��B
  
     1) �Z�N�V�������̃R�����g�̓Z�N�V�����̑O�ɏ������܂�܂��B
     2) �Z�N�V������
  
        [�Z�N�V������]
  
        �Ƃ����悤�ɏ������܂�܂��B�Z�N�V�������̑O�ɃC���f���g��
        �}������܂���B
     3) �e���O/�l�y�A�̑O�ɁA���O/�l�y�A�̃R�����g��������܂��B
     4) �e���O/�l�y�A��
  
        ���O=�l
  
        �Ƃ����`���ŏ�����܂��B
        ���O�̑O�ɃC���f���g�͑}������܂���B
        ���O��=, = �ƒl�̊Ԃɂ͋󔒂͑}������܂���B
        �l�� �󔒂𕞖��ꍇ��A���p��(")���܂ޏꍇ�A�l�� ���p����
        �͂܂�ď������܂�܂��B�l�����p��(")���܂ޏꍇ�� ("")�ɕϊ������
        �������܂�܂�(CSV�Ƃ��Ȃ�)�B���̎d�l�� TMemIniFile �� TIni�t�@�C���Ƃ�
        ���ƂȂ�̂Œ��ӂ��Ă��������B
  
        TIniFile�ł͑O��ɋ󔒂��܂ޒl�����p���ň͂�ŏ������݂܂����A
        ���p���� ("")�ɕϊ����܂���B
        TMemIniFile �͈��p���𖳎����ĕ��ʂ̕�����Ƃ��Ĉ����܂��B
        �܂��A�l�̑O��ɋ󔒂��܂܂�Ă���ꍇ�̓g�������Ă��珑�����݂܂��B


1.4.1.2.16 WriteComment ���\�b�h

�錾
  procedure WriteComment(const Section, Ident, Comment: string); overload;

����
  �Z�N�V������/�L�[���Ŏw�肵���L�[�ɃR�����g����������
  �p�����[�^
    Section: �Z�N�V�������B�O��̋󔒂͖�������܂��B
             CaseSensitive �v���p�e�B�� True �̂Ƃ��� Section ��
             �����̑召�͋�ʂ���܂��Bfalse�̎��͋�ʂ���܂���B
    Ident:   ���O�ł��B�O��̋󔒂͖�������܂��B
             CaseSensitive �v���p�e�B�� True �̂Ƃ��� Ident ��
             �����̑召�͋�ʂ���܂��Bfalse�̎��͋�ʂ���܂���B
    Comment: �ݒ肷��R�����g�ł��B ������Ŏw�肵�܂��B������͕����s�ł�
             ��肠��܂���B�R�����g�̊e�s�̐擪�� ';' ���t���Ă���
             �K�v�͂���܂���B';' �͕K�v�ɉ����Ď����I�ɕt������܂��B
  �ڍ�
    �w�肳�ꂽ�Z�N�V�����̎w�肳�ꂽ���O�ɃR�����g��ݒ肵�܂��B
    �w�肳�ꂽ���O�������ꍇ�͉������܂���B
    �R�����g�̊e�s�̐擪�� ';' ���t���Ă���K�v�͂���܂���B
             ';' �͕K�v�ɉ����Ď����I�ɕt������܂��B


1.4.1.2.17 WriteComment ���\�b�h

�錾
  procedure WriteComment(const Section, Ident: string; Comment: TStrings); overload;

����
  �Z�N�V������/�L�[���Ŏw�肵���L�[�ɃR�����g����������
  �p�����[�^
    Section: �Z�N�V�������B�O��̋󔒂͖�������܂��B
             CaseSensitive �v���p�e�B�� True �̂Ƃ��� Section ��
             �����̑召�͋�ʂ���܂��Bfalse�̎��͋�ʂ���܂���B
    Ident:   ���O�ł��B�O��̋󔒂͖�������܂��B
             CaseSensitive �v���p�e�B�� True �̂Ƃ��� Ident ��
             �����̑召�͋�ʂ���܂��Bfalse�̎��͋�ʂ���܂���B
    Comment: �ݒ肷��R�����g�ł��B TStrings�̉��ʃN���X�̃C���X�^���X��
             ���Ă��܂��B�e�s�̐擪�� ';' ���t���Ă���K�v�͂���܂���B
             ';' �͕K�v�ɉ����Ď����I�ɕt������܂��B
  �ڍ�
    �w�肳�ꂽ�Z�N�V�����̎w�肳�ꂽ���O�ɃR�����g��ݒ肵�܂��B
    �w�肵�����O�������ꍇ�͉������܂���B
    �R�����g�̊e�s�̐擪�� ';' ���t���Ă���K�v�͂���܂���B
             ';' �͕K�v�ɉ����Ď����I�ɕt������܂��B


1.4.1.2.18 WriteSectionComment ���\�b�h

�錾
  procedure WriteSectionComment(const Section: string; Comment: TStrings); overload;

����
  �Z�N�V�����ɃR�����g����������
  �p�����[�^
    Section: �Z�N�V�������B�O��̋󔒂͖�������܂��B
             CaseSensitive �v���p�e�B�� True �̂Ƃ��� Section ��
             �����̑召�͋�ʂ���܂��Bfalse�̎��͋�ʂ���܂���B
             �󕶎�����w�肷��Ɩ����̃Z�N�V�����ɃR�����g��ݒ�ł��܂��B
    Comment: �ݒ肷��R�����g�ł��B TStrings�̉��ʃN���X�̃C���X�^���X��
             ���Ă��܂��B�e�s�̐擪�� ';' ���t���Ă���K�v�͂���܂���B
             ';' �͕K�v�ɉ����Ď����I�ɕt������܂��B
  �ڍ�
    �w�肳�ꂽ�Z�N�V�����ɃR�����g��ݒ肵�܂��B
    �Z�N�V�����������ꍇ�͉������܂���B
    �R�����g�̊e�s�̐擪�� ';' ���t���Ă���K�v�͂���܂���B
             ';' �͕K�v�ɉ����Ď����I�ɕt������܂��B
    Section�̑O��̋󔒂��g�����������ʂ��󕶎���̏ꍇ�A
    �����̃Z�N�V�������w�肵�����ƂɂȂ�܂��B


1.4.1.2.19 WriteSectionComment ���\�b�h

�錾
  procedure WriteSectionComment(const Section, Comment: string); overload;

����
  �Z�N�V�����ɃR�����g����������
  �p�����[�^
    Section: �Z�N�V�������B�O��̋󔒂͖�������܂��B
             CaseSensitive �v���p�e�B�� True �̂Ƃ��� Section ��
             �����̑召�͋�ʂ���܂��Bfalse�̎��͋�ʂ���܂���B
    Comment: �ݒ肷��R�����g�ł��B ������Ŏw�肵�܂��B������͕����s�ł�
             ��肠��܂���B�R�����g�̊e�s�̐擪�� ';' ���t���Ă���
             �K�v�͂���܂���B';' �͕K�v�ɉ����Ď����I�ɕt������܂��B
  �ڍ�
    �w�肳�ꂽ�Z�N�V�����ɃR�����g��ݒ肵�܂��B
    �Z�N�V�����������ꍇ�͉������܂���B
    �R�����g�̊e�s�̐擪�� ';' ���t���Ă���K�v�͂���܂���B
             ';' �͕K�v�ɉ����Ď����I�ɕt������܂��B
    Section�̑O��̋󔒂��g�����������ʂ��󕶎���̏ꍇ�A
    �����̃Z�N�V�������w�肵�����ƂɂȂ�܂��B


1.4.1.2.20 WriteString ���\�b�h

�錾
  procedure WriteString(const Section, Ident, Value: String); override;

����
  �Z�N�V������/�L�[���Ŏw�肵���L�[�ɒl����������
  �p�����[�^
    Section: �Z�N�V�������B�O��̋󔒂͖�������܂��B
             CaseSensitive �v���p�e�B�� True �̂Ƃ��� Section ��
             �����̑召�͋�ʂ���܂��Bfalse�̎��͋�ʂ���܂���B
    Ident:   ���O�ł��B�O��̋󔒂͖�������܂��B
             CaseSensitive �v���p�e�B�� True �̂Ƃ��� Ident ��
             �����̑召�͋�ʂ���܂��Bfalse�̎��͋�ʂ���܂���B
    Value:   �������ޒl�ł��B
  �ڍ�
    �w�肳�ꂽ�Z�N�V�����̎w�肳�ꂽ�l���X�V���܂��B
    �w�肳�ꂽ�Z�N�V������������΍���܂��B�w�肳�ꂽ���O���������
    ����܂��B
    Section�̑O��̋󔒂��g����������̕����񂪋󕶎���̂Ƃ�
    ENkMemIniFileInvalidSection��O���N���܂��B
    Ident�̑O��̋󔒂��g����������̕����񂪋󕶎���̏ꍇ�� '=' ��
    �܂ޏꍇ�� ENkMemIniFileInvalidName��O���N���܂��B
    Value �͂��̂܂܏������܂�܂��B�O��ɋ󔒂������Ă����̂܂܏������܂�܂��B
    �A��Value�� CR �� LF ���܂ޏꍇ��ENkMemIniFileInvalidValue��O���N���܂��B


