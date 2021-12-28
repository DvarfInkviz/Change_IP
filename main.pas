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
    cbox_interface: TComboBox;
    lbl_ipcurrent: TLabel;
    procedure FormShow(Sender: TObject);
    procedure btn_changeClick(Sender: TObject);
    procedure cbox_interfaceChange(Sender: TObject);
    procedure ip_currentChange(Sender: TObject);
    procedure ip_newChange(Sender: TObject);
    procedure netmaskChange(Sender: TObject);
    procedure gwaddrChange(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  Form1: TForm1;

implementation

{$R *.dfm}

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

// процедура проверки подключения к ПЛК, считывания cfg и заливки нового
procedure TForm1.btn_changeClick(Sender: TObject);
var cmd: string;
    temp: TStringList;
begin
  form1.logs.Clear;
  form1.logs.Lines.Add('1. Проверка подключения к ПЛК по IP=' + normalip(form1.ip_current.Text) + '...');
  if Ping(ansistring(normalip(form1.ip_current.Text))) then
    form1.logs.Lines.Add('2. ПЛк отвечает - можно заменить IP адрес.')
  else
    begin
      MessageDlg('Ошибка в подключении ПЛК - проверьте текущий IP адрес!', mtError, [mbOK],0);
      Application.Terminate;
    end;
  form1.logs.Lines.Add('3. Чтение текущих сетевых настроек ПЛК...');
  cmd:= '/c echo y | ' + extractfilepath(paramstr(0))+'pscp.exe -pw "" root@' + normalip(form1.ip_current.Text) + ':/etc/' + NETFILE + ' ' + extractfilepath(paramstr(0));
  ShellExecute(Form1.Handle, 'open', 'cmd.exe', PChar(cmd), nil, SW_NORMAL);
  while not FileExists(extractfilepath(paramstr(0)) + NETFILE) do
      sleep(500);
  sleep(1500);
  form1.logs.Lines.Add('5. Вносим изменения в текущие сетевые настройки ПЛК...');
  temp:= TStringList.Create;
  temp.LoadFromFile(extractfilepath(paramstr(0)) + NETFILE, TEncoding.UTF8);
  temp.Strings[5]:= 'IPADDR="' + normalip(form1.ip_new.Text) + '"';
  temp.Strings[6]:= 'NETMASK="' + normalip(form1.netmask.Text) + '"';
  temp.Strings[7]:= 'GWADDR="' + normalip(form1.gwaddr.Text) + '"';
  temp.SaveToFile(extractfilepath(paramstr(0)) + NETFILE, TEncoding.UTF8);
  temp.Free;
  form1.logs.Lines.Add('6. Записываем изменения сетевых настроек в ПЛК...');
  cmd:= '/c ' + extractfilepath(paramstr(0))+'pscp.exe -pw "" ' + extractfilepath(paramstr(0)) + NETFILE + ' root@' + normalip(form1.ip_current.Text) + ':/etc/';
  ShellExecute(Form1.Handle, 'open', 'cmd.exe', PChar(cmd), nil, SW_NORMAL);
  sleep(30000);
  DeleteFile(extractfilepath(paramstr(0)) + NETFILE);
  cmd:= '/c ' + extractfilepath(paramstr(0))+'plink.exe -pw "" root@' + normalip(form1.ip_current.Text) + ' /sbin/reboot';
  ShellExecute(Form1.Handle, 'open', 'cmd.exe', PChar(cmd), nil, SW_NORMAL);
  sleep(10000);
  form1.logs.Lines.Add('7. ПЛК перезагружен для применения новых настроек!');
//  MessageDlg('Перезагрузите ПЛК, чтобы изменения вступили в силу!', mtWarning, [mbOK],0);
end;

// проверка библиотеки windows и настроек сетевой карты
procedure TForm1.cbox_interfaceChange(Sender: TObject);
begin
  if form1.cbox_interface.ItemIndex = 0 then
    begin
      form1.ip_current.Text:= '___.___.___.___';
      form1.ip_current.Enabled:= False;
      form1.ip_new.Enabled:= False;
      form1.netmask.Enabled:= False;
      form1.gwaddr.Enabled:= False;
      form1.btn_change.Enabled:= False;
    end;
  if form1.cbox_interface.ItemIndex = 1 then
    begin
      form1.ip_current.Text:= '192.168.000.010';
      form1.ip_current.Enabled:= True;
    end;
end;

procedure TForm1.FormShow(Sender: TObject);
var WSAData: TWSAData;
    aNetInterfaceList: tNetworkInterfaceList;
    i: integer;
    flag: boolean;
begin
  if WSAStartup($101, WSAData)<>0 then
    begin
      MessageDlg('#ERROR# '+'Ошибка при инициализации WinSock DLL', mtError, [mbOK],0);
      Application.Terminate;
    end;
  flag := false;
  if GetNetworkInterfaces(aNetInterfaceList) then
    for i := 0 to High(aNetInterfaceList) do
      if aNetInterfaceList[i].AddrIP<>'127.0.0.1' then
        flag := true;
  if not flag then
    begin
      MessageDlg('#ERROR# '+'Ошибка настроек сетевой карты данного ПК! Не получен IP адрес!', mtError, [mbOK],0);
      Application.Terminate;
    end;
end;

procedure TForm1.gwaddrChange(Sender: TObject);
begin
  if pos(' ',form1.gwaddr.Text)=0 then
    form1.btn_change.Enabled:= True
  else
    form1.btn_change.Enabled:= False;
end;

procedure TForm1.ip_currentChange(Sender: TObject);
begin
  if pos(' ',form1.ip_current.Text)=0 then
    begin
      form1.ip_new.Enabled:= True;
      form1.ip_new.OnChange(Sender);
    end
  else
    form1.ip_new.Enabled:= False;
end;

procedure TForm1.ip_newChange(Sender: TObject);
begin
  if pos(' ',form1.ip_new.Text)=0 then
    begin
      form1.netmask.Enabled:= True;
      form1.netmask.OnChange(Sender);
    end
  else
    form1.netmask.Enabled:= False;
end;

procedure TForm1.netmaskChange(Sender: TObject);
begin
  if pos(' ',form1.netmask.Text)=0 then
    begin
      form1.gwaddr.Enabled:= True;
      form1.gwaddr.OnChange(Sender);
    end
  else
    form1.gwaddr.Enabled:= False;
end;

end.
