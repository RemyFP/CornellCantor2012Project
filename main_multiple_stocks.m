% The main
% This file allows us to run our simulator using several stocks, and if we
% want to run an optimization to find optimal bounds we simply have to
% enter the desired values of the bounds on lines 62 and 63
%
% There are 5 parts to the main function:
% 1. inputs: keep 390 as the number of points generated per day
% (corresponding to minutes); select your desired number of days
% 2. initialization: prepares all the empty vectors
% 3. prices & volumes (this is the core):
% since we generate the numbers (volumes and prices) for each day
% separately, we need to create a continuous price, volume, and VWAP
% evolution over n days.
% 4. PNL: see PNL.m
% 5. Graphs and save values in Excel files
% ------------------------------

%% INPUTS
clc;
N = 390;                % 390 for one day
interval = 1;           % in terms of minutes
numDays = 100;          % number of days in the model    
horizon = 'minutes';

% select stocks to consider, they can be chosen from the list in
% Spreads.xls, these are the stocks for which we have spread data
% Then get the spreads of the corresponding stocks
tickers = {'GS','MS','C'};
spread = getSpreads(tickers);

numPointsPerDay = ceil(N/interval)+1;   % number of points in a day
numPoints = numDays * numPointsPerDay;
stockPrices = [];
stockEndPrices = [];
Vbought_Out = [];
Vsold_Out = [];
Vmarket_Out = [];
Vdifference_Out = [];
VWAP_Out = [];
portfolio = 0;
uBuy_Out = [];
uSell_Out = [];
graph_total = 1;

% if only one stock, we don't graph the sum of the portfolio
if length(tickers) == 1
    graph_total = 0;
end

%% GENERATE PRICES. Change here manually for each stock
% generates 34,301 price points for each of our 4 stocks. This corresponds
% to 196 points for 175 days + 1 point at time = 0
[prices,volumesTraded,dailyPrices] = intraday_prices(N,interval,tickers);
dailySD = computeCov(dailyPrices);

price1 = prices;
volume1 = repmat(sum(volumesTraded,2)/length(tickers),1,length(tickers));
numStocks = size(price1,2);

%different values of bounds for which we want to run our simulation for
%lower and upper bound cannot have a value in common, or code crashes
minModifyU = 1000;%[200 400 800 1000 1500 2000 3999 5999 7999 11999];
maxModifyU = 80000;%[5000 10000 15000 20000 30000 40000 50000];

CashValues = zeros(length(minModifyU),length(maxModifyU));
LossesValues = zeros(length(minModifyU),length(maxModifyU));
PNLValues = zeros(length(minModifyU),length(maxModifyU));

pseudoMC = 1; %number of times we run our simulation for each pair of bounds
finalCash = zeros(pseudoMC,1);
finalLosses = zeros(pseudoMC,1);
finalPNL = zeros(pseudoMC,1);

