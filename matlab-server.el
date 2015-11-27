;;; matlab-server.el --- support for the Matlab programming language

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

;; The procedure of communicating with MATLAB is as follows,
;;   1. First, create a socket server in emacs and keep listening
;;   2. When need info from matlab, send command to the matlab process
;;      to run source code in folder "./toolbox/"
;;   3. The .m file in folder toolbox will send emacs the information by
;;      socket.

;; Things need to note
;;   1. The sentinel functions are called when socket is either opened
;;      and closed in the .m files.


;;; Code:

(require 's)
(require 'matlab)

;; The port to be used. Todo: use a list of candidates instead?
(defvar matlab-server-port "10000"
  "port of the matlab server (should be string)")

;; This variable is increased by 1 every time the socket
;; is closed. It is used to determine whether the last connection 
;; is finished.
(defvar matlab-server-nth-connection-done 0
  "how many connections are done")

;; This variable is set t when socket is opened and it is set nil
;; when socket is closed.
(defvar matlab-server-connected nil
  "whether the server is connected to matlab")

;; This variable contains the contents received from the server.
(defvar matlab-server-content-received ""
  "the content sent from matlab")

;; If t, matlab output will not appear in terminal.
(defvar matlab-server-if-turn-off-comint-output nil
  "whether to turn off lock output")

;; Start a server
(defun matlab-server-start nil
    "starts an emacs matlab server"
    (interactive)
    (unless (process-status "matlab-server")
      (make-network-process
       :name "matlab-server"
       :buffer "*matlab-server*"
       :family 'ipv4
       :service (string-to-int matlab-server-port)
       :sentinel 'matlab-server-sentinel
       :filter 'matlab-server-filter
       :server 't)))

;; stop the server
(defun matlab-server-stop nil
  "stop an emacs matlab server"
  (interactive)
  (while  matlab-server-clients
    (delete-process (car (car matlab-server-clients)))
    (setq matlab-server-clients (cdr matlab-server-clients)))
  (delete-process "matlab-server")
  )

;; The string is not received at once, so keep appending the strings.
(defun matlab-server-filter (proc string)
  (if matlab-server-connected
      (setq matlab-server-content-received 
	    (concat matlab-server-content-received string))))

;; This func is called when socket is opened or closed.
(defun matlab-server-sentinel (proc msg)
  (if (string= msg "connection broken by remote peer\n")
      ;; when the socket is closed.
      (progn
	(setq matlab-server-nth-connection-done
	      (+ matlab-server-nth-connection-done 1))
	(setq matlab-server-connected nil))
    (if (string= msg "open from 127.0.0.1\n")
	;; when the socket is opened.
	(progn
	  (setq matlab-server-content-received "")
	  (setq matlab-server-connected t)))))

;; check whether matlab server is ready for receiving new command
(defun matlab-server-ready-for-command-p ()
  "whether matlab process is ready for accepting new command"
  (and (get-process "matlab-server") ;; matlab server is up
       (get-process "MATLAB")        ;; matlab process is up
       (not matlab-server-if-turn-off-comint-output) ;; matlab terminal is not locked
       (matlab-on-prompt-p)))        ;; copied from matlab.el test whether the last line is like ">>> *"


;; Get the matlab server status, this is an improved version of
;; matlab-server-ready-for-command-p in that it provides the reasons
;; if server is not ready.
(defun matlab-server-get-status ()
  "get the status of matlab prompt"
  (if (not (get-process "matlab-server"))
      "matlab server is down, try M-x matlab-server-start."
    (if (not (get-process "MATLAB"))
	"matlab prompt is not run, try M-x matlab-shell."
      (if matlab-server-if-turn-off-comint-output
	  "matlab is busy."
	(if (save-current-buffer
	      (set-buffer "*MATLAB*")
	      (not (matlab-on-prompt-p)))
	    "matlab is busy."
	  "ready")))))


;; The most important inferace, call it everytime when you want to get the 
;; response of some matlab command and does not show in terminal.
(defun matlab-server-get-response-of-command (s)
  "TODO: cancel unfinished last command?"
    (progn
      (setq matlab-server-if-turn-off-comint-output t)

      (let ((old-num-done matlab-server-nth-connection-done))
	(process-send-string (get-buffer-process "*MATLAB*") s)
	(while (= old-num-done matlab-server-nth-connection-done)
	  (sleep-for .1)))
      (setq matlab-server-if-turn-off-comint-output nil)
      matlab-server-content-received))


;; Test if the message is and error message (meet error when processing the command in MATLAB)
;; As seen in the function, the .m files should follow such format "[matlabelerror]:blablabla".
(defun matlab-server-get-error-message-maybe (msg)
  "get the error msg. If this is not an error, return nil"
  (if (s-prefix-p "[matlabelerror]:" msg)
      (substring msg 17)))

;; Used to turn off echoing output of matlab.
(defun matlab-server-comint-prehook (s)
  (if (and (string= (buffer-name) "*MATLAB*")
	   matlab-server-if-turn-off-comint-output) "" s))

(add-to-list 'comint-preoutput-filter-functions 'matlab-server-comint-prehook)


(provide 'matlab-server)
;;; matlab-server.el ends here
