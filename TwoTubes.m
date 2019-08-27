classdef TwoTubes < model & ConstructableHandle


properties

end % props



methods 


	function self = TwoTubes(varargin)

		self = self@ConstructableHandle(varargin{:});   

		if isempty(self.Parameters)
			self.Parameters = struct;
			self.Parameters.t_offset = 1;
			self.Parameters.k_a = 1;
			self.Parameters.k_d = 1;
			self.Parameters.w = 1;
			self.Parameters.tau_s = 1e-1;
		end

	end % constructor 


	function evaluate(self)

		assert(~isempty(self.Parameters),'Parameters should not be empty')
		assert(~isempty(self.Stimulus),'Stimulus should not be empty')

		self.Prediction = puffModel(self.Stimulus,self.Parameters);

	end % evaluate 





end % methods

end % classdef 