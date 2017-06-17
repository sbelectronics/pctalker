unit prncap;

interface

uses dos;

procedure setup_prncap;

implementation

var
  cap: string;
  old_exitproc: Pointer;
  old_int17: Pointer;

procedure printer_exithandler; far;
begin;
  ExitProc := old_exitproc;
  if old_int17 <> NIL then begin;
      writeln('Terminating printer handler');
      setintvec($17, old_int17);
      old_int17:=NIL;
  end;
  writeln('cap ', cap);
end;

{$F+}
procedure printer_handler (_AX, _BX, _CX, _DX, _SI, _DI, _DS, _ES, _BP: Word); interrupt;
var
 ah, al: byte;
begin
  if (_dx=2) then begin
    ah:=HI(_AX);
    al:=LO(_AX);
    if (ah=0) then begin;
       { print char }
       cap:=cap+chr(al);
       _AX:=0;
    end else if (ah=1) then begin;
       { initialize }
       _AX:=0;
    end else if (ah=2) then begin;
       { get status }
       _AX:=0;
    end;
  end else begin
    { call the old printer interrupt}
    asm
      mov ax, _AX
      mov dx, _DX
      pushf
      call old_int17
      mov _AX, ax
    end;
  end;
end;
{$F-}

procedure setup_prncap;
begin;
  cap:='';
  old_int17 := NIL;
  old_exitproc := ExitProc;
  ExitProc := @printer_exithandler;
  GetIntVec($17, old_int17);
  SetIntVec($17, @printer_handler);
end;

begin;
end.