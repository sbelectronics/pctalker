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

procedure parse_args;
var
  i,code: integer;
begin;
  args.driver:=OutputConsole;
  args.port:=$120;
  args.say:='';
  args.filename:='';
  args.prncap:=false;
  i:=1;
  while (i<=ParamCount) do begin;
    if ParamStr(i)='-D' then begin;
        args.driver:=OutputDirect;
    end else if ParamStr(i)='-B' then begin;
        args.driver:=OutputBackground;
    end else if ParamStr(i)='-P' then begin;
        val(ParamStr(i+1), args.port, code);
        i:=i+1;
    end else if ParamStr(i)='-F' then begin;
        args.filename:=ParamStr(i+1);
        i:=i+1;
    end else if ParamStr(i)='-L' then begin;
        args.prncap:=true;
    end else begin;
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
  parse_args;
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