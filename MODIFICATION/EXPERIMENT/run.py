import matlab.engine

engine = matlab.engine.start_matlab()
engine.CompareTable(nargout=0)