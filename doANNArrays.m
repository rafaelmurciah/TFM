%This function transforms all the FDAC functions of a folder to the Inputs
%and Targets Arrays for the Network training. Its variables are:
%   infolderANN: String of the folder where the FDACs are.
%   outfolderANN: String of the folder in which the results are stored.
function [X,T]=doANNArrays(infolderANN, outfolderANN)

%Here are the 'instances' of the method. Variables that were preferred to
%leave inside the method instead of put as input variables.
o=501;

listing = dir(fullfile(infolderANN,'*.mat'));
len = length(listing);
%loop to extract the name from the path of each file
for j=1:1:len;
    list{j} = [infolderANN '\' listing(j).name];
    llist{j} = listing(j).name; 
end
clear listing

T=zeros(2,len);
X=zeros(o*o,len);

%for every sample
for j=1:1:len
    %classify it
    if ~isnan(strfind(llist{j},'young'))
        T(1,j)=1;
    end
    if ~isnan(strfind(llist{j},'crack'))
        T(2,j)=1;
    end
    if ~isnan(strfind(llist{j},'original'))
        T(3,j)=1;
    end
    
    %load and treshape the FDAC
    pos=load(list{j});
    X(:,j)=reshape(pos.CFDAC,[1 o*o]);
    
end

%save the result
save([outfolderANN '\ANN.mat'],'X','T');

end