function RGC_WeirdCells(datapath,name,action)

if action == 1 %add weird cell
    try
        load(fullfile(datapath,'weirdCells'))
        found = 0; m = 0;
        while found == 0 && m<length(weirdCells)
            m=m+1;
            if ~isempty(regexp(weirdCells{m},name))
                found = 1;
            end
        end
        if found == 0
            currSize = size(weirdCells,1);
            weirdCells{currSize+1,1}=name;
        end
    catch
        weirdCells{1,1} = name;
    end
    
elseif action == 0 %remove weird cell
    try
        load(fullfile(datapath,'weirdCells'))
        found = 0; m = 0;
        while found == 0 && m<length(weirdCells)
            m=m+1;
            if ~isempty(regexp(weirdCells{m},name))
                found = 1;
            end
        end
        if found == 1
            currSize = size(weirdCells,1);
            keep=1:currSize;
            keep = setdiff(keep,m);
            weirdCells=weirdCells(keep);
        end
    catch
        weirdCells=cell(1,1);
        
    end
elseif action==-1%remove all
    weirdCells=cell(1,1);
end
save(fullfile(datapath,'weirdCells'),'weirdCells')



end