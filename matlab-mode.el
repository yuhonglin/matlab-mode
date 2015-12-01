(require 'matlab)
(require 'matlab-server)
(require 'company-matlab)
(require 'flycheck-matlab)
(require 'doc-matlab)
(require 'jtd-matlab)

;; hooks that must be done
(add-to-list 'matlab-mode-hook
	     (lambda ()
	       ;; set the prompt value to make matlab-on-prompt-p work
	       (setq-local comint-prompt-regexp "^\\(K\\|EDU\\)?>> *")))


;; setup that can be changed
(defun matlab-mode-common-setup ()
  ;; for .m files
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
				'matlab-view-current-word-doc-in-another-buffer)
		 ;; bind the key of jump to source code
		 (local-set-key (kbd "C-c s") 
				'matlab-jump-to-definition-of-word-at-cursor)
		 ;; set company-backends
		 (setq-local company-backends '(company-files (company-dabbrev company-matlab)))))

  ;; for matlab-shell
  (add-to-list 'matlab-shell-mode-hook
	       (lambda ()
		 ;; set company-backends
		 (setq-local company-backends '(company-files (company-dabbrev company-matlab)))
		 
		 ;; band matlab-doc key
		 (local-set-key (kbd "C-c h") 
				'matlab-view-current-word-doc-in-another-buffer)
		 		 ;; bind the key of jump to source code
		 (local-set-key (kbd "C-c s") 
				'matlab-jump-to-definition-of-word-at-cursor))))

(provide 'matlab-mode)
