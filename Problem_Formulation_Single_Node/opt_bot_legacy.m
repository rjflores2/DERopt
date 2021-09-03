if ~isempty(bot_legacy)
    %% Constraints - Bottom Cycle
    for i=1:size(bot_legacy,2)
        Constraints=[Constraints
            (var_lbot.lbot_on*(bot_legacy(2,i)*bot_legacy(3,i))./4 <= var_lbot.lbot_elec <= var_lbot.lbot_on*(bot_legacy(2,i)./4)):'Min/Max ST Output'];%%% Min/Max power output
    end
end