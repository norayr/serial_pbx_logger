{$mode delphi}
program serial;
Uses synaser, args, sysutils, strutils;
var ser : TBlockSerial;
s, filename : string;
baud, bits, stopbits : integer;
waittime : longint;
softflow, hardflow, all{, writeseparate }: boolean;
parity : char;

function isinteger( some : string) : boolean;
var i : integer;
begin
isinteger := true;
for i := 1 to length(some) do begin
if not (some[i] in ['0'..'9']) then begin isinteger := false; exit end;
end;
end;

procedure serialportbydefault;
begin
                            s := '/dev/ttyS0';
			    writeln ('command line argument for serial port not found');
			    writeln ('assuming by default that serial port is ',s);
			        if copy(s,1,8) <> '/dev/tty' then begin
				                                  writeln;
								  writeln ('WARNING');
								  writeln ('in Linux, as a rule, serial ports called like "/dev/tty*"');
								  writeln ('for instance, "/dev/ttyS0" meand first serial port');
								  writeln;
								  writeln ('if you are using this program under other operating system');
								  writeln ('not Linux, then just check if what you have written');
								  writeln ('and safely ignore this message');
								  writeln;
								  end;
end;

procedure baudratebydefault;
begin
                            baud := 1200;
			    writeln ('command line argument for baud rate not found');
			    writeln ('assuming by default that baud rate is ', baud);
end;

procedure bitsbydefault;
begin
                            bits := 8;
			    writeln ('command line argument for bits not found');
			    writeln ('assuming by default that bits is ', bits);
end;

procedure paritybydefault;
begin
                            parity := 'N';
			    writeln ('command line argument for parity not found');
			    writeln ('assuming by default that Parity is None ');
end;

procedure stopbitsbydefault;
begin
                            stopbits := 1;
			    writeln ('command line argument for stop bits not found');
			    writeln ('assuming by default that stop bits is ', stopbits);
end;

procedure filenamebydefault;
begin
                            filename := 'pbx';
			    writeln ('command line argument for file name not found');
			    writeln ('assuming by default that file name is ', filename);
end;
{
procedure writeseparatebydefault;
begin
 writeln ('argument to write also separate logs for each source phone number not found');
 writeln ('will not write separate files by default');
 writeseparate := false;
end;
}
procedure ParseArgs;
var st : string;
begin
WriteLn ('Parsing command line arguments');
 if args.isthere('-s') then begin
                            s := args.ParamValue ('-s');
                            WriteLn (' Serial port: ',s);
			    end
                           else
			    begin
    								serialportbydefault;
			    end;
 if args.isthere('-B') then begin
                            st := args.ParamValue ('-B');
			                        if isinteger(st) then begin
                                                                      baud := StrToInt (st);
								      end
								      else
								      begin
								      writeln ('error: command line argument for baud rate is not correct');
								      writeln ('please, write integer value instead of "',st,'"');
								      halt;
								      end;
			    WriteLn (' Baud rate: ', baud);
			    end
			    else
			    begin
			    baudratebydefault;
			    end;
 if args.isthere('-b') then begin
                            st := args.ParamValue ('-b');
			                        if isinteger(st) then begin
                                                                      bits := StrToInt (st);
								      end
								      else
								      begin
								      writeln ('error: command line argument for baud rate is not correct');
								      writeln ('please, write integer value instead of "',st,'"');
								      halt;
								      end;
			    WriteLn (' Bits: ', bits);
			    end
			    else
			    begin
			    bitsbydefault;
			    end;
 if args.isthere('-p') then begin
                            st := args.ParamValue ('-p');
			                                   if not st in ['N','O','E','M','S'] then begin
							   writeln;
							   writeln ('error: Parity value should be in "N","O","E","M" or "S"');
							   halt
							   end;
			                     
			    parity := st[1];
			    WriteLn (' Parity: ', parity);
			    end
			    else
			    begin
				paritybydefault;
