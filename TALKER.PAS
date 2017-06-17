unit talker;

interface

uses crt, dos, backgnd;

type
 TOutputDriver = (OutputConsole, OutputDirect, OutputBackground);

procedure talker_setup(adriver: TOutputDriver; aport: integer);
procedure parse_char(c: char);
procedure parse_delim;
procedure say_string(s: string);
procedure say_phoneme(s: string);

implementation

type
  TPhoneme = Record
              symbol: string[3];
              code: integer;
             end;
var
  sym: string; { current symbol being parsed }
  sp0256_port: integer;
  driver: TOutputDriver;
  phoneme_lookup: array[0..63] of TPhoneme;

procedure sort(l, r: integer);
var
  i,j: integer;
  x: string;
  y: TPhoneme;
begin
  i:=l; j:=r; x:=phoneme_lookup[(l+r) div 2].symbol;
  repeat;
    while phoneme_lookup[i].symbol < x do i:=i+1;
    while x < phoneme_lookup[j].symbol do j:=j-1;
    if i<=j then begin
      y:=phoneme_lookup[i];
      phoneme_lookup[i]:=phoneme_lookup[j];
      phoneme_lookup[j]:=y;
      i:=i+1;
      j:=j-1;
    end;
  until i>j;
  if l<j then sort(l,j);
  if i<r then sort(i,r);
end;

procedure setup_phonemes;
var
  phonemes: array[0..63] of string[3];
  i: integer;
begin
  phonemes[0]:='PA1';
  phonemes[1]:='PA2';
  phonemes[2]:='PA3';
  phonemes[3]:='PA4';
  phonemes[4]:='PA5';
  phonemes[5]:='OY';
  phonemes[6]:='AY';
  phonemes[7]:='EH';
  phonemes[8]:='KK3';
  phonemes[9]:='PP';
  phonemes[10]:='JH';
  phonemes[11]:='NN1';
  phonemes[12]:='IH';
  phonemes[13]:='TT2';
  phonemes[14]:='RR1';
  phonemes[15]:='AX';
  phonemes[16]:='MM';
  phonemes[17]:='TT1';
  phonemes[18]:='DH1';
  phonemes[19]:='IY';
  phonemes[20]:='EY';
  phonemes[21]:='DD1';
  phonemes[22]:='UW1';
  phonemes[23]:='AO';
  phonemes[24]:='AA';
  phonemes[25]:='YY2';
  phonemes[26]:='AE';
  phonemes[27]:='HH1';
  phonemes[28]:='BB1';
  phonemes[29]:='TH';
  phonemes[30]:='UH';
  phonemes[31]:='UW2';
  phonemes[32]:='AW';
  phonemes[33]:='DD2';
  phonemes[34]:='GG3';
  phonemes[35]:='VV';
  phonemes[36]:='GG1';
  phonemes[37]:='SH';
  phonemes[38]:='ZH';
  phonemes[39]:='RR2';
  phonemes[40]:='FF';
  phonemes[41]:='KK2';
  phonemes[42]:='KK1';
  phonemes[43]:='ZZ';
  phonemes[44]:='NG';
  phonemes[45]:='LL';
  phonemes[46]:='WW';
  phonemes[47]:='XR';
  phonemes[48]:='WH';
  phonemes[49]:='YY1';
  phonemes[50]:='CH';
  phonemes[51]:='ER1';
  phonemes[52]:='ER2';
  phonemes[53]:='OW';
  phonemes[54]:='DH2';
  phonemes[55]:='SS';
  phonemes[56]:='NN2';
  phonemes[57]:='HH2';
  phonemes[58]:='OR';
  phonemes[59]:='AR';
  phonemes[60]:='YR';
  phonemes[61]:='GG2';
  phonemes[62]:='EL';
  phonemes[63]:='BB2';

  for i:= 0 to 63 do begin
     phoneme_lookup[i].symbol := phonemes[i];
     phoneme_lookup[i].code := i;
  end;

  sort(0,63);
end;

function find_phoneme(s: string): integer;
var
  lo, hi, m: integer;
begin;
  lo:=0;
  hi:=63;
  while (lo <> hi) do begin;
    m:=(lo+hi) DIV 2;
    if phoneme_lookup[m].symbol < s then
      lo:=m+1
    else
      hi:=m;
  end;

  if (phoneme_lookup[lo].symbol <> s) then
    find_phoneme:= -1
  else
    find_phoneme:= phoneme_lookup[lo].code;
end;

procedure output_direct(code: integer);
var
  v: integer;
begin;
  while ((port[sp0256_port] and 2) = 2) do begin;
     { busy wait }
  end;
  port[sp0256_port] := code;
end;

procedure output_background(code: integer);
var
  i: integer;
begin
  i:=0;
  while not enqueue(code) do begin
    Delay(100);
    i:=i+1;
    if (i>25) then begin;
        writeln('Timeout waiting for enqueue');
        Halt;
    end;
  end;
end;


procedure say_phoneme(s: string);
var
  code: integer;
begin;
  code := find_phoneme(s);
  if code >= 0 then begin;
     case driver of
       OutputConsole: write(code, ' ');
       OutputDirect: output_direct(code);
       OutputBackground: output_background(code);
     end;
  end;
end;

procedure parse_delim;
begin
  if sym <> '' then begin;
      say_phoneme(sym);
      sym := '';
  end;
end;

procedure parse_char(c: char);
begin;
   if (c=' ') or (c=chr(10)) or (c=chr(13)) then begin;
      parse_delim;
   end else begin;
      if length(sym)<255 then begin
          sym := sym + c;
      end;
   end;
end;

procedure say_string(s: string);
var
  i: integer;
begin
  for i:=1 to length(s) do parse_char(s[i]);
  parse_delim;
end;


procedure talker_setup(adriver: TOutputDriver; aport: integer);
begin
{  enqueue_dequeue_test; }

  driver:=adriver;
  sp0256_port:=aport;
  sym:='';
  setup_phonemes;

  if (driver = OutputBackground) then begin
      setup_background(aport);
  end;
end;

end.
