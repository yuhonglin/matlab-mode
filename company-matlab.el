;;; company-matlab.el --- support for the Matlab programming language

;; Copyright (C) 2016  yuhonglin

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

(defun company-matlab-process-received-data (inarg)
  (mapcar 'car 
	  (mapcar 'cdr 
		  (s-match-strings-all "'\\([^ \t\n']+\\)'" inarg))))


;; some are copied from matlab-shell-collect-command-output function
(defun company-matlab-get-candidates (arg)
  (if (and matlab-server-process
	   (eq (process-status matlab-server-process) 'run))  
      (let ((res (company-matlab-process-received-data
		  (matlab-send-request-sync 
		   (concat "tmp=com.mathworks.jmi.MatlabMCR;tmp.mtFindAllTabCompletions('" 
			   arg "'," (int-to-string (length arg)) ",0)")))))
	(if (eq res nil)
	    ;;  nil
	    (company-other-backend)
	  res))))


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


(defun company-matlab-company-cancel-hook (arg))

(add-to-list 'company-completion-cancelled-hook 'company-matlab-company-cancel-hook)

(provide 'company-matlab)
