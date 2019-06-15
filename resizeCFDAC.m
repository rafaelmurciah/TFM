%This function resizes the FDACs of a given folder. Its variables are:
%   inputpCFDAC: String of the folder where the FDACs are.
%   outputReCFDAC: String of the folder in which the results are stored.
%   size: number of rows and columns of the resized FDAC
function resizeCFDAC (inputReCFDAC, outputReCFDAC,size)


listing = dir(fullfile(inputReCFDAC,'*.mat'));
len = length(listing);
%loop to extract the name from the path of each file
for j=1:1:len;
    list{j} = [inputReCFDAC '\' listing(j).name];
    llist{j} = listing(j).name; 
end
clear listing

for j=1:1:len
    %Load file
    load(list{j})
    %Do the CFDAC
    CFDACx=CFDAC;
    clear CFDAC
    %resize the FDAC
    CFDAC=imresize(CFDACx,[size size]);
    %Save the CFDAC
    save([outputReCFDAC '\' llist{j} 'CFDAC.mat'],'CFDAC');

end

end