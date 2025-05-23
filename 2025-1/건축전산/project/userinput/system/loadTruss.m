function Truss = loadTruss(filename)
    filepath = fullfile('userinput','system', 'store', filename);

    if ~isfile(filepath)
        Truss = struct();
        return;
    end

    data = load(filepath);

     if isfield(data, 'Truss')
        Truss = data.Truss;
     else
         Truss = struct();
     end
end