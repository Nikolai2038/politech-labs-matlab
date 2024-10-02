
classdef application < matlab.apps.AppBase

    % Properties that correspond to app components
    properties (Access = public)
        ModelSignalGeneratorUIFigure    matlab.ui.Figure
        TabGroup                        matlab.ui.container.TabGroup
        Lab1SignalTab                   matlab.ui.container.Tab
        SignalLabel_1                   matlab.ui.control.Label
        UIAxesSignals_1                 matlab.ui.control.UIAxes
        Lab2FourierTab                  matlab.ui.container.Tab
        LogsTextArea_2                  matlab.ui.control.TextArea
        LogsTextAreaLabel               matlab.ui.control.Label
        FouriercomplexSKOLabel_2        matlab.ui.control.Label
        FourierSKOLabel_2               matlab.ui.control.Label
        ClearTableButton_2              matlab.ui.control.Button
        UITableSKO_2                    matlab.ui.control.Table
        FouriercomplexLabel_2           matlab.ui.control.Label
        FourierLabel_2                  matlab.ui.control.Label
        SignalLabel_2                   matlab.ui.control.Label
        UIAxesSKO_2                     matlab.ui.control.UIAxes
        UIAxesSignals_2                 matlab.ui.control.UIAxes
        Lab3FiltersTab                  matlab.ui.container.Tab
        LogsTextArea_3                  matlab.ui.control.TextArea
        LogsTextArea_3Label             matlab.ui.control.Label
        FouriercomplexSKOLabel_3        matlab.ui.control.Label
        FourierSKOLabel_3               matlab.ui.control.Label
        ClearTableButton_3              matlab.ui.control.Button
        UITableSKO_3                    matlab.ui.control.Table
        FouriercomplexLabel_3           matlab.ui.control.Label
        FourierLabel_3                  matlab.ui.control.Label
        SignalLabel_3                   matlab.ui.control.Label
        UIAxesSKO_3                     matlab.ui.control.UIAxes
        UIAxesSignals_3                 matlab.ui.control.UIAxes
        TheNumberOfFourierSeriesTermsEditFieldLabelKMax  matlab.ui.control.Label
        TheNumberOfFourierSeriesTermsEditFieldLabelKMin  matlab.ui.control.Label
        TheNumberOfFourierSeriesTermsEditField  matlab.ui.control.NumericEditField
        ThenumberofFourierseriestermsKkpKN4Label  matlab.ui.control.Label
        NumberOfAccumulationsEditField  matlab.ui.control.NumericEditField
        NumberOfAccumulationsLabel      matlab.ui.control.Label
        SignalTypeDropDown              matlab.ui.control.DropDown
        ModelSignalGeneratorLabel       matlab.ui.control.Label
        SignalTypeLabel                 matlab.ui.control.Label
        NumberOfPointsNEditField        matlab.ui.control.NumericEditField
        NumberOfPointsLabel             matlab.ui.control.Label
        NoiseTypeDropDown               matlab.ui.control.DropDown
        NoiseTypeLabel                  matlab.ui.control.Label
        SignalAmplitudeEditField        matlab.ui.control.NumericEditField
        SignalAmplitudeLabel            matlab.ui.control.Label
        NoiseSKOEditField               matlab.ui.control.NumericEditField
        NoiseSKOLabel                   matlab.ui.control.Label
        PeriodsNumberkpEditField        matlab.ui.control.NumericEditField
        PeriodsNumberLabel              matlab.ui.control.Label
        GenerateButton                  matlab.ui.control.Button
    end

    
    properties (Access = private)
        FourierData
        FiltersData
    end
    
    methods (Access = private)
        function UpdateTableChart(~, table, data, axes)
            if (isempty(data))
                % Empty the data
                table.Data = [];

                % Clear chart
                cla(axes);
            % For interpolation, we need at least 2 different points
            else
                % Load data from variable
                table.Data = array2table(data, 'VariableNames',{'c01','c02','c03'});
                
                if (size(data, 1) >= 2)
                    x = table.Data.c01;
                    y_1 = table.Data.c02;
                    y_2 = table.Data.c03;
    
                    % Create 100 more points for interpolation
                    x_interpolated = linspace(min(x), max(x), 100);
                    
                    % Apply interpolation
                    y_1_interpolated = interp1(x, y_1, x_interpolated, 'pchip');
                    % Draw chart 1 with soft line and points
                    plot(axes, x_interpolated, y_1_interpolated, 'b-', x, y_1, 'bo');
                    
                    % Apply interpolation
                    y_2_interpolated = interp1(x, y_2, x_interpolated, 'pchip');
                    % Draw chart 2 with soft line and points
                    hold(axes, 'on');
                    plot(axes, x_interpolated, y_2_interpolated, 'm-', x, y_2, 'mo');
                    hold(axes, 'off');
                end
            end
        end
        
        function UpdateMinLimit(app)
            % Update text in label for minimum
            app.TheNumberOfFourierSeriesTermsEditFieldLabelKMin.Text = app.PeriodsNumberkpEditField.Value + " <=";
            % Update edit field minimum and maximum (do not include maximum in edit field properties)
            app.TheNumberOfFourierSeriesTermsEditField.Limits = [app.PeriodsNumberkpEditField.Value, app.NumberOfPointsNEditField.Value / 4];
        end
        
        function UpdateMaxLimit(app)
            % Update text in label for maximum
            app.TheNumberOfFourierSeriesTermsEditFieldLabelKMax.Text = "<= " + app.NumberOfPointsNEditField.Value / 4;
            % Update edit field minimum and maximum (do not include maximum in edit field properties)
            app.TheNumberOfFourierSeriesTermsEditField.Limits = [app.PeriodsNumberkpEditField.Value, app.NumberOfPointsNEditField.Value / 4];
        end
        
        function UpdateTableChartFourier(app)
            app.UpdateTableChart(app.UITableSKO_2, app.FourierData, app.UIAxesSKO_2);
        end
        
        function UpdateTableChartFilters(app)
            app.UpdateTableChart(app.UITableSKO_3, app.FiltersData, app.UIAxesSKO_3);
        end
        
        function ClearTableFourier(app)
            app.FourierData = [];
            app.UpdateTableChartFourier();
        end
        
        function ClearTableFilters(app)
            app.FiltersData = [];
            app.UpdateTableChartFilters();
        end
    end
    

    % Callbacks that handle component events
    methods (Access = private)

        % Code that executes after component creation
        function startupFcn(app)
            % Create ".m" file with ".mlapp" MATLAB code (for track changes in GIT)
            writelines(evalc('type(mfilename(''fullpath'') + ".mlapp")'), mfilename('fullpath') + ".m");

            app.UpdateMinLimit();
            app.UpdateMaxLimit();
        end

        % Callback function
        function QuitButtonPushed(app, event)
            % Close the app
            app.delete();
        end

        % Button pushed function: GenerateButton
        function GenerateButtonPushed(app, event)
            % Количество периодов гармонической функции (kp)
            periods_number = app.PeriodsNumberkpEditField.Value;
            
            % Количество членов ряда Фурье (K)
            K = app.TheNumberOfFourierSeriesTermsEditField.Value;

            % Количество отсчетов (элементов массива y(t)) (number_of_points)
            number_of_points = app.NumberOfPointsNEditField.Value;
            
            noise_sko = app.NoiseSKOEditField.Value;
            signal_amplitude = app.SignalAmplitudeEditField.Value;
            number_of_accumulations = app.NumberOfAccumulationsEditField.Value;

            % Create X array
            x = 1:number_of_points;

            % Create Y array
            y_accumulated = zeros(1, number_of_points);
            y_accumulated_without_noise = zeros(1, number_of_points);

            T = pi;

            % ========================================
            % Лабораторная работа 1
            % ========================================
            % ----------------------------------------
            % Изначальный сигнал: Высчитываем
            % ----------------------------------------
            noise = zeros(1, number_of_points);
            for iteration = 1:number_of_accumulations
                % Create Y array
                y = zeros(1, number_of_points);
                y_without_noise = zeros(1, number_of_points);

                % Generate noise
                if (app.NoiseTypeDropDown.Value == "Normally Distributed")
                    noise = randn(number_of_points);
                elseif (app.NoiseTypeDropDown.Value == "White Gaussian Noise")
                    noise = wgn(number_of_points, 1, 0);
                else
                    noise = zeros(1, number_of_points);
                end
                noise = noise * noise_sko;

                for i = 1:number_of_points
                    x_calculated = (2 * T * periods_number * (i / number_of_points));
                    % Fill Y array by selected signal type
                    if (app.SignalTypeDropDown.Value == "Harmonic (Sinusoidal)")
                        y(i) = sin(x_calculated);
                    elseif (app.SignalTypeDropDown.Value == "Sawtooth")
                        y(i) = sawtooth(x_calculated);
                    elseif (app.SignalTypeDropDown.Value == "Triangular")
                        y(i) = sawtooth(x_calculated, 0.5);
                    elseif (app.SignalTypeDropDown.Value == "Rectangular Pulses")
                        y(i) = square(x_calculated);
                    elseif (app.SignalTypeDropDown.Value == "f(x) = abs(sin(x))")
                        y(i) = abs(sin(x_calculated));
                    elseif (app.SignalTypeDropDown.Value == "Bell-shaped")
                        y(i) = exp(-0.0003 * (x_calculated - 200) ^ 2.0);
                    end
                    y(i) = y(i) * signal_amplitude;
                    y_without_noise(i) = y(i) * signal_amplitude;
                    y(i) = y(i) + noise(i);
                end

                % Accumulate results
                y_accumulated = y_accumulated + y;
                y_accumulated_without_noise = y_accumulated_without_noise + y_without_noise;
            end

            % Normalize the accumulated results
            y_accumulated = y_accumulated / number_of_accumulations;
            % ----------------------------------------

            % ----------------------------------------
            % Изначальный сигнал: Рисуем график
            % ----------------------------------------
            plot(app.UIAxesSignals_1, x, y_accumulated, 'r');
            plot(app.UIAxesSignals_2, x, y_accumulated, 'r');
            plot(app.UIAxesSignals_3, x, y_accumulated, 'r');
            % ----------------------------------------
            % ========================================

            % ========================================
            % Лабораторная работа 2
            % ========================================
            % ----------------------------------------
            % Действительный ряд Фурье: Высчитываем
            % ----------------------------------------
            Sa0 = sum(y_accumulated) / number_of_points;

            Sa = zeros(1, K);
            Sb = zeros(1, K);
            for i = 1:number_of_points
                for j = 1:K
                    Sa_temp = y_accumulated(i) * cos((j) * 2 * T * (i - 1 - number_of_points / 2) / number_of_points);
                    Sb_temp = y_accumulated(i) * sin((j) * 2 * T * (i - 1 - number_of_points / 2) / number_of_points);
                    Sa(j) = Sa(j) + Sa_temp;
                    Sb(j) = Sb(j) + Sb_temp;
                end
            end
            
            for j = 1:K
                Sa(j) = Sa(j) * 2 / number_of_points;
                Sb(j) = Sb(j) * 2 / number_of_points;
            end

            % Для расчётного задания №1
            app.LogsTextArea_2.Value = "n = " + K + "; " + "A0 = " + Sa0 * 2 + "; " + "An = " + Sa(K) + "; " + "Bn = " + Sb(K) + "; ";

            y_fourier = zeros(1, number_of_points);
            for i = 1:number_of_points
                for j = 1:K
                    y_fourier(i) = y_fourier(i) + Sa(j) * cos(j * 2 * T * (i - 1 - number_of_points / 2) / number_of_points) + Sb(j) * sin(j * 2 * T * (i - 1 - number_of_points / 2) / number_of_points);
                end
                  y_fourier(i) = Sa0 + y_fourier(i);
            end
            % ----------------------------------------

            % ----------------------------------------
            % Действительный ряд Фурье: Рисуем график в той же фигуре
            % ----------------------------------------
            hold(app.UIAxesSignals_2, 'on');
            plot(app.UIAxesSignals_2, x, y_fourier, 'b');
            hold(app.UIAxesSignals_2, 'off');
            % ----------------------------------------
            
            % ----------------------------------------
            % Действительный ряд Фурье: Находим СКО
            % ----------------------------------------
            % Абсолютная погрешность восстановления  
            y_fourier_deviation = zeros(1, number_of_points);
            for i = 1:number_of_points
                y_fourier_deviation(i) = y_fourier(i) - y_accumulated(i);
            end
            y_fourier_deviation_in_percents = y_fourier_deviation / (max(y_accumulated) - min(y_accumulated)) * 100;

            % СКО в процентах
            SKO_in_percents = std(y_fourier_deviation_in_percents);
            % ----------------------------------------
            
            % ----------------------------------------
            % Комплексный ряд Фурье: Высчитываем
            % ----------------------------------------
            C0 = sum(y_accumulated) * 2 / number_of_points;
            C = zeros(1, K);
            for i = 1:number_of_points
                for k = 1:K
                    C(k) = C(k) + y_accumulated(i) * exp(-1j * 2 * pi * k * (i - 1) / number_of_points);
                end
            end
            for k = 1:K
                C(k) = C(k) * (2 / number_of_points);
            end

            y_fourier_complex = zeros(1, number_of_points);
            for i = 1:number_of_points
                for k = 1:K
                    y_fourier_complex(i) = y_fourier_complex(i) + C(k) * exp(1j * 2 * pi * k * (i - 1) / number_of_points);
                end
                y_fourier_complex(i) = C0 / 2 + y_fourier_complex(i);
            end
            y_fourier_complex = real(y_fourier_complex);

            % ----------------------------------------
            % Комплексный ряд Фурье: Рисуем график в той же фигуре
            % ----------------------------------------
            hold(app.UIAxesSignals_2, 'on');
            plot(app.UIAxesSignals_2, x, y_fourier_complex, 'm');
            hold(app.UIAxesSignals_2, 'off');
            % ----------------------------------------
            
            % ----------------------------------------
            % Комплексный ряд Фурье: Находим СКО
            % ----------------------------------------
            % Абсолютная погрешность восстановления  
            y_fourier_complex_deviation = zeros(1, number_of_points);
            for i = 1:number_of_points
              y_fourier_complex_deviation(i) = real(y_fourier_complex(i)) - y_accumulated(i);
            end
            y_fourier_complex_deviation_in_percents = y_fourier_complex_deviation / (max(y_accumulated) - min(y_accumulated)) * 100;
            
            % СКО в процентах
            SKO_complex_in_percents = std(y_fourier_complex_deviation_in_percents);
            % ----------------------------------------

            % ----------------------------------------
            % Обновляем график зависимости погрешности от K
            % ----------------------------------------
            % Add new row to the table
            app.FourierData = [app.FourierData; K SKO_in_percents SKO_complex_in_percents];

            % Sort values to make sure they are ascending
            app.FourierData = sortrows(app.FourierData);

            % Filter rows with same first column (K)
            [~,ia,~] = unique(app.FourierData(:,1), 'rows');
            app.FourierData = app.FourierData(ia,:);

            % Redraw table chart
            app.UpdateTableChartFourier();
            % ----------------------------------------
            % ========================================

            % ========================================
            % Лабораторная работа 3
            % ========================================
            N = number_of_points;
            Q = noise_sko;
            s = y_accumulated_without_noise;
            q = noise;
            x = y_accumulated;

            % ----------------------------------------
            % Фильтр Колмогорова-Винера
            % ----------------------------------------
            % БПФ сигнала без шума
            Y = fft(s, N) / N; 
            % Спектр мощности сигнала без шума
            SS1 = Y .* conj(Y) / N; 
            
            % БПФ  шума
            Y1 = fft(q, N) / N; 
            % Спектр мощности  шума
            SS2 = Y1 .* conj(Y1) / N; 

            % Частотная характеристика оптимального фильтра
            H = zeros(1, N);
            for i = 1:N    
                H(i) = SS1(i) / (SS1(i) + SS2(i));
            end
            
            % Частотный спектр сигнала с шумом
            XX1 = fft(x, N); 
            
            % Свертка зашумленного сигнала с частотной хар-кой фильтра 
            Z = ifft(XX1 .* H);

            % Вычисляем СКО
            i = 1:N;
            DZ(i) = Z(i) - s(i);
            DZ1 = DZ * 100 / (max(s) - min(s));
            SKO_KolVin = std(DZ1);

            % Сигнал после свертки с част. хар-кой опт. фильтра: Рисуем график в той же фигуре
            hold(app.UIAxesSignals_3, 'on');
            plot(app.UIAxesSignals_3, i, Z(1:N), 'b');
            hold(app.UIAxesSignals_3, 'off');
            % ----------------------------------------

            % ----------------------------------------
            % Обновляем график зависимости погрешности от K
            % ----------------------------------------
            % Add new row to the table
            app.FiltersData = [app.FiltersData; Q SKO_KolVin SKO_KolVin];

            % Sort values to make sure they are ascending
            app.FiltersData = sortrows(app.FiltersData);

            % Filter rows with same first column (K)
            [~,ia,~] = unique(app.FiltersData(:,1), 'rows');
            app.FiltersData = app.FiltersData(ia,:);

            % Redraw table chart
            app.UpdateTableChartFilters();
            % ----------------------------------------
            % ========================================
        end

        % Value changed function: NoiseTypeDropDown
        function NoiseTypeDropDownValueChanged(app, event)
            if (app.NoiseTypeDropDown.Value == "None")
                app.NoiseSKOLabel.Enable = "off";
                app.NoiseSKOEditField.Enable = "off";
            else
                app.NoiseSKOLabel.Enable = "on";
                app.NoiseSKOEditField.Enable = "on";
            end
            app.ClearTableFourier();
            app.ClearTableFilters();
        end

        % Value changed function: NumberOfPointsNEditField
        function NumberOfPointsNEditFieldValueChanged(app, event)
            app.UpdateMaxLimit();
            app.ClearTableFourier();
            app.ClearTableFilters();
        end

        % Value changed function: PeriodsNumberkpEditField
        function PeriodsNumberkpEditFieldValueChanged(app, event)
            app.UpdateMinLimit();
            app.ClearTableFourier();
            app.ClearTableFilters();
        end

        % Button pushed function: ClearTableButton_2
        function ClearTableButton_2Pushed2(app, event)
            app.ClearTableFourier();
            app.ClearTableFilters();
        end

        % Value changed function: NoiseSKOEditField
        function NoiseSKOEditFieldValueChanged(app, event)
            app.ClearTableFourier();
        end

        % Value changed function: SignalTypeDropDown
        function SignalTypeDropDownValueChanged(app, event)
            app.ClearTableFourier();
            app.ClearTableFilters();
        end

        % Value changed function: NumberOfAccumulationsEditField
        function NumberOfAccumulationsEditFieldValueChanged(app, event)
            app.ClearTableFourier();
            app.ClearTableFilters();
        end

        % Callback function
        function ClearTableButton_2Pushed(app, event)
            app.ClearTableFourier();
        end

        % Button pushed function: ClearTableButton_3
        function ClearTableButton_3Pushed(app, event)
            app.ClearTableFilters();
        end
    end

    % Component initialization
    methods (Access = private)

        % Create UIFigure and components
        function createComponents(app)

            % Create ModelSignalGeneratorUIFigure and hide until all components are created
            app.ModelSignalGeneratorUIFigure = uifigure('Visible', 'off');
            app.ModelSignalGeneratorUIFigure.Position = [100 100 1330 669];
            app.ModelSignalGeneratorUIFigure.Name = 'Model Signal Generator';

            % Create GenerateButton
            app.GenerateButton = uibutton(app.ModelSignalGeneratorUIFigure, 'push');
            app.GenerateButton.ButtonPushedFcn = createCallbackFcn(app, @GenerateButtonPushed, true);
            app.GenerateButton.BackgroundColor = [0.9137 1 0.8];
            app.GenerateButton.Position = [29 68 156 23];
            app.GenerateButton.Text = 'Generate';

            % Create PeriodsNumberLabel
            app.PeriodsNumberLabel = uilabel(app.ModelSignalGeneratorUIFigure);
            app.PeriodsNumberLabel.HorizontalAlignment = 'right';
            app.PeriodsNumberLabel.Position = [48 287 119 22];
            app.PeriodsNumberLabel.Text = 'Periods Number (kp):';

            % Create PeriodsNumberkpEditField
            app.PeriodsNumberkpEditField = uieditfield(app.ModelSignalGeneratorUIFigure, 'numeric');
            app.PeriodsNumberkpEditField.ValueDisplayFormat = '%9.1f';
            app.PeriodsNumberkpEditField.ValueChangedFcn = createCallbackFcn(app, @PeriodsNumberkpEditFieldValueChanged, true);
            app.PeriodsNumberkpEditField.HorizontalAlignment = 'center';
            app.PeriodsNumberkpEditField.Position = [29 266 155 22];
            app.PeriodsNumberkpEditField.Value = 5;

            % Create NoiseSKOLabel
            app.NoiseSKOLabel = uilabel(app.ModelSignalGeneratorUIFigure);
            app.NoiseSKOLabel.HorizontalAlignment = 'right';
            app.NoiseSKOLabel.Position = [69 350 68 22];
            app.NoiseSKOLabel.Text = 'Noise SKO:';

            % Create NoiseSKOEditField
            app.NoiseSKOEditField = uieditfield(app.ModelSignalGeneratorUIFigure, 'numeric');
            app.NoiseSKOEditField.ValueDisplayFormat = '%9.1f';
            app.NoiseSKOEditField.ValueChangedFcn = createCallbackFcn(app, @NoiseSKOEditFieldValueChanged, true);
            app.NoiseSKOEditField.HorizontalAlignment = 'center';
            app.NoiseSKOEditField.Position = [29 329 155 22];
            app.NoiseSKOEditField.Value = 0.1;

            % Create SignalAmplitudeLabel
            app.SignalAmplitudeLabel = uilabel(app.ModelSignalGeneratorUIFigure);
            app.SignalAmplitudeLabel.HorizontalAlignment = 'right';
            app.SignalAmplitudeLabel.Position = [54 475 98 22];
            app.SignalAmplitudeLabel.Text = 'Signal Amplitude:';

            % Create SignalAmplitudeEditField
            app.SignalAmplitudeEditField = uieditfield(app.ModelSignalGeneratorUIFigure, 'numeric');
            app.SignalAmplitudeEditField.ValueDisplayFormat = '%9.1f';
            app.SignalAmplitudeEditField.HorizontalAlignment = 'center';
            app.SignalAmplitudeEditField.Position = [28 454 155 22];
            app.SignalAmplitudeEditField.Value = 1;

            % Create NoiseTypeLabel
            app.NoiseTypeLabel = uilabel(app.ModelSignalGeneratorUIFigure);
            app.NoiseTypeLabel.HorizontalAlignment = 'right';
            app.NoiseTypeLabel.Position = [71 408 68 22];
            app.NoiseTypeLabel.Text = 'Noise Type:';

            % Create NoiseTypeDropDown
            app.NoiseTypeDropDown = uidropdown(app.ModelSignalGeneratorUIFigure);
            app.NoiseTypeDropDown.Items = {'None', 'Normally Distributed', 'White Gaussian Noise'};
            app.NoiseTypeDropDown.ValueChangedFcn = createCallbackFcn(app, @NoiseTypeDropDownValueChanged, true);
            app.NoiseTypeDropDown.Position = [29 387 155 22];
            app.NoiseTypeDropDown.Value = 'Normally Distributed';

            % Create NumberOfPointsLabel
            app.NumberOfPointsLabel = uilabel(app.ModelSignalGeneratorUIFigure);
            app.NumberOfPointsLabel.HorizontalAlignment = 'right';
            app.NumberOfPointsLabel.Position = [45 535 124 22];
            app.NumberOfPointsLabel.Text = 'Number Of Points (N):';

            % Create NumberOfPointsNEditField
            app.NumberOfPointsNEditField = uieditfield(app.ModelSignalGeneratorUIFigure, 'numeric');
            app.NumberOfPointsNEditField.RoundFractionalValues = 'on';
            app.NumberOfPointsNEditField.ValueDisplayFormat = '%.0f';
            app.NumberOfPointsNEditField.ValueChangedFcn = createCallbackFcn(app, @NumberOfPointsNEditFieldValueChanged, true);
            app.NumberOfPointsNEditField.HorizontalAlignment = 'center';
            app.NumberOfPointsNEditField.Position = [28 514 155 22];
            app.NumberOfPointsNEditField.Value = 1024;

            % Create SignalTypeLabel
            app.SignalTypeLabel = uilabel(app.ModelSignalGeneratorUIFigure);
            app.SignalTypeLabel.HorizontalAlignment = 'right';
            app.SignalTypeLabel.Position = [68 592 71 22];
            app.SignalTypeLabel.Text = 'Signal Type:';

            % Create ModelSignalGeneratorLabel
            app.ModelSignalGeneratorLabel = uilabel(app.ModelSignalGeneratorUIFigure);
            app.ModelSignalGeneratorLabel.HorizontalAlignment = 'center';
            app.ModelSignalGeneratorLabel.FontSize = 24;
            app.ModelSignalGeneratorLabel.Position = [2 627 1274 31];
            app.ModelSignalGeneratorLabel.Text = 'Model Signal Generator';

            % Create SignalTypeDropDown
            app.SignalTypeDropDown = uidropdown(app.ModelSignalGeneratorUIFigure);
            app.SignalTypeDropDown.Items = {'Harmonic (Sinusoidal)', 'Sawtooth', 'Triangular', 'Rectangular Pulses', 'f(x) = abs(sin(x))', 'Bell-shaped'};
            app.SignalTypeDropDown.ValueChangedFcn = createCallbackFcn(app, @SignalTypeDropDownValueChanged, true);
            app.SignalTypeDropDown.Position = [28 571 155 22];
            app.SignalTypeDropDown.Value = 'Harmonic (Sinusoidal)';

            % Create NumberOfAccumulationsLabel
            app.NumberOfAccumulationsLabel = uilabel(app.ModelSignalGeneratorUIFigure);
            app.NumberOfAccumulationsLabel.HorizontalAlignment = 'right';
            app.NumberOfAccumulationsLabel.Position = [32 223 148 22];
            app.NumberOfAccumulationsLabel.Text = 'Number Of Accumulations:';

            % Create NumberOfAccumulationsEditField
            app.NumberOfAccumulationsEditField = uieditfield(app.ModelSignalGeneratorUIFigure, 'numeric');
            app.NumberOfAccumulationsEditField.RoundFractionalValues = 'on';
            app.NumberOfAccumulationsEditField.ValueDisplayFormat = '%.0f';
            app.NumberOfAccumulationsEditField.ValueChangedFcn = createCallbackFcn(app, @NumberOfAccumulationsEditFieldValueChanged, true);
            app.NumberOfAccumulationsEditField.HorizontalAlignment = 'center';
            app.NumberOfAccumulationsEditField.Position = [29 202 155 22];
            app.NumberOfAccumulationsEditField.Value = 1;

            % Create ThenumberofFourierseriestermsKkpKN4Label
            app.ThenumberofFourierseriestermsKkpKN4Label = uilabel(app.ModelSignalGeneratorUIFigure);
            app.ThenumberofFourierseriestermsKkpKN4Label.HorizontalAlignment = 'center';
            app.ThenumberofFourierseriestermsKkpKN4Label.WordWrap = 'on';
            app.ThenumberofFourierseriestermsKkpKN4Label.Position = [22 151 166 30];
            app.ThenumberofFourierseriestermsKkpKN4Label.Text = 'The number of Fourier series terms (K, kp <= K <= N/4):';

            % Create TheNumberOfFourierSeriesTermsEditField
            app.TheNumberOfFourierSeriesTermsEditField = uieditfield(app.ModelSignalGeneratorUIFigure, 'numeric');
            app.TheNumberOfFourierSeriesTermsEditField.RoundFractionalValues = 'on';
            app.TheNumberOfFourierSeriesTermsEditField.ValueDisplayFormat = '%.0f';
            app.TheNumberOfFourierSeriesTermsEditField.HorizontalAlignment = 'center';
            app.TheNumberOfFourierSeriesTermsEditField.Position = [73 127 66 22];
            app.TheNumberOfFourierSeriesTermsEditField.Value = 1;

            % Create TheNumberOfFourierSeriesTermsEditFieldLabelKMin
            app.TheNumberOfFourierSeriesTermsEditFieldLabelKMin = uilabel(app.ModelSignalGeneratorUIFigure);
            app.TheNumberOfFourierSeriesTermsEditFieldLabelKMin.HorizontalAlignment = 'right';
            app.TheNumberOfFourierSeriesTermsEditFieldLabelKMin.WordWrap = 'on';
            app.TheNumberOfFourierSeriesTermsEditFieldLabelKMin.Position = [21 127 46 22];
            app.TheNumberOfFourierSeriesTermsEditFieldLabelKMin.Text = '1 <=';

            % Create TheNumberOfFourierSeriesTermsEditFieldLabelKMax
            app.TheNumberOfFourierSeriesTermsEditFieldLabelKMax = uilabel(app.ModelSignalGeneratorUIFigure);
            app.TheNumberOfFourierSeriesTermsEditFieldLabelKMax.WordWrap = 'on';
            app.TheNumberOfFourierSeriesTermsEditFieldLabelKMax.Position = [143 128 59 22];
            app.TheNumberOfFourierSeriesTermsEditFieldLabelKMax.Text = '<= 256';

            % Create TabGroup
            app.TabGroup = uitabgroup(app.ModelSignalGeneratorUIFigure);
            app.TabGroup.Position = [202 14 1103 600];

            % Create Lab1SignalTab
            app.Lab1SignalTab = uitab(app.TabGroup);
            app.Lab1SignalTab.Title = 'Lab 1: Signal';

            % Create UIAxesSignals_1
            app.UIAxesSignals_1 = uiaxes(app.Lab1SignalTab);
            xlabel(app.UIAxesSignals_1, 'N')
            ylabel(app.UIAxesSignals_1, 'S')
            zlabel(app.UIAxesSignals_1, 'Z')
            app.UIAxesSignals_1.Box = 'on';
            app.UIAxesSignals_1.XGrid = 'on';
            app.UIAxesSignals_1.YGrid = 'on';
            app.UIAxesSignals_1.Position = [28 22 1046 479];

            % Create SignalLabel_1
            app.SignalLabel_1 = uilabel(app.Lab1SignalTab);
            app.SignalLabel_1.BackgroundColor = [1 1 1];
            app.SignalLabel_1.FontColor = [1 0 0];
            app.SignalLabel_1.Position = [545 529 38 22];
            app.SignalLabel_1.Text = 'Signal';

            % Create Lab2FourierTab
            app.Lab2FourierTab = uitab(app.TabGroup);
            app.Lab2FourierTab.Title = 'Lab 2: Fourier';

            % Create UIAxesSignals_2
            app.UIAxesSignals_2 = uiaxes(app.Lab2FourierTab);
            xlabel(app.UIAxesSignals_2, 'N')
            ylabel(app.UIAxesSignals_2, 'S')
            zlabel(app.UIAxesSignals_2, 'Z')
            app.UIAxesSignals_2.Box = 'on';
            app.UIAxesSignals_2.XGrid = 'on';
            app.UIAxesSignals_2.YGrid = 'on';
            app.UIAxesSignals_2.Position = [8 22 410 515];

            % Create UIAxesSKO_2
            app.UIAxesSKO_2 = uiaxes(app.Lab2FourierTab);
            xlabel(app.UIAxesSKO_2, 'K')
            ylabel(app.UIAxesSKO_2, 'SKO')
            zlabel(app.UIAxesSKO_2, 'Z')
            app.UIAxesSKO_2.Box = 'on';
            app.UIAxesSKO_2.XGrid = 'on';
            app.UIAxesSKO_2.YGrid = 'on';
            app.UIAxesSKO_2.Position = [432 22 420 248];

            % Create SignalLabel_2
            app.SignalLabel_2 = uilabel(app.Lab2FourierTab);
            app.SignalLabel_2.BackgroundColor = [1 1 1];
            app.SignalLabel_2.FontColor = [1 0 0];
            app.SignalLabel_2.Position = [95 545 38 22];
            app.SignalLabel_2.Text = 'Signal';

            % Create FourierLabel_2
            app.FourierLabel_2 = uilabel(app.Lab2FourierTab);
            app.FourierLabel_2.BackgroundColor = [1 1 1];
            app.FourierLabel_2.FontColor = [0 0 1];
            app.FourierLabel_2.Position = [188 545 43 22];
            app.FourierLabel_2.Text = 'Fourier';

            % Create FouriercomplexLabel_2
            app.FouriercomplexLabel_2 = uilabel(app.Lab2FourierTab);
            app.FouriercomplexLabel_2.BackgroundColor = [1 1 1];
            app.FouriercomplexLabel_2.FontColor = [1 0 1];
            app.FouriercomplexLabel_2.Position = [276 545 99 22];
            app.FouriercomplexLabel_2.Text = 'Fourier (complex)';

            % Create UITableSKO_2
            app.UITableSKO_2 = uitable(app.Lab2FourierTab);
            app.UITableSKO_2.ColumnName = {'K'; 'SKO'; 'SKO_Complex'};
            app.UITableSKO_2.RowName = {};
            app.UITableSKO_2.Position = [468 329 376 201];

            % Create ClearTableButton_2
            app.ClearTableButton_2 = uibutton(app.Lab2FourierTab, 'push');
            app.ClearTableButton_2.ButtonPushedFcn = createCallbackFcn(app, @ClearTableButton_2Pushed2, true);
            app.ClearTableButton_2.BackgroundColor = [1 0.9059 0.6784];
            app.ClearTableButton_2.Position = [468 309 376 23];
            app.ClearTableButton_2.Text = 'Clear table';

            % Create FourierSKOLabel_2
            app.FourierSKOLabel_2 = uilabel(app.Lab2FourierTab);
            app.FourierSKOLabel_2.BackgroundColor = [1 1 1];
            app.FourierSKOLabel_2.FontColor = [0 0 1];
            app.FourierSKOLabel_2.Position = [563 273 72 22];
            app.FourierSKOLabel_2.Text = 'Fourier SKO';

            % Create FouriercomplexSKOLabel_2
            app.FouriercomplexSKOLabel_2 = uilabel(app.Lab2FourierTab);
            app.FouriercomplexSKOLabel_2.BackgroundColor = [1 1 1];
            app.FouriercomplexSKOLabel_2.FontColor = [1 0 1];
            app.FouriercomplexSKOLabel_2.Position = [651 273 128 22];
            app.FouriercomplexSKOLabel_2.Text = 'Fourier (complex) SKO';

            % Create LogsTextAreaLabel
            app.LogsTextAreaLabel = uilabel(app.Lab2FourierTab);
            app.LogsTextAreaLabel.HorizontalAlignment = 'right';
            app.LogsTextAreaLabel.Position = [963 536 31 22];
            app.LogsTextAreaLabel.Text = 'Logs';

            % Create LogsTextArea_2
            app.LogsTextArea_2 = uitextarea(app.Lab2FourierTab);
            app.LogsTextArea_2.Position = [872 55 211 475];

            % Create Lab3FiltersTab
            app.Lab3FiltersTab = uitab(app.TabGroup);
            app.Lab3FiltersTab.Title = 'Lab 3: Filters';

            % Create UIAxesSignals_3
            app.UIAxesSignals_3 = uiaxes(app.Lab3FiltersTab);
            xlabel(app.UIAxesSignals_3, 'N')
            ylabel(app.UIAxesSignals_3, 'S')
            zlabel(app.UIAxesSignals_3, 'Z')
            app.UIAxesSignals_3.Box = 'on';
            app.UIAxesSignals_3.XGrid = 'on';
            app.UIAxesSignals_3.YGrid = 'on';
            app.UIAxesSignals_3.Position = [8 22 410 515];

            % Create UIAxesSKO_3
            app.UIAxesSKO_3 = uiaxes(app.Lab3FiltersTab);
            xlabel(app.UIAxesSKO_3, 'K')
            ylabel(app.UIAxesSKO_3, 'SKO')
            zlabel(app.UIAxesSKO_3, 'Z')
            app.UIAxesSKO_3.Box = 'on';
            app.UIAxesSKO_3.XGrid = 'on';
            app.UIAxesSKO_3.YGrid = 'on';
            app.UIAxesSKO_3.Position = [432 22 420 248];

            % Create SignalLabel_3
            app.SignalLabel_3 = uilabel(app.Lab3FiltersTab);
            app.SignalLabel_3.BackgroundColor = [1 1 1];
            app.SignalLabel_3.FontColor = [1 0 0];
            app.SignalLabel_3.Position = [95 545 38 22];
            app.SignalLabel_3.Text = 'Signal';

            % Create FourierLabel_3
            app.FourierLabel_3 = uilabel(app.Lab3FiltersTab);
            app.FourierLabel_3.BackgroundColor = [1 1 1];
            app.FourierLabel_3.FontColor = [0 0 1];
            app.FourierLabel_3.Position = [188 545 43 22];
            app.FourierLabel_3.Text = 'Fourier';

            % Create FouriercomplexLabel_3
            app.FouriercomplexLabel_3 = uilabel(app.Lab3FiltersTab);
            app.FouriercomplexLabel_3.BackgroundColor = [1 1 1];
            app.FouriercomplexLabel_3.FontColor = [1 0 1];
            app.FouriercomplexLabel_3.Position = [276 545 99 22];
            app.FouriercomplexLabel_3.Text = 'Fourier (complex)';

            % Create UITableSKO_3
            app.UITableSKO_3 = uitable(app.Lab3FiltersTab);
            app.UITableSKO_3.ColumnName = {'Q'; 'SKO_KolVin'; 'SKO_Median'};
            app.UITableSKO_3.RowName = {};
            app.UITableSKO_3.Position = [468 329 376 201];

            % Create ClearTableButton_3
            app.ClearTableButton_3 = uibutton(app.Lab3FiltersTab, 'push');
            app.ClearTableButton_3.ButtonPushedFcn = createCallbackFcn(app, @ClearTableButton_3Pushed, true);
            app.ClearTableButton_3.BackgroundColor = [1 0.9059 0.6784];
            app.ClearTableButton_3.Position = [468 309 376 23];
            app.ClearTableButton_3.Text = 'Clear table';

            % Create FourierSKOLabel_3
            app.FourierSKOLabel_3 = uilabel(app.Lab3FiltersTab);
            app.FourierSKOLabel_3.BackgroundColor = [1 1 1];
            app.FourierSKOLabel_3.FontColor = [0 0 1];
            app.FourierSKOLabel_3.Position = [563 273 72 22];
            app.FourierSKOLabel_3.Text = 'Fourier SKO';

            % Create FouriercomplexSKOLabel_3
            app.FouriercomplexSKOLabel_3 = uilabel(app.Lab3FiltersTab);
            app.FouriercomplexSKOLabel_3.BackgroundColor = [1 1 1];
            app.FouriercomplexSKOLabel_3.FontColor = [1 0 1];
            app.FouriercomplexSKOLabel_3.Position = [651 273 128 22];
            app.FouriercomplexSKOLabel_3.Text = 'Fourier (complex) SKO';

            % Create LogsTextArea_3Label
            app.LogsTextArea_3Label = uilabel(app.Lab3FiltersTab);
            app.LogsTextArea_3Label.HorizontalAlignment = 'right';
            app.LogsTextArea_3Label.Position = [963 536 31 22];
            app.LogsTextArea_3Label.Text = 'Logs';

            % Create LogsTextArea_3
            app.LogsTextArea_3 = uitextarea(app.Lab3FiltersTab);
            app.LogsTextArea_3.Position = [872 55 211 475];

            % Show the figure after all components are created
            app.ModelSignalGeneratorUIFigure.Visible = 'on';
        end
    end

    % App creation and deletion
    methods (Access = public)

        % Construct app
        function app = application

            % Create UIFigure and components
            createComponents(app)

            % Register the app with App Designer
            registerApp(app, app.ModelSignalGeneratorUIFigure)

            % Execute the startup function
            runStartupFcn(app, @startupFcn)

            if nargout == 0
                clear app
            end
        end

        % Code that executes before app deletion
        function delete(app)

            % Delete UIFigure when app is deleted
            delete(app.ModelSignalGeneratorUIFigure)
        end
    end
end
