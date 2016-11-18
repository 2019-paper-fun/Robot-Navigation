figure(1)
plot(data(:,1),data(:,2));
hold on
plot(sig_res(:,1), sig_res(:,2));
plot(tan_res(:,1), tan_res(:,2));
plot(relu_res(:,1), relu_res(:,2));
legend('Ideal', 'Sigmoid', 'Htan', 'ReLU','Location','northwest')

figure(2)
plot(sig_MSE);
hold on
plot(tan_MSE);
plot(relu_MSE);
legend('Sigmoid', 'Htan', 'ReLU')