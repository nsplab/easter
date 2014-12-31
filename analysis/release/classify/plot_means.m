file_experiment = '../data/subject1/vep/Thu_15_05_2014_11_57_42';
experiment = load_vep(file_experiment, on_off);

figure;
hold on;

plot(mean(experiment{4}(  0 + (1:50),:))', 'LineWidth', 3, 'Color', 'red')
plot(mean(experiment{4}( 50 + (1:50),:))', 'LineWidth', 3, 'Color', 'blue')
plot(mean(experiment{4}(100 + (1:50),:))', 'LineWidth', 3, 'Color', 'black')
plot(mean(experiment{4}(150 + (1:50),:))', 'LineWidth', 3, 'Color', 'green')
