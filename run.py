import matlab.engine

engine = matlab.engine.start_matlab()
engine.test(nargout=0)