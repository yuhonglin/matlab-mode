function matlabeldolint(filepath, port)

    lintresult = mlint(filepath);
    
    import java.io.*
    import java.net.*

    client = Socket('127.0.0.1', port);

    outToServer = client.getOutputStream();
    
    out = DataOutputStream(outToServer);
    for i = 1 : length(lintresult)
        a = lintresult(i);
        out.writeUTF(sprintf('%d\t%d\t%s\n', a.line, a.column(1), a.message));
    end
    out.close()

    clear('client', 'outToServer', 'lintresult', 'a', ...
          'out', 'client');


end