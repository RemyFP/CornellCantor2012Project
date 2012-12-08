% needs a price vector of size n
% bought, sold vectors of size n
% VWAP of size n
% uBid and uAsk are scalars
%
% We separate the PNL into two parts: 
% 1. what we have made on edge: edge from buying + edge from selling
% 2. market-to-market PNL which is computed as follows:
% - the difference between the cumulative cost of buying stocks and the
% market value
% - the difference between the cumulative "cost" of selling stocks and the
% market value
%
% At the end, we plot separately the cash we made and the market PNL
% note that the cash is much bigger than the sum of our buying & selling
% PNL
% -----------------------------------------

function [total_PNL, M2M_PNL, cash_made] = PNL_Function(prices, VWAP, bought, sold, uBid, uAsk, spread)
%% rebuilding the slippage for buy and sell based on the direction of the
% market. We are assuming that the percentage change of the default values
% for raising/falling market is the same for each u

n = length(bought);
slippageBid = zeros(n,1);           % must have the same number of elements as there is number of trades
slippageAsk = zeros(n,1);

for i=1:(n-1)
    price_change = prices(i+1)/prices(i)-1;
    if (price_change>=0)
        slippageBid(i) = generate_VWAP(spread,1,uBid(i));
        slippageAsk(i) = generate_VWAP(spread,1,uAsk(i));
    else
        slippageBid(i) = generate_VWAP(spread,-1,uBid(i));
        slippageAsk(i) = generate_VWAP(spread,-1,uAsk(i));
    end
end

%% PNL calculation
cashSavingB = cumsum((VWAP.*slippageBid).*bought);
cashSavingS = cumsum((VWAP.*slippageAsk).*sold);
cash_made = cashSavingB + cashSavingS;

netExposure = bought - sold;
cumNetExposure = cumsum(netExposure);
purchaseCost = VWAP.*(bought - sold);
cumPurchaseCost = cumsum(purchaseCost);
marketValue = prices.*cumNetExposure;
M2M_PNL = marketValue - cumPurchaseCost;

total_PNL = M2M_PNL + cash_made;
