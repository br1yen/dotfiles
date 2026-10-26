;;; init.el --- Init -*- lexical-binding: t; -*-

;;; Package.el
(require 'package)
(package-initialize)
(unless package-archive-contents
  (package-refresh-contents))
(require 'use-package)

;;; Emacs
(use-package emacs
  :ensure nil
  :custom
  ;; Startup
  (inhibit-startup-screen t)
  (initial-scratch-message nil)
  (initial-major-mode 'fundamental-mode)
  (inhibit-startup-echo-area-message user-login-name)
  
  ;; Editing and display
  (prettify-symbols-unprettify-at-point 'right-edge)
  (whitespace-line-column nil)
  (truncate-string-ellipsis "...")
  (x-underline-at-descent-line t)

  ;; Evaluation
  (eval-expression-print-length nil)
  (eval-expression-print-level nil)

  ;; Bell
  (ring-bell-function #'ignore)
  (visible-bell nil)

  ;; Mode line
  (display-time-default-load-average nil)

  ;; Mouse
  (mouse-yank-at-point t)
  (dired-mouse-drag-file t)

  ;; Minibuffer behavior
  (history-length 300)
  (savehist-additional-variables
   '(register-alist
     mark-ring
     global-mark-ring
     search-ring
     regexp-search-ring))
  (enable-local-eval nil)
  (minibuffer-prompt-properties
   '(read-only t
     intangible t
     cursor-intangible t
     face minibuffer-prompt))

  ;; Input
  (default-input-method nil)

  ;; Short answers
  (read-answer-short t)
  (revert-buffer-quick-short-answers t)

  ;; Backups
  (make-backup-files t)
  (backup-directory-alist
   `(("." . ,(expand-file-name "backups/" user-emacs-directory))))
  (backup-by-copying t)
  (version-control t)
  (delete-old-versions t)
  (kept-new-versions 5)
  (kept-old-versions 5)

  ;; File handling
  (delete-by-moving-to-trash (not noninteractive))
  (remote-file-name-inhibit-delete-by-moving-to-trash t)
  (large-file-warning-threshold (* 100 1024 1024))
  (vc-follow-symlinks t)
  (confirm-nonexistent-file-or-buffer nil)

  ;; Window management
  (split-width-threshold 170)
  (split-height-threshold nil)
  
  ;; Auto-saves
  (auto-save-no-message t)
  (auto-save-include-big-deletions t)
  (let ((dir (expand-file-name "auto-saves/" user-emacs-directory)))
    (make-directory dir t)
    (setq auto-save-list-file-prefix
          (expand-file-name "auto-saves/" user-emacs-directory)
          auto-save-file-name-transforms
        `((".*" ,dir t))))
  (tramp-auto-save-directory
   (expand-file-name "tramp-autosave/" user-emacs-directory))

  ;; Custom file
  (custom-file (expand-file-name "custom.el" user-emacs-directory))

  ;; Undo history limits
  (undo-limit (* 13 160000))
  (undo-strong-limit (* 13 240000))
  (undo-outer-limit (* 13 24000000))

  ;; Paren mode options
  (show-paren-delay 0.1)
  (show-paren-highlight-openparen t)
  (show-paren-when-point-inside-paren t)
  (show-paren-when-point-in-periphery t)

  ;; Buffers
  (custom-buffer-done-kill t)
  (next-line-add-newlines nil)
  (bookmark-save-flag 1)
  (uniquify-buffer-name-style 'forward)
  (redisplay-skip-fontification-on-input t)
  (auto-revert-verbose nil)
  (kill-buffer-delete-auto-save-files t)

  ;; Clipboard
  (kill-do-not-save-duplicates t)
  (save-interprogram-paste-before-kill t)

  ;; Imenu
  (imenu-auto-rescan t)
  (imenu-max-item-length 160)

  ;; Comint
  (ansi-color-for-comint-mode t)
  (comint-prompt-read-only t)
  (comint-buffer-maximum-size 4096)
  (comint-move-point-for-output t)
  (comint-scroll-to-bottom-on-output t)
  (comint-scroll-to-bottom-on-input t)

  ;; Tramp
  (tramp-verbose 1)
  (remote-file-name-inhibit-cache 50)
  (remote-file-name-inhibit-locks t)
  (remote-file-name-inhibit-auto-save-visited t)

  ;; VC
  (vc-git-print-log-follow t)
  (vc-git-diff-switches '("--histogram"))

  ;; Compilation
  (compilation-ask-about-save t)
  (compilation-always-kill t)
  (compilation-max-output-line-length 2048)
  (compilation-scroll-output 'first-error)

  ;; Auto-revert
  (global-auto-revert-non-file-buffers t)
  (global-auto-revert-ignore-modes '(Buffer-menu-mode))

  ;; Recent files
  (recentf-max-saved-items 210)
  (recentf-max-menu-items 15)

  ;; Remember cursor position
  (save-place-file (expand-file-name "saveplace" user-emacs-directory))

  ;; Frames and windows
  (resize-mini-windows 'grow-only)
  (max-mini-window-height 0.33)
  (window-divider-default-bottom-width 1)
  (window-divider-default-places t)
  (window-divider-default-right-width 1)

  ;; Scrolling
  (fast-but-imprecise-scrolling t)
  (scroll-error-top-bottom t)
  (scroll-preserve-screen-position t)
  (scroll-conservatively 11)
  (auto-window-vscroll nil)
  (hscroll-margin 2)
  (hscroll-step 1)

  ;; Editing and completion
  (truncate-partial-width-windows nil)
  (tab-always-indent 'complete)
  (tab-first-completion 'word-or-paren-or-punct)
  (read-extended-command-predicate
   #'command-completion-default-include-p)

  ;; Comments and formatting
  (comment-multi-line t)
  (comment-empty-lines t)
  (sentence-end-double-space nil)
  (require-final-newline t)
  (lazy-highlight-initial-delay 0.1)
  (tabify-regexp (rx line-start (zero-or-more ?\t) ?\s
                     (one-or-more blank)))
  (fill-nobreak-invisible t)
  (global-text-scale-adjust-resizes-frames nil)
  (delete-pair-blink-delay 0.03)

  ;; Default text behavior
  (cursor-in-non-selected-windows nil)
  (word-wrap t)
  (truncate-lines t)
  (electric-indent-chars '(?\n ?\^?))
  (indent-tabs-mode nil)
  (tab-width 4)
  (fill-column 80)

  ;; Filetype
  (python-indent-guess-indent-offset-verbose nil)
  (sh-indent-after-continuation 'always)

  ;; Dired and ls-lisp
  (dired-free-space nil)
  (dired-deletion-confirmer 'y-or-n-p)
  (dired-filter-verbose nil)
  (dired-recursive-deletes 'top)
  (dired-recursive-copies 'always)
  (dired-vc-rename-file t)
  (dired-create-destination-dirs 'ask)
  (dired-clean-confirm-killing-deleted-buffers nil)
  (auto-revert-remote-files nil)
  (dired-auto-revert-buffer 'dired-directory-changed-p)
  (dired-use-ls-dired nil)
  (ls-lisp-use-insert-directory-program nil)
  (ls-lisp-dirs-first t)
  (ls-lisp-verbosity nil)
  (ls-lisp-ignore-case t)

  ;; Ediff
  (ediff-window-setup-function 'ediff-setup-windows-plain)
  (ediff-split-window-function 'split-window-horizontally)

  ;; Diff
  (diff-font-lock-prettify t)

  ;; Help
  (apropos-do-all t)
  (help-enable-completion-autoload nil)
  (help-enable-autoload nil)
  (help-enable-symbol-autoload nil)
  (help-clean-buttons t)
  (help-window-select t)

  ;; Eglot
  (eglot-autoshutdown t)
  (eglot-sync-connect 0)
  (eglot-extend-to-xref t)
  (eglot-code-action-indications '(eldoc-hint))

  ;; Flymake
  (flymake-show-diagnostics-at-end-of-line nil)
  (flymake-wrap-around nil)

  ;; hl-line-mode
  (hl-line-sticky-flag nil)
  (global-hl-line-sticky-flag nil)

  ;; Icomplete
  (icomplete-compute-delay 0.01)

  ;; Flyspell
  (flyspell-issue-message-flag nil)
  (flyspell-issue-welcome-flag nil)

  ;; Ispell
  (text-mode-ispell-word-completion nil)
  (ispell-silently-savep t)

  ;; Ibuffer
  (ibuffer-formats
   '((mark modified read-only locked
           " " (name 55 55 :left :elide)
           " " (size 8 -1 :right)
           " " (mode 18 18 :left :elide)
           " " filename-and-process)
     (mark " " (name 16 -1) " " filename)))

  ;; Xref
  (xref-show-definitions-function 'xref-show-definitions-completing-read)
  (xref-show-xrefs-function 'xref-show-definitions-completing-read)

  ;; Abbrev
  (abbrev-file-name (expand-file-name "abbrev_defs" user-emacs-directory))
  (save-abbrevs 'silently)

  ;; Dabbrev
  (dabbrev-upcase-means-case-search t)
  (dabbrev-ignored-buffer-modes
   '(archive-mode image-mode docview-mode
     tags-table-mode pdf-view-mode))
  (dabbrev-ignored-buffer-regexps
   '("\\` "
     "\\(?:\\(?:[EG]?\\|GR\\)TAGS\\|e?tags\\|GPATH\\)\\(<[0-9]+>\\)?"))
  
  (ispell-program-name "aspell")
  (ispell-dictionary "en")

  :hook
  (after-init . recentf-mode)
  (after-init . delete-selection-mode)
  (after-init . save-place-mode)
  (after-init . savehist-mode)
  (after-init . global-auto-revert-mode)
  (after-init . window-divider-mode)
  (after-init . show-paren-mode)
  (after-init . column-number-mode)
  (after-init . electric-pair-mode)
  (after-init . prettify-symbols-mode)
  (minibuffer-setup . cursor-intangible-mode)
  (prog-mode . show-paren-mode)
  (prog-mode . visual-line-mode)
  (text-mode . visual-line-mode)
  (text-moide. variable-pitch-mode)
  (compilation-filter . ansi-color-compilation-filter)
  
  :config
  ;; Colors
  (load-theme 'modus-operandi t)
  
  ;; Noninteractive emacs or batch mode
  (when noninteractive
    (setq enable-dir-local-variables nil)
    (setq-default case-fold-search nil))

  ;; Turn off blink cursor mode
  (blink-cursor-mode -1)

  ;; Load custom if it exists
  (load custom-file t)

  ;; Remove warnings from narrow-to-region, upcase-region...
  (dolist (cmd '(list-timers narrow-to-region narrow-to-page
                             upcase-region downcase-region
                             list-threads erase-buffer scroll-left
                             dired-find-alternate-file set-goal-column))
    (put cmd 'disabled nil))

  ;; Fonts
  (set-face-attribute 'default nil :family "Inconsolata Medium" :height 120)  
  (set-face-attribute 'fixed-pitch nil :family "Inconsolata Medium" :height 120)
  (set-face-attribute 'variable-pitch nil :family "Carlito")
  (set-fontset-font t 'emoji "Noto Color Emoji")
  (set-fontset-font t 'han "Noto Sans CJK JP")
  (set-face-attribute 'line-number nil :inherit 'fixed-pitch)
  (set-face-attribute 'line-number-current-line nil :inherit 'fixed-pitch)

  ;; Bookmarks
  (require 'bookmark)
  (bookmark-maybe-load-default-file) ; load saved bookmarks first
  (dolist (bm '(("home"   . "~/")
                ("org"    . "~/sync/org/")
                ("csc301" . "~/sync/school/csc301/")
                ("rel103" . "~/sync/school/rel103/")
                ("csc373" . "~/sync/school/csc373/")
                ("snc185" . "~/sync/school/snc185/")
                ("emacs"  . "~/.emacs.d/")
                ("config" . "~/.config/")))
    (bookmark-store (car bm) `((filename . ,(cdr bm))) nil))
  (add-hook 'bookmark-after-jump-hook
            (lambda ()
              (call-interactively #'find-file))))

;;; Org mode
(use-package org
  :ensure nil
  :bind (("C-c a" . org-agenda)
         ("C-c c" . org-capture)
         ("C-c l" . org-store-link))
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
  (org-startup-indented t)
  (org-adapt-indentation nil)
  (org-hide-emphasis-markers t)
  (org-pretty-entities t)
  (org-ellipsis " ...")
  (org-startup-folded 'overview)
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


;; Code wrapping respects indent
(use-package adaptive-wrap
  :hook (prog-mode . adaptive-wrap-prefix-mode))

;; Completion
(use-package vertico
  :init
  (vertico-mode))

(use-package orderless
  :custom
  (completion-styles '(orderless basic))
  (completion-category-overrides '((file (styles partial-completion))))
  (completion-category-defaults nil)
  (completion-pcm-leading-wildcard t))

;;; Pdf-tools
(use-package pdf-tools
  :ensure t
  :pin melpa
  :mode ("\\.pdf\\'" . pdf-view-mode)
  :custom
  (pdf-view-display-size 'fit-page)
  (pdf-annot-activate-created-annotations t)
  :config
  (pdf-tools-install)
  :bind
  (:map pdf-view-mode-map
        ("=" . pdf-view-fit-page-to-window)))

;;; Devil mode
(use-package devil :config (global-devil-mode 1))

;;; Persistent undo
(use-package undo-fu-session :hook (after-init . undo-fu-session-global-mode))

;;; init.el ends here
