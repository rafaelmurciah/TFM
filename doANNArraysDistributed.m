%This function transforms distributedly the FDAC functions of a folder to 
%the Inputs and Targets Arrays for the Network training. Its variables are:
%   infolderANN: String of the folder where the FDACs are.
%   outfolderANN: String of the folder in which the results are stored.
%   numclasses: number of classes to categorize
%   samplesperclass: number of samples per each class
function [X,T]=doANNArraysDistributed(infolderANN, outfolderANN,numclasses,samplesperclass)

%Here are the 'instances' of the method. Variables that were preferred to
%leave inside the method instead of put as input variables.
o=301;

listing = dir(fullfile(infolderANN,'*.mat'));
len = length(listing);
%loop to extract the name from the path of each file
for j=1:1:len;
    list{j} = [infolderANN '\' listing(j).name];
    llist{j} = listing(j).name; 
end
clear listing

P=zeros(o*o,len,numclasses);
X=zeros(o*o,numclasses*samplesperclass);
T=zeros(numclasses,numclasses*samplesperclass);
posvec=[0 0 0];

%randomizes the order in which the FDACs appear so the samples are not the
%first ones
ranj=randperm(len);

for j=1:1:len
    if ~isnan(strfind(llist{ranj(j)},'young'))
        class=1;
    end
    if ~isnan(strfind(llist{ranj(j)},'crack'))
        class=2;
    end
    if ~isnan(strfind(llist{ranj(j)},'original'))
        class=3;
    end
    
    pos=load(list{ranj(j)});
    posvec(class)=posvec(class)+1;
    P(:,posvec(class),class)=reshape(pos.CFDAC,[1 o*o]);    
end

%distributes the samples to their position per order. They will be
%randomized later.
X(:,1:samplesperclass)=P(:,1:samplesperclass,1);
T(1,1:samplesperclass)=1;

X(:,samplesperclass+1:2*samplesperclass)=P(:,1:samplesperclass,2);
T(2,samplesperclass+1:2*samplesperclass)=1;

if numclasses==3
    X(:,2*samplesperclass+1:3*samplesperclass)=P(:,1:samplesperclass,3);
    T(3,2*samplesperclass+1:3*samplesperclass)=1;
end

%saves the result
save([outfolderANN '\ANN.mat'],'X','T');

end