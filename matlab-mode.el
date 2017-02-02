(require 'matlab)
(require 'matlab-server)
(require 'company-matlab)
(require 'flycheck-matlab)
(require 'doc-matlab)
(require 'jtd-matlab)


;; update working path
(defvar matlab-last-work-directory "~")
(add-hook 'buffer-list-update-hook
	  (lambda ()
	    (if (and matlab-server-process
		     (eq (process-status matlab-server-process) 'run))	    
		(if (and (or (string= "matlab-mode" major-mode)
			     (string= (buffer-name) "*MATLAB*"))
			 (not (string= matlab-last-work-directory default-directory)))
		    (progn (matlab-send-request-sync (concat "cd " default-directory))
			   (setq matlab-last-work-directory default-directory))))))

;; setup that can be changed
(defun matlab-mode-common-setup ()
  ;; for .m files
  (add-to-list 'matlab-mode-hook 
	       (lambda ()
		 ;; turn on the flycheck mode
		 (flycheck-mode)
		 ;; use flycheck only when saving the file or enabling the mode
		 (setq-local flycheck-check-syntax-automatically '(save mode-enabled))
		 ;; bind the key of checking document
		 (local-set-key (kbd "C-c h")
				'matlab-view-current-word-doc-in-another-buffer)
		 ;; bind the key of jump to source code
		 (local-set-key (kbd "C-c s")
				'matlab-jump-to-definition-of-word-at-cursor)
		 ;; set company-backends
		 (setq-local company-backends '(company-files (company-matlab company-dabbrev)))
		 ))

  ;; for matlab-shell
  (add-to-list 'matlab-shell-mode-hook
	       (lambda ()
		 ;; set company-backends
		 (setq-local company-backends '((company-dabbrev company-matlab) company-files )))))


(provide 'matlab-mode)
