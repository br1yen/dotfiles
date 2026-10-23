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

  (add-hook 'prog-mode-hook
	    (lambda ()
	      (display-line-numbers-mode 1)
	      (visual-line-mode 1)))

  (add-hook 'text-mode-hook
	    (lambda ()
	      (display-line-numbers-mode 1)
	      (variable-pitch-mode 1)
	      (visual-line-mode 1)))

  (set-face-attribute 'default nil :family "Inconsolata Medium" :height 120)  
  (set-face-attribute 'fixed-pitch nil :family "Inconsolata Medium" :height 120)
  (set-face-attribute 'variable-pitch nil :family "Carlito")
  (set-fontset-font t 'emoji "Noto Color Emoji")
  (set-fontset-font t 'han "Noto Sans CJK JP")

  (set-face-attribute 'line-number nil :inherit 'fixed-pitch)
  (set-face-attribute 'line-number-current-line nil :inherit 'fixed-pitch)

  ;; Bookmarks
  (setq bookmark-alist
	'(("home"   (filename . "~/"))
	  ("org"    (filename . "~/sync/org/")) 
	  ("csc301" (filename . "~/sync/school/csc301/"))
	  ("rel103" (filename . "~/sync/school/rel103/"))
	  ("csc373" (filename . "~/sync/school/csc373/"))
	  ("snc185" (filename . "~/sync/school/snc185/"))
	  ("emacs"  (filename . "~/.emacs.d/"))
	  ("config" (filename . "~/.config/"))))
  (add-hook 'bookmark-after-jump-hook
	    (lambda ()
	      (setq-default default-directory default-directory)
	      (call-interactively #'find-file)))

  ;; Now I don't have to escape insert mode to execute
  (add-hook 'eshell-mode-hook
	    (lambda ()
	      (evil-local-set-key 'insert (kbd "RET") #'eshell-send-input)
	      (evil-local-set-key 'insert (kbd "<return>") #'eshell-send-input))))


;; Code wrapping respects indent
(use-package adaptive-wrap
  :hook (prog-mode . adaptive-wrap-prefix-mode))


;; Centered paragraphs
(use-package visual-fill-column
  ;; :hook (text-mode . visual-fill-column-mode)
  :config
  (setq-default visual-fill-column-width 100)
  (setq-default visual-fill-column-center-text t))



;; Org mode
(use-package org
  :ensure nil
  :custom
  ;; files
  (org-directory (expand-file-name "~/sync/org/"))
  (org-agenda-files (list org-directory))

  ;; workflow
  (org-agenda-start-with-log-mode t)
  (org-log-done 'time)
  (org-enforce-todo-dependencies t)
  (org-todo-keywords '((sequence "TODO(t)" "|" "DONE(d)")))

  ;; appearance
  (org-startup-indented nil)
  (org-adapt-indentation nil)
  (org-hide-emphasis-markers t)
  (org-pretty-entities t)
  (org-ellipsis " ...")
  (org-startup-folded 'content)
  (org-tags-column 0)

  ;; editing
  (org-return-follows-link t)
  (org-special-ctrl-a/e t)
  (org-src-fontify-natively t)
  (org-src-tab-acts-natively t)
  (org-src-preserve-indentation t)
  (org-edit-src-content-indentation 0)

  ;; agenda
  (org-agenda-start-on-weekday nil)
  (org-agenda-span 'week)
  (org-agenda-skip-scheduled-if-done t)
  (org-agenda-window-setup 'current-window)

  ;; capture
  (org-capture-templates
   '(("t" "Task" entry (file "~/sync/org/inbox.org")
      "* TODO %?\n%u\n%i")
     ("n" "Note" entry (file "~/sync/org/inbox.org")
      "* %?\n%u")
     ("j" "Journal" entry (file "~/sync/org/inbox.org")
      "* %U\n%?")))

  :config
  (make-directory org-directory t))


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
  (evil-define-key 'normal 'global (kbd "<leader>e") 'dired-jump)
  (evil-define-key 'normal 'global (kbd "<leader>b") 'buffer-menu)

  (evil-define-key 'normal 'global (kbd "<leader>oa") #'org-agenda)
  (evil-define-key 'normal 'global (kbd "<leader>oc") #'org-capture)

  (evil-define-key 'normal 'global (kbd "<leader>j") #'bookmark-jump)

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

(use-package nordic-night-theme
  :config
  (load-theme 'nordic-night t)

  (set-face-attribute 'line-number nil
		      :inherit 'font-lock-comment-face)
  (set-face-attribute 'line-number-current-line nil
		      :inherit 'font-lock-comment-face)
  (dolist (face '(font-lock-comment-face
		  font-lock-comment-delimiter-face
		  font-lock-doc-face))
    (set-face-attribute face nil
			:weight 'normal)))
