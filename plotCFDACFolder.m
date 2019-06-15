%This function plots all the FDACs of a given folder. Its variables are:
%   inputpCFDAC: String of the folder where the FDACs are.
%   reales: boolean to decide if the nomenclature is from real test samples
%   or simulated ones. true when they are real
function plotCFDACFolder(inputpCFDAC,reales)

%Here are the 'instances' of the method. Variables that were preferred to
%leave inside the method instead of put as input variables.
Frequencies=[0:0.5:3600];
numcol=6;

listing = dir(fullfile(inputpCFDAC,'*.mat'));
len = length(listing);
%loop to extract the name from the path of each file
for j=1:1:len;
    list{j} = [inputpCFDAC '\' listing(j).name];
    llist{j} = listing(j).name; 
end
clear listing

j=1;
count=1;
while j<=len
    %shapes the Figure to adapt to the number of elements
    numrows=3;
    numelem=numrows*numcol;
    if len-j<12
        numrows=ceil((len-j)/numcol);
        numelem=len-j+1;
    end
    %close all
    figure('Color',[1 1 1]);
    set(gcf,'Units','inches','Position',[1 1 numcol*1.5 numrows*1.5])
    
    for k=1:numelem
        
        %takes the names of the titles
        strng=llist{j};
        if reales
            dvref=strfind(strng,'dv');
            matref=strfind(strng, '.MATCFDAC');
            nameS=strng(6:dvref-1);
            drvpt=strng(dvref+2:matref-1);
        else
            sysref=strfind(strng,'sys');
            femref=strfind(strng, '_FEM');
            nameS=strng(sysref+7:femref-1);
            drvpt=strng(1:sysref-1);
        end
        
        pos=load(list{j});
        
        %subplots
        subplot(numrows,numcol,k)
        colormap(jet);
        imagesc(Frequencies',Frequencies',pos.CFDAC);
        set(gca,'YDir','normal','XDir','normal','FontSize',8,'FontName','Times');
%         title(({[nameS];}),'FontSize',8,'FontName','Times','EdgeColor',[1 1 1],'BackgroundColor',[1 1 1],'HorizontalAlignment','Center');
        title(({[nameS ', drvpt: 30' drvpt];}),'FontSize',8,'FontName','Times','EdgeColor',[1 1 1],'BackgroundColor',[1 1 1],'HorizontalAlignment','Center');
        axis off
        
        j=j+1;
    end
    drawnow
    
    %saves the figure in the main folder
%     saveas( gcf, ['Folder plot ' num2str(count) '.jpeg'] );
%     count=count+1;
end

end