function run_and_log(scriptName)
%RUN_AND_LOG Run a script in the base workspace with evalc and append its output to analysis_results.md.
%   The script runs in the base workspace because syms cannot create the variable i inside a function.
here = fileparts(mfilename('fullpath'));
cd(here);
cmd = sprintf('run(''%s'')', fullfile(here, scriptName));
txt = evalin('base', sprintf('evalc(''%s'')', strrep(cmd, '''', '''''')));
fid = fopen(fullfile(here, 'analysis_results.md'), 'a', 'n', 'UTF-8');
fprintf(fid, '\n## %s  (%s)\n\n```\n%s\n```\n', scriptName, ...
    char(datetime('now', 'Format', 'yyyy-MM-dd HH:mm:ss')), txt);
fclose(fid);
disp(txt);
end
