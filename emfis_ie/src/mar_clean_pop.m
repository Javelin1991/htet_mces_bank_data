% XXXXXXXXXXXXXXXXXXXXXXXXXXXXX MAR_CLEAN_POP XXXXXXXXXXXXXXXXXXXXXXXXXXXXX
% 
% Author    :   Mario Hartanto
% Date      :   Jan 29 2014
% Function  :   cleans rule structure using POP rule reduction
% Syntax    :   mar_clean_pop(net, current_count)
% 
% net - FIS network structure
% 
% Algorithm -
% 1) Searches rule database for rules with same antecedents but different consequents
% 2) If rules with same antecedents but different consequents are found, only keep the rule with the highest weight
% 3) Normalize weights (see mar_normalize_weights)
% XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX


function D = mar_clean_pop(net, current_count)
%    disp('Clean POP');
    num_attributes = size(net.input, 2);
    num_outputs = size(net.output, 2);
    num_rules = size(net.rule, 2);  

    % collate rules data into database matrix
    weight_col  = num_attributes + num_outputs + 1;
    conn_col    = num_attributes + num_outputs + 2;
    invoked_col = num_attributes + num_outputs + 3;
    lastUpdate  = num_attributes + num_outputs + 4;
    topCache    = num_attributes + num_outputs + 5;
    baseCache   = num_attributes + num_outputs + 6;
    belong      = num_attributes + num_outputs + 7;
    active      = num_attributes + num_outputs + 8;
    
    rule_database = zeros(num_rules, num_attributes + num_outputs + 3);
    
    for i = 1 : num_rules
        rule_database(i, 1 : num_attributes) = net.rule(i).antecedent;
        rule_database(i, num_attributes + 1 : num_attributes + num_outputs) = net.rule(i).consequent;
        rule_database(i, weight_col) = net.rule(i).weight;
        rule_database(i, conn_col) = net.rule(i).connection;
        rule_database(i, invoked_col) = net.rule(i).num_invoked;
        rule_database(i, lastUpdate) = net.rule(i).lastUpdate;
        rule_database(i, topCache) = net.rule(i).topCache;
        rule_database(i, baseCache) = net.rule(i).baseCache;
        rule_database(i, belong) = net.rule(i).belong;
        rule_database(i, active) = net.rule(i).active;
    end
    

    for i = 1 : num_rules
        for j = 1 : num_rules
            % find rules with same antecendents but different consequents
            if sum(rule_database(i, 1 : num_attributes) == rule_database(j, 1 : num_attributes)) == num_attributes && ...
                    sum(rule_database(i, num_attributes + 1 : num_attributes + num_outputs) == rule_database(j, num_attributes + 1 : num_attributes + num_outputs)) ~= num_outputs && ...
                        i ~= j
                % keep only the rule with higher weight
                if rule_database(i, weight_col) > rule_database(j, weight_col)
                    rule_database(i, invoked_col) = rule_database(i, invoked_col) + rule_database(j, invoked_col);
                    rule_database(i, active) = max(rule_database(i, active), rule_database(j, active));
                    rule_database(i, lastUpdate) = max(rule_database(i, lastUpdate), rule_database(j, lastUpdate));
                    rule_database(i, topCache) = rule_database(i, topCache) + rule_database(j, topCache);
                    rule_database(j, :) = 0;
                else
                    rule_database(j, invoked_col) = rule_database(j, invoked_col) + rule_database(i, invoked_col);
                    rule_database(j, active) = max(rule_database(i, active), rule_database(j, active));
                    rule_database(j, lastUpdate) = max(rule_database(i, lastUpdate), rule_database(j, lastUpdate));
                    rule_database(j, topCache) = rule_database(i, topCache) + rule_database(j, topCache);
                    rule_database(i, :) = 0;
                end
            % remove duplicate rules
            elseif sum(rule_database(i, 1 : num_attributes) == rule_database(j, 1 : num_attributes)) == num_attributes && ...
                    sum(rule_database(i, num_attributes + 1 : num_attributes + num_outputs) == rule_database(j, num_attributes + 1 : num_attributes + num_outputs)) == num_outputs && ...
                        i ~= j
                % add weights together
                rule_database(i, weight_col) = rule_database(i, weight_col) + rule_database(j, weight_col);
                rule_database(i, invoked_col) = rule_database(i, invoked_col) + rule_database(j, invoked_col);
                rule_database(i, active) = max(rule_database(i, active), rule_database(j, active));
                rule_database(i, lastUpdate) = max(rule_database(i, lastUpdate), rule_database(j, lastUpdate));
                rule_database(i, topCache) = rule_database(i, topCache) + rule_database(j, topCache);
                rule_database(j, :) = 0;
            end            
        end
    end

    % rebuild rule structure
    num_new_rules = 1;
    for i = 1 : num_rules
        if sum(rule_database(i, :)) == 0 
            continue;
        end
        if (rule_database(i, active) == 0 && (rule_database(i, lastUpdate) < (current_count - 2 * net.half_life) || rule_database(i, weight_col) < 0.05))
            continue;
        end    
            
        new_rule_struct(num_new_rules).antecedent = rule_database(i, 1 : num_attributes);
        new_rule_struct(num_new_rules).consequent = rule_database(i, num_attributes + 1 : num_attributes + num_outputs);
        new_rule_struct(num_new_rules).weight = rule_database(i, weight_col);
        new_rule_struct(num_new_rules).connection = rule_database(i, conn_col);
        new_rule_struct(num_new_rules).num_invoked = rule_database(i, invoked_col);
        new_rule_struct(num_new_rules).lastUpdate = rule_database(i, lastUpdate);
        new_rule_struct(num_new_rules).topCache = rule_database(i, topCache);
        new_rule_struct(num_new_rules).baseCache = rule_database(i, baseCache);
        new_rule_struct(num_new_rules).belong = rule_database(i, belong);
        new_rule_struct(num_new_rules).active = rule_database(i, active);
        num_new_rules = num_new_rules + 1;
    end
    
    net.rule = new_rule_struct;    
    net = mar_normalize_weights(net);
    D = net;

end

