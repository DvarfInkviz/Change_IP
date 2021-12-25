unit UPing;

interface

function Ping(Address:RawByteString):Boolean;

implementation

uses
  Windows, Winsock, SysUtils;

const
  IP_STATUS_BASE=11000;
  IP_SUCCESS=0;
  IP_BUF_TOO_SMALL=11001;
  IP_DEST_NET_UNREACHABLE=11002;
  IP_DEST_HOST_UNREACHABLE=11003;
  IP_DEST_PROT_UNREACHABLE=11004;
  IP_DEST_PORT_UNREACHABLE=11005;
  IP_NO_RESOURCES=11006;
  IP_BAD_OPTION=11007;
  IP_HW_ERROR=11008;
  IP_PACKET_TOO_BIG=11009;
  IP_REQ_TIMED_OUT=11010;
  IP_BAD_REQ=11011;
  IP_BAD_ROUTE=11012;
  IP_TTL_EXPIRED_TRANSIT=11013;
  IP_TTL_EXPIRED_REASSEM=11014;
  IP_PARAM_PROBLEM=11015;
  IP_SOURCE_QUENCH=11016;
  IP_OPTION_TOO_BIG=11017;
  IP_BAD_DESTINATION=11018;
  IP_ADDR_DELETED=11019;
  IP_SPEC_MTU_CHANGE=11020;
  IP_MTU_CHANGE=11021;
  IP_UNLOAD=11022;
  IP_GENERAL_FAILURE=11050;
  IP_PENDING=11255;

  MAX_IP_STATUS=IP_GENERAL_FAILURE;

type
  ip_option_information = packed record       // Информация заголовка IP (Наполнение
                                              // этой структуры и формат полей описан в RFC791.
      Ttl : byte;                                   // Время жизни (используется traceroute-ом)
      Tos : byte;                                   // Тип обслуживания, обычно 0
      Flags : byte;                             // Флаги заголовка IP, обычно 0
      OptionsSize : byte;                         // Размер данных в заголовке, обычно 0, максимум 40
      OptionsData : Pointer;                    // Указатель на данные
  end;

 icmp_echo_reply = packed record
      Address : u_long;                            // Адрес отвечающего
      Status : u_long;                           // IP_STATUS (см. ниже)
      RTTime : u_long;                           // Время между эхо-запросом и эхо-ответом
                                               // в миллисекундах
      DataSize : u_short;                        // Размер возвращенных данных
      Reserved : u_short;                        // Зарезервировано
      Data : Pointer;                            // Указатель на возвращенные данные
      Options : ip_option_information;         // Информация из заголовка IP
  end;

  PIPINFO = ^ip_option_information;
  PVOID = Pointer;

  function IcmpCreateFile() : THandle; stdcall; external 'ICMP.DLL' name 'IcmpCreateFile';
  function IcmpCloseHandle(IcmpHandle : THandle) : BOOL; stdcall; external 'ICMP.DLL'  name 'IcmpCloseHandle';
  function IcmpSendEcho(
                    IcmpHandle : THandle;    // handle, возвращенный IcmpCreateFile()
                    DestAddress : u_long;    // Адрес получателя (в сетевом порядке)
                    RequestData : PVOID;     // Указатель на посылаемые данные
                    RequestSize : Word;      // Размер посылаемых данных
                    RequestOptns : PIPINFO;  // Указатель на посылаемую структуру
                                             // ip_option_information (может быть nil)
                    ReplyBuffer : PVOID;     // Указатель на буфер, содержащий ответы.
                    ReplySize : DWORD;       // Размер буфера ответов
                    Timeout : DWORD          // Время ожидания ответа в миллисекундах
                   ) : DWORD; stdcall; external 'ICMP.DLL' name 'IcmpSendEcho';



function PingIp(Address:RawByteString):Boolean;
var
  hIP : THandle;
  pingBuffer : array [0..31] of Char;
  pIpe : ^icmp_echo_reply;
  wVersionRequested : WORD;
  lwsaData : WSAData;
  error : DWORD;
  destAddress : In_Addr;
begin
  Result:=False;
  hIP := IcmpCreateFile();
  GetMem( pIpe,
          sizeof(icmp_echo_reply) + sizeof(pingBuffer));
  try
    pIpe.Data := @pingBuffer;
    pIpe.DataSize := sizeof(pingBuffer);

    wVersionRequested := MakeWord(1,1);
    error := WSAStartup(wVersionRequested,lwsaData);
    if (error <> 0) then
    begin
      Exit;
    end;
    destAddress.S_addr:=inet_addr(PAnsiChar(Address));
    IcmpSendEcho(hIP,
                 destAddress.S_addr,
                 @pingBuffer,
                 sizeof(pingBuffer),
                 Nil,
                 pIpe,
                 sizeof(icmp_echo_reply) + sizeof(pingBuffer),
                 5000);

    error := GetLastError();
    if (error <> 0) then
    begin
      Exit;
    end;
    Result:=pIpe.Status=IP_SUCCESS;
  finally
    IcmpCloseHandle(hIP);
    WSACleanup();
    FreeMem(pIpe);
  end;
end;

function HostToIP(name: RawByteString; var Ip: RawByteString): Boolean;
var
  wsdata : TWSAData;
  hostName : array [0..255] of ansichar;
  hostEnt : PHostEnt;
  addr : PAnsiChar;
begin
  WSAStartup ($0101, wsdata);
  try
    gethostname (@hostName[0], sizeof (hostName));
    StrPCopy(hostName, name);
    hostEnt := gethostbyname (hostName);
    if Assigned (hostEnt) then
      if Assigned (hostEnt^.h_addr_list) then begin
        addr := hostEnt^.h_addr_list^;
        if Assigned (addr) then begin
          IP := Format ('%d.%d.%d.%d', [byte (addr [0]),
          byte (addr [1]), byte (addr [2]), byte (addr [3])]);
          Result := True;
        end
        else
          Result := False;
      end
      else
        Result := False
    else begin
      Result := False;
    end;
  finally
    WSACleanup;
  end
end;

function Ping(Address:RawByteString):Boolean;
var
  s:RawByteString;

begin
  Result:=HostToIP(Address,s);
  if Result then
    Result:=PingIp(s);
end;


end.
