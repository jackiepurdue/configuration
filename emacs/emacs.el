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

(add-hook 'after-init-hook 'global-company-mode)

(add-to-list 'custom-theme-load-path "~/.emacs.d/themes/")

(load-theme 'monokai t)

(setq org-todo-keywords '((sequence "TODO" "IN-PROGRESS" "WAITING" "DONE")))
