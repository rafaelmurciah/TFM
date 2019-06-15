%This function applies the FDAC function to all the files of a
%given folder. Its variables are:
%   infolderCFDAC: String of the folder where the FRFs are.
%   outfolderCFDAC: String of the folder in which the results are stored.
%   original: Reference sample.
function []= folderCFDAC(infolderCFDAC, outfolderCFDAC, original)

%Here are the 'instances' of the method. Variables that were preferred to
%leave inside the method instead of put as input variables.
startFreq=0;
delta=0.5;

  
listing = dir(fullfile(infolderCFDAC,'*.mat'));
l = length(listing);
%loop to extract the name from the path of each file
for j=1:1:l;
    list{j} = [infolderCFDAC '\' listing(j).name];
    llist{j} = listing(j).name; 
end
clear listing

for j=1:1:l
    %Load file
    load(list{j})
    %Do the CFDAC
    [CFDAC]=CFDACm([startFreq:delta:3200],FRFsMatrix_synth,original,startFreq,3200,delta,2);
    %Save the CFDAC
    save([outfolderCFDAC '\' llist{j} 'CFDAC.mat'],'CFDAC');

end
end