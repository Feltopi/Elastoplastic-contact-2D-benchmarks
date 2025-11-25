function [] = PlotOutputFn(problemToDraw, problemVersion, stress, rMult)
% PlotOutputFn(problemToDraw, problemVersion, stress, rMult)
% problemToDraw: "Hertz_Plastic", "Hertz_Elastic", "Lamalea_3", ...
% problemVersion: index výsledku v souboru s outputy (1,2,...)
% stress: "sigmaX", "sigmaY", "sigmaEq"
% rMult: násobek deformace

addpath(genpath('ProgramFiles'));
addpath(genpath('Problem_Input_Data'));
addpath(genpath('Problem_Output_Data'));

% Parse name
parts = split(problemToDraw,"_");
if numel(parts) ~= 2
    error("Bad input: must contain exactly one '_' (e.g. Hertz_Plastic)");
end
mainName = parts(1);
subName  = parts(2);

% Load INPUT
Sin = load(fullfile("Problem_Input_Data", mainName + "_Struct.mat"));
fnIn = fieldnames(Sin);
dataCell = Sin.(fnIn{1});
if mainName == "Lamalea"
    idx = str2double(subName);
elseif mainName == "Hertz"
    switch subName
        case "Elastic", idx = 1;
        case "Plastic", idx = 2;
        otherwise, error("Unknown Hertz subName: %s", subName);
    end
else
    error("Unknown mainName: %s", mainName);
end
problemStruct = dataCell{idx};

% Load OUTPUT (struct verze)
Sout = load(fullfile("Problem_Output_Data", mainName + "_" + subName + "_Struct.mat"));
fnOut = fieldnames(Sout);
outCell = Sout.(fnOut{1});
outputStruct = outCell{problemVersion};

% Figure
figure('Color','w'); hold on; axis equal;
title(mainName + " - " + subName + " (" + stress + ")");
xlabel('x'); ylabel('y');

nBodies = numel(problemStruct.bodies);
bodyColors = lines(nBodies);

% Pomocná funkce na výběr složky napětí
    function v = pickStressComponent(SIG, name)
        switch lower(name)
            case 'sigmax', v = SIG(1,:).';
            case 'sigmay', v = SIG(2,:).';
            case {'sigmaeq','vmises'}
                sx  = SIG(1,:); sy = SIG(2,:); txy = SIG(3,:);
                v = sqrt(sx.^2 - sx.*sy + sy.^2 + 3*txy.^2).';
            otherwise
                v = SIG(1,:).';
        end
    end

% Smyčka přes těla
for i = 1:nBodies
    body   = problemStruct.bodies{i};
    coords = body.coordinates;          % N x 2 double
    N      = size(coords,1);

    % --- RVE C: může být VecCell (struct s blocks) nebo už double/cell
    u = [];
    if isfield(outputStruct,'rvec')
        rvec = outputStruct.rvec;
        if isstruct(rvec) && isfield(rvec,'blocks')
            % klasický VecCell
            u = rvec.blocks{i};
            if iscell(u), u = u{1}; end
        elseif iscell(rvec)
            u = rvec{i};
            if iscell(u), u = u{1}; end
        else
            % fallback: jeden dlouhý vektor pro všechna těla -> rozřízni
            off = 0;
            for k = 1:(i-1)
                off = off + 2*size(problemStruct.bodies{k}.coordinates,1);
            end
            len = 2*N;
            u = rvec(off+(1:len));
        end
    else
        error("outputStruct neobsahuje pole 'rvec'.");
    end
    if isempty(u)
        warning("Empty displacement vector for body %d. Using zeros.", i);
        u = zeros(2*N,1);
    end

    % Deformované uzly (N x 2)
    if numel(u) ~= 2*N
        warning("Length of rvec for body %d does not match 2*N. Trimming.", i);
        u = u(1:min(end,2*N));
    end
    U = reshape(u, 2, []).';                  % N x 2
    defCoords = coords + rMult * U;           % N x 2

    % --- Složení uzlových napětí z bloků sigmas
    sigmaNode = nan(N,1);
    sigmaCnt  = zeros(N,1);

    if isfield(outputStruct,'sigmas') && ~isempty(outputStruct.sigmas)
        Sroot = outputStruct.sigmas;
        if isstruct(Sroot) && isfield(Sroot,'blocks') && i <= numel(Sroot.blocks)
            Bi = Sroot.blocks{i};  % struct nebo cell pro tělo i
            if isstruct(Bi) && isfield(Bi,'blocks')
                blocksSig = Bi.blocks;
            elseif iscell(Bi)
                blocksSig = Bi;
            else
                blocksSig = {Bi};
            end

            for e = 1:numel(body.elements)
                if e > numel(blocksSig), break; end
                el = body.elements{e};
                if ~isfield(el,'nodes') || isempty(el.nodes), continue; end
                faces = el.nodes;                          % k x nFaces
                nods  = unique(faces(:));                  % uzly v tomto bloku
                SIGe  = blocksSig{e};
                if isempty(SIGe), continue; end
                % očekáváme 3 x nNods nebo 3 x nSamples
                % pokud sedí na počet uzlů, vezmeme přímo, jinak přeskočíme
                if size(SIGe,2) == numel(nods)
                    vals = pickStressComponent(SIGe, stress); % nNods x 1
                    % mapování: předpoklad, že SIGe sloupce odpovídají nods v rostoucím pořadí
                    [nodsSorted,ord] = sort(nods);
                    vals = vals(ord);
                    % akumulace (průměrování pokud uzel patří do více bloků)
                    sigmaNode(nodsSorted) = nansum([sigmaNode(nodsSorted), vals],2,'omitnan');
                    sigmaCnt(nodsSorted)  = sigmaCnt(nodsSorted) + 1;
                end
            end
        end
    end

    % dokonči průměrování a doplň nuly, kde nic není
    has = sigmaCnt > 0;
    sigmaNode(has)  = sigmaNode(has) ./ sigmaCnt(has);
    sigmaNode(~has) = 0;

    % --- Deformovaný tvar barevně podle uzlových napětí
    for e = 1:numel(body.elements)
        el = body.elements{e};
        if isfield(el,'nodes') && ~isempty(el.nodes)
            faces = el.nodes.';
            patch('Faces', faces, ...
                  'Vertices', defCoords, ...
                  'FaceVertexCData', sigmaNode, ...
                  'FaceColor', 'interp', ...
                  'EdgeColor', [0.3 0.3 0.3], ...
                  'LineWidth', 0.5);
        end
    end
end

colorbar; colormap(jet);
axis equal tight;
set(gca,'FontSize',12); box on;
end
