function raw_data = LTSpice2Matlab(filename, varargin)
% LTspice2Matlab
%
% -------------------------------------------------------------------------
% PURPOSE
% -------------------------------------------------------------------------
% Reads LTspice .raw waveform files and converts simulation results into a
% MATLAB structure for post-processing.
%
% Supported LTspice versions:
%   - LTspice IV
%   - LTspice XVII
%
% Supported analyses:
%   - .tran   Transient Analysis
%   - .ac     AC Small-Signal Analysis
%   - .dc     DC Sweep Analysis
%   - .op     DC Operating Point
%
% Supported file encodings:
%   - Binary
%   - ASCII
%
% Not supported:
%   - Fast Access Format
%
% -------------------------------------------------------------------------
% BASIC USAGE
% -------------------------------------------------------------------------
% raw_data = LTspice2Matlab('file.raw')
%
% Reads all variables contained in the LTspice RAW file.
%
% -------------------------------------------------------------------------
% OPTIONAL INPUT ARGUMENTS
% -------------------------------------------------------------------------
% raw_data = LTspice2Matlab(filename, selected_vars)
%
% selected_vars:
%   Vector containing the variable indices to import.
%
%   Example:
%       raw_data = LTspice2Matlab('test.raw',[1 3 5]);
%
%   Only variables 1, 3, and 5 are loaded.
%
%   Important:
%   Index 0 (time/frequency/sweep axis) is handled automatically and should
%   NOT be included.
%
% raw_data = LTspice2Matlab(filename, selected_vars, downsamp_N)
%
% downsamp_N:
%   Positive integer used for downsampling.
%
%   Example:
%       raw_data = LTspice2Matlab('test.raw','all',10);
%
%   Loads every 10th sample.
%
%   Useful for very large transient simulations.
%
% raw_data = LTspice2Matlab(filename, selected_vars, downsamp_N, version)
%
% version:
%   'IV'      -> LTspice IV
%   'XVII'    -> LTspice XVII
%
% Example:
%   raw_data = LTspice2Matlab('test.raw','all',1,'XVII');
%
% -------------------------------------------------------------------------
% SPECIAL ARGUMENT OPTIONS
% -------------------------------------------------------------------------
% selected_vars = 'all'
%   Loads all variables.
%
% selected_vars = []
%   Reads only the header and variable names without importing waveform
%   data. Useful for inspecting file contents quickly.
%
% -------------------------------------------------------------------------
% OUTPUT STRUCTURE
% -------------------------------------------------------------------------
% The function returns a MATLAB structure named raw_data containing metadata
% and numerical results.
%
% Common fields:
% -------------------------------------------------------------------------
% raw_data.title
%   Title line from LTspice RAW header.
%
% raw_data.date
%   Simulation date/time.
%
% raw_data.plotname
%   Type of simulation.
%
% raw_data.num_variables
%   Number of imported variables.
%
% raw_data.num_data_pnts
%   Number of samples / sweep points.
%
% raw_data.variable_name_list
%   Cell array with variable names.
%
% raw_data.variable_type_list
%   Cell array with variable types.
%   Example:
%       'voltage'
%       'device_current'
%
% raw_data.selected_vars
%   Imported variable indices.
%
% raw_data.variable_mat
%   Numerical data matrix.
%
%   Rows   -> variables
%   Cols   -> samples / points
%
% -------------------------------------------------------------------------
% ANALYSIS-SPECIFIC AXIS FIELDS
% -------------------------------------------------------------------------
% .tran:
%   raw_data.time_vect
%       Time vector [s]
%
% .ac:
%   raw_data.freq_vect
%       Frequency vector [Hz]
%
% .dc:
%   raw_data.sweep_vect
%       Sweep variable vector
%
% .op:
%   No axis vector is required.
%   raw_data.variable_mat contains one operating point value per variable.
%
% -------------------------------------------------------------------------
% DATA FORMAT DETAILS
% -------------------------------------------------------------------------
% .tran and .dc:
%   variable_mat is real-valued.
%
% .ac:
%   variable_mat is complex-valued:
%       real part = real component
%       imag part = imaginary component
%
%   Magnitude in dB:
%       mag_dB = 20*log10(abs(raw_data.variable_mat))
%
%   Phase in degrees:
%       phase_deg = angle(raw_data.variable_mat)*180/pi
%
% -------------------------------------------------------------------------
% EXAMPLES
% -------------------------------------------------------------------------
% Example 1: Read complete transient file
%   raw = LTspice2Matlab('filter.raw');
%   plot(raw.time_vect, raw.variable_mat(1,:));
%
% Example 2: Read only first two variables
%   raw = LTspice2Matlab('test.raw',[1 2]);
%
% Example 3: Inspect available variables only
%   raw = LTspice2Matlab('test.raw',[]);
%   disp(raw.variable_name_list);
%
% Example 4: AC magnitude plot
%   raw = LTspice2Matlab('bode.raw');
%   semilogx(raw.freq_vect,20*log10(abs(raw.variable_mat(1,:))));
%
% Example 5: Operating point results
%   raw = LTspice2Matlab('bias.raw');
%   table(raw.variable_name_list',raw.variable_mat)
% -------------------------------------------------------------------------
% NOTES
% -------------------------------------------------------------------------
% 1) LTspice may store compressed transient data.
% 2) Downsampling does not apply anti-alias filtering.
% 3) Variable numbering follows LTspice variable table order.
% 4) Current sign convention follows LTspice device orientation.
%
% -------------------------------------------------------------------------
% ORIGINAL AUTHOR
% -------------------------------------------------------------------------
% Paul Wagner
%
% Extended / adapted for additional formats:
%   .dc and .op support
% -------------------------------------------------------------------------

