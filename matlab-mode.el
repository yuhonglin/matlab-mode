(require 'matlab)
(require 'matlab-server)
(require 'company-matlab)
(require 'flycheck-matlab)
(require 'doc-matlab)

(defun matlab-mode-common-setup ()
  (add-to-list 'matlab-mode-hook 
	       (lambda ()
		 ;; start the matlab-server
		 (matlab-server-start)		 
		 ;; turn on the flycheck mode
		 (flycheck-mode)
		 ;; use flycheck only when saving the file or enabling the mode
		 (setq-local flycheck-check-syntax-automatically '(save mode-enabled))
		 ;; bind the key of checking document
		 (local-set-key (kbd "C-c h") 
				'matlab-view-current-word-doc-in-another-buffer))))

(provide 'matlab-mode)
