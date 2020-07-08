% This vector sets the maximun PV capacity for each building, in kW

% max_kW_bldg = [ ];

if isempty(roof_area) == 0
    for k=1:size(elec,2) % for each bulding
    Constraints = [Constraints
       pv_adopt(:,k)<= max_kW_bldg(k)];
end