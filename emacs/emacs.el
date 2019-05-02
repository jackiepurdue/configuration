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

(require 'whitespace)
(setq whitespace-line-column 80) ;; limit line length
(setq whitespace-style '(face lines-tail))

(add-hook 'prog-mode-hook 'whitespace-mode)

(global-whitespace-mode +1)

(require 'org)
(global-set-key (kbd "C-c c") 'org-capture)
(setq todo-notes-file-self "~/focal/oper/tasks/_refile.org")
(setq journal-notes-file-self "~/focal/oper/notes/_journal.org")
(setq refile-notes-file-self "~/focal/oper/notes/_refile.org")
(setq org-capture-templates
  (quote (
    ("t" "Task" entry (file todo-notes-file-self)
     "** TODO %?
added: %U"
)
    ("j" "Journal" entry (file+datetree journal-notes-file-self)
     "* %?")
    ("r" "Refile" entry (file refile-notes-file-self)
     "* TODO %?")

)))

(setq org-agenda-files (list todo-notes-file-self refile-notes-file-self))

(setq org-tag-alist '(
  ("sometime" . ?s)
  ("urgent" . ?u)
  ("minor" . ?m)
  ("important" . ?i)
  ("evident" . ?e)
  ("uncertain" . ?u)))

(setq org-link-search-must-match-exact-headline nil)

(require 'org-ref)

(require 'company)
(add-hook 'after-init-hook 'global-company-mode)

(add-to-list 'custom-theme-load-path "~/.emacs.d/themes/")
(load-theme 'monokai t)

(setq org-todo-keywords '((sequence "TODO" "WAITING" "REFILE" "DONE")))
