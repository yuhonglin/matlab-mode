function matlabeldocomplete(substring, port)
%% [ Modified from matlab-mode emacsdocomplete]
% Ask for completions of SUBSTRING from MATLAB.
% This is used by Emacs TAB in matlab-shell to provide possible
% completions.  This hides the differences between versions
% for the calls needed to do completions.

    matlabMCRprocess_emacs = com.mathworks.jmi.MatlabMCR; emacs_completions_output = matlabMCRprocess_emacs.mtFindAllTabCompletions(substring, length(substring),0);
    
    import java.io.*
    import java.net.*

    emacsmatlabel_client = Socket('127.0.0.1', port);

    emacsmatlabel_outToServer = emacsmatlabel_client.getOutputStream();

    emacsmatlabel_out = DataOutputStream(emacsmatlabel_outToServer);
    for i = 1 : length(emacs_completions_output)
        emacsmatlabel_out.writeUTF(emacs_completions_output(i));
    end
    emacsmatlabel_out.close()
    
    clear('matlabMCRprocess_emacs', 'emacs_completions_output', ...
          'emacsmatlabel_out', 'emacsmatlabel_client');

end