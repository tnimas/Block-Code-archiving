unit Archiver;

interface
uses Dialogs, Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls,Math;
type

  IProgressHandler = interface
  procedure StepHandleEvent(delta:byte);
  end;

  TByteArray = array of byte;
  TByteCodes = class
  public
  Code:byte; //соответствует коду байта
  Rang:integer; //чем ниже ранг тем популярнее байт с кодом Code в считанном файле
  CompressedValue:string; //строка отображающая двоичное представление байта в сжатом виде
  //в вызывающем коде для определения прогресса сжатия \ распаковки
  end;

  TData = class(TComponent)
  public
  BlockCodeStep:byte;
  BlockCodeStart:byte;
  Head: TList;
  DataArray : TbyteArray;
  CompressedArray:TbyteArray;
  DataLength:integer;
  end;

TArchiver = class
public
procedure AddProgressHandler(handler:IProgressHandler);
procedure CompressFile(const inputFilename:string;const outputFilename:string;codeStep:byte=2;codeStart:byte=2 );
procedure DecompressFile(const inputFilename:string; const outputFilename: string );
constructor Create();overload;
private
Data:TData;
Handlers:TInterfaceList;
  procedure OnStep(delta:byte);


  procedure LoadDataFromFile(const FileName: TFileName);
  procedure SaveDataToFile(const FileName: TFileName);
  procedure SaveCompressedDataToFile(const FileName: TFileName);
  procedure LoadCompressedDataFromFile(const FileName: TFileName);
  procedure CalculateRangs();
  procedure FillCompressingHeadValues();
  procedure FillCompressingBytes();
  procedure FillDecompressingBytes();
  procedure ClearData();


end;


implementation

function StrToByte(binStr:string):byte;
var i,temp:byte;
begin
result:=0;
for i:=0 to 7 do
  begin
  if binstr[i+1] = '1' then
    temp:=1
  else
    temp:=0;

  result:= result shl 1;
  result:= result + temp;
end;
end;

function ByteToStr(b:byte):string;
var i,temp:byte; isOne:bool;
begin
result:='';
for i:=7 downto 0 do
begin
temp:= (b shr i);
isOne:= (temp mod 2) = 0;

if (not isOne) then
  result:=result+'1'
else
  result:=result+'0';
end;
end;

function compareByCode(Item1 : Pointer; Item2 : Pointer) : Integer;
var
  byteRecord1, byteRecord2 : TByteCodes;
begin
  byteRecord1 := TByteCodes(Item1);
  byteRecord2 := TByteCodes(Item2);

  if      byteRecord1.Code > byteRecord2.Code
  then Result := 1
  else if byteRecord1.Code = byteRecord2.Code
  then Result := 0
  else Result := -1;
end;

function compareByRang(Item1 : Pointer; Item2 : Pointer) : Integer;
var
  byteRecord1, byteRecord2 : TByteCodes;
begin
  byteRecord1 := TByteCodes(Item1);
  byteRecord2 := TByteCodes(Item2);

  if      byteRecord1.Rang > byteRecord2.Rang
  then Result := 1
  else if byteRecord1.Rang = byteRecord2.Rang
  then Result := 0
  else Result := -1;
end;

constructor Tarchiver.Create;
begin
handlers := TInterfaceList.Create;
end;

procedure Tarchiver.CompressFile(const inputFilename:string;const outputFilename:string;codeStep:byte=2;codeStart:byte=2 );
begin
ClearData();
Data.BlockCodeStep := codeStep;
Data.BlockCodeStart:= codeStart;
//загрузить несжатые байты в основной массив
LoadDataFromFile(inputFilename);
//вычислить какие байты встречаются чаще, проранжировать
CalculateRangs();
//добавить строковые значения бит для каждого ранга  байта
FillCompressingHeadValues();
//заполнить массив сжатых байтов на основе массива несжатых байтов и рангов
FillCompressingBytes();
//сохранить ранговую структуру и массив сжатых байтов
SaveCompressedDataToFile(outputFilename);

end;

procedure Tarchiver.DecompressFile(const inputFilename:string;const outputFilename:string );
begin
ClearData();

//загрузить сжатые байты и заголовок в основной массив
LoadCompressedDataFromFile(inputFilename);
//заполнить заголовок строковыми значениями бит для каждого ранга
FillCompressingHeadValues();
//выполнить распаковку данных по сжатым байтам и заголовку
FillDecompressingBytes();
//сохранить массив исходных байтов файла
SaveDataToFile(outputFilename);


end;

procedure Tarchiver.ClearData();
var i:byte; nextByteCode:TByteCodes;
begin

if (Data <> nil) then
begin
  for i:=0 to 255 do
    Data.Head.Items[i]:= nil;
  SetLength(Data.CompressedArray,0);
  SetLength(Data.DataArray,0);
  Data.Head := nil;
  Data:=nil;
end;

