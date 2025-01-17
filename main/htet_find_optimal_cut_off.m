% XXXXXXXXXXXXXXXXXXXXXXXXXXXX htet_find_optimal_cut_off XXXXXXXXXXXXXXXXXXXXXXXXXXXXX
%
% Author    :   Htet
% Date      :   Sep 11, 2019
% Function  :   used to find optimal cut off point and other results for classificaiton problems
% Syntax    :   htet_find_optimal_cut_off(testData, net_out)
% testData - target data, the output label
% net_out - predicted values
% threshold - the cut-off point for binary classification, when the threshold value is given,
%             the function will not find the optimal cut-off point, instead it will just use the given threshold
%             Otherwise, the function will locate the optimal cut-off point
% Stars     :   *****
% XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX


function output = htet_find_optimal_cut_off(testData, net_out, threshold)

    unclassified_count = 0;
    after_threshold = zeros(length(testData),1);
    RESOLUTION = 0.001;
    cut_off = RESOLUTION;
    optimal_cut_off = cut_off;
    min_mean_cost = intmax;
    best_eer = min_mean_cost;
    best_acc = intmin;
    best_fpr = 0;
    best_fnr = 100;
    eer_count = 0;

    fpr_penalized_cost = 1;
    fnr_penalized_cost = 1;
    % fnr_penalized_cost = [1];
    % fnr_penalized_cost = [1; 5; 10; 15; 20; 25; 30];
    MIN_MME = []; %% minimum of mean error
    MIN_FPR = [];
    MIN_FNR = [];
    MIN_CUT_OFF = [];

    % initialize varaiables
    Acc = [];
    FPR = [];
    FNR = [];
    BEST_AFTER_THRESHOLD = [];

    % to plot EER bisector line
    Bisector = [];
    for k=0:99
      Bisector = [Bisector, k];
    end

    % when threshold is given, no need to find the best cut_off point, can use the threshold
    if threshold ~= 0

      for i=1: length(testData)
          if net_out(i) > threshold
              after_threshold(i) = 1;
          elseif net_out(i) < threshold
              after_threshold(i) = 0;
          else
              unclassified_count = unclassified_count + 1;
          end
      end
      net_result.predicted = {net_out};
      net_result.after_threshold = {after_threshold};
      net_result.unclassified = (unclassified_count * 100)/length(testData);

      [TP, FP, TN, FN, fnr, fpr, acc] = htet_get_classification_results(testData, after_threshold(:,1))

      output.MIN_MME = (fpr + fnr)/2;
      output.MIN_CUT_OFF = threshold;
      output.after_threshold = after_threshold;
      output.MIN_FNR = fnr;
      output.MIN_FPR = fpr;
      output.acc = acc; % should not use this accuracy
      output.unclassified_count = unclassified_count;
      return;
    end

    out_fpr = [];
    out_fnr = [];

    %%%%%%%%%%%%%% to find out the best cut-off point or EER value %%%%%%%%%%%%%%%%%
    while(cut_off <= 1)
      for i=1: length(testData)
          if net_out(i) > cut_off
              after_threshold(i) = 1;
          elseif net_out(i) < cut_off
              after_threshold(i) = 0;
          elseif net_out(i) == cut_off
              after_threshold(i) = cut_off;
              eer_count = eer_count + 1;
          else
              unclassified_count = unclassified_count + 1;
          end
      end
      net_result.predicted = {net_out};
      net_result.after_threshold = {after_threshold};
      net_result.unclassified = (unclassified_count * 100)/length(testData);

      [TP, FP, TN, FN, fnr, fpr, acc] = htet_get_classification_results(testData, after_threshold(:,1))

      FPR = [FPR, fpr];
      FNR = [FNR, fnr];

      fpr_cost = fpr * fpr_penalized_cost;
      fnr_cost = fnr * fnr_penalized_cost;

      curr_cost = (fpr_cost + fnr_cost)/2;
      eer = (fpr + fnr)/2;

      % if the current cost is less than the minimum value, update the minimum cost
      if curr_cost < min_mean_cost
        optimal_cut_off = round(cut_off, 4);
        min_mean_cost = (round(curr_cost, 4)); % it is also the EER
        best_eer = round(eer, 2);
        best_fpr = round(fpr, 2);
        best_fnr = round(fnr, 2);
        best_after_threshold = after_threshold;
      end

      cut_off = cut_off + RESOLUTION;
      unclassified_count = 0;
      eer_count = 0;
      after_threshold = zeros(length(testData),1);
    end

    output.BEST_AFTER_THRESHOLD = best_after_threshold;
    output.MIN_MME = best_eer;
    output.MIN_CUT_OFF = optimal_cut_off;
    output.MIN_FPR = best_fpr;
    output.MIN_FNR = best_fnr;
    output.all_fpr = FPR;
    output.all_fnr = FNR;
    output.bisector = Bisector;
end
