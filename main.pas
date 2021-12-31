unit main;

interface

uses
  Windows, Winapi.Messages, System.SysUtils, System.Variants,
  System.Classes, Vcl.Graphics, system.UITypes, func_proc,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.StdCtrls,
  Vcl.ExtCtrls, IdBaseComponent, IdComponent, Vcl.ComCtrls, WinSock,
  Vcl.CheckLst, Vcl.Mask, Usock, ComObj, thread_cmd, Vcl.Imaging.pngimage;

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
    cbox_interface: TComboBox;
    lbl_ipcurrent: TLabel;
    StatusBar1: TStatusBar;
    clk_timer: TTimer;
    CheckBox1: TCheckBox;
    dot_timer: TTimer;
    Image1: TImage;
    procedure FormShow(Sender: TObject);
    procedure btn_changeClick(Sender: TObject);
    procedure cbox_interfaceChange(Sender: TObject);
    procedure ip_currentChange(Sender: TObject);
    procedure ip_newChange(Sender: TObject);
    procedure netmaskChange(Sender: TObject);
    procedure gwaddrChange(Sender: TObject);
    procedure clk_timerTimer(Sender: TObject);
    procedure dot_timerTimer(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  Form1: TForm1;
  Thread_cmd: Tthread_cmd;            //переменная процесса

implementation

{$R *.dfm}

// процедура проверки подключения к ПЛК, считывания cfg и заливки нового
procedure TForm1.btn_changeClick(Sender: TObject);
begin
  Thread_cmd := Tthread_cmd.Create(true);
  Thread_cmd.FreeOnTerminate:=true;
  Thread_cmd.Priority:=tpNormal;
  Thread_cmd.Suspended:=False;
end;



procedure TForm1.cbox_interfaceChange(Sender: TObject);
begin
  if form1.cbox_interface.ItemIndex < 0 then
    form1.ip_current.Enabled:= False
  else
    form1.ip_current.Enabled:= True;
  if form1.cbox_interface.ItemIndex = 0 then
    begin
      form1.ip_current.Text:= '192.168.100.246';
      form1.ip_current.SetFocus;
    end;
  if form1.cbox_interface.ItemIndex = 1 then
    begin
      form1.ip_current.Text:= '192.168.000.010';
      form1.ip_current.Enabled:= True;
      form1.ip_current.OnChange(Sender);
      form1.ip_new.SetFocus;
    end;
end;

procedure TForm1.clk_timerTimer(Sender: TObject);
begin
  form1.StatusBar1.Panels.Items[1].Text:= timetostr(now);
end;

procedure TForm1.dot_timerTimer(Sender: TObject);
begin
  if pos('=', form1.logs.Lines[form1.logs.Lines.Count-1])=0 then
    form1.logs.Lines.Add('=>')
  else
    form1.logs.Lines[form1.logs.Lines.Count-1]:='='+form1.logs.Lines[form1.logs.Lines.Count-1];
end;

// проверка библиотеки windows и настроек сетевой карты
procedure TForm1.FormShow(Sender: TObject);
var WSAData: TWSAData;
    aNetInterfaceList: tNetworkInterfaceList;
    i: integer;
    flag: boolean;
begin
  form1.StatusBar1.Panels.Items[0].Text:= form1.StatusBar1.Panels.Items[0].Text + #$00AE;
  form1.StatusBar1.Panels.Items[2].Text:= 'Versioin: ' + GetMyVersion;
  form1.StatusBar1.Panels.Items[1].Text:= timetostr(now);
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
    begin
      form1.ip_new.Enabled:= False;
      form1.netmask.Enabled:= False;
      form1.gwaddr.Enabled:= False;
      form1.btn_change.Enabled:= False;
    end;
end;

procedure TForm1.ip_newChange(Sender: TObject);
begin
  if pos(' ',form1.ip_new.Text)=0 then
    begin
      form1.netmask.Enabled:= True;
      form1.netmask.OnChange(Sender);
    end
  else
    begin
      form1.netmask.Enabled:= False;
      form1.gwaddr.Enabled:= False;
      form1.btn_change.Enabled:= False;
    end;
end;

procedure TForm1.netmaskChange(Sender: TObject);
begin
  if pos(' ',form1.netmask.Text)=0 then
    begin
      form1.gwaddr.Enabled:= True;
      form1.gwaddr.OnChange(Sender);
    end
  else
    begin
      form1.gwaddr.Enabled:= False;
      form1.btn_change.Enabled:= False;
    end;
end;

end.
