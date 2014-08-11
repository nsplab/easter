function [] = generate_all()

addpath('cardiac');
addpath('config');
addpath('ssavep');
addpath('util');
addpath('vep');

mkdir(pwd(),  'figures');

plot_all_vep('subject1');
plot_all_ssavep('ssaep', 'subject1');
plot_all_ssavep('ssvep', 'subject1');

plot_all_vep('subject2');
plot_all_ssavep('ssaep', 'subject2');
plot_all_ssavep('ssvep', 'subject2');

cardiac_figure();

end