Data:= TData.Create(nil);
Data.Head:= TList.Create;
Data.BlockCodeStep:=0;
Data.BlockCodeStart:=0;
for i:=0 to 255 do
begin
  nextByteCode := TByteCodes.Create;
  nextByteCode.code := i;
  nextByteCode.rang := 0;
  Data.Head.Add(nextByteCode);
end;


end;

procedure Tarchiver.CalculateRangs();
var i:integer; nextByteValue:byte; nextByteRecord:TByteCodes;
begin
Data.Head.Sort(compareByCode);

for i:=0 to Data.DataLength-1 do
begin
nextByteValue:=Data.DataArray[i];
//т.к. записи в Head отсортированы по значениям байтов
//первая запись соответствует значению 0, вторая 1 и т.д. до 255
nextByteRecord:= TByteCodes(Data.Head.Items[nextByteValue]);
//вытащив запись с текущим значением байта инкрементим
//количество таких байт в файле,
//чтобы составить список байтов по популярности
inc(nextByteRecord.Rang);
end;

//поменяем количество байт на ранг байта,
//где 0 ранг - ранг с максимальным количеством байтов в файле
//а 255 - с минимальным
Data.Head.Sort(compareByRang);

for i:=0 to Data.Head.Count-1 do
  begin

  nextByteRecord := TByteCodes(Data.Head.Items[i]);
  nextByteRecord.Rang :=  255-i;
  end;


end;


(*
заполнить CompressingValues в соответствии с рангами листа TByteCodes

соответствия rang - result
 0 - 10
 1 - 11
 2 - 0100
 3 - 0101
 4 - 0110
 5 - 0111
 6 - 001000
 7 - 001001
 ...
 255 - ...

 0-10
 1-11
 2-01000


 размер подвижной части по рангам:
 0-1 - 1 (2)
 2-5 - 2 (4)
 6-13 - 3 (8)
 ...
 количество фиксированных нулей + 1
 *)
procedure Tarchiver.FillCompressingHeadValues();
var i,nowZeroCount,rightDelta,j,x:byte;  nextByteRecord:TByteCodes; value,binNumber:string;
countR,currentR:integer;
(*
 количество фиксированных нулей по рангам:
 0-1     - 0 (2)
 2-5     - 1 (4)
 6-13    - 2 (8)
 14-29   - 3 (16)
 30-61   - 4 (32)
 62-125  - 5 (64)
 126-253 - 6 (128)
 254-255 - 7 (2)
*)


begin
Data.Head.Sort(compareByRang);
x:=0;
nowZeroCount:=0;
countR:=Data.BLockCodeStart-1;
currentR:=Round(Power(2,countR));

for i:=0 to 255 do
   begin
   nextByteRecord:= TByteCodes(Data.Head.Items[i]);

   if (i >= currentR) then
   begin
   countR := countR + Data.BlockCodeStep-1;
   currentR:= Round(Power(2,countR)) + i;

   inc(nowZeroCount);
   x:=0;
   end;


   if (nowZeroCount > 0) then
    for j:=0 to nowZeroCount-1 do
      value:= value + '0';
   value:= value + '1';
   binNumber:=ByteToStr(x);



   if (nowZeroCount = 0) then
    rightDelta := 0 else
    rightDelta := Data.BlockCodeStep-1;

 // v1:= length(binNumber)-nowZeroCount*rightDelta-BlockCodeStart+2;
 // v2:= nowZeroCount * rightDelta+BlockCodeStart-1;
  ///ShowMessage(IntToStr(v1+v2));
   value:= value +
    copy(binNumber,length(binNumber)-nowZeroCount*rightDelta-Data.BlockCodeStart+2,nowZeroCount * rightDelta+Data.BlockCodeStart-1);

   nextByteRecord.CompressedValue := value;
   value:='';
   inc(x);
   end;

end;

//на основе data и bytesList сформировать writefile, который представляет собой сжатый блочным кодом readfile
procedure Tarchiver.FillCompressingBytes();
var i,j: integer; nextReadByte,nextWriteByte:byte;procentCounter:integer;
nextByteRecord:TByteCodes;  nowValues,rest:string;
begin
Data.Head.Sort(compareByCode);
SetLength(Data.CompressedArray,Data.DataLength*8);
nowValues:='';
rest:='';
j:=0;
procentCounter:=0;
for i:=0 to Data.DataLength-1 do
begin

inc(procentcounter);
if (procentCounter > Data.DataLength / 100) then
begin
procentCounter :=0;
OnStep(1);
end;

nextReadByte:=Data.DataArray[i];
nextByteRecord:= TByteCodes(Data.Head.Items[nextReadByte]);
nowValues:=nowValues+nextByteRecord.CompressedValue;
while (length(nowValues) >= 8) do
  begin
  nextWriteByte:=StrToByte(copy(nowValues,1,8));
  Delete(nowValues,1,8);
  Data.CompressedArray[j]:=nextWriteByte;
  inc(j);
  end;
end;


if (nowValues <> '') then
begin
while (length(nowValues) < 8) do
 nowValues := nowValues + '0';
