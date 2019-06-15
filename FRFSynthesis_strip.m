%Not written by Rafael Murcia
function [Frequency, FRFsMatrix_synth, rovingdof, drivingdof] = ...
    FRFSynthesis_strip(Data_File_synt,Fmax,df,eta,delta,rovings,drvpt,outfolder)
    
%This function returns 4 arguments:
%   -Frequency: A vector containing the frequencies sampled for the FRFs
%   -synthFRFs: A matrix of FRFs with the following dimensions
%       +rows : Number of roving points * number of driving points
%       +columns: Number of line frequencies
%   -rovs: A vector indicating the roving point in which the FRF(row) is
%       calculated
%   -driv: A vector indicating the driving point in which he FRF(row) is
%       calculated
%
%This function requires 7 input arguments
%   -pathinp: A string containing the path to the *.mat file containing the
%       UMM model from which the synthesis will be performed.
%   -Fmax: A number indicating the maximum frequency for which the FRFs
%       will be computed.
%   -df: A number indicating the frequen cy increment between to spectral
%       lines of the FRF synthesis
%   -eta: first proportional damping model coefficient
%   -delta: secod proportional damping model coefficient
%   -rovings: a row vector indicating the roving DOFs in which the FRFs
%       will be synthetized.
%   -drivings: a row vector indicating the driving points in which the FRFs
%       will be synthetised. For an EMA equivalent synthesis, this value
%       must be only a number indicating the DoF in which the accelerometer
%       is located
%
%Example of usage
%   pathinp =
%   'D:\Dropbox\00_VibrationSHM\FEM_Modes\UMMmodel_ClampedMarco_11x11.mat';         PARA PC
%   pathinp =
%   '/Users/MacBookMarco/Dropbox/Compartidas/IQS_UPC/ValidacionSynthesisExperimental/UMMmodel_ClampedMarco_11x11.mat'       PARA MAC
%   [Frequency, FRFsMatrix_synth, rovingdof, drivingdof] = ...
%       FRFSynthesis_strip(pathinp,3200,0.25,20.23142,8.026066E-8,[1:1:121],1);
%



    %Open the file containing the modal model. This is a *.mat file condensed from Ansys results
    umm = load(Data_File_synt);

    %get the number of eigenvectors (number of modes in the umm file)
    Nmode = length(umm.ModalVects(1,:));

    %get the number of degrees of freedom (number of dofs in the umm file)
    Ndof = length(umm.ModalVects(:,1));

    %Calculate the number of frequency lines to sample virtually
    Nf = floor(Fmax/df)+1;
    
    %Check if rovings and drivings are valid for the umm file read
    maxrow = max(rovings);
    maxcol = max(drvpt);
    minrow = min(rovings);
    mincol = min(drvpt);
    if(maxrow>Ndof || maxcol>Ndof)
        error('Rows or cols larger than available DoFs in umm file');
    end
    if(minrow<1 || mincol<1)
        error('Rows and cols must be positive integers');
    end
    
    %Preallocate the FRFs : each FRF in a row of the matrix. rovs and driv indentfy the roving dofs and driving dofs
    FRFsMatrix_synth = zeros(length(rovings)*length(drvpt),Nf);
    rovingdof = zeros(length(rovings)*length(drvpt),1);
    drivingdof = zeros(length(rovings)*length(drvpt),1);

    %Generate the frequency vector
    Frequency = 2*pi*df*[0:1:Nf-1];    %#ok<NBRAK>
    % Frequency = 2*pi*df*[1:1:Nf];    %#ok<NBRAK>

    omegas = umm.ModalFreqs.*2.0.*pi;
    xis = eta./omegas./2 + omegas.*delta./2;
    omegas = omegas.*(sqrt(ones(1,Nmode)-xis.^2));
    %sigmas = 2.*omegas.*xis;
    sigmas = omegas.*xis;
    masses = umm.ModalMass;

    eigvals1 = sigmas + 1j*omegas;
    eigvals2 = sigmas - 1j*omegas;
    
    count = 0;
    for i = rovings 
        for j = drvpt
            count = count+1;            
            
			%This implmementation avoids the use of an inner loop for the spectral lines
            ResMod = ((umm.ModalVects(i,:).*umm.ModalVects(j,:))./2./1j.*1E-3./masses./omegas);
            Res1 = repmat(Frequency.^2,Nmode,1).*repmat(ResMod',1,Nf);
            Res2 = conj(Res1);
            
            %ResMod = ((umm.ModalVects(i,:).*umm.ModalVects(j,:))./masses./omegas);
            %Res1 = repmat(1j*Frequency,Nmode,1).*repmat(ResMod',1,Nf);
            %Res2 = - Res1;
            %Res2 = Res1;   
            
            Den1 = repmat(1j.*Frequency,Nmode,1) - repmat(eigvals1',1,Nf);
            Den2 = repmat(1j.*Frequency,Nmode,1) - repmat(eigvals2',1,Nf);           
			%Fill the FRF matrix and the roving and driving vector
            FRFsMatrix_synth(count,:) = sum((Res1./Den1 + Res2./Den2),1);
            rovingdof(count,1) = j;
            drivingdof(count,1) = i;
        end
    end
 FRFsMatrix_synth=FRFsMatrix_synth';
    Frequency = Frequency./2./pi;
     Frequency=Frequency';
    save([outfolder '\' Data_File_synt(strfind(Data_File_synt,'sys'):end) '_synth_drvpt_' num2str(drvpt) '.mat'],'Frequency','FRFsMatrix_synth','rovingdof','drivingdof');
end

