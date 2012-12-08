% Generates a Percentage of Volume that depends on the price change,
% trade type, and stated aggression level.  The numbers used were chosen
% based on our analysis of the trade data.
%
% Inputs:
%     price change - the amount the price rose or fell during this trade
%     trade type - (+1) for buying / (-1) for selling
%     u - aggression level
function POV = generate_POV(price_change, trade_type, u)

if u == 0
    POV = 0;
else
    lambda = 1.0;
    x = trade_type*price_change;

    % Sets lambda in the case of an favorable price move
    if (x > 0)
        lambda = 9.756294*(-0.54604*log(x) - 1.885964);
    % Sets lambda in the case of an unfavorable price move
    elseif (x < 0)
        lambda = 4.424209*(-0.624*log(abs(x)) - 1.5152);
    end

    % Generates an exponential random variable to simulate 
    % X := sqrt(price_change)*POV    where  X ~ exp(lambda)
    e1 = ( -log(rand()) )/( lambda );

    % The simulated percentage of volume.
    %    For now, if no price change then choose a POV ~ uniform(2,20)
    if (price_change == 0)
        POV = unifrnd(2,20);
    else
        POV = ( e1 ) / ( sqrt(abs(x)) );  
    end
    
    if POV > 15
        POV = 15;
    end

    % Adjusted the percentage of volume based on aggression level.
    %    For now, we assume each aggression level we move up adds a percentage
    %    point to POV
    POV = POV + (u-1);
end