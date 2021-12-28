object Form1: TForm1
  Left = 0
  Top = 0
  BorderIcons = [biSystemMenu]
  Caption = 'Change IP'
  ClientHeight = 376
  ClientWidth = 209
  Color = clBtnFace
  CustomTitleBar.ShowIcon = False
  Constraints.MaxHeight = 415
  Constraints.MaxWidth = 225
  Constraints.MinHeight = 415
  Constraints.MinWidth = 225
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
    Left = 8
    Top = 62
    Width = 34
    Height = 13
    Caption = 'New IP'
  end
  object lbl_netmask: TLabel
    Left = 8
    Top = 89
    Width = 46
    Height = 13
    Caption = 'NETMASK'
  end
  object lbl_gwaddr: TLabel
    Left = 8
    Top = 116
    Width = 45
    Height = 13
    Caption = 'GWADDR'
  end
  object lbl_author: TLabel
    Left = 8
    Top = 354
    Width = 172
    Height = 13
    Caption = 'Lyashko A.A. (C) 2021 v.1.2.28121'
  end
  object lbl_ipcurrent: TLabel
    Left = 8
    Top = 35
    Width = 48
    Height = 13
    Caption = 'IP current'
  end
  object ip_current: TMaskEdit
    Left = 80
    Top = 32
    Width = 118
    Height = 21
    Enabled = False
    EditMask = '!099.099.099.099;1;_'
    MaxLength = 15
    TabOrder = 0
    Text = '192.168.000.010'
    OnChange = ip_currentChange
  end
  object ip_new: TMaskEdit
    Left = 80
    Top = 59
    Width = 118
    Height = 21
    Enabled = False
    EditMask = '!099.099.099.099;1;_'
    MaxLength = 15
    TabOrder = 1
    Text = '010.100.100.145'
    OnChange = ip_newChange
  end
  object netmask: TMaskEdit
    Left = 80
    Top = 86
    Width = 119
    Height = 21
    Enabled = False
    EditMask = '!099.099.099.099;1;_'
    MaxLength = 15
    TabOrder = 2
    Text = '255.255.255.000'
    OnChange = netmaskChange
  end
  object gwaddr: TMaskEdit
    Left = 80
    Top = 113
    Width = 119
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
    Width = 192
    Height = 181
    TabOrder = 4
  end
  object btn_change: TButton
    Left = 8
    Top = 140
    Width = 192
    Height = 25
    Caption = 'Change IP'
    Enabled = False
    TabOrder = 5
    OnClick = btn_changeClick
  end
  object cbox_interface: TComboBox
    Left = 7
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
end
