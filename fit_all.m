% this script fits all the data from the puff dataset
% with a Model, and saves the fits
% assumes you have a struct called fd in the ws

% define upper and lower bounds


lb.t_offset = 0;
ub.t_offset = 10;

lb.k_a = 1e-3;
ub.k_a = 1e3;

lb.k_d = 1e-3;
ub.k_d = 1e2;

lb.w = 0;
ub.w = 1e3;

lb.tau_s = 1e-6;
ub.tau_s = 10;


load best_offsets
load fit_data

Model = TwoTubes_f2;


clear p

N = 30; % try to fit each odorant N times
all_r2 = NaN(length(fd),N);


% does .fitparams already exist?
savename = [class(Model) '.fitparams'];


if ~exist('p','var') 
	p = repmat(ub,27,N);

end

for j = 1:N

	for i = length(fd):-1:1
		disp(['Fitting ' mat2str(i)])

		% ub.t_offset = best_offsets(i);
		% lb.t_offset = best_offsets(i);

		Model.Stimulus = fd(i).stimulus;
		Model.Response = fd(i).response;
		Model.Upper = ub;
		Model.Lower = lb;

		Model.Parameters = [];

	
		Model.fit;

		% estimate r2
		Model.evaluate;
		this_r2 = statlib.correlation(Model.Response,Model.Prediction);

		disp(['r^2 = ' strlib.oval(this_r2)])

		p(i,j) = Model.Parameters;

		all_r2(i,j) = this_r2;


		close all
		drawnow

		Model.plot
		drawnow
		save(savename,'p','all_r2')
	end
end



% show all the fits 

figure('outerposition',[300 300 1200 600],'PaperUnits','points','PaperSize',[1200 600]); hold on

fn = {'k_a','k_d','tau_s','w'};

for i = 1:length(fn)
	subplot(2,2,i); hold on

	for j = size(p,1):-1:1


		plot_this = [p(j,:).(fn{i})];
		plot_this(all_r2(j,:) < .99) = NaN;

		x = 0*plot_this(:) + j + randn(size(p,2),1)/10;
		plot(x,plot_this,'k.')

	end

	set(gca,'YScale','log','XLim',[0 28])
	ylabel(fn{i})

end

figlib.pretty()


% show variations

figure('outerposition',[300 300 1200 600],'PaperUnits','points','PaperSize',[1200 600]); hold on
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
		

		for k = 1:size(p,1)

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


% order by variabnility in fit params
V = NaN(27,1);
for i = 1:27
	V(i) = mean([p(i,:).w]);
end
[~,idx] = sort(V);


Model.Response = fd(6).response;

figure('outerposition',[300 300 1200 600],'PaperUnits','points','PaperSize',[1200 600]); hold on

plot(Model.Response,'k')

for i = 1:10
	Model.Parameters = p(6,i);
	Model.evaluate;
	plot(Model.Prediction)
end




Model.Response = fd(1).response;
Model.Parameters = p(1,1);

tau_s = logspace(-15,-1,100);
tau_s_r2 = NaN*tau_s;

for i = 1:length(tau_s)
	Model.Parameters.tau_s = tau_s(i);
	Model.evaluate;

	tau_s_r2(i) = statlib.correlation(Model.Response,Model.Prediction);

end
