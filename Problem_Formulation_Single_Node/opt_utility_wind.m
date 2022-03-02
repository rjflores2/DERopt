%% Utility wind Constraints
if ~isempty(util_wind_v)
    %%% PV Energy Balance
    Constraints = [Constraints
        (var_util_wind.util_wind_elec <= var_util_wind.util_wind_adopt/e_adjust.*wind_util):'Utility WIND Energy Balance'
        (var_util_wind.util_wind_adopt <= 10*60000):'Max Utility PV'];
end