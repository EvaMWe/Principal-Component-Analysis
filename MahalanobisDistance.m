%This is a routine that will calculate the Mahalonobis distance between two
%two subgroups in PC1 and PC2 coordinate system
% Goodpaster AM, Kennedy MA. Quantification and statistical significance analysis of group separation in NMR-based metabonomics studies. 
% Chemometr Intell Lab Syst. 2011;109(2):162-170. doi:10.1016/j.chemolab.2011.08.009

%% Load data sets:
sheetname =  'day2';
k = 2; %number of groups

[filename, pathname] = uigetfile();
cd(pathname)
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

%% Figures
colormapCostum = [189 208 159; 152 171 144; 115 134 129 ; 78 97 114];  
colormapCostum = colormapCostum./255;

figure('Color',[1 1 1],'Position', [0 0 1318 800] );
colormap(colormapCostum);


% data of group1
sct1 = scatter(group1_dat(:,1),group1_dat(:,2));
sct1.Marker = '^';
sct1.MarkerEdgeColor = [0 0 255]./255;
sct1.MarkerFaceColor = [0 0 255]./255;
sct1.SizeData = 150;
hold on

% data of group2
sct2 = scatter(group2_dat(:,1),group2_dat(:,2));
sct2.Marker = 's';
sct2.MarkerEdgeColor = [255 0 0]./255;
sct2.MarkerFaceColor = [255 0 0]./255;
sct2.SizeData = 150;


% draw line between centroids
hold on
p_con = line([PC1_1_avg PC1_2_avg],[PC2_1_avg PC2_2_avg]);
p_con.Color = 'k';
p_con.LineWidth = 4;


%draw centroids
hold on
centr1 = scatter(PC1_1_avg,PC2_1_avg);
centr1.MarkerEdgeColor = [0 0 0];
centr1.MarkerFaceColor = [1 1 1];
centr1.Marker = '^';
centr1.LineWidth = 4;
centr1.SizeData = 400;

hold on
centr2 = scatter(PC1_2_avg,PC2_2_avg);
centr2.MarkerEdgeColor = [0 0 0];
centr2.MarkerFaceColor = [1 1 1];
centr2.Marker = 's';
centr2.LineWidth = 4;
centr2.SizeData = 400;


%label axis
xlabel({'PC1'},'FontSize',33);
ylabel({'PC2'},'FontSize',3)

%control axis properties
ax1 = gca;
ax1.TickDir = 'out';
ax1.LineWidth = 1.5;
ax1.PlotBoxAspectRatio = [1 1 1];
ax1.FontSize = 30;
ax1.FontName = 'Arial';
ax1.XLim = [-6 6];
ax1.YLim = [-4 4];
ax1.XTick = [-6,-5,-4,-3,-2,-1,0,1,2,3,4,5,6]; %ax1.XTick = [-8,-6,-4,-2,0,2,4,6,8];
ax1.YTick = [-4,-3,-2,-1,0,1,2,3,4]; %ax1.YTick = [-8,-6,-4,-2,0,2,4,6,8];