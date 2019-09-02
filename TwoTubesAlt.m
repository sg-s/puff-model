% This implements a simpler 2-ODe model 
% where the key assumption is that the interaction with
% surfaces equilibrates rapidly 
% In this version, the parameters are slightly different
% because it looks like (from previous fitting efforts)
% that the old set of parameters were a little redundant 
% This model allows us to switch b/w a simpler and the full
% model by setting a single parameter (tau_a) to zero

classdef TwoTubesAlt < model & ConstructableHandle


properties

end % props



methods 


	function self = TwoTubesAlt(varargin)

		self = self@ConstructableHandle(varargin{:});   

		if isempty(self.Parameters)
			self.Parameters = struct;
			self.Parameters.t_offset = 1;
			self.Parameters.tau_s = 1e-1;
			self.Parameters.tau_a = 1e-1;
			self.Parameters.W = 1;
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
		L = V1/V2;


		% unpack parameters
		t_offset = self.Parameters.t_offset;
		tau_s = self.Parameters.tau_s;
		tau_a = self.Parameters.tau_a;
		W = self.Parameters.W;
		k_d = self.Parameters.k_d;

		% x12 theta1 x2 theta2
		ic = [1 1/(1+k_d) 0 0];

		S = self.Stimulus;

		time = 1e-2*(1:length(S)); % 10 ms timestep
		Tspan = [min(time) max(time)];

		options = odeset('MaxStep',.1);
		warning off
		[T, Y] = ode23t(@(t,y) SimplifedODE(t,y,time,S),Tspan,ic,options); % Solve ODE
		warning on


		% re-interpolate the solution to fit the stimulus
		x2 = corelib.vectorise(interp1(T,Y(:,3),time));


		% allow for some offset in time
		x2 = circshift(x2,floor(self.Parameters.t_offset));


		f2 = (1 + S(:)*phi).*x2(:);

		if max(f2) == 0
		else
			f2 = f2/max(f2(find(time>1,1,'first'):find(time<3,1,'last')));
		end

		self.Prediction = f2;

		function dy = SimplifedODE(t,y,time,odor)
			% calculate the odor at the time point
			stim = interp1(time,odor,t); % Interpolate the data set (ft,f) at time t

			% unpack variables
			x1 = y(1);
			Theta1 = y(2);
			x2 = y(3);
			Theta2 = y(4);

			dTheta2 = 0;
			if tau_a > 1
				dTheta2 = x2*(1-Theta2)/tau_a - k_d*Theta2/tau_a;
			end

			dx2 = (stim*phi*x1)/tau_2 - (1+ stim*phi)*x2/tau_2 - W*dTheta2;

			dTheta1 = 0;
			if tau_a > 0
				dTheta1 = x1*(1 - Theta1)/tau_a - k_d*Theta1/tau_a;
			end

			dx1 = (1 - x1)/tau_s - (stim*phi*x1)/(tau_2) - W*dTheta1;

			dy = 0*y;
			dy(1) = dx1;
			dy(2) = dTheta1;
			dy(3) = dx2;
			dy(4) = dTheta2;

			dy = dy(:);
		end



	end % evaluate 





end % methods

end % classdef 