% This model implements the two tube model, with two
% reductions built in. So in effect, there are three models
% here:
% 
% 1. The full model with 4 ODEs and 4 parameters 
% 2. The reduced model assuming fast surface interactions
% 3. The even more reduced model assuming large K_D
%
% Note that the parameters mean different things based on which 
% reduction you are using

classdef TwoTubesX < model & ConstructableHandle


properties

end % props



methods 


	function self = TwoTubesX(varargin)

		self = self@ConstructableHandle(varargin{:});   

		if isempty(self.Parameters)
			self.Parameters = struct;
			self.Parameters.t_offset = 1;
			self.Parameters.tau_s = 1e-1;
			self.Parameters.tau_a = 1e-1;
			self.Parameters.w = 1;
			self.Parameters.k_d = 1;
			
			
		end

	end % constructor 


	function evaluate(self)

		assert(~isempty(self.Parameters),'Parameters should not be empty')
		assert(~isempty(self.Stimulus),'Stimulus should not be empty')


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
		tau_2 = (V2/q2); % seconds

		tau_2 = tau_2/2;


		L = V1/V2;


		% unpack parameters
		t_offset = self.Parameters.t_offset;
		tau_s = self.Parameters.tau_s;
		tau_a = self.Parameters.tau_a;
		w = self.Parameters.w;
		k_d = self.Parameters.k_d;

		% x12 theta1 x2 theta2
		




		S = self.Stimulus;

		time = 1e-2*(1:length(S)); % 10 ms timestep
		Tspan = [min(time) max(time)];

		% allow for some offset in time
		S = circshift(S,floor(self.Parameters.t_offset));


		options = odeset('MaxStep',.1);
		warning off

		if tau_a == 0 && k_d == 0
			% interpret this as k_d being equal to infinity 
			% and use the 2-param model
			ic = [1 0];
			[T, Y] = ode23t(@(t,y) TwoParamODE(t,y,time,S),Tspan,ic,options); % Solve ODE

			% re-interpolate the solution to fit the stimulus
			x2 = corelib.vectorise(interp1(T,Y(:,2),time));

		elseif tau_a == 0 
			% 3 param model
			ic = [1 0];
			[T, Y] = ode23t(@(t,y) ThreeParamODE(t,y,time,S),Tspan,ic,options); % Solve ODE

			% re-interpolate the solution to fit the stimulus
			x2 = corelib.vectorise(interp1(T,Y(:,2),time));
		else
			% full model
			ic = [1 1/(1+k_d) 0 0];
			[T, Y] = ode23t(@(t,y) FullODE(t,y,time,S),Tspan,ic,options); % Solve ODE

			% re-interpolate the solution to fit the stimulus
			x2 = corelib.vectorise(interp1(T,Y(:,3),time));

		end

		warning on


		
	


		f2 = (1 + S(:)*phi).*x2(:);

		if max(f2) == 0
		else
			f2 = f2/max(f2(find(time>1,1,'first'):find(time<3,1,'last')));
		end

		self.Prediction = f2;

		function dy = FullODE(t,y,time,odor)
			% calculate the odor at the time point
			stim = interp1(time,odor,t); % Interpolate the data set (ft,f) at time t

			% unpack variables
			x1 = y(1);
			Theta1 = y(2);
			x2 = y(3);
			Theta2 = y(4);


			dTheta2 = x2*(1-Theta2)/tau_a - k_d*Theta2/tau_a;

			dx2 = (stim*phi*x1)/tau_2 - (1+ stim*phi)*x2/tau_2 - w*dTheta2;


			dTheta1 = x1*(1 - Theta1)/tau_a - k_d*Theta1/tau_a;

			if tau_s == 0
				dx1 = 0;
				x(1) = 1;
			else
				dx1 = (1 - x1)/tau_s - (stim*phi*x1)/(tau_2) - w*dTheta1;
			end

			dy = 0*y;
			dy(1) = dx1;
			dy(2) = dTheta1;
			dy(3) = dx2;
			dy(4) = dTheta2;

			dy = dy(:);
		end





		% in this simplification, we assume that tau_a = 0 
		% so the theta ODEs are at steady state
		function dy = ThreeParamODE(t,y,time,odor)
			stim = interp1(time,odor,t); 

			% unpack variables
			x1 = y(1);
			x2 = y(2);


			effective_tau = tau_2*(1 + (w/k_d)/((1+(x2/k_d))^2));

			dx2 =  (stim*phi*x1 - ((1 + stim*phi)*x2))/effective_tau;


			effective_tau = 1 + (w/k_d)/((1+(x1/k_d))^2);


			if tau_s == 0
				dx1 = 0;
				x1 = 1;
			else
				dx1 = ((1-x1)/tau_s - (stim*phi*x1)/(tau_2*L))/effective_tau;
			end


			dy = y;
			dy(1) = dx1;
			dy(2) = dx2;


		end




		% in this simplification, we assume that tau_a = 0
		% and k_D is very large, so that the only other
		% parameter that matters is w/k_D, so here,
		% we effectively have 2 parameters 
		% this case is triggered when k_D = 0
		% (Yes, I know it's weird, but this is it)
		%
		% The only two parameters that matter here are:
		% tau_s and w
		function dy = TwoParamODE(t,y,time,odor)

			stim = interp1(time,odor,t); 

			% unpack variables
			x1 = y(1);
			x2 = y(2);


			effective_tau = tau_2*(1 + w);

			dx2 =  (stim*phi*x1 - ((1 + stim*phi)*x2))/effective_tau;


			effective_tau = 1 + w;

			if tau_s == 0 
				dx1 = 0;
				x(1) = 1;
			else
				dx1 = ((1-x1)/tau_s - (stim*phi*x1)/(tau_2*L))/effective_tau;
			end

			dy = y;
			dy(1) = dx1;
			dy(2) = dx2;



		end






	end % evaluate 





end % methods

end % classdef 