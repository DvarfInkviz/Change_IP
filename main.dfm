object Form1: TForm1
  Left = 0
  Top = 0
  BorderIcons = [biSystemMenu]
  Caption = 'Change IP'
  ClientHeight = 351
  ClientWidth = 209
  Color = clBtnFace
  CustomTitleBar.ShowIcon = False
  Constraints.MaxHeight = 390
  Constraints.MaxWidth = 225
  Constraints.MinHeight = 390
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
  object lbl_current_ip: TLabel
    Left = 8
    Top = 11
    Width = 64
    Height = 13
    Caption = 'USB-B IPaddr'
  end
  object lbl_new_ip: TLabel
    Left = 8
    Top = 38
    Width = 34
    Height = 13
    Caption = 'New IP'
  end
  object lbl_netmask: TLabel
    Left = 8
    Top = 65
    Width = 46
    Height = 13
    Caption = 'NETMASK'
  end
  object lbl_gwaddr: TLabel
    Left = 8
    Top = 92
    Width = 45
    Height = 13
    Caption = 'GWADDR'
  end
  object lbl_author: TLabel
    Left = 8
    Top = 330
    Width = 166
    Height = 13
    Caption = 'Lyashko A.A. (C) 2021 v.1.1.2412'
  end
  object ip_current: TMaskEdit
    Left = 80
    Top = 8
    Width = 118
    Height = 21
    Enabled = False
    EditMask = '!099.099.099.099;1;_'
    MaxLength = 15
    TabOrder = 0
    Text = '192.168.000.010'
  end
  object ip_new: TMaskEdit
    Left = 80
    Top = 35
    Width = 118
    Height = 21
    EditMask = '!099.099.099.099;1;_'
    MaxLength = 15
    TabOrder = 1
    Text = '010.100.100.145'
  end
  object netmask: TMaskEdit
    Left = 80
    Top = 62
    Width = 119
    Height = 21
    EditMask = '!099.099.099.099;1;_'
    MaxLength = 15
    TabOrder = 2
    Text = '255.255.255.000'
  end
  object gwaddr: TMaskEdit
    Left = 80
    Top = 89
    Width = 119
    Height = 21
    EditMask = '!099.099.099.099;1;_'
    MaxLength = 15
    TabOrder = 3
    Text = '192.168.100.003'
  end
  object logs: TMemo
    Left = 8
    Top = 147
    Width = 192
    Height = 181
    TabOrder = 4
  end
  object btn_change: TButton
    Left = 8
    Top = 116
    Width = 192
    Height = 25
    Caption = 'Change IP'
    TabOrder = 5
    OnClick = btn_changeClick
  end
end
