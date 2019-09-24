% XXXXXXXXXXXXXXXXXXXXXXXXXXXX htet_generate_data_for_combined_T_preidction XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
%
% Author    :   Htet
% Date      :   Sep 11, 2019
% Function  :   htet_generate_data_for_combined_T_preidction
% XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
clear;
clc;

load Failed_Banks;
load Survived_Banks;

type = '3T';
index = 3;
backward_offset = 0;
Failed_Banks_Group_By_Bank_ID = [];
Survived_Banks_Group_By_Bank_ID = [];

output_1 = htet_filter_bank_data_by_index(Survived_Banks, backward_offset, type);
output_2 = htet_filter_bank_data_by_index(Failed_Banks, backward_offset, type);

% output_1 = htet_filter_bank_data_by_index(Survived_Banks(:,[1 2 3 7 10]), backward_offset, type);
% output_2 = htet_filter_bank_data_by_index(Failed_Banks(:,[1 2 3 7 10]), backward_offset, type);

Survived_Banks_Group_By_Bank_ID = output_1.result;
Failed_Banks_Group_By_Bank_ID = output_2.result;

CV = htet_generate_cross_validation_data(Survived_Banks_Group_By_Bank_ID, Failed_Banks_Group_By_Bank_ID, 5, true);

% % used to generate 9 inputs taking 3 input each from t, t-1 and t-2
CV_3T = [];
CV_2T = [];
CV_1T = [];

for cv_num = 1:5
  DATA = [];
  TMP = CV{cv_num, 1}
  for j=1:size(TMP,1)
    mat = cell2mat(TMP(j));
    input_record = [];
    for k=1:index
      % input_record = [input_record, mat(k,[3 7 10])]
      input_record = [input_record, mat(k,[3:5])]
    end
    label = mat(k,2);
    input_record = [input_record, label];
    DATA = [DATA; input_record];
  end

  if index == 3
    CV_3T = [CV_3T; {DATA}];
  elseif index == 2
    CV_2T = [CV_2T; {DATA}];
  else
    CV_1T = [CV_1T; {DATA}];
  end
  clear DATA;
end