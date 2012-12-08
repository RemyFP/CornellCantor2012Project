% Generates a VWAP slippage that depends on the spread, trade type, and
% stated aggression level.  The numbers used were chosen based on our
% analysis of the trade data.
%
% Inputs:
%    spread: vector of the bid/ask spreads for the stocks traded (in bps)
%    type  : vector indicating whether each trade was a BUY (+1) or SELL (-1)
%    u     : the aggression levels, vector of integers from 1 to 5
%
% Outputs:
%    VWAP_slippages : the vector of simulated VWAP slippages 
%
function VWAP_slippages = generate_VWAP(spread, type, u)

n = length(spread);
VWAP_slippages = zeros(n,1);
mu = zeros(n,1);
sigma = zeros(n,1);

for i = 1:n
    % Set parameters if a BUY Trade
    if (type == 1)
        mu(i) = (-0.458944 + .25*(u(i)-1))*spread(i) + 0.00003;
        sigma(i) = 0.7*(0.938859*spread(i) + 0.000164);
    % Set parameters if a SELL Trade
    elseif (type == -1)
        mu(i) = (-0.502295 + .25*(u(i)-1))*spread(i) + 0.0000367;
        sigma(i) = 0.7*(1.144760*spread(i) + 0.000050);
    end
    
    VWAP_slippages(i) = normrnd(mu(i),sigma(i));  
end

VWAP_slippages = -VWAP_slippages;