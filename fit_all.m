% this script fits all the data from the puff dataset
% with a Model, and saves the fits
% assumes you have a struct called fd in the ws

% define upper and lower bounds


clearvars

% get data
load best_offsets
load fit_data

% define model to work with
Model = TwoTubesX;


% specify bounds. Parameters will be found 
% within these bounds

lb.t_offset = 0;
ub.t_offset = 10;

lb.k_d = 1e-4;
ub.k_d = 1e4;

lb.w = 0;
ub.w = 1e3;

lb.tau_s = 1e-6;
ub.tau_s = 10;

lb.tau_a = 1e-3;
ub.tau_a = 1e3;


% define bounds for initial seeds
lb = orderfields(lb);
ub = orderfields(ub);
ParameterNames = sort(fieldnames(lb));

% also take note of which parmaeters are constrained
H = [ParameterNames{structlib.vectorise(ub) - structlib.vectorise(lb) == 0}];


% how many times should we fit each odorant?
N = 30; 


all_r2 = NaN(length(fd),N);


savename = [class(Model)  H '.fitparams'];


if exist(savename,'file') == 2
	load(savename,'-mat')
end


for j = 1:N
	for i = length(fd):-1:1


		if ~isnan(all_r2(i,j))
			continue
		end

		disp(['Fitting ' mat2str(i)])

		ub.t_offset = best_offsets(i);
		lb.t_offset = best_offsets(i);

		Model.Stimulus = fd(i).stimulus;
		Model.Response = fd(i).response;
		Model.Upper = ub;
		Model.Lower = lb;

		

		for k = 1:length(ParameterNames)
			Model.Parameters.(ParameterNames{k}) = 1;
		end

		% Model.Parameters = [];

	
		Model.fit;

		% estimate r2
		Model.evaluate;
		this_r2 = statlib.correlation(Model.Response,Model.Prediction);

		disp(['r^2 = ' strlib.oval(this_r2)])

		p(i,j) = Model.Parameters;

		disp(Model.Parameters)

		all_r2(i,j) = this_r2;


		if ismac
			close all
			drawnow
			Model.plot;
			drawnow
		end

		save(savename,'p','all_r2')
	end
end


return


% show all the fits 

figure('outerposition',[300 300 1200 600],'PaperUnits','points','PaperSize',[1200 600]); hold on

fn = setdiff(fieldnames(p),'t_offset');

for i = 1:length(fn)
	subplot(2,2,i); hold on

	for j = size(p,1):-1:1


		plot_this = [p(j,:).(fn{i})];
		plot_this(all_r2(j,:) < .99) = NaN;

		x = 0*plot_this(:) + j + randn(length(plot_this),1)/10;
		plot(x,plot_this,'k.')

	end

	set(gca,'YScale','log','XLim',[0 28])
	ylabel(fn{i})

end

figlib.pretty()


% show variations

figure('outerposition',[300 300 1200 600],'PaperUnits','points','PaperSize',[1200 600]); hold on
fn = {'k_a','k_d','tau_s','w'};
fn = {'k_d','w'};
idx = 1;
clear ax
for i = 1:length(fn)
	for j = 1:length(fn)

		if i >= j
			continue
		end

		ax(idx) = subplot(3,2,idx); hold on
		set(ax(idx),'YScale','log','XScale','log')
		xlabel(fn{i})
		ylabel(fn{j})
		

		for k = size(p,1):-1:1

			x = [p(k,:).(fn{i})];
			x(all_r2(k,:) < .99) = NaN;

			y = [p(k,:).(fn{j})];
			y(all_r2(k,:) < .99) = NaN;

			plot(x,y,'.','MarkerSize',20)

		end
		
		idx = idx + 1;

	end

end
figlib.pretty()


