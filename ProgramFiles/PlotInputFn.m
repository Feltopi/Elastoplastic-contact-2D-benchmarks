function [] = PlotInputFn(problemToDraw,version)

f1 = figure;

parts = split(problemToDraw,"_");
mainName = parts(1);

if mainName == "Hertz"

    subName  = parts(2);
    fullName = "input_" + mainName + "_" + subName + ".mat";

    dataFile = fullfile("Problem_Input_Data", fullName);
    if ~isfile(dataFile)
        error("Data file not found: %s", dataFile);
    end

    S = load(dataFile);
    fn = fieldnames(S);
    problemStruct = S.(fn{1});
    problemStruct = problemStruct{version};

elseif mainName == "IPE"

    dataFile = fullfile("Problem_Input_Data", "input_IPE.mat");
    if ~isfile(dataFile)
        error("Data file not found: %s", dataFile);
    end

    S = load(dataFile);
    fn = fieldnames(S);
    problemStruct = S.(fn{1});

    % enforce exactly one version
    if iscell(problemStruct)
        problemStruct = problemStruct{1};
    end

else

    baseName = "input_" + mainName;

    perChunk = 4;
    chunkID = ceil(version / perChunk);
    localIdx = version - (chunkID-1)*perChunk;

    fullName = sprintf("%s_part%d.mat", baseName, chunkID);
    dataFile = fullfile("Problem_Input_Data", fullName);

    if ~isfile(dataFile)
        error("Data file not found: %s", dataFile);
    end

    S = load(dataFile);
    fn = fieldnames(S);
    chunk = S.(fn{1});
    problemStruct = chunk{localIdx};

end


nBodies     = length(problemStruct.problem.bodies);
bodyColors  = lines(nBodies);
colorMap    = lines(50);
colorIndex  = 1;
allHandles  = [];
allLegends  = {};

ax1 = subplot(2,1,1);
hold(ax1,"on")

for i = 1:nBodies
    [hs, mylegends, colorIndex] = PlotBody2D(problemStruct,i, bodyColors(i,:), colorMap, colorIndex);
    allHandles = [allHandles, hs];
    allLegends = [allLegends, mylegends];
end

legend(ax1, allHandles, allLegends, 'FontSize', PlotSetting.FontSize);
axis(ax1,'equal')

ax2 = subplot(2,1,2);
PlotMaterial(problemStruct.problem.bodies, ax2, bodyColors);

hold off
set(gcf,'Units','normalized','OuterPosition',[0 0 1 1]);

end
