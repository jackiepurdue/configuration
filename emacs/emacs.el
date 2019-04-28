(package-initialize)
(menu-bar-mode -1)

(setq-default mode-line-format nil)

(setq backup-directory-alist `(("." . "~/.emacs.save.d")))

(setq backup-by-copying t)

(setq delete-old-versions t
      kept-new-versions 6
      kept-old-versions 2
        version-control t)

(global-set-key [f5] 'linum-mode)

(defun on-after-init ()
  (unless (display-graphic-p (selected-frame))
    (set-face-background 'default "unspecified-bg" (selected-frame))))

(add-hook 'window-setup-hook 'on-after-init)


(require 'org)
(global-set-key (kbd "C-c c") 'org-capture)
(setq todo-notes-file-self "~/oper/notes/todo.org")
(setq journal-notes-file-self "~/oper/notes/journal.org")
(setq org-capture-templates
  (quote (
    ("t" "TODO" entry (file todo-notes-file-self)
     "* TODO %?")
    ("j" "Journal" entry (file+datetree journal-notes-file-self)
     "* %?")
)))

(require 'org-ref)

(require 'company)
(add-hook 'after-init-hook 'global-company-mode)

(add-to-list 'custom-theme-load-path "~/.emacs.d/themes/")
(load-theme 'monokai t)

(setq org-todo-keywords '((sequence "TODO" "WAITING" "DONE")))
