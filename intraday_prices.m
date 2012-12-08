
%%%%%%%%%%%%%%%%%%%%%%%%
% The code below first obtains the daily prices and volume of the stocks
% listed for the days specified and then interpolates the intraday path
% based on the BM between the two consecutive closing prices.
%%%%%%%%%%%%%%%%%%%%%%%%

function [price,volume,dailyPrices] = intraday_prices(NumMinDay,interval,tics)

% Getting the daily data
%%%%tics = {'C' 'GE' 'ROP' 'WMT'};
%tics = {'C','GS','MS','BAC'};
% BAC:high spread and volume, GE: high volume, ROP: low volume, WMT: low spread
startdt = '01-23-2012';   % in  format
enddt = '09-30-2012';     % in  format
StocksData = hist_stock_data(startdt,enddt,tics);

% Specifying simulation parameters
% interval = 5 ;  % this means interval is 2 minutes and there are 390 trading minutes in a day
% NumMinDay = 390;

%%%%% ----------------------------------------------------
% Computation of number of days
if(mod(NumMinDay,interval)~=0)    % needs to be a factor of 390;
    error('Error: The number of trading intervals should be a whole number for a day. Check the interval size');
end
temp = zeros(1,length(tics));
for j = 1:length(tics)
    temp(j) = length(StocksData(j).Date);
end
if(all(temp~=temp(1)))
    error('Error: not all stocks have data on the dates chosen. Choose different dates');
else
    NumDays = temp(1);
end
NumIntervalsDay = NumMinDay/interval+1;
DaysIndex = 1+NumIntervalsDay:NumIntervalsDay:(NumDays+1)*NumIntervalsDay;

% creating the arrays
price = zeros(NumDays*NumIntervalsDay,length(tics));
volume = zeros(NumDays*NumIntervalsDay,length(tics));
ADV = zeros(NumDays,length(tics));

%creating the data for each interval
for i = 1:length(tics)
    price(1,i) = StocksData(i).Open(1);
    price(DaysIndex,i) = StocksData(i).AdjClose;
    ADV(:,i) = StocksData(i).Volume;
end

dailyPrices = StocksData(1).AdjClose;
dailyPrices = dailyPrices(end:-1:1);

% Creating intraday prices using BM. The factor is used to reduce std if
% the prices are too small
for i = 1:NumDays
    EndDayPrice = price(1+NumIntervalsDay*i,:);
    for j = 2:NumIntervalsDay
        factor = ones(1,length(tics));
        PastPrice = price( (i-1)*NumIntervalsDay+(j-1) ,:);
        PriceMean = ((NumIntervalsDay - j).*PastPrice + EndDayPrice )./ (NumIntervalsDay-j+1);
        factor = 10*NumIntervalsDay./PastPrice;
        PriceStd = (NumIntervalsDay - j)/(NumIntervalsDay-j+1)./factor;
        price( (i-1)*NumIntervalsDay + j,:) = normrnd(PriceMean,PriceStd);
    end
    volume( (i-1)*NumIntervalsDay+1:i*NumIntervalsDay,:) = repmat(ADV(i,:)./NumIntervalsDay,NumIntervalsDay,1);
end

price = price(2:end,:); % remove the first value? Why is there +1 point?
price = price(end:-1:1,:);
volume = volume(end:-1:1,:);
size(price)