object Form1: TForm1
  Left = 1164
  Top = 574
  Width = 223
  Height = 210
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
    Left = 40
    Top = 8
    Width = 3
    Height = 13
  end
  object OpenButton: TButton
    Left = 40
    Top = 32
    Width = 145
    Height = 25
    Caption = #1054#1090#1082#1088#1099#1090#1100' '#1092#1072#1081#1083
    TabOrder = 0
    OnClick = OpenButtonClick
  end
  object CompressionButton: TButton
    Left = 40
    Top = 64
    Width = 145
    Height = 25
    Caption = #1057#1078#1072#1090#1100' '#1080' '#1089#1086#1093#1088#1072#1085#1080#1090#1100
    Enabled = False
    TabOrder = 1
    OnClick = CompressionButtonClick
  end
  object RecoveryButton: TButton
    Left = 40
    Top = 96
    Width = 145
    Height = 25
    Caption = #1042#1086#1089#1089#1090#1072#1085#1086#1074#1080#1090#1100' '#1080' '#1089#1086#1093#1088#1072#1085#1080#1090#1100
    Enabled = False
    TabOrder = 2
    OnClick = RecoveryButtonClick
  end
  object ProgressBar1: TProgressBar
    Left = 40
    Top = 128
    Width = 145
    Height = 25
    TabOrder = 3
  end
  object OpenDialog1: TOpenDialog
    Top = 48
  end
  object SaveDialog1: TSaveDialog
    Left = 65528
    Top = 96
  end
end
