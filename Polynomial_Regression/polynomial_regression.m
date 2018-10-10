clear all;
%% Feature Selection
warning('OFF', 'MATLAB:table:ModifiedAndSavedVarnames')
NIMSdata = readtable("matlab_data.csv");

% feature selection is oopsie, something went wrong (doesn't return same parameters everytime) but we know whare the best parameters are
% parameters = feature_selection(NIMSdata);
% parameters.cFS = NIMSdata.cFS;


%% Lumped HC ASP Model
% Construct table for polynomial regression using P, S, Reduction Ratio
% Inclusion (dB and dC, Vickers Hardness, and LUMPED ASP. FS is response
names = ["P", "S", "RR", "I", "HVN", "lumpASP"];
namesIndex = zeros(1, length(names));
for i = 1:length(names)
    namesIndex(i) = find(strcmp(NIMSdata.Properties.VariableNames, names(i)));
end
polyParameters_lump_ASP = NIMSdata(:, namesIndex);
polyParameters_lump_ASP.lumpASP2 = (polyParameters_lump_ASP.lumpASP).^2;
polyParameters_lump_ASP.cFS = NIMSdata.cFS;

% Regression
[model_lumpASP, RMSE_lumpASP] = trainRegressionModel1(polyParameters_lump_ASP);

% Critical point
lumpASP_Crit = -table2array(model_lumpASP.LinearModel.Coefficients(6,1))...
                                / (2 * table2array(model_lumpASP.LinearModel.Coefficients(7,1)));
                            
% Isolate effect of lumped HC ASP on FS
f_lumpASP = @(x) table2array(model_lumpASP.LinearModel.Coefficients(6,1))*x...
                                                    + table2array(model_lumpASP.LinearModel.Coefficients(7,1))*x.^2;
expectedScatter_lumpASP = NIMSdata.cFS -...
                      table2array(model_lumpASP.LinearModel.Coefficients(1,1)) * NIMSdata.P -...
                      table2array(model_lumpASP.LinearModel.Coefficients(2,1)) * NIMSdata.S -...
                      table2array(model_lumpASP.LinearModel.Coefficients(3,1)) * NIMSdata.RR -...
                      table2array(model_lumpASP.LinearModel.Coefficients(4,1)) * NIMSdata.I -...
                      table2array(model_lumpASP.LinearModel.Coefficients(5,1)) * NIMSdata.HVN;
                  
% Graphing isolated effect
figure;
subplot(1,2,1)
set(gcf, 'Position', [0 0 2000 1200]);
fplot(f_lumpASP, [-24000 0], 'linewidth', 8); hold on;
scatter(polyParameters_lump_ASP.lumpASP, expectedScatter_lumpASP, 75, [1 0 0], 'filled'); hold on;
scatter(lumpASP_Crit, f_lumpASP(lumpASP_Crit), 1000, 'd', 'filled', 'MarkerEdgeColor', [0 0 0], 'MarkerFaceColor',[1 1 0]);
set(gca, 'fontsize', 14, 'fontweight', 'bold');
xlabel("Lumped HC ASP J/mol", 'fontsize', 18); ylabel("Effect on FS", 'fontsize', 18); 
title("Effect of Lumped ASP and FS", 'fontsize', 24);

%% ASP Model
% Construct table for polynomial regression using P, S, Reduction Ratio
% Inclusion (dB and dC, Vickers Hardness, and ASP. FS is response
polyParameters_ASP = polyParameters_lump_ASP;
polyParameters_ASP(:,end-2:end) = [];
polyParameters_ASP.ASP = NIMSdata.ASP;
polyParameters_ASP.ASP2 = NIMSdata.ASP.^2;
polyParameters_ASP.cFS = NIMSdata.cFS;

% Regresion
[model_ASP, RMSE_ASP] = trainRegressionModel2(polyParameters_ASP);

% Critical point
ASP_Crit = -table2array(model_ASP.LinearModel.Coefficients(6,1))...
                                / (2 * table2array(model_ASP.LinearModel.Coefficients(7,1)));

% Isolate effect of ASP on FS
f_ASP = @(x) table2array(model_ASP.LinearModel.Coefficients(6,1))*x...
                                                    + table2array(model_ASP.LinearModel.Coefficients(7,1))*x.^2;
expectedScatter_ASP = NIMSdata.cFS -...
                      table2array(model_ASP.LinearModel.Coefficients(1,1)) * NIMSdata.P -...
                      table2array(model_ASP.LinearModel.Coefficients(2,1)) * NIMSdata.S -...
                      table2array(model_ASP.LinearModel.Coefficients(3,1)) * NIMSdata.RR -...
                      table2array(model_ASP.LinearModel.Coefficients(4,1)) * NIMSdata.I -...
                      table2array(model_ASP.LinearModel.Coefficients(5,1)) * NIMSdata.HVN;

% Graphing stuff
subplot(1,2,2);
fplot(f_ASP, [-2100 -500], 'linewidth', 8); hold on;
scatter(polyParameters_ASP.ASP, expectedScatter_ASP, 75, [1 0 0], 'filled'); hold on;
scatter(ASP_Crit, f_ASP(ASP_Crit), 1000, 'd', 'filled', 'MarkerEdgeColor', [0 0 0],'MarkerFaceColor', [1 1 0]);
set(gca, 'fontsize', 14, 'fontweight', 'bold');
xlabel("ASP J/mol", 'fontsize', 18); ylabel("Effect on FS", 'fontsize', 18); 
title("Effect of ASP and FS", 'fontsize', 24);
saveas(gcf, "isolations.jpg");

%% Graphing accuracy of models
figure;
set(gcf, 'Position', get(0, 'Screensize'));
subplot(1,2,1);
set(gca, 'fontsize', 14, 'fontweight', 'bold');
expected_cFS = model_lumpASP.predictFcn(polyParameters_lump_ASP(:,1:7));
scatter(polyParameters_lump_ASP.cFS, expected_cFS, 50, [1 0 0], 'filled');
xlabel("Actual FS", 'fontsize', 14, 'fontweight', 'bold'); ylabel("Model predicted FS", 'fontsize', 14, 'fontweight', 'bold');
title("Actual vs Predicted FS (Lumped ASP model)", 'fontsize', 20, 'fontweight', 'bold');
l = refline(1,0);
l.LineWidth = 4;

subplot(1,2,2);
expected_cFS = model_ASP.predictFcn(polyParameters_ASP(:,1:7));
scatter(polyParameters_ASP.cFS, expected_cFS, 50, [1 0 0], 'filled');
xlabel("Actual FS", 'fontsize', 14, 'fontweight', 'bold'); ylabel("Model predicted FS", 'fontsize', 14, 'fontweight', 'bold'); 
title("Actual vs Predicted FS (ASP model)", 'fontsize', 20, 'fontweight', 'bold');
l = refline(1,0);
l.LineWidth = 4;

saveas(gcf, "residuals.jpg");


%% Save polynomials in excel
writetable(model_ASP.LinearModel.Coefficients, "ASP_coefficients.xlsx", "WriteRowNames", true);
writetable(model_lumpASP.LinearModel.Coefficients, "lumped_ASP_coefficients.xlsx", "WriteRowNames", true);