;;; init.el --- Init -*- lexical-binding: t; -*-

;; Package.el
(require 'package)
(package-initialize)
(unless package-archive-contents
  (package-refresh-contents))
(require 'use-package)


;;; Emacs
(use-package emacs
  :ensure nil
  :config
  (setq which-func-update-delay 1.0)
  (defalias #'view-hello-file #'ignore)

  ;; I don't know
  (setq prettify-symbols-unprettify-at-point 'right-edge
        whitespace-line-column nil
        eval-expression-print-length nil
        eval-expression-print-level nil
        visible-bell nil
        ring-bell-function #'ignore
        x-underline-at-descent-line t
        truncate-string-ellipsis "..."
        display-time-default-load-average nil
        mouse-yank-at-point t)

  ;; Line numbers mode
  (setq-default display-line-numbers-width 3
                display-line-numbers-widen t
                display-line-numbers-current-absolute t
                display-line-numbers-type 'visual)

  ;; Startup screen
  (setq inhibit-startup-screen t
	initial-scratch-message nil
	initial-major-mode 'fundamental-mode
    inhibit-startup-echo-area-message user-login-name)

  ;; Minbuffer  
  (setq enable-recursive-minibuffers t
      enable-local-eval nil
      minibuffer-prompt-properties
      '(read-only t intangible t cursor-intangible t face minibuffer-prompt))
  (add-hook 'minibuffer-setup-hook #'cursor-intangible-mode)

  ;; Input
  (setq default-input-method nil
	native-comp-async-query-on-exit t
	read-answer-short t
	revert-buffer-quick-short-answers t)

  (if (boundp 'use-short-answers)
      (setq use-short-answers t)
    (advice-add 'yes-or-no-p :override #'y-or-n-p))


  ;; Backups
  (setq create-lockfiles nil
        make-backup-files nil
        backup-directory-alist `(("." . ,(expand-file-name "backups/" user-emacs-directory)))
        tramp-backup-directory-alist backup-directory-alist
        backup-by-copying-when-linked t
        backup-by-copying t
        delete-old-versions t
        version-control t 
        kept-new-versions 5
        kept-old-versions 5)

  ;; Other file stuff
  (setq custom-file (make-temp-file "emacs-custom-")
        epg-pinentry-mode 'loopback
        auth-sources '("~/.authinfo.gpg")
        find-library-include-other-files nil
        delete-by-moving-to-trash (not noninteractive)
        remote-file-name-inhibit-delete-by-moving-to-trash t
        find-file-suppress-same-file-warnings t
        find-file-visit-truename t
        vc-follow-symlinks t
        split-width-threshold 170
        split-height-threshold nil
        large-file-warning-threshold (* 100 1024 1024))

  ;; Auto save
  (setq auto-save-no-message t)
  (when noninteractive
    (setq enable-dir-local-variables nil)
    (setq-default case-fold-search nil))
  (setq
   auto-save-include-big-deletions t
   auto-save-list-file-prefix (expand-file-name "auto-save/" user-emacs-directory)
   tramp-auto-save-directory (expand-file-name "tramp-autosave/" user-emacs-directory))

  ;; Undo
  (setq undo-limit (* 13 160000)
        undo-strong-limit (* 13 240000)
        undo-outer-limit (* 13 24000000))

  ;;; Show-paren
  (setq show-paren-delay 0.1
        show-paren-highlight-openparen t
        show-paren-when-point-inside-paren t
        show-paren-when-point-in-periphery t)

  ;; Buffers
  (setq custom-buffer-done-kill t
        next-line-add-newlines nil
        bookmark-save-flag 1
        uniquify-buffer-name-style 'forward
        redisplay-skip-fontification-on-input t)

  ;; Imenu
  (setq-default imenu-auto-rescan t)
  (setq imenu-max-item-length 160)

  ;; Comint
  (setq ansi-color-for-comint-mode t
        comint-prompt-read-only t
        comint-buffer-maximum-size 4096
        comint-move-point-for-output t
        comint-scroll-to-bottom-on-output t
        comint-scroll-to-bottom-on-input t)

  ;;; Tramp
  (setq tramp-verbose 1
        remote-file-name-inhibit-cache 50
        remote-file-name-inhibit-locks t
        remote-file-name-inhibit-auto-save-visited t)

  ;; VC
  (setq vc-git-print-log-follow t
        vc-handled-backends '(Git SVN Hg RCS)
        vc-git-diff-switches '("--histogram"))

  ;;; Compilation
  (setq compilation-ask-about-save nil
        compilation-always-kill t
        compilation-max-output-line-length 2048
        compilation-scroll-output 'first-error
        confirm-nonexistent-file-or-buffer nil)

  (add-hook 'compilation-filter-hook 'ansi-color-compilation-filter)

  (defun setup-auto-save-transforms ()
    "Configure `auto-save-file-name-transforms' for local and remote files.
This should be called after changing `auto-save-list-file-prefix'."
    (setq auto-save-file-name-transforms
          `(("\\`/[^/]*:\\([^/]*/\\)*\\([^/]*\\)\\'"
             ,(file-name-concat auto-save-list-file-prefix "tramp-\\2-") sha1)
            ("\\`/\\([^/]+/\\)*\\([^/]+\\)\\'"
             ,(file-name-concat auto-save-list-file-prefix "\\2-") sha1)))
    (when (memq system-type '(windows-nt cygwin ms-dos))
      (push `("\\`\\(/\\|[a-zA-Z]:/\\|//\\)\\([^/]+/\\)*\\([^/]+\\)\\'"
              ,(file-name-concat auto-save-list-file-prefix "\\3-") sha1)
            auto-save-file-name-transforms)))

  (setup-auto-save-transforms)

  (when auto-save-default
    (let ((auto-save-dir (file-name-directory auto-save-list-file-prefix)))
      (unless (file-exists-p auto-save-dir)
        (with-file-modes #o700
          (make-directory auto-save-dir t)))))

  (setq kill-buffer-delete-auto-save-files t
        kill-do-not-save-duplicates t
        save-interprogram-paste-before-kill t)

  ;; Revert other buffers
  (setq global-auto-revert-non-file-buffers t
        global-auto-revert-ignore-modes '(Buffer-menu-mode))

  ;; Recentf
  (setq recentf-max-saved-items 210
        recentf-max-menu-items 15)

  ;; Saveplace
  (setq save-place-file (expand-file-name "saveplace" user-emacs-directory))


  ;; Savehist
  (setq history-length 300
        savehist-additional-variables
        '(register-alist 
          mark-ring global-mark-ring 
          search-ring regexp-search-ring))

  ;; Frames and windows
  (setq resize-mini-windows 'grow-only
        max-mini-window-height 0.33
        window-divider-default-bottom-width 1
        window-divider-default-places t
        window-divider-default-right-width 1)

  ;; Scrolling
  (setq fast-but-imprecise-scrolling t
        scroll-error-top-bottom t
        scroll-preserve-screen-position t
        scroll-conservatively 11
        auto-window-vscroll nil
        hscroll-margin 2
        hscroll-step 1)

  ;; Cursor
  (when (bound-and-true-p blink-cursor-mode)
    (blink-cursor-mode -1))
  (setq
   blink-matching-paren nil
   highlight-nonselected-windows nil)

  ;; Text editing, indent, font, and formatting
  (setq truncate-partial-width-windows nil
        tab-always-indent 'complete
        tab-first-completion 'word-or-paren-or-punct
        read-extended-command-predicate #'command-completion-default-include-p
        comment-multi-line t
        comment-empty-lines t
        sentence-end-double-space nil
        require-final-newline t
        lazy-highlight-initial-delay 0
        tabify-regexp (rx line-start (zero-or-more ?\t) ?\s (one-or-more blank))
        fill-nobreak-invisible t
        global-text-scale-adjust-resizes-frames nil
        delete-pair-blink-delay 0.03)
  (setq-default cursor-in-non-selected-windows nil
                word-wrap t
                truncate-lines t
                electric-indent-chars '(?\n ?\^?)
                indent-tabs-mode nil
                tab-width 4
                fill-column 80)

  ;; Filetype
  (setq python-indent-guess-indent-offset-verbose nil
        sh-indent-after-continuation 'always)

  ;; Dired and ls-lisp
  (setq dired-free-space nil
        dired-deletion-confirmer 'y-or-n-p
        dired-filter-verbose nil
        dired-recursive-deletes 'top
        dired-recursive-copies 'always
        dired-vc-rename-file t
        dired-create-destination-dirs 'ask
        dired-clean-confirm-killing-deleted-buffers nil
        auto-revert-remote-files nil
        dired-auto-revert-buffer 'dired-directory-changed-p)

  (defun local-dir-p (dir)
    "Return non-nil if DIR is a local directory."
    (not (file-remote-p dir)))

  (setq dired-do-revert-buffer #'local-dir-p
        dired-omit-verbose nil
        dired-omit-files "\\`[.]\\'"

        ls-lisp-verbosity nil
        ls-lisp-dirs-first t)

  ;; Ediff
  (setq ediff-window-setup-function 'ediff-setup-windows-plain
        ediff-split-window-function 'split-window-horizontally)

  ;; Diff
  (setq diff-font-lock-prettify t)

  ;; Help
  (setq apropos-do-all t
        help-enable-completion-autoload nil
        help-enable-autoload nil
        help-enable-symbol-autoload nil
        help-clean-buttons t
        help-window-select t)

  ;; Eglot
  (setq eglot-report-progress init-file-debug
        eglot-autoshutdown t
        eglot-sync-connect 0
        eglot-extend-to-xref t
        eglot-code-action-indications '(eldoc-hint))

  (if init-file-debug
      (setq eglot-events-buffer-config '(:size 2000000 :format full))
    (with-no-warnings
      (setq eglot-events-buffer-size 0))
    (setq jsonrpc-event-hook nil
          eglot-events-buffer-config '(:size 0 :format short)))

  ;; Flymake
  (setq flymake-show-diagnostics-at-end-of-line nil
        flymake-wrap-around nil)

  ;; hl-line-mode
  (setq hl-line-sticky-flag nil
        global-hl-line-sticky-flag nil)

  ;; icomplete
  (setq icomplete-compute-delay 0.01)

  ;; flyspell
  (setq flyspell-issue-message-flag nil
        flyspell-issue-welcome-flag nil)

  ;; ispell
  (setq text-mode-ispell-word-completion nil
        ispell-silently-savep t)

  ;; ibuffer
  (setq ibuffer-formats
        '((mark modified read-only locked
                " " (name 55 55 :left :elide)
                " " (size 8 -1 :right)
                " " (mode 18 18 :left :elide) " " filename-and-process)
          (mark " " (name 16 -1) " " filename)))

  ;; xref
  (setq xref-show-definitions-function 'xref-show-definitions-completing-read
        xref-show-xrefs-function 'xref-show-definitions-completing-read)

  ;; abbrev
  (setq
   abbrev-file-name (expand-file-name "abbrev_defs" user-emacs-directory)
   save-abbrevs 'silently)

  ;; dabbrev
  (setq dabbrev-upcase-means-case-search t

        dabbrev-ignored-buffer-modes
        '(archive-mode image-mode docview-mode tags-table-mode
                       pdf-view-mode tags-table-mode)

        dabbrev-ignored-buffer-regexps
        '("\\` "
          "\\(?:\\(?:[EG]?\\|GR\\)TAGS\\|e?tags\\|GPATH\\)\\(<[0-9]+>\\)?"))

  ;; Remove warnings from narrow-to-region, upcase-region...
  (dolist (cmd '(list-timers narrow-to-region narrow-to-page
                             upcase-region downcase-region
                             list-threads erase-buffer scroll-left
                             dired-find-alternate-file set-goal-column))
    (put cmd 'disabled nil))

  ;; Prog hook
  (add-hook 'prog-mode-hook
	    (lambda ()
	      (display-line-numbers-mode -1)
	      (visual-line-mode 1)))

  ;; Text hook
  (add-hook 'text-mode-hook
	    (lambda ()
	      (display-line-numbers-mode -1)
	      (variable-pitch-mode 1)
	      (visual-line-mode 1)))

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
              (call-interactively #'find-file)))

  (savehist-mode 1)
  (save-place-mode 1)
  (recentf-mode 1)
  (global-auto-revert-mode 1)
  (window-divider-mode 1))


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


;; Code wrapping respects indent
(use-package adaptive-wrap
  :hook (prog-mode . adaptive-wrap-prefix-mode))

;; Vertical menu
(use-package vertico
  :init
  (vertico-mode))

(use-package orderless
  :custom
  (completion-styles '(orderless basic))
  (completion-category-overrides '((file (styles partial-completion))))
  (completion-category-defaults nil)
  (completion-pcm-leading-wildcard t))

;;; Evil
;; (use-package evil
;;   :init
;;   (setq evil-respect-visual-line-mode t)
;;   (setq evil-want-integration t)
;;   (setq evil-want-keybinding nil)
;;   (setq evil-undo-system 'undo-redo)
;;   (setq evil-want-C-u-scroll t)
;;   (setq evil-want-C-u-delete t)
;;   (setq evil-want-Y-yank-to-eol t)
;;   (setq evil-search-module 'evil-search)
;;   (setq evil-flash-delay 0)
;;   (setq evil-ex-hl-update-delay 0.00)
;;   (setq evil-shift-width 4)
;;   (setq evil-v$-excludes-newline t)
;;   (setq evil-split-window-below t)
;;   (setq evil-vsplit-window-right t)
;;   (setq evil-echo-state nil)
;;   :config
;;   (evil-set-leader '(normal motion) (kbd "SPC"))
;; 
;;   (advice-add 'evil-force-normal-state :after #'evil-ex-nohighlight)
;; 
;;   (evil-define-key 'normal 'global (kbd "<leader>;") 'execute-extended-command)

;;   (evil-define-key 'normal 'global (kbd "<leader>f") 'find-file)
;;   (evil-define-key 'normal 'global (kbd "<leader>e") 'dired-jump)
;;   (evil-define-key 'normal 'global (kbd "<leader>b") 'buffer-menu)
;; 
;;   (evil-define-key 'normal 'global (kbd "<leader>oa") #'org-agenda)
;;   (evil-define-key 'normal 'global (kbd "<leader>oc") #'org-capture)
;; 
;;   (evil-define-key 'normal 'global (kbd "<leader>j") #'bookmark-jump)
;; 
;;   (evil-mode)
;; 
;;   (add-hook 'eshell-mode-hook
;; 	    (lambda ()
;; 	      (evil-local-set-key 'insert (kbd "RET") #'eshell-send-input)
;; 	      (evil-local-set-key 'insert (kbd "<return>") #'eshell-send-input))))

;; (use-package evil-collection
;;   :after evil
;;   :init
;;   (setq evil-collection-key-blacklist '("SPC"))
;;   :custom
;;   (evil-collection-setup-minibuffer t)
;;   (evil-collection-calendar-want-org-bindings t)
;;   (evil-collection-bind-tab-p t)
;;   :config
;;   (evil-collection-init))

;; (use-package evil-commentary
;;   :after evil
;;   :config (evil-commentary-mode))


;;; Colors
(use-package nordic-night-theme
  :config
  (load-theme 'nordic-night t)

  (let ((bg (face-background 'default)))
    (dolist (f '(window-divider
                 window-divider-first-pixel
                 window-divider-last-pixel))
      (set-face-attribute f nil :foreground bg :background bg)))

  (set-face-attribute 'line-number nil
                      :inherit '(font-lock-comment-face fixed-pitch))
  (set-face-attribute 'line-number-current-line nil
                      :inherit '(font-lock-comment-face fixed-pitch))
  (dolist (face '(font-lock-comment-face
                  font-lock-comment-delimiter-face
                  font-lock-doc-face))
    (set-face-attribute face nil
                        :weight 'normal)))

;; Local variables:
;; byte-compile-warnings: (not free-vars)
;; End:

;;; init.el ends here
