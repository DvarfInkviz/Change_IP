unit main;

interface

uses
  Windows, Winapi.Messages, System.SysUtils, System.Variants,
  System.Classes, Vcl.Graphics, system.UITypes,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.StdCtrls,
  Vcl.ExtCtrls, IdBaseComponent, IdComponent, Vcl.ComCtrls, WinSock,
  Vcl.CheckLst, Vcl.Mask, Usock, Uping, ShellApi, ShlObj, ComObj;

const NETFILE = 'network.conf';

type
  TForm1 = class(TForm)
    lbl_current_ip: TLabel;
    ip_current: TMaskEdit;
    lbl_new_ip: TLabel;
    ip_new: TMaskEdit;
    lbl_netmask: TLabel;
    netmask: TMaskEdit;
    lbl_gwaddr: TLabel;
    gwaddr: TMaskEdit;
    logs: TMemo;
    btn_change: TButton;
    lbl_author: TLabel;
    procedure FormShow(Sender: TObject);
    procedure btn_changeClick(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  Form1: TForm1;

implementation

{$R *.dfm}

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

// ��������� �������� ����������� � ���, ���������� cfg � ������� ������
procedure TForm1.btn_changeClick(Sender: TObject);
var cmd: string;
    temp: TStringList;
begin
  form1.logs.Clear;
  form1.logs.Lines.Add('1. �������� ����������� � ��� �� IP=' + normalip(form1.ip_current.Text) + '...');
  if Ping(ansistring(normalip(form1.ip_current.Text))) then
    form1.logs.Lines.Add('2. ��� �������� - ����� �������� IP �����.')
  else
    begin
      MessageDlg('������ � ����������� ��� - ��������� ������� IP �����!', mtError, [mbOK],0);
      Application.Terminate;
    end;
  form1.logs.Lines.Add('3. ������ ������� ������� �������� ���...');
  cmd:= '/c echo y | ' + extractfilepath(paramstr(0))+'pscp.exe -pw "" root@' + normalip(form1.ip_current.Text) + ':/etc/' + NETFILE + ' ' + extractfilepath(paramstr(0));
  ShellExecute(Form1.Handle, 'open', 'cmd.exe', PChar(cmd), nil, SW_NORMAL);
  while not FileExists(extractfilepath(paramstr(0)) + NETFILE) do
      sleep(500);
  sleep(1500);
  form1.logs.Lines.Add('5. ������ ��������� � ������� ������� ��������� ���...');
  temp:= TStringList.Create;
  temp.LoadFromFile(extractfilepath(paramstr(0)) + NETFILE, TEncoding.UTF8);
  temp.Strings[5]:= 'IPADDR="' + normalip(form1.ip_new.Text) + '"';
  temp.Strings[6]:= 'NETMASK="' + normalip(form1.netmask.Text) + '"';
  temp.Strings[7]:= 'GWADDR="' + normalip(form1.gwaddr.Text) + '"';
  temp.SaveToFile(extractfilepath(paramstr(0)) + NETFILE, TEncoding.UTF8);
  temp.Free;
  form1.logs.Lines.Add('6. ���������� ��������� ������� �������� � ���...');
  cmd:= '/c ' + extractfilepath(paramstr(0))+'pscp.exe -pw "" ' + extractfilepath(paramstr(0)) + NETFILE + ' root@' + normalip(form1.ip_current.Text) + ':/etc/';
  ShellExecute(Form1.Handle, 'open', 'cmd.exe', PChar(cmd), nil, SW_NORMAL);
  sleep(30000);
  DeleteFile(extractfilepath(paramstr(0)) + NETFILE);
  cmd:= '/c ' + extractfilepath(paramstr(0))+'plink.exe -pw "" root@' + normalip(form1.ip_current.Text) + ' /sbin/reboot';
  ShellExecute(Form1.Handle, 'open', 'cmd.exe', PChar(cmd), nil, SW_NORMAL);
  sleep(10000);
  form1.logs.Lines.Add('7. ��� ������������ ��� ���������� ����� ��������!');
//  MessageDlg('������������� ���, ����� ��������� �������� � ����!', mtWarning, [mbOK],0);
end;

// �������� ���������� windows � �������� ������� �����
procedure TForm1.FormShow(Sender: TObject);
var WSAData: TWSAData;
    aNetInterfaceList: tNetworkInterfaceList;
    i: integer;
    flag: boolean;
begin
  if WSAStartup($101, WSAData)<>0 then
    begin
      MessageDlg('#ERROR# '+'������ ��� ������������� WinSock DLL', mtError, [mbOK],0);
      Application.Terminate;
    end;
  flag := false;
  if GetNetworkInterfaces(aNetInterfaceList) then
    for i := 0 to High(aNetInterfaceList) do
      if aNetInterfaceList[i].AddrIP<>'127.0.0.1' then
        flag := true;
  if not flag then
    begin
      MessageDlg('#ERROR# '+'������ �������� ������� ����� ������� ��! �� ������� IP �����!', mtError, [mbOK],0);
      Application.Terminate;
    end;
end;

end.
