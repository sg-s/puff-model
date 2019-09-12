clearvars
close all


c = lines(8);
c(2:4,:) = c([1 4 5],:);
c(1,:) = [1 0 0];

offset = 2;

figure('outerposition',[300 300 1001 666],'PaperUnits','points','PaperSize',[1001 666]); hold on


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

for i = 8:-1:1
	ax(i) = subplot(2,4,i); hold on
	set(ax(i),'XLim',[0 3])
end

for i = 1:8
	if rem(i,2) == 1
		ax(i).Position(3) = .25;
	else
		ax(i).Position(1) = ax(i).Position(1) + .075;
		ax(i).Position(3) = .15;
	end
end



% Case 1: zero or 1 parameter fits

show_these = [22 3];

plot(ax(1),alldata(2).time,alldata(2).PID,'Color',[.5 .5 .5])

load TwoTubesXk_dtau_atau_s.fitparams -mat

[~,idx] = max(all_r2(2,:));
Model.Parameters = p(2,idx);
Model.evaluate;

time = linspace(0,3,300);
plot(ax(1),time,Model.Prediction,'LineWidth',3,'Color',c(1,:))
title(ax(1),alldata(2).odour_name,'FontWeight','normal')


% now show 4 more examples in a smaller plot
for i = 1:length(show_these)
	PID = alldata(show_these(i)).PID;
	T = alldata(show_these(i)).time;
	plot(ax(2),T,offset*(i-1)+PID,'Color',[.5 .5 .5])

	% also show predictions

	[~,idx] = max(all_r2(show_these(i),:));
	Model.Parameters = p(show_these(i),idx);
	Model.evaluate;
	plot(ax(2),time,offset*(i-1)+Model.Prediction,'LineWidth',3,'Color',c(1,:))
	T = regexprep(alldata(show_these(i)).odour_name,'[\n\r]+','');
	text(1,offset*(i)-.5, T,'FontSize',12,'FontWeight','normal','Parent',ax(2));

end



% case 2: sharp odorants with paleteau 

plot(ax(3),time, fd(14).response,'Color',[.5 .5 .5])

load TwoTubesXtau_s.fitparams -mat

[~,idx] = max(all_r2(14,:));
Model.Parameters = p(14,idx);
Model.evaluate;

plot(ax(3),time,Model.Prediction,'LineWidth',3,'Color',c(2,:))
title(ax(3),alldata(14).odour_name,'FontWeight','normal')


show_these = [25 15];

% now show 4 more examples in a smaller plot
for i = 1:length(show_these)
	PID = alldata(show_these(i)).PID;
	T = alldata(show_these(i)).time;
	plot(ax(4),T,offset*(i-1)+PID,'Color',[.5 .5 .5])

	% also show predictions

	[~,idx] = max(all_r2(show_these(i),:));
	Model.Parameters = p(show_these(i),idx);
	Model.evaluate;
	time = linspace(0,3,300);
	plot(ax(4),time,offset*(i-1)+Model.Prediction,'LineWidth',3,'Color',c(2,:))
	T = regexprep(alldata(show_these(i)).odour_name,'[\n\r]+','');
	text(1,offset*(i)-.5, T,'FontSize',12,'FontWeight','normal','Parent',ax(4));
end




% case 3: high plateaus 



plot(ax(5),time, fd(6).response,'Color',[.5 .5 .5])

load TwoTubesXtau_s.fitparams -mat

[~,idx] = max(all_r2(6,:));
Model.Parameters = p(6,idx);
Model.evaluate;

plot(ax(5),time,Model.Prediction,'LineWidth',3,'Color',c(3,:))

title(ax(5),alldata(6).odour_name,'FontWeight','normal')


show_these = [17  20];

% now show 4 more examples in a smaller plot
for i = 1:length(show_these)
	PID = alldata(show_these(i)).PID;
	T = alldata(show_these(i)).time;
	plot(ax(6),T,offset*(i-1)+PID,'Color',[.5 .5 .5])

	% also show predictions

	[~,idx] = max(all_r2(show_these(i),:));
	Model.Parameters = p(show_these(i),idx);
	Model.evaluate;
	time = linspace(0,3,300);
	plot(ax(6),time,offset*(i-1)+Model.Prediction,'LineWidth',3,'Color',c(3,:))

	T = regexprep(alldata(show_these(i)).odour_name,'[\n\r]+','');
	text(1,offset*(i)-.5, T,'FontSize',12,'FontWeight','normal','Parent',ax(6));
end



% case 4: slow, with slower decays



plot(ax(7),time, fd(8).response,'Color',[.5 .5 .5])

load TwoTubesXtau_s.fitparams -mat

[~,idx] = max(all_r2(8,:));
Model.Parameters = p(8,idx);
Model.evaluate;

