classdef (Abstract) model < handle 

properties


	Stimulus
	Parameters
	Response
	Prediction


	Lower
	Upper



end % props

properties (Access = protected)
	ParameterNames
end

methods


	function evaluate(self)
	end




	function fit(self)

		assert(~isempty(self.Upper),'Upper bounds must be set')
		assert(~isempty(self.Lower),'Lower bounds must be set')

		lb = structlib.vectorise(orderfields(self.Lower));
		ub = structlib.vectorise(orderfields(self.Upper));

		assert(length(lb) == length(ub),'Length of Upper and Lower bounds not the same')

		self.ParameterNames = sort(fieldnames(self.Upper));

		assert(length(ub) == length(self.ParameterNames),'Length of ParameterNames does not match bounds')

		if isempty(self.Parameters)
			% pick a random point within bounds
			x =  (ub-lb).*(rand(length(lb),1)) + lb;
			for i = 1:length(self.ParameterNames)
				self.Parameters.(self.ParameterNames{i}) = x(i);
			end
		end

		psoptions = optimoptions('particleswarm');
		psoptions.UseParallel = true;
		psoptions.MaxIterations = 50;

		psoptions.Display = 'final';

		psoptions.InitialSwarmMatrix = structlib.vectorise(self.Parameters)';

	

		x = particleswarm(@(x) self.fitEvaluate(x),length(psoptions.InitialSwarmMatrix), lb,ub, psoptions);

		for i = 1:length(self.ParameterNames)
			self.Parameters.(self.ParameterNames{i}) = x(i);
		end



	end % fit



	function C = fitEvaluate(self, x)
		for i = 1:length(self.ParameterNames)
			self.Parameters.(self.ParameterNames{i}) = x(i);
		end
		self.evaluate();
		C = self.cost();
	end


	function plot(self)

		figure('outerposition',[300 300 1200 600],'PaperUnits','points','PaperSize',[1200 600]); hold on

		if ~isempty(self.Response)
			plot(self.Response,'k')
		end

		self.evaluate;
		plot(self.Prediction,'r')


	end% plot



	function C = cost(self)

		C = nansum((self.Prediction - self.Response).^2);

	end

end % methods



methods (Static)




end % static methods

end % classdef 