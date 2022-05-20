import matlab.engine

engine = matlab.engine.start_matlab()
engine.CompleteTable(nargout=0)