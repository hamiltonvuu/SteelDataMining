function [data] = feature_selection(NIMSdata)
NIMSdata(:, [1:7 10:13 17 21 23:26]) = [];

% sort into parameters and response
x = table2array(NIMSdata(:,1:end-1));
y = NIMSdata.cFS;

c = cvpartition(y,'k',10);
opts = statset('display','iter');
keepIn = find(strcmpi(NIMSdata.Properties.VariableNames,'ASP'));
fun = @(XT,yT,Xt,yt)...
    (norm(yt - classify(Xt,XT,yT,'linear')));

[fs,history] = sequentialfs(fun, x, y, 'cv', c, 'keepin', keepIn);              
           
data = NIMSdata(:,find(fs));

end

           
                        