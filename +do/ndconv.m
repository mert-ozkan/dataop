function C = ndconv(arr, kernel, options)
% NDCONV N-Dimensional convolution with custom padding.
%   C = NDCONV(arr, kernel, Name, Value, ...) performs N-D convolution
%   of arrays arr and kernel. It is a wrapper for:
%       arr_padded = paddata(arr, ...);
%       C = convn(arr_padded, kernel, 'valid');
%
%   This allows using 'convn' with 'replicate', 'symmetric', or
%   custom constant padding, equivalent to convn(..., 'same') size.
%
%   Arguments:
%       arr (double): The N-D array to be filtered.
%       kernel (double): The N-D convolution kernel.
%
%   Name-Value Pairs (passed directly to paddata):
%       'Pattern' (string): The padding method.
%           Options: "constant", "replicate", "symmetric", "circular"
%           Default: "constant"
%
%       'FillValue' (double): The constant value to use when
%           Pattern="constant".
%           Default: 0
%
%   Example:
%       % Convolve with 'replicate' padding
%       C = ndconv(myArray, myKernel, 'Pattern', 'replicate');
%
%       % Convolve with NaN padding
%       C = ndconv(myArray, myKernel, 'Pattern', 'constant', 'FillValue', NaN);

arguments
    arr double
    kernel double
    options.Pattern string {mustBeMember(options.Pattern, ["constant", "replicate", "symmetric", "circular"])} = "constant"
    options.FillValue double {mustBeScalarOrEmpty} = 0
end

% Determine the maximum number of dimensions to consider
nd = max(ndims(arr), ndims(kernel));

% Get kernel size, padded with 1s up to 'nd'
sz_k = ones(1, nd);
sz_k(1:ndims(kernel)) = size(kernel);

% Calculate total padding needed to simulate 'same' size output
% 'convn(..., 'same')' would be equivalent to padding with (sz_k - 1)
pad_size_total = sz_k - 1;

% Split padding for 'pre' and 'post' to center the kernel,
% mimicking convn's 'same' behavior.
pad_pre = floor(pad_size_total / 2);
pad_post = pad_size_total - pad_pre;

% Convert the options struct to a cell array for paddata
% This will be {'Pattern', 'replicate'} or {'Pattern', 'constant', 'FillValue', 0}
paddingArgs = namedargs2cell(options);

% Pad the array twice: once for 'pre' and once for 'post'
% We must do this to support asymmetric padding for even-sized kernels,
% as paddata(..., 'both') is always symmetric.
% Use 'Side', 'leading' for 'pre' and 'Side', 'trailing' for 'post'.
arr_padded = paddata(arr, pad_pre, 'Side', 'leading', paddingArgs{:});
arr_padded = paddata(arr_padded, pad_post, 'Side', 'trailing', paddingArgs{:});

% Perform convolution only on the 'valid' part.
% The size of arr_padded is (size(arr) + pad_size_total).
% The 'valid' convolution size is:
%   size(arr_padded) - sz_k + 1
% = (size(arr) + pad_size_total) - sz_k + 1
% = (size(arr) + (sz_k - 1)) - sz_k + 1
% = size(arr)
% This returns an array of the same size as the original 'arr'.
C = convn(arr_padded, kernel, 'valid');

end

