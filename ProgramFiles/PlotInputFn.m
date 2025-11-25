function [] = PlotInputFn(problemToDraw)

f1 = figure;

parts = split(problemToDraw,"_");

if numel(parts) ~= 2
    error("Bad input: problemToDraw must contain exactly one '_' (e.g. Hertz_Plastic, Lamalea_1)");
end

mainName = parts(1);
subName  = parts(2);

dataFile = fullfile("Problem_Input_Data", mainName + "_Struct" + ".mat");
if ~isfile(dataFile)
    error("Data file not found: %s", dataFile);
end

S = load(dataFile);
fn = fieldnames(S);
dataCell = S.(fn{1});   % očekáváme, že je to cell array

% --- Urči index podle subName
if mainName == "Lamalea"
    idx = str2double(subName);
elseif mainName == "Hertz"
    switch subName
        case "Elastic"
            idx = 1;
        case "Plastic"
            idx = 2;
        otherwise
            error("Unknown Hertz subName: %s", subName);
    end
else
    error("Unknown mainName: %s", mainName);
end

problemStruct = dataCell{idx};

nBodies     = length(problemStruct.bodies);
bodyColors  = lines(nBodies);  
colorMap    = lines(50);        
colorIndex  = 1;
allHandles  = [];
allLegends  = {};

ax1 = subplot(2,1,1);
hold(ax1,"on")
for i = 1:nBodies
    [hs, mylegends, colorIndex] = PlotBody2D(problemStruct.bodies{i}, bodyColors(i,:), colorMap, colorIndex);
    allHandles = [allHandles, hs];
    allLegends = [allLegends, mylegends];
end
legend(ax1, allHandles, allLegends, 'FontSize', PlotSetting.FontSize);
axis(ax1,'equal')

ax2 = subplot(2,1,2);
PlotMaterial(problemStruct.bodies, ax2, bodyColors);
hold off

end
