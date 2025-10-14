function i = argmin(varargin)
% wrapper function around mink that returns index no of min, useful espc.
% within cellfun, arrayfun etc.
% input order must be same as mink()
if nargin == 1
    varargin{2} = 1;
end
[~, i] = mink(varargin{1},varargin{2:end});

end