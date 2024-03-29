;;; rev-mode.el --- An Emacs Engine for RevBayes -*- lexical-binding: t; -*-

;; Copyright (C) 2018  Gustavo  A. Ballen

;; Author: Gustavo A. Ballen <gaballench@gmail.com>
;; Keywords: lisp, languages, files
;; Created: 4 May 2018
;; Version: 0.0.1
;; URL: https://github.com/gaballench/rev-mode

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

;; The package rev-mode provides a platform for interactive work with the Rev language of RevBayes, a program for bayesian evolutionary analyses.  It provides the usual advantages of a major mode, such as syntax highlight and text redirection to RevBayes processes.  This project itself was heavily based on `essh' and `julia-mode' although it is becoming less similar to these with time.

;; Installation is a simple process.  Just clone the github repository and add the following to your .emacs file:
;(add-to-list 'load-path "/path/to/rev-mode")
;(require 'rev-mode)
;;; associate the .Rev extension to rev-mode
;(setq auto-mode-alist
;        (cons '("\\.Rev" . rev-mode) auto-mode-alist))

;;; Code:

;;;; define autoload as an instance of sh-mode as suggested here https://www.gnu.org/software/emacs/manual/html_node/elisp/Derived-Modes.html
;;;###autoload
(define-derived-mode rev-mode sh-mode "rev mode"
  "Major mode for editing and evaluating Rev")


;;;;;;;;;;;;;;;;;;;;;;;;;
; run-rev modified from run-julia in julia-mode. working properly
;; Code for `inferior-rev-mode'
(require 'comint)

(defcustom rev-program "rb"
  "Path to the program used by `inferior-rev'."
  :type 'string
  :group 'rev)

(defcustom rev-arguments '()
  "Commandline arguments to pass to `rev-program'."
  :type 'string
  :group 'rev)

(defvar rev-prompt-regexp "^\\w*> "
  "Regexp for matching `inferior-rev' prompt.")

(defvar inferior-rev-mode-map
  (let ((map (nconc (make-sparse-keymap) comint-mode-map)))
    ;; example definition
    (define-key map (kbd "TAB") 'rev-latexsub-or-indent)
    map)
  "Basic mode map for `inferior-rev-mode'.")

;;;###autoload
(defun inferior-rev ()
    "Run an inferior instance of `rev' inside Emacs."
    (interactive)
    (let ((rev-program rev-program)
          (buffer (get-buffer-create "*rev*")))
      (when (not (comint-check-proc "*rev*"))
            (apply #'make-comint-in-buffer "rev" "*rev*" rev-program rev-arguments))
      (pop-to-buffer-same-window "*rev*")
      (inferior-rev-mode)))

(defun inferior-rev--initialize ()
    "Helper function to initialize `inferior-rev'."
    (setq comint-use-prompt-regexp t))

(define-derived-mode inferior-rev-mode comint-mode "rev"
  "Major mode for `inferior-rev'.

\\<inferior-rev-mode-map>"
  nil "rev"
  (setq comint-prompt-regexp rev-prompt-regexp)
  (setq comint-prompt-read-only t)
  ;(set (make-local-variable 'font-lock-defaults) '(rev-font-lock-keywords t))
  (set (make-local-variable 'paragraph-start) rev-prompt-regexp)
  (set (make-local-variable 'indent-line-function) 'rev-indent-line))

(add-hook 'inferior-rev-mode-hook 'inferior-rev--initialize)

;;;###autoload
(defalias 'run-rev #'inferior-rev
  "Run an inferior instance of `rev' inside Emacs.")

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;


;;;;;;;;;;;;;;;;;code modified from essh.el, it turns out to contain code that the developer of essh borrowed from sh-mode.el
;; function taken from ess package
(defun rev-next-code-line (&optional arg)
  "Move ARG lines of code forward (backward if ARG is negative).
Skips past all empty and comment lines.	 Default for ARG is 1.

On success, return 0.  Otherwise, go as far as possible and return -1."
  (interactive "p")
  (or arg (setq arg 1))
  (beginning-of-line)
  (let ((n 0)
	(inc (if (> arg 0) 1 -1)))
    (while (and (/= arg 0) (= n 0))
      (setq n (forward-line inc)); n=0 is success
      (while (and (= n 0)
		  (looking-at "\\s-*\\($\\|\\s<\\)"))
	(setq n (forward-line inc)))
      (setq arg (- arg inc)))
    n))

(defun process-rev ()
  "Return a list with existing shell process."
  (interactive)
  (setq listpr (process-list))
  (setq lengthpr (length listpr))
  (setq i 0)
  (setq listshellp '())
  (while (< i lengthpr)
    (setq pos (string-match "rev" (prin1-to-string (elt listpr i))))
    (if pos (add-to-list 'listshellp (process-name (get-process (elt listpr i)))))
    (setq i (+ 1 i)))
  listshellp)


(defun process-rev-choose ()
  "Return which process to use."
(interactive)
(setq outpr 0)
(setq cbuf (current-buffer))
(setq shelllist (process-rev))
(setq shelln (length shelllist))
(if (eq shelln 0)
    (progn (shell)
	   (switch-to-buffer cbuf)
	   (setq outpr (get-process "rev"))
	   (sleep-for 0.5)))
(if (eq shelln 1)
    (setq outpr (get-process (elt shelllist 0))))
(if (> shelln 1)
(progn
(setq proc (completing-read "Send code to:" shelllist nil t (elt shelllist 0)))
(setq outpr (get-process proc))))
outpr)


(defun rev-eval-line (sprocess command)
  "Evaluate SPROCESS with a redirected COMMAND.
Argument SPROCESS evaluates a single command.
Argument COMMAND is a string to be redirected."
  (setq sbuffer (process-buffer sprocess))
  (setq command (concat command "\n"))
  (accept-process-output sprocess 0 10)
  (with-current-buffer sbuffer
    (end-of-buffer) ;point is not seen being moved (unless sbuffer is focused)
    (insert command)			;pastes the command to shell
    (set-marker (process-mark sprocess) (point-max))
    (process-send-string sprocess command)
    ;; (accept-process-output sprocess 0 10)
    ))

; commented function, maybe not needed at all
;(defun shell-cd-current-directory ()
;  "Changes the shell working directory to the current buffer's one."
;  (interactive)
;  (setq sprocess (process-shell-choose))
;  (setq com (format "cd %s" (file-name-directory default-directory)))
;  (shell-eval-line sprocess com))


(defun pipe-line-to-rev (&optional step)
  "Evaluate the current line to the rev interpreter.
Optional argument STEP ."
  (interactive ())
  (if (process-rev) nil
		  (run-rev))
  (setq com (buffer-substring (point-at-bol) (point-at-eol)))
  (if (> (length com) 0)
      (progn
	(setq sprocess (process-rev-choose))
	(rev-eval-line sprocess com)
	(when step (rev-next-code-line)))
    (message "No command in this line")))

(defun pipe-line-to-rev-and-step ()
  "Evaluate the current line to the rev interpreter and go to next line."
  (interactive)
  (if (process-rev) nil
		  (run-rev))
  (pipe-line-to-rev t))

(defun pipe-region-to-rev (start end)
  "Sends a region to the rev interpreter.
Argument START .
Argument END ."
  (interactive "r")
  (if (process-rev) nil
		  (run-rev))
  (setq com (buffer-substring start end))	       ;reads command
  (setq lcom (length com))		       ;count chars
  (setq lastchar (substring com (1- lcom) lcom)) ;get last char
  (unless (string-match "\n" lastchar) ;if last char is not "\n", then...
    (setq com (concat com "\n")))	     ;...add it!
  (setq sprocess (process-rev-choose))
  (setq sbuffer (process-buffer sprocess))
  (while (> (length com) 0)
    (setq pos (string-match "\n" com))
    (setq scom (substring com 0 pos))
    (setq com (substring com (min (length com) (1+ pos))))
    (rev-eval-line sprocess scom)
    (accept-process-output sprocess 0 10)
    ))


(defun pipe-buffer-to-rev ()
  "Evaluate whole buffer to the rev interpreter."
  (interactive)
  (if (process-rev) nil
		  (run-rev))
  (pipe-region-to-rev (point-min) (point-max)))

(defun pipe-function-to-rev ()
"Evaluate function to the rev interpreter."
(interactive)
  (if (process-rev) nil
		  (run-rev))
(setq beg-end (essh-beg-end-of-function))
(if beg-end
    (save-excursion
      (setq beg (nth 0 beg-end))
      (setq end (nth 1 beg-end))
      (goto-line beg)
      (setq origin (point-at-bol))
      (goto-line end)
      (setq terminal (point-at-eol))
      (pipe-region-to-rev origin terminal))
  (message "No function at current point.")))

(defun rev-beg-end-of-function ()
  "Return the lines where the function start and ends.  If there is no function at current line, it return nil."
  (interactive)
  (setq curline (line-number-at-pos))	;current line
  (setq curcom (buffer-substring (point-at-bol) (point-at-eol)))
  (setq pos (string-match "function" curcom))
  (save-excursion
    (if pos
	(progn
	  (setq beg curline))
      (progn
	(while (not pos)
	  (setq curline (1- curline))	;current line
	  (previous-line)			;go to previous line
	  (setq curcom (buffer-substring (point-at-bol) (point-at-eol)))
	  (setq pos (string-match "function" curcom)))
      (setq beg curline)))
    (beginning-of-line)
    (forward-list)			; move pointer to first matching brace
    (setq end (line-number-at-pos)))
  ;; (message (format  "%d %d" beg end))
  (if (and (<= (line-number-at-pos) end) (>= (line-number-at-pos) beg))
      (list beg end)
    nil))
;;;;;;;;;;;;;;

;; Keybindings
(defun rev-mode-sh-hook ()                                             "."
  (define-key sh-mode-map "\C-c\C-r" 'pipe-region-to-rev)        ;;
  (define-key sh-mode-map "\C-c\C-b" 'pipe-buffer-to-rev)        ;;
  (define-key sh-mode-map "\C-c\C-j" 'pipe-line-to-rev)          ;;
  (define-key sh-mode-map "\C-c\C-n" 'pipe-line-to-rev-and-step) ;;
  (define-key sh-mode-map "\C-c\C-f" 'pipe-function-to-rev))      ;;
;  (define-key sh-mode-map "\C-c\C-d" 'rev-cd-current-directory)) ;;
(add-hook 'sh-mode-hook 'rev-mode-sh-hook)
;; setup files ending in “.rev” to open in rev-mode
(add-to-list 'auto-mode-alist '("\\.rev\\'" . rev-mode))

(provide 'rev-mode)
;;; rev-mode.el ends here
