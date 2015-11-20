(require 'matlab-server)

(defun doc-matlab-process-received-data (s)
  (when (> (length s) 2)
    (substring s 2)))

(defun doc-matlab-grab-current-word ()
  (save-excursion
   (let (start end oldpos)
     (setq oldpos (point))
     (skip-chars-backward "A-Za-z0–9_") (setq start (point))
     (skip-chars-forward "A-Za-z0–9_") (setq end (point))
     (buffer-substring start end))))

(defun matlab-view-current-word-doc-in-another-buffer ()
  "look up the matlab help info and show in another buffer"
  (interactive)
  (if (not (matlab-server-ready-for-command-p))
      (error "matlab is busy or the network process is down"))

  (let* ((word (doc-matlab-grab-current-word))
	 (doc (doc-matlab-process-received-data 
	       (matlab-server-get-response-of-command 
		(concat "matlabeldodoc('" word "', " matlab-server-port ")\n"))))
	 (buffer (get-buffer-create (concat "*matdoc:" word "*"))))

    (set-buffer buffer)
    (erase-buffer)
    (insert doc)
    (goto-char (point-min))
    (pop-to-buffer buffer)))


(provide 'doc-matlab)
