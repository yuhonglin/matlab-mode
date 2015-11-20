function matlabeldolint(filepath, port)
    
    emacsmatlabel_lintresult = mlint(filepath);
    
    import java.io.*
    import java.net.*

    try
        emacsmatlabel_client = Socket('127.0.0.1', port);
        
        emacsmatlabel_outToServer = emacsmatlabel_client.getOutputStream();
        
        emacsmatlabel_out = DataOutputStream(emacsmatlabel_outToServer);
        for i = 1 : length(emacsmatlabel_lintresult)
            emacsmatlabel_a = emacsmatlabel_lintresult(i);
            emacsmatlabel_out.writeUTF(sprintf('%d\t%d\t%s\n', ...
                                               emacsmatlabel_a.line, emacsmatlabel_a.column(1), emacsmatlabel_a.message));        
        end
        emacsmatlabel_out.close()

        clear('emacsmatlabel_client', 'emacsmatlabel_outToServer', ...
              'emacsmatlabel_lintresult', 'emacsmatlabel_a', ...
              'emacsmatlabel_out', 'emacsmatlabel_client');
    catch
        emacsmatlabel_out.close()

        clear('emacsmatlabel_client', 'emacsmatlabel_outToServer', ...
              'emacsmatlabel_lintresult', 'emacsmatlabel_a', ...
              'emacsmatlabel_out', 'emacsmatlabel_client');
        
    end
        

end