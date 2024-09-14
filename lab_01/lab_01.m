
classdef lab_01 < matlab.apps.AppBase

    % Properties that correspond to app components
    properties (Access = public)
        UIFigure                        matlab.ui.Figure
        NumberOfAccumulationsEditField  matlab.ui.control.NumericEditField
        NumberOfAccumulationsLabel      matlab.ui.control.Label
        ModelSignalGeneratorLabel       matlab.ui.control.Label
        SignalTypeDropDown              matlab.ui.control.DropDown
        SignalTypeLabel                 matlab.ui.control.Label
        NumberOfPointsEditField         matlab.ui.control.NumericEditField
        NumberOfPointsLabel             matlab.ui.control.Label
        NoiseTypeDropDown               matlab.ui.control.DropDown
        NoiseTypeLabel                  matlab.ui.control.Label
        SignalAmplitudeEditField        matlab.ui.control.NumericEditField
        SignalAmplitudeLabel            matlab.ui.control.Label
        NoiseSKOEditField               matlab.ui.control.NumericEditField
        NoiseSKOLabel                   matlab.ui.control.Label
        PeriodsNumberEditField          matlab.ui.control.NumericEditField
        PeriodsNumberLabel              matlab.ui.control.Label
        QuitButton                      matlab.ui.control.Button
        StartButton                     matlab.ui.control.Button
        UIAxes                          matlab.ui.control.UIAxes
    end

    % Callbacks that handle component events
    methods (Access = private)

        % Code that executes after component creation
        function startupFcn(app)
            writelines(evalc('type(mfilename(''fullpath'') + ".mlapp")'), mfilename('fullpath') + ".m");
        end

        % Button pushed function: QuitButton
        function QuitButtonPushed(app, event)
            % Close the app
            app.delete();
        end

        % Button pushed function: StartButton
        function StartButtonPushed(app, event)
            periods_number = app.PeriodsNumberEditField.Value;
            number_of_points = app.NumberOfPointsEditField.Value;
            noise_sko = app.NoiseSKOEditField.Value;
            signal_aplitude = app.SignalAmplitudeEditField.Value;
            number_of_accumulations = app.NumberOfAccumulationsEditField.Value;

            % Create X array
            x = 1:number_of_points;

            % Create Y array
            y_accumulated = 1:number_of_points;
            for i = x
                y_accumulated(i) = 0;
            end

            for iteration = 1:number_of_accumulations
                % Create Y array
                y = 1:number_of_points;
                for i = x
                    % Fill Y array by selected signal type
                    if (app.SignalTypeDropDown.Value == "Harmonic (Sinusoidal)")
                        y(i) = sin(2 * pi * i * periods_number / 1000);
                    elseif (app.SignalTypeDropDown.Value == "Sawtooth")
                        y(i) = sawtooth(2 * pi * i * periods_number / 1000);
                    elseif (app.SignalTypeDropDown.Value == "Triangular")
                        y(i) = sawtooth(2 * pi * i * periods_number / 1000, 0.5);
                    elseif (app.SignalTypeDropDown.Value == "Rectangular Pulses")
                        y(i) = square(2 * pi * i * periods_number / 1000);
                    end
                end
    
                % Amplify signal
                for i = x
                    y(i) = y(i) * signal_aplitude;
                end
    
                % Generate noise
                if (app.NoiseTypeDropDown.Value == "Normally Distributed")
                    noise = randn(number_of_points);
                elseif (app.NoiseTypeDropDown.Value == "White Gaussian Noise")
                    noise = wgn(number_of_points, 1, 0);
                end
                for i = x
                    y(i) = y(i) + (noise_sko * noise(i));
                end

                % Accumulate results
                for i = x
                    y_accumulated(i) = y_accumulated(i) + y(i);
                end
            end

            % Accumulate results
            for i = x
                y_accumulated(i) = y_accumulated(i) / number_of_accumulations;
            end

            % Draw graph in axes object
            plot(app.UIAxes, x, y_accumulated);
        end
    end

    % Component initialization
    methods (Access = private)

        % Create UIFigure and components
        function createComponents(app)

            % Create UIFigure and hide until all components are created
            app.UIFigure = uifigure('Visible', 'off');
            app.UIFigure.Position = [100 100 631 496];
            app.UIFigure.Name = 'MATLAB App';

            % Create UIAxes
            app.UIAxes = uiaxes(app.UIFigure);
            xlabel(app.UIAxes, 'X')
            ylabel(app.UIAxes, 'Y')
            zlabel(app.UIAxes, 'Z')
            app.UIAxes.Position = [201 77 410 360];

            % Create StartButton
            app.StartButton = uibutton(app.UIFigure, 'push');
            app.StartButton.ButtonPushedFcn = createCallbackFcn(app, @StartButtonPushed, true);
            app.StartButton.BackgroundColor = [0.9137 1 0.8];
            app.StartButton.Position = [299 30 100 23];
            app.StartButton.Text = 'Start';

            % Create QuitButton
            app.QuitButton = uibutton(app.UIFigure, 'push');
            app.QuitButton.ButtonPushedFcn = createCallbackFcn(app, @QuitButtonPushed, true);
            app.QuitButton.BackgroundColor = [1 0.8588 0.8588];
            app.QuitButton.Position = [446 30 100 23];
            app.QuitButton.Text = 'Quit';

            % Create PeriodsNumberLabel
            app.PeriodsNumberLabel = uilabel(app.UIFigure);
            app.PeriodsNumberLabel.HorizontalAlignment = 'right';
            app.PeriodsNumberLabel.Position = [56 134 95 22];
            app.PeriodsNumberLabel.Text = 'Periods Number:';

            % Create PeriodsNumberEditField
            app.PeriodsNumberEditField = uieditfield(app.UIFigure, 'numeric');
            app.PeriodsNumberEditField.ValueDisplayFormat = '%9.1f';
            app.PeriodsNumberEditField.HorizontalAlignment = 'center';
            app.PeriodsNumberEditField.Position = [28 113 155 22];
            app.PeriodsNumberEditField.Value = 2;

            % Create NoiseSKOLabel
            app.NoiseSKOLabel = uilabel(app.UIFigure);
            app.NoiseSKOLabel.HorizontalAlignment = 'right';
            app.NoiseSKOLabel.Position = [68 197 68 22];
            app.NoiseSKOLabel.Text = 'Noise SKO:';

            % Create NoiseSKOEditField
            app.NoiseSKOEditField = uieditfield(app.UIFigure, 'numeric');
            app.NoiseSKOEditField.ValueDisplayFormat = '%9.1f';
            app.NoiseSKOEditField.HorizontalAlignment = 'center';
            app.NoiseSKOEditField.Position = [28 176 155 22];
            app.NoiseSKOEditField.Value = 0.1;

            % Create SignalAmplitudeLabel
            app.SignalAmplitudeLabel = uilabel(app.UIFigure);
            app.SignalAmplitudeLabel.HorizontalAlignment = 'right';
            app.SignalAmplitudeLabel.Position = [54 312 98 22];
            app.SignalAmplitudeLabel.Text = 'Signal Amplitude:';

            % Create SignalAmplitudeEditField
            app.SignalAmplitudeEditField = uieditfield(app.UIFigure, 'numeric');
            app.SignalAmplitudeEditField.ValueDisplayFormat = '%9.1f';
            app.SignalAmplitudeEditField.HorizontalAlignment = 'center';
            app.SignalAmplitudeEditField.Position = [28 291 155 22];
            app.SignalAmplitudeEditField.Value = 1;

            % Create NoiseTypeLabel
            app.NoiseTypeLabel = uilabel(app.UIFigure);
            app.NoiseTypeLabel.HorizontalAlignment = 'right';
            app.NoiseTypeLabel.Position = [70 255 68 22];
            app.NoiseTypeLabel.Text = 'Noise Type:';

            % Create NoiseTypeDropDown
            app.NoiseTypeDropDown = uidropdown(app.UIFigure);
            app.NoiseTypeDropDown.Items = {'Normally Distributed', 'White Gaussian Noise'};
            app.NoiseTypeDropDown.Position = [28 234 155 22];
            app.NoiseTypeDropDown.Value = 'Normally Distributed';

            % Create NumberOfPointsLabel
            app.NumberOfPointsLabel = uilabel(app.UIFigure);
            app.NumberOfPointsLabel.HorizontalAlignment = 'right';
            app.NumberOfPointsLabel.Position = [51 362 104 22];
            app.NumberOfPointsLabel.Text = 'Number Of Points:';

            % Create NumberOfPointsEditField
            app.NumberOfPointsEditField = uieditfield(app.UIFigure, 'numeric');
            app.NumberOfPointsEditField.ValueDisplayFormat = '%.0f';
            app.NumberOfPointsEditField.HorizontalAlignment = 'center';
            app.NumberOfPointsEditField.Position = [28 341 155 22];
            app.NumberOfPointsEditField.Value = 1024;

            % Create SignalTypeLabel
            app.SignalTypeLabel = uilabel(app.UIFigure);
            app.SignalTypeLabel.HorizontalAlignment = 'right';
            app.SignalTypeLabel.Position = [68 419 71 22];
            app.SignalTypeLabel.Text = 'Signal Type:';

            % Create SignalTypeDropDown
            app.SignalTypeDropDown = uidropdown(app.UIFigure);
            app.SignalTypeDropDown.Items = {'Harmonic (Sinusoidal)', 'Sawtooth', 'Triangular', 'Rectangular Pulses'};
            app.SignalTypeDropDown.Position = [28 398 155 22];
            app.SignalTypeDropDown.Value = 'Harmonic (Sinusoidal)';

            % Create ModelSignalGeneratorLabel
            app.ModelSignalGeneratorLabel = uilabel(app.UIFigure);
            app.ModelSignalGeneratorLabel.HorizontalAlignment = 'center';
            app.ModelSignalGeneratorLabel.FontSize = 24;
            app.ModelSignalGeneratorLabel.Position = [2 451 630 31];
            app.ModelSignalGeneratorLabel.Text = 'Model Signal Generator';

            % Create NumberOfAccumulationsLabel
            app.NumberOfAccumulationsLabel = uilabel(app.UIFigure);
            app.NumberOfAccumulationsLabel.HorizontalAlignment = 'right';
            app.NumberOfAccumulationsLabel.Position = [32 51 148 22];
            app.NumberOfAccumulationsLabel.Text = 'Number Of Accumulations:';

            % Create NumberOfAccumulationsEditField
            app.NumberOfAccumulationsEditField = uieditfield(app.UIFigure, 'numeric');
            app.NumberOfAccumulationsEditField.ValueDisplayFormat = '%.0f';
            app.NumberOfAccumulationsEditField.HorizontalAlignment = 'center';
            app.NumberOfAccumulationsEditField.Position = [29 30 155 22];
            app.NumberOfAccumulationsEditField.Value = 1;

            % Show the figure after all components are created
            app.UIFigure.Visible = 'on';
        end
    end

    % App creation and deletion
    methods (Access = public)

        % Construct app
        function app = lab_01

            % Create UIFigure and components
            createComponents(app)

            % Register the app with App Designer
            registerApp(app, app.UIFigure)

            % Execute the startup function
            runStartupFcn(app, @startupFcn)

            if nargout == 0
                clear app
            end
        end

        % Code that executes before app deletion
        function delete(app)

            % Delete UIFigure when app is deleted
            delete(app.UIFigure)
        end
    end
end
