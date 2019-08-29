% this script fits all the data from the puff dataset
% with a Model, and saves the fits
% assumes you have a struct called fd in the ws

% define upper and lower bounds


clearvars

% get data
load best_offsets
load fit_data

% define model to work with
Model = TwoTubesSimple;


% specify bounds. Parameters will be found 
% within these bounds

lb.t_offset = 0;
ub.t_offset = 10;

% lb.k_a = 1e-3;
% ub.k_a = 1e3;

lb.k_d = 1e-3;
ub.k_d = 1e3;

lb.w = 0;
ub.w = 1e3;

lb.tau_s = 1e-6;
ub.tau_s = 10;




% define bounds for initial seeds
seed_lb = orderfields(lb);
seed_ub = orderfields(ub);





% how many times should we fit each odorant?
N = 30; 


all_r2 = NaN(length(fd),N);


savename = [class(Model) '.fitparams'];


if exist(savename,'file') == 2
	load(savename,'-mat')
end



for i = length(fd):-1:1

	for j = 1:N

		

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


		% pick a random seed
		slb = structlib.vectorise(seed_lb);
		sub = structlib.vectorise(seed_ub);
		ParameterNames = sort(fieldnames(seed_lb));


		% pick a random point within bounds
		x =  (sub-slb).*(rand(length(slb),1)) + slb;
		for k = 1:length(ParameterNames)
			Model.Parameters.(ParameterNames{k}) = x(k);
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


		close all
		drawnow

		Model.plot
		drawnow
		save(savename,'p','all_r2')
	end
end


return


% show all the fits 

figure('outerposition',[300 300 1200 600],'PaperUnits','points','PaperSize',[1200 600]); hold on

fn = {'k_a','k_d','tau_s','w'};

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

			plot(x,y,'.')

		end
		
		idx = idx + 1;

	end

end
figlib.pretty()