for minIndex = 1:length(minModifyU)
    minIndex 
    for maxIndex = 1:length(maxModifyU)
        maxIndex
        for j=1:pseudoMC %pseudo MC loop
            % PRICES & VOLUMES
            for modifyUorNot = 1:1
                % if 1 we modify the u's, otherwise it stays equal to 1
                Vbought_Out = [];
                Vsold_Out = [];
                Vmarket_Out = [];
                Vdifference_Out = [];
                VWAP_Out = [];
                portfolio = 0;
                uBuy_Out = [];
                uSell_Out = [];
                start = 1;    
                portfolioEvo = zeros(numDays,1);
                
                stockPrices = [];
                stockEndPrices = [];
                Vbought_Out = [];
                Vsold_Out = [];
                Vmarket_Out = [];
                Vdifference_Out = [];
                VWAP_Out = [];
                portfolio = zeros(numStocks,1);
                uBuy_Out = [];
                uSell_Out = [];

                for i=1:numDays
                    currentSD = dailySD(:,:,i);

                    if modifyUorNot == 1
                        prices = price1(start:start+numPointsPerDay-1,:);       % generates 196 points for each day 
                        stockPrices = [stockPrices; prices];                % appends the 196 to the previous days 
                        stockEndPrices = [stockEndPrices; prices(2:end,:)];   % appends 195 prices. This will be used with 195 of volume
                        volumesTraded = volume1(start:start+numPointsPerDay-2,:);
                    else
                        prices = price1(start:start+numPointsPerDay-1,:); 
                        volumesTraded = volume1(start:start+numPointsPerDay-2,:);
                    end

                    % move by one day into the future
                    start = start + numPointsPerDay - 1;

                    % Vx is 195 points because at t0 we assume volume = 0. The vector
                    % is of the size 195x1
                    [Vdifference,Vbought,Vsold,Vmarket,uBuy,uSell] = tradedVolumesMultiple(interval,horizon,prices, portfolio,modifyUorNot,numStocks,volumesTraded,minModifyU(minIndex),maxModifyU(maxIndex),currentSD);
                    sumVdiff = sum(Vdifference,1);
                    sumVdiff = sum(sumVdiff,2);

                    VdiffTot = sum(Vdifference,1);
                    portfolio = portfolio + VdiffTot';
                    uBuy_Out = [uBuy_Out; uBuy];
                    uSell_Out = [uSell_Out; uSell];
                    Vbought_Out = [Vbought_Out; Vbought];               
                    Vsold_Out = [Vsold_Out; Vsold];
                    Vmarket_Out = [Vmarket_Out; Vmarket];
                    Vdifference_Out = [Vdifference_Out; Vdifference];

                    % for generating VWAP, we need the sizes of price vector and
                    % Vmarket vector to be the same. For a two minute interval, the
                    % size should be 196 points
                    Vmarket = [zeros(1,numStocks);Vmarket];   
                    
                    VWAP = zeros(size(volumesTraded));
                    for k = 1:numStocks
                        VWAP(:,k) = VWAP_Function(prices, Vmarket);
                    end
                    VWAP_Out = [VWAP_Out; VWAP];

                    % next day, the starting price is the last price of yesterday
                    initialPrice = stockPrices(end);
                end

                %displays which values of aggressiveness occur, and how many times
                [uBuyValues,uBuyOccurences] = count_unique(uBuy_Out(:,1));
                [uSellValues,uSellOccurences] = count_unique(uSell_Out(:,1));

                %% PNL & EVOLUTION
                total_PNL = [];
                M2M_PNL = [];
                cash_made = [];

                for i = 1:numStocks
                    [total_PNL_new, M2M_PNL_new, cash_made_new] = PNL_Function(stockEndPrices(:,i), VWAP_Out(:,i), Vbought_Out(:,i), Vsold_Out(:,i), uBuy_Out(:,i), uSell_Out(:,i),spread(i));
                    total_PNL = [total_PNL,total_PNL_new];
                    M2M_PNL = [M2M_PNL,M2M_PNL_new];
                    cash_made = [cash_made,cash_made_new];
                end
                
                allStocks_total_PNL = sum(total_PNL,2);
                allStocks_M2M_PNL = sum(M2M_PNL,2);
                allStocks_cash_made = sum(cash_made,2);

                %% GRAPH
                % stockEndPrices has 195 rows
                l = size(stockEndPrices,1);
                t = (0:1:l-1)/(l-1);
                t = t*sqrt(1);

                for jj=1:numStocks
                    figure
                    ticker = tickers{jj};
                    subplot(2,2,1); plot(t,stockEndPrices(:,jj)); 
                    legend(num2str(ticker))
                    title(['Geometric Brownian motions over ' num2str(numDays) ' days.'])
                    xlabel('Time')
                    ylabel('Price')
                    grid on

                    subplot(2,2,2); plot(t,cumsum(Vdifference_Out(:,jj)));
                    legend('Difference','Location','NorthWest')
                    title(['Evolution of Difference over ' num2str(numDays) ' days.'])
                    xlabel('Time')
                    ylabel('dif')
                    grid on

                    subplot(2,2,3);
                    plot(t,M2M_PNL(:,jj),t,cash_made(:,jj)); 
                    legend('Marked-to-market PNL','Slippage PNL','Location','NorthWest');
                    title('Evolution of Slippage Profit & M2M');
                    xlabel('Time');
                    ylabel('PNL');
                    grid on

                    subplot(2,2,4);
                    plot(t,total_PNL(:,jj)); 
                    legend('total PNL','Location','NorthWest');
                    title('Evolution of total PNL');
                    xlabel('Time');
                    ylabel('PNL');
                    grid on
                end

                %% plotting Cash & Marked-to-Market PNL
                if graph_total == 1
                    figure
                    % ploting the portfolio difference
                    subplot(3,1,1); plot(t,cumsum(sum(Vdifference_Out(:,j),2)));
                    legend('Difference')
                    title(['Evolution of Difference for GS, MS, C over' num2str(numDays) ' days.'])
                    xlabel('Time')
                    ylabel('dif')  
                    grid on;

                    % ploting components of PNL
                    subplot(3,1,2);
                    plot(t,allStocks_M2M_PNL,t,allStocks_cash_made); 
                    legend('Marked-to-market PNL','Slippage PNL');
                    title('Evolution of Slippage Profit & M2M');
                    xlabel('Time');
                    ylabel('PNL');
                    grid on;

                    % ploting total PNL
                    subplot(3,1,3);
                    plot(t,allStocks_total_PNL); 
                    legend('total PNL');
                    title('Evolution of total PNL');
                    xlabel('Time');
                    ylabel('PNL');
                    grid on;
                end
                
                %compute final values of variables of interest
                finalCash(j) = cash_made(end);
                finalLosses(j) = M2M_PNL(end);
                finalPNL(j) = total_PNL(end);
            end
        end
        %take average of the variables over the several simulations
        CashValues(minIndex,maxIndex) = mean(finalCash);
        LossesValues(minIndex,maxIndex) = mean(finalLosses);
        PNLValues(minIndex,maxIndex) = mean(finalPNL);
    end
end

CashValues
LossesValues
PNLValues

% %save values in Excel files
% xlswrite('CashValuesMatrixMultiple',CashValues);
% xlswrite('LossesValuesMatrixMultiple',LossesValues);
% xlswrite('PNLValuesMatrixMultiple',PNLValues);
