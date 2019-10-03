% XXXXXXXXXXXXXXXXXXXXXXXXXXXX htet_test_bank_classification_safin_frie_hcl XXXXXXXXXXXXXXXXXXXXXXXXXXXXX
%
% Author    :   Htet
% Date      :   Sep 11, 2019
% File  :   used to test bank failure prediction/classification using SaFIN_FRIE with HCL
% XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
% diary SaFIN_FRIE_Learning_Trace;
%
clear;
clc;

%%% load different data %%%
% load '5_Fold_CVs_with_top_3_features';
load CV1_Classification;
% load CV3_Classification;
% load CV3_Classification;
% load 'Reconstructed_Data_LL';
% load RECON_5_fold_cv_top_3_feat;
% load Failed_Banks;
% load Survived_Banks;
% load '5_fold_CV_top3_feat_FB';
% load '5_fold_CV_Bank_Cells';
% load DATA_5_CV;
% load CV_3T_Original_Updated;
% load CV_3T_Increased_Updated;
% load CV_3T_Increased_one_year_prior;
% load CV_3T_Increased_two_year_prior;
% load CV_3T_27_feat_one_year;
% load CV_2T_18_feat;

%%% EXPERIMENT PARAMS SETUP %%%
Epochs = 0;
Eta = 0.05;
Sigma0 = sqrt(0.16);
Forgetfactor = 0.99;
Lamda = 0.5;
Rate = 0.25;
Omega = 0.7;
Gamma = 0.1;
forget = 1;
tau = 0.2;
Alpha = 0.0001;
threshold = 0;
best_mean_acc = 0;
BEST_SYSTEMS = [];
primary_threshold = 88;
secondary_threshold = 100;

