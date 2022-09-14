%This is a routine that will calculate the Mahalonobis distance between two
%two subgroups in PC1 and PC2 coordinate system
% Goodpaster AM, Kennedy MA. Quantification and statistical significance analysis of group separation in NMR-based metabonomics studies. 
% Chemometr Intell Lab Syst. 2011;109(2):162-170. doi:10.1016/j.chemolab.2011.08.009

%% Load data sets:
sheetname =  'DIV19-20';
k = 2; %number of groups

% [filename, pathname] = uigetfile();
% cd(pathname)
T = readtable(filename,'Sheet',sheetname);
group1_dat = [T.(2) T.(3)];
group2_dat = [T.(4) T.(5)];

% clean from NANs
group1_dat(isnan(group1_dat(:,1)),:) = [];
group2_dat(isnan(group2_dat(:,1)),:) = [];

n_gr1 = length(group1_dat);
n_gr2 = length(group2_dat);
N = n_gr1 + n_gr2;

%get pooled variance-covariance matrix between the two groups
between_group = getCovMatrices(group1_dat, group2_dat, k);
%centroid group1
PC1_1_avg = mean(group1_dat(:,1));
PC2_1_avg = mean(group1_dat(:,2));
%centroid group2
PC1_2_avg = mean(group2_dat(:,1));
PC2_2_avg = mean(group2_dat(:,2));
% Euclidian difference vector
d =[PC1_2_avg - PC1_1_avg, PC2_2_avg - PC2_1_avg];
Cw = between_group';

DM = sqrt(d*Cw*d');

%% statistics
Tsqr = ((n_gr1*n_gr2)/(n_gr1+n_gr2))*d*Cw*d';

p = 2;
F = (n_gr1+n_gr2-p-1)/(p*(n_gr1+n_gr2-2))*Tsqr;