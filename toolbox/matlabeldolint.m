function matlabeldolint(filepath, port)
    
    import java.io.*
    import java.net.*
    
    try
        %% do the check
        emacsmatlabel_lintresult = mlint(filepath);
        
      
    catch emacsmatlabel_exception
        %% if meet errors, report error
        emacsmatlabel_client = Socket('127.0.0.1', port);
        emacsmatlabel_outToServer = emacsmatlabel_client.getOutputStream();
        emacsmatlabel_out = DataOutputStream(emacsmatlabel_outToServer);
        emacsmatlabel_out.writeUTF(sprintf('[matlabelerror]: %s', ...
                                           emacsmatlabel_exception.message))
        emacsmatlabel_out.close()
        
        clear('emacsmatlabel_client', 'emacsmatlabel_outToServer', ...
              'emacsmatlabel_lintresult', 'emacsmatlabel_out', 'emacsmatlabel_client');
        
        return 
    end

    %% no errors, send the result
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
        

        

end