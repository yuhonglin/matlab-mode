(require 'matlab)
(require 'matlab-server)
(require 'company-matlab)
(require 'flycheck-matlab)

(defun matlab-mode-common-setup ()
  (add-to-list 'matlab-mode-hook 
	       (lambda ()
		 ;; use flycheck only when saving the file or enabling the mode
		 (setq-local flycheck-check-syntax-automatically '(save mode-enabled))
		 ;; turn on the flycheck mode
		 (flycheck-mode)
		 ;; start the matlab-server
		 (matlab-server-start))))

(provide 'matlab-mode)
