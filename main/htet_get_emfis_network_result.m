% XXXXXXXXXXXXXXXXXXXXXXXXXXXX htet_get_emfis_network_result XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
%
% Author    :   Htet
% Date      :   Sep 11, 2019
% Function  :   get classification results using "eMFIS(FRIE)"
% Syntax    :   htet_get_emfis_network_result(cv, params, x, y)
% cv - data set
% params - parameters required for the induction algorithm, which is in this case, "eMFIS(FRIE)"
% x - input data
% y - target label
% Stars     :   *
% XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX

function out = htet_get_emfis_network_result(cv, params, x, y)

      algo = params.algo;
      max_cluster = params.max_cluster;
      half_life = params.half_life;
      threshold_mf = params.threshold_mf;
      min_rule_weight = params.min_rule_weight;
      spec = params.spec;
      ie_rules_no = params.ie_rules_no;
      create_ie_rule = params.create_ie_rule;
      unclassified_count = 0;
      eer_count = 0;

      D = cv;

      if params.dummy_run
        data_target = D(1:10,2);
        % data_input = D(1:10,3:12);

        % already filter out
        data_input = D(1:10,[3:5]);
      else
        data_target = D(:,2);
        % data_input = D(:,3:12);

        % already filter out
        data_input = D(:,[3:5]);
      end

      if params.use_top_features
        % 1 is CAPADE, 5 is PLAQLY, 8 is ROE
        % data_input = data_input(:,[1 5 8]);

        % 1 is CAPADE, 2 is OLAQLY, 3 is PROBLO, 5 is PLAQLY, 7 is NINMAR
        % data_input = data_input(:,[1 2 3 5 7]);
      end

      if params.do_not_use_cv
        data_input = x;
        data_target = y;
      end

      target_size = size(data_target, 1);
      start_test = (size(data_input, 1) * 0.2) + 1;

      disp(['Running algo : ', algo]);
      system = mar_trainOnline(ie_rules_no ,create_ie_rule, data_input, data_target, algo, max_cluster, half_life, threshold_mf, min_rule_weight);
      system = ron_calcErrors(system, data_target(start_test : target_size));
      system.num_rules = mean(system.net.ruleCount(start_test : target_size));

      % after_threshold = zeros(target_size,1);
      % for i=1: size(data_target, 1)
      %     if system.predicted(i) > 0.5
      %         after_threshold(i) = 1;
      %     elseif system.predicted(i) < 0.5
      %         after_threshold(i) = 0;
      %     elseif system.predicted(i) == 0.5
      %         after_threshold(i) = 0.5;
      %         eer_count = eer_count + 1;
      %     else
      %         unclassified_count = unclassified_count + 1;
      %     end
      % end

      target_length = length(data_target);
      testData = data_target(start_test: target_length, :);
      testPredicted = system.predicted(start_test: target_length,:);

      % net_result.rmse = system.RMSE;
      % net_result.num_rules = system.num_rules;
      % net_result.R = system.R;
      % net_result.predicted = {system.predicted};
      % net_result.after_threshold = {after_threshold};
      %
      % target = data_target(start_test: target_size, :);
      % pv = after_threshold(start_test: target_size, :);
      %
      % cp = 0;
      % for j=1:length(target)
      %     if (target(j,:) == pv(j,:))
      %       cp = cp + 1;
      %     end
      % end
      % net_result.ac2 = (cp * 100)/length(target);
      % correct_predictions = length(find(data_target(start_test : target_size) - after_threshold(start_test :target_size) == 0));
      % test_examples = (target_size - start_test) + 1;
      % net_result.accuracy = (correct_predictions * 100)/test_examples;
      % net_result.unclassified = (unclassified_count * 100)/test_examples;
      % net_result.EER = (eer_count * 100)/test_examples;
      % net_result.data_input = {data_input};
      % net_result.data_target = {data_target};

      out.opt = htet_find_optimal_cut_off(testData, testPredicted, 0);
      out.testData = testData;
      out.testPredicted = testPredicted;
end
