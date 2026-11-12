function txt = log_run(scriptName)
% LOG_RUN Run a check script in the base workspace, append its output to analysis_results.md.
here = fileparts(mfilename('fullpath'));
cmd = sprintf('log_txt__ = evalc(''run(''''%s'''')'');', fullfile(here, [scriptName '.m']));
evalin('base', cmd);                                     % base workspace: syms i, syms t work there
txt = evalin('base', 'log_txt__');
fid = fopen(fullfile(here, 'analysis_results.md'), 'a');
fprintf(fid, '\n## %s  (%s)\n\n```\n%s\n```\n', scriptName, char(datetime('now', 'Format', 'yyyy-MM-dd HH:mm:ss')), txt);
fclose(fid);
end
