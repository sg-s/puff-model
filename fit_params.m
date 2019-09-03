% this script fits pulse data repeatedly to see how good the pulse fit parameters
% are


close all
clearvars
load fit_data

Model = TwoTubesX;

% define bounds for fitting

lb.t_offset = 0;
ub.t_offset = 10;


lb.k_d = 0;
ub.k_d = 1e2;

lb.w = 0;
ub.w = 0;

lb.tau_s = 1e-6;
ub.tau_s = 10;

lb.tau_a = 0;
ub.tau_a = 0;


% how many times should we fit this?
N = 1;


% which odorant to fit?
do_this = 2;

all_r2 = NaN(N,1);

% configure model
Model.Stimulus = fd(do_this).stimulus;
Model.Response = fd(do_this).response;
Model.Upper = ub;
Model.Lower = lb;

for i = N:-1:1
	
	disp(i)

	Model.Parameters = [];
	Model.fit;

	Model.evaluate;

	% estimate r2
	all_r2(i) = statlib.correlation(fd(do_this).response,Model.Prediction);
	p(i) = Model.Parameters;
end






figure('outerposition',[300 300 1401 901],'PaperUnits','points','PaperSize',[1200 901]); hold on

subplot(2,3,1); hold on
plot(fd(do_this).response,'k')
for i = 1:N
	Model.Parameters = p(i);
	Model.evaluate;
	plot(Model.Prediction,'r')
end
set(gca,'XLim',[50 3e2])

return

% show parameters
pp = rmfield(p,'t_offset');
fn = fieldnames(pp);


subplot(2,3,2); hold on
plot(([pp.(fn{1})]),([pp.(fn{2})]),'ko')
set(gca,'XScale','log','YScale','log')
xlabel(fn{1},'interpreter','none')
ylabel(fn{2},'interpreter','none')


subplot(2,3,3); hold on
plot(([pp.(fn{3})]),([pp.(fn{4})]),'ko')
set(gca,'XScale','log','YScale','log')
xlabel(fn{3},'interpreter','none')
ylabel(fn{4},'interpreter','none')

subplot(2,3,4); hold on
plot(([pp.(fn{2})]),([pp.(fn{4})]),'ko')
set(gca,'XScale','log','YScale','log')
xlabel(fn{2},'interpreter','none')
ylabel(fn{4},'interpreter','none')

subplot(2,3,5); hold on
plot(([pp.(fn{1})]),([pp.(fn{5})]),'ko')
set(gca,'XScale','log','YScale','log')
xlabel(fn{1},'interpreter','none')
ylabel(fn{5},'interpreter','none')

subplot(2,3,6); hold on
plot(([p.(fn{1})]),all_r2,'ro')
plot(([p.(fn{2})]),all_r2,'bo')
plot(([p.(fn{3})]),all_r2,'kd')
plot(([p.(fn{4})]),all_r2,'rd')
set(gca,'XScale','log')
ylabel('r^2 of fit to data')
xlabel('Parameter value')
L = legend(fn);
L.Position = [.86 .15 .1 .16];
set(gca,'YLim',[.9 1])

figlib.pretty('FontSize',20)