plot(ax(7),time,Model.Prediction,'LineWidth',3,'Color',c(4,:))

title(ax(7),alldata(8).odour_name,'FontWeight','normal')


show_these = [5 1 ];

% now show 2 more examples in a smaller plot
for i = 1:length(show_these)
	PID = alldata(show_these(i)).PID;
	T = alldata(show_these(i)).time;
	plot(ax(8),T,offset*(i-1)+PID,'Color',[.5 .5 .5])

	% also show predictions

	[~,idx] = max(all_r2(show_these(i),:));
	Model.Parameters = p(show_these(i),idx);
	Model.evaluate;
	time = linspace(0,3,300);
	plot(ax(8),time,offset*(i-1)+Model.Prediction,'LineWidth',3,'Color',c(4,:))

	T = regexprep(alldata(show_these(i)).odour_name,'[\n\r]+','');
	text(1,offset*(i)-.5, T,'FontSize',12,'FontWeight','normal','Parent',ax(8));

end

% set lims
for i = 2:2:8
	ax(i).YLim = [-.5 3];
	ax(i-1).YLim = [-.2 1.5];
	plot(ax(i-1),[0 3],[0 0],'k:')
end

for i = 1:8
	axis(ax(i),'off')
end




% move some axes around
axlib.move(ax([1 2 5 6]),'left',.075);






% add some annotations
a(1) = annotation('textarrow',[ 0.0975    0.1381],[0.7656    0.7225],'String','Sharp rise');
a(2) = annotation('textarrow',[0.2323 0.2015],[0.7799 0.7329],'String','Sharp drop');
a(3) = annotation('textarrow',[0.7362 0.7362],[0.7086 0.6686],'String','Lingering plateau');
a(4) = annotation('textarrow',[0.6062 0.6258],[0.7620 0.7201],'String','Sharp rise');
a(5) = annotation('textarrow',[0.2623 0.2623],[0.2172 0.2472],'String','Large plateau');
a(6) = annotation('textarrow',[0.2269 0.1985],[0.3249 0.3251],'String','Sharp drop');
a(7) = annotation('textarrow',[0.1146 0.1446],[0.2919 0.2335],'String',['Fast, then ' newline 'slow rise']);
a(8) = annotation('textarrow',[0.6092 0.6346],[0.3129 0.2725],'String','Slow rise');
a(9) = annotation('textarrow',[0.7231 0.6977],[0.3054 0.2833],'String','Slower decay');

for i = 1:length(a)
	a(i).FontSize = 12;
end

figlib.pretty('FontSize',14)




% now make a supplementary figure showing all the fits to all the odorants 

figure('outerposition',[300 300 1200 1001],'PaperUnits','points','PaperSize',[1200 1001]); hold on

for i = 1:length(alldata)
	subplot(5,6,i); hold on
	PID = alldata(i).PID;
	T = alldata(i).time;
	plot(T,PID,'Color',[.5 .5 .5])
	title(alldata(i).odour_name,'FontWeight','normal')
	set(gca,'XLim',[0.5 3],'YLim',[-.2 1.1])
	axis off

	[~,idx] = max(all_r2(i,:));
	Model.Parameters = p(i,idx);
	Model.evaluate;
	time = linspace(0,3,300);
	plot(time,Model.Prediction,'LineWidth',2,'Color','r')
end

figlib.pretty()





% now make a supplementary figure showing the range of parameters
figure('outerposition',[1 1 880 901],'PaperUnits','points','PaperSize',[880 901]); hold on

clear ax

fn = {'w','tau_a','k_d'};

show_these = setdiff(1:27,[2 3 4 7 25 26]);

clear ax

for i = length(fn):-1:1
	ax(i) = subplot(3,1,i); hold on

	X = {};

	for j = length(show_these):-1:1


		plot_this = [p(show_these(j),:).(fn{i})];

		errorbar(j,mean(plot_this),std(plot_this),'Color','r')
		plot(j,mean(plot_this),'o','Color','r')

		X{j} = alldata(show_these(j)).odour_name;
		X{j} = regexprep(X{j},'[\n\r]+','');

	end

	set(gca,'YScale','log','XLim',[0 length(show_these)+1],'XTickLabel','','YMinorGrid','on')
	ylabel(fn{i})



end

set(ax(3),'XTickLabel',X,'XTick',1:length(show_these),'XTickLabelRotation',45)

ylabel(ax(2),'\tau_a')
ylabel(ax(3),'K_D')

figlib.pretty()

for i = 1:length(ax)
	ax(i).Position(4) = .2;
end

ax(3).Position(2) = .2;
ax(2).Position(2) = .45;
ax(1).Position(2) = .7;
ax(3).YLim = [10 1e3];

