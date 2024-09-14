
classdef lab_01 < matlab.apps.AppBase

    % Properties that correspond to app components
    properties (Access = public)
        UIFigure                       matlab.ui.Figure
        ModelsignalgeneratorLabel      matlab.ui.control.Label
        SignalTypeDropDown             matlab.ui.control.DropDown
        SignalTypeDropDownLabel        matlab.ui.control.Label
        NumberOfPointsEditField        matlab.ui.control.NumericEditField
        NumberOfPointsEditFieldLabel   matlab.ui.control.Label
        NoiseTypeDropDown              matlab.ui.control.DropDown
        NoiseTypeDropDownLabel         matlab.ui.control.Label
        SignalAmplitudeEditField       matlab.ui.control.NumericEditField
        SignalAmplitudeEditFieldLabel  matlab.ui.control.Label
        NoiseSKOEditField              matlab.ui.control.NumericEditField
        NoiseSKOEditFieldLabel         matlab.ui.control.Label
        PeriodsNumberEditField         matlab.ui.control.NumericEditField
        PeriodsNumberEditFieldLabel    matlab.ui.control.Label
        QuitButton                     matlab.ui.control.Button
        StartButton                    matlab.ui.control.Button
        UIAxes                         matlab.ui.control.UIAxes
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

            % Create X array
            x = 1:number_of_points;

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

            % Draw graph in axes object
            plot(app.UIAxes, x, y);
        end
    end

    % Component initialization
    methods (Access = private)

        % Create UIFigure and components
        function createComponents(app)

            % Create UIFigure and hide until all components are created
            app.UIFigure = uifigure('Visible', 'off');
            app.UIFigure.Position = [100 100 632 406];
            app.UIFigure.Name = 'MATLAB App';

            % Create UIAxes
            app.UIAxes = uiaxes(app.UIFigure);
            xlabel(app.UIAxes, 'X')
            ylabel(app.UIAxes, 'Y')
            zlabel(app.UIAxes, 'Z')
            app.UIAxes.Position = [16 65 410 286];

            % Create StartButton
            app.StartButton = uibutton(app.UIFigure, 'push');
            app.StartButton.ButtonPushedFcn = createCallbackFcn(app, @StartButtonPushed, true);
            app.StartButton.Position = [109 23 100 23];
            app.StartButton.Text = 'Start';

            % Create QuitButton
            app.QuitButton = uibutton(app.UIFigure, 'push');
            app.QuitButton.ButtonPushedFcn = createCallbackFcn(app, @QuitButtonPushed, true);
            app.QuitButton.Position = [262 23 100 23];
            app.QuitButton.Text = 'Quit';

            % Create PeriodsNumberEditFieldLabel
            app.PeriodsNumberEditFieldLabel = uilabel(app.UIFigure);
            app.PeriodsNumberEditFieldLabel.HorizontalAlignment = 'right';
            app.PeriodsNumberEditFieldLabel.Position = [485 44 92 22];
            app.PeriodsNumberEditFieldLabel.Text = 'Periods Number';

            % Create PeriodsNumberEditField
            app.PeriodsNumberEditField = uieditfield(app.UIFigure, 'numeric');
            app.PeriodsNumberEditField.ValueDisplayFormat = '%9.1f';
            app.PeriodsNumberEditField.HorizontalAlignment = 'center';
            app.PeriodsNumberEditField.Position = [454 23 155 22];
            app.PeriodsNumberEditField.Value = 2;

            % Create NoiseSKOEditFieldLabel
            app.NoiseSKOEditFieldLabel = uilabel(app.UIFigure);
            app.NoiseSKOEditFieldLabel.HorizontalAlignment = 'right';
            app.NoiseSKOEditFieldLabel.Position = [498 107 64 22];
            app.NoiseSKOEditFieldLabel.Text = 'Noise SKO';

            % Create NoiseSKOEditField
            app.NoiseSKOEditField = uieditfield(app.UIFigure, 'numeric');
            app.NoiseSKOEditField.ValueDisplayFormat = '%9.1f';
            app.NoiseSKOEditField.HorizontalAlignment = 'center';
            app.NoiseSKOEditField.Position = [454 86 155 22];
            app.NoiseSKOEditField.Value = 0.1;

            % Create SignalAmplitudeEditFieldLabel
            app.SignalAmplitudeEditFieldLabel = uilabel(app.UIFigure);
            app.SignalAmplitudeEditFieldLabel.HorizontalAlignment = 'right';
            app.SignalAmplitudeEditFieldLabel.Position = [484 222 94 22];
            app.SignalAmplitudeEditFieldLabel.Text = 'Signal Amplitude';

            % Create SignalAmplitudeEditField
            app.SignalAmplitudeEditField = uieditfield(app.UIFigure, 'numeric');
            app.SignalAmplitudeEditField.ValueDisplayFormat = '%9.1f';
            app.SignalAmplitudeEditField.HorizontalAlignment = 'center';
            app.SignalAmplitudeEditField.Position = [454 201 155 22];
            app.SignalAmplitudeEditField.Value = 1;

            % Create NoiseTypeDropDownLabel
            app.NoiseTypeDropDownLabel = uilabel(app.UIFigure);
            app.NoiseTypeDropDownLabel.HorizontalAlignment = 'right';
            app.NoiseTypeDropDownLabel.Position = [499 165 65 22];
            app.NoiseTypeDropDownLabel.Text = 'Noise Type';

            % Create NoiseTypeDropDown
            app.NoiseTypeDropDown = uidropdown(app.UIFigure);
            app.NoiseTypeDropDown.Items = {'Normally Distributed', 'White Gaussian Noise'};
            app.NoiseTypeDropDown.Position = [454 144 155 22];
            app.NoiseTypeDropDown.Value = 'Normally Distributed';

            % Create NumberOfPointsEditFieldLabel
            app.NumberOfPointsEditFieldLabel = uilabel(app.UIFigure);
            app.NumberOfPointsEditFieldLabel.HorizontalAlignment = 'right';
            app.NumberOfPointsEditFieldLabel.Position = [481 272 100 22];
            app.NumberOfPointsEditFieldLabel.Text = 'Number Of Points';

            % Create NumberOfPointsEditField
            app.NumberOfPointsEditField = uieditfield(app.UIFigure, 'numeric');
            app.NumberOfPointsEditField.ValueDisplayFormat = '%.0f';
            app.NumberOfPointsEditField.HorizontalAlignment = 'center';
            app.NumberOfPointsEditField.Position = [454 251 155 22];
            app.NumberOfPointsEditField.Value = 1024;

            % Create SignalTypeDropDownLabel
            app.SignalTypeDropDownLabel = uilabel(app.UIFigure);
            app.SignalTypeDropDownLabel.HorizontalAlignment = 'right';
            app.SignalTypeDropDownLabel.Position = [497 329 68 22];
            app.SignalTypeDropDownLabel.Text = 'Signal Type';

            % Create SignalTypeDropDown
            app.SignalTypeDropDown = uidropdown(app.UIFigure);
            app.SignalTypeDropDown.Items = {'Harmonic (Sinusoidal)', 'Sawtooth', 'Triangular', 'Rectangular Pulses'};
            app.SignalTypeDropDown.Position = [454 308 155 22];
            app.SignalTypeDropDown.Value = 'Harmonic (Sinusoidal)';

            % Create ModelsignalgeneratorLabel
            app.ModelsignalgeneratorLabel = uilabel(app.UIFigure);
            app.ModelsignalgeneratorLabel.FontSize = 24;
            app.ModelsignalgeneratorLabel.Position = [187 358 251 31];
            app.ModelsignalgeneratorLabel.Text = 'Model signal generator';

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
