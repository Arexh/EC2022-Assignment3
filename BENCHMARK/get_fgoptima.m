% ******************************************************************************
% * Version: 1.0
% * Last modified on: 21 January, 2013 
% * Developers: Michael G. Epitropakis, Xiaodong Li.
% *      email: mge_(AT)_cs_(DOT)_stir_(DOT)_ac_(DOT)_uk 
% *           : xiaodong_(DOT)_li_(AT)_rmit_(DOT)_edu_(DOT)_au 
% * ****************************************************************************

function [fit] = get_fgoptima(nfunc)
fgoptima = [1,1,1.6,1,1.729843561973525,2.2727272727,1.0,1.393589488353574,1.826836992013024,0.875,1,1,10-5*sqrt(2),10-5*sqrt(2),20-10*sqrt(2),20-10*sqrt(2),30-15*sqrt(2),50-25*sqrt(2)];
fit = fgoptima(nfunc);
