

%% Pulse Kinetics
% In this figure, I show the diversity of pulse kinetics and fit a model to reproduce these kinetics


% specify model to use
Model = TwoTubes;

load('alldata')


% remove PID baseline from all the data
for i = 1:length(alldata)
	for j = 1:size(alldata(i).PID,2)
		alldata(i).PID(:,j) = alldata(i).PID(:,j) - mean(alldata(i).PID(1:500,j));
	end
end

figure('outerposition',[0 0 1000 901],'PaperUnits','points','PaperSize',[1000 901]); hold on
clear ax fd
c = 36;
sp = [4:6 10:12 16:36];

for i = length(alldata):-1:1
	ax(i) = subplot(6,6,sp(i)); hold on; c = c - 1;
	title(alldata(i).odour_name)
	S = alldata(i).PID;
	conc = alldata(i).conc;
	if ~any(isnan(conc))
		% more than one concenration, pick the max
		S = S(:,conc == max(conc));

	end

	% normalise
	for j = 1:size(S,2)
		S(:,j) = S(:,j)/max(S(:,j));
	end

	time = 1e-3*(1:length(S));
	plot(time,S,'Color',[.5 .5 .5])
	set(ax(i),'XLim',[0.5 3],'YLim',[-.1 1.05])

	all_S = S;

	% save for fitting
	S = mean(S,2);
	z = 3e3;
	all_S = all_S(1:z,:);
	all_S = all_S(1:10:end,:);
	S = S(1:z); % ten seconds enough
	S = S(1:10:end); % now at 10 ms timestep
	S = S/max(S);
	S(S<0) = 0;
	fd(i).response = S;
	P = 0*S;
	t = 1:length(P);
	P1 = 1 - exp(-(t-98)/2.5);
	P2 = exp(-(t-147)/3.8);
	P(100:150) = P1(100:150);
	P(151:end) = P2(151:end);
	fd(i).stimulus = P;
	fd(i).response(1:90) = NaN;



end

% add a cartoon showing the puff 
ax_cartoon = subplot(6,6,[1:3 7:9 13:15]); hold on
figlib.showImageInAxes(ax_cartoon,imread('puff-schematic.png'))

ax_cartoon.Position = [.1 .55 .36 .36];



% show the simulations too

savename = [class(Model) '.fitparams'];
load(savename,'-mat')




for i = length(fd):-1:1

	% pick the best r^2
	this_r2 = all_r2(i,:);
	[~,pick_me] = max(this_r2);


	Model.Stimulus = fd(i).stimulus;
	Model.Parameters = p(i,pick_me);
	try
		Model.evaluate;
		plot(ax(i),time(1:10:3e3),Model.Prediction,'r')
	catch
		
	end
	axis(ax(i),'off')
end

figlib.pretty('FontSize',13)