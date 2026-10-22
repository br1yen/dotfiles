;; -*- lexical-binding: t; -*-

;; Restore GC after early-init
(add-hook 'emacs-startup-hook
          (lambda () (setq gc-cons-threshold (* 16 1024 1024))))


;; Set up package.el to work with MELPA
(require 'package)
(add-to-list 'package-archives
             '("melpa" . "https://melpa.org/packages/"))
(package-initialize)
(require 'use-package-ensure)
(setq use-package-always-ensure t)


;; Emacs
(use-package emacs
  :ensure nil
  :config
  (blink-cursor-mode -1)
  (setq inhibit-startup-screen t)
  (setq initial-scratch-message nil)
  (setq initial-major-mode 'fundamental-mode)

  (setq create-lockfiles nil) 
  (setq backup-directory-alist `(("." . ,(expand-file-name "backups/" user-emacs-directory))))
  (setq auto-save-file-name-transforms `((".*" ,(expand-file-name "auto-save/" user-emacs-directory) t)))
  (setq auto-save-list-file-prefix (expand-file-name "auto-save/.saves-" user-emacs-directory))
  (setq custom-file (make-temp-file "emacs-custom-"))
  (setq inhibit-startup-screen t)
  (setq initial-scratch-message nil)
  (setq initial-major-mode 'fundamental-mode)
  (setq inhibit-startup-echo-area-message user-login-name)
  (setq-default display-line-numbers-width 4)
  (setq display-line-numbers-type 'visual)
  (setq display-line-numbers-current-absolute t)

  (add-hook 'prog-mode-hook #'display-line-numbers-mode)
  (add-hook 'text-mode-hook #'display-line-numbers-mode)
  (add-hook 'prog-mode-hook #'visual-line-mode)
  (add-hook 'text-mode-hook #'visual-line-mode)

  (set-face-attribute 'default nil :family "UbuntuMono Nerd Font" :height 120)
  (set-face-attribute 'fixed-pitch nil :family "UbuntuMono Nerd Font" :height 120)
  (set-face-attribute 'variable-pitch nil :family "Ubuntu Sans" :height 120)
  (set-fontset-font t 'emoji "Noto Color Emoji")
  (set-fontset-font t 'han "Noto Sans CJK JP"))


;; Code wrapping respects indent
(use-package adaptive-wrap
  :hook (text-mode . adaptive-wrap-prefix-mode))


;; Centered paragraphs
(use-package visual-fill-column
  :hook (visual-line-mode . visual-fill-column-mode)
  :config
  (setq-default visual-fill-column-width 100)
  (setq-default visual-fill-column-center-text t))


;; Org mode
(use-package org
  :ensure nil
  :custom
  (org-directory (expand-file-name "~/sync/org/"))
  (org-agenda-files (list org-directory))
  (org-agenda-start-with-log-mode t)
  (org-log-done 'time)
  (org-todo-keywords '((sequence "TODO(t)" "|" "DONE(d)")))
  :config
  (make-directory org-directory t)
  (setq org-capture-templates
	'(("t" "Task" entry (file "~/sync/org/inbox.org")
	   "* TODO %?\n  %U\n")
	  ("n" "Note" entry (file "~/sync/org/inbox.org")
	   "* %?\n  %U\n"))))


;; Evil
(use-package evil
  :init
  (setq evil-respect-visual-line-mode t)
  (setq evil-want-integration t)
  (setq evil-want-keybinding nil)
  (setq evil-undo-system 'undo-redo)
  (setq evil-want-C-u-scroll t)
  (setq evil-want-C-u-delete t)
  (setq evil-want-Y-yank-to-eol t)
  (setq evil-search-module 'evil-search)
  (setq evil-flash-delay 0)
  (setq evil-ex-hl-update-delay 0.00)
  (setq evil-shift-width 2)
  (setq evil-v$-excludes-newline t)
  (setq evil-split-window-below t)
  (setq evil-vsplit-window-right t)
  (setq evil-echo-state nil)
  :config
  (evil-set-leader '(normal motion) (kbd "SPC"))

  (advice-add 'evil-force-normal-state :after #'evil-ex-nohighlight)

  (evil-define-key 'normal 'global (kbd "<leader>SPC") 'execute-extended-command)

  (evil-define-key 'normal 'global (kbd "<leader>f") 'find-file)
  (evil-define-key 'normal 'global (kbd "<leader>d") 'dired-jump)
  (evil-define-key 'normal 'global (kbd "<leader>b") 'buffer-menu)

  (evil-define-key 'normal 'global (kbd "<leader>el") 'eval-last-sexp)
  (evil-define-key 'normal 'global (kbd "<leader>eb") 'eval-buffer)
  (evil-define-key 'normal 'global (kbd "<leader>ed") 'eval-defun)
  (evil-define-key 'normal 'global (kbd "<leader>ee") 'eval-expression)
  (evil-define-key 'normal 'global (kbd "<leader>er") 'eval-region)

  (evil-define-key 'normal 'global (kbd "<leader>oa") #'org-agenda)
  (evil-define-key 'normal 'global (kbd "<leader>oc") #'org-capture)

  (evil-mode))

(use-package evil-collection
  :after evil
  :init
  (setq evil-collection-key-blacklist '("SPC"))
  :custom
  (evil-collection-setup-minibuffer t)
  (evil-collection-calendar-want-org-bindings t)
  (evil-collection-bind-tab-p t)
  :config
  (evil-collection-init))

(use-package evil-commentary
  :after evil
  :config (evil-commentary-mode))

;;; Colors
(use-package doom-themes
  :custom
  (doom-themes-enable-bold nil)
  (doom-themes-enable-italic nil)
  :config
  (load-theme 'doom-one t)
  (doom-themes-org-config))
