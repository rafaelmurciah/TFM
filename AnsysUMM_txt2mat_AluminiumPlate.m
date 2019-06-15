%Not written by Rafael Murcia
function [] = AnsysUMM_txt2mat_AluminiumPlate(pathin_folder, pathout_folder)

%--------------------------------------------------------------------------
% This function reads all the *.txt modal shapes result files exported by a
% APDL routine in ANSYS project and located certain folder pathin_folder.
%
% 
% Input variables:
%   pathin_folder: full path to the folder containing APDL exported
%                   individual modeshape files.
%   pathout_folder: full path to the folder that will contain the *.mat
%                   files to save the reduced modal data
%   a: first damping coefficient
%   b: second damping coefficient
% 
% Example of usage
% 	pathin_folder = 'D:\PhD_SHM\AluminiumPlate\RawData\Ansys\ShapesUMM'
% 	pathout_folder = 'D:\PhD_SHM\AluminiumPlate\MatData\Ansys\ShapesUMM'
% 	AnsysUMM_txt2mat_AluminiumPlate(pathin_folder,pathout_folder)
%
%--------------------------------------------------------------------------


%     %MESH OF 9x9 nodes
%     %Initialize variables
    X = ones(9,9);
    Y = ones(9,9);    
    Z = zeros(9,9);    %mid plane points
    %Set different unique values
    xpos = [30:30:270];
    %xpos = [0.03:0.03:0.27];
    ypos = flipdim(xpos,2);
    %Generate regular mesh
    for l=1:1:9
        X(l,:)= xpos;
        Y(:,l)= ypos;
    end
    %Reshape mesh to a single column format
    ExpX = reshape(X',[81,1]);
    ExpY = reshape(Y',[81,1]);
    ExpZ = reshape(Z',[81,1]);
    clear X Y Z

% List the case directories in the pathin_folder folder
    casefolders = dir(pathin_folder);
    idfolder = [casefolders(:).isdir];
    namefolders = {casefolders(idfolder).name}';
    namefolders(ismember(namefolders,{'.','..'})) = [];
   
    
% Loop for each case and store the variables
    for i = 1:1:length(namefolders)
        %get all the *.dat files in the directory
        listing = dir(fullfile([pathin_folder '\' namefolders{i}],'*.dat'));
        %get number of independent files in each case folder
        l = length(listing);
        %loop to extract the name from the path of each file
        for j=1:1:l;
            list{j} = [pathin_folder '\' namefolders{i} '\' listing(j).name];
            llist{j} = listing(j).name; 
        end
        clear listing 
        
        %Start reading variables
        for j=1:1:l
            %Read first line: ModalFreq and MPF
            fid = fopen(list{j});
            line = fgetl(fid);
            [~,remain] = strtok(line,' ');
            [strfreq,remain] = strtok(remain,' ');
            [strModalMass,remain] = strtok(remain,' ');
            [strModalStiff,~] = strtok(remain,' ');
            fclose(fid);
            
            %Read all lines in file starting in the second line
            datastruct = importdata(list{j},' ',1);
            
            if j==1
                %Generate modal data to be saved
                FemX = datastruct.data(:,2);
                FemY = datastruct.data(:,3);
                FemZ = datastruct.data(:,4);

                %Match DoFs from ANSYS with the Experimental Mesh         
                loc = zeros(1,length(ExpX));
                dist = zeros(1,length(datastruct.data(:,5)));

                %For experimental nodes, get distance to all numeric nodes    
                for l=1:1:length(ExpX)                      
                    for k=1:1:length(datastruct.data(:,5))  
                        

                        dist(1,k)= sqrt(...
                            (ExpX(l)-FemX(k))^2 + ...
                            (ExpY(l)-FemY(k))^2 + ...
                            (ExpZ(l)-FemZ(k))^2);
                    end
                    %locate the index corresponding to the minimum distance
                    [~,idx] = min(dist);                           
                    loc(1,l)=idx;
                end
            end
            
            %Generate full mesh modal data
            ModalFreqs(j) = str2double(strfreq);
            ModalDamps(j) = 0;
            ModalMass(j) = str2double(strModalMass);
            ModalStiff(j) = str2double(strModalStiff);
            ModalVects(:,j) = datastruct.data(loc,5);
               
            %The modal vectors are extracted from ansys with the
            %normalization criteria of maximum component equals 1. Not UMM,
            %not unitary modulus.
            
            n = max(abs(datastruct.data(loc,5)));
            ModalVects(:,j) = datastruct.data(loc,5);%/n;
            
            %Destruct temporal placeholders
            clear datastruct strfreq strmpf fid remain line n N
           
            
        end %modeshapes files
        
        savepath = [pathout_folder '\' namefolders{i} '_FEM.mat'];
        save(savepath,'ModalFreqs','ModalDamps','ModalMass',...
            'ModalStiff','ModalVects');
        clear ModalFreqs ModalDamps ModalVects ModalMass ModalStiff
        disp(['Saved case ' num2str(i) '/'...
            num2str(length(namefolders))  ' ' namefolders{i}]);
        
    end   

end 