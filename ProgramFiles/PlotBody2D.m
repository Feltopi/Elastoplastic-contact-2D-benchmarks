function [hs, mylegends, colorIndex] = PlotBody2D(problem,i, bodyColor, colorMap, colorIndex)
hold on

persistent markDirichlet markNeumann markMortar mortarStyles

if isempty(markDirichlet); markDirichlet = 1; end
if isempty(markNeumann);  markNeumann  = 1; end
if isempty(markMortar);   markMortar   = 1; end
if isempty(mortarStyles)
    mortarStyles = containers.Map('KeyType','int32','ValueType','any');
end

markers = {'+','o','*','x','v','d','^','s','>','<'};

body = problem.domains{i};
coordinates = body.coordinates';
hs = [];  % numeric array of handles
mylegends = strings(0);

mylegends(end+1) = "Body " + i;

faceColor = bodyColor + (1-bodyColor)*0.8;

%% Draw body elements
if isfield(body,"elements") && ~isempty(body.elements)
    for e = 1:numel(body.elements)
        el = body.elements{e};
        if isfield(el,"nodes") && ~isempty(el.nodes)
            h = patch('Faces', el.nodes', ...
                'Vertices', coordinates', ...
                'FaceColor', faceColor, ...
                'EdgeColor', [0.3 0.3 0.3]);
            hs(end+1) = h;
        end
    end
end

%% Collect Dirichlet + Neumann BCs
BCsurfaces = {};
BCtypes    = {};
BClabels   = {};

for k = 1:length(problem.problem.bcDirichlets)
    bc = problem.problem.bcDirichlets{k};
    if bc.id_body == i
        BCsurfaces{end+1} = problem.problem.bodies{i}.surfaces{bc.id_surface};
        BCtypes{end+1}    = "Dirichlet";
        BClabels{end+1}   = sprintf("Dirichlet: [%g %g] m", bc.values(1), bc.values(2));
    end
end

for k = 1:length(problem.problem.bcNeumanns)
    bc = problem.problem.bcNeumanns{k};
    if bc.id_body == i
        BCsurfaces{end+1} = problem.problem.bodies{i}.surfaces{bc.id_surface};
        BCtypes{end+1}    = "Neumann";
        BClabels{end+1}   = sprintf("Neumann: [%g %g] N", bc.values(1), bc.values(2));
    end
end

%% Draw Dirichlet + Neumann BCs
for s = 1:length(BCsurfaces)
    surf = BCsurfaces{s};
    type = BCtypes{s};
    label = BClabels{s};

    c = colorMap(colorIndex,:);
    colorIndex = colorIndex + 1;

    if type == "Dirichlet"
        marker = markers{markDirichlet};
        markDirichlet = markDirichlet + 1;
    else
        marker = markers{markNeumann};
        markNeumann = markNeumann + 1;
    end

    h = plot(coordinates(1,surf.nodes), ...
             coordinates(2,surf.nodes), ...
             'o','Color',c,'Marker',marker,'LineWidth',1.5);

    hs(end+1) = h;
    mylegends(end+1) = string(label);

    if isfield(surf,'elements')
        for e = 1:numel(surf.elements)
            segs = surf.elements{e}.nodes;
            for j = 1:size(segs,1)
                plot(coordinates(1,segs(j,:)),coordinates(2,segs(j,:)), ...
                    '-','Color',c,'LineWidth',1.8);
            end
        end
    end
end

%% Mortars (shared Master/Slave style)
for k = 1:length(problem.problem.bcMortars)

    bc = problem.problem.bcMortars{k};
    isMaster = (bc.id_body1 == i);
    isSlave  = (bc.id_body2 == i);

    if ~(isMaster || isSlave)
        continue
    end

    if isMaster
        surf = problem.problem.bodies{i}.surfaces{bc.id_surface1};
        label = sprintf("Mortar %d: Master", k);
    else
        surf = problem.problem.bodies{i}.surfaces{bc.id_surface2};
        label = sprintf("Mortar %d: Slave", k);
    end

    % shared style per mortar ID
    if mortarStyles.isKey(k)
        st = mortarStyles(k);
        c = st.color;
        marker = st.marker;
    else
        c = colorMap(colorIndex,:);
        marker = markers{markMortar};
        mortarStyles(k) = struct('color',c,'marker',marker);
        colorIndex = colorIndex + 1;
        markMortar = markMortar + 1;
    end

    h = plot(coordinates(1,surf.nodes), ...
             coordinates(2,surf.nodes), ...
             'o','Color',c,'Marker',marker,'LineWidth',1.5);

    hs(end+1) = h;
    mylegends(end+1) = string(label);

    if isfield(surf,'elements')
        for e = 1:numel(surf.elements)
            segs = surf.elements{e}.nodes;
            for j = 1:size(segs,1)
                plot(coordinates(1,segs(j,:)),coordinates(2,segs(j,:)), ...
                     '-','Color',c,'LineWidth',1.8);
            end
        end
    end
end

set(gca,'FontSize',PlotSetting.FontSize)
axis equal

end
