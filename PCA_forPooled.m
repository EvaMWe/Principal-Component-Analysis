%this function read the data from spike/burst Calculator files to create a
%feature table cell
% all features
% to deal with log and 0: add a constant to each data point
% MBR = 0.001; BD: 1;
% row: well, col: feature, 3.dim: time

function [FeatureStore, findata] = PCA_forPooled(dataCont1,varargin)

%to do: Umwandeln auf mehr als 2 inputs

if nargin == 0
    featureVector = dataCont1;
else
    nbDatasets = length(varargin);
    size_1 = size(dataCont1,1);
    for dat = 1:nbDatasets
        dataCont2 = varargin{dat};
        size_1 = size_1 + size(dataCont2,1);        
    end 

    featureVector = cell(size_1, size(dataCont1,2), size(dataCont1,3));
    featureVector(:,1:size(dataCont1,2),:) = dataCont1;
    for dat = 1:nbDatasets
        dataCont2 = varargin{dat};
        featureVector = [featureVector;dataCont2(2:end,:,:)];
    end 

end


%% this has to be implemented to the basic routine, for now to convert values:

nameFeatures = featureVector(:,1,1);
numFeatures = numel(nameFeatures);
numTimepoints = size(featureVector,3);
numWells = size(featureVector,2)-1;
%load data


%%
PCA_results = zeros(numWells, numFeatures, numTimepoints);
PCA_featureRelevance = cell(nbFeatures+1,3,nbTimeBins); %for PC1 & PC2
PCA_featureRelevance(1,2:3,:) = {'PC1','PC2'};

for bin = 1:numTimepoints
    PCA_featureRelevance(2:end,1,bin) = nameFeatures;
    %Extract bin correlated data; convert to double
    dataBin = cell2mat(featureVector(2:end,2:end,bin)');  
    dataBin(isinf(dataBin)) = NaN;
    meanVec = mean(dataBin,1,"omitnan");
    stdVec = std(dataBin,0,1, "omitnan");    
    dataAdjust = (dataBin-meanVec)./stdVec; %standardize, center around 0
    
    %% deal with NANs in dataAdjust
    A = dataAdjust;
    mini= min(abs(A(A ~= 0)));
    dataAdjust=cell2mat(arrayfun(@(i) replaceNan(A(:,i), size(A,1), mini) , 1:size(A,2), 'uni', 0));
    
    [coeff,PC,eigVal,~,explained] = pca(dataAdjust,'Centered',false);
    if isnan(coeff)
        continue
    end
    
    for pc = 1:size(PC,2)
        PCA_results(:,pc,bin) = PC(:,pc); %wellxpc
    end
    
    PCA_featureRelevance(:,2,bin) = num2cell(coeff(:,1));
    PCA_featureRelevance(:,3,bin) = num2cell(coeff(:,2));
    summary = cell(3,nbWells+1);
    summary(1,2:end) = wellNames;
    summary{2,1} = 'PC1';
    summary{3,1} = 'PC2';
    summary(2,2:end) = num2cell(PC(:,1)');
    summary(3,2:end) = num2cell(PC(:,2)');
    PCA_struct.PCA1 = PC(:,1);
    PCA_struct.PCA2 = PC(:,2);
    PCA_struct.summary_per_well = summary;
    PCA_struct.eigenValues = eigVal;
    PCA_struct.loadings = coeff;
    PCA_struct.explained = explained;
    PCA_struct.allPC = PC;
    
    filename = sprintf('PCA_data_bin%i', bin);   
    save(fullfile(savePath, filename),'PCA_struct');    

end

FeatureStore.wells = nameWells;
FeatureStore.features = nameFeatures;
FeatureStore.data = FeatureArray;

end
