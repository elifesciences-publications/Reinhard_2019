function [VoxelSize, resolution, Channels, nchannels, GFP, chAT, DAPI, TD, YFP, namein, nameout, ds] = getstack(pathname, fname, ext, BigFile)
GFP = []; DAPI = []; chAT = []; TD = []; YFP = [];
switch ext
    case '.lsm'
        if BigFile == 1
            tmp = regexp(pathname,'/');
            rawpathname  = pathname(1:tmp(end)-1);
            II = lsminfo([rawpathname filesep fname '.lsm']);
            stack = tiffread([pathname filesep fname ext]);
            namein = [fname ext];
            nameout = fname;
        else
            II = lsminfo([pathname fname]);
            nchannels = II.ChannelColors.NumberColors;
            stack = tiffread([pathname filesep fname]);
            namein = fname;
            nameout = fname(1:end-4);
        end

        VoxelSize = [II.VoxelSizeX, II.VoxelSizeY, II.VoxelSizeZ] * 1000000;
        switch nchannels
            case 1
                Channels = {'GFP'};                
            case 2
                Channels = {'GFP', 'chAT'};                
            case 3
                Channels = {'GFP', 'td','chAT'};
            case 4
                Channels = {'DAPI', 'GFP', 'YFP', 'chAT'}; % Roska Lab Images

            otherwise
        end
        ds = .5/VoxelSize(1); % Make final image pixel size = 0.5 um.
        sizeZ = (II.VoxelSizeZ*1000000);
        resolution = [0.5 0.5 sizeZ];        
        
        %----- Create Individual Stacks -----%
        nx = stack(1).width;
        ny = stack(1).height;
        nz = length(stack);
        for ch = 1:nchannels
            for z = 1:nz
                if z == 1
                    switch stack(z).bits
                        case 8
                            eval([Channels{ch} ' = uint8(zeros(ny,nx,nz));']);
                        case 16
                            eval([Channels{ch} ' = uint16(zeros(ny,nx,nz));']);
                        otherwise
                            eval([Channels{ch} ' = double(zeros(ny,nx,nz));']);
                    end
                end
                if nchannels == 1
                    eval([Channels{ch} '(:,:,z) = stack(z).data;']);
                else
                    eval([Channels{ch} '(:,:,z) = stack(z).data{ch};']);
                end
            end
        end        
        
    case '.nd'
        disp('Program!');
    case '.tif'
        disp('Program!');
end
        

