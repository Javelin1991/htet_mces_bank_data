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

Epochs = 0;
Eta = 0.05;
Sigma0 = sqrt(0.16);
Forgetfactor = 0.99;
Lamda = 0.45;
Rate = 0.25;
Omega = 0.7;
Gamma = 0.1;
forget = 1;
tau = 0.7;

threshold = 0;
mean_acc = 0;
best_acc = 0;
BEST_SYSTEMS = [];

epoch = 0;

for cv_num = 1:5

  % Labels = ["CAPADE_t", "PLAQLY_t","ROE_t","CAPADE_t_1","PLAQLY_t_1","ROE_t_1","CAPADE_t_2","PLAQLY_t_2","ROE_t_2"]
  % Labels = ["CAPADE", "OLAQLY", "PROBLO","PLAQLY", "NIEOIN", "NINMAR", "ROE", "LIQUID", "GROWLA"];
  Labels = ["CAPADE_t", "OLAQLY_t", "PROBLO_t","PLAQLY_t", "NIEOIN_t", "NINMAR_t", "ROE_t", "LIQUID_t", "GROWLA_t", "CAPADE_t_1", "OLAQLY_t_1", "PROBLO_t_1","PLAQLY_t_1", "NIEOIN_t_1", "NINMAR_t_1", "ROE_t_1", "LIQUID_t_1", "GROWLA_t_1", "CAPADE_t_2", "OLAQLY_t_2", "PROBLO_t_2","PLAQLY_t_2", "NIEOIN_t_2", "NINMAR_t_2", "ROE_t_2", "LIQUID_t_2", "GROWLA_t_2"];
% Labels = ["CAPADE_t_1", "OLAQLY_t_1", "PROBLO_t_1","PLAQLY_t_1", "NIEOIN_t_1", "NINMAR_t_1", "ROE_t_1", "LIQUID_t_1", "GROWLA_t_1"];
% Labels = ["CAPADE_t_2", "OLAQLY_t_2", "PROBLO_t_2","PLAQLY_t_2", "NIEOIN_t_2", "NINMAR_t_2", "ROE_t_2", "LIQUID_t_2", "GROWLA_t_2"];
  % Labels = ["CAPADE","PLAQLY","ROE"];

  formatSpec = '\nThe current cv used is: %d';
  str = sprintf(formatSpec,cv_num)
  disp(str);

  % D0 = CV_2T{cv_num,1};
  % D0(:,6) = []; % removing ADQLLP
  % D0 = D0(:,[3 7 10 2]); % 9 covariates

  D0 = CV1{cv_num,1}
  D0(:,6) = [];
  D0 = D0(:,[3:11 2])
  % % D1 = CV2{cv_num,1}
  % % D2 = CV3{cv_num,1}
  % D0 = CV1_with_top_3_features{cv_num,1};
  % D0 = D0(:,[3:5 2]);
  % D1 = D1(:,[3 7 10 2]);
  % D2 = D2(:,[3 7 10 2]);
  % D0 = DATA_5_CV{cv_num,1};
  % D0 = CV_3T{cv_num,1};

  epoch = 0;
  not_done_yet = true;

  while(not_done_yet)

      prev_acc = best_acc;

      limit = size(D0,2) - 1;
      [idx,scores] = fscmrmr(D0(:,[1:limit]), D0(:,limit+1));
      input = D0(:,[1:limit]);
      input = input(:,idx);
      Labels = Labels(:,idx);
      output = D0(:,limit+1);
      D0 = [input output];

      start_test = (size(D0, 1) * 0.2) + 1;
      trainData_D0 = D0(1:start_test-1,:);
      testData_D0 = D0(start_test:length(D0), :);

      best_list = [];
      best_tst_list = [];
      best_eer = 100;
      best_indices = [];
      best_labels = [];
      filter_indices = [];

      for l=1:limit
        curr_list = [best_list trainData_D0(:,l) trainData_D0(:,limit+1)]
        curr_tstData = [best_tst_list testData_D0(:,l) testData_D0(:,limit+1)]

        CL(l) = {curr_list};

        max_acc = 0;
        trainData_Neg = [];
        trainData_Pos = [];

        target = size(curr_list,2);

        for j=1:size(curr_list,1)
          if curr_list(j,target) == 0
              trainData_Neg = [trainData_Neg; curr_list(j,:)]
          else
              trainData_Pos = [trainData_Pos; curr_list(j,:)]
          end
        end
        IND = size(curr_list,2) - 1;
        OUTD = 1;

        % ensemble learning with hcl
        [net_out, net_out_2, final_out, system, system_2] = htet_SaFIN_FRIE_with_HCL(trainData_Pos,trainData_Neg,curr_tstData,IND,OUTD,Epochs,Eta,Sigma0,Forgetfactor, forget,Lamda, tau,Rate, Omega, Gamma);
        [TP, FP, TN, FN, fnr, fpr, acc] = htet_get_classification_results(testData_D0(:,limit+1), final_out);
        op.fnr = fnr;
        op.fpr = fpr;
        op.eer = (fnr+fpr)/2;

        if op.eer < best_eer
          best_list = [best_list trainData_D0(:,l)];
          best_tst_list = [best_tst_list testData_D0(:,l)];
          best_indices = [best_indices, idx(1,l)];
          best_labels = [best_labels, Labels(1,l)];
          filter_indices = [filter_indices, l];
          best_eer = op.eer;
          best_acc = 100 - best_eer;

          best_systems.pos_system = system;
          best_systems.neg_system = system_2;
          best_systems.pos_rules = size(system.net.Rules,1);
          best_systems.neg_rules = size(system_2.net.Rules,1);
          best_systems.best_feat = {best_indices};
          best_systems.best_labels = {best_labels};
          best_systems.fnr = fnr;
          best_systems.fpr = fpr;
          best_systems.eer = best_eer;
          best_systems.acc = best_acc;
          best_systems.feat_num = size(best_indices,2);
          best_systems.total_rules = size(system.net.Rules,1) + size(system_2.net.Rules,1);
          best_systems.pos_out = net_out;
          best_systems.neg_out = net_out_2;
          best_systems.final_out = final_out;
          best_systems.testData = [best_tst_list testData_D0(:,limit+1)];
        end
      end
      epoch = epoch + 1;

      if best_acc > 99 || epoch > 2
        break;
      else
        Labels = Labels(:,filter_indices);
        filter_indices = [filter_indices, limit+1];
        D0 = D0(:,filter_indices);
      end
  end

  BEST_SYSTEMS = [BEST_SYSTEMS; best_systems]
  final_acc(cv_num) = best_acc;
  mean_acc = mean_acc + best_acc;
end

mean_acc = mean_acc/5;
% alarm sound to alert that the program has ended
load handel;
sound(y,Fs);