function saveTruss(Truss, filename)
    save(fullfile('userinput','Truss','system', 'store', filename), 'Truss');
end