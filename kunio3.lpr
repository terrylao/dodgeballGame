program kunio3;

{$MODE Delphi}

uses
  //MemCheck,
  Forms, Interfaces,
  Main in 'Main.pas' {Form1},
  VarUnit in 'VarUnit.pas',
  DBUnit in 'DBUnit.pas',
  CPUUnit in 'CPUUnit.pas',
  DBClass in 'DBClass.pas';

{$R *.res}

begin
  Application.Initialize;
  Application.Title := 'DtDodgeball';
  Application.CreateForm(TForm1, Form1);
  Application.Run;
end.
