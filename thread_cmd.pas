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
  ExtCtrls, jpeg, System.UITypes, main, uping;




{ thread_cmd }

// ��������� �������� "������" ����� � IP ������
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
var cmd: string;
    temp: TStringList;
    i: integer;
begin
  form1.logs.Clear;
  form1.logs.Lines.Add('1. �������� ����������� � ��� �� IP=' + normalip(form1.ip_current.Text) + '...');
  if Ping(ansistring(normalip(form1.ip_current.Text))) then
    begin
      form1.logs.Lines.Add('2. ��� �������� - ����� �������� IP �����.');
      form1.logs.Lines.Add('3. ������ ������� ������� �������� ���...');
      cmd:= '/c echo y | ' + extractfilepath(paramstr(0))+'pscp.exe -pw "" root@' + normalip(form1.ip_current.Text) + ':/etc/' + NETFILE + ' ' + extractfilepath(paramstr(0));
      ShellExecute(Form1.Handle, 'open', 'cmd.exe', PChar(cmd), nil, SW_NORMAL);
      while not FileExists(extractfilepath(paramstr(0)) + NETFILE) do
          sleep(500);
      sleep(1500);
      temp:= TStringList.Create;
      temp.LoadFromFile(extractfilepath(paramstr(0)) + NETFILE, TEncoding.UTF8);
      form1.logs.Lines.AddStrings(temp);
      //D:\Kosenko\network.conf
      form1.logs.Lines.Add('4. ������ ��������� � ������� ������� ��������� ���...');
      for I := 0 to temp.Count-1 do
        begin
          if pos('IPADDR="',temp.Strings[i])>0 then
            temp.Strings[i]:= 'IPADDR="' + normalip(form1.ip_new.Text) + '"';
          if pos('NETMASK="',temp.Strings[i])>0 then
            temp.Strings[i]:= 'NETMASK="' + normalip(form1.netmask.Text) + '"';
          if pos('GWADDR="',temp.Strings[i])>0 then
            temp.Strings[i]:= 'GWADDR="' + normalip(form1.gwaddr.Text) + '"';
        end;
    //  temp.Strings[5]:= 'IPADDR="' + normalip(form1.ip_new.Text) + '"';
    //  temp.Strings[6]:= 'NETMASK="' + normalip(form1.netmask.Text) + '"';
    //  temp.Strings[7]:= 'GWADDR="' + normalip(form1.gwaddr.Text) + '"';
      form1.logs.Lines.AddStrings(temp);
      temp.SaveToFile(extractfilepath(paramstr(0)) + NETFILE, TEncoding.UTF8);
      temp.Free;
      form1.logs.Lines.Add('5. ���������� ��������� ������� �������� � ���...');
      cmd:= '/c ' + extractfilepath(paramstr(0))+'pscp.exe -pw "" ' + extractfilepath(paramstr(0)) + NETFILE + ' root@' + normalip(form1.ip_current.Text) + ':/etc/';
      ShellExecute(Form1.Handle, 'open', 'cmd.exe', PChar(cmd), nil, SW_NORMAL);
      sleep(30000);
      DeleteFile(extractfilepath(paramstr(0)) + NETFILE);
      cmd:= '/c ' + extractfilepath(paramstr(0))+'plink.exe -pw "" root@' + normalip(form1.ip_current.Text) + ' /sbin/reboot';
      ShellExecute(Form1.Handle, 'open', 'cmd.exe', PChar(cmd), nil, SW_NORMAL);
      sleep(15000);
      form1.logs.Lines.Add('6. ��� ������������ ��� ���������� ����� ��������!');
    //  MessageDlg('������������� ���, ����� ��������� �������� � ����!', mtWarning, [mbOK],0);
    end
  else
    begin
      MessageDlg('������ � ����������� ��� - ��������� ������� IP �����!', mtError, [mbOK],0);
      Application.Terminate;
    end;
end;

end.
