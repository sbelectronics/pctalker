{ PRNCAP.PAS
  Scott Baker, http://www.smbaker.com/

  This unit implements a mechanism for capturing the lpt3: printer. It
  does this by attaching itself to BIOS interrupt 17h.
}

unit prncap;

interface

uses crt, dos, talker;

procedure setup_prncap;

implementation

var
  old_exitproc: Pointer;
  old_int17: Pointer;
  SavedSS, SavedSP: Word;
  OurSS, OurSP: Word;
  thechar: char; { character to write }

procedure printer_exithandler; far;
begin;
  ExitProc := old_exitproc;
  if old_int17 <> NIL then begin;
      writeln('Terminating printer handler');
      setintvec($17, old_int17);
      old_int17:=NIL;
  end;
end;

procedure handle_char;
begin
  asm
    CLI
  end;
  SavedSS:=SSeg;
  SavedSP:=SPtr;
  asm
    MOV SS, OurSS
    MOV SP, OurSP
    STI
  end;
  parse_char(thechar);
  asm
    CLI
    MOV SS, SavedSS
    MOV SP, SavedSP
    STI
  end;
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
       thechar := chr(al); { must pass this in a global }
       handle_char;        { ... because handle_char uses new stack }
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
  old_int17 := NIL;
  old_exitproc := ExitProc;
  ExitProc := @printer_exithandler;
  GetIntVec($17, old_int17);
  SetIntVec($17, @printer_handler);
  OurSS := SSeg;
  OurSP := SPtr;
end;

begin;
end.