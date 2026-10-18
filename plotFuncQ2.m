function plotFuncQ2(app)

%% Reads the data
censusTract = readcell('CensusTract_Data.xlsx');

%% Variable assignment
lBound = app.MinimumIncomeEditField.Value;
hBound = app.MaximumIncomeEditField.Value;

incomeCol = 40;   % SE_A14006_001
totalHousingCol = 42;   % SE_A10060_001
totalOwnerCol = 43;   % SE_A10060_002
raceTotalCol = 23;   % SE_A03001_001
raceBlackCol = 25;   % SE_A03001_003
raceWhiteCol = 24;   % SE_A03001_002
raceAsianCol = 27;   % SE_A03001_005
racePICol  = 28;   % SE_A03001_006
raceOtherCol = 29;   % SE_A03001_007

%% Extract numeric data
incomeData = cell2mat(censusTract(2:end, incomeCol));
ownerData = cell2mat(censusTract(2:end, totalOwnerCol));
totalHousingData = cell2mat(censusTract(2:end, totalHousingCol));

minIncomeData = min(incomeData);
maxIncomeData = max(incomeData);

%% CHECK 1: income range validity
invalidRange = 0;

if lBound > maxIncomeData
    invalidRange = 1;
elseif hBound < minIncomeData
    invalidRange = 1;
end

if invalidRange == 1

    uialert(app.UIFigure, ...
        "Income range is outside dataset bounds (" + ...
        string(minIncomeData) + " to " + string(maxIncomeData) + ").", ...
        "Range Error");

    cla(app.UIAxes2);
    legend(app.UIAxes2, 'off');
    title(app.UIAxes2, ' ');

else

    %% CHECK 2: must select at least TWO races
    selectedRaces = [
        app.BlackCheckBox.Value,
        app.WhiteCheckBox.Value,
        app.AsianCheckBox.Value,
        app.PacificIslanderCheckBox.Value,
        app.OtherRaceCheckBox.Value
        ];

    countSelected = 0;
    for i = 1:5
        if selectedRaces(i) == 1
            countSelected = countSelected + 1;
        end
    end

    if countSelected < 2

        uialert(app.UIFigure, ...
            "Please select at least TWO race categories to display the chart.", ...
            "Selection Error");

        cla(app.UIAxes2);
        legend(app.UIAxes2, 'off');
        title(app.UIAxes2, ' ');

    else

        %% Filter income range
        validMask = (incomeData >= lBound) & (incomeData <= hBound);
        rangeIncome = incomeData(validMask);

        if length(rangeIncome) > 0

            %% Find max/min income tracts
            [maxIncome, idxMax] = max(rangeIncome);
            [minIncome, idxMin] = min(rangeIncome);

            validRows = find(validMask);
            rowMax = validRows(idxMax);
            rowMin = validRows(idxMin);

            %% Ownership %
            maxOwnership = ownerData(rowMax) / totalHousingData(rowMax) * 100;
            minOwnership = ownerData(rowMin) / totalHousingData(rowMin) * 100;

            %% Race setup
            raceCols = [raceBlackCol, raceWhiteCol, raceAsianCol, racePICol, raceOtherCol];
            races = {'Black', 'White', 'Asian', 'Pacific Islander', 'Other Race'};

            %% Build bar data
            y = [];
            labels = {};

            for ix = 1:5
                if selectedRaces(ix) == 1
                    raceDataNum = cell2mat(censusTract(2:end, raceCols(ix)));
                    valMax = raceDataNum(rowMax);
                    valMin = raceDataNum(rowMin);
                    y = [y; [valMax, valMin]];
                    labels = [labels, races(ix)];
                end
            end

            %% Plot
            b = bar(app.UIAxes2, y);

            b(2).FaceColor = [0, 0.4470, 0.7410];
            b(1).FaceColor = [0.929, 0.694, 0.125];

            titleString = "Tract " + (rowMax + 1) + ...
                " (" + num2str(maxOwnership, 3) + "% owned) Vs " + ...
                "Tract " + (rowMin + 1) + ...
                " (" + num2str(minOwnership, 3) + "% owned)";

            title(app.UIAxes2, titleString, "Color", "black");

            app.UIAxes2.XTickLabel = labels;
            ylabel(app.UIAxes2, 'Number of Individuals');

            legend(app.UIAxes2, ...
                {['Max Income: ', num2str(maxIncome)], ...
                ['Min Income: ', num2str(minIncome)]});

        else

            uialert(app.UIFigure, ...
                "No tracts found in this income range. Please widen the range (data goes from " + ...
                string(minIncomeData) + " to " + string(maxIncomeData) + ").", ...
                "Income Range Error");

            cla(app.UIAxes2);
            legend(app.UIAxes2, 'off');
            title(app.UIAxes2, ' ');

        end
    end
end

end