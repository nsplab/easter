function [ accuracy, sensitivity, specificity ] = evaluate(file_experiment, file_control, on_off, control_type)

experiment = load_vep(file_experiment, on_off);
[ control, digital_data, pre, post ] = load_vep(file_control, on_off);

if strfind(file_experiment, 'subject1')
    subject_ID = 'subject1';
elseif strfind(file_experiment, 'subject2')
    subject_ID = 'subject2';
end

[ accuracy, sensitivity, specificity ] = evaluate_h(experiment, control, subject_ID, digital_data, pre, post, control_type);

end

