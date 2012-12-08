function [Vdifference,Vbought,Vsold,Vmarket,uBuy,uSell] = tradedVolumes(n,horizon,prices,portfolio,modifyUorNot,numStocks,volumesTraded,minOpt,maxOpt,currentSD)
%%%%%INPUTS
%n is the interval on which each volume is computed (eg n=2 the day is divided in 195 2-minute intervals)
%prices is the vector of prices based on the same intervals as the ones the volumes are computed
%portfolio is the number of shares of the portfolio we are currently holding (positive or negative)
%modifyUorNot indicates whether we change aggressiveness or not (1 yes,2 no)
%numStocks is the number of stocks in the portfolio]
%volumesTraded is the number of stocks traded in each interval for each stock
%minOpt and maxOpt correspond to the values of the bounds for which aggressiveness will change
%currentSD is the volatility of the stock considered for that day
%%%%%OUTPUTS
%Vmarket: vector containing the number of shares traded in the whole market on a single stock during the intervals we are interested in
%Vbought, Vsold: vectors containing the number of shares we bought and sold during the intervals
%Vdifference: vector being the difference between the number of stocks bought and sold, during each interval
%uBuy and uSell: vectors representing the values of u (buy and sell) during each of the intervals throughout the day

if strcmp(horizon,'days')
    split = 1;
elseif strcmp(horizon,'minutes')
    split = 6.5*60;
elseif strcmp(horizon,'seconds')
    split = 6.5*60*60;
end

[mu,sigma,lambda] = getVolumeInputs();

%in case we cannot fit an integer number of n in our split we compute the length of the last interval (rest)
%eg for 390 minutes, if n = 45 minutes we have 8 intervals of 45 minutes and one of only 30 minutes
divider = split/n;
intervals = floor(divider);
rest = divider - intervals;

mu_vector = volumesTraded;
sigma_vector = repmat(sigma*sqrt(n),intervals,numStocks);

% % if rest ~= 0
% % 	intervals = intervals + 1;
% % 	mu_vector = [mu_vector; mu*rest*n];
% % 	sigma_vector = [sigma_vector;sigma*sqrt(rest*n)];
% % end

Vmarket = mu_vector.*normrnd(1,sigma_vector);

returns = zeros(intervals,numStocks);

for i=1:intervals
	returns(i,:)=prices(i+1,:)/prices(i,:)-ones(1,numStocks); %value of 0.02 means a return of 2%
end

Vbought = zeros(intervals,numStocks);
Vsold = zeros(intervals,numStocks);
uBuy = zeros(intervals,numStocks);
uSell = zeros(intervals,numStocks);

for i = 1:intervals
    if modifyUorNot == 1
        [uBuy(i,:),uSell(i,:)] = modifyU(portfolio,numStocks,minOpt,maxOpt,currentSD);
    else
        uBuy(i,:) = ones(1,numStocks);
        uSell(i,:) = ones(1,numStocks);
    end
    for j = 1:numStocks
        Vbought(i,j) = 0.01*generate_POV(returns(i,j),1,uBuy(i,j))*Vmarket(i,j);
        Vsold(i,j) = 0.01*generate_POV(returns(i,j),-1,uSell(i,j))*Vmarket(i,j);
    end
    VboughtTot = sum(Vbought(i,:));
    VsoldTot = sum(Vsold(i,:));
    portfolio = portfolio + VboughtTot - VsoldTot;
end

Vdifference = Vbought-Vsold;