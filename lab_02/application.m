
classdef application < matlab.apps.AppBase

    % Properties that correspond to app components
    properties (Access = public)
        ModelSignalGeneratorUIFigure    matlab.ui.Figure
        FouriercomplexLabel             matlab.ui.control.Label
        FourierLabel                    matlab.ui.control.Label
        SignalLabel                     matlab.ui.control.Label
        ClearTableButton                matlab.ui.control.Button
        UITable                         matlab.ui.control.Table
        TheNumberOfFourierSeriesTermsEditFieldLabelKMax  matlab.ui.control.Label
        TheNumberOfFourierSeriesTermsEditFieldLabelKMin  matlab.ui.control.Label
        TheNumberOfFourierSeriesTermsEditField  matlab.ui.control.NumericEditField
        ThenumberofFourierseriestermsKkpKN4Label  matlab.ui.control.Label
        NumberOfAccumulationsEditField  matlab.ui.control.NumericEditField
        NumberOfAccumulationsLabel      matlab.ui.control.Label
        ModelSignalGeneratorLabel       matlab.ui.control.Label
        SignalTypeDropDown              matlab.ui.control.DropDown
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
        QuitButton                      matlab.ui.control.Button
        GenerateButton                  matlab.ui.control.Button
        UIAxes_2                        matlab.ui.control.UIAxes
        UIAxes                          matlab.ui.control.UIAxes
    end

    
    properties (Access = private)
        TableData
    end
    
    methods (Access = private)
        function UpdateTableChart(app)
            if (isempty(app.TableData))
                % Empty the data
                app.UITable.Data = [];

                % Clear chart
                cla(app.UIAxes_2);
            else
                % Load data from variable
                app.UITable.Data = array2table(app.TableData,'VariableNames',{'K','SKO'});
    
                x = app.UITable.Data.K;
                y = app.UITable.Data.SKO;
    
                % Draw chart
                plot(app.UIAxes_2, x, y);
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

        % Button pushed function: QuitButton
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

            % Define frequency
            frequency = 2 * pi * periods_number / number_of_points;

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
                    % Fill Y array by selected signal type
                    if (app.SignalTypeDropDown.Value == "Harmonic (Sinusoidal)")
                        y(i) = sin(frequency * i);
                    elseif (app.SignalTypeDropDown.Value == "Sawtooth")
                        y(i) = sawtooth(frequency * i);
                    elseif (app.SignalTypeDropDown.Value == "Triangular")
                        y(i) = sawtooth(frequency * i, 0.5);
                    elseif (app.SignalTypeDropDown.Value == "Rectangular Pulses")
                        y(i) = square(frequency * i);
                    elseif (app.SignalTypeDropDown.Value == "f(x) = abs(sin(x))")
                        y(i) = abs(sin(frequency * i));
                    end
                    y(i) = y(i) * signal_aplitude;
                    y(i) = y(i) + noise(i);
                end

                % Accumulate results
                y_accumulated = y_accumulated + y;
            end

            % Normalize the accumulated results
            y_accumulated = y_accumulated / number_of_accumulations;

            % Draw graph in axes object
            plot(app.UIAxes, x, y_accumulated, 'r');














            Sa0 = sum(y_accumulated) / number_of_points; %вычисленный коэф. a0/2












            y = zeros(1,number_of_points);
            Sa = zeros(1,K);
            Sb = zeros(1,K);
            
            % Показатель степени функции t^p
            p=4;

            f=y_accumulated;


            for i=1:number_of_points
                for j=1:K
                    Sa(j) = (Sa(j)+f(i)*cos((j)*2*pi*(i-1-number_of_points/2)/number_of_points));
                    Sb(j) = (Sb(j)+f(i)*sin((j)*2*pi*(i-1-number_of_points/2)/number_of_points));
                end
            
            end
            for j=1:K
                Sa(j)=Sa(j)*(1/(number_of_points/2));
                Sb(j)=Sb(j)*(1/(number_of_points/2));
                % Saa(j)= 4*(-1)^j/(j^2);%теоретически определенный коэф. аk для функции t^2
            end
            %SSaa=Saa %теоретически определенные коэф. аk для функции t^2
            % i=1:K;
            % figure
            % plot(i,Sa);
            % title('Коэффициенты Sa');
            
            
            %Вычисление и отображение спектра амплитуд (начало)
            %%%for j=1:K
            %%%    Sab(j)=sqrt(Sa(j)^2+Sb(j)^2);
            %%%end
            %%%K1=K;
            %%%i=1:K1;
            %%%figure
            %%%plot(i,Sab(i));
            %%%stem(Sab(1:K1)); %вывод графика  дискретной последовательности данных
            %%%axis([1 8 -0.2 1.2]);%задание осей: [xmin xmax ymin ymax]
            %%%title('Амплитуды частотных составляющих спектра');
            %%%xlabel('Количество периодов')
            %%%axis tight;



            %Вычисление и отображение спектра амплитуд (конец)
            y=zeros(1,number_of_points);
            for i=1:number_of_points
                for j=1:K
                    y(i)= y(i)+Sa(j)*cos(j*2*pi*(i-1-number_of_points/2)/number_of_points)+Sb(j)*sin(j*2*pi*(i-1-number_of_points/2)/number_of_points); %%%%%%%%
                end
                  y(i)=(Sa0+y(i));
            end
            i=1:number_of_points;
            %%%figure
            %%%hold on;
            %%%plot(i,y, 'g');
            %%%axis tight;
            %%% hold off;
            hold(app.UIAxes,'on');
            plot(app.UIAxes, i, y, 'b');
            hold(app.UIAxes,'off');
            
            for i=2:number_of_points
              dy(i)=y(i)-f(i);%абсолютная погрешность восстановления
            end
            dy_proc=dy/(max(f)-min(f))*100;
            CKO=std(dy);
            CKO_proc=std(dy_proc)%СКО в процентах
            
            % Add new row to the table
            app.TableData = [app.TableData; K CKO_proc];

            % Sort values to make sure they are ascending
            app.TableData = sortrows(app.TableData);
            
            % Redraw table chart
            app.UpdateTableChart();
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
        end

        % Value changed function: NumberOfPointsNEditField
        function NumberOfPointsNEditFieldValueChanged(app, event)
            app.UpdateMaxLimit();
        end

        % Value changed function: PeriodsNumberkpEditField
        function PeriodsNumberkpEditFieldValueChanged(app, event)
            app.UpdateMinLimit();
        end

        % Button pushed function: ClearTableButton
        function ClearTableButtonPushed(app, event)
            app.TableData = [];
            app.UpdateTableChart();
        end
    end

    % Component initialization
    methods (Access = private)

        % Create UIFigure and components
        function createComponents(app)

            % Create ModelSignalGeneratorUIFigure and hide until all components are created
            app.ModelSignalGeneratorUIFigure = uifigure('Visible', 'off');
            app.ModelSignalGeneratorUIFigure.Position = [100 100 1256 493];
            app.ModelSignalGeneratorUIFigure.Name = 'Model Signal Generator';

            % Create UIAxes
            app.UIAxes = uiaxes(app.ModelSignalGeneratorUIFigure);
            xlabel(app.UIAxes, 'N')
            ylabel(app.UIAxes, 'S')
            zlabel(app.UIAxes, 'Z')
            app.UIAxes.Position = [201 74 410 333];

            % Create UIAxes_2
            app.UIAxes_2 = uiaxes(app.ModelSignalGeneratorUIFigure);
            xlabel(app.UIAxes_2, 'K')
            ylabel(app.UIAxes_2, 'SKO')
            zlabel(app.UIAxes_2, 'Z')
            app.UIAxes_2.Position = [806 78 410 360];

            % Create GenerateButton
            app.GenerateButton = uibutton(app.ModelSignalGeneratorUIFigure, 'push');
            app.GenerateButton.ButtonPushedFcn = createCallbackFcn(app, @GenerateButtonPushed, true);
            app.GenerateButton.BackgroundColor = [0.9137 1 0.8];
            app.GenerateButton.Position = [411 26 93 23];
            app.GenerateButton.Text = 'Generate';

            % Create QuitButton
            app.QuitButton = uibutton(app.ModelSignalGeneratorUIFigure, 'push');
            app.QuitButton.ButtonPushedFcn = createCallbackFcn(app, @QuitButtonPushed, true);
            app.QuitButton.BackgroundColor = [1 0.8588 0.8588];
            app.QuitButton.Position = [518 26 91 23];
            app.QuitButton.Text = 'Quit';

            % Create PeriodsNumberLabel
            app.PeriodsNumberLabel = uilabel(app.ModelSignalGeneratorUIFigure);
            app.PeriodsNumberLabel.HorizontalAlignment = 'right';
            app.PeriodsNumberLabel.Position = [47 131 119 22];
            app.PeriodsNumberLabel.Text = 'Periods Number (kp):';

            % Create PeriodsNumberkpEditField
            app.PeriodsNumberkpEditField = uieditfield(app.ModelSignalGeneratorUIFigure, 'numeric');
            app.PeriodsNumberkpEditField.ValueDisplayFormat = '%9.1f';
            app.PeriodsNumberkpEditField.ValueChangedFcn = createCallbackFcn(app, @PeriodsNumberkpEditFieldValueChanged, true);
            app.PeriodsNumberkpEditField.HorizontalAlignment = 'center';
            app.PeriodsNumberkpEditField.Position = [28 110 155 22];
            app.PeriodsNumberkpEditField.Value = 4.5;

            % Create NoiseSKOLabel
            app.NoiseSKOLabel = uilabel(app.ModelSignalGeneratorUIFigure);
            app.NoiseSKOLabel.HorizontalAlignment = 'right';
            app.NoiseSKOLabel.Enable = 'off';
            app.NoiseSKOLabel.Position = [68 194 68 22];
            app.NoiseSKOLabel.Text = 'Noise SKO:';

            % Create NoiseSKOEditField
            app.NoiseSKOEditField = uieditfield(app.ModelSignalGeneratorUIFigure, 'numeric');
            app.NoiseSKOEditField.ValueDisplayFormat = '%9.1f';
            app.NoiseSKOEditField.HorizontalAlignment = 'center';
            app.NoiseSKOEditField.Enable = 'off';
            app.NoiseSKOEditField.Position = [28 173 155 22];
            app.NoiseSKOEditField.Value = 0.1;

            % Create SignalAmplitudeLabel
            app.SignalAmplitudeLabel = uilabel(app.ModelSignalGeneratorUIFigure);
            app.SignalAmplitudeLabel.HorizontalAlignment = 'right';
            app.SignalAmplitudeLabel.Position = [54 309 98 22];
            app.SignalAmplitudeLabel.Text = 'Signal Amplitude:';

            % Create SignalAmplitudeEditField
            app.SignalAmplitudeEditField = uieditfield(app.ModelSignalGeneratorUIFigure, 'numeric');
            app.SignalAmplitudeEditField.ValueDisplayFormat = '%9.1f';
            app.SignalAmplitudeEditField.HorizontalAlignment = 'center';
            app.SignalAmplitudeEditField.Position = [28 288 155 22];
            app.SignalAmplitudeEditField.Value = 1;

            % Create NoiseTypeLabel
            app.NoiseTypeLabel = uilabel(app.ModelSignalGeneratorUIFigure);
            app.NoiseTypeLabel.HorizontalAlignment = 'right';
            app.NoiseTypeLabel.Position = [70 252 68 22];
            app.NoiseTypeLabel.Text = 'Noise Type:';

            % Create NoiseTypeDropDown
            app.NoiseTypeDropDown = uidropdown(app.ModelSignalGeneratorUIFigure);
            app.NoiseTypeDropDown.Items = {'None', 'Normally Distributed', 'White Gaussian Noise'};
            app.NoiseTypeDropDown.ValueChangedFcn = createCallbackFcn(app, @NoiseTypeDropDownValueChanged, true);
            app.NoiseTypeDropDown.Position = [28 231 155 22];
            app.NoiseTypeDropDown.Value = 'None';

            % Create NumberOfPointsLabel
            app.NumberOfPointsLabel = uilabel(app.ModelSignalGeneratorUIFigure);
            app.NumberOfPointsLabel.HorizontalAlignment = 'right';
            app.NumberOfPointsLabel.Position = [45 359 124 22];
            app.NumberOfPointsLabel.Text = 'Number Of Points (N):';

            % Create NumberOfPointsNEditField
            app.NumberOfPointsNEditField = uieditfield(app.ModelSignalGeneratorUIFigure, 'numeric');
            app.NumberOfPointsNEditField.RoundFractionalValues = 'on';
            app.NumberOfPointsNEditField.ValueDisplayFormat = '%.0f';
            app.NumberOfPointsNEditField.ValueChangedFcn = createCallbackFcn(app, @NumberOfPointsNEditFieldValueChanged, true);
            app.NumberOfPointsNEditField.HorizontalAlignment = 'center';
            app.NumberOfPointsNEditField.Position = [28 338 155 22];
            app.NumberOfPointsNEditField.Value = 1024;

            % Create SignalTypeLabel
            app.SignalTypeLabel = uilabel(app.ModelSignalGeneratorUIFigure);
            app.SignalTypeLabel.HorizontalAlignment = 'right';
            app.SignalTypeLabel.Position = [68 416 71 22];
            app.SignalTypeLabel.Text = 'Signal Type:';

            % Create SignalTypeDropDown
            app.SignalTypeDropDown = uidropdown(app.ModelSignalGeneratorUIFigure);
            app.SignalTypeDropDown.Items = {'Harmonic (Sinusoidal)', 'Sawtooth', 'Triangular', 'Rectangular Pulses', 'f(x) = abs(sin(x))'};
            app.SignalTypeDropDown.Position = [28 395 155 22];
            app.SignalTypeDropDown.Value = 'Harmonic (Sinusoidal)';

            % Create ModelSignalGeneratorLabel
            app.ModelSignalGeneratorLabel = uilabel(app.ModelSignalGeneratorUIFigure);
            app.ModelSignalGeneratorLabel.HorizontalAlignment = 'center';
            app.ModelSignalGeneratorLabel.FontSize = 24;
            app.ModelSignalGeneratorLabel.Position = [2 448 1255 31];
            app.ModelSignalGeneratorLabel.Text = 'Model Signal Generator';

            % Create NumberOfAccumulationsLabel
            app.NumberOfAccumulationsLabel = uilabel(app.ModelSignalGeneratorUIFigure);
            app.NumberOfAccumulationsLabel.HorizontalAlignment = 'right';
            app.NumberOfAccumulationsLabel.Position = [240 48 148 22];
            app.NumberOfAccumulationsLabel.Text = 'Number Of Accumulations:';

            % Create NumberOfAccumulationsEditField
            app.NumberOfAccumulationsEditField = uieditfield(app.ModelSignalGeneratorUIFigure, 'numeric');
            app.NumberOfAccumulationsEditField.RoundFractionalValues = 'on';
            app.NumberOfAccumulationsEditField.ValueDisplayFormat = '%.0f';
            app.NumberOfAccumulationsEditField.HorizontalAlignment = 'center';
            app.NumberOfAccumulationsEditField.Position = [237 27 155 22];
            app.NumberOfAccumulationsEditField.Value = 1;

            % Create ThenumberofFourierseriestermsKkpKN4Label
            app.ThenumberofFourierseriestermsKkpKN4Label = uilabel(app.ModelSignalGeneratorUIFigure);
            app.ThenumberofFourierseriestermsKkpKN4Label.HorizontalAlignment = 'center';
            app.ThenumberofFourierseriestermsKkpKN4Label.WordWrap = 'on';
            app.ThenumberofFourierseriestermsKkpKN4Label.Position = [22 51 166 30];
            app.ThenumberofFourierseriestermsKkpKN4Label.Text = 'The number of Fourier series terms (K, kp <= K <= N/4):';

            % Create TheNumberOfFourierSeriesTermsEditField
            app.TheNumberOfFourierSeriesTermsEditField = uieditfield(app.ModelSignalGeneratorUIFigure, 'numeric');
            app.TheNumberOfFourierSeriesTermsEditField.RoundFractionalValues = 'on';
            app.TheNumberOfFourierSeriesTermsEditField.ValueDisplayFormat = '%.0f';
            app.TheNumberOfFourierSeriesTermsEditField.HorizontalAlignment = 'center';
            app.TheNumberOfFourierSeriesTermsEditField.Position = [73 27 66 22];
            app.TheNumberOfFourierSeriesTermsEditField.Value = 128;

            % Create TheNumberOfFourierSeriesTermsEditFieldLabelKMin
            app.TheNumberOfFourierSeriesTermsEditFieldLabelKMin = uilabel(app.ModelSignalGeneratorUIFigure);
            app.TheNumberOfFourierSeriesTermsEditFieldLabelKMin.HorizontalAlignment = 'right';
            app.TheNumberOfFourierSeriesTermsEditFieldLabelKMin.WordWrap = 'on';
            app.TheNumberOfFourierSeriesTermsEditFieldLabelKMin.Position = [21 27 46 22];
            app.TheNumberOfFourierSeriesTermsEditFieldLabelKMin.Text = '2 <=';

            % Create TheNumberOfFourierSeriesTermsEditFieldLabelKMax
            app.TheNumberOfFourierSeriesTermsEditFieldLabelKMax = uilabel(app.ModelSignalGeneratorUIFigure);
            app.TheNumberOfFourierSeriesTermsEditFieldLabelKMax.WordWrap = 'on';
            app.TheNumberOfFourierSeriesTermsEditFieldLabelKMax.Position = [143 28 59 22];
            app.TheNumberOfFourierSeriesTermsEditFieldLabelKMax.Text = '<= 256';

            % Create UITable
            app.UITable = uitable(app.ModelSignalGeneratorUIFigure);
            app.UITable.ColumnName = {'K'; 'SKO'};
            app.UITable.RowName = {};
            app.UITable.Position = [634 152 157 269];

            % Create ClearTableButton
            app.ClearTableButton = uibutton(app.ModelSignalGeneratorUIFigure, 'push');
            app.ClearTableButton.ButtonPushedFcn = createCallbackFcn(app, @ClearTableButtonPushed, true);
            app.ClearTableButton.BackgroundColor = [1 0.9059 0.6784];
            app.ClearTableButton.Position = [633 110 157 23];
            app.ClearTableButton.Text = 'Clear table';

            % Create SignalLabel
            app.SignalLabel = uilabel(app.ModelSignalGeneratorUIFigure);
            app.SignalLabel.BackgroundColor = [1 1 1];
            app.SignalLabel.FontColor = [1 0 0];
            app.SignalLabel.Position = [288 415 38 22];
            app.SignalLabel.Text = 'Signal';

            % Create FourierLabel
            app.FourierLabel = uilabel(app.ModelSignalGeneratorUIFigure);
            app.FourierLabel.BackgroundColor = [1 1 1];
            app.FourierLabel.FontColor = [0 0 1];
            app.FourierLabel.Position = [381 415 43 22];
            app.FourierLabel.Text = 'Fourier';

            % Create FouriercomplexLabel
            app.FouriercomplexLabel = uilabel(app.ModelSignalGeneratorUIFigure);
            app.FouriercomplexLabel.BackgroundColor = [1 1 1];
            app.FouriercomplexLabel.FontColor = [1 0 1];
            app.FouriercomplexLabel.Position = [469 415 99 22];
            app.FouriercomplexLabel.Text = 'Fourier (complex)';

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
