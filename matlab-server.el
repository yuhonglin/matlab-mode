(require 's)
(require 'matlab)

(defvar matlab-server-port "10000"
  "port of the matlab server (should be string)")

(defvar matlab-server-nth-connection-done 0
  "how many connections are done")

(defvar matlab-server-connected nil
  "whether the server is connected to matlab")

(defvar matlab-server-content-received ""
  "the content sent from matlab")

(defvar matlab-server-if-turn-off-comint-output nil
  "whether to turn off lock output")

(defun matlab-server-start nil
    "starts an emacs matlab server"
    (interactive)
    (unless (process-status "matlab-server")
      (make-network-process
       :name "matlab-server"
       :buffer "*matlab-server*"
       :family 'ipv4
       :service (string-to-int matlab-server-port)
       :sentinel 'matlab-server-sentinel
       :filter 'matlab-server-filter
       :server 't)))

  
(defun matlab-server-stop nil
  "stop an emacs matlab server"
  (interactive)
  (while  matlab-server-clients
    (delete-process (car (car matlab-server-clients)))
    (setq matlab-server-clients (cdr matlab-server-clients)))
  (delete-process "matlab-server")
  )

(defun matlab-server-filter (proc string)
  (if matlab-server-connected
      (setq matlab-server-content-received 
	    (concat matlab-server-content-received string))))

(defun matlab-server-sentinel (proc msg)
  (if (string= msg "connection broken by remote peer\n")
      (progn
	(setq matlab-server-nth-connection-done
	      (+ matlab-server-nth-connection-done 1))
	(setq matlab-server-connected nil))
    (if (string= msg "open from 127.0.0.1\n")
	(progn
	  (setq matlab-server-content-received "")
	  (setq matlab-server-connected t)))))

(defun matlab-server-ready-for-command-p ()
  "whether matlab process is ready for accepting new command"
  (and (get-process "matlab-server")
       (get-process "MATLAB")
       (not matlab-server-if-turn-off-comint-output)
       (matlab-on-prompt-p)))


(defun matlab-server-get-response-of-command (s)
  (if (not (matlab-server-ready-for-command-p))
      nil
    (progn
      (setq matlab-server-if-turn-off-comint-output t)

      (let ((old-num-done matlab-server-nth-connection-done))
	(process-send-string (get-buffer-process "*MATLAB*") s)
	(while (= old-num-done matlab-server-nth-connection-done)
	  (sleep-for .1)))
      
      (setq matlab-server-if-turn-off-comint-output nil)
      
      matlab-server-content-received)))


(defun matlab-server-comint-prehook (s)
  (if (and (string= (buffer-name) "*MATLAB*")
	   matlab-server-if-turn-off-comint-output) "" s))

(add-to-list 'comint-preoutput-filter-functions 'matlab-server-comint-prehook)


(provide 'matlab-server)
