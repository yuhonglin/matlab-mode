(require 'matlab)
(require 'matlab-server)
(require 'company-matlab)
(require 'flycheck-matlab)
(require 'doc-matlab)

;; hooks that must be done
(add-to-list 'matlab-mode-hook
	     (lambda ()
	       ;; set the prompt value to make matlab-on-prompt-p work
	       (setq-local comint-prompt-regexp "^\\(K\\|EDU\\)?>> *")))


;; setup that can be changed
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
				'matlab-view-current-word-doc-in-another-buffer)
		 ;; handle company-backends
		 (make-local-variable 'company-backends)
		 (delete 'company-files company-backends)
		 (add-to-ordered-list 'company-backends '(company-dabbrev company-matlab) 0)
		 (add-to-ordered-list 'company-backends 'company-files -1)))

  (add-to-list 'matlab-shell-mode-hook
	       (lambda ()
		 ;; handle company-backends
		 (make-local-variable 'company-backends)
		 (delete 'company-files company-backends)
		 (add-to-ordered-list 'company-backends '(company-dabbrev company-matlab) 0)
		 (add-to-ordered-list 'company-backends 'company-files -1)
		 ;; band matlab-doc key
		 (local-set-key (kbd "C-c h") 
				'matlab-view-current-word-doc-in-another-buffer))))

(provide 'matlab-mode)
