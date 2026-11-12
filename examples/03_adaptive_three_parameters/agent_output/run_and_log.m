function run_and_log(scriptName)
%RUN_AND_LOG Run a script with evalc and append its output to analysis_results.md
here = fileparts(mfilename('fullpath'));
txt = runIsolated(fullfile(here, [scriptName '.m']));
fid = fopen(fullfile(here, 'analysis_results.md'), 'a', 'n', 'UTF-8');
fprintf(fid, '\n## %s - %s\n\n```\n%s\n```\n', scriptName, char(datetime('now', 'Format', 'yyyy-MM-dd HH:mm:ss')), txt);
fclose(fid);
fprintf('%s', txt);
end

function txt = runIsolated(file__)
% the script's "clear" only clears this workspace
txt = evalc('run(file__)');
end
