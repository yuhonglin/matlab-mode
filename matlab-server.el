;; Only API: matlab-send-request-sync (request &rest args)
;;           return command output as string

(defvar matlab-server-executable "matlab")
(defvar matlab-server-process nil)
(defvar matlab-server-buffer " *matlab* "
  "The name of the buffer for the matlab process to run in")
(defvar matlab-eot ">>")
(defvar matlab-just-startup t)
(defvar matlab-process-auto-start t)

(defun matlab-start-server-process ()
  (if (and matlab-server-executable (matlab-check-server-executable))
      (let ((process-connection-type nil)
	    (process-adaptive-read-buffering nil)
	    process)
	(setq process
	      (start-process-shell-command
	       "matlab"
	       matlab-server-buffer
	       (format "%s -nodesktop -nosplash"
		       (shell-quote-argument matlab-server-executable))))
	(buffer-disable-undo matlab-server-buffer)
	(set-process-query-on-exit-flag process nil)
	(set-process-sentinel process 'matlab-server-process-sentinel)
	(set-process-filter process 'matlab-server-process-filter)
	(setq matlab-just-startup t)
	process)
    (error "matlab: can't find the matlab executable, try to set matlab-server-executable")))


(defun matlab-check-server-executable ()
  (executable-find matlab-server-executable))

(defun matlab-get-server-process-create ()
  (if (and matlab-server-process
	   (process-live-p matlab-server-process))
      matlab-server-process
    (setq matlab-server-process (matlab-start-server-process))))


(defun matlab-server-kill ()
  "Kill the running matlab process, if any."
  (interactive)
  (when (and matlab-server-process (process-live-p matlab-server-process))
    (kill-process matlab-server-process)
    (setq matlab-server-process nil)))


(defun matlab-server-process-sentinel (process event)
  (unless (process-live-p process)
    (setq matlab-server-process nil)
    (message "matlab process stopped")))


(defun matlab-process-server-response (process response)
  (let ((sexp response)
	(callback (matlab-server-process-pop-callback process)))
    (with-demoted-errors "Warning: %S"
      (apply (car callback) sexp (cdr callback)))))

(defun matlab-server-process-filter (process output)
  "Handle the output from matlab.
1. Split by matlab-eot and return the finished responses.
2. Then call the callbacks from stack on each of the finished responses."
  (let ((pbuf (process-buffer process))
	responses)
    ;; append output to process buffer
    (when (buffer-live-p pbuf)
      (with-current-buffer pbuf
	(save-excursion
	  (goto-char (process-mark process))
	  (insert output)
	  (set-marker (process-mark process) (point))
	  ;; check if the message is complete based on `matlab-eot'
	  (goto-char (point-min))
	  (while (search-forward matlab-eot nil t)
	    (let ((response (buffer-substring-no-properties (point-min)
							    (point))))
	      (delete-region (point-min) (point))
	      ;; ignore the first process
		(setq responses (cons response responses))))
	  (goto-char (process-mark process)))))
    ;; handle all responses.
    (mapc #'(lambda (r)
	      (matlab-process-server-response process r))
	  (nreverse responses))))

(defun matlab-server-process-push-callback (p cb)
  "push (process callback) into a stack"
  (let ((callbacks (process-get p 'matlab-callback-stack)))
    (if callbacks
	(nconc callbacks (list cb))
      (process-put p 'matlab-callback-stack (list cb)))))

(defun matlab-server-process-pop-callback (p)
  "pop (process callback) into a stack and return the callback popped"
  (let ((callbacks (process-get p 'matlab-callback-stack)))
    (process-put p 'matlab-callback-stack (cdr callbacks))
    (car callbacks)))

(defmacro matlab--without-narrowing (&rest body)
  "Remove the effect of narrowing for the current buffer.
Note: If `save-excursion' is needed for BODY, it should be used
before calling this macro."
  (declare (indent 0) (debug t))
  `(save-restriction
     (widen)
(progn ,@body)))

(defun matlab-send-request (request callback &rest args)
  "Send a request to the process.
At the same time push the callback to the stack (number of callbacks
and number of command sent are the same). After this, the filter 
will be called when process outputs."
    (let ((process (matlab-get-server-process-create))
	  (argv (cons request args)))
      (when (and process (process-live-p process))
	(matlab-server-process-push-callback process callback)
	(matlab--without-narrowing
	 (process-send-string process
			      (format "%s\n" (car argv)))))))

(defvar matlab-sync-id 0 "ID of next sync request.")
(defvar matlab-sync-result '(-1 . nil)
  "The car stores the id of the result and cdr stores the return value.")

(defun matlab-sync-request-callback (response id)
  (setq matlab-sync-result (cons id response)))

(defun matlab-send-request-sync-helper (request &rest args)
  "Send a request to matlab and wait for the result.
Called by matlab-send-request-sync"
  (let* ((id matlab-sync-id)
	 (callback (list #'matlab-sync-request-callback id)))
    (setq matlab-sync-id (1+ matlab-sync-id))
    (with-local-quit
      (let ((process (matlab-get-server-process-create)))
	(when process
	  (apply 'matlab-send-request request callback args)
	  (while (not (= id (car matlab-sync-result)))
	    (accept-process-output process))
	  (cdr matlab-sync-result))))))

(defun matlab-start ()
  (interactive)
  (if (not (and matlab-server-process
		(process-live-p matlab-server-process)))
      (progn
	(message "matlab: starting background matlab...")
	(matlab-send-request-sync-helper "import com;") ;; ignore first request
	(setq matlab-just-startup nil)
	(message "matlab: done")
	(if (and (or (string= "matlab-mode" major-mode)
		     (string= (buffer-name) "*MATLAB*"))
		 (not (string= matlab-last-work-directory default-directory)))
	    (progn (matlab-send-request-sync (concat "cd " default-directory))
		   (setq matlab-last-work-directory default-directory))))))


(defun matlab-send-request-sync (request &rest args)
  "Send a request to matlab and wait for the result."
  (if matlab-process-auto-start
      (if (or matlab-just-startup (not (process-live-p matlab-server-process)))
	  (progn
	    (message "matlab: starting background matlab...")
	    (matlab-send-request-sync-helper "import com;") ;; ignore first request
	    (setq matlab-just-startup nil)	
	    (apply 'matlab-send-request-sync-helper request args)
	    (message "matlab: done"))
	(apply 'matlab-send-request-sync-helper request args))))


(provide 'matlab-server)
