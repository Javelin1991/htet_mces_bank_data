% Nakanishi datasets

load ron_naka;
load naka3;

warning('off');

i = 1;
spec(i).algo = 'ierspop';
i = i + 1;
%spec(i).algo = 'rspop'; i = i + 1;
% %(i).algo = 'pop'; i = i + 1;
% % spec(i).algo = 'efunn'; i = i + 1;
%spec(i).algo = 'anfis'; i = i + 1;
% % spec(i).algo = 'denfis'; i = i + 1;
%spec(i).algo = 'saifin'; i = i + 1;
%
for Z = 2:2

    switch Z
        case 1
            data_input = naka1_input;
            data_target = naka1_target;
        case 2
            data_input = naka2_input;
            data_target = naka2_target;
        case 3
            data_input = naka3_input;
            data_target = naka3_target;
%             data_input = naka_new3_input;
%             data_target = naka_new3_target;
%             data_input = naka_input3;
%             data_target = naka_target3;
    end

    start_test = (size(data_input, 1) / 2) + 1;
    inMF = zeros(size(spec, 2), size(data_input, 2));
    outMF = zeros(size(spec, 2), size(data_target, 2));
    window =90;

    figure;
    plot(1:size(data_input,1),data_input(1:size(data_input,1), 2));
    figure;
    hold all;
    plot(1:size(data_input,1),data_input(1:size(data_input,1), 1));
    for l=3:size(data_input,2)
    plot(1:size(data_input,1),data_input(1:size(data_input,1), l));

    end

    for i = 1 : size(spec, 2)

        switch spec(i).algo
        % XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX ieRSPOP XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
            case {'ierspop'}
                disp(['Running algo : ', spec(i).algo]);

                ensemble = update_ron_trainOnline(data_input, data_target, spec(i).algo, window);
                ensemble = ron_calcErrors(ensemble, data_target(start_test : size(data_target, 1)));


                figure;
                str = [sprintf('Actual VS Predicted')];
                title(str);

                for l = 1:size(data_target,2)
                hold on;
                plot(1:size(data_target,1),data_target(1:size(data_target,1)), 'b');
                plot(1:size(ensemble.predicted,1),ensemble.predicted(1:size(data_target,1)), 'r');
                end

                %legend('Actual','ieRSPOP');

                r(i, Z) = ensemble.R;
                 r2(i,Z) = ensemble.R2;
                rmse(i, Z) = sqrt(ensemble.MSE);
                rules(i, Z) = ensemble.num_rules;
                %plot(start_test:size(data_target,1),ensemble.predicted(start_test:size(data_target,1)), 'r');
        % XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX RSPOP XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
            case 'rspop'

                net = member('gen', 'spsec', data_input(1 : start_test - 1, :), data_target(1 : start_test - 1, :));

                [net Ot] = popfnn('train', 'rspop', net, data_input(1 : start_test - 1, :), data_target(1 : start_test - 1, :));
                [net Ot] = popfnn('train', 'reduce1', net, data_input(1 : start_test - 1, :), data_target(1 : start_test - 1, :), [0 NaN]);
                 %[net Ot] = popfnn('train', 'reduce2', net, data_input(1 : start_test - 1, :), data_target(1 : start_test - 1, :), [0 NaN]);
                clear Ot;

                Ot = popfnn('compute', net, data_input(1 : start_test - 1, :));
                Oc = popfnn('compute', net, data_input(start_test : size(data_target, 1), :));

                train_predicted = Ot;
                test_predicted = Oc;

                net.predicted = test_predicted;
                net = ron_calcErrors(net, data_target(start_test : size(data_target, 1)));
                r(i, Z) = net.R;
                r2(i,Z) = net.R2;
                rmse(i, Z) = sqrt(net.MSE);
                rules(i, Z) = net.num_rules;
                plot(start_test:size(data_target,1),net.predicted(1:start_test-1), 'm');
        % XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX POP XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
            case 'pop'

                net = member('gen', 'spsec', data_input(1 : start_test - 1, :), data_target(1 : start_test - 1, :));

                [net Ot] = popfnn('train', 'pop', net, data_input(1 : start_test - 1, :), data_target(1 : start_test - 1, :));
                clear D.Ot;

                Ot = popfnn('compute', net, data_input(1 : start_test - 1, :));
                Oc = popfnn('compute', net, data_input(start_test : size(data_target, 1), :));

                train_predicted = Ot;
                test_predicted = Oc;

                net.predicted = test_predicted;
                net = ron_calcErrors(net, data_target(start_test : size(data_target, 1)));
                r(i, Z) = net.R;
               r2(i,Z) = net.R2;
                rmse(i, Z) = sqrt(net.MSE);
                rules(i, Z) = net.num_rules;
                plot(start_test:size(data_target,1),net.predicted(1:start_test-1));
        % XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX EFuNN XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
            case 'efunn'

                C.dispmode = 0;
                trnData = [data_input(1 : start_test - 1, :), data_target(1 : start_test - 1, :)];
                tstData = [data_input(start_test : size(data_target, 1), :), data_target(start_test : size(data_target, 1), :)];
                net = efunn(trnData, C);
                tfis = efunns(trnData, net);
                cfis = efunns(tstData, net);

                train_predicted = tfis.Out;
                test_predicted = cfis.Out;

                net.predicted = test_predicted;
                net = ron_calcErrors(net, data_target(start_test : size(data_target, 1)));
                r(i, Z) = net.R;
                 r2(i,Z) = net.R2;
                rmse(i, Z) = sqrt(net.MSE);
                rules(i, Z) = net.num_rules;
                plot(start_test:size(data_target,1),net.predicted(1:start_test-1));
        % XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX ANFIS XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
            case 'anfis'

                trnData = [data_input(1 : start_test - 1, :), data_target(1 : start_test - 1, :)];
                epoch_n = 100;
                % Parameters fixed at 0.3
                infis = genfis2(data_input(1 : start_test - 1, :), data_target(1 : start_test - 1, :), 0.3);
                net = anfis(trnData, infis, epoch_n);

                train_predicted = evalfis(data_input(1 : start_test - 1, :)', net);
                test_predicted = evalfis(data_input(start_test : size(data_target, 1), :)', net);

                net.predicted = test_predicted;
                net = ron_calcErrors(net, data_target(start_test : size(data_target, 1)));
                r(i, Z) = net.R;
                 r2(i,Z) = net.R2;
                rmse(i, Z) = sqrt(net.MSE);
                rules(i, Z) = net.num_rules;
                plot(start_test:size(data_target,1),net.predicted(1:start_test-1), 'g');
        % XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX DENFIS XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
            case 'denfis'

                C.trainmode = 2;

                trnData = [data_input(1 : start_test - 1, :), data_target(1 : start_test - 1, :)];
                tstData = [data_input(start_test : size(data_target, 1), :), data_target(start_test : size(data_target, 1), :)];
                net = denfis(trnData, C);
                tfis = denfiss(trnData, net);
                cfis = denfiss(tstData, net);

                train_predicted = tfis.Out';
                test_predicted = cfis.Out';

                net.predicted = test_predicted;
                net = ron_calcErrors(net, data_target(start_test : size(data_target, 1)));
                r(i, Z) = net.R;
                 r2(i,Z) = net.R2;
                rmse(i, Z) = sqrt(net.MSE);
                rules(i, Z) = net.num_rules;
                plot(start_test:size(data_target,1),net.predicted(1:start_test-1));
            case 'saifin'

                train_IN= data_input(1 : start_test - 1, :);
                train_OUT = data_target(1 : start_test - 1, :);
                test= [data_input(start_test : size(data_target, 1), :), data_target(start_test : size(data_target, 1), :)];
                [predicted, R, Rules, MSE] = Run_SaFIN(train_IN,train_OUT,test,0.25,0.65,300,0.05);

                net.predicted = predicted;
                net = ron_calcErrors(net, data_target(start_test : size(data_target, 1)));
%                 r2(i, Z) = R;
%                 rmse(i, Z) = sqrt(MSE);
                r(i, Z) = net.R;
                 r2(i,Z) = net.R2;
                rmse(i, Z) = sqrt(net.MSE);
                rules(i, Z) = size(Rules,1);
                plot(start_test:size(data_target,1),predicted(1:size(predicted,1)), 'y');

        end


    end
      legend('Actual','ieRSPOP++', 'RSPOP', 'ANFIS', 'SAFIN');
    clear data_input data_target;

end
