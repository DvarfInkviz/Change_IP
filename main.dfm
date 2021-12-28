object Form1: TForm1
  Left = 0
  Top = 0
  BorderIcons = [biSystemMenu]
  Caption = 'Change IP'
  ClientHeight = 411
  ClientWidth = 284
  Color = clBtnFace
  CustomTitleBar.ShowIcon = False
  Constraints.MaxHeight = 450
  Constraints.MaxWidth = 300
  Constraints.MinHeight = 450
  Constraints.MinWidth = 300
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  OldCreateOrder = False
  OnShow = FormShow
  PixelsPerInch = 96
  TextHeight = 13
  object lbl_new_ip: TLabel
    Left = 40
    Top = 62
    Width = 34
    Height = 13
    Caption = 'New IP'
  end
  object lbl_netmask: TLabel
    Left = 40
    Top = 89
    Width = 46
    Height = 13
    Caption = 'NETMASK'
  end
  object lbl_gwaddr: TLabel
    Left = 40
    Top = 116
    Width = 45
    Height = 13
    Caption = 'GWADDR'
  end
  object lbl_ipcurrent: TLabel
    Left = 40
    Top = 35
    Width = 48
    Height = 13
    Caption = 'IP current'
  end
  object ip_current: TMaskEdit
    Left = 112
    Top = 32
    Width = 120
    Height = 21
    Enabled = False
    EditMask = '!099.099.099.099;1;_'
    MaxLength = 15
    TabOrder = 0
    Text = '192.168.000.010'
    OnChange = ip_currentChange
  end
  object ip_new: TMaskEdit
    Left = 112
    Top = 59
    Width = 119
    Height = 21
    Enabled = False
    EditMask = '!099.099.099.099;1;_'
    MaxLength = 15
    TabOrder = 1
    Text = '192.168.100.145'
    OnChange = ip_newChange
  end
  object netmask: TMaskEdit
    Left = 112
    Top = 86
    Width = 119
    Height = 21
    Enabled = False
    EditMask = '!099.099.099.099;1;_'
    MaxLength = 15
    TabOrder = 2
    Text = '255.255.254.000'
    OnChange = netmaskChange
  end
  object gwaddr: TMaskEdit
    Left = 112
    Top = 113
    Width = 120
    Height = 21
    Enabled = False
    EditMask = '!099.099.099.099;1;_'
    MaxLength = 15
    TabOrder = 3
    Text = '192.168.100.003'
    OnChange = gwaddrChange
  end
  object logs: TMemo
    Left = 8
    Top = 171
    Width = 268
    Height = 215
    ScrollBars = ssVertical
    TabOrder = 4
  end
  object btn_change: TButton
    Left = 40
    Top = 140
    Width = 192
    Height = 25
    Caption = 'Change IP'
    Enabled = False
    TabOrder = 5
    OnClick = btn_changeClick
  end
  object cbox_interface: TComboBox
    Left = 39
    Top = 5
    Width = 193
    Height = 21
    TabOrder = 6
    Text = 'Choose the interface:'
    OnChange = cbox_interfaceChange
    Items.Strings = (
      'Ethernet'
      'USB B')
  end
  object StatusBar1: TStatusBar
    Left = 0
    Top = 392
    Width = 284
    Height = 19
    Panels = <
      item
        Text = 'Lyashko A.A. (C) 2021 v.1.3.29121'
        Width = 200
      end
      item
        Text = '00:16:16'
        Width = 20
      end>
    ExplicitLeft = -8
  end
  object clk_timer: TTimer
    OnTimer = clk_timerTimer
    Left = 248
    Top = 112
  end
end
