clearvars
close all


c = lines(8);
c(2:4,:) = c([1 4 5],:);
c(1,:) = [1 0 0];



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
	if i > 1
		plot(ax(i).hero,[0 3],[0 0],'k:')
	end
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
plot(ax(2).hero,time,Model.Prediction,'Color',c(1,:))
title(ax(2).hero,alldata(2).odour_name,'FontWeight','normal')


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
	plot(ax(2).examples(i),time,Model.Prediction,'Color',c(1,:))
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

plot(ax(3).hero,time,Model.Prediction,'Color',c(2,:))
title(ax(3).hero,alldata(14).odour_name,'FontWeight','normal')

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
	plot(ax(3).examples(i),time,Model.Prediction,'Color',c(2,:))
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

plot(ax(4).hero,time,Model.Prediction,'Color',c(3,:))

title(ax(4).hero,alldata(6).odour_name,'FontWeight','normal')


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
	plot(ax(4).examples(i),time,Model.Prediction,'Color',c(3,:))

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

plot(ax(5).hero,time,Model.Prediction,'Color',c(4,:))

title(ax(5).hero,alldata(8).odour_name,'FontWeight','normal')


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
	plot(ax(5).examples(i),time,Model.Prediction,'Color',c(4,:))

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


% add some annotations
a(1) = annotation('textarrow',[0.1552    0.1958],[0.7491    0.7060],'String','Sharp rise');
a(2) = annotation('textarrow',[0.35    0.3],[.7 .7],'String','Sharp drop');
a(3) = annotation('textarrow',[0.4    0.4],[.52 .48],'String','Lingering plateau');
a(4) = annotation('textarrow',[0.1552    0.1958],[0.54    0.5],'String','Sharp rise');
a(5) = annotation('textarrow',[0.4    0.4],[.31 .34],'String','Large plateau');
a(6) = annotation('textarrow',[0.35    0.3],[.37 .37],'String','Sharp drop');
a(7) = annotation('textarrow',[0.16    0.21],[0.36    0.33],'String',['Fast, then ' newline 'slow rise']);
a(8) = annotation('textarrow',[0.16    0.21],[0.2    0.17],'String','Slow rise');
a(9) = annotation('textarrow',[0.35    0.3],[.2 .18],'String','Slower decay');


% now make a supplementary figure showing the range of parameters
figure('outerposition',[1 1 880 901],'PaperUnits','points','PaperSize',[880 901]); hold on

clear ax

fn = {'w','tau_a','k_d'};




% don't show zero or 1 parameter fits, and show them in the order that they are presented in 

show_these = [14 25  15 16 18 6 17  23 19 20 8 5 1 12 27];

C = zeros(15,3);
c = lines;

for i = 1:5
	C(i,:) = c(1,:);
end
for i = 6:10
	C(i,:) = c(2,:);
end
for i = 11:15
	C(i,:) = c(4,:);
end



for i = 1:length(fn)
	ax(i) = subplot(3,1,i); hold on

	X = {};

	for j = 1:length(show_these)


		plot_this = [p(show_these(j),:).(fn{i})];

		errorbar(j,mean(plot_this),std(plot_this),'Color',C(j,:))
		plot(j,mean(plot_this),'o','Color',C(j,:))

		X{j} = alldata(show_these(j)).odour_name;
		X{j} = regexprep(X{j},'[\n\r]+','');

	end

	set(gca,'YScale','log','XLim',[0 length(show_these)+1],'XTickLabel','','YMinorGrid','on')
	ylabel(fn{i})



end

set(gca,'XTickLabel',X,'XTick',1:length(show_these),'XTickLabelRotation',45)

figlib.pretty()

for i = 1:length(ax)
	ax(i).Position(4) = .2;
end

ax(3).Position(2) = .2;
ax(2).Position(2) = .45;
ax(1).Position(2) = .7;
ax(3).YLim = [10 1e3];

