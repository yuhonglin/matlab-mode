function matlabeldocomplete(substring, port)
%% [ Modified from matlab-mode emacsdocomplete]
% Ask for completions of SUBSTRING from MATLAB.
% This is used by Emacs TAB in matlab-shell to provide possible
% completions.  This hides the differences between versions
% for the calls needed to do completions.
   
    global emacs_completions_output
    global emacsmatlabelfieldnames
    
    emacsmatlabeldotpos = strfind(substring, '.');
    
    if isempty(emacsmatlabeldotpos) || substring(1) == '.'
        % matlabMCRprocess_emacs = com.mathworks.jmi.MatlabMCR; ...
        %     emacs_completions_output = matlabMCRprocess_emacs.mtFindAllTabCompletions(substring, length(substring),0);
        evalin('base', sprintf('matlabMCRprocess_emacs = com.mathworks.jmi.MatlabMCR; emacs_completions_output = matlabMCRprocess_emacs.mtFindAllTabCompletions(''%s'', %d,0);', substring, length(substring)))
    else
        emacsmatlabelsplitbydot = strsplit(substring, '.');
        emacsmatlabelcumstr = emacsmatlabelsplitbydot{1};
        emacsmatlabelstatus = 'success';
        for i = 2 : length(emacsmatlabelsplitbydot)-1
            try
                evalin('base',['emacsmatlabelfieldnames=fieldnames(' ...
                               emacsmatlabelcumstr ');'])
            catch
                emacsmatlabelstatus = 'fail';
                break;
            end
            if not(strcmp(emacsmatlabelsplitbydot{i},'')) && isempty(find(not (cellfun('isempty', strfind(emacsmatlabelfieldnames, emacsmatlabelsplitbydot{i}))),1))
                emacsmatlabelstatus = 'fail';
                break;
            end
            emacsmatlabelcumstr = [emacsmatlabelcumstr '.' emacsmatlabelsplitbydot{i}];
        end
        
        if strcmp(emacsmatlabelstatus, 'fail')
            emacs_completions_output = {};
        else
            try
                emacsmatlabelrawcandidatecell = fieldnames(evalin('base', emacsmatlabelcumstr));
                emacs_completions_output = strcat([emacsmatlabelcumstr, '.'], emacsmatlabelrawcandidatecell(~cellfun('isempty',regexp(emacsmatlabelrawcandidatecell,['^' emacsmatlabelsplitbydot{end} '.*'],'match','once'))));
            catch
                emacs_completions_output = {};
            end
        end
    end
    
    import java.io.*
    import java.net.*

    emacsmatlabel_client = Socket('127.0.0.1', port);

    emacsmatlabel_outToServer = emacsmatlabel_client.getOutputStream();

    emacsmatlabel_out = DataOutputStream(emacsmatlabel_outToServer);
        
    for i = 1 : length(emacs_completions_output)
        emacsmatlabel_out.writeUTF(emacs_completions_output(i));
    end
    emacsmatlabel_out.close()
    
    clear('matlabMCRprocess_emacs', ...
          'emacsmatlabel_out', 'emacsmatlabel_client', ...
          'emacsmatlabelsplitbydot', 'emacsmatlabelrawcandidatecell', ...
          'emacsmatlabelcumstr', 'emacsmatlabeldotpos', 'emacsmatlabelstatus');

end