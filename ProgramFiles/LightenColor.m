function c = LightenColor(color, factor)
    c = color + (1 - color) * factor;
end