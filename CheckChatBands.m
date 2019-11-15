function CheckChatBands(dname)
% Calculate histogram of Chat band distances

% Initiate
fnames = dir(dname);
fnames = fnames(3:end);
% addpath('A:\LabPapers\SCRouter\Katja\Sumbul_modified\code\clustering')
% addpath('A:\LabPapers\SCRouter\Katja\Sumbul_modified\code')
    
    %---------- Get File Names ----------%
    n = 0;
    for i = 1:length(fnames)
       yn = strfind(fnames(i).name, 'zDist');
       if yn
           n = n + 1;
           fn{n,:} = fnames(i).name;
       end       
    end        
    ncells = length(fn);

clear fnames i n yn    
%Get Chat Bands
DD = zeros(ncells,1);
for i = 1:ncells
%     disp(num2str(i))
    clear chatDist

    %----- Check for kvoxels -----%
    load(fullfile(dname, fn{i,:}), 'chatDist');   
    if exist('chatDist')
        continue
    else
        clear chatDist
    end
    load(fullfile(dname, fn{i,:}), 'voxels', 'resolution');
    chatDist = resolution(3) * (voxels.medVZmax - voxels.medVZmin);    
    save(fullfile(dname, fn{i,:}), 'chatDist','-append');
    disp(['saved ',fn{i,:}])
end
disp('FINISHED')

end