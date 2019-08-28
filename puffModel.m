%% puffModel.m
% a simple model for puffs of odorant using two air streams

function [f2, x2] = puffModel(S,p)


	% unpack parameters  
	tau_s = (p.tau_s);
	w = (p.w);
	k_a = (p.k_a);
	k_d = (p.k_d);


	% geometrical parameters
	q1 = 3; % mL/s
	q2 = 30; % mL/s
	r2 = 2.425; % mm
	r1 = 2.7; % mm

	V2 = pi*r2*r2*90/1000;  % mL, /1000 comes from converting to mL

	% Pasteur pipette
	V1 = pi*r1*r1*90/1000; % mL

	% fixed parameters
	phi = q1/q2; % 3mL/s / 30 mL/s
	tau_2 = (V2/q2);
	L = V1/V2;


	ic = [1e-3 0 0 0];

	time = 1e-2*(1:length(S)); % 10 ms timestep
	Tspan = [min(time) max(time)];

	options = odeset('MaxStep',.01);
	warning off
	[T, Y] = ode23t(@(t,y) puffModel_ode(t,y,time,S),Tspan,ic,options); % Solve ODE
	warning on


	% re-interpolate the solution to fit the stimulus
	x2 = (interp1(T,Y(:,1),time)); x2 = x2(:);
	Theta2 = (interp1(T,Y(:,2),time));  Theta2 = Theta2(:);
	x1 = (interp1(T,Y(:,3),time)); x1 = x1(:);
	Theta1 = (interp1(T,Y(:,4),time)); Theta1 = Theta1(:);

	f2 = (1 + S(:)*phi).*x2(:);
	

	% normalise
	if max(x2) == 0
	else
		x2 = x2/max(x2(S>.9));
	end


	if max(f2) == 0
	else
		f2 = f2/max(f2(S>.9));
	end

	% allow for some offset in time
	x2 = circshift(x2,floor(p.t_offset));
	f2 = circshift(f2,floor(p.t_offset));


	function dy = puffModel_ode(t,y,time,odor)
		% calculate the odor at the time point


		stim = interp1(time,odor,t); % Interpolate the data set (ft,f) at time t

		% unpack variables
		x2 = y(1);
		Theta2 = y(2);
		x1 = y(3);
		Theta1 = y(4);


		dTheta2 = k_a*x2*(1 - Theta2) - k_d*Theta2;

		dx2 =  (stim*phi*x1)/tau_2 - ((1 + stim*phi)*x2)/tau_2 - w*dTheta2;

		dTheta1 = k_a*x1*(1-Theta1) - k_d*Theta1;

		dx1 = (1-x1)/tau_s - (stim*phi*x1)/(tau_2*L) - w*dTheta1;


		dy = 0*y;
		dy(1) = dx2;
		dy(2) = dTheta2;
		dy(3) = dx1;
		dy(4) = dTheta1; 

		dy = dy(:);
	end
end