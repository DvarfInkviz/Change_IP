unit func_proc;

interface
 Uses
  Windows, Messages, SysUtils, Graphics, Controls, Forms,
  Dialogs, StdCtrls, ExtDlgs, ShellApi, ShlObj, ComCtrls,ComObj, Classes, Variants;

  procedure DeleteFiles(const FileName: String);
  function normalip(ip:string):string;
  function GetMyVersion:string;

implementation

// процедура удаления файлов
procedure DeleteFiles(const FileName: String);
var
  FileOp: TSHFileOpStruct;
begin
  FileOp.Wnd := Application.Handle;
  FileOp.wFunc := FO_DELETE;
  FileOp.pFrom := PChar(FileName + #0);
  FileOp.pTo := nil;
  FileOp.fFlags := FOF_NOCONFIRMATION;
  SHFileOperation(FileOp);
end;

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

// функция получение версии программы //
function GetMyVersion:string;
type
  TVerInfo=packed record
    Nevazhno: array[0..47] of byte;
    Minor,Major,Build,Release: word;
  end;
var
  s:TResourceStream;
  v:TVerInfo;
begin
  result:='';
  try
    s:=TResourceStream.Create(HInstance,'#1',RT_VERSION);
    if s.Size>0 then begin
      s.Read(v,SizeOf(v));
      result:=IntToStr(v.Major)+'.'+IntToStr(v.Minor)+'.'+
              IntToStr(v.Release)+'.'+IntToStr(v.Build);
    end;
  s.Free;
  except; end;
end;
//-------------------------//

end.
