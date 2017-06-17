unit backgnd;

interface

uses dos;

procedure setup_background(port: integer);
procedure enqueue_dequeue_test;
function enqueue(c: byte): boolean;

implementation

const
  OUTBUF_SIZE = 256;
var
  sp0256_port: integer;
  old_exitproc, old_int1c: Pointer;
  outbuf: array[0..(OUTBUF_SIZE-1)] of byte;
  outbuf_in, outbuf_out: integer;
  outbuf_count: integer;
  last_code: byte;
  idle_count: integer;

procedure background_exithandler; far;
begin;
  ExitProc := old_exitproc;
  if old_int1c <> NIL then begin;
      writeln('Terminating background handler');
      setintvec($1C, old_int1c);
      old_int1c:=NIL;
  end;
end;

function enqueue(c: byte): boolean;
begin
  asm CLI end;
  if (outbuf_count = OUTBUF_SIZE) then begin;
     enqueue := FALSE;
  end else begin;
     outbuf[outbuf_in] := c;
     outbuf_in:=outbuf_in+1;
     outbuf_count := outbuf_count + 1;
     if (outbuf_in = OUTBUF_SIZE) then outbuf_in := 0;
     enqueue := TRUE;
  end;
  asm STI end;
end;

function dequeue(var c: byte): boolean;
begin
  asm CLI end;
  if (outbuf_count = 0) then begin;
    dequeue:=FALSE;
  end else begin;
    c := outbuf[outbuf_out];
    outbuf_out := outbuf_out + 1;
    outbuf_count := outbuf_count - 1;
    if (outbuf_out = OUTBUF_SIZE) then outbuf_out := 0;
    dequeue:=TRUE;
  end;
  asm STI end;
end;

{$F+}
procedure background_handler; interrupt;
var
  code: byte;
begin
  if ((port[sp0256_port] and 2) <> 2) then begin
     if dequeue(code) then begin
        port[sp0256_port] := code;
        last_code:=code;
        idle_count:=0;
     end else begin;
       { check to see if speech was left running without a terminating pause }
       if (last_code>5) then begin
         idle_count:=idle_count+1;
         if (idle_count>10) then begin
           { terminate speech }
           port[sp0256_port] := 0;
           last_code:=0;
         end;
       end;
     end;
  end;

  { call saved handler }
  asm
    PUSHF
    CALL old_int1c
  end;
end;
{$F-}

procedure setup_background(port: integer);
begin;
  outbuf_in:=0;
  outbuf_out:=0;
  outbuf_count:=0;
  last_code:=0;
  idle_count:=0;
  sp0256_port:=port;
  old_int1c := NIL;
  old_exitproc := ExitProc;
  ExitProc := @background_exithandler;
  GetIntVec($1C, old_int1c);
  SetIntVec($1C, @background_handler);
end;

{ quick test of the enqueue/dequeue on the ring buffer }
procedure enqueue_dequeue_test;
var
 i,dqc: integer;
 v: byte;
 last: byte;
 junk: boolean;
begin;
 last:=0;
 dqc:=0;
 for i:=1 to 10000 do begin;
    junk:=enqueue(i);
    if ((i mod 7) = 2) or (i=10000) then begin;
        while dequeue(v) do begin;
          if (v<>((last+1) mod 256)) then begin;
              writeln('error', v);
          end;
          dqc:=dqc+1;
          last:=v;
        end;
    end;
 end;
 if (dqc <> 10000) then begin
     writeln('bad dequeue count', dqc);
 end;
end;

begin
  old_exitproc := NIL;
  old_int1c := NIL;
end.