raw_data = [];

%% ------------------------------------------------------------------------
% INPUT ARGUMENTS
% -------------------------------------------------------------------------
if nargin==0
    error('LTspice2Matlab requires at least filename.');
elseif nargin==1
    selected_vars = 'all';
    downsamp_N = 1;
    LTspiceVersion = 'IV';
elseif nargin==2
    selected_vars = varargin{1};
    if ischar(selected_vars), selected_vars = lower(selected_vars); end
    downsamp_N = 1;
    LTspiceVersion = 'IV';
elseif nargin==3
    selected_vars = varargin{1};
    if ischar(selected_vars), selected_vars = lower(selected_vars); end
    downsamp_N = varargin{2};
    LTspiceVersion = 'IV';
elseif nargin==4
    selected_vars = varargin{1};
    if ischar(selected_vars), selected_vars = lower(selected_vars); end
    downsamp_N = varargin{2};
    LTspiceVersion = varargin{3};
else
    error('Too many input arguments.');
end

if length(downsamp_N)~=1 || ~isnumeric(downsamp_N) || isnan(downsamp_N) ...
        || mod(downsamp_N,1)~=0 || downsamp_N<=0
    error('downsamp_N must be positive integer >=1');
end

%% ------------------------------------------------------------------------
% OPEN FILE
% -------------------------------------------------------------------------
filename = strtrim(filename);

fid = fopen(filename,'rb','l');
if fid==-1
    fid = fopen([filename '.raw'],'rb','l');
    if fid==-1
        error('Could not open file.');
    end
end

[filename,~,machineformat] = fopen(fid);

%% ------------------------------------------------------------------------
% READ HEADER
% -------------------------------------------------------------------------
variable_name_list = {};
variable_type_list = {};
variable_flag = 0;
file_format = '';

