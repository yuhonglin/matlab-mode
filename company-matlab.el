;;; company-matlab.el --- support for the Matlab programming language

;; Copyright (C) 2015  yuhonglin

;; Author: yuhonglin <yuhonglin1986@gmail.com>
;; Keywords: languages, terminals

;; This program is free software; you can redistribute it and/or modify
;; it under the terms of the GNU General Public License as published by
;; the Free Software Foundation, either version 3 of the License, or
;; (at your option) any later version.

;; This program is distributed in the hope that it will be useful,
;; but WITHOUT ANY WARRANTY; without even the implied warranty of
;; MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
;; GNU General Public License for more details.

;; You should have received a copy of the GNU General Public License
;; along with this program.  If not, see <http://www.gnu.org/licenses/>.

;;; Commentary:

;; The company backend of matlab mode.
;; It is based on matlab-server.el.

;;; Code:

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
	    ;; nil)
	    (company-other-backend))
	(let ((res (company-matlab-process-received-data
		    (matlab-server-get-response-of-command 
		     (concat "matlabeldocomplete('" arg "', " matlab-server-port ")\n")) arg)))
	  (if (eq res nil)
	    ;;  nil
	    (company-other-backend)
	    res))))))


(defun company-matlab-grab-symbol ()
  (let* ((prefix (buffer-substring (point) 
				  (save-excursion (skip-chars-backward "a-zA-Z0-9._")
						  (point)))))
    (if (or (= (length prefix) 0)
	    (string= (substring prefix 0 1) ".")
	    (string= (substring prefix 0 1) "/"))
	nil
      prefix)))


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


(defun company-matlab-company-cancel-hook (arg)
  (if (or (eq major-mode 'matlab-mode)
	 (string= (buffer-name) "*MATLAB*"))
      (setq company-matlab-is-completing nil)))

(add-to-list 'company-completion-cancelled-hook 'company-matlab-company-cancel-hook)



(provide 'company-matlab)
