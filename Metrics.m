function [] = Metrics(Ptotal, Pmax_trafo)
%METRICS Calculate all relavent metrics
%Input:
%	Ptotal = vector with Power at the trafo on each time interval
%	Pmax_trafo = the power limit of the trafo
Pover_limit = Ptotal - Pmax_trafo;
Pover_limit(Pover_limit(A>0)) = 0; % Only show values that breach the limit
sum(Pover_limit);
end