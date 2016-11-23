(require 'matlab-server)
(require 's)

(defun doc-matlab-process-received-data (s)
  (when (> (length s) 4)
    (substring (s-chomp (s-trim s)) 0 -2)))

(defun doc-matlab-grab-current-word ()
  (save-excursion
   (let (start end oldpos)
     (setq oldpos (point))
     (skip-chars-backward "A-Za-z0-9_") (setq start (point))
     (skip-chars-forward "A-Za-z0-9_") (setq end (point))
     (buffer-substring start end))))

(defun matlab-view-current-word-doc-in-another-buffer ()
  "look up the matlab help info and show in another buffer"
  (interactive)
  (let* ((word (doc-matlab-grab-current-word))
	 (doc (doc-matlab-process-received-data 
	       (matlab-send-request-sync
		(concat "help " word)))))
    (if (= (length doc) 0)
	(error (concat "doc of '" word "' not found")))
    
    (let ((buffer (get-buffer-create (concat "*matdoc:" word "*"))))
      (set-buffer buffer)
      (erase-buffer)
      (insert doc)
      (goto-char (point-min))
      (pop-to-buffer buffer))))


(provide 'doc-matlab)