Data.CompressedArray[j]:=strtobyte(nowValues);
inc(j);
end;
SetLength(Data.CompressedArray,j);

OnStep(100);

end;

procedure Tarchiver.FillDecompressingBytes();

function DecompressValue(var buffer:string; var dataCounter:integer):boolean;
var j,k:integer; nextValue:TByteCodes; bufferpart:string;
begin
result:=false;
      for j:=1 to length(buffer) do
      begin  //перебрать все варианты кодового слова
       bufferpart:= copy(buffer,1,j);

       for k:=0 to 255 do
       begin //найти нужное сжатое значение
        nextValue:=TbyteCodes(Data.Head.Items[k]);
        if nextValue.CompressedValue = bufferpart then
        begin
         Data.DataArray[dataCounter]:= nextValue.Code;
         inc(dataCounter);
         delete(buffer,1,j);
         result:=true;
         exit;
        end;//if found
       end;//k цикл
      end;//j цикл
end;

var i,dataCounter,arraylength,procentCounter:integer; buffer:string;
begin
buffer:='';
Data.Head.Sort(compareByRang);
arraylength:=length(Data.CompressedArray);
SetLength(Data.DataArray,arraylength*8);
dataCounter:=0;
procentCounter :=0;
for i:=0 to arraylength-1 do
begin

inc(procentCounter);
if (procentCounter > arraylength / 100) then
begin
procentCounter :=0;
OnStep(1);
end;

   buffer := buffer + ByteToStr(Data.CompressedArray[i]);
   if (length(buffer) >= 24) then //16 максимальная длина кодового слова
   begin
     DecompressValue(buffer,dataCounter);
   end;//if buflength >=16
end;//i цикл
while (length(buffer) > 0) do
 if (not DecompressValue(buffer,dataCounter)) then
  break;//в последнем байте могут быть добавленные нули в конце

SetLength(Data.DataArray,dataCounter);
OnStep(100);
end;


//load logic
procedure TArchiver.LoadDataFromFile(const FileName: TFileName);
var
  //buffer:array of byte;
  length:integer;
  FileStream: TFileStream;
begin
  FileStream := TFileStream.Create(FileName, fmOpenRead);
  try
    length:= FileStream.Size;
    //SetLength(buffer,length);
    SetLength(Data.DataArray,length);
    FileStream.Read(Pointer(Data.DataArray)^,length);

   // for i:=0 to length do
   //   Data.DataArray[i] := buffer[i];
    Data.DataLength:=length;
  finally
    FileStream.Free;
  end;
end;

procedure TArchiver.SaveDataToFile(const FileName: TFileName);
var
  FileStream: TFileStream;
begin
  FileStream := TFileStream.Create(FileName, fmCreate);
  try
  //write body
  FileStream.Write(Pointer(Data.DataArray)^,length(Data.DataArray));
  finally
    FileStream.Free;
  end;
end;

procedure TArchiver.LoadCompressedDataFromFile(const FileName: TFileName);
var
  FileStream: TFileStream; i:integer; nextItem:TByteCodes; buf: array of byte;
begin
SetLength(buf,2);
  FileStream := TFileStream.Create(FileName, fmOpenRead);
  try
  //read type
    FileStream.Read(Pointer(buf)^,2);
    Data.BlockCodeStart := buf[0];
    Data.BlockCodeStep  :=buf[1];

  // read head
  for i:=0 to 255 do
  begin
  nextItem := TByteCodes(Data.Head.Items[i]);
  FileStream.Read(Pointer(buf)^,1);
  nextItem.Code := buf[0];
  nextItem.Rang := i;
  end;
  //read body
  SetLength(Data.CompressedArray,Filestream.Size-256);
  FileStream.Read(Pointer(Data.CompressedArray)^,FileStream.Size-256);
  finally
    FileStream.Free;
  end;
end;

procedure TArchiver.SaveCompressedDataToFile(const FileName: TFileName);
var
  FileStream: TFileStream; i:integer; nextItem:TByteCodes; b:byte;
begin
Data.Head.Sort(compareByRang);
  FileStream := TFileStream.Create(FileName, fmCreate);
  try
  //write type
  FileStream.Write(Data.BlockCodeStart,1);
  FileStream.Write(Data.BlockCodeStep,1);
  // write head
  for i:=0 to 255 do
  begin
  nextItem := TByteCodes(Data.Head.Items[i]);
  b:=nextItem.Code;
  FileStream.Write(b,1);
  end;
  //write body
  FileStream.Write(Pointer(Data.CompressedArray)^,length(Data.CompressedArray));
  finally
    FileStream.Free;
  end;
end;


//end load logic
procedure TArchiver.AddProgressHandler(handler:IProgressHandler);
begin
handlers.Add(handler);
end;

procedure TArchiver.OnStep(delta:byte);
var i:integer;
begin
for i:=0 to handlers.Count-1 do
 (IProgressHandler(handlers[i])).StepHandleEvent(delta);
end;


end.
