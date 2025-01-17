    % XXXXXXXXXXXXXXXXXXXXXXXXXXX  XXXXXXXXXXXXXXXXXXXXXXXXXXXXX
    %
    % Author    :   Susanti
    % Date      :   Aug 1 2014
    % Function  :
    % Syntax    :
    %

    %
    % Algorithm -

    % XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX

    function a1 = sus_interpolation_extrapolation(data_input, net, prev_net, current_count)
%    disp('sus_interpolation_v1');






    antecedent = sus_get_antecedent_mf(data_input, net);

    num_attributes = size(data_input, 2);
    num_outputs = size(prev_net.output, 2);
    num_rules = size(prev_net.rule, 2);



    if(num_rules > 1)
            missing_index = num_attributes+1 ;
            rules_no = net.interpolation.ie_rules_no; % no of rules for inter or extrapolation

            %declare range of antecedents
            min_antecedent_ranges = zeros (1,num_attributes);
            max_antecedent_ranges = zeros (1,num_attributes);

            for i = 1:1:num_attributes
                num_mfs = size(prev_net.input(i).mf, 2);
                min_antecedent_ranges(1,i) = (prev_net.input(i).mf(1).params(2)) - (prev_net.input(i).mf(1).params(1));
                max_antecedent_ranges(1,i) = (prev_net.input(i).mf(num_mfs).params(2)) + (prev_net.input(i).mf(num_mfs).params(3));
            end

            for i = 1:1:num_outputs
                num_mfs = size(prev_net.output(i).mf, 2);
                %min_consequent_ranges = (prev_net.output(i).mf(1).params(2)) - (prev_net.output(i).mf(1).params(1));
                %max_consequent_ranges = (prev_net.output(i).mf(num_mfs).params(2)) + (prev_net.output(i).mf(num_mfs).params(3));
                min_consequent_ranges = (prev_net.output(i).mf(1).params(2)) - (prev_net.output(i).mf(1).params(1));
                max_consequent_ranges = (prev_net.output(i).mf(num_mfs).params(2)) + (prev_net.output(i).mf(num_mfs).params(3));
            end


            %declare first rule and antecedents, consequence values
            r.rules.length = num_rules;

            for i = 1:1:num_rules
                r.rules(i).antecedents.length = num_attributes;
            end
            observation.antecedents.length = num_attributes;


            index = 0;
            for i = 1 : num_rules
                    if net.rule(i).active == 0
                            continue;
                    else
                        index = index +1;

                        r.rules(index).min_antecedent_ranges = min_antecedent_ranges;
                        r.rules(index).max_antecedent_ranges = max_antecedent_ranges;
                        r.rules(index).min_consequent_ranges = min_consequent_ranges;
                        r.rules(index).max_consequent_ranges = max_consequent_ranges;

                        for j = 1 : num_attributes
                            r.rules(index).antecedent(j).point(1) = (prev_net.input(j).mf(net.rule(index).antecedent(j)).params(2)) - (prev_net.input(j).mf(net.rule(index).antecedent(j)).params(1));
                            r.rules(index).antecedent(j).point(2) = prev_net.input(j).mf(net.rule(index).antecedent(j)).params(2);
                            r.rules(index).antecedent(j).point(3) = (prev_net.input(j).mf(net.rule(index).antecedent(j)).params(2)) + (prev_net.input(j).mf(net.rule(index).antecedent(j)).params(3));
                        end

                        for j = 1 : num_outputs
                            r.rules(index).consequent.point(1) = (prev_net.output(j).mf(net.rule(index).consequent(j)).params(2)) - (prev_net.output(j).mf(net.rule(index).consequent(j)).params(1));
                            r.rules(index).consequent.point(2) = prev_net.output(j).mf(net.rule(index).consequent(j)).params(2);
                            r.rules(index).consequent.point(3) = (prev_net.output(j).mf(net.rule(index).consequent(j)).params(2)) + (prev_net.output(j).mf(net.rule(index).consequent(j)).params(3));
                        end
                    end
            end

            for k = 1 : num_attributes

                observation.min_antecedent_ranges = min_antecedent_ranges;
                observation.max_antecedent_ranges = max_antecedent_ranges;
                observation.min_consequent_ranges = min_consequent_ranges;
                observation.max_consequent_ranges = max_consequent_ranges;

                observation.antecedent(k).point(1) = (net.input(k).mf(antecedent.antecedent(k)).params(2)) - (net.input(k).mf(antecedent.antecedent(k)).params(1));
                observation.antecedent(k).point(2) = net.input(k).mf(antecedent.antecedent(k)).params(2);
                observation.antecedent(k).point(3) = (net.input(k).mf(antecedent.antecedent(k)).params(2)) + (net.input(k).mf(antecedent.antecedent(k)).params(3));

            end



            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


            r.active_rule_count = index;
            n = sus_nearest_rule(r,observation,rules_no);

            %disp('Interpolation Start');

            %declare first rule and antecedents, consequence values
            p.rules.length = rules_no;

            for i = 1:1:rules_no
                p.rules(i).antecedents.length = num_attributes;
            end
            observation.antecedents.length = num_attributes;

            for i = 1 : rules_no


                p.rules(i).min_antecedent_ranges = min_antecedent_ranges;
                p.rules(i).max_antecedent_ranges = max_antecedent_ranges;
                p.rules(i).min_consequent_ranges = min_consequent_ranges;
                p.rules(i).max_consequent_ranges = max_consequent_ranges;

                for j = 1 : num_attributes
                    p.rules(i).antecedent(j).point(1) = (prev_net.input(j).mf(net.rule(n.nearest_rule(1,i)).antecedent(j)).params(2)) - (prev_net.input(j).mf(net.rule(n.nearest_rule(1,i)).antecedent(j)).params(1));
                    p.rules(i).antecedent(j).point(2) = prev_net.input(j).mf(net.rule(n.nearest_rule(1,i)).antecedent(j)).params(2);
                    p.rules(i).antecedent(j).point(3) = (prev_net.input(j).mf(net.rule(n.nearest_rule(1,i)).antecedent(j)).params(2)) + (prev_net.input(j).mf(net.rule(n.nearest_rule(1,i)).antecedent(j)).params(3));
                end

                for j = 1 : num_outputs
                    p.rules(i).consequent.point(1) = (prev_net.output(j).mf(net.rule(n.nearest_rule(1,i)).consequent(j)).params(2)) - (prev_net.output(j).mf(net.rule(n.nearest_rule(1,i)).consequent(j)).params(1));
                    p.rules(i).consequent.point(2) = prev_net.output(j).mf(net.rule(n.nearest_rule(1,i)).consequent(j)).params(2);
                    p.rules(i).consequent.point(3) = (prev_net.output(j).mf(net.rule(n.nearest_rule(1,i)).consequent(j)).params(2)) + (prev_net.output(j).mf(net.rule(n.nearest_rule(1,i)).consequent(j)).params(3));
                end

            end

            for k = 1 : num_attributes

                observation.min_antecedent_ranges = min_antecedent_ranges;
                observation.max_antecedent_ranges = max_antecedent_ranges;
                observation.min_consequent_ranges = min_consequent_ranges;
                observation.max_consequent_ranges = max_consequent_ranges;

                observation.antecedent(k).point(1) = (net.input(k).mf(antecedent.antecedent(k)).params(2)) - (net.input(k).mf(antecedent.antecedent(k)).params(1));
                observation.antecedent(k).point(2) = net.input(k).mf(antecedent.antecedent(k)).params(2);
                observation.antecedent(k).point(3) = (net.input(k).mf(antecedent.antecedent(k)).params(2)) + (net.input(k).mf(antecedent.antecedent(k)).params(3));

            end
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%




            %forward interpolation A->B
            %get intermediate rule (A' and B')
            intermediate_rule = sus_intermediate_rule(p, observation, missing_index);


            %transform the intermediate variables (A', B' to A*, B*)
            transformed_rule = sus_transform(intermediate_rule.shifted_intermediate_rule, observation, missing_index);
            %output consequence value


            %


