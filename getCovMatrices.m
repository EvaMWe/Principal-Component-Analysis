% This is a function that calculates the pooled and the between-group
% Covariance
% Based on
% https://blogs.sas.com/content/iml/2020/07/01/pooled-covariance-between-group.html
% (sept '22)

function [BCov, PooledCov, M] = getCovMatrices(group1_dat, group2_dat, k)

group1_dat(isnan(group1_dat(:,1)),:) = [];
group2_dat(isnan(group2_dat(:,1)),:) = [];

n_gr1 = length(group1_dat);
n_gr2 = length(group2_dat);
N = n_gr1 + n_gr2;
S_gr1 = cov(group1_dat);
S_gr2 = cov(group2_dat);

M = (n_gr1-1)*S_gr1 + (n_gr2-1)*S_gr2;
PooledCov = M/(N-k);
dat = [group1_dat;group2_dat];
CovAll = (N-1)*cov(dat);  %Full Covariance; ignore subgroups

BCov = (CovAll-M)*k/(N*(k-1));
end



