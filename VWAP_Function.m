% generates VWAP 
% needs a vector of prices and market volumes of the same length
% the first number of the volumes vector should be 0 (since we don't trade
% at time 0)
% ------------------------------------

function VWAP = VWAP_Function(prices, vol)

l = length(prices)-1;
VWAP = zeros(l,1);

for i=1:l
    price_t = prices(i);
    price_t1 = prices(i+1);
    vol_t = vol(i);
    vol_t1 = vol(i+1);
    VWAP(i) = (price_t*vol_t + price_t1*vol_t1)/(vol_t + vol_t1);
end


