function matlabeldojtd(arg, filepath, port)
    
    try
        emacsmatlabel_whichresult = which(arg, 'in', filepath);
    
        [emacsmatlabel_s, emacsmatlabel_e] = ...
            regexp(emacsmatlabel_whichresult, '\/[\w\/@-]+');
        
        emacsmatlabel_arg = emacsmatlabel_whichresult(emacsmatlabel_s : emacsmatlabel_e);
        
    catch
        emacsmatlabel_arg = '';
    end
    
    import java.io.*
    import java.net.*

    emacsmatlabel_client = Socket('127.0.0.1', port);

    emacsmatlabel_outToServer = emacsmatlabel_client.getOutputStream();
    
    emacsmatlabel_out = DataOutputStream(emacsmatlabel_outToServer);
    emacsmatlabel_out.writeUTF(emacsmatlabel_arg);
    emacsmatlabel_out.close()

    clear('emacsmatlabel_whichresult', ...
          'emacsmatlabel_out', 'emacsmatlabel_client', 'emacsmatlabel_arg');

end