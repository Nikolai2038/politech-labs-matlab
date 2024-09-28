
classdef application < matlab.apps.AppBase

    % Properties that correspond to app components
    properties (Access = public)
        ModelSignalGeneratorUIFigure    matlab.ui.Figure
        LogsTextArea                    matlab.ui.control.TextArea
        LogsTextAreaLabel               matlab.ui.control.Label
        FouriercomplexSKOLabel          matlab.ui.control.Label
        FourierSKOLabel                 matlab.ui.control.Label
        ClearTableButton                matlab.ui.control.Button
        UITableSKO                      matlab.ui.control.Table
        FouriercomplexLabel             matlab.ui.control.Label
        FourierLabel                    matlab.ui.control.Label
        SignalLabel                     matlab.ui.control.Label
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
        UIAxesSKO                       matlab.ui.control.UIAxes
        UIAxesSignals                   matlab.ui.control.UIAxes
    end

    
    properties (Access = private)
        FourierData
    end
    
    methods (Access = private)
        function UpdateTableChart(app)
            if (isempty(app.FourierData))
                % Empty the data
                app.UITableSKO.Data = [];

                % Clear chart
                cla(app.UIAxesSKO);
            % For interpolation, we need at least 2 different points
            else
                % Load data from variable
                app.UITableSKO.Data = array2table(app.FourierData,'VariableNames',{'K','SKO','SKO_Complex'});
                
                if (size(app.FourierData, 1) >= 2)
                    x = app.UITableSKO.Data.K;
                    y_simple = app.UITableSKO.Data.SKO;
                    y_complex = app.UITableSKO.Data.SKO_Complex;
    
                    % Create 100 more points for interpolation
                    x_interpolated = linspace(min(x), max(x), 100);
                    
                    % Apply interpolation
                    y_simple_interpolated = interp1(x, y_simple, x_interpolated, 'pchip');
                    % Draw chart 1 with soft line and points
                    plot(app.UIAxesSKO, x_interpolated, y_simple_interpolated, 'b-', x, y_simple, 'bo');
                    
                    % Apply interpolation
                    y_complex_interpolated = interp1(x, y_complex, x_interpolated, 'pchip');
                    % Draw chart 2 with soft line and points
                    hold(app.UIAxesSKO, 'on');
                    plot(app.UIAxesSKO, x_interpolated, y_complex_interpolated, 'm-', x, y_complex, 'mo');
                    hold(app.UIAxesSKO, 'off');
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
        
        function ClearTable(app)
            app.FourierData = [];
            app.UpdateTableChart();
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
            signal_aplitude = app.SignalAmplitudeEditField.Value;
            number_of_accumulations = app.NumberOfAccumulationsEditField.Value;

            % Create X array
            x = 1:number_of_points;

            % Create Y array
            y_accumulated = zeros(1, number_of_points);

            T = pi;
 
            % ----------------------------------------
            % Изначальный сигнал: Высчитываем
            % ----------------------------------------
            for iteration = 1:number_of_accumulations
                % Create Y array
                y = zeros(1, number_of_points);

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
                    x_calculated = (2 * T * (((i - 1-number_of_points/2)) / number_of_points));
                    % Fill Y array by selected signal type
                    if (app.SignalTypeDropDown.Value == "Harmonic (Sinusoidal)")
                        y(i) = sin(x_calculated * periods_number);
                    elseif (app.SignalTypeDropDown.Value == "Sawtooth")
                        y(i) = sawtooth(x_calculated);
                    elseif (app.SignalTypeDropDown.Value == "Triangular")
                        y(i) = sawtooth(x_calculated, 0.5);
                    elseif (app.SignalTypeDropDown.Value == "Rectangular Pulses")
                        y(i) = square(x_calculated);
                    elseif (app.SignalTypeDropDown.Value == "f(x) = abs(sin(x))")
                        y(i) = abs(sin(x_calculated));
                    end
                    y(i) = y(i) * signal_aplitude;
                    y(i) = y(i) + noise(i);
                end

                % Accumulate results
                y_accumulated = y_accumulated + y;
            end

            % Normalize the accumulated results
            y_accumulated = y_accumulated / number_of_accumulations;
            % ----------------------------------------

            % ----------------------------------------
            % Изначальный сигнал: Рисуем график
            % ----------------------------------------
            plot(app.UIAxesSignals, x, y_accumulated, 'r');
            % ----------------------------------------

            % ----------------------------------------
            % Действительный ряд Фурье: Высчитываем
            % ----------------------------------------
            Sa0 = sum(y_accumulated) / number_of_points;

            Sa = zeros(1,K);
            Sb = zeros(1,K);
            for i = 1:number_of_points
                for j = 1:K
                    Sa_temp = y_accumulated(i) * cos((j) * 2 * T * (i - 1 - number_of_points / 2) / number_of_points);
                    Sb_temp = y_accumulated(i) * sin((j) * 2 * T * (i - 1 - number_of_points / 2) / number_of_points);
                    Sa(j) = Sa(j) + Sa_temp;
                    Sb(j) = Sb(j) + Sb_temp;
                end
            end

            % Для расчётного задания №1
            app.LogsTextArea.Value = "n = " + K + "; " + "A0 = " + Sa0 + "; " + "An = " + Sa(K) + "; " + "Bn = " + Sb(K) + "; ";

            for j = 1:K
                Sa(j) = Sa(j) * 2 / number_of_points;
                Sb(j) = Sb(j) * 2 / number_of_points;
            end

            y_fourier = zeros(1,number_of_points);
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
            hold(app.UIAxesSignals, 'on');
            plot(app.UIAxesSignals, x, y_fourier, 'b');
            hold(app.UIAxesSignals, 'off');
            % ----------------------------------------
            
            % ----------------------------------------
            % Действительный ряд Фурье: Находим СКО
            % ----------------------------------------
            % Абсолютная погрешность восстановления  
            y_fourier_deviation = zeros(1,number_of_points);
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
            C = zeros(1,K);
            for i = 1:number_of_points
                for k = 1:K
                    C(k) = C(k) + y_accumulated(i) * exp(-1j * 2 * pi * k * (i - 1) / number_of_points);
                end
            end
            for k = 1:K
                C(k) = C(k) * (2 / number_of_points);
            end

            y_fourier_complex = zeros(1,number_of_points);
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
            hold(app.UIAxesSignals, 'on');
            plot(app.UIAxesSignals, x, y_fourier_complex, 'm');
            hold(app.UIAxesSignals, 'off');
            % ----------------------------------------
            
            % ----------------------------------------
            % Комплексный ряд Фурье: Находим СКО
            % ----------------------------------------
            % Абсолютная погрешность восстановления  
            y_fourier_complex_deviation = zeros(1,number_of_points);
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
            app.UpdateTableChart();
            % ----------------------------------------
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
            ClearTable(app);
        end

        % Value changed function: NumberOfPointsNEditField
        function NumberOfPointsNEditFieldValueChanged(app, event)
            app.UpdateMaxLimit();
            ClearTable(app);
        end

        % Value changed function: PeriodsNumberkpEditField
        function PeriodsNumberkpEditFieldValueChanged(app, event)
            app.UpdateMinLimit();
            ClearTable(app);
        end

        % Button pushed function: ClearTableButton
        function ClearTableButtonPushed(app, event)
            ClearTable(app);
        end

        % Value changed function: NoiseSKOEditField
        function NoiseSKOEditFieldValueChanged(app, event)
            ClearTable(app);
        end

        % Value changed function: SignalTypeDropDown
        function SignalTypeDropDownValueChanged(app, event)
            ClearTable(app);
        end

        % Value changed function: NumberOfAccumulationsEditField
        function NumberOfAccumulationsEditFieldValueChanged(app, event)
            ClearTable(app);
        end

        % Callback function
        function ClearTableButton_2Pushed(app, event)
            ClearTable(app);
        end
    end

    % Component initialization
    methods (Access = private)

        % Create UIFigure and components
        function createComponents(app)

            % Create ModelSignalGeneratorUIFigure and hide until all components are created
            app.ModelSignalGeneratorUIFigure = uifigure('Visible', 'off');
            app.ModelSignalGeneratorUIFigure.Position = [100 100 1299 629];
            app.ModelSignalGeneratorUIFigure.Name = 'Model Signal Generator';

            % Create UIAxesSignals
            app.UIAxesSignals = uiaxes(app.ModelSignalGeneratorUIFigure);
            xlabel(app.UIAxesSignals, 'N')
            ylabel(app.UIAxesSignals, 'S')
            zlabel(app.UIAxesSignals, 'Z')
            app.UIAxesSignals.Box = 'on';
            app.UIAxesSignals.XGrid = 'on';
            app.UIAxesSignals.YGrid = 'on';
            app.UIAxesSignals.Position = [201 28 410 515];

            % Create UIAxesSKO
            app.UIAxesSKO = uiaxes(app.ModelSignalGeneratorUIFigure);
            xlabel(app.UIAxesSKO, 'K')
            ylabel(app.UIAxesSKO, 'SKO')
            zlabel(app.UIAxesSKO, 'Z')
            app.UIAxesSKO.Box = 'on';
            app.UIAxesSKO.XGrid = 'on';
            app.UIAxesSKO.YGrid = 'on';
            app.UIAxesSKO.Position = [625 28 420 248];

            % Create GenerateButton
            app.GenerateButton = uibutton(app.ModelSignalGeneratorUIFigure, 'push');
            app.GenerateButton.ButtonPushedFcn = createCallbackFcn(app, @GenerateButtonPushed, true);
            app.GenerateButton.BackgroundColor = [0.9137 1 0.8];
            app.GenerateButton.Position = [29 28 156 23];
            app.GenerateButton.Text = 'Generate';

            % Create PeriodsNumberLabel
            app.PeriodsNumberLabel = uilabel(app.ModelSignalGeneratorUIFigure);
            app.PeriodsNumberLabel.HorizontalAlignment = 'right';
            app.PeriodsNumberLabel.Position = [48 247 119 22];
            app.PeriodsNumberLabel.Text = 'Periods Number (kp):';

            % Create PeriodsNumberkpEditField
            app.PeriodsNumberkpEditField = uieditfield(app.ModelSignalGeneratorUIFigure, 'numeric');
            app.PeriodsNumberkpEditField.ValueDisplayFormat = '%9.1f';
            app.PeriodsNumberkpEditField.ValueChangedFcn = createCallbackFcn(app, @PeriodsNumberkpEditFieldValueChanged, true);
            app.PeriodsNumberkpEditField.HorizontalAlignment = 'center';
            app.PeriodsNumberkpEditField.Position = [29 226 155 22];
            app.PeriodsNumberkpEditField.Value = 4.5;

            % Create NoiseSKOLabel
            app.NoiseSKOLabel = uilabel(app.ModelSignalGeneratorUIFigure);
            app.NoiseSKOLabel.HorizontalAlignment = 'right';
            app.NoiseSKOLabel.Enable = 'off';
            app.NoiseSKOLabel.Position = [69 310 68 22];
            app.NoiseSKOLabel.Text = 'Noise SKO:';

            % Create NoiseSKOEditField
            app.NoiseSKOEditField = uieditfield(app.ModelSignalGeneratorUIFigure, 'numeric');
            app.NoiseSKOEditField.ValueDisplayFormat = '%9.1f';
            app.NoiseSKOEditField.ValueChangedFcn = createCallbackFcn(app, @NoiseSKOEditFieldValueChanged, true);
            app.NoiseSKOEditField.HorizontalAlignment = 'center';
            app.NoiseSKOEditField.Enable = 'off';
            app.NoiseSKOEditField.Position = [29 289 155 22];
            app.NoiseSKOEditField.Value = 0.1;

            % Create SignalAmplitudeLabel
            app.SignalAmplitudeLabel = uilabel(app.ModelSignalGeneratorUIFigure);
            app.SignalAmplitudeLabel.HorizontalAlignment = 'right';
            app.SignalAmplitudeLabel.Position = [54 435 98 22];
            app.SignalAmplitudeLabel.Text = 'Signal Amplitude:';

            % Create SignalAmplitudeEditField
            app.SignalAmplitudeEditField = uieditfield(app.ModelSignalGeneratorUIFigure, 'numeric');
            app.SignalAmplitudeEditField.ValueDisplayFormat = '%9.1f';
            app.SignalAmplitudeEditField.HorizontalAlignment = 'center';
            app.SignalAmplitudeEditField.Position = [28 414 155 22];
            app.SignalAmplitudeEditField.Value = 1;

            % Create NoiseTypeLabel
            app.NoiseTypeLabel = uilabel(app.ModelSignalGeneratorUIFigure);
            app.NoiseTypeLabel.HorizontalAlignment = 'right';
            app.NoiseTypeLabel.Position = [71 368 68 22];
            app.NoiseTypeLabel.Text = 'Noise Type:';

            % Create NoiseTypeDropDown
            app.NoiseTypeDropDown = uidropdown(app.ModelSignalGeneratorUIFigure);
            app.NoiseTypeDropDown.Items = {'None', 'Normally Distributed', 'White Gaussian Noise'};
            app.NoiseTypeDropDown.ValueChangedFcn = createCallbackFcn(app, @NoiseTypeDropDownValueChanged, true);
            app.NoiseTypeDropDown.Position = [29 347 155 22];
            app.NoiseTypeDropDown.Value = 'None';

            % Create NumberOfPointsLabel
            app.NumberOfPointsLabel = uilabel(app.ModelSignalGeneratorUIFigure);
            app.NumberOfPointsLabel.HorizontalAlignment = 'right';
            app.NumberOfPointsLabel.Position = [45 495 124 22];
            app.NumberOfPointsLabel.Text = 'Number Of Points (N):';

            % Create NumberOfPointsNEditField
            app.NumberOfPointsNEditField = uieditfield(app.ModelSignalGeneratorUIFigure, 'numeric');
            app.NumberOfPointsNEditField.RoundFractionalValues = 'on';
            app.NumberOfPointsNEditField.ValueDisplayFormat = '%.0f';
            app.NumberOfPointsNEditField.ValueChangedFcn = createCallbackFcn(app, @NumberOfPointsNEditFieldValueChanged, true);
            app.NumberOfPointsNEditField.HorizontalAlignment = 'center';
            app.NumberOfPointsNEditField.Position = [28 474 155 22];
            app.NumberOfPointsNEditField.Value = 1024;

            % Create SignalTypeLabel
            app.SignalTypeLabel = uilabel(app.ModelSignalGeneratorUIFigure);
            app.SignalTypeLabel.HorizontalAlignment = 'right';
            app.SignalTypeLabel.Position = [68 552 71 22];
            app.SignalTypeLabel.Text = 'Signal Type:';

            % Create ModelSignalGeneratorLabel
            app.ModelSignalGeneratorLabel = uilabel(app.ModelSignalGeneratorUIFigure);
            app.ModelSignalGeneratorLabel.HorizontalAlignment = 'center';
            app.ModelSignalGeneratorLabel.FontSize = 24;
            app.ModelSignalGeneratorLabel.Position = [2 587 1056 31];
            app.ModelSignalGeneratorLabel.Text = 'Model Signal Generator';

            % Create SignalTypeDropDown
            app.SignalTypeDropDown = uidropdown(app.ModelSignalGeneratorUIFigure);
            app.SignalTypeDropDown.Items = {'Harmonic (Sinusoidal)', 'Sawtooth', 'Triangular', 'Rectangular Pulses', 'f(x) = abs(sin(x))'};
            app.SignalTypeDropDown.ValueChangedFcn = createCallbackFcn(app, @SignalTypeDropDownValueChanged, true);
            app.SignalTypeDropDown.Position = [28 531 155 22];
            app.SignalTypeDropDown.Value = 'Harmonic (Sinusoidal)';

            % Create NumberOfAccumulationsLabel
            app.NumberOfAccumulationsLabel = uilabel(app.ModelSignalGeneratorUIFigure);
            app.NumberOfAccumulationsLabel.HorizontalAlignment = 'right';
            app.NumberOfAccumulationsLabel.Position = [32 183 148 22];
            app.NumberOfAccumulationsLabel.Text = 'Number Of Accumulations:';

            % Create NumberOfAccumulationsEditField
            app.NumberOfAccumulationsEditField = uieditfield(app.ModelSignalGeneratorUIFigure, 'numeric');
            app.NumberOfAccumulationsEditField.RoundFractionalValues = 'on';
            app.NumberOfAccumulationsEditField.ValueDisplayFormat = '%.0f';
            app.NumberOfAccumulationsEditField.ValueChangedFcn = createCallbackFcn(app, @NumberOfAccumulationsEditFieldValueChanged, true);
            app.NumberOfAccumulationsEditField.HorizontalAlignment = 'center';
            app.NumberOfAccumulationsEditField.Position = [29 162 155 22];
            app.NumberOfAccumulationsEditField.Value = 1;

            % Create ThenumberofFourierseriestermsKkpKN4Label
            app.ThenumberofFourierseriestermsKkpKN4Label = uilabel(app.ModelSignalGeneratorUIFigure);
            app.ThenumberofFourierseriestermsKkpKN4Label.HorizontalAlignment = 'center';
            app.ThenumberofFourierseriestermsKkpKN4Label.WordWrap = 'on';
            app.ThenumberofFourierseriestermsKkpKN4Label.Position = [22 111 166 30];
            app.ThenumberofFourierseriestermsKkpKN4Label.Text = 'The number of Fourier series terms (K, kp <= K <= N/4):';

            % Create TheNumberOfFourierSeriesTermsEditField
            app.TheNumberOfFourierSeriesTermsEditField = uieditfield(app.ModelSignalGeneratorUIFigure, 'numeric');
            app.TheNumberOfFourierSeriesTermsEditField.RoundFractionalValues = 'on';
            app.TheNumberOfFourierSeriesTermsEditField.ValueDisplayFormat = '%.0f';
            app.TheNumberOfFourierSeriesTermsEditField.HorizontalAlignment = 'center';
            app.TheNumberOfFourierSeriesTermsEditField.Position = [73 87 66 22];
            app.TheNumberOfFourierSeriesTermsEditField.Value = 128;

            % Create TheNumberOfFourierSeriesTermsEditFieldLabelKMin
            app.TheNumberOfFourierSeriesTermsEditFieldLabelKMin = uilabel(app.ModelSignalGeneratorUIFigure);
            app.TheNumberOfFourierSeriesTermsEditFieldLabelKMin.HorizontalAlignment = 'right';
            app.TheNumberOfFourierSeriesTermsEditFieldLabelKMin.WordWrap = 'on';
            app.TheNumberOfFourierSeriesTermsEditFieldLabelKMin.Position = [21 87 46 22];
            app.TheNumberOfFourierSeriesTermsEditFieldLabelKMin.Text = '2 <=';

            % Create TheNumberOfFourierSeriesTermsEditFieldLabelKMax
            app.TheNumberOfFourierSeriesTermsEditFieldLabelKMax = uilabel(app.ModelSignalGeneratorUIFigure);
            app.TheNumberOfFourierSeriesTermsEditFieldLabelKMax.WordWrap = 'on';
            app.TheNumberOfFourierSeriesTermsEditFieldLabelKMax.Position = [143 88 59 22];
            app.TheNumberOfFourierSeriesTermsEditFieldLabelKMax.Text = '<= 256';

            % Create SignalLabel
            app.SignalLabel = uilabel(app.ModelSignalGeneratorUIFigure);
            app.SignalLabel.BackgroundColor = [1 1 1];
            app.SignalLabel.FontColor = [1 0 0];
            app.SignalLabel.Position = [288 551 38 22];
            app.SignalLabel.Text = 'Signal';

            % Create FourierLabel
            app.FourierLabel = uilabel(app.ModelSignalGeneratorUIFigure);
            app.FourierLabel.BackgroundColor = [1 1 1];
            app.FourierLabel.FontColor = [0 0 1];
            app.FourierLabel.Position = [381 551 43 22];
            app.FourierLabel.Text = 'Fourier';

            % Create FouriercomplexLabel
            app.FouriercomplexLabel = uilabel(app.ModelSignalGeneratorUIFigure);
            app.FouriercomplexLabel.BackgroundColor = [1 1 1];
            app.FouriercomplexLabel.FontColor = [1 0 1];
            app.FouriercomplexLabel.Position = [469 551 99 22];
            app.FouriercomplexLabel.Text = 'Fourier (complex)';

            % Create UITableSKO
            app.UITableSKO = uitable(app.ModelSignalGeneratorUIFigure);
            app.UITableSKO.ColumnName = {'K'; 'SKO'; 'SKO_Complex'};
            app.UITableSKO.RowName = {};
            app.UITableSKO.Position = [661 335 376 201];

            % Create ClearTableButton
            app.ClearTableButton = uibutton(app.ModelSignalGeneratorUIFigure, 'push');
            app.ClearTableButton.ButtonPushedFcn = createCallbackFcn(app, @ClearTableButtonPushed, true);
            app.ClearTableButton.BackgroundColor = [1 0.9059 0.6784];
            app.ClearTableButton.Position = [661 315 376 23];
            app.ClearTableButton.Text = 'Clear table';

            % Create FourierSKOLabel
            app.FourierSKOLabel = uilabel(app.ModelSignalGeneratorUIFigure);
            app.FourierSKOLabel.BackgroundColor = [1 1 1];
            app.FourierSKOLabel.FontColor = [0 0 1];
            app.FourierSKOLabel.Position = [756 279 72 22];
            app.FourierSKOLabel.Text = 'Fourier SKO';

            % Create FouriercomplexSKOLabel
            app.FouriercomplexSKOLabel = uilabel(app.ModelSignalGeneratorUIFigure);
            app.FouriercomplexSKOLabel.BackgroundColor = [1 1 1];
            app.FouriercomplexSKOLabel.FontColor = [1 0 1];
            app.FouriercomplexSKOLabel.Position = [844 279 128 22];
            app.FouriercomplexSKOLabel.Text = 'Fourier (complex) SKO';

            % Create LogsTextAreaLabel
            app.LogsTextAreaLabel = uilabel(app.ModelSignalGeneratorUIFigure);
            app.LogsTextAreaLabel.HorizontalAlignment = 'right';
            app.LogsTextAreaLabel.Position = [1156 542 31 22];
            app.LogsTextAreaLabel.Text = 'Logs';

            % Create LogsTextArea
            app.LogsTextArea = uitextarea(app.ModelSignalGeneratorUIFigure);
            app.LogsTextArea.Position = [1065 61 211 475];

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