while 1

    the_line = fgetl(fid);

    if isequal(the_line,-1)
        fclose(fid);
        error('Unexpected EOF while reading header.');
    end

    the_lineTemp = char(the_line);
    the_line = the_lineTemp(the_lineTemp~=0);

    if contains(the_line,'Binary:')
        if ~isempty(the_lineTemp) && the_lineTemp(end)==0
            fseek(fid,ftell(fid)+1,'bof');
        end
        file_format = 'binary';
        break;
    end

    if contains(the_line,'Values:')
        file_format = 'ascii';
        break;
    end

    %% HEADER TAGS
    if variable_flag==0

        idx = find(the_line==':',1);

        if isempty(idx)
            fclose(fid);
            error('Invalid header line.');
        end

        var_name  = strtrim(the_line(1:idx-1));
        var_value = strtrim(the_line(idx+1:end));

        keep = find(var_name~=' ' & var_name~='.' & ...
                    var_name~=char(9) & var_name~=char(10) & ...
                    var_name~=char(13));

        var_name = lower(var_name(keep));

        if strcmp(var_name,'variables') || strcmp(var_name,'variable')
            variable_flag = 1;
            continue;
        end

        val = str2num(var_value); %#ok<ST2NM>

        if isempty(val)
            raw_data.(var_name) = var_value;
        else
            raw_data.(var_name) = val;
        end

    %% VARIABLE TABLE
    else

        lead = find( ...
            (the_line(1:end-1)==' ' | the_line(1:end-1)==char(9)) & ...
            (the_line(2:end)~=' ' & the_line(2:end)~=char(9)));

        if length(lead)<3
            continue;
        end

        part1 = strtrim(the_line((lead(1)+1):lead(2)));
        part2 = strtrim(the_line((lead(2)+1):lead(3)));
        part3 = strtrim(the_line((lead(3)+1):end));

        if str2double(part1) ~= length(variable_name_list)
            fclose(fid);
            error('Variable table inconsistency.');
        end

        variable_name_list{end+1} = part2;
        variable_type_list{end+1} = part3;
    end
end

%% ------------------------------------------------------------------------
% REQUIRED FIELDS
% -------------------------------------------------------------------------
req = {'title','date','plotname','flags','novariables','nopoints'};

for k=1:length(req)
    if ~isfield(raw_data,req{k})
        fclose(fid);
        error(['Missing header field: ' req{k}]);
    end
end

raw_data.conversion_notes = '';
raw_data.num_data_pnts = raw_data.nopoints;
raw_data = rmfield(raw_data,'nopoints');


%------------------------------------------------------------
% Definir tipo de simulação ANTES de ajustar número de variáveis
%------------------------------------------------------------
simulation_type = '';

if ~isempty(strfind(lower(raw_data.plotname),'transient analysis'))
    simulation_type = '.tran';

elseif ~isempty(strfind(lower(raw_data.plotname),'ac analysis'))
    simulation_type = '.ac';

elseif ~isempty(strfind(lower(raw_data.plotname),'dc transfer characteristic'))
    simulation_type = '.dc';

elseif ~isempty(strfind(lower(raw_data.plotname),'operating point'))
    simulation_type = '.op';
end

%------------------------------------------------------------
% Ajuste correto da lista de variáveis
%------------------------------------------------------------
if strcmpi(simulation_type,'.op')
    % .op: todas as variáveis são dados válidos
    raw_data.num_variables = raw_data.novariables;
    raw_data.variable_name_list = variable_name_list;
    raw_data.variable_type_list = variable_type_list;
else
    % .tran / .ac / .dc:
    % índice 0 = tempo, frequência ou sweep
    raw_data.num_variables = raw_data.novariables - 1;
    raw_data.variable_name_list = variable_name_list(2:end);
    raw_data.variable_type_list = variable_type_list(2:end);
end

raw_data = rmfield(raw_data,'novariables');

%------------------------------------------------------------
% Limpeza de campos auxiliares
%------------------------------------------------------------
if isfield(raw_data,'command')
    raw_data = rmfield(raw_data,'command');
end

if isfield(raw_data,'backannotation')
    raw_data = rmfield(raw_data,'backannotation');
end

if isfield(raw_data,'offset')
    general_offset = raw_data.offset;
    raw_data = rmfield(raw_data,'offset');
else
    general_offset = 0;
end

%% ------------------------------------------------------------------------
% SIMULATION TYPE
% -------------------------------------------------------------------------
simulation_type = '';

if contains(lower(raw_data.plotname),'transient analysis')
    simulation_type = '.tran';

elseif contains(lower(raw_data.plotname),'ac analysis')
    simulation_type = '.ac';

