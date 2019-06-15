function plotCFDAC(infolderPlot)

Frequencies=[2000:4:3600];

listing = dir(fullfile(infolderPlot,'*.mat'));
len = length(listing);
%loop to extract the name from the path of each file
for j=1:1:len;
    list{j} = [infolderPlot '\' listing(j).name];
    llist{j} = listing(j).name; 
end
clear listing

for j=1:1:len
    pos=load(list{j});
    
    %TEMPORAL%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    strng=llist{j};
    dvref = strfind(strng,'_');
    nameS=strng(7:(dvref-1));
    %TEMPORAL%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    
    
    % Plot
    figure2 = figure('Name','CFDAC Matrix','Color',[1 1 1]);
    %clims = [0.005 1];   
    colormap(jet);
    imagesc(Frequencies',Frequencies',abs(real(pos.CFDAC)));
    colorbar
    set(gca,'YDir','normal','XDir','normal','FontSize',14,'FontName','Times');
    ylabel('Hz'); xlabel('Hz');
    title(nameS,'FontSize',14,'FontName','Times','EdgeColor',[1 1 1],'BackgroundColor',[1 1 1],'HorizontalAlignment','Center');                
    axis square tight
    grid on
    %savefig([FRF2 '_vs_' FRF1 'Re_CFDAC']);
    %print([Results_Path 'Re_CFDAC'], figure2,'-dpng');
    %print([Results_Path 'Re_CFDAC'], figure2,'-dpdf');
    drawnow
    
    
    saveas( gcf, [nameS '.jpeg'] );
    close all;
    
end

end