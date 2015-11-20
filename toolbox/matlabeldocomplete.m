function matlabeldocomplete(substring, port)
%% [ Modified from matlab-mode emacsdocomplete]
% Ask for completions of SUBSTRING from MATLAB.
% This is used by Emacs TAB in matlab-shell to provide possible
% completions.  This hides the differences between versions
% for the calls needed to do completions.

    matlabMCRprocess_emacs = com.mathworks.jmi.MatlabMCR; emacs_completions_output = matlabMCRprocess_emacs.mtFindAllTabCompletions(substring, length(substring),0);
    
    import java.io.*
    import java.net.*

    client = Socket('127.0.0.1', port);

    outToServer = client.getOutputStream();

    out = DataOutputStream(outToServer);
    for i = 1 : length(emacs_completions_output)
        out.writeUTF(emacs_completions_output(i));
    end
    out.close()
    
    clear('matlabMCRprocess_emacs', 'emacs_completions_output', ...
          'out', 'client');

end