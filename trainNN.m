%This function trains a Neural Network. Its variables are:
%   X: Inputs Array.
%   T: Targets Array.
function trainNN(X,T)

close all;
x = X;
t = T;

%percentage of the sample to training, validation and test
trainP=[0.9 0.05 0.05];

%We shuffle the values of each block independently (this way we are
%assuring that the inputs added at the beginning in addInputs.m will go to
%the training sample for sure but will be presented randomly
samplepos=[floor(size(x,2)*trainP(1)) floor(size(x,2)*(trainP(1)+trainP(2)))];
xaux=x;
taux=t;

pr=randperm(samplepos(1));
for p=1:samplepos(1)
    xaux(:,p)=x(:,pr(p));
    taux(:,p)=t(:,pr(p));
end
pr=randperm(samplepos(2)-samplepos(1));
pr=pr+samplepos(1);
for p=1:samplepos(2)-samplepos(1)
    xaux(:,p+samplepos(1))=x(:,pr(p));
    taux(:,p+samplepos(1))=t(:,pr(p));    
end
pr=randperm(size(x,2)-samplepos(2));
pr=pr+samplepos(2);
for p=1:size(x,2)-samplepos(2)
    xaux(:,p+samplepos(2))=x(:,pr(p));
    taux(:,p+samplepos(2))=t(:,pr(p));
end
x = xaux;
t = taux;
clear xaux taux


trainFcn = 'trainscg';  % Scaled conjugate gradient backpropagation.

% Create a Pattern Recognition Network
hiddenLayerSize = 10;
net = patternnet(hiddenLayerSize,trainFcn);

% Choose Input and Output Pre/Post-Processing Functions
% For a list of all processing functions type: help nnprocess
net.input.processFcns = {'removeconstantrows','mapminmax'};
net.output.processFcns = {'removeconstantrows','mapminmax'};

% Setup Division of Data for Training, Validation, Testing
%'divideblock' doesn't divide the data randomly (we already did it);
%instead, it divides it sequentially
net.divideFcn = 'dividerand';  
net.divideMode = 'sample';  % Divide up every sample
net.divideParam.trainRatio = trainP(1);
net.divideParam.valRatio = trainP(2);
net.divideParam.testRatio = trainP(3);

%We are changing the validation checks up from 6 up to 12 because 6 made
%the training stop too early in many cases when it still could learn
net.trainParam.max_fail=12;

% Choose a Performance Function
net.performFcn = 'crossentropy';  % Cross-Entropy

% Choose Plot Functions
net.plotFcns = {'plotperform','plottrainstate','ploterrhist', ...
    'plotconfusion', 'plotroc'};

% Train the Network
%we will use the GPU since our GPU performs better than our processor at this
%type of problems
[net,tr] = train(net,x,t,'useGPU','yes');

% Test the Network
y = net(x);
e = gsubtract(t,y);
performance = perform(net,t,y);
tind = vec2ind(t);
yind = vec2ind(y);
percentErrors = sum(tind ~= yind)/numel(tind);

% Recalculate Training, Validation and Test Performance
trainTargets = t .* tr.trainMask{1};
valTargets = t .* tr.valMask{1};
testTargets = t .* tr.testMask{1};
trainPerformance = perform(net,trainTargets,y);
valPerformance = perform(net,valTargets,y);
testPerformance = perform(net,testTargets,y);


figure
plotperform(tr)

figure
plotconfusion(t,y)
end
