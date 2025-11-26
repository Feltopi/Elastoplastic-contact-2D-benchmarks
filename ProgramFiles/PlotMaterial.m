function [] = PlotMaterial(bodies, ax, bodyColors)

cla(ax)
hold(ax,"on")
axis(ax,'off')

nBodies = numel(bodies);

for i = 1:nBodies
    mat = bodies{i}.material;
    cBody = bodyColors(i,:);   % barva přesně podle těla nahoře
    bodyName = strjoin(string(bodies{i}.name)," ");

    E  = mat.elasticity.E;
    nu = mat.elasticity.v;

    if isequal(mat.isPlastic,1)
        Y = mat.plasticity.Y;
        a = mat.plasticity.a;
        lines = {
            sprintf('%s', bodyName)
            sprintf('  E = %.2e', E)
            sprintf('  ν = %.2f', nu)
            sprintf('  Y = %.2e', Y)
            sprintf('  a = %.2e', a)
        };
    else
        lines = {
            sprintf('%s', bodyName)
            sprintf('  E = %.2e', E)
            sprintf('  ν = %.2f', nu)
        };
    end

    % Sloupec textu
    xPos   = (i-1)/nBodies + 0.05;
    yStart = 0.9;
    yStep  = -0.15;

    for j = 1:numel(lines)
        text(ax, xPos, yStart + (j-1)*yStep, lines{j}, ...
             'Units','normalized', ...
             'Color', cBody, ...
             'HorizontalAlignment','left', ...
             'FontSize', PlotSetting.FontSize);
    end
end

end
