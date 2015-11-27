(require 'cl-lib)
(require 'company)
(require 'matlab)
(require 's)
(require 'matlab-server)

(defvar company-matlab-is-completing nil
"Whether it is during the completing backend.")

(defvar company-matlab-complete-output ""
  "The output of matlab used by completing")

(defvar company-matlab-complete-candidates ""
  "The candidates")

(defun company-matlab-process-received-data (in arg)
  (delq nil (mapcar (lambda (s)
		      (if (or (string= s "") (string= (substring s 1) arg))
			      nil (substring s 1)))
		    (s-split "\000" in))))


;; some are copied from matlab-shell-collect-command-output function
(defun company-matlab-get-candidates (arg)
  (if (or (string= arg "")
	  (string= (substring arg 1 1) ".")
	  (string= (substring arg 1 1) "~"))
      nil
    (let ((status (matlab-server-get-status)))
      (if (not (string= status "ready"))
	  (progn
	    (message status)
	    (company-other-backend))
	(let ((res (company-matlab-process-received-data
		    (matlab-server-get-response-of-command 
		     (concat "matlabeldocomplete('" arg "', " matlab-server-port ")\n")) arg)))
	  (if (eq res nil)
	    (company-other-backend)
	    res))))))


(defun company-matlab-grab-symbol ()
  (buffer-substring (point) (save-excursion (skip-syntax-backward "w_.")
                                                (point))))

(defun company-matlab (command &optional arg &rest ignored)
  (interactive (list 'interactive))
  (cl-case command
    (interactive (company-begin-backend 'company-matlab))
    (prefix (and (or (eq major-mode 'matlab-mode)
		     (string= (buffer-name) "*MATLAB*"))
		     (company-matlab-grab-symbol)))
    (no-cache nil)
    (duplicates t)
    (ignore-case nil)
    (candidates
     (company-matlab-get-candidates arg))))

(add-to-list 'company-backends 'company-matlab)



(defun company-matlab-company-cancel-hook (arg)
  (if (or (eq major-mode 'matlab-mode)
	 (string= (buffer-name) "*MATLAB*"))
      (setq company-matlab-is-completing nil)))

(add-to-list 'company-completion-cancelled-hook 'company-matlab-company-cancel-hook)



(provide 'company-matlab)
