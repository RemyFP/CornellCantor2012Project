function sd = computeSD(dailyPrices)

window = 20; %length of trailing window

sd = zeros(length(dailyPrices),1);

lastPrices = zeros(window);

differentSD = length(dailyPrices)-window-1;
for i = 1:differentSD
    lastPrices = dailyPrices(i:i+window-1);
    sd(i+window) = std(lastPrices);
end

sd(1:window) = sd(window+1);
sd(end) = sd(end-1);