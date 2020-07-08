%%% BAseline NG Costs

%%%Monthly NG Costs
for i=1:length(endpts)
    if i==1
        start=1;
        finish=endpts(1);
    else
        start=endpts(i-1)+1;
        finish=endpts(i);
    end
    for j=1:size(heating,2)
        if (c1/boil_v(2))*sum(heating(start:finish),j)<=ng_use_v(2)
            ng_baseline_costs(i,j)=(c1/boil_v(2))*sum(heating(start:finish,j))*tierv(1);
        elseif (c1/boil_v(2))*sum(heating(start:finish,j))>ng_use_v(2) && (c1/boil_v(2))*sum(heating(start:finish,j))<=ng_use_v(3)
            ng_baseline_costs(i,j)=ng_use_v(2)*tierv(1)+...
                ((c1/boil_v(2))*sum(heating(start:finish,j))-ng_use_v(2))*tierv(2);
        else
            ng_baseline_costs(i,j)=(ng_use_v(2)*tierv(1))+...
                ((ng_use_v(3)-ng_use_v(2))*tierv(2))+...
                ((c1/boil_v(2))*sum(heating(start:finish,j))-ng_use_v(3))*tierv(3);
        end
    end
end

%%%Average Baseline Costs ($/therm)
avg_baseline_ng_cost=sum(ng_baseline_costs)/((c1/boil_v(2))*sum(heating));

for i=2:length(ng_cost_v)
    ng_cost_v(i)=avg_baseline_ng_cost*ng_use_v(i);
end