function [Pcharger] = AbsoluteControl(Ptarget,Ptrafo,Pprev, N)
%AbsoluteControl Controlling the chargers in absolute steps
%Input:
%	Ptarget	= the wanted value for Ptrafo
%	Ptrafo	= the power at the trafo (power consumed by EV - power produced by PV
%	Pprev	= previous value of Pcharger
%	N		= the number of chargers
%Output:
%	Pcharger = The power for each charger. This is an N-length vector, because
%	in FCFS chargers will get different power.

if (Ptrafo <= Ptarget) && (Ptrafo > Ptarget * 0.95)
	% Prevents the Pcharger from constantly updating with only small
	% changes
	Pcharger = Pprev;
else
	% If all chargers will use Pev than the Ptarget will be reached 
	Pcharger = Pprev + ones([1 N])*(Ptarget - Ptrafo)/N;		
end
end