
load Ellsgty_LMP_Summary

e_adjust = 4;

%%%Day ahead market at the local node ($/kWh)
whl_sale_da = vector(:,2)./1000;

%%%Generating time vector
time = datevec(vector(:,1));

%%%Reducing time to desired window
idx = (time(:,1) == yr_target);
time = time(idx,:);
whl_sale_da_hr = whl_sale_da(idx);
%%%Expanding time to 15 minutes
time = [min(datenum(time)):1/(24*4):max(datenum(time))]'; %%%Min and max times


%%% Finding month start/endpoints
end_cnt = 1;
stpts=1;

datetimev=datevec(time);

day_cnt = 1;
day_stpts = 1;
for ii = 2:length(time)
    if datetimev(ii,2) ~= datetimev(ii-1,2)
        endpts(end_cnt,1) = ii-1;
        stpts(end_cnt+1,1) = ii;
        end_cnt = end_cnt +1;
    end
    
    if datetimev(ii,3) ~= datetimev(ii-1,3)
        day_endpts(day_cnt,1) = ii-1;
        day_stpts(day_cnt+1,1) = ii;
        day_cnt = day_cnt +1;
    end
    
    if ii == length(time);
        endpts(end_cnt,1) = ii;
        day_endpts(day_cnt,1) = ii;
    end
end

%% Reducing wholesale vector
whl_sale_da = zeros(size(time));
size(whl_sale_da)
for ii = 1:length(whl_sale_da_hr);
whl_sale_da(1+(ii-1)*e_adjust:ii*e_adjust) = whl_sale_da_hr(ii);
end

%%%Reducing whl_sale_da if its longer than the time vector
whl_sale_da = whl_sale_da(1:length(time));

% whl_sale_da = interp1(vector(:,1),whl_sale_da,time);

