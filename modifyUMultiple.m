function [uBuy,uSell] = modifyUMultiple(portfolio,numStocks,minOpt,maxOpt,currentSD)

Inv = portfolio';
portfolio = sqrt(portfolio'*currentSD*portfolio); %risk adjusted portfolio
min = minOpt;
max = maxOpt;
uBuy = 1;
uSell = 1;
step = 0.5;
indices = 1:step:5;
if mod(5,step) ~= 0 %to make sure 5 is actually in the vector
    indices = [indices 5];
end
l=length(indices);

diff = max - min;
inc = diff/(l-2);
threshold = min:inc:max;

k=0;
for i=(l-1):(-1):1
	if abs(portfolio)>threshold(i)
		k=i;
		break
	end
end


if (k~=0 & portfolio>0)
	if k==l
		uBuy = 0;
	end
	uSell = indices(k);
end

if (k~=0 & portfolio<0)
	if k==l
		uSell = 0;
	end
	uBuy = indices(k);
end

ub = uBuy;
us = uSell;
uBuy = ones(1,numStocks);
uSell = ones(1,numStocks);

for i = 1:numStocks
    if(isnan(Inv(i)) == 0 && Inv(i) ~=0)
        if(Inv(i) < 0)
            uBuy(i) = us;
            uSell(i) = 1;
        else
            uBuy(i) = 1;
            uSell(i) = us;
        end
    else
        uBuy(i) = 1;
        uSell(i) = 1;
    end
end
