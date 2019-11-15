function IDlist = RGC_CurrentlyWorkingOn(datapath,IDlist,listOfCells,type)

if type == 1
    currList = listOfCells(IDlist,1);
    try
%         load(fullfile(datapath,'currentlyWorkingOn'))
%         if ~isempty(currentlyWorkingOn)
%             checkList = 1;
%         else
            currentlyWorkingOn=currList;
            checkList = 0;
%         end
    catch
        currentlyWorkingOn=currList;
        checkList = 0;
    end
    
    if checkList == 1
        keep=[];
        for c = 1:length(currList)
            found = 0; m = 0;
            while found == 0 && m<length(currentlyWorkingOn)
                m=m+1;
                if ~isempty(regexp(currentlyWorkingOn{m},currList{c}))
                    found = 1;
                end
            end
            if found == 0
                keep = [keep;c];
                currentlyWorkingOn{length(currentlyWorkingOn)+1}=currList{c};
            end
        end
        IDlist=IDlist(keep);
    end
    save(fullfile(datapath,'currentlyWorkingOn'),'currentlyWorkingOn')
    
elseif type==2
    currList = listOfCells(IDlist,1);
    try
     load(fullfile(datapath,'currentlyWorkingOn'))
    keep=[];
    for c = 1:length(currentlyWorkingOn)
        found = 0; m = 0;
        while found == 0 && m<length(currList)
            m=m+1;
            if ~isempty(regexp(currList{m},currentlyWorkingOn{c}))
                found = 1;
            end
        end
        if found == 0
            keep = [keep;c];
        end
    end
    currentlyWorkingOn = currentlyWorkingOn(keep);
    catch
        currentlyWorkingOn={};
    end
    IDlist = [];
    save(fullfile(datapath,'currentlyWorkingOn'),'currentlyWorkingOn')
elseif type==0
     currentlyWorkingOn={};
         save(fullfile(datapath,'currentlyWorkingOn'),'currentlyWorkingOn')
end