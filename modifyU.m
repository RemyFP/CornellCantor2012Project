function [uBuy,uSell] = modifyU(portfolio,numStocks,minOpt,maxOpt,currentSD)

portfolio = portfolio*currentSD; %risk adjusted portfolio
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

uBuy = repmat(uBuy,1,numStocks);
uSell = repmat(uSell,1,numStocks);
