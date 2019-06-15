%This function serves two purposes. It tests the performance of a trained
%Network against all the FDACs of the chosen folder, and if chosen it plots
%up to 6 missed results of every class mistaken by every other class. The
%variables are:
%   infolderchecknn: String of the folder in which the FDACs to check are
%   stored.
%   nnet: Trained Network.
%   plotMiss: Boolean to choose whether to plot the misses or not.

function y=checkNN(infolderchecknn,  nnet, plotMiss)

%Here are the 'instances' of the method. Variables that were preferred to
%leave inside the method instead of put as input variables.
o=301;
Frequencies=[2000:4:3600];

listing = dir(fullfile(infolderchecknn,'*.mat'));
len = length(listing);
%loop to extract the name from the path of each file
for j=1:1:len;
    list{j} = [infolderchecknn '\' listing(j).name];
    llist{j} = listing(j).name; 
end
clear listing


y=zeros(len,4);
y(:,1)=1:1:len;
misses=zeros(len,3,3); %array that stores the position of the misses
count=zeros(3,3); %variable that counts the relative position inside misses array


for j=1:1:len
    pos=load(list{j});
    c=1;
    if ~isnan(strfind(llist{j},'young'))
        c=1;
    end
    if ~isnan(strfind(llist{j},'crack'))
        c=2;
    end
    if ~isnan(strfind(llist{j},'original'))
        c=3;
    end
    y(j,2:4)=nnet(reshape(pos.CFDAC,[o*o 1]));
    [~,ind]=max(y(j,2:4));
    
    %when the class doesn't coincide a miss reference is stored
    if ind~=c
        count(ind,c)=count(ind,c)+1;
        misses(count(ind,c),ind,c)=j;
    end
end

%if it is plottable
if plotMiss
    for ind=1:1:3
        switch ind
            case 1
                mistakenBy='Young';
            case 2
                mistakenBy='Crack';
            otherwise
                mistakenBy='Original';
        end
        
        
        second=false;
        start=1;
        ploteds=1;
        
        %it organises the subplots so they are presented in order
        numslid=6;
        if misses(4,ind,1)==0
            numslid=numslid-1;
            if misses(1,ind,1)==0
                numslid=numslid-1;
            end
        end
        if misses(4,ind,2)==0
            numslid=numslid-1;
            if misses(1,ind,2)==0
                numslid=numslid-1;
            end
        end
        if misses(4,ind,3)==0
            numslid=numslid-1;
            if misses(1,ind,3)==0
                numslid=numslid-1;
            end
        end
        
        figure('Name',['Mistaken by ' mistakenBy],'Color',[1 1 1]);
        set(gcf,'Units','inches','Position',[1 1 5 numslid*1.5])
        
        for class=1:1:3
            missp=1;
            if ind ~= class
                if second
                    if ploteds >3
                        start=7;
                    else
                        if numslid>2
                            start=4;
                        end
                    end
                end
                for k=start:start+5
                    if misses(missp,ind,class)~= 0
                        %find strings for the title
                        strng=llist{misses(missp,ind,class)};
                        sysref=strfind(strng,'sys');
                        femref=strfind(strng, '_FEM');
                        nameS=strng(sysref+7:femref-1);
                        drvpt=strng(1:sysref-1);

                        pos=load(list{misses(missp,ind,class)});
                        missp=missp+1;
                        
                        %subplots
                        subplot(numslid,3,k)
                        colormap(jet);
                        imagesc(Frequencies',Frequencies',pos.CFDAC);
                        set(gca,'YDir','normal','XDir','normal','FontSize',8,'FontName','Times');
                        title(({[nameS ', drvpt:' drvpt];}),'FontSize',8,'FontName','Times','EdgeColor',[1 1 1],'BackgroundColor',[1 1 1],'HorizontalAlignment','Center');
                        axis off
                        
                        ploteds=ploteds+1;
                    end
                end
                drawnow
                second=true;
            end
        end
        if numslid>0
            %the image is saves in the main folder as .jpeg
            saveas( gcf, ['mistaken by ' mistakenBy '.jpeg'] );
        end
    end        
end



end