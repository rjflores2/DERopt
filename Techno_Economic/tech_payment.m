%% Altering DG capital cost to monthly payments
%% Financing CRAP
interest=0.08; %%%Interest rates on any loans
interest=nthroot(interest+1,12)-1; %Converting from annual to monthly rate for compounding interest
period=10;%%%Length of any loans (years)
equity=0.2; %%%Percent of investment made by investors
required_return=.12; %%%Required return on equity investment
required_return=nthroot(required_return+1,12)-1; % Converting from annual to monthly rate for compounding required return
equity_return=10;% Length at which equity + required return will be paid off (Years)

%% Adjusting capital cost to the mthly payment

%%%pv
for i=1:size(pv_v,2)
    pv_v(1,i)=pv_v(1,i)*((1-equity)*(interest*(1+interest)^(period*12))...
        /((1+interest)^(period*12)-1)+...%%%Money to pay back bank
        req_return_on*(equity)*(required_return*(1+required_return)^(period*12))...
        /((1+required_return)^(period*12)-1));
end

%%%EES
for i=1:size(ees_v,2)
    ees_v(1,i)=ees_v(1,i)*((1-equity)*(interest*(1+interest)^(period*12))...
        /((1+interest)^(period*12)-1)+...%%%Money to pay back bank
        req_return_on*(equity)*(required_return*(1+required_return)^(period*12))...
        /((1+required_return)^(period*12)-1));
end

%%%Inverter
for i=1:size(inv_v,2)
    inv_v(1,i)=inv_v(1,i)*((1-equity)*(interest*(1+interest)^(period*12))...
        /((1+interest)^(period*12)-1)+...%%%Money to pay back bank
        req_return_on*(equity)*(required_return*(1+required_return)^(period*12))...
        /((1+required_return)^(period*12)-1));
end

%%%Transformer
for i=1:size(xfmr_v,2)
    xfmr_v(1,i)=xfmr_v(1,i)*((1-equity)*(interest*(1+interest)^(period*12))...
        /((1+interest)^(period*12)-1)+...%%%Money to pay back bank
        req_return_on*(equity)*(required_return*(1+required_return)^(period*12))...
        /((1+required_return)^(period*12)-1));
end

%% Converting SGIP values to annualized values
for i = 2:(length(sgip) - 1)
    sgip(i)=sgip(i)*(interest*(1+interest)^(period*12))...
        /((1+interest)^(period*12)-1);%%%Money to pay back bank
end