%% Legacy VC Systems
if ~isempty(cool) && sum(cool) > 0  && isempty(vc_legacy)
    for i=1:size(vc_legacy,2)
        i
        
        lgth = round(length(time)/vc_hour_num);
        for j = 1:vc_hour_num
            if j == 1
                st = 1;
                fn = j*lgth;
            elseif j == vc_hour_num
                st = (j-1)*lgth + 1;
                fn = length(elec);
            else
                st = (j-1)*lgth + 1;
                fn = j*lgth;
            end
            Constraints=[Constraints
                ((1/e_adjust).*vc_legacy(3,i)*vc_legacy(4,i).*var_lvc.lvc_op(j,i) <= var_lvc.lvc_cool(st:fn,i) <= (1/e_adjust).*vc_legacy(3,i).*var_lvc.lvc_op(j,i)):'VC Min/Max Output'];         %%% VC Min/Max output
            %         vc_op(2:length(elec),i)-vc_op(1:length(elec)-1,i)<=vc_start(2:length(elec),i)];%%% VC Startup
        end
    end
end