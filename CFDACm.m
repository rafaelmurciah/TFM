%Not written by Rafael Murcia

%This function is the general version of FDAC.m for experimetnal and numerical FRF.
% Returns a complex matrix ComplexFDAC and 2 scalar arrays f1 and f2. The variables are:
%   FRF1: FRFs (experimental or numerical) format Lines x DoF
%   FRF2: FRFs (experimental or numerical) format Lines x DoF
%   frequencies: vector of frequencies form 0 to fmax.
%   type: Complex (1), Real (2) or Imag (3) FDAC.
%   Dof: which DoF being considered
%   fmin: minimum frequency
%   fmax: maximum frequency
%   (df):   frequency resolution to keep compatibility.

function [CFDAC]=CFDACm(Frequencies,FRF1,FRF2,fmin,fmax,df,type)
    samplemin=fmin/df+1;     
    samplemax=fmax/df+1;
    FRF1=FRF1(samplemin:samplemax,:);
    FRF2=FRF2(samplemin:samplemax,:);
    
    switch type
        case 1 % Complex
        CFDAC=((FRF1*FRF2').^2).*(1./(diag(FRF1*FRF1')*diag(FRF2*FRF2')'));

        case 2 % Real
        FRF1=real(FRF1);
        FRF2=real(FRF2);
        CFDAC=((FRF1*FRF2').^2).*(1./(diag(FRF1*FRF1')*diag(FRF2*FRF2')'));
        
        case 3 % Imag
        FRF1=imag(FRF1);
        FRF2=imag(FRF2);
        CFDAC=((FRF1*FRF2').^2).*(1./(diag(FRF1*FRF1')*diag(FRF2*FRF2')'));
        
    end
end