unit func_proc;

interface
 Uses
  Windows, Messages, SysUtils, Graphics, Controls, Forms,
  Dialogs, StdCtrls, ExtDlgs, ShellApi, ShlObj, ComCtrls,ComObj, Classes, Variants;

  function normalip(ip:string):string;
  function GetMyVersion:string;
  function RunCaptured(const _dirName, _exeName, _cmdLine: string; var res: TStringList): Boolean;
  Procedure WinExecute(CmdLine: string; Wait: Boolean);

implementation

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
      if CreateProcess(nil, PChar(_exeName + ' ' + _cmdLine), nil, nil, True,
                       CREATE_NO_WINDOW, nil, PChar(_dirName), start, procInfo) then
                       //CREATE_NO_WINDOW
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

end.
