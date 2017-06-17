{$M 8192,0,0}
uses prncap, dos;

{procedure LPT3;
begin
inline($58/$5A/$50/$8B/$C2/$B4/$00/$BA/$02/$00/$55/$CD/$17/$5D/$C3);
end;}

begin;
   setup_prncap;
   Exec('c:\dos\command.com', '/C test.bat');
   writeln(DosError, ' ', DosExitCode);
   readln;
end.