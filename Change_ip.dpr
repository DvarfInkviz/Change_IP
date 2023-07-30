program Change_ip;

uses
  Vcl.Forms,
  main in 'main.pas' {Form1},
  USock in 'USock.pas',
  UPing in 'UPing.pas',
  thread_cmd in 'thread_cmd.pas',
  func_proc in 'func_proc.pas',
  thread_upgrade in 'thread_upgrade.pas';

{$R *.res}

begin
  Application.Initialize;
  Application.MainFormOnTaskbar := True;
  Application.CreateForm(TForm1, Form1);
  Application.Run;
end.
