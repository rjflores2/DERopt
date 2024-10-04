wave_power_limit = wave_range(wave_num);
if exist('wave_on') && wave_on 
%       Constraints = [Constraints
%          (var_run_of_river.electricity <= river_power_potential):'Run of River is limited by available resources'];
     Constraints = [Constraints
         (0 <= var_wave.electricity <= wave_power_potential.*repmat(var_wave.power,T,1)):'Run of River is limited by available resources'
         (var_wave.power <= wave_power_limit):'Run of River Swept Area Limit' ];  
     
end
    


%  Constraints = [Constraints
%          (var_run_of_river.electricity <= river_power_potential):'Run of River is limited by available resources'];