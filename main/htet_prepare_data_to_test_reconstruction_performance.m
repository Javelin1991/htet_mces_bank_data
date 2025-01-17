% XXXXXXXXXXXXXXXXXXXXXXXXXXXX htet_prepare_data_to_test_reconstruction_performance XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
%
% Author    :   Htet
% Date      :   Sep 11, 2019
% Function  :   used to generate test data that are randomly populated with NaN values
%               so that reconstruction algorithm's performance can be measured and tested
% Syntax    :
% Stars     :   ****
% XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX

clc;
clear;

% total time taken to run this file is 1 min 27 sec

load Failed_Banks;
load Survived_Banks;

load FAILED_BANK_DATA_HORIZONTAL;
load SURVIVED_BANK_DATA_HORIZONTAL;


Failed_Banks_Group_By_Bank_ID = [];
Survived_Banks_Group_By_Bank_ID = [];

Failed_Banks(any(isnan(Failed_Banks), 2), :) = [];
Survived_Banks(any(isnan(Survived_Banks), 2), :) = [];

output_1 = htet_filter_bank_data_by_index(Survived_Banks(:,[1:3 7 10]), 0);
output_2 = htet_filter_bank_data_by_index(Failed_Banks(:,[1:3 7 10]), 0);

Survived_Banks_Group_By_Bank_ID = output_1.result;
Failed_Banks_Group_By_Bank_ID = output_2.result;

Survived_Banks_Group_By_Bank_ID_Full_Records = output_1.full_record;
Failed_Banks_Group_By_Bank_ID_Full_Records = output_2.full_record;

Failed_IDs = output_2.id;
Survived_IDs = output_1.id;

PREPARED_DATA = [];

for itr = 1:2
  if itr == 1
    unseen_testData = FAILED_BANK_DATA_HORIZONTAL{1, 1}.TEST_DATA_TO_PREDICT_ROE
    A = generate_random_num_to_remove(unseen_testData);
    % B is randomly populated with NaN and ready to use for testing
    B = populate_random_NaN_in_full_records(unseen_testData, A, Failed_Banks_Group_By_Bank_ID_Full_Records, Failed_IDs);
    % Z is to retrieve reconstructed values and measure performance
    Z = htet_get_predicted_and_ground_truth_values(unseen_testData, A, B, Failed_Banks_Group_By_Bank_ID_Full_Records, Failed_IDs);
    IDs = Failed_IDs;
    Original = Failed_Banks_Group_By_Bank_ID_Full_Records;
  else
    unseen_testData = SURVIVED_BANK_DATA_HORIZONTAL{1, 1}.TEST_DATA_TO_PREDICT_ROE
    A = generate_random_num_to_remove(unseen_testData);
    % B is randomly populated with NaN and ready to use for testing
    B = populate_random_NaN_in_full_records(unseen_testData, A, Survived_Banks_Group_By_Bank_ID_Full_Records, Survived_IDs);
    % Z is to retrieve reconstructed values and measure performance
    Z = htet_get_predicted_and_ground_truth_values(unseen_testData, A, B, Survived_Banks_Group_By_Bank_ID_Full_Records, Survived_IDs);
    IDs = Survived_IDs;
    Original = Survived_Banks_Group_By_Bank_ID_Full_Records;
  end
  PREPARED_DATA = [PREPARED_DATA; [{A}, {B}, {Z}, {IDs}, {Original}]];
  A = []; B = []; Z = []; IDs = []; Original = [];
end

function A = generate_random_num_to_remove(unseen_testData)
  A = [];
  for i=1:length(unseen_testData)
      record = unseen_testData(i,:);
      ran_num = randi(3) + 1;
      val_at_ran_num = unseen_testData(i,ran_num);
      record(1, ran_num) = NaN;
      A = [A; [record, ran_num, val_at_ran_num]];
  end
end

function out = populate_random_NaN_in_full_records(unseen_testData, A, B, IDs)
  for i = 1:length(unseen_testData)
      bID = unseen_testData(i,1);
      idx = find(bID == IDs);
      t = B(idx,:);
      % retrieve the corresponding records for a given Bank based on Bank ID, i.e bID
      d = t{1,1};
      for j = 1:size(d,1)
          % get the sum of the targeted record in the original record
          sum = d(j,[1 3 4 5]);
          % get the sum of the targeted record in unseen test data
          sum1 = unseen_testData(i,:);
          % if the sum are equal, we have found the respective row of the targeted record
          if sum == sum1
              % populate that row with random NaN
              d(j, 3:5) = A(i, 2:4)
              % save the record back into the original record;
              B(idx,:) = {d};
          end
      end
  end
  out = B;
end
