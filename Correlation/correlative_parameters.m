% Import data and filtering useless ones
NIMSdata = readtable("matlab_data.csv");
NIMSdata.FS = [];
NIMSdata.CRS = [];
NIMSdata.YS = [];
NIMSdata.Properties.VariableNames{'x___NT'} = 'NT';
data = table2array(NIMSdata);

% Correlation matrix of all variables
corr = corrcoef(data);

% Exporting correlation matrix as .cvs
varNames = NIMSdata.Properties.VariableNames;
corr_table = array2table(corr);
corr_table.Properties.VariableNames = varNames;
corr_table.Properties.RowNames = varNames;
writetable(corr_table, "correlation_matrix.xlsx", "WriteRowNames", true);

% Sorting parameters vs FS correlations
fsCorr = corr(1:end-1, end);
[~, i] = sort(abs(fsCorr), 'descend');
fsCorr = fsCorr(i);
fsCorrPos = fsCorr;
fsCorrPos(fsCorr < 0) = nan;
fsCorrNeg = fsCorr;
fsCorrNeg(fsCorr > 0) = nan;

% Graphing and saving as .jpg
figure;
bar(1:length(fsCorrPos), fsCorrPos); hold on;
bar(1:length(fsCorrPos), abs(fsCorrNeg));
set(gca, 'xtick', 1:length(varNames)-1, 'xticklabels', varNames(i), 'fontsize', 14, 'fontweight', 'bold');
xlabel("Parameters");
ylabel("Pearson Correlation Value (Red < 0, Blue > 0)");
title("Correlation of parameters to cFS", 'fontsize', 24);
set(gcf, 'Units', 'Normalized', 'OuterPosition', [0 0 1 1]);
saveas(gcf, "correlation_bargraph.jpg");




