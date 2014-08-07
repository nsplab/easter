%% For paper figure 2
plot_all_ssavep('ssvep', '8rabbit_apr_24_2014', 2, [5]); 
plot_all_ssavep('ssvep', '10rabbit_may_15_2014', 2, [11]);
plot_all_ssavep('ssaep', '10rabbit_may_15_2014', 2, [15]);
plot_all_ssavep('ssvep', '9rabbit_may_6_2014', 2, [5]);
plot_all_ssavep('ssaep', '9rabbit_may_6_2014', 2, [8]);

%ssavep_different('8rabbit_apr_24_2014', 'ssaep', 18, 'ssvep', 24);
ssavep_different('8rabbit_apr_24_2014', 'ssaep', 5, 'ssvep', 5);

%% For paper figure 2 live control version
plot_all_ssavep('ssvep', '8rabbit_apr_24_2014', 2, [36]); 
plot_all_ssavep('ssvep', '9rabbit_may_6_2014', 2, [8]);
plot_all_ssavep('ssaep', '9rabbit_may_6_2014', 2, [11]);
plot_all_ssavep('ssvep', '10rabbit_may_15_2014', 2, [14]);
plot_all_ssavep('ssaep', '10rabbit_may_15_2014', 2, [12]);

ssavep_different('8rabbit_apr_24_2014', 'ssaep', 26, 'ssvep', 36);

%% For paper figure 3
plot_all_ssavep('ssvep', '10rabbit_may_15_2014', 2, [2 11 23 32 35 14 38]);
plot_all_ssavep('ssaep', '10rabbit_may_15_2014', 2, [3 15 24 33 36 12 40]);

% Resting state (resting state - dead control) for SSAEP 86 Hz
artifact('10rabbit_may_15_2014', 'ssaep', 15, 40); % basilar tip
artifact('10rabbit_may_15_2014', 'ssaep', 24, 40); % mid-basilar
artifact('10rabbit_may_15_2014', 'ssaep', 33, 40); % vb junction
artifact('10rabbit_may_15_2014', 'ssaep', 36, 40); % basilar tip
artifact('10rabbit_may_15_2014', 'ssaep', 12, 40); % live control
artifact('10rabbit_may_15_2014', 'ssaep', 40, 40); % dead control

% Resting state (resting state - dead control) for SSVEP 40 Hz
artifact('10rabbit_may_15_2014', 'ssvep', 11, 38); % basilar tip
artifact('10rabbit_may_15_2014', 'ssvep', 23, 38); % mid-basilar
artifact('10rabbit_may_15_2014', 'ssvep', 32, 38); % vb junction
artifact('10rabbit_may_15_2014', 'ssvep', 35, 38); % basilar tip
artifact('10rabbit_may_15_2014', 'ssvep', 14, 38); % live control
artifact('10rabbit_may_15_2014', 'ssvep', 38, 38); % dead control

% Resting state only for 9
% ssvep 40 Hz
artifact('9rabbit_may_6_2014', 'ssvep',  5, 5); % basilar tip
artifact('9rabbit_may_6_2014', 'ssvep', 29, 5); % mid-basilar
artifact('9rabbit_may_6_2014', 'ssvep', 32, 5); % vb junction
artifact('9rabbit_may_6_2014', 'ssvep', 38, 5); % basilar tip
artifact('9rabbit_may_6_2014', 'ssvep',  8, 5); % live control
%artifact('9rabbit_may_6_2014', 'ssvep', 38, 5); % dead control
% ssaep 86
artifact('9rabbit_may_6_2014', 'ssaep',  8, 8); % basilar tip
artifact('9rabbit_may_6_2014', 'ssaep', 32, 8); % mid-basilar
artifact('9rabbit_may_6_2014', 'ssaep', 35, 8); % vb junction
artifact('9rabbit_may_6_2014', 'ssaep', 41, 8); % basilar tip
artifact('9rabbit_may_6_2014', 'ssaep', 11, 8); % live control

return
plot_all_ssavep('ssvep', '10rabbit_may_15_2014', 2, [2 11 23 32 35 14 38]);
plot_all_ssavep('ssaep', '10rabbit_may_15_2014', 2, [3 15 24 33 36 12 40]);
plot_all_ssavep('ssvep', '9rabbit_may_6_2014', 2, [2 5 29 32 38 8]);
plot_all_ssavep('ssaep', '9rabbit_may_6_2014', 2, [5 8 32 35 41 11]);
return
% experiment - live control
artifact('10rabbit_may_15_2014', 'ssaep', 15, 12); % SSAEP 86 Hz
artifact('10rabbit_may_15_2014', 'ssvep', 11,  8); % SSVEP 40 Hz
                                         %11   8
artifact('9rabbit_may_6_2014',   'ssvep',  8, 11); % SSVEP 40 Hz
artifact('9rabbit_may_6_2014',   'ssaep', 14, 17); % SSAEP 86 Hz

%artifact('8rabbit_apr_24_2014',  'ssaep', 14, 17); % SSAEP 86 Hz
%artifact('8rabbit_apr_24_2014',  'ssvep',  8, 11); % SSVEP 40 Hz

return;

plot_all_ssavep('ssvep', '10rabbit_may_15_2014', 2, [2 11 23 32 35 14 38]);
plot_all_ssavep('ssaep', '10rabbit_may_15_2014', 2, [3 15 24 33 36 12 40]);
plot_all_ssavep('ssvep', '9rabbit_may_6_2014', 2, [2 5 29 32 38 8]);
plot_all_ssavep('ssaep', '9rabbit_may_6_2014', 2, [5 8 32 35 41 11]);

