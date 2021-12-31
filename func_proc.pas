unit func_proc;

interface
 Uses
  Windows, Messages, SysUtils, Graphics, Controls, Forms,
  Dialogs, StdCtrls, ExtDlgs, ShellApi, ShlObj, ComCtrls,ComObj, Classes, Variants;

  function HexToInt(CH : string): integer;
  function dec2hex(value,len: dword): string;
  function Hex2Bin(Hex: string):string;
  function folder(dr:string):string;
  function WindowsCopyFile(FromFile, ToDir : string) : boolean;
  function obrab(s:string; scale:integer; zero:boolean; var flag:boolean):string;
  function key_mod(k_i,nomer:integer):integer;
  function GetMyVersion:string;
  function RunCaptured(const _dirName, _exeName, _cmdLine: string; var res: TStringList): Boolean;
  function MaskSpace(s:string):string;
  Procedure WinExecute(CmdLine: string; Wait: Boolean);
  procedure Scan_file(StartDir,files,mask: string; var qpf:string);
  procedure const_edit(const_file,chislo:string;ver:integer);
  procedure mif_edit(dir,cnt:string;num:integer);

implementation

// Функция перевода шестнадцетиричного символа в число //
function HexToInt(CH : string): integer;
var i,x,j,res:integer;
begin
  Res:=0;
  x:=0;
  for i := length(ch) downto 1 do
    begin
      case CH[i] of
        '0'..'9': x:=Ord(CH[i])-Ord('0');
        'A'..'F': x:=Ord(CH[i])-Ord('A')+10;
        'a'..'f': x:=Ord(CH[i])-Ord('a')+10;
      end;
      if length(ch)-i>0 then
        for j := 1 to length(ch)-i do
          x:=x*16;
      res:=res + x;
    end;
  result:=res;
end;
//-----------------------------//

// функция Dec -> Hex //
function dec2hex(value,len: dword): string;
const
  hexdigit = '0123456789ABCDEF';
var s:string;
    i:integer;
  j: Integer;
begin
  s:='';
  while value <> 0 do
  begin
    s := hexdigit[succ(value and $F)] + s;
    value := value shr 4;
  end;
  for I := 0 to len -1 do
    if length(s)=i then
      for j := i+1 to len do
        s:= '0' + s;
  Result:= s;
end;
//-------------------------------//

// HEX -> bin
function Hex2Bin(Hex: string):string;
const
  BCD: array [0..15] of string =
    ('0000', '0001', '0010', '0011', '0100', '0101', '0110', '0111',
    '1000', '1001', '1010', '1011', '1100', '1101', '1110', '1111');
var
  i: integer;
  res,s:string;
begin
  res:='';
  s:=dec2hex(strtoint(hex),8);
  for i := 1 to length(s) do
    res := res+BCD[HexToInt(s[i])];
  Result:=res;
end;

// функция добавления '\' при необходимости //
function folder(dr:string):string;
begin
  if dr[length(dr)] <> '\' then Result:=dr + '\'
  else Result:=dr;
end;
//-------------------------//

// функция копирования файлов //
function WindowsCopyFile(FromFile, ToDir : string) : boolean;
var F : TShFileOpStruct;
begin
  F.Wnd := 0;
  F.wFunc := FO_COPY;
  FromFile:=FromFile+#0;
  F.pFrom:=pchar(FromFile);
  ToDir:=ToDir+#0;
  F.pTo:=pchar(ToDir);
  F.fFlags := FOF_ALLOWUNDO or FOF_NOCONFIRMATION;
  result:=ShFileOperation(F) = 0;
end;
//-------------------------------//

// функция проверки строки на лишние символы //
// Используется в TDebug.Button1Click; TCompilation.firstChange; TCompilation.quantChange;
function obrab(s:string;scale:integer;zero:boolean;var flag:boolean):string;
var str:string;
  I: Integer;
const d='0123456789';             // scale=0
      h='abcdefABCDEF0123456789'; // scale=1
begin
  flag:=false;
  str:='';
  for I := 1 to length(s) do
    if scale=0 then
      if pos(s[i],d)>0 then
        str:=str+s[i]
      else
        flag:=true
    else
      if pos(s[i],h)>0 then
        str:=str+s[i]
      else
        flag:=true;
  if zero then
    for I := length(str) to 5 do
      str:='0'+str;
  Result:=str;
end;
//-------------//

// функция модификации ключа //
function key_mod(k_i,nomer:integer):integer;
begin
  if k_i>65635 then
    Result:=((k_i mod 256)xor(k_i div 256))*65536+k_i
  else
    if nomer<65536 then
      Result:=(k_i xor nomer)*1048576+k_i
    else
      Result:=(k_i xor (nomer div 256))*1048576+k_i;
end;
//---------------------------------//

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

// функция перехвата консоли //
function RunCaptured(const _dirName, _exeName, _cmdLine: string; var res: TStringList): Boolean;
var
  start: TStartupInfo;
  procInfo: TProcessInformation;
  tmpName: string;
  tmp: Windows.THandle;
  tmpSec: TSecurityAttributes;

  return: Cardinal;
