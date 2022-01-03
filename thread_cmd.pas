unit thread_cmd;

interface

uses
  System.Classes;


type
  Tthread_cmd = class(TThread)
  private
    { Private declarations }
  protected
    procedure Execute; override;
  end;

implementation

  uses
  Windows, Messages, SysUtils, Variants, Graphics, Controls, Forms,
  Dialogs, StdCtrls, ExtDlgs, ShellApi, ShlObj, ComCtrls, Mask,
  ExtCtrls, jpeg, System.UITypes, main, uping, func_proc;




{ thread_cmd }

procedure Tthread_cmd.Execute;
var cmd, kluch: string;
    temp: TStringList;
begin
  if form1.CheckBox1.Checked then
    kluch:= '/k '
  else
    kluch:= '/c ';
  form1.btn_change.Enabled:= False;
  form1.logs.Clear;
  form1.logs.Lines.Add('1. Проверка подключения к ПЛК по IP=' + normalip(form1.ip_current.Text) + '...');
  if Ping(ansistring(normalip(form1.ip_current.Text))) then
    begin
      form1.logs.Lines.Add('2. ПЛК отвечает - можно заменить IP адрес.');
      form1.logs.Lines.Add('3. Замена сетевых настроек ПЛК...');
      form1.dot_timer.Enabled:= True;
      cmd:= kluch + 'echo y | plink.exe -pw "" root@' + normalip(form1.ip_current.Text) + ' sed -i ' + #$0027 + 's/IPADDR=.*/IPADDR="' + normalip(form1.ip_new.Text) + '"/; s/NETMASK=.*/NETMASK="' + normalip(form1.netmask.Text) + '"/; s/GWADDR=.*/GWADDR="' + normalip(form1.gwaddr.Text) + '"/' + #$0027 + ' /etc/network.conf; /sbin/reboot';
      if form1.CheckBox1.Checked then
        form1.logs.Lines.Add(cmd);
      temp:=TStringList.Create;
      if RunCaptured('C:\', 'cmd.exe',cmd,temp) then
        begin
          form1.dot_timer.Enabled:= False;
          form1.logs.Lines.Add('');
          form1.logs.Lines.Add('Адрес ПЛК заменен на ' + form1.ip_new.Text + '.');
          form1.logs.Lines.Add('ПЛК перезагружен! Дождитесь его загрузки и проверьте связь! Программу можно закрыть.');
          form1.btn_change.Enabled:= True;
        end
      else
        begin
          MessageDlg('Ошибка при замене адреса ПЛК!', mtError, [mbOK],0);
          Application.Terminate;
        end;
      temp.Free;
    end
  else
    begin
      MessageDlg('Ошибка в подключении ПЛК - проверьте текущий IP адрес!', mtError, [mbOK],0);
      Application.Terminate;
    end;
end;

end.
