;; jump-to-definition of matlab

(require 's)
(require 'matlab-server)


;; the problem is that, sometime the return of `which`
;; function in matlab contains file extensions '.m',
;; but sometime does not.
(defun jtd-matlab-process-received-data (s)
  (when (> (length s) 2)
    (let ((rawreturn (substring s 2)))
      (if (= 2 (length (s-shared-end ".m" rawreturn)))
	  rawreturn ;; contains '.m'
	(if (file-exists-p (concat rawreturn ".m"))
	    (concat rawreturn ".m") ;; append the '.m'
	  ;; else, may be a folder
	  rawreturn)))))

(defun jtd-matlab-grab-current-word ()
  (save-excursion
   (let (start end oldpos)
     (setq oldpos (point))
     (skip-chars-backward "A-Za-z0-9_") (setq start (point))
     (skip-chars-forward "A-Za-z0-9_") (setq end (point))
     (buffer-substring start end))))

(defun matlab-jump-to-definition-of-word-at-cursor ()
  "open the source code of the word at cursor"
  (interactive)
  (let ((status (matlab-server-get-status)))
    (if (not (string= status "ready"))
	(error status)))

  (let* ((word (jtd-matlab-grab-current-word))
	 (scpath (jtd-matlab-process-received-data 
		  (matlab-server-get-response-of-command 
		   (concat "matlabeldojtd('" word "', " "'" (buffer-file-name) "', " matlab-server-port ")\n")))))
    (if scpath
	(find-file scpath)
      (error "can not find the definition"))))


(provide 'jtd-matlab)
