function [mu,sigma,lambda] = getVolumeInputs()
%output is average and standard deviation of volume traded per minute

mu = 10^8;
sigma = 0.8; %standard deviation of traded volume
lambda = 10; %correlation with stock return

numberTradingHours = 6.5; %trading is from 9:30am to 4pm
n = numberTradingHours*60;

mu = mu/n;
sigma = sigma/sqrt(n);