%             disp(['Forward interpolation consequence:']);
%             disp([transformed_rule.interpolation.transformed_rule]);
            trans_rule_point(1) = transformed_rule.interpolation.transformed_rule.point(1);
            trans_rule_point(2) = transformed_rule.interpolation.transformed_rule.point(2);
            trans_rule_point(3) = transformed_rule.interpolation.transformed_rule.point(3);


            a = sus_cri(data_input, prev_net);
            prev_net.rule_firing_strength = a.rule_firing_strength;
            prev_net.numer = a.numer;
            prev_net.denom = a.denom;
            % DEFUZZIFICATION

            % average the widths
            width = (trans_rule_point(3) - trans_rule_point(1)) / 2;

            % average the centroids
            centroid = trans_rule_point(2);

            firing_strength = prev_net.rule_firing_strength(n.nearest_rule(1,1), 1);
            weight = prev_net.rule_firing_strength(n.nearest_rule(1,1), 2);

            for i = 2 : rules_no
                if firing_strength < prev_net.rule_firing_strength(n.nearest_rule(1,i), 1)
                    firing_strength = prev_net.rule_firing_strength(n.nearest_rule(1,i), 1);
                    weight = prev_net.rule_firing_strength(n.nearest_rule(1,i), 2);
                end
            end

            % f5 = sum((centroid / width) * f * w) for each consequent
            % fuzzy set fired from rule base
            % o5 = f5 / sum(f * w / width)
            numer = prev_net.numer + ((centroid / width) * firing_strength * weight);
            denom = prev_net.denom + (firing_strength * weight / width);


            if denom == 0
                y = 0;
            else
                y = (numer / denom);
            end

%             disp('result for interpolation:');
%             disp(y);


            % create the rules
            if (net.interpolation.create_ie_rule == 1)
                if (isnan(y))
                else
                    %net = sus_gene_new_rule(antecedent, y, net, current_count);
                    net = sus_online_rule(net, data_input, y,weight, current_count);
                end
            end



            a1.y = y;
            a1.net = net;


    else
            a1.y = 0;
            a1.net = net;

    end



    end
