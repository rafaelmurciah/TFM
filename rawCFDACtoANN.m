function [T,X]=rawCFDACtoANN(CFDACfolder)

%[T,X]=rawCFDACtoANN('D:\Rafael\IQS\MÁSTER 2\TFM\Archivos
%Matlab\outputCFDAC')

o=6401;
num=19;

%prueba
T=[1 1 1 1 1 1 1 1 1 0 0 0 0 0 0 0 0 0 0;...
    0 0 0 0 0 0 0 0 0 1 1 1 1 1 1 1 1 1 1]';
%T=zeros(2,num);
X=zeros(o*o,num);

listing = dir(fullfile(CFDACfolder,'*.mat'));
l = length(listing);
%loop to extract the name from the path of each file
for j=1:1:l;
    list{j} = [CFDACfolder '\' listing(j).name];
    llist{j} = listing(j).name; 
end
clear listing

for j=2:1:l
       %Do the reshape and put it in X
       step=load(list{j});
       X(:,j-1)=reshape(step.CFDAC,[1 o*o]);
end

end