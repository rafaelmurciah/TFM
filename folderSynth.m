%This function applies the  FRF Synthesis function to all the files of a
%given folder. Its variables are:
%   infolderCFDAC: String of the folder where the UMMs are.
%   outfolderCFDAC: String of the folder in which the results are stored.
function []= folderSynth(infolder, outfolder)

% List the case directories in the pathin_folder folder
   
    
    listing = dir(fullfile(infolder,'*.mat'));
    l = length(listing);
    %loop to extract the name from the path of each file
    for j=1:1:l;
        list{j} = [infolder '\' listing(j).name];
        llist{j} = listing(j).name; 
    end
    clear listing
    
    for j=1:1:l
           %Do the synthesis
            [Frequency, FRFsMatrix_synth, rovingdof, drivingdof] =...
                FRFSynthesis_strip(list{j},3200,0.5,20.23142,8.026066E-8,[1:1:81],30,outfolder);
    end


end