for cv_num = 1:5

  % top 3 feat x 3 , combined 3 timeline
  % Labels = ["CAPADE_t", "PLAQLY_t","ROE_t","CAPADE_t_1","PLAQLY_t_1","ROE_t_1","CAPADE_t_2","PLAQLY_t_2","ROE_t_2"]

  % 9 feat t
  % Labels = ["CAPADE", "OLAQLY", "PROBLO","PLAQLY", "NIEOIN", "NINMAR", "ROE", "LIQUID", "GROWLA"];
  % 9 feat t-1
  % Labels = ["CAPADE_t_1", "OLAQLY_t_1", "PROBLO_t_1","PLAQLY_t_1", "NIEOIN_t_1", "NINMAR_t_1", "ROE_t_1", "LIQUID_t_1", "GROWLA_t_1"];
  % 9 feat t-2
  % Labels = ["CAPADE_t_2", "OLAQLY_t_2", "PROBLO_t_2","PLAQLY_t_2", "NIEOIN_t_2", "NINMAR_t_2", "ROE_t_2", "LIQUID_t_2", "GROWLA_t_2"];

  % 27 feat
  Labels = ["CAPADE_t", "OLAQLY_t", "PROBLO_t","PLAQLY_t", "NIEOIN_t", "NINMAR_t", "ROE_t", "LIQUID_t", "GROWLA_t", "CAPADE_t_1", "OLAQLY_t_1", "PROBLO_t_1","PLAQLY_t_1", "NIEOIN_t_1", "NINMAR_t_1", "ROE_t_1", "LIQUID_t_1", "GROWLA_t_1", "CAPADE_t_2", "OLAQLY_t_2", "PROBLO_t_2","PLAQLY_t_2", "NIEOIN_t_2", "NINMAR_t_2", "ROE_t_2", "LIQUID_t_2", "GROWLA_t_2"];

  % top 3 feat as per FCMAC
  % Labels = ["CAPADE","PLAQLY","ROE"];

  formatSpec = '\nThe current cv used is: %d';
  str = sprintf(formatSpec,cv_num)
  disp(str);

  %%% assign required data %%%

  % Top 3 features data size same as FCMAC
  % Data = CV1{cv_num,1};
  % Data = Data(:,[3 7 10 2]); % 3 covariates

  % for 9 variable, timeline - last available
  % Data = CV1{cv_num,1}
  % Data(:,6) = [];
  % Data = Data(:,[3:11 2])

  % % for 9 variable, timeline - one year prior
  % Data = CV2{cv_num,1}
  % Data(:,6) = [];
  % Data = Data(:,[3:11 2])

  % % for 9 variable, timeline - two year prior
  % Data = CV3{cv_num,1}
  % Data(:,6) = [];
  % Data = Data(:,[3:11 2])

  % D0 = CV1_with_top_3_features{cv_num,1};
  % D0 = D0(:,[3:5 2]);
  % Data = Data(:,[3 7 10 2]);
  % D2 = D2(:,[3 7 10 2]);
  % D0 = DATA_5_CV{cv_num,1};

  % combined last 3 timeline prediction
  Data = CV_3T{cv_num,1};

  % top 3 features
  % Data = CV1_with_top_3_features{cv_num,1};
  % Data = Data(:,[3:5 2])

  epoch = 0; % this epoch is just for a predefined number of iterations
  not_done_yet = true; % forever loop
  best_acc = 0;
  prev_acc_2 = best_acc;

  best_eer = 100;
  D0 = Data;

  % while(not_done_yet)

  %%% keep track of the previous accuracy %%%
  prev_acc = best_acc;
  limit = size(D0,2) - 1;

  %%% using feature selection algorithm to rank features %%%
  [idx,scores] = fscmrmr(D0(:,[1:limit]), D0(:,limit+1));
  input = D0(:,[1:limit]);
  input = input(:,idx);
  Labels = Labels(:,idx);
  output = D0(:,limit+1);
  D0 = [input output];

  %%% get train data and validation data %%%
  start_test = (size(Data, 1) * 0.2) + 1;
  trainData_D0 = D0(1:start_test-1,:);
  start_validate = floor((size(trainData_D0, 1) * 0.8) + 1);
  valData_D0 = trainData_D0(start_validate:length(trainData_D0),:);
  trainData_D0 = trainData_D0(1:start_validate-1,:); % reduce train data size to 80%

  best_list = [];
  best_val_list = [];
  best_indices = [];
  best_labels = [];
  filter_indices = [];

  second_best_list = [];
  second_best_val_list = [];
  second_best_indices = [];
  second_best_labels = [];
  second_filter_indices = [];

  %%% for input dimension 1 to limit %%%
  for l=1:limit

    %%% maintain a list for current iteration %%%
    curr_list = [best_list trainData_D0(:,l) trainData_D0(:,limit+1)]
    curr_valData = [best_val_list valData_D0(:,l) valData_D0(:,limit+1)]

    trainData_Neg = [];
    trainData_Pos = [];

    target = size(curr_list,2);

    %%% segregating data
    for j=1:size(curr_list,1)
      if curr_list(j,target) == 0
          trainData_Neg = [trainData_Neg; curr_list(j,:)]
      else
          trainData_Pos = [trainData_Pos; curr_list(j,:)]
      end
    end

    %%% input dimension and output dimension %%%
    IND = size(curr_list,2) - 1;
    OUTD = 1;

    % ensemble learning with hcl
    [net_out, net_out_2, max_net_out, max_net_out_2, final_out, system, system_2] = htet_SaFIN_FRIE_with_HCL(trainData_Pos,trainData_Neg,curr_valData,IND,OUTD,Epochs,Eta,Sigma0,Forgetfactor, forget,Lamda, tau,Rate, Omega, Gamma, Alpha);
    [TP, FP, TN, FN, fnr, fpr, acc] = htet_get_classification_results(valData_D0(:,limit+1), final_out);

    %%% balanced error %%%
    curr_eer = (fnr+fpr)/2;
    curr_acc = 100 - curr_eer;
    %%% if the current error is lower than best error, then update the best error %%%
    if curr_acc > primary_threshold && curr_acc > best_acc
        best_list = [best_list trainData_D0(:,l)];
        best_val_list = [best_val_list valData_D0(:,l)];

        best_indices = [best_indices, idx(1,l)];
        best_labels = [best_labels, Labels(1,l)];
        filter_indices = [filter_indices, l];

        best_features = best_indices;
        best_eer = curr_eer;
        best_acc = 100 - best_eer;
    end
    %
    % if curr_acc > secondary_threshold && curr_acc > prev_acc_2
    %     prev_acc_2 = curr_acc;
    %     second_best_list = [best_list trainData_D0(:,l)];
    %     second_best_val_list = [second_best_val_list valData_D0(:,l)];
    %
    %     second_best_indices = [second_best_indices, idx(1,l)];
    %     second_best_labels = [second_best_labels, Labels(1,l)];
    %     second_filter_indices = [second_filter_indices, l];
    %
    %     second_best_features = second_best_indices;
    %     second_best_eer = curr_eer;
    %     second_best_acc = 100 - best_eer;
    % end
  end

  if size(best_indices,1) == 0 && size(second_best_indices,1) == 0
    disp('The required accuracy cannot be found! Please adjust the primary_threshold setting');
    return;
  end


  %%% getting the label dimension %%%
  last_idx = size(Data,2);
  %%% preparing the data for new training + testing %%%
  %%% reuse validation data now for training as well %%%

  if size(best_indices,1) ~= 0
    Data = Data(:,[best_features last_idx]);
  else

    best_indices = second_best_indices;
    best_labels = second_best_labels;
    best_features = second_best_indices;

    Data = Data(:,[best_features last_idx]);
  end
  start_test = (size(Data, 1) * 0.2) + 1;
  train = Data(1:start_test-1,:);
  test = Data(start_test:length(Data), :);
  target = size(train,2);
  trainData_Neg = [];
  trainData_Pos = [];

  for j=1:size(train,1)
    if train(j,target) == 0
        trainData_Neg = [trainData_Neg; train(j,:)]
    else
        trainData_Pos = [trainData_Pos; train(j,:)]
    end
  end

  limit = target-1;
  IND = limit;
  OUTD = 1;
  [net_out, net_out_2, max_net_out, max_net_out_2, final_out, system, system_2] = htet_SaFIN_FRIE_with_HCL(trainData_Pos,trainData_Neg,test,IND,OUTD,Epochs,Eta,Sigma0,Forgetfactor, forget,Lamda, tau,Rate, Omega, Gamma, Alpha);
  [TP, FP, TN, FN, fnr, fpr, acc] = htet_get_classification_results(test(:,limit+1), final_out);

  % max_acc = 0;
  % RESOLUTION = 0.001;
  % cut_off = RESOLUTION;
  %
  % while cut_off <= 1
  %   for i = 1 : size(net_out,1)
  %       if (abs(net_out(i,:) - net_out_2(i,:)) <= cut_off)
  %         if max_net_out(i,:) > max_net_out_2(i,:)
  %           final_out(i,:) = max_net_out(i,:)
  %         else
  %           final_out(i,:) = max_net_out_2(i,:)
  %         end
  %       elseif (net_out(i,:) > net_out_2(i,:))
  %           final_out(i,:) = 1;
  %       else
  %         final_out(i,:) = 0;
  %       end
  %   end
  %
  %   [TP, FP, TN, FN, fnr, fpr, acc] = htet_get_classification_results(test(:,limit+1), final_out);
  %   eer = (fnr+fpr)/2;
  %   balanced_acc = 100 - eer;
  %
  %   if balanced_acc > max_acc
  %     max_acc = balanced_acc;
  %     %%% update the results %%%
  %     best_systems.fnr = fnr;
  %     best_systems.fpr = fpr;
  %     best_systems.eer = (fnr + fpr)/2;
  %     best_systems.cut_off = cut_off;
  %     best_systems.acc = 100 - best_systems.eer;
  %     best_systems.final_out = final_out;
  %   end
  %   cut_off = cut_off + RESOLUTION;
  % end
  best_systems.pos_threshold = (max(net_out) - min(net_out))/2;
  best_systems.neg_threshold = (max(net_out_2) - min(net_out_2))/2;
  best_systems.summary = [net_out net_out_2 final_out test(:,limit+1)];
  best_systems.fnr = fnr;
  best_systems.fpr = fpr;
  best_systems.eer = (fnr + fpr)/2;
  % best_systems.cut_off = cut_off;
  best_systems.acc = 100 - best_systems.eer;
  best_systems.pos_system = system;
  best_systems.neg_system = system_2;
  best_systems.pos_rules = size(system.net.Rules,1);
  best_systems.neg_rules = size(system_2.net.Rules,1);
  best_systems.best_feat = {best_indices};
  best_systems.best_labels = {best_labels};
  best_systems.feat_num = size(best_features,2);
  best_systems.total_rules = size(system.net.Rules,1) + size(system_2.net.Rules,1);

  %%% store the system for each CV group %%%
  BEST_SYSTEMS = [BEST_SYSTEMS; best_systems]

  %%% calculate mean accuracy %%%
  best_mean_acc = best_mean_acc + best_systems.acc;
end

best_mean_acc = best_mean_acc/5;
% alarm sound to alert that the program has ended
load handel;
sound(y,Fs);
