;; jump-to-definition of matlab

(require 's)
(require 'matlab-server)


;; the problem is that, sometime the return of `which`
;; function in matlab contains file extensions '.m',
;; but sometime does not.
(defun jtd-matlab-process-received-data (s)
  (when (> (length s) 4)
    (let ((rawreturn (car (s-match "/[^><()\t\n,'\";:]+\\(:[0-9]+\\)?"
				   (s-chomp (s-trim s))))))
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
  (if (not (buffer-file-name))
      (error "jtd-matlab: you should save the file first"))

  (let* ((word (jtd-matlab-grab-current-word))
	 (scpath (jtd-matlab-process-received-data 
		  (matlab-send-request-sync
		   (concat "which('" word "', 'in', " "'" (file-truename (buffer-file-name))  "')")))))
    (if scpath
	(find-file scpath)
      (error "can not find the definition"))))


(provide 'jtd-matlab)
