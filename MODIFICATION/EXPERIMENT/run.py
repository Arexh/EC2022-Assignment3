import matlab.engine

engine = matlab.engine.start_matlab()
engine.CompareLowEvaluations(nargout=0)