end;
 if args.isthere('-S') then begin
                            st := args.ParamValue ('-S');
			                        if isinteger(st) then begin
                                                                      stopbits := StrToInt (st);
								      end
								      else
								      begin
								      writeln ('error: command line argument for stop bits is not correct');
								      writeln ('please, write integer value instead of "',st,'"');
								      halt;
								      end;
			    WriteLn (' Stop Bits: ', stopbits);
			   end
			   else
			   begin
					stopbitsbydefault;
				end;
 if args.isthere('-f') then begin
                            filename := args.ParamValue ('-f');
			    WriteLn (' File Name: ', filename);
			    end
			    else
			    begin
			    filenamebydefault;
		            end;
{
if args.IsThere ('-N') then begin
 writeln ('command line argument to write also separate logs for each source phone number is found');
 writeseparate := true;
  end
 else
  begin
 writeseparatebydefault;
 end;
}
end {parseargs};

procedure assumedefaultparams;
begin
serialportbydefault;
baudratebydefault;
bitsbydefault;
paritybydefault;
stopbitsbydefault;
filenamebydefault;
//writeseparatebydefault;
end;

procedure showhelp;

begin
writeln;
writeln (' Serial PBX Logger v 1.0');
writeln ('(c) Copyright 2006 by Norayr Chilingaryan aka roni');
writeln;
writeln (' distributed under GPL-2 which could be found at www.gnu.org');
writeln;
writeln ('Usage:');
writeln ('serialpbxlogger [-s serial port name] [-B baud rate] [-b bits] [-p parity] [-S stopbits] [-f path to output file] -N');
writeln;
writeln (' -s  serial port name');
writeln ('      for linux may be like /dev/ttyS0 or /dev/ttyS1');
writeln ('      for windows may be like COM1 or COM2 though I am not sure, have not tested on win');
writeln;
writeln (' -B  baud rate');
writeln ('      by default assumed 1200 ');
writeln;
writeln (' -b bits');
writeln ('     by default assumed 8');
writeln;
writeln (' -p parity');
writeln ('     could be N - for None');
writeln ('              O - for Odd');
writeln ('              E - for Even');
writeln ('              M - for Mark');
writeln ('              S - for Space');
writeln;
writeln (' -S  stop bits');
writeln ('      by default assumed 1');
writeln;
writeln (' -f  path to csv (comma-separated values) file');
writeln ('     may be full');
writeln ('     if not mentioned then by default assumed pbx-date.csv in current directory');
writeln ('     if file already exists then program will not overwrite it but continue instead');
writeln;
{
writeln (' -N  write also separate log for any source phone number');
writeln ('     in case file already exists it will be continiued');
writeln;
}
writeln (' -h or --help show help message (this)');
writeln;
end {showhelp};

procedure readdata;
var f : textfile;
name : string;
m,y : string;
rr : boolean;
i,k : integer;
begin
//baud := 1200;
//bits := 8;
//parity := 'N';
//stopbits := 1;
softflow := false;
hardflow := true;
waittime := 1000000{3600000};
ser := TBlockSerial.Create;
//s := GetSerialPortNames;
//writeln (s);
ser.Connect (s);
ser.config (baud, bits, parity, stopbits, softflow, hardflow);
all := false;
repeat
	s := 'abracadabra';
	s := ser.RecvString (waittime);
	if s <> 'abracadabra' then
	          begin
                  writeln ('I have got call');
		  writeln (s);
		  k :=  WordCount (s,[' ']);
		        m := FormatDateTime ('mm',sysutils.Date);
                        y := FormatDateTime ('yyyy',sysutils.Date);
		        name := filename + '-' + m + '-' + y + '.csv';
			If FileExists(name) then rr := false else rr := true;
			Assign (f, name);
			if rr then rewrite(f) else append(f);

                  for i := 1 to k do begin
                             Write (f, '"' + ExtractWord (i, s, [' ']) + '"');
			     IF i < k then Write (f,',');
			     IF i = k then Writeln (f,' ');
		  end;
		            Close(f);
{
107 02 0:00:13 17:19 09/20/09 O 093272665

107 01 0:00:19 17:19 09/20/09 O 512436
}
		  end {if};
until all;
ser.free;

end;


begin

if args.IsThereArgs then begin
			 	ParseArgs
			 end
			else
			 begin
			 	showhelp;
				assumedefaultparams;
			 end;

readdata;

end.

