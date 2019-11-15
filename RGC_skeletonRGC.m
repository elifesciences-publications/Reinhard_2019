function tree = RGC_skeletonRGC(apath, somaloc, plottree, savetree,doall)
% Pts is a three column matrix where rows represent each ninarized point.
% Pts is equivalent to a list of voxels, e.g. kvoxels.

dList = dir(fullfile(apath,'*_zDist.mat'));

for i =1:length(dList)
    clear kvoxels25
    tst = load(fullfile(apath,dList(i).name), 'tree');
    
    if doall == 1
        go = 1;
    else
        if isfield(tst,'tree')
            go = 0;
        else
            go = 1;
        end
    end
    
    if go == 1
        clear pts kvoxels25
        load(fullfile(apath, dList(i).name), 'kvoxels25');
        
        %----- DownSample -----%
        if exist('kvoxels25','var')
        pts = kvoxels25;
        %----- Input Arguments -----%
        if nargin < 2
            somaloc = [];
        end
        if nargin < 3
            plottree = 0;
        end
        if nargin < 4
            savetree = 0;
        end
        if nargin < 5
            treename = 'test';
        end
        
        %----- Get Paths -----%
        addpath('/media/areca_raid/LabCode/Anatomy/treestoolbox/construct')
        addpath('/media/areca_raid/LabCode/Anatomy/treestoolbox/graphical');
        addpath('/media/areca_raid/LabCode/Anatomy/treestoolbox/IO');
        addpath('/media/areca_raid/LabCode/Anatomy/treestoolbox/metrics');
        addpath('/media/areca_raid/LabCode/Anatomy/treestoolbox/graphtheory');
        addpath('/media/areca_raid/LabCode/Anatomy/treestoolbox/edit');
        
        
        %---------- Creat Minimum Spanning Tree ----------%
        DownSample = 1;
        BalancingFactor = .4;
        ThresholdDistance = 250;
        MaximimPathLength = [];
        DIST = [];
        
        %----- Make Initial Tree -----%
        if isempty(somaloc)
            tree = MST_tree(1, pts(1:DownSample:end,1), pts(1:DownSample:end,2), pts(1:DownSample:end,3), ...
                BalancingFactor, ThresholdDistance, MaximimPathLength, DIST, 'none');
        else
            [somaloc(1); pts(1:DownSample:end,1)]
            tree = MST_tree(1, [somaloc(1); pts(1:DownSample:end,1)], [somaloc(2); pts(1:DownSample:end,2)], [somaloc(3); pts(1:DownSample:end,3)], ...
                BalancingFactor, ThresholdDistance, MaximimPathLength, DIST, 'none');
        end
        
        %----- Clean Tree: Still needs optimizing -----%
        tree = clean_tree(tree, 50);
        tree = clean_tree(tree, 25);
        tree = clean_tree(tree, 10);
        
        %----- Smooth Tree -----%
        %     tree = smooth_tree (tree, 0.5, 0.9, 5, '-w');
        
        %---------- Visualize ----------%
        if plottree == 1
            
            %----- Define Figure -----%
            figure('Position', [150 150 1000 750], 'Color', 'w');
            cmap_lines = cbrewer2K('Dark2',8,'1');
            cellcolor = cmap_lines(8,:);
            
            %----- Plot Voxels -----%
            subplot(4,2,[1 3 5])
            scatter(pts(:,1),pts(:,2), .5, '.', 'MarkerFaceColor', cellcolor, 'MarkerEdgeColor',cellcolor)
            subplot(4,2,7)
            scatter(pts(:,1),pts(:,3), .5, '.', 'MarkerFaceColor', cellcolor, 'MarkerEdgeColor',cellcolor)
            set(gca, 'ylim', [-2 2.5])
            
            %----- Plot Tree -----%
            subplot(4,2,[2 4 6])
            scatter(tree.X,tree.Y, .5, '.', 'MarkerFaceColor', cellcolor, 'MarkerEdgeColor',cellcolor)
            subplot(4,2,8)
            scatter(tree.X,tree.Z, .5, '.', 'MarkerFaceColor', cellcolor, 'MarkerEdgeColor',cellcolor)
            set(gca, 'ylim', [-2 2.5])
            
            figure;
            plot_tree(tree)
            
        end
        
        %---------- Save Tree File as swc ----------%
        if savetree == 1
            %         swc_tree(tree, treename);
            save(fullfile(apath, dList(i).name), 'tree', '-append');
        end
        else
            continue
        end
    end
end

end