begin
  Result := true;//False;
  try
    { Set a temporary file }
    tmpName := extractfilepath(paramstr(0)) + 'Test.tmp';
    FillChar(tmpSec, SizeOf(tmpSec), #0);
    tmpSec.nLength := SizeOf(tmpSec);
    tmpSec.bInheritHandle := True;
    tmp := Windows.CreateFile(PChar(tmpName),
           Generic_Write, File_Share_Write,
           @tmpSec, Create_Always, File_Attribute_Normal, 0);
    try
      FillChar(start, SizeOf(start), #0);
      start.cb          := SizeOf(start);
      start.hStdOutput  := tmp;
      start.dwFlags     := StartF_UseStdHandles or StartF_UseShowWindow;
      start.wShowWindow := SW_Minimize;
      { Start the program }
      if CreateProcess(nil, PChar(_exeName + ' ' + _cmdLine), nil, nil, True,
                       0, nil, PChar(_dirName), start, procInfo) then
        begin
          SetPriorityClass(procInfo.hProcess, Idle_Priority_Class);
          WaitForSingleObject(procInfo.hProcess, Infinite);
          GetExitCodeProcess(procInfo.hProcess, return);
//          Result := (return = 0);
          CloseHandle(procInfo.hThread);
          CloseHandle(procInfo.hProcess);
          Windows.CloseHandle(tmp);
          { Add the output }
          try
            res.LoadFromFile(tmpName);
          finally
          end;
          Windows.DeleteFile(PChar(tmpName));
        end
      else
        begin
          Application.MessageBox(PChar(SysErrorMessage(GetLastError())),
            'RunCaptured Error', MB_OK);
        end;
    except
      Windows.CloseHandle(tmp);
      Windows.DeleteFile(PChar(tmpName));
      raise;
    end;
  finally
  end;
end;
//-----------------------------//

// Функция обработки номера TMaskEdit //
function MaskSpace(s:string):string;
var str:string;
  I: Integer;
const d='0123456789';
begin
  str:='';
  for I := 1 to length(s) do
    if pos(s[i],d)>0 then
      str:=str+s[i];
  Result:=str;
end;
//-----------------------------//

// процедура ожидания завершения процесса компиляции //
Procedure WinExecute(CmdLine: string; Wait: Boolean);
var StartupInfo: TStartupInfo;
    ProcessInformation: TProcessInformation;
begin
  try
    FillChar(StartupInfo, SizeOf(StartupInfo), 0);
    StartupInfo.cb := SizeOf(StartupInfo);
    if not CreateProcess(nil, PChar(CmdLine), nil, nil, True, 0, nil, nil, StartupInfo, ProcessInformation)
      then RaiseLastOSError;
   if Wait then
    WaitForSingleObject(ProcessInformation.hProcess, INFINITE);
  except
  end;
end;
//-------------------------------//

//процедура поиска имени файла с определенным расширением
procedure Scan_file(StartDir,files,mask: string; var qpf:string);
var
  SearchRec: TSearchRec;
begin
  if FindFirst(StartDir + Mask, faAnyFile, SearchRec) = 0 then
    begin
      repeat Application.ProcessMessages;
        if (SearchRec.Attr and faDirectory) <> faDirectory then
          begin
            if pos(files,SearchRec.Name)>0 then
              begin
                qpf:=StartDir+SearchRec.Name;
                FindClose(SearchRec);
              end;
          end
        else
          if (SearchRec.Name <> '..') and (SearchRec.Name <> '.')then
            begin
              Scan_file(StartDir + SearchRec.Name + '\',files,mask,qpf);
            end;
      until FindNext(SearchRec) <> 0;
      FindClose(SearchRec);
    end;
end;
//--------------------------------//

//процедура замены константы в файлах *.tdf, *.v (сразу в трех местах) //
procedure const_edit(const_file,chislo:string;ver:integer);
var tempp:tstrings;
  I: Integer;
begin
//ver = 3 => 		result = 32'b00000000111100010100000000001100; //
  tempp:=tstringlist.Create;
  tempp.LoadFromFile(const_file);
  for I := 0 to tempp.Count-1 do
    begin
      if (pos('result = 32',tempp.strings[i])>0)and(ver=3) then
        begin
          tempp.Insert(i,copy(tempp.Strings[i],1,pos('b',tempp.Strings[i])) + hex2bin(chislo) + ';');
          tempp.Delete(i+1);
        end;
      if (pos('lpm_constant_component.lpm_cvalue = ',tempp.strings[i])>0)and(ver=1) then
        begin
          tempp.Insert(i,copy(tempp.Strings[i],1,pos('=',tempp.Strings[i])+1) + chislo + ',');
          tempp.Delete(i+1);
        end;
      if (pos('LPM_CVALUE =',tempp.strings[i])>0)and(ver=2) then
        begin
          tempp.Insert(i,copy(tempp.Strings[i],1,pos('=',tempp.Strings[i])+1) + chislo + ',');
          tempp.Delete(i+1);
        end;
      if pos(': Value NUMERIC "',tempp.strings[i])>0 then
        begin
          tempp.Insert(i,copy(tempp.Strings[i],1,pos('"',tempp.Strings[i])) + chislo + '"');
          tempp.Delete(i+1);
        end;
      if pos(': LPM_CVALUE NUMERIC "',tempp.strings[i])>0 then
        begin
          tempp.Insert(i,copy(tempp.Strings[i],1,pos('"',tempp.Strings[i])) + chislo + '"');
          tempp.Delete(i+1);
        end;
    end;
  tempp.SaveToFile(const_file);
  tempp.Free;
end;
//--------------------------------//

// процедура замены в mif файле CYCLON констант//
procedure mif_edit(dir,cnt:string;num:integer);
var tempp:tstrings;
    i,j:integer;
begin
  tempp:=tstringlist.create;
  tempp.LoadFromFile(dir);
  j:=0;
  for I := 0 to tempp.Count - 1 do
    if pos('CONTENT BEGIN',tempp.Strings[i])>0 then
      j:=i+1+num;
  tempp.Insert(j,#9 + '0'+inttostr(num)+'  :   ' + cnt + ';');
  tempp.Delete(j+1);
  tempp.SaveToFile(dir);
  tempp.Free;
end;
//----------------------------------//

end.
