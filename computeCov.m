function covMat = computeCov(dailyPrices)

numStocks = size(dailyPrices,2);
window = 20; %length of trailing window
l = size(dailyPrices,1);

covMat = zeros(numStocks,numStocks,l);

lastPrices = zeros(window,numStocks);

differentSD = l-window-1;
for i = 1:differentSD
    lastPrices = dailyPrices(i:i+window-1,:);
    covMat(:,:,i+window) = cov(lastPrices);
end

mat = covMat(:,:,window+1);
for j = 1:window
    covMat(:,:,j) = mat;
end
covMat(:,:,end) = covMat(:,:,end-1);