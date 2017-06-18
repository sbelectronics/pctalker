{ SAY.PAS

  Scott Baker, http://www.smbaker.com

  This is the main file for the SP0256A-AL2 demo. It implements command
  line parsing and calls the other units as necessary. Use the '-H'
  command line option for help.
}

{$M 4096,0,0 }

uses talker, prncap, dos;

type
  TArgs = record
           driver: TOutputDriver;
           port: integer;
           say: string;
           filename: string;
           prncap: boolean;
         end;
var
  args: TArgs;

procedure show_banner;
begin
  writeln('SP0256A-AL2 driver, by Scott M. Baker');
  writeln('http://www.smbaker.com/');
end;

procedure show_help;
begin
  writeln('syntax: SAY.EXE [args] <phonemes>');
  writeln('args:');
  writeln('   -D         direct output');
  writeln('   -B         background output');
  writeln('   -P <port>  specify port number');
  writeln('   -L         capture LPT3: and terminate and stay resident');
  writeln('examples:');
  writeln('   "SAY.EXE SS KK2 AO TT1"    ... output phonemes to console');
  writeln('   "SAY.EXE -D SS KK2 AO TT1" ... output phonemes to sp0256');
  writeln('   "SAY.EXE -B -L"            ... attach to lpt3: and TSR');
end;

procedure parse_args;
var
  i,code: integer;
  cmd: char;
  param: string;
begin
  args.driver:=OutputConsole;
  args.port:=$120;
  args.say:='';
  args.filename:='';
  args.prncap:=false;
  i:=1;
  if (ParamCount<1) then begin
    show_help;
    halt;
  end;
  while (i<=ParamCount) do begin
    param:=ParamStr(i);
    if (length(param)>1) and ((param[1]='-') or (param[1]='/')) then begin
      cmd:=upcase(param[2]);
      if cmd='D' then begin
          args.driver:=OutputDirect;
      end else if cmd='B' then begin
          args.driver:=OutputBackground;
      end else if cmd='P' then begin
          val(ParamStr(i+1), args.port, code);
          i:=i+1;
      end else if cmd='F' then begin
          args.filename:=ParamStr(i+1);
          i:=i+1;
      end else if cmd='L' then begin
          args.prncap:=true;
      end else if cmd='H' then begin
          show_help;
          halt;
      end;
    end else begin
       if args.say <> '' then args.say:=args.say+' ';
       args.say := args.say + ParamStr(i);
    end;
    i:=i+1;
  end;
end;

procedure say_file(fn: string);
var
  f: text;
  s: string;
begin
  assign(f, fn);
  reset(f);
  while not eof(f) do begin
      readln(f, s);
      say_string(s);
  end;
end;

begin;
  show_banner;
  parse_args;

  if args.driver=OutputConsole then begin
     writeln;
     writeln('Note - Console driver is selected. No speech will be heard.');
     writeln('       Use -H for help');
     writeln;
  end;

  talker_setup(args.driver, args.port);
  if args.say<>'' then say_string(args.say);
  if args.filename<>'' then say_file(args.filename);

  { stop speech }
  if (args.say<>'') or (args.filename<>'') then begin
    say_phoneme('PA4');
    if (args.driver = OutputBackground) then begin
      writeln('press enter');
      readln;
    end;
  end;

  if args.prncap then begin
    setup_prncap;
    writeln('terminate and stay resident.');
    keep(0);
  end;
end.