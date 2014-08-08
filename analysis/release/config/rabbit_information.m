function [ channelNames, gtechGND, earth ] = rabbit_information(rabbit_ID)

%Channel labels during VEP for all rabbits (5,6,7, etc.)
        channelNames = {'Disconnected','Endo','Mid head','Disconnected','Right Eye','Right Leg','Back Head','Left Eye','Bottom Precordial','Top Precordial'};
        gtechGND = 'Nose';
        earth = 'Left Leg';
switch rabbit_ID
    case '7rabbit_apr_15_2014'
    case '8rabbit_apr_24_2014'
    case '9rabbit_may_6_2014'
        channelNames = {'Disconnected','Endo','Mid head','Disconnected','Right Eye','Right Leg','Back Head','Left Eye','Bottom Precordial','Top Precordial'};
        gtechGND = 'Nose';
        earth = 'Left Leg';
    case '10rabbit_may_15_2014'
        channelNames = {'Disconnected','Endo','Mid head','Disconnected','Right Eye','Right Leg','Back Head','Left Eye','Bottom Precordial','Top Precordial'};
        gtechGND = 'Nose';
        earth = 'Left Leg';
    case '6rabbit_apr_15_2014'
        channelNames = {'Disconnected','Endo','Mid head','Disconnected','Right Eye','Right Leg','Back Head','Left Eye','Bottom Precordial','Top Precordial'};
    case '5rabbit_apr_15_2014'
%        channelNames = 
end

end

