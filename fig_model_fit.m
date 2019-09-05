% this figure shows the data, with fits from the two tube model
% and its many reductions 

clearvars
close all


load fit_data
load alldata

Model = TwoTubesX;
Model.Stimulus = fd(1).stimulus;


figure('outerposition',[300 300 1200 600],'PaperUnits','points','PaperSize',[1200 600]); hold on

for i = 1:27
	ax(i) = subplot(5,6,i); hold on

end


% first show fast odorants and the two parameter fit 
load TwoTubesXk_dtau_a.fitparams -mat


show_these{1} = [ 2 3 4 10 11 7] % 25 ]; %26];

for i = 1:length(show_these{1})
	[~,idx] = max(all_r2(show_these{1}(i),:));
	Model.Parameters = p(show_these{1}(i),idx);
	Model.evaluate;

	title(ax(i),alldata(show_these{1}(i)).odour_name)
	S = alldata(show_these{1}(i)).PID;
	conc = alldata(show_these{1}(i)).conc;
	if ~any(isnan(conc))
		% more than one concenration, pick the max
		S = S(:,conc == max(conc));

	end

	% normalise
	for j = 1:size(S,2)
		S(:,j) = S(:,j) - mean(S(1:1e3,j));
		S(:,j) = S(:,j)/max(S(:,j));
	end

	time = 1e-3*(1:length(S));
	plot(ax(i),time,S,'Color',[.5 .5 .5])
	set(ax(i),'XLim',[0.5 3],'YLim',[-.1 1.05])

	Model.Response = fd(show_these{1}(i)).response;

	time = linspace(0,3,300);
	plot(ax(i),time,Model.Prediction,'r')
end

offset = i;


% now show the medium odorants with the 3 parameter fits 

load TwoTubesXtau_a.fitparams -mat

show_these{2} = [5 9 18 16];

for i = 1:length(show_these{2})

	title(ax(i+offset),alldata(show_these{2}(i)).odour_name)
	S = alldata(show_these{2}(i)).PID;
	conc = alldata(show_these{2}(i)).conc;
	if ~any(isnan(conc))
		% more than one concenration, pick the max
		S = S(:,conc == max(conc));

	end

	% normalise
	for j = 1:size(S,2)
		S(:,j) = S(:,j) - mean(S(1:1e3,j));
		S(:,j) = S(:,j)/max(S(:,j));
	end

	time = 1e-3*(1:length(S));
	plot(ax(i+offset),time,S,'Color',[.5 .5 .5])
	set(ax(i+offset),'XLim',[0.5 3],'YLim',[-.1 1.05])



	[~,idx] = max(all_r2(show_these{2}(i),:));
	Model.Parameters = p(show_these{2}(i),idx);
	Model.Response = fd(show_these{2}(i)).response;
	Model.evaluate;
	time = linspace(0,3,300);
	plot(ax(i+offset),time,Model.Prediction,'b')
end

offset = offset + i;



% now the really slow ones


load TwoTubesX.fitparams -mat

show_these{3} = setdiff(1:27,[show_these{:}]);

for i = 1:length(show_these{3})
	[~,idx] = max(all_r2(show_these{3}(i),:));
	Model.Parameters = p(show_these{3}(i),idx);
	Model.Parameters.tau_s = 0;
	Model.evaluate;

	title(ax(i+offset),alldata(show_these{3}(i)).odour_name)
	S = alldata(show_these{3}(i)).PID;
	conc = alldata(show_these{3}(i)).conc;
	if ~any(isnan(conc))
		% more than one concenration, pick the max
		S = S(:,conc == max(conc));

	end

	% normalise
	for j = 1:size(S,2)
		S(:,j) = S(:,j) - mean(S(1:1e3,j));
		S(:,j) = S(:,j)/max(S(:,j));
	end

	time = 1e-3*(1:length(S));
	plot(ax(i+offset),time,S,'Color',[.5 .5 .5])
	set(ax(i+offset),'XLim',[0.5 3],'YLim',[-.1 1.05])


	time = linspace(0,3,300);
	plot(ax(i+offset),time,Model.Prediction,'g')

end


for i = 1:length(ax)
	axis(ax(i),'off')

end


figlib.pretty()


return


% now show how widely distributed the parameters for the 2-parameter model are
% this is as simple as showing a plane 


figure('outerposition',[300 300 1200 600],'PaperUnits','points','PaperSize',[1200 600]); hold on
load TwoTubesXk_dtau_a.fitparams -mat
fn = {'w','tau_s'};


for i = 1:length(fn)
	subplot(1,2,i); hold on

	X = {};

	for j = 1:length(show_these{1})


		plot_this = [p(show_these{1}(j),:).(fn{i})];
		plot_this(all_r2(show_these{1}(j),:) < .99) = NaN;

		x = 0*plot_this(:) + j + randn(length(plot_this),1)/10;
		plot(x,plot_this,'k.')

		X{j} = alldata(show_these{1}(j)).odour_name;
		X{j} = regexprep(X{j},'[\n\r]+','');

	end

	set(gca,'YScale','linear','XLim',[0 length(show_these{1}+1)])
	ylabel(fn{i})

	set(gca,'XTickLabel',X,'XTick',1:length(show_these{1}),'XTickLabelRotation',45)

end

figlib.pretty()




% now show the 3-parameter fits

figure('outerposition',[300 300 1200 600],'PaperUnits','points','PaperSize',[1200 600]); hold on
load TwoTubesXtau_a.fitparams -mat

fn = {'w','tau_s','k_d'};


for i = 1:length(fn)
	subplot(1,3,i); hold on

	X = {};

	for j = 1:length(show_these{2})


		plot_this = [p(show_these{2}(j),:).(fn{i})];
		plot_this(all_r2(show_these{2}(j),:) < .99) = NaN;

		x = 0*plot_this(:) + j + randn(length(plot_this),1)/10;
		plot(x,plot_this,'k.')

		X{j} = alldata(show_these{2}(j)).odour_name;
		X{j} = regexprep(X{j},'[\n\r]+','');

	end

	set(gca,'YScale','log','XLim',[0 length(show_these{2}+1)])
	ylabel(fn{i})

	set(gca,'XTickLabel',X,'XTick',1:length(show_these{2}),'XTickLabelRotation',45)

end

figlib.pretty()


