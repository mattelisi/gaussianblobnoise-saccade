function repchar(file,oriChar,newChar)
% 
% function repchar(file,oriChar,newChar)
%
% replaces an original character in a
% complete file with a new one.
%
% by Martin Rolfs

tempFile = 'tempFile';

infid = fopen(file,'r');
tefid = fopen(tempFile,'w');

while ~feof(infid)
    str = fgetl(infid);
    str(find(str==oriChar))=newChar;
    
    fprintf(tefid,'%s\n',str);
end
fclose(infid);
fclose(tefid);

cmd = sprintf('mv tempFile %s',file);
unix(cmd);
