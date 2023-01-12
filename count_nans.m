    function [c, indices] = count_nans(A)
        indices = find(isnan(A));
        c=numel(indices);
    end