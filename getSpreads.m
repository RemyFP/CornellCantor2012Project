function spreads = getSpreads(tickers)

n = length(tickers);

spreads = nan(n,1);

[num,txt,raw] = xlsread('Spreads');
txt = txt(2:end); %gets rid of the header

for i = 1:n
    x = strmatch(tickers(i),txt,'exact');
    spreads(i) = num(x);
end
