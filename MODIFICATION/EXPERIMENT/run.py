import matlab.engine

engine = matlab.engine.start_matlab()
engine.AverageTable(nargout=0)