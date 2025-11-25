function out = unclassifyStructsDeep(in)
% Převádí libovolně zanořené classy/structy/celly na čistý struct.

    if isstring(in) || ischar(in) || isnumeric(in) || islogical(in) || isempty(in)
        % Tyto typy necháváme jak jsou
        out = in;

    elseif isobject(in)
        % Objekt -> public vlastnosti
        meta = metaclass(in);
        props = meta.PropertyList;
        out = struct();
        for p = props'
            if strcmp(p.GetAccess, 'public') && isprop(in, p.Name)
                val = in.(p.Name);
                out.(p.Name) = unclassifyStructsDeep(val);
            end
        end

    elseif isstruct(in)
        % Struct -> projdi všechna pole
        out = struct();
        f = fieldnames(in);
        for i = 1:numel(f)
            out.(f{i}) = unclassifyStructsDeep(in.(f{i}));
        end

    elseif iscell(in)
        % Cell -> projdi prvky
        out = cellfun(@unclassifyStructsDeep, in, 'UniformOutput', false);

    else
        % Ostatní typy (např. function handle)
        out = in;
    end
end
