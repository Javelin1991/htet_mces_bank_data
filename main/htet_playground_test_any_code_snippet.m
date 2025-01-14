% XXXXXXXXXXXXXXXXXXXXXXXXXXXX htet_playground_test_any_code_snippet XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
%
% Author    :   Htet
% Date      :   Sep 11, 2019
% Function  :   dummy file that is used to test any code snippet in matlab
% Stars     :
% XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX


% data pre-processing
clear;
clc;
close all;

load CV1_Corrected_Denfis_Recon_100;
load CV2_Corrected_Denfis_Recon_100;
load CV3_Corrected_Denfis_Recon_100;

fb = 0;
sb = 0;

D = CV3{1,1}

for i=1:size(D,1)
    if D(i,2) == 0
        sb = sb + 1;
    else
        fb = fb + 1;
    end
end

%
% tr_fb_cv1 = [];
% tt_fb_cv1 = [];
%
% tr_sb_cv1 = [];
% tt_sb_cv1 = [];
%
% D = CV1{1,1}
%
% start_test = size(D,1) * 0.2 + 1;
%
% D_tr = D(1:start_test-1, :)
% D_tt = D(start_test:size(D,1),:)
%
% for i=1:size(D_tr,1)
%     if D_tr(i,2) == 1
%         tr_fb_cv1 = [tr_fb_cv1; D_tr(i,:)]
%     else
%         tr_sb_cv1 = [tr_sb_cv1; D_tr(i,:)]
%     end
% end
%
% for i=1:size(D_tt,1)
%     if D_tt(i,2) == 1
%         tt_fb_cv1 = [tt_fb_cv1; D_tt(i,:)]
%     else
%         tt_sb_cv1 = [tt_sb_cv1; D_tt(i,:)]
%     end
% end
%
% TRAIN_DATA = (vertcat(tr_fb_cv1, tr_sb_cv1))'
% TRAIN_DATA([1 2 6], :) = []
% TEST_DATA = (vertcat(tt_fb_cv1, tt_sb_cv1))'
% TEST_DATA([1 2 6], :) = []
