clearvars
close all


figure('outerposition',[300 300 601 901],'PaperUnits','points','PaperSize',[601 901]); hold on


load alldata
load fit_data

Model = TwoTubesX;
Model.Stimulus = fd(1).stimulus;

% clean up plot data
for i = 1:length(alldata)

	S = alldata(i).PID;
	conc = alldata(i).conc;
	if ~any(isnan(conc))
		% more than one concentration, pick the max
		S = S(:,conc == max(conc));
	end

	% normalise
	for j = 1:size(S,2)
		S(:,j) = S(:,j) - mean(S(1:1e3,j));
		S(:,j) = S(:,j)/max(S(:,j));
	end
	alldata(i).PID = S;
	alldata(i).time = (1:length(S))*1e-3;
end


clear ax

for i = 1:5
	ax(i).hero = subplot(5,2,(i-1)*2+1); hold on
	set(ax(i).hero,'XLim',[.5 3],'YLim',[-.1 1.1])
	plot(ax(i).hero,[0 3],[0 0],'k:')
	axis off
end

base = [11 12 15 16];

for i = 2:5
	for j = 1:4
		ax(i).examples(j) = subplot(10,4,base(j)+(i-2)*8); hold on
		set(ax(i).examples(j),'XLim',[.5 3],'YLim',[-.1 1.1])
		axis off
	end

end


% Case 1: zero or 1 parameter fits

show_these = [3  4 7 22];

plot(ax(2).hero,alldata(2).time,alldata(2).PID,'Color',[.5 .5 .5])

load TwoTubesXk_dtau_atau_s.fitparams -mat

[~,idx] = max(all_r2(2,:));
Model.Parameters = p(2,idx);
Model.evaluate;

time = linspace(0,3,300);
plot(ax(2).hero,time,Model.Prediction,'r')


% now show 4 more examples in a smaller plot
for i = 1:length(show_these)
	PID = alldata(show_these(i)).PID;
	T = alldata(show_these(i)).time;
	plot(ax(2).examples(i),T,PID,'Color',[.5 .5 .5])

	% also show predictions

	[~,idx] = max(all_r2(2,:));
	Model.Parameters = p(show_these(i),idx);
	Model.evaluate;
	time = linspace(0,3,300);
	plot(ax(2).examples(i),time,Model.Prediction,'r')
	T = regexprep(alldata(show_these(i)).odour_name,'[\n\r]+','');
	title(ax(2).examples(i),T,'FontSize',12,'FontWeight','normal')
end



% case 2: sharp odorants with paleteau 


time = linspace(0,3,300);
plot(ax(3).hero,time, fd(14).response,'Color',[.5 .5 .5])

load TwoTubesXtau_s.fitparams -mat

[~,idx] = max(all_r2(14,:));
Model.Parameters = p(14,idx);
Model.evaluate;

plot(ax(3).hero,time,Model.Prediction,'r')


show_these = [25  15 16 18];

% now show 4 more examples in a smaller plot
for i = 1:length(show_these)
	PID = alldata(show_these(i)).PID;
	T = alldata(show_these(i)).time;
	plot(ax(3).examples(i),T,PID,'Color',[.5 .5 .5])

	% also show predictions

	[~,idx] = max(all_r2(2,:));
	Model.Parameters = p(show_these(i),idx);
	Model.evaluate;
	time = linspace(0,3,300);
	plot(ax(3).examples(i),time,Model.Prediction,'r')
	T = regexprep(alldata(show_these(i)).odour_name,'[\n\r]+','');
	title(ax(3).examples(i),T,'FontSize',12,'FontWeight','normal')
end






% case 3: high plateaus 




time = linspace(0,3,300);
plot(ax(4).hero,time, fd(6).response,'Color',[.5 .5 .5])

load TwoTubesXtau_s.fitparams -mat

[~,idx] = max(all_r2(6,:));
Model.Parameters = p(6,idx);
Model.evaluate;

plot(ax(4).hero,time,Model.Prediction,'r')


show_these = [17  23 19 20];

% now show 4 more examples in a smaller plot
for i = 1:length(show_these)
	PID = alldata(show_these(i)).PID;
	T = alldata(show_these(i)).time;
	plot(ax(4).examples(i),T,PID,'Color',[.5 .5 .5])

	% also show predictions

	[~,idx] = max(all_r2(2,:));
	Model.Parameters = p(show_these(i),idx);
	Model.evaluate;
	time = linspace(0,3,300);
	plot(ax(4).examples(i),time,Model.Prediction,'r')

	T = regexprep(alldata(show_these(i)).odour_name,'[\n\r]+','');
	title(ax(4).examples(i),T,'FontSize',12,'FontWeight','normal')
end




% case 4: slow, with slower decays


time = linspace(0,3,300);
plot(ax(5).hero,time, fd(8).response,'Color',[.5 .5 .5])

load TwoTubesXtau_s.fitparams -mat

[~,idx] = max(all_r2(8,:));
Model.Parameters = p(8,idx);
Model.evaluate;

plot(ax(5).hero,time,Model.Prediction,'r')


show_these = [5 1 12 27];

% now show 4 more examples in a smaller plot
for i = 1:length(show_these)
	PID = alldata(show_these(i)).PID;
	T = alldata(show_these(i)).time;
	plot(ax(5).examples(i),T,PID,'Color',[.5 .5 .5])

	% also show predictions

	[~,idx] = max(all_r2(2,:));
	Model.Parameters = p(show_these(i),idx);
	Model.evaluate;
	time = linspace(0,3,300);
	plot(ax(5).examples(i),time,Model.Prediction,'r')

	T = regexprep(alldata(show_these(i)).odour_name,'[\n\r]+','');
	title(ax(5).examples(i),T,'FontSize',12,'FontWeight','normal')
end


figlib.pretty('FontSize',12)

% make the example plots smaller

for i = 2:5
	for j = 1:4
		ax(i).examples(j).Position(3) = .14;
		ax(i).examples(j).Position(4) = .04;
	end
end

axlib.move(ax(2).examples,'up',.03)
axlib.move(ax(3).examples,'up',.02)




% now make a supplementary figure showing the range of parameters
figure('outerposition',[300 300 880 901],'PaperUnits','points','PaperSize',[880 901]); hold on

fn = {'w','tau_a','k_d'};


% don't show zero or 1 parameter fits
show_these = setdiff(1:27,[2 3 4 7 26 22]);

for i = 1:length(fn)
	subplot(3,1,i); hold on

	X = {};

	for j = 1:length(show_these)


		plot_this = [p(show_these(j),:).(fn{i})];

		x = 0*plot_this(:) + j + randn(length(plot_this),1)/10;
		plot(x,plot_this,'k.')

		X{j} = alldata(show_these(j)).odour_name;
		X{j} = regexprep(X{j},'[\n\r]+','');

	end

	set(gca,'YScale','log','XLim',[0 length(show_these)+1],'XTickLabel','')
	ylabel(fn{i})



end

set(gca,'XTickLabel',X,'XTick',1:length(show_these),'XTickLabelRotation',45)

figlib.pretty()

