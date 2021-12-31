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

// процедура удаления "лишних" нулей в IP адресе
function normalip(ip:string):string;
var res, tmp: string;
  I: Integer;
begin
  res:= '';
  for I := 1 to 4 do
    begin
      tmp:= copy(ip, i+3*(i-1), 3);
      while (length(tmp) > 0) and (tmp[1] = '0') do
        Delete(tmp, 1, 1);
      if length(tmp) = 0 then
        tmp:= '0';
      if i<4 then
        res:= res + tmp + '.'
      else
        res:= res + tmp;
    end;
  result:= res;
end;

procedure Tthread_cmd.Execute;
var cmd, kluch: string;
    temp: TStringList;
    i: integer;
    flag: boolean;
begin
  if form1.CheckBox1.Checked then
    kluch:= '/c '
  else
    kluch:= '/c ';
  form1.btn_change.Enabled:= False;
  form1.logs.Clear;
  form1.logs.Lines.Add('1. Проверка подключения к ПЛК по IP=' + normalip(form1.ip_current.Text) + '...');
  if Ping(ansistring(normalip(form1.ip_current.Text))) then
    begin
      form1.logs.Lines.Add('2. ПЛК отвечает - можно заменить IP адрес.');
      form1.logs.Lines.Add('3. Чтение текущих сетевых настроек ПЛК...');
      form1.dot_timer.Enabled:= True;
      cmd:= kluch + 'echo y | "' + extractfilepath(paramstr(0))+'pscp.exe" -pw "" root@' + normalip(form1.ip_current.Text) + ':/etc/' + NETFILE + ' ' + extractfilepath(paramstr(0));
      if not form1.CheckBox1.Checked then
        form1.logs.Lines.Add(cmd);
      temp:=TStringList.Create;
      flag:= False;
      if RunCaptured('C:\', 'cmd.exe',cmd,temp) then
        begin
          form1.dot_timer.Enabled:= False;
          for I := 0 to temp.Count-1 do
            if pos('100%',temp.Strings[i])>0 then
              begin
                flag:= True;
                form1.logs.Lines.Add(temp.Strings[i]);
              end;
        end;
      if not flag then
        begin
          MessageDlg('Ошибка в получении файла конфигурации network.conf!', mtError, [mbOK],0);
          Application.Terminate;
        end;
      temp.Free;
      temp:= TStringList.Create;
      temp.LoadFromFile(extractfilepath(paramstr(0)) + NETFILE, TEncoding.UTF8);
      form1.logs.Lines.Add('');
      form1.logs.Lines.AddStrings(temp);
      form1.logs.Lines.Add('');
      //D:\Kosenko\network.conf
      form1.logs.Lines.Add('4. Вносим изменения в текущие сетевые настройки ПЛК...');
      form1.logs.Lines.Add('');
      for I := 0 to temp.Count-1 do
        begin
          if pos('IPADDR="',temp.Strings[i])>0 then
            begin
              temp.Strings[i]:= 'IPADDR="' + normalip(form1.ip_new.Text) + '"';
              form1.logs.Lines.Add(temp.Strings[i]);
            end;
          if pos('NETMASK="',temp.Strings[i])>0 then
            begin
              temp.Strings[i]:= 'NETMASK="' + normalip(form1.netmask.Text) + '"';
              form1.logs.Lines.Add(temp.Strings[i]);
            end;
          if pos('GWADDR="',temp.Strings[i])>0 then
            begin
              temp.Strings[i]:= 'GWADDR="' + normalip(form1.gwaddr.Text) + '"';
              form1.logs.Lines.Add(temp.Strings[i]);
            end;
        end;
      form1.logs.Lines.Add('');
      temp.SaveToFile(extractfilepath(paramstr(0)) + NETFILE, TEncoding.UTF8);
      temp.Free;
      form1.logs.Lines.Add('5. Записываем изменения сетевых настроек в ПЛК...');
      form1.dot_timer.Enabled:= True;
      cmd:= kluch + 'echo y | "' + extractfilepath(paramstr(0))+'pscp.exe" -pw "" "' + extractfilepath(paramstr(0)) + NETFILE + '" root@' + normalip(form1.ip_current.Text) + ':/etc/';
      if not form1.CheckBox1.Checked then
        form1.logs.Lines.Add(cmd);
      temp:=TStringList.Create;
      flag:= False;
      if RunCaptured('C:\', 'cmd.exe',cmd,temp) then
        begin
          form1.dot_timer.Enabled:= False;
          for I := 0 to temp.Count-1 do
            if pos('100%',temp.Strings[i])>0 then
              begin
                flag:= True;
                form1.logs.Lines.Add(temp.Strings[i]);
              end;
        end;
      if not flag then
        begin
          MessageDlg('Ошибка в отправке файла конфигурации network.conf!', mtError, [mbOK],0);
          Application.Terminate;
        end;
      temp.Free;
      form1.logs.Lines.Add('');
      form1.logs.Lines.Add('6. Посылаем команду перезагрузки ПЛК...');
      form1.dot_timer.Enabled:= True;
      cmd:= kluch + '"' + extractfilepath(paramstr(0))+'plink.exe" -pw "" root@' + normalip(form1.ip_current.Text) + ' /sbin/reboot';
      if not form1.CheckBox1.Checked then
        form1.logs.Lines.Add(cmd);
      temp:=TStringList.Create;
      if RunCaptured('C:\', 'cmd.exe',cmd,temp) then
        begin
          form1.dot_timer.Enabled:= False;
          form1.logs.Lines.Add('');
          form1.logs.Lines.Add('7. Адрес ПЛК заменен на ' + form1.ip_new.Text + '. ПЛК перезагружен! Дождитесь его загрузки и проверьте связь! Программу можно закрыть.');
          form1.btn_change.Enabled:= True;
        end
      else
        begin
          MessageDlg('Ошибка при перезагрузке ПЛК!', mtError, [mbOK],0);
          Application.Terminate;
        end;
      temp.Free;
      DeleteFile(extractfilepath(paramstr(0)) + NETFILE);
    end
  else
    begin
      MessageDlg('Ошибка в подключении ПЛК - проверьте текущий IP адрес!', mtError, [mbOK],0);
      Application.Terminate;
    end;
end;

end.
