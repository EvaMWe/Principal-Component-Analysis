%this is a routine to convert the data structs obtained after
%MEA-basic-analysis

% What you will need:
% Number of Experiments
% Number of final time points

%(1) Convert the data structs from NB and Conn data to the same structure
%as spiking and bursting

%% BASIC INFOS:


prompt = "How Many Experiments do you want to merge? ";
nbExp = str2double(cell2mat(inputdlg(prompt))); 

prompt = "Whats the final number of time points ";
nbTim = str2double(cell2mat(inputdlg(prompt))); 


% create data cells for filename and paths
cellNBFiles = cell(nbExp,1);
cellConnFiles = cell(nbExp,1);
cellSpikeFiles = cell(nbExp,1);
cellBurstFiles = cell(nbExp,1);

cellNBpath = cell(nbExp,1);
cellConnpath = cell(nbExp,1);
cellSpikepath = cell(nbExp,1);
cellBurstpath = cell(nbExp,1);


celltimeBinspath = cell(nbExp,1);
celltimeBinsfile = cell(nbExp,1);
cellsheetName = cell(nbExp,1);
celltimeID = cell(nbExp,1);
nbFiles_all = 0;

nbWells_all = 0;
for exp = 1:nbExp
    %NB
    prompt = sprintf('select data from NB Calculator for Exp No %i', exp);
    [fileNBpre,pathNBpre]=uigetfile('.mat', prompt ,'MultiSelect','on');
    cellNBFiles{exp,1} = fileNBpre;
    cellNBpath{exp,1} = pathNBpre;
    nbFiles_all = nbFiles_all + numel(fileNBpre);
    data = load(fullfile(pathNBpre, fileNBpre{1,1}),'-mat');
    nbWells_all = nbWells_all + length({data.networkBursts(:).wellName});
    cd (pathNBpre);
    % Conn
    prompt = sprintf('select data from Conn Calculator for Exp No %i', exp);
    [fileConnpre,pathConnpre]=uigetfile('.mat',prompt ,'MultiSelect','on');
    cellConnFiles{exp,1} = fileConnpre;
    cellConnpath{exp,1} =  pathConnpre;
    %Spiking
    prompt = sprintf('select data from Spike Calculator for Exp No %i', exp);
    [fileSpikepre,pathSpikepre]=uigetfile('.mat',prompt,'MultiSelect','on');
    cellSpikeFiles{exp,1} = fileSpikepre;
    cellSpikepath{exp,1} =  pathSpikepre;
    %Bursting
     prompt = sprintf('select data from Burst Calculator for Exp No %i', exp);
    [fileBurstpre,pathBurstpre]=uigetfile('.mat',prompt,'MultiSelect','on');
    cellBurstFiles{exp,1} = fileBurstpre;
    cellBurstpath{exp,1} =  pathBurstpre;
    %Time grouping
    prompt = sprintf('select time grouping list for Exp No %i', exp);
    [fileTiming,pathTiming]=uigetfile('.xlsx',prompt,'MultiSelect','off');
    celltimeBinsfile{exp,1} = fileTiming;
    celltimeBinspath{exp,1} = pathTiming;

    %sheet name
    prompt = "Please insert the name of the sheet containing binning info";
    cellsheetName{exp,1} = inputdlg(prompt); 

    %sheet ime ID
    prompt = "Please insert the name of the sheet containing time ID";
    celltimeID{exp,1} = inputdlg(prompt); 
end

