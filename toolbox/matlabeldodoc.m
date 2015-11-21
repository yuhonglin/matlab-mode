function matlabeldodoc(arg, filepath, port)
    
    try
        emacsmatlabel_whichresult = which(arg, 'in', filepath);
    
        [emacsmatlabel_s, emacsmatlabel_e] = ...
            regexp(emacsmatlabel_whichresult, '\/[\w\/@-]+');
        
        arg = emacsmatlabel_whichresult(emacsmatlabel_s : emacsmatlabel_e);
        
        if isempty(arg)
            emacsmatlabel_docofarg = '';
        else
            emacsmatlabel_docofarg = help(arg);
        end
        
    catch
        emacsmatlabel_docofarg = help(arg);
    end
    
    import java.io.*
    import java.net.*

    emacsmatlabel_client = Socket('127.0.0.1', port);

    emacsmatlabel_outToServer = emacsmatlabel_client.getOutputStream();
    
    emacsmatlabel_out = DataOutputStream(emacsmatlabel_outToServer);
    emacsmatlabel_out.writeUTF(emacsmatlabel_docofarg);
    emacsmatlabel_out.close()

    clear('emacsmatlabel_whichresult', 'emacsmatlabel_docofarg', ...
          'emacsmatlabel_out', 'emacsmatlabel_client');

end