unit thread_upgrade;

interface

uses
  System.Classes;


type
  Tthread_upgrade = class(TThread)
  private
    { Private declarations }
  protected
    procedure Execute; override;
  end;

implementation

  uses
  Windows, Messages, SysUtils, Variants, Graphics, Controls, Forms,
  Dialogs, StdCtrls, ExtDlgs, ShellApi, ShlObj, ComCtrls, Mask, WinSock,
  ExtCtrls, jpeg, System.UITypes, main, uping, func_proc;




{ thread_cmd }

procedure Tthread_upgrade.Execute;
var cmd, kluch: string;
    SEInfo: TShellExecuteInfo;
    ExitCode: DWORD;
    ExecuteFile: string;
begin
  if form1.CheckBox1.Checked then
    kluch:= '/k '
  else
    kluch:= '/c ';
  form1.btn_change.Enabled:= False;
  form1.logs.Lines.Add('1. �������� ����������� � ��� �� IP=' + normalip(form1.ip_current.Text) + '...');
  if Ping(ansistring(normalip(form1.ip_current.Text))) then
    begin
      form1.logs.Lines.Add('2. ��� �������� - ����� ��������� ��������.');
      form1.caution_time.visible:= True;
      form1.caution_pwr.visible:= True;
      form1.logs.Lines.Add('3. ������ �������� cfg �� ���... �������� ���������� ��������.');
      form1.dot_timer.Enabled:= True;
      cmd:= kluch + 'echo y | pscp.exe -r -pw "" ' + dir_unzip + 'cfg\ root@' + normalip(form1.ip_current.Text) + ':/mnt/ufs/root/mplc4/cfg/';
      if form1.CheckBox1.Checked then
        form1.logs.Lines.Add(cmd);
      form1.logs.Lines.Add('');
      ExecuteFile:='cmd.exe';
      FillChar(SEInfo, SizeOf(SEInfo), 0) ;
      SEInfo.cbSize := SizeOf(TShellExecuteInfo) ;
      with SEInfo do
        begin
          fMask := SEE_MASK_NOCLOSEPROCESS;
          Wnd := Application.Handle;
          lpFile := PChar(ExecuteFile) ;
          lpParameters := PChar(cmd) ;
          nShow := SW_HIDE;
        end;
      if ShellExecuteEx(@SEInfo) then
        begin
          repeat
            Application.ProcessMessages;
            GetExitCodeProcess(SEInfo.hProcess, ExitCode) ;
          until (ExitCode <> STILL_ACTIVE) or Application.Terminated;
          form1.dot_timer.Enabled:= False;
          form1.logs.Lines.Add('');
          form1.logs.Lines.Add('������� �������.');
        end
      else
        begin
          MessageDlg('������ ��� ������ �������� cfg!', mtError, [mbOK],0);
          Application.Terminate;
        end;
      form1.logs.Lines.Add('4. ������ �������� htdocs �� ���... �������� ���������� ��������.');
      form1.dot_timer.Enabled:= True;
      cmd:= kluch + 'echo y | pscp.exe -r -pw "" ' + dir_unzip + 'htdocs\ root@' + normalip(form1.ip_current.Text) + ':/mnt/ufs/root/mplc4/htdocs/';
      if form1.CheckBox1.Checked then
        form1.logs.Lines.Add(cmd);
      form1.logs.Lines.Add('');
      ExecuteFile:='cmd.exe';
      FillChar(SEInfo, SizeOf(SEInfo), 0) ;
      SEInfo.cbSize := SizeOf(TShellExecuteInfo) ;
      with SEInfo do
        begin
          fMask := SEE_MASK_NOCLOSEPROCESS;
          Wnd := Application.Handle;
          lpFile := PChar(ExecuteFile) ;
          lpParameters := PChar(cmd) ;
          nShow := SW_HIDE;
        end;
      if ShellExecuteEx(@SEInfo) then
        begin
          repeat
            Application.ProcessMessages;
            GetExitCodeProcess(SEInfo.hProcess, ExitCode) ;
          until (ExitCode <> STILL_ACTIVE) or Application.Terminated;
          form1.dot_timer.Enabled:= False;
          form1.logs.Lines.Add('');
          form1.logs.Lines.Add('������� htdocs �������.');
        end
      else
        begin
          MessageDlg('������ ��� ������ �������� htdocs!', mtError, [mbOK],0);
          Application.Terminate;
        end;
      form1.logs.Lines.Add('5. ������������ ���... �������� ���������� ��������.');
      form1.dot_timer.Enabled:= True;
      cmd:= kluch + 'echo y | plink.exe -pw "" root@' + normalip(form1.ip_current.Text) + ' "/sbin/reboot"';
      if form1.CheckBox1.Checked then
        form1.logs.Lines.Add(cmd);
      form1.logs.Lines.Add('');
      ExecuteFile:='cmd.exe';
      FillChar(SEInfo, SizeOf(SEInfo), 0) ;
      SEInfo.cbSize := SizeOf(TShellExecuteInfo) ;
      with SEInfo do
        begin
          fMask := SEE_MASK_NOCLOSEPROCESS;
          Wnd := Application.Handle;
          lpFile := PChar(ExecuteFile) ;
          lpParameters := PChar(cmd) ;
          nShow := SW_HIDE;
        end;
      if ShellExecuteEx(@SEInfo) then
        begin
          repeat
            Application.ProcessMessages;
            GetExitCodeProcess(SEInfo.hProcess, ExitCode) ;
          until (ExitCode <> STILL_ACTIVE) or Application.Terminated;
          form1.dot_timer.Enabled:= False;
          form1.logs.Lines.Add('');
          form1.logs.Lines.Add('��� ������������! ��������� ��� �������� � ��������� ������ ��������!');
          form1.logs.Lines.Add('�������� �������� cfg...');
          DeleteFiles(dir_unzip + 'cfg\');
          form1.logs.Lines.Add('�������� �������� htdocs...');
          DeleteFiles(dir_unzip + 'htdocs\');
          form1.logs.Lines.Add('��������� ����� �������.');
          form1.btn_upgrade.Enabled:= False;
          form1.caution_time.visible:= False;
          form1.caution_pwr.visible:= False;
          WSACleanup;
        end
      else
        begin
          MessageDlg('������ ��� ������������ ���!', mtError, [mbOK],0);
          Application.Terminate;
        end;

    end
  else
    begin
      MessageDlg('������ � ����������� ��� - ��������� ������� IP �����!', mtError, [mbOK],0);
      Application.Terminate;
    end;
end;

end.
