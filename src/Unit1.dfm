object Form1: TForm1
  Left = 1164
  Top = 574
  Width = 245
  Height = 278
  Caption = #1040#1088#1093#1080#1074#1072#1090#1086#1088
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'MS Sans Serif'
  Font.Style = []
  OldCreateOrder = False
  OnCreate = FormCreate
  PixelsPerInch = 96
  TextHeight = 13
  object FilenameLabel: TLabel
    Left = 19
    Top = 56
    Width = 14
    Height = 17
  end
  object Label1: TLabel
    Left = 16
    Top = 8
    Width = 174
    Height = 13
    Caption = #1053#1072#1095#1072#1083#1100#1085#1072#1103' '#1076#1083#1080#1085#1072' '#1082#1086#1076#1086#1074#1086#1075#1086' '#1089#1083#1086#1074#1072':'
  end
  object Label2: TLabel
    Left = 128
    Top = 32
    Width = 57
    Height = 13
    Caption = #1057#1084#1077#1097#1077#1085#1080#1077':'
  end
  object OpenButton: TButton
    Left = 56
    Top = 80
    Width = 145
    Height = 25
    Caption = #1054#1090#1082#1088#1099#1090#1100' '#1092#1072#1081#1083
    TabOrder = 0
    OnClick = OpenButtonClick
  end
  object CompressionButton: TButton
    Left = 56
    Top = 112
    Width = 145
    Height = 25
    Caption = #1057#1078#1072#1090#1100' '#1080' '#1089#1086#1093#1088#1072#1085#1080#1090#1100
    Enabled = False
    TabOrder = 1
    OnClick = CompressionButtonClick
  end
  object RecoveryButton: TButton
    Left = 56
    Top = 144
    Width = 145
    Height = 25
    Caption = #1042#1086#1089#1089#1090#1072#1085#1086#1074#1080#1090#1100' '#1080' '#1089#1086#1093#1088#1072#1085#1080#1090#1100
    Enabled = False
    TabOrder = 2
    OnClick = RecoveryButtonClick
  end
  object ProgressBar1: TProgressBar
    Left = 56
    Top = 176
    Width = 145
    Height = 25
    TabOrder = 3
  end
  object StartBox: TEdit
    Left = 192
    Top = 8
    Width = 17
    Height = 21
    ImeName = 'Russian'
    MaxLength = 1
    TabOrder = 4
    Text = '2'
  end
  object StepBox: TEdit
    Left = 192
    Top = 32
    Width = 17
    Height = 21
    ImeName = 'Russian'
    MaxLength = 1
    TabOrder = 5
    Text = '2'
  end
  object OpenDialog1: TOpenDialog
    Left = 16
    Top = 96
  end
  object SaveDialog1: TSaveDialog
    Left = 8
    Top = 144
  end
end
