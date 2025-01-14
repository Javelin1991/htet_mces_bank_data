% XXXXXXXXXXXXXXXXXXXXXXXXXXXX MAR_CALCULATE_AGE2 XXXXXXXXXXXXXXXXXXXXXXXXX
%
% Author    :   Mario Hartanto
% Date      :   Feb 1 2014
% Function  :   creates membership functions incrementally
% Syntax    :   mar_calculate_age2(neuron, data_input, threshold_mf, current_count, end_of_phase_1)
%
%
% Algorithm -
% 1) Update Age
% 2) Find second derivative
% XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX


function [drift_detected, neuron] = mar_calculate_age2( neuron, data, threshold_mf, current_count, end_of_phase_1 )

%disp('mar_calculate_age2');

    num_mf = size(neuron.mf, 2);
    mf_values = zeros(1, num_mf);

    for j = 1 : num_mf
        if(neuron.mf(j).params(1) ~= 0 && neuron.mf(j).params(3) ~= 0)
            mf_values(j) = gauss2mf(data, neuron.mf(j).params);
        end
    end

    [max_mf_value, max_index] = max(mf_values);
    neuron.age = [neuron.age; max(neuron.age) + (1 - max_mf_value)];

%     disp('neuron age:');
%     disp(neuron.age);

    second_diff_age = diff(diff(neuron.age));
    drift_detected = false;

    if current_count < end_of_phase_1
        if max_mf_value < 0.5
            drift_detected = true;
        end
        return;
    end

    disp('second_diff_age')
    disp(second_diff_age)

    disp('second_diff_age size')
    disp(size(second_diff_age, 1))

    disp('current_count')
    disp(current_count)

    disp('max_mf_value')
    disp(max_mf_value)

    disp('threshold_mf')
    disp(threshold_mf)

    is_valid_index = true;
    v1 = current_count - 2;
    v2 = current_count - 3;

    if (v1 > size(second_diff_age, 1) || v2 > size(second_diff_age, 1))
      is_valid_index = false;
    end

    if (is_valid_index && second_diff_age(current_count - 2) > second_diff_age(current_count - 3) && max_mf_value < threshold_mf )
        drift_detected = true;
    end
end
