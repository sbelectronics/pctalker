uses prncap, dos;

begin;
   setup_prncap;
   Exec('command.com', '/C test.bat');
   writeln(DosError, ' ', DosExitCode);
   readln;
end.