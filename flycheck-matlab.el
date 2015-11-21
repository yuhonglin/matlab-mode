;;; -*- lexical-binding: t; -*-

(require 'flycheck)
(require 'matlab-server)
(require 's)

(defun flycheck-matlab--verify (checker)
  "Verify the matlab syntax checker."
  (list
   (flycheck-verification-result-new
    :label "mlint path checking"
    :message (if t
		 "matlab is on" "matlab process not found")
    :face (if t
	      'success '(bold error)) )))

(defun flycheck-matlab-get-error (filepath)
  (let ((rawerrstr (matlab-server-get-response-of-command 
		    (concat "matlabeldolint('" filepath "', " matlab-server-port ")\n"))))
    (delq nil
	  (mapcar (lambda (rrs)
		    (if (not (string= rrs ""))
			(let* ((cleanrs (substring rrs 2))
			      (cleanrs-split (s-split "\t" (s-trim cleanrs))))
			  (cl-multiple-value-bind (lpostart cpostart estr) cleanrs-split
			    `(,(string-to-int lpostart) ,(string-to-int lpostart) ,(string-to-int cpostart) ,(string-to-int cpostart) ,estr)))))
		    (s-split "\n" rawerrstr)))))

		    
(defun flycheck-matlab--start (checker callback)
  (if (not (matlab-server-ready-for-command-p))
      (error "matlab is busy or the network process is down")
    (progn
      (let* ((rawerror (flycheck-matlab-get-error (buffer-file-name)))
	     (errors (mapcar (lambda (rerr)
			       (cl-multiple-value-bind (lpostart lposend cpostart cposend estr) rerr
				 (flycheck-error-new-at lpostart cpostart 'warning estr :checker checker)))
			     rawerror)))
	(funcall callback 'finished errors)))))
    

(flycheck-define-generic-checker 'matlab
  "A syntax checker for matlab."
  :start #'flycheck-matlab--start
  :verify #'flycheck-matlab--verify
  :modes '(matlab-mode)
  ;; :error-filter flycheck-matlab-error-filter
  :predicate (lambda ()
	       (eq major-mode 'matlab-mode)))

(add-to-list 'flycheck-checkers 'matlab)

(provide 'flycheck-matlab)