%% get data structs 
%% loop through experiments
idxWell = 1;
for exp = 1:nbExp

    %% get Time points
    timeIDSheetname = celltimeID{exp,1};
    timeIDSheetname = timeIDSheetname{1,1};
    binningSheetname = cellsheetName{exp,1};
    binningSheetname = binningSheetname{1,1};
    timeFile = celltimeBinsfile{exp,1};
    timepath = celltimeBinspath{exp,1};
    [timepoints, timeID] = getTimepoints_GUI(binningSheetname, timeIDSheetname, timeFile, timepath);

    %% parameter for individual experiment
    strApp = sprintf('Exp-%i_',exp);
   
    %nbFilesConn = numel(fileConnpre); all the same
    %nbFilesSpike = numel(fileSpikepre);
    %nbFilesBurst = numel(fileBurstpre);

    %% convert NB
    fileNBpre = cellNBFiles{exp,1};
    nbFiles = numel(fileNBpre);
    pathNBpre = cellNBpath{exp,1};
    for fil = 1:nbFiles
        dataPre = load(fullfile(pathNBpre, fileNBpre{1,fil}),'-mat');
        %get well names
        if fil == 1
            wellNames_ = {dataPre.networkBursts(:).wellName};
            %rename well specifically with exp no
            wellNames = cellfun(@(c)[strApp c],wellNames_,'uni',false);
            nbWells = length(wellNames);
            featureNames = fieldnames(dataPre.networkBursts(1).networkBurstsData);
            featureNamesNB = featureNames([1:2 4:5 7:8 10:11],1);
            %preallocate
            dataArrayNB = zeros(length(featureNamesNB), length(wellNames),nbFiles);
        end
        %fill the array with data
        for well = 1:length(wellNames)
            for feat = 1:length(featureNamesNB)
                value = dataPre.networkBursts(well).networkBurstsData.(featureNamesNB{feat});
                dataArrayNB(feat,well,fil) = value;
            end
        end
    end

  

    %% convert Conn
    fileConnpre = cellConnFiles{exp,1};
    pathConnpre = cellConnpath{exp,1};
    for fil = 1:nbFiles
        dataPre = load(fullfile(pathConnpre, fileConnpre{1,fil}),'-mat');
        %get well names
        if fil == 1
            %wellNames = {dataPre.networkBursts(:).wellName}; same as the
            %others
            featureNames = fieldnames(dataPre.connectivity);
            featureNamesConn = featureNames(5:7,1);
            %preallocate data array
            dataArrayConn = zeros(length(featureNamesConn), length(wellNames),nbFiles);
        end

        %fill the cell with data
        for well = 1:length(wellNames)
            for feat = 1:length(featureNamesConn)
                value = dataPre.connectivity(well).(featureNamesConn{feat});
                dataArrayConn(feat,well,fil) = value;
            end
        end
    end
    

    %% get Spike Array
    fileSpikepre = cellSpikeFiles{exp,1};
    pathSpikepre = cellSpikepath{exp,1};
    for fil = 1:nbFiles
        dataPre = load(fullfile(pathSpikepre, fileSpikepre{1,fil}),'-mat');
        %get well names
        summaryData = dataPre.resultsSpkCalc.summary_perWell;
        if fil == 1
            featureNamesSpike =summaryData(2:end,1);
            dataArraySpike = zeros(length(featureNamesSpike), length(wellNames),nbFiles);
        end
        dataArraySpike(:,:,fil) = cell2mat(summaryData(2:end,2:end));
    end


    %% get Burst Array
    fileBurstpre = cellBurstFiles{exp,1};
    pathBurstpre = cellBurstpath{exp,1};
    for fil = 1:nbFiles
        dataPre = load(fullfile(pathBurstpre, fileBurstpre{1,fil}),'-mat');
        %get well names
        summaryData = dataPre.burstCalcResult.summary_of_Results;
        if fil == 1
            featureNamesBurst =summaryData(2:end,1);
            dataArrayBurst = zeros(length(featureNamesBurst), length(wellNames),nbFiles);
        end
        dataArrayBurst(:,:,fil) = cell2mat(summaryData(2:end,2:end));
    end

    %% average values according to timepoints
    dataArrayNB_ = zeros(size(dataArrayNB,1),size(dataArrayNB,2),length(timepoints));
    dataArrayConn_ = zeros(size(dataArrayConn,1),size(dataArrayConn,2),length(timepoints));
    dataArraySpike_ = zeros(size(dataArraySpike,1),size(dataArraySpike,2),length(timepoints));
    dataArrayBurst_ = zeros(size(dataArrayBurst,1),size(dataArrayBurst,2),length(timepoints));

    for t = 1:length(timepoints)
        dataArrayNB_(:,:,t) = mean(dataArrayNB(:,:,timepoints(t,1):timepoints(t,2)),3);
        dataArrayConn_(:,:,t) = mean(dataArrayConn(:,:,timepoints(t,1):timepoints(t,2)),3);
        dataArraySpike_(:,:,t) = mean(dataArraySpike(:,:,timepoints(t,1):timepoints(t,2)),3);
        dataArrayBurst_(:,:,t) = mean(dataArrayBurst(:,:,timepoints(t,1):timepoints(t,2)),3);
    end

   %% preallocate cell    
    if exp == 1
        dataCellNB = cell(length(featureNamesNB)+1,nbWells_all+1,nbTim);
        dataCellNB(2:end,1,:) = repmat(featureNamesNB,1,1,nbTim);

        dataCellConn = cell(length(featureNamesConn)+1,nbWells_all+1,nbTim);
        dataCellConn(2:end,1,:) = repmat(featureNamesConn,1,1,nbTim);

        dataCellSpike = cell(length(featureNamesSpike)+1,nbWells_all+1,nbTim);
        dataCellSpike(2:end,1,:) = repmat(featureNamesSpike,1,1,nbTim);

        dataCellBurst = cell(length(featureNamesBurst)+1,nbWells_all+1,nbTim);
        dataCellBurst(2:end,1,:) = repmat(featureNamesBurst,1,1,nbTim);
    end       

    % put well name
    dataCellNB(1,idxWell+1:idxWell+nbWells,:) = repmat(wellNames,1,1,nbTim);
    dataCellConn(1,idxWell+1:idxWell+nbWells,:) = repmat(wellNames,1,1,nbTim);
    dataCellBurst(1,idxWell+1:idxWell+nbWells,:) = repmat(wellNames,1,1,nbTim);
    dataCellSpike(1,idxWell+1:idxWell+nbWells,:) = repmat(wellNames,1,1,nbTim);
       
      
    
    
    %% fill into pooled data cell
    dataCellNB(2:end,idxWell+1:idxWell+nbWells,timeID) = num2cell(dataArrayNB_);
    dataCellConn(2:end,idxWell+1:idxWell+nbWells,timeID) = num2cell(dataArrayConn_);
    dataCellSpike(2:end,idxWell+1:idxWell+nbWells,timeID) = num2cell(dataArraySpike_);
    dataCellBurst(2:end,idxWell+1:idxWell+nbWells,timeID) = num2cell(dataArrayBurst_);

    idxWell = idxWell + nbWells-1;
end
%% SUBFUNCTIONS
function [timepoints, timeID] = getTimepoints_GUI(binning, timeID, fileInfo, filePath)

if ~iscell(fileInfo)
    fileInfo = cellstr(fileInfo);
end
filename = fullfile(filePath,fileInfo{1});
opts = detectImportOptions(filename);

opts.Sheet = binning;
opts.VariableNames = {'starts', 'stops'};
opts.DataRange = 'A3';
timepoints = readtable(filename,opts);
timepoints =table2array(timepoints);
if iscell(timepoints)
    if ischar(timepoints{1,1})
        timepoints = str2double(timepoints);
    end
end

opts.Sheet = timeID;
opts.VariableNames = {'time_ID'};
opts.DataRange = 'A3';
timeID = readtable(filename,opts);
timeID =table2array(timeID);
if iscell(timeID)
    if ischar(timeID{1,1})
        timeID = str2double(timeID);
    end
end



end