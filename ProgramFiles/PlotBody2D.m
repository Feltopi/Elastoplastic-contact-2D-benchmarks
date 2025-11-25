function [hs, mylegends, colorIndex] = PlotBody2D(body, bodyColor, colorMap, colorIndex)
hold on

mymarkers = {'+','o','*','x','v','d','^','s','>','<'};
coordinates = body.coordinates';
hs = [];
mylegends = {};

% --- barva těla (světlejší pro plošky)
faceColor = bodyColor + (1-bodyColor)*0.8;

if isfield(body, "elements") && ~isempty(body.elements)
    for e = 1:numel(body.elements)
        el = body.elements{e};
        if isfield(el, "nodes") && ~isempty(el.nodes)
            hs(end+1) = patch('Faces', el.nodes', ...
                              'Vertices', coordinates', ...
                              'FaceColor', faceColor, ...
                              'EdgeColor', [0.3 0.3 0.3]);
        end
    end
end

% legenda pro body
mylegends{end+1} = strjoin(string(body.name)," ");

% --- Surfaces (mají vlastní barvy z colorMap)
for i=1:length(body.surfaces)
    mysurface = body.surfaces{i};
    c = colorMap(colorIndex,:);
    colorIndex = colorIndex + 1;

    hs(end+1) = plot(coordinates(1,mysurface.nodes), ...
        coordinates(2,mysurface.nodes), ...
        'o','Color',c,...
        'LineWidth',1.5,'Marker',mymarkers{mod(i-1,length(mymarkers))+1});

    mylegends{end+1} = append(num2str(i),': ',mysurface.name);

    if isfield(mysurface, 'elements') && ~isempty(mysurface.elements)
    for e = 1:numel(mysurface.elements)
        el = mysurface.elements{e};
        if isfield(el, 'nodes') && ~isempty(el.nodes)
            segs = el.nodes;
            for j = 1:size(segs,1)
                plot(coordinates(1,segs(j,:)), coordinates(2,segs(j,:)), ...
                     '-', 'Color', c, 'LineWidth', 1.8);
            end
        end
    end
end
end

set(gca,'FontSize',PlotSetting.FontSize)
axis equal
end
