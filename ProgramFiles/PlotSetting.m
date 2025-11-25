classdef PlotSetting
    %PLOTSETTING Summary of this class goes here
    %   Detailed explanation goes here
    
    properties(Constant)
        FontSize = 12;
        LineWidth = 2.0;
        MarkerSize = 7;

        FaceColor = 'flat'; %'interp';
        EdgeColor = 'none';

        Axis = [];
    end
    
    methods(Static)
        function Info()

        end
        
        function mycolors = GetColorPalette(nmb)
            mycolors = lines(nmb);
        end
        
        function mymarkers = GetMarkers()
            mymarkers = {'+','o','*','x','v','d','^','s','>','<'};
        end
    end
end

