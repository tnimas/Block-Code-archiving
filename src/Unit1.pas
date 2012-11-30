unit Unit1;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, ComCtrls,Archiver;

type
  TForm1 = class(TForm,IProgressHandler)
    OpenButton: TButton;
    CompressionButton: TButton;
    RecoveryButton: TButton;
    ProgressBar1: TProgressBar;
    FilenameLabel: TLabel;
    OpenDialog1: TOpenDialog;
    SaveDialog1: TSaveDialog;
    Label1: TLabel;
    Label2: TLabel;
    StartBox: TEdit;
    StepBox: TEdit;
    procedure OpenButtonClick(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure CompressionButtonClick(Sender: TObject);
    procedure RecoveryButtonClick(Sender: TObject);
  private
    procedure RecalculateFormState(currentFilename:string);
  public
  procedure StepHandleEvent(delta:byte);
  end;
 const filebuf:integer = 1024;
var
  Form1: TForm1;
  archiver:Tarchiver;

implementation


{$R *.dfm}

procedure TForm1.StepHandleEvent(delta:byte);
begin
ProgressBar1.Position := ProgressBar1.Position + delta;
end;

procedure TForm1.OpenButtonClick(Sender: TObject);
begin
if OpenDialog1.Execute then
  RecalculateFormState(OpenDialog1.FileName);
end;



procedure TForm1.FormCreate(Sender: TObject);
begin

archiver:=Tarchiver.Create;
archiver.AddProgressHandler(self);
end;


procedure TForm1.CompressionButtonClick(Sender: TObject);
var start,step:byte;
begin
try
start:=StrToInt(StartBox.Text);
step:=StrToInt(StepBox.Text);
if ( (start+step > 8) or (step < 2)) then
Raise Exception.Create('«адайте корректные значени€ начальной длины кодового слова и смещени€!');

SaveDialog1.Filter := 'Block code file|*.bc';
SaveDialog1.FileName:= FilenameLabel.Caption+'.bc';
if (SaveDialog1.Execute) then
begin
archiver.CompressFile(FilenameLabel.Caption,SaveDialog1.FileName);
RecalculateFormState(SaveDialog1.FileName);
end;

except On E : Exception do
Showmessage(E.Message);
end;

end;


procedure TForm1.RecoveryButtonClick(Sender: TObject);
begin
SaveDialog1.Filter := '';
SaveDialog1.FileName:= Copy(FilenameLabel.Caption,0,length(FilenameLabel.Caption)-3);
if (SaveDialog1.Execute) then
begin
archiver.DecompressFile(FilenameLabel.Caption,SaveDialog1.FileName);
RecalculateFormState(SaveDialog1.FileName);
end;
end;


procedure Tform1.RecalculateFormState(currentFilename:string);
var forCompression:boolean; lastname:string;
begin
ProgressBar1.Position :=0;
FilenameLabel.Caption:=currentFilename;
lastname:=copy(currentFilename,length(currentFilename)-2,3);
forCompression:= (length(currentFilename) > 3) and (lastname <> '.bc');
CompressionButton.Enabled := forCompression;
RecoveryButton.Enabled:= not forCompression;
end;

end.
