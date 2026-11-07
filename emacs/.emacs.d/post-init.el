;;; post-init.el --- Customizations -*- no-byte-compile: t; lexical-binding: t; -*-
(use-package compile-angel
  ;; Make sure this is before all other packages
  :demand t
  :config
  (setq compile-angel-verbose nil)


  ;; The following directive prevents compile-angel from compiling your init
  ;; files. If you choose to remove this push to `compile-angel-excluded-files'
  ;; and compile your pre/post-init files, ensure you understand the
  ;; implications and thoroughly test your code. For example, if you're using
  ;; the `use-package' macro, you'll need to explicitly add:
  ;; (eval-when-compile (require 'use-package))
  ;; at the top of your init file.
  (push "/init.el" compile-angel-excluded-path-suffixes)
  (push "/early-init.el" compile-angel-excluded-path-suffixes)
  (push "/pre-init.el" compile-angel-excluded-path-suffixes)
  (push "/post-init.el" compile-angel-excluded-path-suffixes)
  (push "/pre-early-init.el" compile-angel-excluded-path-suffixes)
  (push "/post-early-init.el" compile-angel-excluded-path-suffixes)

  ;; A local mode that compiles .el files whenever the user saves them.
  ;; (add-hook 'emacs-lisp-mode-hook #'compile-angel-on-save-local-mode)

  ;; A global mode that compiles .el files prior to loading them via `load' or
  ;; `require'. Additionally, it compiles all packages that were loaded before
  ;; the mode `compile-angel-on-load-mode' was activated.
  (compile-angel-on-load-mode 1))

;; M-x find-library RET autorevert RET
(use-package autorevert
  :ensure nil
  :init
  (setq auto-revert-verbose nil)
  (setq auto-revert-interval 3)
  (setq auto-revert-remote-files nil)
  (setq auto-revert-use-notify t)
  (setq auto-revert-avoid-polling nil)
  (global-auto-revert-mode 1))

;; M-x find-library RET recentf RET
(use-package recentf
  :ensure nil
  :init
  (setq recentf-auto-cleanup (if (daemonp) 300 'never))
  (setq recentf-exclude
        (list "\\.tar$" "\\.tbz2$" "\\.tbz$" "\\.tgz$" "\\.bz2$"
              "\\.bz$" "\\.gz$" "\\.gzip$" "\\.xz$" "\\.zip$"
              "\\.7z$" "\\.rar$"
              "COMMIT_EDITMSG\\'"
              "\\.\\(?:gz\\|gif\\|svg\\|png\\|jpe?g\\|bmp\\|xpm\\)$"
              "-autoloads\\.el$" "autoload\\.el$"))
  (recentf-mode 1)
  :config
  ;; A cleanup depth of -90 ensures that `recentf-cleanup' runs before
  ;; `recentf-save-list', allowing stale entries to be removed before the list
  ;; is saved by `recentf-save-list', which is automatically added to
  ;; `kill-emacs-hook' by `recentf-mode'.
  (add-hook 'kill-emacs-hook #'recentf-cleanup -90))

;; M-x find-library RET savehist RET
(use-package savehist
  :ensure nil
  :init
  (setq history-length 300)
  (setq savehist-autosave-interval 600)
  (savehist-mode 1))

;; M-x find-library RET saveplace RET
(use-package saveplace
  :ensure nil
  :init
  (setq save-place-limit 400)
  (save-place-mode 1))

;; Use `recover-file' or `recover-session' to restore unsaved changes.
(setq auto-save-default t)
(setq auto-save-interval 300) ;; Trigger an auto-save after 300 keystrokes
(setq auto-save-timeout 30) ;; Trigger an auto-save 30 seconds of idle time.

;; Shows the completion popup menu in-buffer
;; M-x find-library RET corfu RET
(use-package corfu
  :init
  ;; Disable Ispell completion function. As an alternative try `cape-dict'.
  (setq text-mode-ispell-word-completion 'cape-dict)
  ;; Hide commands in M-x which do not apply to the current mode.
  (setq read-extended-command-predicate #'command-completion-default-include-p)
  ;; Enable completion by pressing TAB.
  (setq tab-always-indent 'complete)
  (setq corfu-auto t)
  (global-corfu-mode 1))

;; Extends functionality of corfu by providing more completion options.
;; M-x find-library RET cape RET
(use-package cape
  :commands (cape-dabbrev cape-file cape-elisp-block)
  :bind ("C-c p" . cape-prefix-map)
  :init
  ;; Add to the global default value of `completion-at-point-functions' which is
  ;; used by `completion-at-point'.
  (add-hook 'completion-at-point-functions #'cape-dabbrev)
  (add-hook 'completion-at-point-functions #'cape-file)
  (add-hook 'completion-at-point-functions #'cape-elisp-block))

;; M-x find-library RET vertico RET
(use-package vertico
  :init
  (setq vertico-scroll-margin 10)
  (setq vertico-count 10)
  (setq vertico-cycle t)
  (vertico-mode 1))

;; M-x find-library RET orderless RET
(use-package orderless
  :init
  (setq completion-styles '(orderless basic))
  (setq completion-category-overrides '((file (styles partial-completion))))
  (setq completion-pcm-leading-wildcard t))

;; M-x find-library RET marginalia RET
(use-package marginalia
  :init (marginalia-mode 1))

;; M-x find-library RET embark RET
(use-package embark
  :bind
  (("C-." . embark-act)         ;; pick some comfortable binding
   ("C-;" . embark-dwim)        ;; good alternative: M-.
   ("C-h B" . embark-bindings)) ;; alternative for `describe-bindings'
  :init
  ;; Show the Embark target at point via Eldoc. You may adjust the
  ;; Eldoc strategy, if you want to see the documentation from
  ;; multiple providers. Beware that using this can be a little
  ;; jarring since the message shown in the minibuffer can be more
  ;; than one line, causing the modeline to move up and down:

  ;; (add-hook 'eldoc-documentation-functions #'embark-eldoc-first-target)
  ;; (setq eldoc-documentation-strategy #'eldoc-documentation-compose-eagerly)

  ;; Add Embark to the mouse context menu. Also enable `context-menu-mode'.
  ;; (context-menu-mode 1)
  ;; (add-hook 'context-menu-functions #'embark-context-menu 100)

  :config
  ;; Hide the mode line of the Embark live/completions buffers
  (add-to-list 'display-buffer-alist
               '("\\`\\*Embark Collect \\(Live\\|Completions\\)\\*"
                 nil
                 (window-parameters (mode-line-format . none)))))
(use-package embark-consult)

;; M-x find-library RET consult RET
(use-package consult
  ;; Lazily-loaded by use-package
  :bind (;; C-c bindings in `mode-specific-map'
         ("C-c M-x" . consult-mode-command)
         ("C-c h" . consult-history)
         ("C-c k" . consult-kmacro)
         ("C-c m" . consult-man)
         ("C-c i" . consult-info)
         ;; C-x bindings in `ctl-x-map'
         ("C-x M-:" . consult-complex-command)     ;; orig. repeat-complex-command
         ("C-x b" . consult-buffer)                ;; orig. switch-to-buffer
         ("C-x 4 b" . consult-buffer-other-window) ;; orig. switch-to-buffer-other-window
         ("C-x 5 b" . consult-buffer-other-frame)  ;; orig. switch-to-buffer-other-frame
         ("C-x t b" . consult-buffer-other-tab)    ;; orig. switch-to-buffer-other-tab
         ("C-x r b" . consult-bookmark)            ;; orig. bookmark-jump
         ("C-x p b" . consult-project-buffer)      ;; orig. project-switch-to-buffer
         ;; Custom M-# bindings for fast register access
         ("M-#" . consult-register-load)
         ("M-'" . consult-register-store)          ;; orig. abbrev-prefix-mark (unrelated)
         ("C-M-#" . consult-register)
         ;; Other custom bindings
         ("M-y" . consult-yank-pop)                ;; orig. yank-pop
         ;; M-g bindings in `goto-map'
         ("M-g e" . consult-compile-error)
         ("M-g r" . consult-grep-match)
         ("M-g f" . consult-flymake)               ;; Alternative: consult-flycheck
         ("M-g g" . consult-goto-line)             ;; orig. goto-line
         ("M-g M-g" . consult-goto-line)           ;; orig. goto-line
         ("M-g o" . consult-outline)               ;; Alternative: consult-org-heading
         ("M-g m" . consult-mark)
         ("M-g k" . consult-global-mark)
         ("M-g i" . consult-imenu)
         ("M-g I" . consult-imenu-multi)
         ;; M-s bindings in `search-map'
         ("M-s d" . consult-find)                  ;; Alternative: consult-fd
         ("M-s c" . consult-locate)
         ("M-s g" . consult-grep)
         ("M-s G" . consult-git-grep)
         ("M-s r" . consult-ripgrep)
         ("M-s l" . consult-line)
         ("M-s L" . consult-line-multi)
         ("M-s k" . consult-keep-lines)
         ("M-s u" . consult-focus-lines)
         ;; Isearch integration
         ("M-s e" . consult-isearch-history)
         :map isearch-mode-map
         ("M-e" . consult-isearch-history)         ;; orig. isearch-edit-string
         ("M-s e" . consult-isearch-history)       ;; orig. isearch-edit-string
         ("M-s l" . consult-line)                  ;; needed by consult-line to detect isearch
         ("M-s L" . consult-line-multi)            ;; needed by consult-line to detect isearch
         ;; Minibuffer history
         :map minibuffer-local-map
         ("M-s" . consult-history)                 ;; orig. next-matching-history-element
         ("M-r" . consult-history))                ;; orig. previous-matching-history-element

  :init ;; Init is always executed, so not lazily loaded

  ;; Tweak the register preview for `consult-register-load',
  ;; `consult-register-store' and the built-in commands.  This improves the
  ;; register formatting, adds thin separator lines, register sorting and hides
  ;; the window mode line.
  (advice-add #'register-preview :override #'consult-register-window)
  (setq register-preview-delay 0.5)

  ;; Use Consult to select xref locations with preview
  (setq xref-show-xrefs-function #'consult-xref
        xref-show-definitions-function #'consult-xref)

  ;; Configure other variables and modes in the :config section,
  ;; after lazily loading the package.
  :config

  ;; Optionally configure preview. The default value
  ;; is 'any, such that any key triggers the preview.
  ;; (setq consult-preview-key 'any)
  ;; (setq consult-preview-key "M-.")
  ;; (setq consult-preview-key '("S-<down>" "S-<up>"))
  ;; For some commands and buffer sources it is useful to configure the
  ;; :preview-key on a per-command basis using the `consult-customize' macro.
  (consult-customize
   consult-theme :preview-key '(:debounce 0.2 any)
   consult-ripgrep consult-git-grep consult-grep consult-man
   consult-bookmark consult-recent-file consult-xref
   consult-source-bookmark consult-source-file-register
   consult-source-recent-file consult-source-project-recent-file
   ;; :preview-key "M-."
   :preview-key '(:debounce 0.4 any))

  ;; Optionally configure the narrowing key.
  ;; Both < and C-+ work reasonably well.
  (setq consult-narrow-key "<") ;; "C-+"

  ;; Optionally make narrowing help available in the minibuffer.
  ;; You may want to use `embark-prefix-help-command' or which-key instead.
  ;; (keymap-set consult-narrow-map (concat consult-narrow-key " ?") #'consult-narrow-help)
  )

;; M-x find-library RET helpful RET
(use-package helpful
  :commands (helpful-callable
             helpful-variable
             helpful-key
             helpful-command
             helpful-at-point
             helpful-function)
  :bind
  ([remap describe-command] . helpful-command)
  ([remap describe-function] . helpful-callable)
  ([remap describe-key] . helpful-key)
  ([remap describe-symbol] . helpful-symbol)
  ([remap describe-variable] . helpful-variable)
  :init
  (setq helpful-max-buffers 7))
;; M-x find-library RET undo-fu RET
(use-package undo-fu
  :commands (undo-fu-only-undo
             undo-fu-only-redo
             undo-fu-only-redo-all
             undo-fu-disable-checkpoint))
(use-package undo-fu-session
  :init
  (undo-fu-session-global-mode 1))

(setq evil-undo-system 'undo-fu)

;; Vim emulation
(use-package evil
  :init
  (setq evil-want-integration t)
  (setq evil-want-keybinding nil)
  (setq evil-ex-visual-char-range t)
  (setq evil-ex-search-vim-style-regexp t)
  (setq evil-split-window-below t)
  (setq evil-vsplit-window-right t)
  (setq evil-echo-state nil)
  (setq evil-move-cursor-back nil)
  (setq evil-v$-excludes-newline t)
  (setq evil-want-fine-undo t)
  (setq evil-want-C-h-delete t)
  (setq evil-want-C-u-delete t)
  (setq evil-want-C-u-scroll t)
  (setq evil-want-Y-yank-to-eol t)
  (setq evil-search-wrap t)
  (defvar evil-mode-buffers '())
  (evil-mode 1)
  :config
  (setq evil-search-module 'evil-search)
  (evil-select-search-module 'evil-search-module 'evil-search))
(use-package evil-collection
  :after evil
  :init
  (setq evil-collection-key-blacklist '("SPC"))
  (setq evil-collection-setup-minibuffer t)
  (evil-collection-init))

(use-package goto-chg
  :commands (goto-last-change
             goto-last-change-reverse))

(use-package evil-surround
  :after evil
  :init
  (setq evil-surround-pairs-alist
        '((?\( . ("(" . ")"))
          (?\[ . ("[" . "]"))
          (?\{ . ("{" . "}"))

          (?\) . ("(" . ")"))
          (?\] . ("[" . "]"))
          (?\} . ("{" . "}"))

          (?< . ("<" . ">"))
          (?> . ("<" . ">"))))
  :config
  (global-evil-surround-mode 1))

(use-package vim-tab-bar
  :init
  (vim-tab-bar-mode 1))
(setopt tab-bar-show 1)

;; Vim's comment keys: gc and gcc
(with-eval-after-load "evil"
  (evil-define-operator my-evil-comment-or-uncomment (beg end)
    "Toggle comment for the region between BEG and END."
    (interactive "<r>")
    (comment-or-uncomment-region beg end))
  (evil-define-key 'normal 'global (kbd "gc") 'my-evil-comment-or-uncomment))

(use-package evil-matchit
  :commands turn-on-evil-matchit-mode
  :hook (prog-mode . turn-on-evil-matchit-mode)

  :init
  ;; Setting this to t disables the advanced Python matching algorithm.
  ;; Set to nil if you prefer the advanced block-matching behavior in Python.
  (setq evilmi-always-simple-jump t)

  (with-eval-after-load 'evil
    (require 'evil-matchit-evil-setup))

  :config
  ;; Because evil-matchit maps its rules to traditional major modes by default,
  ;; we must manually associate the new tree-sitter modes with their respective
  ;; matching rules until the package incorporates them natively.
  (when (fboundp 'evilmi-load-plugin-rules)
    (evilmi-load-plugin-rules '(cmake-ts-mode) '(cmake))
    (evilmi-load-plugin-rules '(c-ts-mode c++-ts-mode) '(c simple))
    (evilmi-load-plugin-rules '(bash-ts-mode) '(simple sh))
    (evilmi-load-plugin-rules '(css-ts-mode) '(simple))
    (evilmi-load-plugin-rules '(php-ts-mode) '(simple template html))
    (evilmi-load-plugin-rules '(lua-ts-mode) '(simple script))
    (evilmi-load-plugin-rules '(python-ts-mode) '(simple python))
    (evilmi-load-plugin-rules '(yaml-ts-mode) '(simple yaml))))

;; Markdown
(use-package markdown-mode
  :commands (gfm-mode
             gfm-view-mode
             markdown-mode
             markdown-view-mode)
  :mode (("\\.markdown\\'" . markdown-mode)
         ("\\.md\\'" . markdown-mode)
         ("README\\.md\\'" . gfm-mode))
  :bind
  (:map markdown-mode-map
        ("C-c C-e" . markdown-do)))

(use-package kirigami
  :commands (kirigami-open-fold
             kirigami-open-fold-rec
             kirigami-close-fold
             kirigami-toggle-fold
             kirigami-open-folds
             kirigami-close-folds-except-current
             kirigami-close-folds)
  :init
  (kirigami-global-mode 1))

(with-eval-after-load 'evil
  (define-key evil-normal-state-map "zo" 'kirigami-open-fold)
  (define-key evil-normal-state-map "zO" 'kirigami-open-fold-rec)
  (define-key evil-normal-state-map "zc" 'kirigami-close-fold)
  (define-key evil-normal-state-map "za" 'kirigami-toggle-fold)
  (define-key evil-normal-state-map "zr" 'kirigami-open-folds)
  (define-key evil-normal-state-map "zm" 'kirigami-close-folds))

(add-hook 'emacs-lisp-mode-hook #'outline-minor-mode)

(use-package apheleia
  :commands (apheleia-mode
             apheleia-global-mode)
  :init
  (apheleia-global-mode +1))

(use-package xclip
  :config

  (xclip-mode 1))
(use-package stripspace
  :commands stripspace-local-mode
  :hook ((prog-mode . stripspace-local-mode)
         (text-mode . stripspace-local-mode)
         (conf-mode . stripspace-local-mode))
  :init
  (setq stripspace-only-if-initially-clean nil)
  (setq stripspace-restore-column t))

(use-package rainbow-delimiters
  :config
  (add-hook 'prog-mode-hook #'rainbow-delimiters-mode))

(use-package diff-hl
  :commands (diff-hl-mode
             global-diff-hl-mode)
  :hook (prog-mode . diff-hl-mode)
  :init
  (setq diff-hl-flydiff-delay 0.4)  ; Faster
  (setq diff-hl-show-staged-changes nil)  ; Realtime feedback
  (setq diff-hl-update-async t)  ; Do not block Emacs
  (setq diff-hl-global-modes '(not pdf-view-mode image-mode)))

(use-package org
  :ensure nil
  :mode ("\\.org\\'" . org-mode)
  :init
  ;; Your existing visual preferences
  (setq org-hide-leading-stars t)
  (setq org-startup-indented nil)
  (setq org-adapt-indentation nil)
  (setq org-edit-src-content-indentation 0)
  (setq org-startup-truncated t)
  (setq org-startup-folded t)

  :config
  (setq org-default-notes-file (expand-file-name "inbox.org" "~/Documents/org"))

  (setq org-capture-templates
        '(("t" "Task" entry (file+headline "~/Documents/org/inbox.org" "Tasks")
           "* TODO %?")
          ("n" "Note" entry (file+headline "~/Documents/org/inbox.org" "Notes")
           "* %?")))

  ;; REFILE (Move * headings to any org file)
  ;; Targets all files in your org-agenda-files, up to 2 levels deep
  (setq org-refile-targets '((org-agenda-files :maxlevel . 2)))
  (setq org-refile-use-outline-path 'file)          ; Shows "filename/heading" in completion
  (setq org-outline-path-complete-in-steps nil)     ; Completes the whole path at once
  (setq org-refile-allow-creating-parent-nodes 'confirm))

(add-hook 'org-mode-hook #'turn-on-auto-fill)

(use-package org-agenda
  :ensure nil
  :init
  (setq org-agenda-files '("~/Documents/org"))
  (setq org-agenda-span 7)
  (setq org-agenda-start-on-weekday 1)
  (setq org-agenda-current-time-string "← now")
  (setq org-agenda-skip-deadline-if-done t)
  (setq org-agenda-skip-scheduled-if-done t)
  :config
  (setq org-agenda-custom-commands
        '(("w" "Weekly Review"
           ((agenda "")
            (todo "TODO"))))))

(use-package org-appear
  :commands org-appear-mode
  :hook (org-mode . org-appear-mode))

(use-package evil-org
  :after org
  :hook (org-mode . (lambda () (evil-org-mode)))
  :config
  (require 'evil-org-agenda)
  (evil-org-agenda-set-keys))

(use-package eglot
  :ensure nil
  :commands (eglot-ensure
             eglot-rename
             eglot-format-buffer))

(use-package buffer-terminator
  :init
  ;; Enable/Disable verbose mode to log buffer cleanup events
  (setq buffer-terminator-verbose nil)
  ;; Set the inactivity timeout (in seconds) after which buffers are considered
  ;; inactive (default is 30 minutes):
  (setq buffer-terminator-inactivity-timeout (* 30 60)) ; 30 minutes
  ;; Define how frequently the cleanup process should run (default is every 10
  ;; minutes):
  (setq buffer-terminator-interval (* 10 60)) ; 10 minutes
  (buffer-terminator-mode 1))

(use-package bufferfile
  :commands (bufferfile-copy
             bufferfile-rename
             bufferfile-delete)
  :init
  ;; If non-nil, display messages during file renaming operations
  (setq bufferfile-verbose nil)

  ;; If non-nil, enable using version control (VC) when available
  (setq bufferfile-use-vc nil)

  ;; Specifies the action taken after deleting a file and killing its buffer.
  (setq bufferfile-delete-switch-to 'parent-directory))

(use-package avy
  :commands (avy-goto-char
             avy-goto-char-2
             avy-next)
  :init
  (with-eval-after-load 'evil
    (define-key evil-normal-state-map (kbd "g s") 'avy-goto-char-2)))

(use-package highlight-defined
  ;; Highlights function and variable definitions in Emacs Lisp mode
  :commands highlight-defined-mode
  :hook
  (emacs-lisp-mode . highlight-defined-mode))
;; Prevent parenthesis imbalance
(use-package paredit
  :commands paredit-mode
  :hook
  (emacs-lisp-mode . paredit-mode)
  :config
  (define-key paredit-mode-map (kbd "RET") nil))

(use-package enhanced-evil-paredit
  :commands enhanced-evil-paredit-mode
  :hook
  (paredit-mode . enhanced-evil-paredit-mode))

;; Displays visible indicators for page breaks
(use-package page-break-lines
  :commands (page-break-lines-mode
             global-page-break-lines-mode)
  :hook
  (emacs-lisp-mode . page-break-lines-mode))

;; Provides functions to find references to functions, macros, variables,
;; special forms, and symbols in Emacs Lisp
(use-package elisp-refs
  :commands (elisp-refs-function
             elisp-refs-macro
             elisp-refs-variable
             elisp-refs-special
             elisp-refs-symbol))

(use-package quick-sdcv
  :commands (quick-sdcv-search-at-point
             quick-sdcv-search-input)
  :init
  ;; When non-nil, a distinct buffer is created for each word searched.
  (setq quick-sdcv-unique-buffers t)

  ;; Change the prefix character used before dictionary names, replacing the
  ;; default `-->`:
  (setq quick-sdcv-dictionary-prefix-symbol "►")

  ;; Change the quick-sdcv dictionaries ellipsis from … to " ▼"
  ;; (In quick-sdcv buffers, `outline-minor-mode' is enabled by default, which
  ;; allows sections corresponding to individual dictionaries to be folded. The
  ;; ellipsis … indicates a folded section, making it easy to collapse all
  ;; dictionaries and expand only those of interest.)
  (setq quick-sdcv-ellipsis " ▼")

  ;; Automatically fold all dictionary entries when performing a search.
  ;; You can then unfold the dictionaries you want to read.
  (setq quick-sdcv-fold-on-search t))
(use-package persist-text-scale
  :init
  (setq text-scale-mode-step 1.07)
  (persist-text-scale-mode 1))
(use-package vterm
  :if (bound-and-true-p module-file-suffix)
  :commands (vterm
             vterm-send-string
             vterm-send-return
             vterm-send-key
             vterm-module-compile)

  :preface
  (when noninteractive
    ;; vterm unnecessarily triggers compilation of vterm-module.so upon loading.
    ;; This prevents that during byte-compilation (`use-package' eagerly loads
    ;; packages when compiling).
    (advice-add #'vterm-module-compile :override #'ignore))

  (defun my-vterm--setup ()
    ;; Hide the mode-line
    (setq mode-line-format nil)

    ;; Inhibit early horizontal scrolling
    (setq-local hscroll-margin 0)

    ;; Suppress prompts for terminating active processes when closing vterm
    (setq-local confirm-kill-processes nil))

  :init
  (add-hook 'vterm-mode-hook #'my-vterm--setup)

  (setq vterm-timer-delay 0.05)  ; Faster vterm
  (setq vterm-kill-buffer-on-exit t)
  (setq vterm-max-scrollback 5000))

;; Ispell
;; Set the ispell program name to aspell
(setq ispell-program-name "aspell")
(setq ispell-dictionary "en_US")
(setq ispell-quietly t)
(setq ispell-extra-args '("--sug-mode=ultra" "--camel-case"))

(defun my-flyspell-enable-appropriate-mode ()
  "Use `flyspell-prog-mode' in config/markup modes, `flyspell-mode' elsewhere."
  (if (derived-mode-p 'conf-mode 'yaml-mode 'yaml-ts-mode
                      'ansible-mode 'nxml-mode 'sgml-mode)
      (flyspell-prog-mode)
    (flyspell-mode 1)))

(add-hook 'prog-mode-hook #'flyspell-prog-mode)
(add-hook 'conf-mode-hook #'my-flyspell-enable-appropriate-mode)
(add-hook 'text-mode-hook #'my-flyspell-enable-appropriate-mode)

;; Silence the startup message
(defun my-silence-ispell-init (orig-fun &rest args)
  (cl-letf (((symbol-function 'message) #'ignore))
    (apply orig-fun args)))
(advice-add 'ispell-init-process :around #'my-silence-ispell-init)
(advice-add 'ispell-kill-ispell :around #'my-silence-ispell-init)


(use-package server
  ;; The Emacs server allows external programs such as `emacsclient' to connect to
  ;; a single running instance of Emacs. This makes it possible to open files in
  ;; the existing session rather than starting a new Emacs process each time.
  ;;
  ;; Once the server is running, the `emacsclient' command can be used in the
  ;; terminal to open files in the active Emacs session. For example, running the
  ;; following command opens the file in the existing Emacs frame without blocking
  ;; the terminal process.
  ;;   emacsclient -n filename.txt
  :ensure nil
  :if (not (daemonp))
  :preface
  (defun my-server-start ()
    "Start the Emacs server if no server process is currently active."
    (unless (server-running-p)
      (server-start)))
  :init
  ;; Defer starting the server until after Emacs has finished initializing
  (add-hook 'emacs-startup-hook #'my-server-start))
(use-package elec-pair
  :ensure nil
  :init
  (electric-pair-mode 1))

;; When Delete Selection mode is enabled, typed text replaces the selection
;; if the selection is active.
(delete-selection-mode 1)

;; Display the current line and column numbers in the mode line
(setq line-number-mode t)
(setq column-number-mode t)
(setq mode-line-position-column-line-format '("%l:%C"))

;; Display of line numbers in the buffer:
(setq-default display-line-numbers-type 'relative)
(dolist (hook '(prog-mode-hook text-mode-hook conf-mode-hook))
  (add-hook hook #'display-line-numbers-mode))

;; Set the maximum level of syntax highlighting for Tree-sitter modes
(setq treesit-font-lock-level 4)

(use-package which-key
  :ensure nil
  :init
  (setq which-key-idle-delay 0.0)
  (setq which-key-idle-secondary-delay 0.0)
  (setq which-key-add-column-padding 1)
  (setq which-key-max-description-length 40)
  (which-key-mode 1))

(unless (and (eq window-system 'mac)
             (bound-and-true-p mac-carbon-version-string))
  ;; Enables `pixel-scroll-precision-mode' on all operating systems and Emacs
  ;; versions, except for emacs-mac.
  ;;
  ;; Enabling `pixel-scroll-precision-mode' is unnecessary with emacs-mac, as
  ;; this version of Emacs natively supports smooth scrolling.
  (setq pixel-scroll-precision-use-momentum nil) ; Precise/smoother scrolling
  (pixel-scroll-precision-mode 1))

;; Paren match highlighting
(show-paren-mode 1)

;; Track changes in the window configuration, allowing undoing actions such as
;; closing windows.
(setq winner-boring-buffers '("*Completions*"
                              "*Minibuf-0*"
                              "*Minibuf-1*"
                              "*Minibuf-2*"
                              "*Minibuf-3*"
                              "*Minibuf-4*"
                              "*Compile-Log*"
                              "*inferior-lisp*"
                              "*Fuzzy Completions*"
                              "*Apropos*"
                              "*Help*"
                              "*cvs*"
                              "*Buffer List*"
                              "*Ibuffer*"
                              "*esh command on file*"))
(winner-mode 1)

(setq uniquify-buffer-name-style 'file-name)
(setq uniquify-separator "•")
(setq uniquify-after-kill-buffer-p t)

;; Constrain vertical cursor movement to lines within the buffer
(setq dired-movement-style 'bounded-files)

;; Dired buffers: Automatically hide file details (permissions, size,
;; modification date, etc.) and all the files in the `dired-omit-files' regular
;; expression for a cleaner display.
(add-hook 'dired-mode-hook #'dired-hide-details-mode)

;; Hide files from dired
(setq dired-omit-files (concat "\\`[.]\\'"
                               "\\|\\(?:\\.js\\)?\\.meta\\'"
                               "\\|\\.\\(?:elc\\|a\\|o\\|pyc\\|pyo\\|swp\\|class\\)\\'"
                               "\\|^\\.DS_Store\\'"
                               "\\|^\\.\\(?:svn\\|git\\)\\'"
                               "\\|^\\.ccls-cache\\'"
                               "\\|^__pycache__\\'"
                               "\\|^\\.project\\(?:ile\\)?\\'"
                               "\\|^flycheck_.*"
                               "\\|^flymake_.*"))
(add-hook 'dired-mode-hook #'dired-omit-mode)

;; dired: Group directories first
(with-eval-after-load 'dired
  (let ((args "--group-directories-first -ahlv"))
    (when (or (eq system-type 'darwin) (eq system-type 'berkeley-unix))
      (if-let* ((gls (executable-find "gls")))
          (setq insert-directory-program gls)
        (setq args nil)))
    (when args
      (setq dired-listing-switches args))))

;; Enables visual indication of minibuffer recursion depth after initialization.
(minibuffer-depth-indicate-mode 1)

;; Configure Emacs to ask for confirmation before exiting
(setq confirm-kill-emacs 'y-or-n-p)

;; Enabled backups save your changes to a file intermittently
(setq make-backup-files t)
(setq vc-make-backup-files t)
(setq kept-old-versions 10)
(setq kept-new-versions 10)

;; When tooltip-mode is enabled, certain UI elements (e.g., help text,
;; mouse-hover hints) will appear as native system tooltips (pop-up windows),
;; rather than as echo area messages. This is useful in graphical Emacs sessions
;; where tooltips can appear near the cursor.
(setq tooltip-hide-delay 20)    ; Time in seconds before a tooltip disappears (default: 10)
(setq tooltip-delay 0.4)        ; Delay before showing a tooltip after mouse hover (default: 0.7)
(setq tooltip-short-delay 0.08) ; Delay before showing a short tooltip (Default: 0.1)
(tooltip-mode 1)

;; Keep unmodified buffers A/B/C at session end
(setq ediff-keep-variants t)

;; Automatically apply verified, safe file-local variables. This eliminates
;; confirmation prompts when loading files, while ensuring that unauthorized or
;; risky configurations are silently ignored.
(setq enable-local-variables :safe)

;; Prevent Emacs from applying directory-local settings
(setq enable-dir-local-variables nil)


(use-package buffer-guardian
  :init
  ;; When non-nil, include remote files in the auto-save process
  (setq buffer-guardian-inhibit-saving-remote-files t)
  ;; When non-nil, buffers visiting nonexistent files are not saved
  (setq buffer-guardian-inhibit-saving-nonexistent-files nil)
  ;; Save the buffer even if the window change results in the same buffer
  (setq buffer-guardian-save-on-same-buffer-window-change t)
  ;; Non-nil to enable verbose mode to log when a buffer is automatically saved
  (setq buffer-guardian-verbose nil)
  (buffer-guardian-mode 1))

(use-package doom-modeline
  :init
  (doom-modeline-mode 1)
  :config
  (setq doom-modeline-height 25)
  (setq doom-modeline-bar-width 0)
  (setq doom-modeline-icon nil)
  (setq doom-modeline-modal-icon nil)
  (setq doom-modeline-buffer-encoding nil)
  (setq doom-modeline-buffer-file-name-style 'file-name))

;; Theme
(let ((inhibit-redisplay t))
  (mapc #'disable-theme custom-enabled-themes)
  (load-theme 'modus-operandi t))

(fringe-mode -1)
(set-face-attribute 'line-number nil :background 'unspecified)
(set-face-attribute 'line-number-current-line nil :background 'unspecified)
(defun my/line-number-weight (&rest _)
  (set-face-attribute 'line-number-current-line nil
                      :inherit 'line-number
                      :weight 'unspecified
                      :slant 'unspecified))

(advice-add 'load-theme :after #'my/line-number-weight)
(my/line-number-weight)

(defun my/flat-ui (&rest _)
  (let ((bg (face-background 'default nil t))
        (ml-active (face-background 'mode-line nil t))
        (ml-inactive (face-background 'mode-line-inactive nil t)))
    ;; modeline: keep the theme's gray, just remove box and lines
    (dolist (face '(mode-line mode-line-active mode-line-inactive))
      (when (facep face)
        (set-face-attribute face nil
                            :box nil :overline nil :underline nil)))
    ;; window dividers: invisible
    (dolist (face '(window-divider
                    window-divider-first-pixel
                    window-divider-last-pixel
                    vertical-border))
      (when (facep face)
        (set-face-attribute face nil :foreground bg :background bg)))
    ;; doom-modeline bar: blend into the gray band
    (when (facep 'doom-modeline-bar)
      (set-face-attribute 'doom-modeline-bar nil
                          :inherit nil :inverse-video nil
                          :foreground ml-active :background ml-active))
    (when (facep 'doom-modeline-bar-inactive)
      (set-face-attribute 'doom-modeline-bar-inactive nil
                          :inherit nil :inverse-video nil
                          :foreground ml-inactive :background ml-inactive))
    ;; bar images are cached, so rebuild them
    (when (fboundp 'doom-modeline-refresh-bars)
      (doom-modeline-refresh-bars))))

(advice-add 'load-theme :after #'my/flat-ui)
(with-eval-after-load 'doom-modeline
  (my/flat-ui))
(my/flat-ui)

(set-face-attribute 'default nil
                    :height 120 :weight 'medium :family "Inconsolata")

;;; Keymaps / remaps
(defvar leader (make-sparse-keymap)
  "Keymap for custom SPC leader bindings.")

(defun jump-to-directory ()
  "Jump to a frequently used directory using completion."
  (interactive)
  (let* ((dirs '(("Home" . "~")
                 ("Config" . "~/.config")
                 ("Emacs" . "~/.emacs.d")
                 ("Org" . "~/Documents/org")
                 ("School" . "~/Documents/school")))
         (choice (completing-read "Jump to: " (mapcar #'car dirs) nil t))
         (dir (cdr (assoc choice dirs))))
    (when dir
      (dired (expand-file-name dir)))))

(defun search-notes ()
  "Search contents of all org files in ~/Documents/org"
  (interactive)
  (consult-ripgrep "~/Documents/org"))

(defun find-note-file ()
  "Find org files in ~/Documents/org"
  (interactive)
  (let ((default-directory "~/Documents/org"))
    (consult-find)))

(with-eval-after-load 'consult
  (setq consult-fd-args
        '("fd" "--full-path" "--color=never" "--hidden" "--exclude" ".git")))

(with-eval-after-load 'evil
  (evil-global-set-key 'normal (kbd "SPC") leader)

  ;; Leader
  (define-key leader (kbd "f") 'consult-fd)
  (define-key leader (kbd "r") 'recentf)
  (define-key leader (kbd "g") 'consult-ripgrep)
  (define-key leader (kbd "b") 'consult-buffer)
  (define-key leader (kbd "h") 'help-command)
  (define-key leader (kbd "j") 'jump-to-directory)

  (define-key leader (kbd "o a") 'org-agenda)
  (define-key leader (kbd "o c") 'org-capture)
  (define-key leader (kbd "o r") 'org-refile)
  (define-key leader (kbd "o l") 'org-store-link)
  (define-key leader (kbd "o f") 'find-note-file)
  (define-key leader (kbd "o g") 'search-notes)

  ;; Normal mode
  (evil-global-set-key 'normal (kbd "<escape>") 'evil-ex-nohighlight)
  (evil-global-set-key 'normal (kbd "-") 'dired-jump))