elseif contains(lower(raw_data.plotname),'dc transfer characteristic')
    simulation_type = '.dc';

elseif contains(lower(raw_data.plotname),'operating point')
    simulation_type = '.op';
end

if isempty(simulation_type)
    fclose(fid);
    error('Unsupported simulation type.');
end

if contains(lower(raw_data.flags),'fastaccess')
    fclose(fid);
    error('FastAccess format not supported.');
end

if isfield(raw_data,'flags')
    raw_data = rmfield(raw_data,'flags');
end

%% ------------------------------------------------------------------------
% SELECTED VARS
% -------------------------------------------------------------------------
if ischar(selected_vars)
    selected_vars = 1:raw_data.num_variables;
end

if isempty(selected_vars)
    raw_data.selected_vars = [];
    raw_data.variable_mat = [];
    fclose(fid);
    return;
end

selected_vars = unique(selected_vars(:).');
raw_data.selected_vars = selected_vars;

NumPnts = raw_data.num_data_pnts;
NumPnts_DS = floor(NumPnts/downsamp_N);
raw_data.num_data_pnts = NumPnts_DS;

NumVars = raw_data.num_variables + 1;

%% ========================================================================
% BINARY DATA
% ========================================================================
if strcmpi(file_format,'binary')

    binary_start = ftell(fid);

    %% --------------------------------------------------------------------
    % .TRAN  (ORIGINAL LOGIC PRESERVED)
    % ---------------------------------------------------------------------
    if strcmpi(simulation_type,'.tran')

        if length(selected_vars)>1
            g_border = find([2 diff(selected_vars) 2]~=1);
            block_list = {};
            for k=1:length(g_border)-1
                block_list{k} = g_border(k):(g_border(k+1)-1);
            end
        else
            block_list = {1:length(selected_vars)};
        end

        raw_data.variable_mat = zeros(length(selected_vars),NumPnts_DS);

        for k=1:length(block_list)
            target_var_index = selected_vars(block_list{k});

            fseek(fid,binary_start + (target_var_index(1)+1)*4,'bof');

            TVIL = length(target_var_index);

            bytes_skip = (NumVars+1-TVIL)*4 + ...
                         (downsamp_N-1)*(NumVars+1)*4;

            precision_str = sprintf('%d*float',TVIL);

            raw_data.variable_mat(block_list{k},:) = reshape( ...
                fread(fid,NumPnts_DS*TVIL,precision_str, ...
                bytes_skip,machineformat),TVIL,NumPnts_DS);
        end

        fseek(fid,binary_start,'bof');

        raw_data.time_vect = fread(fid,NumPnts_DS,'double', ...
            (NumVars-1)*4 + (downsamp_N-1)*(NumVars+1)*4, ...
            machineformat).';

    %% --------------------------------------------------------------------
    % .AC  (ORIGINAL LOGIC PRESERVED)
    % ---------------------------------------------------------------------
    elseif strcmpi(simulation_type,'.ac')

        if length(selected_vars)>1
            g_border = find([2 diff(selected_vars) 2]~=1);
            block_list = {};
            for k=1:length(g_border)-1
                block_list{k} = g_border(k):(g_border(k+1)-1);
            end
        else
            block_list = {1:length(selected_vars)};
        end

        raw_data.variable_mat = complex(zeros(length(selected_vars),NumPnts_DS));

        for k=1:length(block_list)

            target_var_index = selected_vars(block_list{k});
            TVIL = length(target_var_index);

            fseek(fid,binary_start + target_var_index(1)*16,'bof');

            bytes_skip = (NumVars-TVIL)*16 + ...
                         (downsamp_N-1)*NumVars*16;

            precision_str = sprintf('%d*double',TVIL*2);

            temp = reshape(fread(fid,NumPnts_DS*TVIL*2,precision_str,...
                   bytes_skip,machineformat),TVIL*2,NumPnts_DS);

            raw_data.variable_mat(block_list{k},:) = ...
                temp(1:2:end-1,:) + 1j*temp(2:2:end,:);
        end

        fseek(fid,binary_start,'bof');

        raw_data.freq_vect = fread(fid,NumPnts_DS,'double', ...
            (NumVars-1)*16 + 8 + (downsamp_N-1)*NumVars*16, ...
            machineformat).';
%% --------------------------------------------------------------------
% .DC
% ---------------------------------------------------------------------
elseif strcmpi(simulation_type,'.dc')

    raw_data.variable_mat = zeros(length(selected_vars),NumPnts_DS);
    sweep_vect = zeros(1,NumPnts_DS);

    for p = 1:NumPnts_DS

        % variável de sweep
        sweep_val = fread(fid,1,'double',machineformat);

        % demais variáveis
        vals = fread(fid,raw_data.num_variables,'float',machineformat);

        if isempty(vals)
            break;
        end

        sweep_vect(p) = sweep_val;
        raw_data.variable_mat(:,p) = vals(selected_vars);
    end

    raw_data.sweep_vect = sweep_vect;


%% --------------------------------------------------------------------
% .OP
% ---------------------------------------------------------------------
    elseif strcmpi(simulation_type,'.op')

    raw_data.variable_mat = zeros(length(selected_vars),1);

    vals = zeros(raw_data.num_variables,1);

    % primeira variável em double
    vals(1) = fread(fid,1,'double',0,machineformat);

    % restantes em float
    vals(2:end) = fread(fid,raw_data.num_variables-1,'float',0,machineformat);

    if length(vals) ~= raw_data.num_variables
        fclose(fid);
        error('Erro ao ler dados .op');
    end

    raw_data.variable_mat(:,1) = vals(selected_vars);

%% ========================================================================
% ASCII DATA
% ========================================================================
elseif strcmpi(file_format,'ascii')

    %% --------------------------------------------------------------------
    % .TRAN
    % ---------------------------------------------------------------------
    if strcmpi(simulation_type,'.tran')

        M = fscanf(fid,'%g',[raw_data.num_variables+2 raw_data.num_data_pnts]);

        raw_data.time_vect = M(2,1:downsamp_N:end);
        raw_data.variable_mat = M(2+selected_vars,1:downsamp_N:end);

    %% --------------------------------------------------------------------
    % .AC
    % ---------------------------------------------------------------------
    elseif strcmpi(simulation_type,'.ac')

        all_data = fread(fid,inf,'uchar');
        all_data(all_data==',') = sprintf('\t');

        M = sscanf(char(all_data),'%g', ...
            [3+2*raw_data.num_variables raw_data.num_data_pnts]);

        raw_data.freq_vect = M(2,1:downsamp_N:end);

        raw_data.variable_mat = ...
            M(3+selected_vars*2-1,1:downsamp_N:end) + ...
            1j*M(3+selected_vars*2,1:downsamp_N:end);

    %% --------------------------------------------------------------------
    % .DC / .OP
    % ---------------------------------------------------------------------
    elseif strcmpi(simulation_type,'.dc') || strcmpi(simulation_type,'.op')

        M = fscanf(fid,'%g',[raw_data.num_variables+2 raw_data.num_data_pnts]);

        raw_data.sweep_vect = M(1,1:downsamp_N:end);
        raw_data.variable_mat = M(1+selected_vars,1:downsamp_N:end);
    end
end

fclose(fid);

%% ------------------------------------------------------------------------
% ORIGINAL TRANSIENT DECOMPRESSION
% -------------------------------------------------------------------------
if strcmpi(simulation_type,'.tran') && isfield(raw_data,'time_vect')

    if min(diff(raw_data.time_vect)) < 0
        raw_data.time_vect = abs(raw_data.time_vect);
    end
end

%% ------------------------------------------------------------------------
% OFFSET
% -------------------------------------------------------------------------
if isfield(raw_data,'time_vect')
    raw_data.time_vect = raw_data.time_vect + general_offset;

elseif isfield(raw_data,'freq_vect')
    raw_data.freq_vect = raw_data.freq_vect + general_offset;

elseif isfield(raw_data,'sweep_vect')
    raw_data.sweep_vect = raw_data.sweep_vect + general_offset;
end

end