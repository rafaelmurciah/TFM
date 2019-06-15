%This function applies the  FRF Synthesis function to all the files of a
%given folder for every driving point, and later applies the CFDAC function
%to all of them, finally storing the results in a folder
%   infolderAllDrvpts: String of the folder where the UMMs are.
%   outfolderAllDrvpts: String of the folder in which the results are stored.
function exeAllDrvpts(infolderAllDrvpts,outfolderAllDrvpts)

%Here are the 'instances' of the method. Variables that were preferred to
%leave inside the method instead of put as input variables.
topDvpt=81;
delta=0.5;
startFreq=0;

listing = dir(fullfile(infolderAllDrvpts,'*.mat'));
len = length(listing);
%loop to extract the name from the path of each file
for j=1:1:len;
    list{j} = [infolderAllDrvpts '\' listing(j).name];
    llist{j} = listing(j).name; 
end
clear listing

%for every driving point
for dvpt=1:1:topDvpt
   %get undamaged sample
   [fr,original]=FRFSynthesis_strip(list{1},3200,delta,20.23142,8.026066E-8,[1:1:81],dvpt,'');
   %for every sample
   for j=1:1:len
       %do synthesis and FDAC
       [fr,tempSynth]=FRFSynthesis_strip(list{j},3200,delta,20.23142,8.026066E-8,[1:1:81],dvpt,'');
       [CFDAC]=CFDACm([startFreq:delta:3200],tempSynth,original,startFreq,3200,delta,2);
       
       %Some crack results for high driving points happened to be all NaN
       if ~isnan(CFDAC(2,2))           
            save([outfolderAllDrvpts '\' num2str(dvpt) llist{j} 'CFDAC.mat'],'CFDAC');
       end
   end 
end
end