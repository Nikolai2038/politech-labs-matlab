
classdef application < matlab.apps.AppBase

    % Properties that correspond to app components
    properties (Access = public)
        ModelSignalGeneratorUIFigure    matlab.ui.Figure
        Lab1Label                       matlab.ui.control.Label
        Lab3Label                       matlab.ui.control.Label
        Lab2Label                       matlab.ui.control.Label
        SmoothingWindowMax              matlab.ui.control.NumericEditField
        TheNumberOfFourierSeriesTermsEditFieldLabelKMin_2  matlab.ui.control.Label
        SmoothingWindowMin              matlab.ui.control.NumericEditField
        SmoothingwindowwidthEditFieldLabel  matlab.ui.control.Label
        TabGroup                        matlab.ui.container.TabGroup
        Lab1SignalTab                   matlab.ui.container.Tab
        SignalLabel_1                   matlab.ui.control.Label
        UIAxesSignals_1                 matlab.ui.control.UIAxes
        Lab2FourierTab                  matlab.ui.container.Tab
        LastinnervariablesTextArea      matlab.ui.control.TextArea
        LastinnervariablesTextAreaLabel  matlab.ui.control.Label
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
        TabGroup2                       matlab.ui.container.TabGroup
        SignalTab                       matlab.ui.container.Tab
        UIAxesSignals_3_Signal          matlab.ui.control.UIAxes
        KolmogorovWienerTab             matlab.ui.container.Tab
        UIAxesSignals_3_KolmogorovWiener  matlab.ui.control.UIAxes
        MedianTab                       matlab.ui.container.Tab
        BestsmoothingwindowfoundWLabel  matlab.ui.control.Label
        UIAxesSignals_3_Median          matlab.ui.control.UIAxes
        MovingAverageTab                matlab.ui.container.Tab
        SmoothingwindowW9Label          matlab.ui.control.Label
        UIAxesSignals_3_MovingAverage   matlab.ui.control.UIAxes
        ButterworthTab                  matlab.ui.container.Tab
        BandwidthNC15Label              matlab.ui.control.Label
        UIAxesSignals_3_Butterworth     matlab.ui.control.UIAxes
        ChebyshevTab                    matlab.ui.container.Tab
        BandwidthNC4Label               matlab.ui.control.Label
        UIAxesSignals_3_Chebyshev       matlab.ui.control.UIAxes
        ChebyshevInverseTab             matlab.ui.container.Tab
        BandwidthNC16Label              matlab.ui.control.Label
        UIAxesSignals_3_ChebyshevInverse  matlab.ui.control.UIAxes
        LowPassTab                      matlab.ui.container.Tab
        BandwidthNC64Label              matlab.ui.control.Label
        UIAxesSignals_3_LowPass         matlab.ui.control.UIAxes
        ClearTableButton_3              matlab.ui.control.Button
        UITableSKO_3                    matlab.ui.control.Table
        UIAxesSKO_3                     matlab.ui.control.UIAxes
        TheNumberOfFourierSeriesTermsEditFieldLabelKMax  matlab.ui.control.Label
        TheNumberOfFourierSeriesTermsEditFieldLabelKMin  matlab.ui.control.Label
        TheNumberOfFourierSeriesTermsEditField  matlab.ui.control.NumericEditField
        ThenumberofFourierseriestermsKkpKN4Label  matlab.ui.control.Label
        NumberofaccumulationsEditField  matlab.ui.control.NumericEditField
        NumberOfAccumulationsLabel      matlab.ui.control.Label
        SignaltypeDropDown              matlab.ui.control.DropDown
        ModelSignalGeneratorLabel       matlab.ui.control.Label
        SignalTypeLabel                 matlab.ui.control.Label
        NumberofpointsNEditField        matlab.ui.control.NumericEditField
        NumberOfPointsLabel             matlab.ui.control.Label
        NoisetypeDropDown               matlab.ui.control.DropDown
        NoiseTypeLabel                  matlab.ui.control.Label
        SignalamplitudeEditField        matlab.ui.control.NumericEditField
        SignalAmplitudeLabel            matlab.ui.control.Label
        NoiseSKOQEditField              matlab.ui.control.NumericEditField
        NoiseSKOLabel                   matlab.ui.control.Label
        PeriodsnumberkpEditField        matlab.ui.control.NumericEditField
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
            app.TheNumberOfFourierSeriesTermsEditFieldLabelKMin.Text = app.PeriodsnumberkpEditField.Value + " <=";
            % Update edit field minimum and maximum (do not include maximum in edit field properties)
            app.TheNumberOfFourierSeriesTermsEditField.Limits = [app.PeriodsnumberkpEditField.Value, app.NumberofpointsNEditField.Value / 4];
        end
        
        function UpdateMaxLimit(app)
            % Update text in label for maximum
            app.TheNumberOfFourierSeriesTermsEditFieldLabelKMax.Text = "<= " + app.NumberofpointsNEditField.Value / 4;
            % Update edit field minimum and maximum (do not include maximum in edit field properties)
            app.TheNumberOfFourierSeriesTermsEditField.Limits = [app.PeriodsnumberkpEditField.Value, app.NumberofpointsNEditField.Value / 4];
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

        % Button pushed function: GenerateButton
        function GenerateButtonPushed(app, event)
            % Количество периодов гармонической функции (kp)
            periods_number = app.PeriodsnumberkpEditField.Value;
            
            % Количество членов ряда Фурье (K)
            K = app.TheNumberOfFourierSeriesTermsEditField.Value;

            % Количество отсчетов (элементов массива y(t)) (number_of_points)
            number_of_points = app.NumberofpointsNEditField.Value;
            
            noise_sko = app.NoiseSKOQEditField.Value;
            signal_amplitude = app.SignalamplitudeEditField.Value;
            number_of_accumulations = app.NumberofaccumulationsEditField.Value;

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
                if (app.NoisetypeDropDown.Value == "Normally Distributed")
                    noise = randn(number_of_points);
                elseif (app.NoisetypeDropDown.Value == "White Gaussian Noise")
                    noise = wgn(number_of_points, 1, 0);
                else
                    noise = zeros(1, number_of_points);
                end
                noise = noise * noise_sko;

                for i = 1:number_of_points
                    x_calculated = (2 * T * periods_number * (i / number_of_points));
                    % Fill Y array by selected signal type
                    if (app.SignaltypeDropDown.Value == "Harmonic (Sinusoidal)")
                        y(i) = sin(x_calculated);
                    elseif (app.SignaltypeDropDown.Value == "Sawtooth")
                        y(i) = sawtooth(x_calculated);
                    elseif (app.SignaltypeDropDown.Value == "Triangular")
                        y(i) = sawtooth(x_calculated, 0.5);
                    elseif (app.SignaltypeDropDown.Value == "Rectangular Pulses")
                        y(i) = square(x_calculated);
                    elseif (app.SignaltypeDropDown.Value == "f(x) = abs(sin(x))")
                        y(i) = abs(sin(x_calculated));
                    elseif (app.SignaltypeDropDown.Value == "Bell-shaped")
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
            y_accumulated_without_noise = y_accumulated_without_noise / number_of_accumulations;
            % ----------------------------------------

            % ----------------------------------------
            % Изначальный сигнал: Рисуем график
            % ----------------------------------------
            plot(app.UIAxesSignals_1, x, y_accumulated, 'r');
            plot(app.UIAxesSignals_2, x, y_accumulated, 'r');
            plot(app.UIAxesSignals_3_Signal, x, y_accumulated, 'r');
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
            app.LastinnervariablesTextArea.Value = "n = " + K + "; " + "A0 = " + Sa0 * 2 + "; " + "An = " + Sa(K) + "; " + "Bn = " + Sb(K) + "; ";

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

            % Вывод графика сигнала после применения фильтра
            i = 1:N;
            plot(app.UIAxesSignals_3_KolmogorovWiener, i, Z(i), 'b');
            % ----------------------------------------

            % ----------------------------------------
            % Медианный фильтр
            % ----------------------------------------
            SKO_Median_min = 999999;
            W_optimal = app.SmoothingWindowMin.Value;
            y_optimal = zeros(1, N);
            % Ширина окна сглаживания - Находим наилучшую
            for W = app.SmoothingWindowMin.Value:app.SmoothingWindowMax.Value
                % Вычисление полуширины окна сглаживания
                H = round((W + 1) / 2);
                
                % Сглаживание зашумленного сигнала
                for i = 1:N-W 
                    z = zeros(1, W);
                    for j = 1:W
                        z(j) = x(j + i - 1);
                    end  
    
                  % Вычисление медианы в скользящем окне
                  y(i - 1 + H) = median(z);
                end
                for i = H:N-H
                    % Уровень зашумления в сигнале после фильтра
                    DZ(i) = s(i) - y(i);
                end

                % Полная погрешность в процентах
                DZ = DZ * 100 / (max(s) - min(s));
                SKO_Median = std(DZ);

                if (SKO_Median < SKO_Median_min)
                    SKO_Median_min = SKO_Median;
                    W_optimal = W;
                    y_optimal = y;
                end
            end

            app.BestsmoothingwindowfoundWLabel.Text = "Best smoothing window found: W = " + W_optimal;

            % Вывод графика сигнала после применения фильтра
            i = 1:N;
            plot(app.UIAxesSignals_3_Median, i, y_optimal(i), 'm');
            % ----------------------------------------

            % ----------------------------------------
            % Фильтр скользящего среднего
            % ----------------------------------------
            % Ширина окна сглаживания
            W = 9;
            
            % Вычисление полуширины окна сглаживания
            H = (W + 1) / 2;
            
            % Сглаживание зашумленного сигнала
            for i = 1:N-W 
                z = zeros(1, W);
                for j = 1:W
                    z(j) = x(j + i - 1);
                end

              % Вычисление скользящего среднего
              y(i - 1 + H) = mean(z);
            end
            for i = H:N-H
                % Уровень зашумления в сигнале после фильтра
                DZ(i) = s(i) - y(i);
            end

            % Полная погрешность в процентах
            DZ = DZ * 100 / (max(s) - min(s));
            SKO_MovingAverage = std(DZ);

            % Вывод графика сигнала после применения фильтра
            i = 1:N;
            plot(app.UIAxesSignals_3_MovingAverage, i, y(i), 'c');
            % ----------------------------------------

            % ----------------------------------------
            % Фильтр Беттерворта
            % ----------------------------------------
            % NC - полоса пропускания фильтра по уровню 0,7 амплитуды.
            % Выражена в количестве отчетов спектра БПФ, пропускаемых фильтром.
            % Остальные отсчеты (в частотном спектре!) будут ослабляться по амплитуде.
            NC = 15;
            
            for i = 1:N
                % Передаточная функция фильтра Баттерворта 4-го порядка
                H(i) = 1 / (sqrt(1 + (i / NC) .^ 4));
            end
            
            i = 1:N;

            % Частотный спектр сигнала с шумом
            XX1 = fft(x, N); 

            % Свертка частотного спектра зашумленного сигнала с частотной хар-кой фильтра
            Z = ifft(XX1 .* H);

            % Полная погрешность в процентах
            DZ1(i) = (2 * real(Z(i)) - s(i)) * 100 ./ (max(s) - min(s));
            SKO_Butterworth = std(DZ1);

            % Вывод графика сигнала после применения фильтра
            plot(app.UIAxesSignals_3_Butterworth, i, 2 * real(Z(i)), 'g');
            % ----------------------------------------

            % ----------------------------------------
            % Фильтр Чебышева
            % ----------------------------------------
            % NC - полоса пропускания фильтра по уровню 0,7 амплитуды.
            % Выражена в количестве отчетов спектра БПФ, пропускаемых фильтром.
            % Остальные отсчеты (в частотном спектре!) будут ослабляться по амплитуде.
            NC = 4;
            
            % Параметр фильтра Чебышёва
            e = 0.1;
                                  
            for i=1:N
                % Значение полинома Чебышёва 1 рода 2-го порядка  
                Tn = 2 * (i / NC) ^ 2 - 1;

                % Частотная характеристика фильтра Чебышева
                H(i) = 1 / sqrt(1 + e ^ 2 * Tn ^ 2);
            end
            
            i = 1:N;

            % Частотный спектр сигнала с шумом
            XX1 = fft(x, N); 
            
            % Свертка частотного спектра зашумленного сигнала с частотной хар-кой фильтра
            Z = ifft(XX1 .* H);

            % Полная погрешность в процентах
            DZ1(i) = (2 * real(Z(i)) - s(i)) * 100 / (max(s) - min(s));
            SKO_Chebyshev = std(DZ1);
            
            % Вывод графика сигнала после применения фильтра
            plot(app.UIAxesSignals_3_Chebyshev, i, 2 * real(Z(i)), 'k');
            % ----------------------------------------

            % ----------------------------------------
            % Инверсный фильтр Чебышева
            % ----------------------------------------
            % NC - полоса пропускания фильтра по уровню 0,7 амплитуды.
            % Выражена в количестве отчетов спектра БПФ, пропускаемых фильтром.
            % Остальные отсчеты (в частотном спектре!) будут ослабляться по амплитуде.
            NC = 16;
            
            % Параметр фильтра Чебышёва вместо 0.001
            e = 0.1;
                                  
            for i = 1:N   
                % Значение полинома Чебышёва 1 рода 2-го порядка
                Tn = 2 * (NC / i) ^ 2 - 1;

                % Частотная характеристика инверсного фильтра Чебышёва
                H(i) = sqrt((e ^ 2 * Tn ^ 2) / ((1 + e ^ 2 * Tn ^ 2)));
            end
                        
            i = 1:N;

            % Частотный спектр сигнала с шумом
            XX1 = fft(x, N); 
            
            % Свертка частотного спектра зашумленного сигнала с частотной хар-кой фильтра
            Z = ifft(XX1 .* H);

            % Полная погрешность в процентах
            DZ1(i) = (2 * real(Z(i)) - s(i)) * 100 ./ (max(s) - min(s));
            SKO_ChebyshevInverse = std(DZ1);
                        
            % Вывод графика сигнала после применения фильтра
            plot(app.UIAxesSignals_3_ChebyshevInverse, i, 2 * real(Z(i)), 'b');
            % ----------------------------------------

            % ----------------------------------------
            % Низкочастотный фильтр 1-го порядка
            % ----------------------------------------
            % NC - полоса пропускания фильтра по уровню 0,7 амплитуды.
            % Выражена в количестве отчетов спектра БПФ, пропускаемых фильтром.
            % Остальные отсчеты (в частотном спектре!) будут ослабляться по амплитуде.
            NC = 64;
                 
            for i = 1:N    
                % Передаточная функция цифрового фильтра НЧ 1-го порядка в частотной области
                H(i) = 1 / (1 + j * i / NC); 
            end

            i = 1:N;
                      
            % Частотный спектр сигнала с шумом
            XX1 = fft(x, N); 
            
            % Свертка частотного спектра зашумленного сигнала с частотной хар-кой фильтра
            Z = ifft(XX1 .* H);

            % Полная погрешность в процентах
            DZ1(i) = (2 * real(Z(i)) - s(i)) * 100 ./ (max(s) - min(s));
            SKO_LowPass = std(DZ1);

            % Вывод графика сигнала после применения фильтра
            plot(app.UIAxesSignals_3_LowPass, i, 2 * real(Z(i)), 'm');
            % ----------------------------------------

            % Устанавливаем вертикальные границы области графика - чтобы у всех графиков они были одинаковые
            app.UIAxesSignals_3_Signal.YLimMode = "manual";
            app.UIAxesSignals_3_KolmogorovWiener.YLimMode = "manual";
            app.UIAxesSignals_3_Median.YLimMode = "manual";
            app.UIAxesSignals_3_MovingAverage.YLimMode = "manual";
            app.UIAxesSignals_3_Butterworth.YLimMode = "manual";
            app.UIAxesSignals_3_Chebyshev.YLimMode = "manual";
            app.UIAxesSignals_3_ChebyshevInverse.YLimMode = "manual";
            app.UIAxesSignals_3_LowPass.YLimMode = "manual";
            y_limit = [-signal_amplitude * 1.3, signal_amplitude * 1.3];
            app.UIAxesSignals_3_Signal.YLim = y_limit;
            app.UIAxesSignals_3_KolmogorovWiener.YLim = y_limit;
            app.UIAxesSignals_3_Median.YLim = y_limit;
            app.UIAxesSignals_3_MovingAverage.YLim = y_limit;
            app.UIAxesSignals_3_Butterworth.YLim = y_limit;
            app.UIAxesSignals_3_Chebyshev.YLim = y_limit;
            app.UIAxesSignals_3_ChebyshevInverse.YLim = y_limit;
            app.UIAxesSignals_3_LowPass.YLim = y_limit;

            % ----------------------------------------
            % Обновляем график зависимости погрешности от K
            % ----------------------------------------
            % TODO: Добавить все СКО в таблицу и отобразить все графики
            % Add new row to the table
            app.FiltersData = [app.FiltersData; Q SKO_KolVin SKO_Median_min];

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

        % Value changed function: NoisetypeDropDown
        function NoisetypeDropDownValueChanged(app, event)
            if (app.NoisetypeDropDown.Value == "None")
                app.NoiseSKOLabel.Enable = "off";
                app.NoiseSKOQEditField.Enable = "off";
            else
                app.NoiseSKOLabel.Enable = "on";
                app.NoiseSKOQEditField.Enable = "on";
            end
            app.ClearTableFourier();
            app.ClearTableFilters();
        end

        % Value changed function: NumberofpointsNEditField
        function NumberofpointsNEditFieldValueChanged(app, event)
            app.UpdateMaxLimit();
            app.ClearTableFourier();
            app.ClearTableFilters();
        end

        % Value changed function: PeriodsnumberkpEditField
        function PeriodsnumberkpEditFieldValueChanged(app, event)
            app.UpdateMinLimit();
            app.ClearTableFourier();
            app.ClearTableFilters();
        end

        % Value changed function: NoiseSKOQEditField
        function NoiseSKOQEditFieldValueChanged(app, event)
            app.ClearTableFourier();
        end

        % Value changed function: SignaltypeDropDown
        function SignaltypeDropDownValueChanged(app, event)
            app.ClearTableFourier();
            app.ClearTableFilters();
        end

        % Value changed function: NumberofaccumulationsEditField
        function NumberofaccumulationsEditFieldValueChanged(app, event)
            app.ClearTableFourier();
            app.ClearTableFilters();
        end

        % Button pushed function: ClearTableButton_2
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
            app.ModelSignalGeneratorUIFigure.Position = [100 100 1200 724];
            app.ModelSignalGeneratorUIFigure.Name = 'Model Signal Generator';

            % Create GenerateButton
            app.GenerateButton = uibutton(app.ModelSignalGeneratorUIFigure, 'push');
            app.GenerateButton.ButtonPushedFcn = createCallbackFcn(app, @GenerateButtonPushed, true);
            app.GenerateButton.BackgroundColor = [0.9137 1 0.8];
            app.GenerateButton.Position = [18 17 156 42];
            app.GenerateButton.Text = 'Generate';

            % Create PeriodsNumberLabel
            app.PeriodsNumberLabel = uilabel(app.ModelSignalGeneratorUIFigure);
            app.PeriodsNumberLabel.HorizontalAlignment = 'right';
            app.PeriodsNumberLabel.Position = [39 342 117 22];
            app.PeriodsNumberLabel.Text = 'Periods number (kp):';

            % Create PeriodsnumberkpEditField
            app.PeriodsnumberkpEditField = uieditfield(app.ModelSignalGeneratorUIFigure, 'numeric');
            app.PeriodsnumberkpEditField.ValueDisplayFormat = '%9.1f';
            app.PeriodsnumberkpEditField.ValueChangedFcn = createCallbackFcn(app, @PeriodsnumberkpEditFieldValueChanged, true);
            app.PeriodsnumberkpEditField.HorizontalAlignment = 'center';
            app.PeriodsnumberkpEditField.Position = [18 321 155 22];
            app.PeriodsnumberkpEditField.Value = 5;

            % Create NoiseSKOLabel
            app.NoiseSKOLabel = uilabel(app.ModelSignalGeneratorUIFigure);
            app.NoiseSKOLabel.HorizontalAlignment = 'right';
            app.NoiseSKOLabel.Position = [51 405 88 22];
            app.NoiseSKOLabel.Text = 'Noise SKO (Q):';

            % Create NoiseSKOQEditField
            app.NoiseSKOQEditField = uieditfield(app.ModelSignalGeneratorUIFigure, 'numeric');
            app.NoiseSKOQEditField.ValueDisplayFormat = '%9.1f';
            app.NoiseSKOQEditField.ValueChangedFcn = createCallbackFcn(app, @NoiseSKOQEditFieldValueChanged, true);
            app.NoiseSKOQEditField.HorizontalAlignment = 'center';
            app.NoiseSKOQEditField.Position = [18 384 155 22];
            app.NoiseSKOQEditField.Value = 0.1;

            % Create SignalAmplitudeLabel
            app.SignalAmplitudeLabel = uilabel(app.ModelSignalGeneratorUIFigure);
            app.SignalAmplitudeLabel.HorizontalAlignment = 'right';
            app.SignalAmplitudeLabel.Position = [44 530 97 22];
            app.SignalAmplitudeLabel.Text = 'Signal amplitude:';

            % Create SignalamplitudeEditField
            app.SignalamplitudeEditField = uieditfield(app.ModelSignalGeneratorUIFigure, 'numeric');
            app.SignalamplitudeEditField.ValueDisplayFormat = '%9.1f';
            app.SignalamplitudeEditField.HorizontalAlignment = 'center';
            app.SignalamplitudeEditField.Position = [17 509 155 22];
            app.SignalamplitudeEditField.Value = 1;

            % Create NoiseTypeLabel
            app.NoiseTypeLabel = uilabel(app.ModelSignalGeneratorUIFigure);
            app.NoiseTypeLabel.HorizontalAlignment = 'right';
            app.NoiseTypeLabel.Position = [64 463 65 22];
            app.NoiseTypeLabel.Text = 'Noise type:';

            % Create NoisetypeDropDown
            app.NoisetypeDropDown = uidropdown(app.ModelSignalGeneratorUIFigure);
            app.NoisetypeDropDown.Items = {'None', 'Normally Distributed', 'White Gaussian Noise'};
            app.NoisetypeDropDown.ValueChangedFcn = createCallbackFcn(app, @NoisetypeDropDownValueChanged, true);
            app.NoisetypeDropDown.Position = [18 442 155 22];
            app.NoisetypeDropDown.Value = 'Normally Distributed';

            % Create NumberOfPointsLabel
            app.NumberOfPointsLabel = uilabel(app.ModelSignalGeneratorUIFigure);
            app.NumberOfPointsLabel.HorizontalAlignment = 'right';
            app.NumberOfPointsLabel.Position = [38 590 120 22];
            app.NumberOfPointsLabel.Text = 'Number of points (N):';

            % Create NumberofpointsNEditField
            app.NumberofpointsNEditField = uieditfield(app.ModelSignalGeneratorUIFigure, 'numeric');
            app.NumberofpointsNEditField.RoundFractionalValues = 'on';
            app.NumberofpointsNEditField.ValueDisplayFormat = '%.0f';
            app.NumberofpointsNEditField.ValueChangedFcn = createCallbackFcn(app, @NumberofpointsNEditFieldValueChanged, true);
            app.NumberofpointsNEditField.HorizontalAlignment = 'center';
            app.NumberofpointsNEditField.Position = [17 569 155 22];
            app.NumberofpointsNEditField.Value = 1024;

            % Create SignalTypeLabel
            app.SignalTypeLabel = uilabel(app.ModelSignalGeneratorUIFigure);
            app.SignalTypeLabel.HorizontalAlignment = 'right';
            app.SignalTypeLabel.Position = [60 647 68 22];
            app.SignalTypeLabel.Text = 'Signal type:';

            % Create ModelSignalGeneratorLabel
            app.ModelSignalGeneratorLabel = uilabel(app.ModelSignalGeneratorUIFigure);
            app.ModelSignalGeneratorLabel.HorizontalAlignment = 'center';
            app.ModelSignalGeneratorLabel.FontSize = 24;
            app.ModelSignalGeneratorLabel.Position = [1 682 1200 31];
            app.ModelSignalGeneratorLabel.Text = 'Model Signal Generator';

            % Create SignaltypeDropDown
            app.SignaltypeDropDown = uidropdown(app.ModelSignalGeneratorUIFigure);
            app.SignaltypeDropDown.Items = {'Harmonic (Sinusoidal)', 'Sawtooth', 'Triangular', 'Rectangular Pulses', 'f(x) = abs(sin(x))', 'Bell-shaped'};
            app.SignaltypeDropDown.ValueChangedFcn = createCallbackFcn(app, @SignaltypeDropDownValueChanged, true);
            app.SignaltypeDropDown.Position = [17 626 155 22];
            app.SignaltypeDropDown.Value = 'Harmonic (Sinusoidal)';

            % Create NumberOfAccumulationsLabel
            app.NumberOfAccumulationsLabel = uilabel(app.ModelSignalGeneratorUIFigure);
            app.NumberOfAccumulationsLabel.HorizontalAlignment = 'right';
            app.NumberOfAccumulationsLabel.Position = [25 261 144 22];
            app.NumberOfAccumulationsLabel.Text = 'Number of accumulations:';

            % Create NumberofaccumulationsEditField
            app.NumberofaccumulationsEditField = uieditfield(app.ModelSignalGeneratorUIFigure, 'numeric');
            app.NumberofaccumulationsEditField.RoundFractionalValues = 'on';
            app.NumberofaccumulationsEditField.ValueDisplayFormat = '%.0f';
            app.NumberofaccumulationsEditField.ValueChangedFcn = createCallbackFcn(app, @NumberofaccumulationsEditFieldValueChanged, true);
            app.NumberofaccumulationsEditField.HorizontalAlignment = 'center';
            app.NumberofaccumulationsEditField.Position = [18 240 155 22];
            app.NumberofaccumulationsEditField.Value = 1;

            % Create ThenumberofFourierseriestermsKkpKN4Label
            app.ThenumberofFourierseriestermsKkpKN4Label = uilabel(app.ModelSignalGeneratorUIFigure);
            app.ThenumberofFourierseriestermsKkpKN4Label.HorizontalAlignment = 'center';
            app.ThenumberofFourierseriestermsKkpKN4Label.WordWrap = 'on';
            app.ThenumberofFourierseriestermsKkpKN4Label.Position = [11 176 166 30];
            app.ThenumberofFourierseriestermsKkpKN4Label.Text = 'The number of Fourier series terms (K, kp <= K <= N/4):';

            % Create TheNumberOfFourierSeriesTermsEditField
            app.TheNumberOfFourierSeriesTermsEditField = uieditfield(app.ModelSignalGeneratorUIFigure, 'numeric');
            app.TheNumberOfFourierSeriesTermsEditField.RoundFractionalValues = 'on';
            app.TheNumberOfFourierSeriesTermsEditField.ValueDisplayFormat = '%.0f';
            app.TheNumberOfFourierSeriesTermsEditField.HorizontalAlignment = 'center';
            app.TheNumberOfFourierSeriesTermsEditField.Position = [62 152 66 22];
            app.TheNumberOfFourierSeriesTermsEditField.Value = 5;

            % Create TheNumberOfFourierSeriesTermsEditFieldLabelKMin
            app.TheNumberOfFourierSeriesTermsEditFieldLabelKMin = uilabel(app.ModelSignalGeneratorUIFigure);
            app.TheNumberOfFourierSeriesTermsEditFieldLabelKMin.HorizontalAlignment = 'right';
            app.TheNumberOfFourierSeriesTermsEditFieldLabelKMin.WordWrap = 'on';
            app.TheNumberOfFourierSeriesTermsEditFieldLabelKMin.Position = [10 152 46 22];
            app.TheNumberOfFourierSeriesTermsEditFieldLabelKMin.Text = '5 <=';

            % Create TheNumberOfFourierSeriesTermsEditFieldLabelKMax
            app.TheNumberOfFourierSeriesTermsEditFieldLabelKMax = uilabel(app.ModelSignalGeneratorUIFigure);
            app.TheNumberOfFourierSeriesTermsEditFieldLabelKMax.WordWrap = 'on';
            app.TheNumberOfFourierSeriesTermsEditFieldLabelKMax.Position = [131 152 42 22];
            app.TheNumberOfFourierSeriesTermsEditFieldLabelKMax.Text = '<= 256';

            % Create TabGroup
            app.TabGroup = uitabgroup(app.ModelSignalGeneratorUIFigure);
            app.TabGroup.Position = [191 17 995 652];

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
            app.UIAxesSignals_1.Position = [17 21 967 570];

            % Create SignalLabel_1
            app.SignalLabel_1 = uilabel(app.Lab1SignalTab);
            app.SignalLabel_1.BackgroundColor = [1 1 1];
            app.SignalLabel_1.FontColor = [1 0 0];
            app.SignalLabel_1.Position = [501 594 38 22];
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
            app.UIAxesSignals_2.Position = [8 74 564 515];

            % Create UIAxesSKO_2
            app.UIAxesSKO_2 = uiaxes(app.Lab2FourierTab);
            xlabel(app.UIAxesSKO_2, 'K')
            ylabel(app.UIAxesSKO_2, 'SKO')
            zlabel(app.UIAxesSKO_2, 'Z')
            app.UIAxesSKO_2.Box = 'on';
            app.UIAxesSKO_2.XGrid = 'on';
            app.UIAxesSKO_2.YGrid = 'on';
            app.UIAxesSKO_2.Position = [587 11 393 311];

            % Create SignalLabel_2
            app.SignalLabel_2 = uilabel(app.Lab2FourierTab);
            app.SignalLabel_2.BackgroundColor = [1 1 1];
            app.SignalLabel_2.FontColor = [1 0 0];
            app.SignalLabel_2.Position = [161 590 38 22];
            app.SignalLabel_2.Text = 'Signal';

            % Create FourierLabel_2
            app.FourierLabel_2 = uilabel(app.Lab2FourierTab);
            app.FourierLabel_2.BackgroundColor = [1 1 1];
            app.FourierLabel_2.FontColor = [0 0 1];
            app.FourierLabel_2.Position = [254 590 43 22];
            app.FourierLabel_2.Text = 'Fourier';

            % Create FouriercomplexLabel_2
            app.FouriercomplexLabel_2 = uilabel(app.Lab2FourierTab);
            app.FouriercomplexLabel_2.BackgroundColor = [1 1 1];
            app.FouriercomplexLabel_2.FontColor = [1 0 1];
            app.FouriercomplexLabel_2.Position = [342 590 99 22];
            app.FouriercomplexLabel_2.Text = 'Fourier (complex)';

            % Create UITableSKO_2
            app.UITableSKO_2 = uitable(app.Lab2FourierTab);
            app.UITableSKO_2.ColumnName = {'K'; 'SKO'; 'SKO_Complex'};
            app.UITableSKO_2.RowName = {};
            app.UITableSKO_2.Position = [596 382 376 201];

            % Create ClearTableButton_2
            app.ClearTableButton_2 = uibutton(app.Lab2FourierTab, 'push');
            app.ClearTableButton_2.ButtonPushedFcn = createCallbackFcn(app, @ClearTableButton_2Pushed, true);
            app.ClearTableButton_2.BackgroundColor = [1 0.9059 0.6784];
            app.ClearTableButton_2.Position = [596 362 376 23];
            app.ClearTableButton_2.Text = 'Clear table';

            % Create FourierSKOLabel_2
            app.FourierSKOLabel_2 = uilabel(app.Lab2FourierTab);
            app.FourierSKOLabel_2.BackgroundColor = [1 1 1];
            app.FourierSKOLabel_2.FontColor = [0 0 1];
            app.FourierSKOLabel_2.Position = [698 325 72 22];
            app.FourierSKOLabel_2.Text = 'Fourier SKO';

            % Create FouriercomplexSKOLabel_2
            app.FouriercomplexSKOLabel_2 = uilabel(app.Lab2FourierTab);
            app.FouriercomplexSKOLabel_2.BackgroundColor = [1 1 1];
            app.FouriercomplexSKOLabel_2.FontColor = [1 0 1];
            app.FouriercomplexSKOLabel_2.Position = [786 325 128 22];
            app.FouriercomplexSKOLabel_2.Text = 'Fourier (complex) SKO';

            % Create LastinnervariablesTextAreaLabel
            app.LastinnervariablesTextAreaLabel = uilabel(app.Lab2FourierTab);
            app.LastinnervariablesTextAreaLabel.HorizontalAlignment = 'right';
            app.LastinnervariablesTextAreaLabel.Position = [243 41 112 22];
            app.LastinnervariablesTextAreaLabel.Text = 'Last inner variables:';

            % Create LastinnervariablesTextArea
            app.LastinnervariablesTextArea = uitextarea(app.Lab2FourierTab);
            app.LastinnervariablesTextArea.HorizontalAlignment = 'center';
            app.LastinnervariablesTextArea.WordWrap = 'off';
            app.LastinnervariablesTextArea.Position = [37 11 524 24];

            % Create Lab3FiltersTab
            app.Lab3FiltersTab = uitab(app.TabGroup);
            app.Lab3FiltersTab.Title = 'Lab 3: Filters';

            % Create UIAxesSKO_3
            app.UIAxesSKO_3 = uiaxes(app.Lab3FiltersTab);
            xlabel(app.UIAxesSKO_3, 'Q')
            ylabel(app.UIAxesSKO_3, 'SKO')
            zlabel(app.UIAxesSKO_3, 'Z')
            app.UIAxesSKO_3.Box = 'on';
            app.UIAxesSKO_3.XGrid = 'on';
            app.UIAxesSKO_3.YGrid = 'on';
            app.UIAxesSKO_3.Position = [655 13 328 273];

            % Create UITableSKO_3
            app.UITableSKO_3 = uitable(app.Lab3FiltersTab);
            app.UITableSKO_3.ColumnName = {'Q'; 'SKO_KolVin'; 'SKO_Median'};
            app.UITableSKO_3.RowName = {};
            app.UITableSKO_3.Position = [25 33 624 251];

            % Create ClearTableButton_3
            app.ClearTableButton_3 = uibutton(app.Lab3FiltersTab, 'push');
            app.ClearTableButton_3.ButtonPushedFcn = createCallbackFcn(app, @ClearTableButton_3Pushed, true);
            app.ClearTableButton_3.BackgroundColor = [1 0.9059 0.6784];
            app.ClearTableButton_3.Position = [25 13 624 23];
            app.ClearTableButton_3.Text = 'Clear table';

            % Create TabGroup2
            app.TabGroup2 = uitabgroup(app.Lab3FiltersTab);
            app.TabGroup2.Position = [17 296 967 320];

            % Create SignalTab
            app.SignalTab = uitab(app.TabGroup2);
            app.SignalTab.Title = 'Signal';

            % Create UIAxesSignals_3_Signal
            app.UIAxesSignals_3_Signal = uiaxes(app.SignalTab);
            xlabel(app.UIAxesSignals_3_Signal, 'N')
            ylabel(app.UIAxesSignals_3_Signal, 'S')
            zlabel(app.UIAxesSignals_3_Signal, 'Z')
            app.UIAxesSignals_3_Signal.Box = 'on';
            app.UIAxesSignals_3_Signal.XGrid = 'on';
            app.UIAxesSignals_3_Signal.YGrid = 'on';
            app.UIAxesSignals_3_Signal.Position = [8 8 947 279];

            % Create KolmogorovWienerTab
            app.KolmogorovWienerTab = uitab(app.TabGroup2);
            app.KolmogorovWienerTab.Title = 'Kolmogorov-Wiener';

            % Create UIAxesSignals_3_KolmogorovWiener
            app.UIAxesSignals_3_KolmogorovWiener = uiaxes(app.KolmogorovWienerTab);
            xlabel(app.UIAxesSignals_3_KolmogorovWiener, 'N')
            ylabel(app.UIAxesSignals_3_KolmogorovWiener, 'S')
            zlabel(app.UIAxesSignals_3_KolmogorovWiener, 'Z')
            app.UIAxesSignals_3_KolmogorovWiener.Box = 'on';
            app.UIAxesSignals_3_KolmogorovWiener.XGrid = 'on';
            app.UIAxesSignals_3_KolmogorovWiener.YGrid = 'on';
            app.UIAxesSignals_3_KolmogorovWiener.Position = [8 8 947 279];

            % Create MedianTab
            app.MedianTab = uitab(app.TabGroup2);
            app.MedianTab.Title = 'Median';

            % Create UIAxesSignals_3_Median
            app.UIAxesSignals_3_Median = uiaxes(app.MedianTab);
            xlabel(app.UIAxesSignals_3_Median, 'N')
            ylabel(app.UIAxesSignals_3_Median, 'S')
            zlabel(app.UIAxesSignals_3_Median, 'Z')
            app.UIAxesSignals_3_Median.Box = 'on';
            app.UIAxesSignals_3_Median.XGrid = 'on';
            app.UIAxesSignals_3_Median.YGrid = 'on';
            app.UIAxesSignals_3_Median.Position = [8 8 947 279];

            % Create BestsmoothingwindowfoundWLabel
            app.BestsmoothingwindowfoundWLabel = uilabel(app.MedianTab);
            app.BestsmoothingwindowfoundWLabel.HorizontalAlignment = 'right';
            app.BestsmoothingwindowfoundWLabel.VerticalAlignment = 'bottom';
            app.BestsmoothingwindowfoundWLabel.Position = [638 4 301 22];
            app.BestsmoothingwindowfoundWLabel.Text = 'Best smoothing window found: W = ?';

            % Create MovingAverageTab
            app.MovingAverageTab = uitab(app.TabGroup2);
            app.MovingAverageTab.Title = 'Moving Average';

            % Create UIAxesSignals_3_MovingAverage
            app.UIAxesSignals_3_MovingAverage = uiaxes(app.MovingAverageTab);
            xlabel(app.UIAxesSignals_3_MovingAverage, 'N')
            ylabel(app.UIAxesSignals_3_MovingAverage, 'S')
            zlabel(app.UIAxesSignals_3_MovingAverage, 'Z')
            app.UIAxesSignals_3_MovingAverage.Box = 'on';
            app.UIAxesSignals_3_MovingAverage.XGrid = 'on';
            app.UIAxesSignals_3_MovingAverage.YGrid = 'on';
            app.UIAxesSignals_3_MovingAverage.Position = [8 8 947 279];

            % Create SmoothingwindowW9Label
            app.SmoothingwindowW9Label = uilabel(app.MovingAverageTab);
            app.SmoothingwindowW9Label.HorizontalAlignment = 'right';
            app.SmoothingwindowW9Label.VerticalAlignment = 'bottom';
            app.SmoothingwindowW9Label.Position = [638 4 301 22];
            app.SmoothingwindowW9Label.Text = 'Smoothing window: W = 9';

            % Create ButterworthTab
            app.ButterworthTab = uitab(app.TabGroup2);
            app.ButterworthTab.Title = 'Butterworth';

            % Create UIAxesSignals_3_Butterworth
            app.UIAxesSignals_3_Butterworth = uiaxes(app.ButterworthTab);
            xlabel(app.UIAxesSignals_3_Butterworth, 'N')
            ylabel(app.UIAxesSignals_3_Butterworth, 'S')
            zlabel(app.UIAxesSignals_3_Butterworth, 'Z')
            app.UIAxesSignals_3_Butterworth.Box = 'on';
            app.UIAxesSignals_3_Butterworth.XGrid = 'on';
            app.UIAxesSignals_3_Butterworth.YGrid = 'on';
            app.UIAxesSignals_3_Butterworth.Position = [8 8 947 279];

            % Create BandwidthNC15Label
            app.BandwidthNC15Label = uilabel(app.ButterworthTab);
            app.BandwidthNC15Label.HorizontalAlignment = 'right';
            app.BandwidthNC15Label.VerticalAlignment = 'bottom';
            app.BandwidthNC15Label.Position = [638 4 301 22];
            app.BandwidthNC15Label.Text = 'Bandwidth: NC = 15';

            % Create ChebyshevTab
            app.ChebyshevTab = uitab(app.TabGroup2);
            app.ChebyshevTab.Title = 'Chebyshev';

            % Create UIAxesSignals_3_Chebyshev
            app.UIAxesSignals_3_Chebyshev = uiaxes(app.ChebyshevTab);
            xlabel(app.UIAxesSignals_3_Chebyshev, 'N')
            ylabel(app.UIAxesSignals_3_Chebyshev, 'S')
            zlabel(app.UIAxesSignals_3_Chebyshev, 'Z')
            app.UIAxesSignals_3_Chebyshev.Box = 'on';
            app.UIAxesSignals_3_Chebyshev.XGrid = 'on';
            app.UIAxesSignals_3_Chebyshev.YGrid = 'on';
            app.UIAxesSignals_3_Chebyshev.Position = [8 8 947 279];

            % Create BandwidthNC4Label
            app.BandwidthNC4Label = uilabel(app.ChebyshevTab);
            app.BandwidthNC4Label.HorizontalAlignment = 'right';
            app.BandwidthNC4Label.VerticalAlignment = 'bottom';
            app.BandwidthNC4Label.Position = [638 4 301 22];
            app.BandwidthNC4Label.Text = 'Bandwidth: NC = 4';

            % Create ChebyshevInverseTab
            app.ChebyshevInverseTab = uitab(app.TabGroup2);
            app.ChebyshevInverseTab.Title = 'Chebyshev Inverse';

            % Create UIAxesSignals_3_ChebyshevInverse
            app.UIAxesSignals_3_ChebyshevInverse = uiaxes(app.ChebyshevInverseTab);
            xlabel(app.UIAxesSignals_3_ChebyshevInverse, 'N')
            ylabel(app.UIAxesSignals_3_ChebyshevInverse, 'S')
            zlabel(app.UIAxesSignals_3_ChebyshevInverse, 'Z')
            app.UIAxesSignals_3_ChebyshevInverse.Box = 'on';
            app.UIAxesSignals_3_ChebyshevInverse.XGrid = 'on';
            app.UIAxesSignals_3_ChebyshevInverse.YGrid = 'on';
            app.UIAxesSignals_3_ChebyshevInverse.Position = [8 8 947 279];

            % Create BandwidthNC16Label
            app.BandwidthNC16Label = uilabel(app.ChebyshevInverseTab);
            app.BandwidthNC16Label.HorizontalAlignment = 'right';
            app.BandwidthNC16Label.VerticalAlignment = 'bottom';
            app.BandwidthNC16Label.Position = [638 4 301 22];
            app.BandwidthNC16Label.Text = 'Bandwidth: NC = 16';

            % Create LowPassTab
            app.LowPassTab = uitab(app.TabGroup2);
            app.LowPassTab.Title = 'Low-Pass';

            % Create UIAxesSignals_3_LowPass
            app.UIAxesSignals_3_LowPass = uiaxes(app.LowPassTab);
            xlabel(app.UIAxesSignals_3_LowPass, 'N')
            ylabel(app.UIAxesSignals_3_LowPass, 'S')
            zlabel(app.UIAxesSignals_3_LowPass, 'Z')
            app.UIAxesSignals_3_LowPass.Box = 'on';
            app.UIAxesSignals_3_LowPass.XGrid = 'on';
            app.UIAxesSignals_3_LowPass.YGrid = 'on';
            app.UIAxesSignals_3_LowPass.Position = [8 8 947 279];

            % Create BandwidthNC64Label
            app.BandwidthNC64Label = uilabel(app.LowPassTab);
            app.BandwidthNC64Label.HorizontalAlignment = 'right';
            app.BandwidthNC64Label.VerticalAlignment = 'bottom';
            app.BandwidthNC64Label.Position = [638 4 301 22];
            app.BandwidthNC64Label.Text = 'Bandwidth: NC = 64';

            % Create SmoothingwindowwidthEditFieldLabel
            app.SmoothingwindowwidthEditFieldLabel = uilabel(app.ModelSignalGeneratorUIFigure);
            app.SmoothingwindowwidthEditFieldLabel.HorizontalAlignment = 'right';
            app.SmoothingwindowwidthEditFieldLabel.Position = [27 97 140 22];
            app.SmoothingwindowwidthEditFieldLabel.Text = 'Smoothing window width:';

            % Create SmoothingWindowMin
            app.SmoothingWindowMin = uieditfield(app.ModelSignalGeneratorUIFigure, 'numeric');
            app.SmoothingWindowMin.Limits = [1 Inf];
            app.SmoothingWindowMin.RoundFractionalValues = 'on';
            app.SmoothingWindowMin.ValueDisplayFormat = '%.0f';
            app.SmoothingWindowMin.HorizontalAlignment = 'center';
            app.SmoothingWindowMin.Position = [23 76 37 22];
            app.SmoothingWindowMin.Value = 5;

            % Create TheNumberOfFourierSeriesTermsEditFieldLabelKMin_2
            app.TheNumberOfFourierSeriesTermsEditFieldLabelKMin_2 = uilabel(app.ModelSignalGeneratorUIFigure);
            app.TheNumberOfFourierSeriesTermsEditFieldLabelKMin_2.HorizontalAlignment = 'center';
            app.TheNumberOfFourierSeriesTermsEditFieldLabelKMin_2.WordWrap = 'on';
            app.TheNumberOfFourierSeriesTermsEditFieldLabelKMin_2.Position = [61 76 69 22];
            app.TheNumberOfFourierSeriesTermsEditFieldLabelKMin_2.Text = '<= W <=';

            % Create SmoothingWindowMax
            app.SmoothingWindowMax = uieditfield(app.ModelSignalGeneratorUIFigure, 'numeric');
            app.SmoothingWindowMax.Limits = [1 Inf];
            app.SmoothingWindowMax.RoundFractionalValues = 'on';
            app.SmoothingWindowMax.ValueDisplayFormat = '%.0f';
            app.SmoothingWindowMax.HorizontalAlignment = 'center';
            app.SmoothingWindowMax.Position = [131 76 40 22];
            app.SmoothingWindowMax.Value = 30;

            % Create Lab2Label
            app.Lab2Label = uilabel(app.ModelSignalGeneratorUIFigure);
            app.Lab2Label.Position = [74 205 43 22];
            app.Lab2Label.Text = '(Lab 2)';

            % Create Lab3Label
            app.Lab3Label = uilabel(app.ModelSignalGeneratorUIFigure);
            app.Lab3Label.Position = [75 116 43 22];
            app.Lab3Label.Text = '(Lab 3)';

            % Create Lab1Label
            app.Lab1Label = uilabel(app.ModelSignalGeneratorUIFigure);
            app.Lab1Label.Position = [75 279 43 22];
            app.Lab1Label.Text = '(Lab 1)';

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
