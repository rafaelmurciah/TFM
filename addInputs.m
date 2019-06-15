%This function adds more values to the Inputs and Targets Arrays. It is
%used to add samples from the Real Set to a previously prepared Simulated
%Set. It shuffles the values of the simulated set, leaving the values from
%the Real Set untouched at the beginning. Its variables are:
%   infolderAdd: String of the folder where the FDACs to add are.
%   outfolderAdd: String of the folder in which the results are stored.
%   x: previous Inputs Array.
%   t: previous Targets Array.
%   numclasses: Number of classes of the Targets Array.
function [X,T]=addInputs(infolderAdd,outfolderAdd, x, t,numclasses)

%Here are the 'instances' of the method. Variables that were preferred to
%leave inside the method instead of put as input variables.
o=301;

listing = dir(fullfile(infolderAdd,'*.mat'));
len = length(listing);
%loop to extract the name from the path of each file
for j=1:1:len;
    list{j} = [infolderAdd '\' listing(j).name];
    llist{j} = listing(j).name; 
end
clear listing


X=zeros(o*o,size(x,2)+len);
T=zeros(numclasses,size(x,2)+len);
addx=zeros(o*o,len);
addt=zeros(numclasses,len);
xp=x;
tp=t;

%it creates the Inputs an Targets segments of the Real samples
for j=1:1:len
    if ~isnan(strfind(llist{j},'stringer'))
        class=1;
    end
    if ~isnan(strfind(llist{j},'crack'))
        class=2;
    end
    if ~isnan(strfind(llist{j},'original'))
        class=3;
    end
    
    pos=load(list{j});
    addx(:,j)=reshape(pos.CFDAC,[1 o*o]);
    addt(class,j)=1;
end

%the previous inputs are randomized
ranj=randperm(size(x,2));
for j=1:1:size(x,2)
    xp(:,j)=x(:,ranj(j));
    tp(:,j)=t(:,ranj(j));    
end

%the new arrays are created
X(:,1:len)=addx;
X(:,(len+1):end)=xp;
T(:,1:len)=addt;
T(:,(len+1):end)=tp;

save([outfolderAdd '\ANN.mat'],'X','T');

end