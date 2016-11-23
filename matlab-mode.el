(require 'matlab)
(require 'matlab-server)
(require 'company-matlab)
(require 'flycheck-matlab)
;(require 'doc-matlab)
;(require 'jtd-matlab)

(add-hook 'buffer-list-update-hook
	  (lambda ()
	    (if (or (string= "matlab-mode" major-mode)
		    (string= (buffer-name) "*MATLAB*"))
		(matlab-send-request-sync (concat "cd " default-directory)))))

;; setup that can be changed
(defun matlab-mode-common-setup ()
  ;; for .m files
  (add-to-list 'matlab-mode-hook 
	       (lambda ()
		 ;; turn on the flycheck mode
		 (flycheck-mode)
		 ;; use flycheck only when saving the file or enabling the mode
		 (setq-local flycheck-check-syntax-automatically '(save mode-enabled))
		 ;; set company-backends
		 (setq-local company-backends '(company-files (company-matlab company-dabbrev)))))

  ;; for matlab-shell
  (add-to-list 'matlab-shell-mode-hook
	       (lambda ()
		 ;; set company-backends
		 (setq-local company-backends '(company-files (company-dabbrev company-matlab))))))


(provide 'matlab-mode)
