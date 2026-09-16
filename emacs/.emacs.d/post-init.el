;; FILENAME.el --- Additional configuration and packages -*- no-byte-compile: t; lexical-binding: t; -*-

;; Native compilation enhances Emacs performance by converting Elisp code into
;; native machine code, resulting in faster execution and improved
;; responsiveness.
;; Ensure adding the following compile-angel code at the very beginning
;; of your `~/.emacs.d/post-init.el` file, before all other packages.
(use-package compile-angel
  :demand t
  :config
  (setq package-native-compile nil)
  (setq compile-angel-verbose nil)
  (setq load-prefer-newer t)

  ;; The following directive prevents compile-angel from compiling your init
  ;; files. If you choose to remove this push to `compile-angel-excluded-files'
  ;; and compile your pre/post-init files, ensure you understand the
  ;; implications and thoroughly test your code. For example, if you're using
  ;; the `use-package' macro, you'll need to explicitly add:
  ;; (eval-when-compile (require 'use-package))
  ;; at the top of your init file.
  (push "/init.el" compile-angel-excluded-files)
  (push "/early-init.el" compile-angel-excluded-files)
  (push "/pre-init.el" compile-angel-excluded-files)
  (push "/post-init.el" compile-angel-excluded-files)
  (push "/pre-early-init.el" compile-angel-excluded-files)
  (push "/post-early-init.el" compile-angel-excluded-files)

  ;; A local mode that compiles .el files whenever the user saves them.
  ;; (add-hook 'emacs-lisp-mode-hook #'compile-angel-on-save-local-mode)

  ;; A global mode that compiles .el files prior to loading them via `load' or
  ;; `require'. Additionally, it compiles all packages that were loaded before
  ;; the mode `compile-angel-on-load-mode' was activated.
  (compile-angel-on-load-mode 1))

;; Auto-revert in Emacs is a feature that automatically updates the
;; contents of a buffer to reflect changes made to the underlying file
;; on disk.
(use-package autorevert
  :ensure nil
  :init
  ;; (setq auto-revert-verbose t)
  (setq auto-revert-interval 3)
  (setq auto-revert-remote-files nil)
  (setq auto-revert-use-notify t)
  (setq auto-revert-avoid-polling nil)
  (global-auto-revert-mode 1))

;; Recentf is an Emacs package that maintains a list of recently
;; accessed files, making it easier to reopen files you have worked on
;; recently.
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
  ;; Enable `recentf-mode'
  (recentf-mode 1)

  :config
  ;; A cleanup depth of -90 ensures that `recentf-cleanup' runs before
  ;; `recentf-save-list', allowing stale entries to be removed before the list
  ;; is saved by `recentf-save-list', which is automatically added to
  ;; `kill-emacs-hook' by `recentf-mode'.
  (add-hook 'kill-emacs-hook #'recentf-cleanup -90))

;; savehist is an Emacs feature that preserves the minibuffer history between
;; sessions. It saves the history of inputs in the minibuffer, such as commands,
;; search strings, and other prompts, to a file. This allows users to retain
;; their minibuffer history across Emacs restarts.
(use-package savehist
  :ensure nil
  :init
  (setq history-length 300)
  (setq savehist-autosave-interval 600)
  (savehist-mode 1))

;; save-place-mode enables Emacs to remember the last location within a file
;; upon reopening. This feature is particularly beneficial for resuming work at
;; the precise point where you previously left off.
(use-package saveplace
  :ensure nil
  :init
  (setq save-place-limit 400)
  (save-place-mode 1))

;; Enable `auto-save-mode' to prevent data loss. Use `recover-file' or
;; `recover-session' to restore unsaved changes.
(setq auto-save-default t)

;; Trigger an auto-save after 300 keystrokes
(setq auto-save-interval 300)

;; Trigger an auto-save 30 seconds of idle time.
(setq auto-save-timeout 30)

;; Corfu enhances in-buffer completion by displaying a compact popup with
;; current candidates, positioned either below or above the point. Candidates
;; can be selected by navigating up or down.
(use-package corfu
  :init
  (setq text-mode-ispell-word-completion nil)
  ;; Hide commands in M-x which do not apply to the current mode.
  (setq read-extended-command-predicate #'command-completion-default-include-p)
  ;; Disable Ispell completion function. As an alternative try `cape-dict'.
  (setq tab-always-indent 'complete)

  (global-corfu-mode 1))

;; Cape, or Completion At Point Extensions, extends the capabilities of
;; in-buffer completion. It integrates with Corfu or the default completion UI,
;; by providing additional backends through completion-at-point-functions.
(use-package cape
  :commands (cape-dabbrev cape-file cape-elisp-block)
  :bind ("C-c p" . cape-prefix-map)
  :init
  ;; Add to the global default value of `completion-at-point-functions' which is
  ;; used by `completion-at-point'.
  (add-hook 'completion-at-point-functions #'cape-dabbrev)
  (add-hook 'completion-at-point-functions #'cape-file)
  (add-hook 'completion-at-point-functions #'cape-elisp-block))

;; Vertico provides a vertical completion interface, making it easier to
;; navigate and select from completion candidates (e.g., when `M-x` is pressed).
(use-package vertico
  :init
  ;; (setq vertico-scroll-margin 0) ;; Different scroll margin
  ;; (setq vertico-count 20) ;; Show more candidates
  ;; (setq vertico-resize t) ;; Grow and shrink the Vertico minibuffer
  ;; (setq vertico-cycle t) ;; Enable cycling for `vertico-next/previous'
  (vertico-mode 1))

;; Vertico leverages Orderless' flexible matching capabilities, allowing users
;; to input multiple patterns separated by spaces, which Orderless then
;; matches in any order against the candidates.
(use-package orderless
  :init
  (setq completion-styles '(orderless basic))
  (setq completion-category-overrides '((file (styles partial-completion))))
  ;; Emacs 31: partial-completion behaves like substring
  (setq completion-pcm-leading-wildcard t))

;; Marginalia allows Embark to offer you preconfigured actions in more contexts.
;; In addition to that, Marginalia also enhances Vertico by adding rich
;; annotations to the completion candidates displayed in Vertico's interface.
(use-package marginalia
  ;; Bind `marginalia-cycle' locally in the minibuffer.  To make the binding
  ;; available in the *Completions* buffer, add it to the
  ;; `completion-list-mode-map'.
  :bind (:map minibuffer-local-map
              ("M-A" . marginalia-cycle))

  ;; The :init section is always executed.
  :init

  ;; Marginalia must be activated in the :init section of use-package such that
  ;; the mode gets enabled right away. Note that this forces loading the
  ;; package.
  (marginalia-mode 1))

;; Embark integrates with Consult and Vertico to provide context-sensitive
;; actions and quick access to commands based on the current selection, further
;; improving user efficiency and workflow within Emacs. Together, they create a
;; cohesive environment for managing completions and interactions.
(use-package embark
  :bind
  (("C-." . embark-act)         ;; pick some comfortable binding
   ("C-;" . embark-dwim)        ;; good alternative: M-.
   ("C-h B" . embark-bindings)) ;; alternative for `describe-bindings'

  :init

  ;; Optionally replace the key help with a completing-read interface
  (setq prefix-help-command #'embark-prefix-help-command)

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

;; Consult offers a suite of commands for efficient searching, previewing, and
;; interacting with buffers, file contents, and more, improving various tasks.

(use-package consult
  :init
  (advice-add #'register-preview :override #'consult-register-window)
  (setq register-preview-delay 0.5
        xref-show-xrefs-function #'consult-xref
        xref-show-definitions-function #'consult-xref)

  :config
  (consult-customize
   consult-theme
   consult-ripgrep consult-git-grep consult-grep consult-man
   consult-bookmark consult-recent-file consult-xref
   :preview-key '(:debounce 0.4 any))

  (setq consult-narrow-key "<"))

;; Helpful is an alternative to the built-in Emacs help that provides much more
;; contextual information.
(use-package helpful
  :bind
  ([remap describe-command] . helpful-command)
  ([remap describe-function] . helpful-callable)
  ([remap describe-key] . helpful-key)
  ([remap describe-symbol] . helpful-symbol)
  ([remap describe-variable] . helpful-variable)
  :init
  (setq helpful-max-buffers 7))

;; Which-key
(use-package which-key
  :ensure nil
  :init
  (which-key-mode 1))

;; The undo-fu package is a lightweight wrapper around Emacs' built-in undo
;; system, providing more convenient undo/redo functionality.
(use-package undo-fu
  :commands (undo-fu-only-undo
             undo-fu-only-redo
             undo-fu-only-redo-all
             undo-fu-disable-checkpoint)
  :init
  (global-unset-key (kbd "C-z"))
  (global-set-key (kbd "C-z") 'undo-fu-only-undo)
  (global-set-key (kbd "C-S-z") 'undo-fu-only-redo))

;; The undo-fu-session package complements undo-fu by enabling the saving
;; and restoration of undo history across Emacs sessions, even after restarting.
(use-package undo-fu-session
  :init
  (undo-fu-session-global-mode 1))

;; Remove GTK client-side window decorations
(add-to-list 'default-frame-alist '(undecorated . t))

;; Default theme
(let ((inhibit-redisplay t))
  ;; Disable all active themes
  (mapc #'disable-theme custom-enabled-themes)
  ;; Load the built-in theme
  (load-theme 'modus-operandi t))

;; Uncomment the following if you are using undo-fu
(setq evil-undo-system 'undo-fu)

;; Vim emulation
(use-package evil
  :init
  ;; It has to be defined before evil
  (setq evil-want-integration t)
  (setq evil-want-keybinding nil)

  ;; Make :s in visual mode operate only on the actual visual selection
  ;; (character or block), instead of the full lines covered by the selection
  (setq evil-ex-visual-char-range t)
  ;; Use Vim-style regular expressions in search and substitute commands,
  ;; allowing features like \v (very magic), \zs, and \ze for precise matches
  (setq evil-ex-search-vim-style-regexp t)
  ;; Enable automatic horizontal split below
  (setq evil-split-window-below t)
  ;; Enable automatic vertical split to the right
  (setq evil-vsplit-window-right t)
  ;; Disable echoing Evil state to avoid replacing eldoc
  (setq evil-echo-state nil)
  ;; Do not move cursor back when exiting insert state
  (setq evil-move-cursor-back nil)
  ;; Make `v$` exclude the final newline
  (setq evil-v$-excludes-newline t)
  ;; Enable fine-grained undo behavior
  (setq evil-want-fine-undo t)
  ;; Disable wrapping of search around buffer
  (setq evil-search-wrap nil)
  ;; Allow C-h to delete in insert state
  (setq evil-want-C-h-delete t)
  ;; Enable C-u to delete back to indentation in insert state
  (setq evil-want-C-u-delete t)
  ;; Whether Y yanks to the end of the line
  (setq evil-want-Y-yank-to-eol t)
  ;; Normal mode C-u will scroll (emacs C-u remapped to Space-u)
  (setq evil-want-C-u-scroll t)

  ;; Start `evil-mode'
  (evil-mode 1)

  :config
  ;; evil commenting behavior (gcc)
  (evil-define-operator my-evil-comment-or-uncomment (beg end)
    "Toggle comment for the region between BEG and END."
    (interactive "<r>")
    (comment-or-uncomment-region beg end))
  (evil-define-key 'normal 'global (kbd "gc") 'my-evil-comment-or-uncomment)
  ;; Occasionally, `evil' fails to respect `evil-search-module' when it is
  ;; defined inside the :custom block. This fix ensures the search module
  ;; is correctly set to `evil-search'.
  (setq evil-search-module 'evil-search)
  (evil-select-search-module 'evil-search-module 'evil-search))

(add-hook 'org-mode-hook
          (lambda ()
            (define-key evil-normal-state-local-map
                        (kbd "j") #'evil-next-visual-line)
            (define-key evil-normal-state-local-map
                        (kbd "k") #'evil-previous-visual-line)))

(add-hook 'text-mode-hook
          (lambda ()
            (define-key evil-normal-state-local-map
                        (kbd "j") #'evil-next-visual-line)
            (define-key evil-normal-state-local-map
                        (kbd "k") #'evil-previous-visual-line)))

(use-package evil-collection
  :after evil
  :init
  ;; It has to be defined before evil-collection
  (setq evil-collection-setup-minibuffer t)
  (evil-collection-init))

;; The goto-chg package is useful with Evil to jump directly to the most recent
;; edit location. This mirrors Vim's change navigation, allowing fast return to
;; where text was last modified without relying on the jump list or search.
;;
;; The goto-chg commands are bound to g; and g,
(use-package goto-chg
  :commands (goto-last-change
             goto-last-change-reverse))

;; The evil-surround package simplifies handling surrounding characters, such as
;; parentheses, brackets, quotes, etc. It provides key bindings to easily add,
;; change, or delete these surrounding characters in pairs. For instance, you
;; can surround the currently selected text with double quotes in visual state
;; using S" or gS".
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

;;; Folding
(add-hook 'prog-mode-hook #'hs-minor-mode)

(use-package hideshow
  :ensure nil
  :hook (prog-mode . hs-minor-mode)
  :config
  (evil-define-key 'normal 'global
    (kbd "za") #'hs-toggle-hiding
    (kbd "zo") #'hs-show-block
    (kbd "zc") #'hs-hide-block
    (kbd "zR") #'hs-show-all
    (kbd "zM") #'hs-hide-all))

(use-package evil-org
  :after org evil
  :hook (org-mode . evil-org-mode)

  :config
  ;; Vim-style folding for Org
  (evil-define-key 'normal org-mode-map
    (kbd "za") #'org-cycle
    (kbd "zo") #'org-show-subtree
    (kbd "zc") #'outline-hide-subtree
    (kbd "zR") #'org-show-all
    (kbd "zM") #'org-overview))

(with-eval-after-load 'evil
  (define-key evil-normal-state-map (kbd "<escape>") #'evil-ex-nohighlight))

(defun my/evil-zz ()
  (evil-scroll-line-to-center nil))

(dolist (cmd '(evil-search-next
               evil-search-previous
               evil-goto-line
               evil-jump-backward
               evil-jump-forward))
  (advice-add cmd :after #'my/evil-zz))

(use-package general
  :after evil
  :config
  (general-create-definer my-leader-def
    :states '(normal visual motion)
    :keymaps 'override
    :prefix "SPC"
    :global-prefix "C-SPC")

  (my-leader-def
    ;; Universal argument / M-x
    "u" #'universal-argument
    "SPC" #'execute-extended-command

    ;; Help
    "h" '(:ignore t :which-key "help")
    "hf" #'helpful-callable
    "hv" #'helpful-variable
    "hk" #'helpful-key
    "hc" #'helpful-command
    "hs" #'helpful-symbol
    "ha" #'helpful-at-point

    ;; Search
    "s" '(:ignore t :which-key "search")
    "ss" #'consult-line
    "sg" #'consult-ripgrep
    "sf" #'consult-find
    "so" #'consult-outline
    "si" #'consult-imenu
    "sm" #'consult-mark

    ;; Files
    "f" '(:ignore t :which-key "files")
    "ff" #'find-file
    "fr" #'consult-recent-file
    "fs" #'save-buffer

    ;; Org / Notes
    "n"  '(:ignore t :which-key "org")
    "na" #'org-agenda
    "ns" #'org-schedule
    "nd" #'org-deadline
    "nc" #'org-capture
    "nw" #'org-agenda-list
    "no" #'org-clock-in
    "ni" #'org-clock-out
    "nt" #'org-todo
    "nl" #'org-toggle-checkbox
    "np" #'org-set-property
    "ng" #'org-set-tags-command

    ;; Buffers
    "b" '(:ignore t :which-key "buffers")
    "bb" #'consult-buffer
    "bd" #'kill-current-buffer

    ;; Windows
    "w" '(:ignore t :which-key "windows")
    "wh" #'evil-window-left
    "wj" #'evil-window-down
    "wk" #'evil-window-up
    "wl" #'evil-window-right
    "ws" #'evil-window-split
    "wv" #'evil-window-vsplit
    "wc" #'evil-window-delete
    "wo" #'delete-other-windows

    ;; Quit
    "q" '(:ignore t :which-key "quit")
    "qq" #'save-buffers-kill-terminal))

;; Context-aware 'go to definition' without LSP
(use-package dumb-jump
  :commands dumb-jump-xref-activate
  :init
  ;; Register `dumb-jump' as an xref backend so it integrates with
  ;; `xref-find-definitions'. A priority of 80 ensures it is used only when no
  ;; more specific backend is available.
  (with-eval-after-load 'xref
    (add-hook 'xref-backend-functions #'dumb-jump-xref-activate 80))

  (setq dumb-jump-aggressive nil)
  ;; (setq dumb-jump-quiet t)

  ;; Number of seconds a rg/grep/find command can take before being warned to
  ;; use ag and config.
  (setq dumb-jump-max-find-time 3)

  ;; Use `completing-read' so that selection of jump targets integrates with the
  ;; active completion framework (e.g., Vertico, Ivy, Helm, Icomplete),
  ;; providing a consistent minibuffer-based interface whenever multiple
  ;; definitions are found.
  (setq dumb-jump-selector 'completing-read)

  :config
  ;; If ripgrep is available, force `dumb-jump' to use it because it is
  ;; significantly faster and more accurate than the default searchers (grep,
  ;; ag, etc.).
  (when (executable-find "rg")
    (setq dumb-jump-force-searcher 'rg)
    (setq dumb-jump-prefer-searcher 'rg)))

;; LSP Completion
(use-package eglot
  :ensure nil
  :commands (eglot
             eglot-ensure
             eglot-rename
             eglot-format-buffer))

(add-hook 'java-mode-hook #'eglot-ensure)

;; The official collection of snippets for yasnippet.
(use-package yasnippet-snippets)

;; YASnippet is a template system designed that enhances text editing by
;; enabling users to define and use snippets. When a user types a short
;; abbreviation, YASnippet automatically expands it into a full template, which
;; can include placeholders, fields, and dynamic content.
(use-package yasnippet
  :after yasnippet-snippets
  :init
  (setq yas-also-auto-indent-first-line t)  ; Indent first line of snippet
  (setq yas-also-indent-empty-lines t)
  (setq yas-snippet-revival nil)  ; Setting this to t causes issues with undo
  (setq yas-wrap-around-region nil) ; Do not wrap region when expanding snippets
  (setq yas-indent-line 'fixed) ; Do not auto-indent snippet content
  ;; (setq yas-triggers-in-field nil)  ; Disable nested snippet expansion
  ;; (setq yas-prompt-functions '(yas-no-prompt))  ; No prompt for snippet choices

  ;; Suppress verbose messages
  (setq yas-verbosity 0)

  (yas-global-mode 1))

;; The stripspace Emacs package provides stripspace-local-mode, a minor mode
;; that automatically removes trailing whitespace and blank lines at the end of
;; the buffer when saving.
(use-package stripspace
  :commands stripspace-local-mode

  ;; Enable for prog-mode-hook, text-mode-hook, conf-mode-hook
  :hook ((prog-mode . stripspace-local-mode)
         (text-mode . stripspace-local-mode)
         (conf-mode . stripspace-local-mode))

  :init
  ;; The `stripspace-only-if-initially-clean' option:
  ;; - nil to always delete trailing whitespace.
  ;; - Non-nil to only delete whitespace when the buffer is clean initially.
  ;; (The initial cleanliness check is performed when `stripspace-local-mode'
  ;; is enabled.)
  (setq stripspace-only-if-initially-clean nil)

  ;; Enabling `stripspace-restore-column' preserves the cursor's column position
  ;; even after stripping spaces. This is useful in scenarios where you add
  ;; extra spaces and then save the file. Although the spaces are removed in the
  ;; saved file, the cursor remains in the same position, ensuring a consistent
  ;; editing experience without affecting cursor placement.
  (setq stripspace-restore-column t))

;; Make the text width thinner
(use-package visual-fill-column
  :custom
  (visual-fill-column-width 88)
  (visual-fill-column-center-text t)
  :hook (org-mode . visual-fill-column-mode))

;; Org
(use-package org
  :hook ((org-mode . visual-line-mode)
         (org-mode . variable-pitch-mode)
         (org-mode . org-indent-mode))

  :custom
  (org-hide-leading-stars t)
  (org-hide-emphasis-markers t)
  (org-pretty-entities t)
  (org-adapt-indentation nil)
  (org-tags-column 0)
  (org-indent-indentation-per-level 2)
  (org-edit-src-content-indentation 0)

  :config
  (require 'org-tempo)

(add-hook 'org-mode-hook
          (lambda ()
            (setq-local line-spacing 0.15)

            (dolist (face '(org-meta-line
                            org-document-title
                            org-document-info-keyword
                            org-code
                            org-block
                            org-block-begin-line
                            org-block-end-line
                            org-table
                            org-formula
                            org-special-keyword
                            org-property-value
                            org-drawer
                            org-date
                            org-tag))
              (set-face-attribute face nil
                                  :family "IBM Plex Mono")))))

(use-package org-superstar
  :after org
  :hook (org-mode . org-superstar-mode)

  :custom
  (org-superstar-headline-bullets-list
   '("*" "*" "*" "*"))
  (org-superstar-item-bullet-alist
   '((?- . ?-)
     (?+ . ?•)
     (?* . ?*))))

(use-package org-appear
  :commands org-appear-mode
  :hook (org-mode . org-appear-mode))

;; Slightly larger Org headings while preserving the theme's colors.
(custom-set-faces
 '(org-level-1 ((t (:inherit outline-1 :height 1.30))))
 '(org-level-2 ((t (:inherit outline-2 :height 1.20))))
 '(org-level-3 ((t (:inherit outline-3 :height 1.15))))
 '(org-level-4 ((t (:inherit outline-4 :height 1.10))))
 '(org-level-5 ((t (:inherit outline-5 :height 1.00)))))

;;; Org Agenda
(require 'org)
(require 'org-agenda)

(setq org-directory "~/org/")
(setq org-agenda-files
      '("~/org/inbox.org"
        "~/org/rel103.org"
        "~/org/csc301.org"
        "~/org/snc185.org"
        "~/org/csc373.org"))

(setq org-todo-keywords
      '((sequence "TODO(t)" "|" "DONE(d)")))

(setq org-log-done 'time)

(setq org-capture-templates
      '(("t" "Todo" entry
         (file "~/org/inbox.org")
         "* TODO %?\n")

        ("n" "Note" entry
         (file "~/org/inbox.org")
         "* %?\n")))

(setq org-agenda-custom-commands
      '(("f" "Today + Upcoming + Inbox"
         ((agenda ""
                  ((org-agenda-span 1)
                   (org-agenda-start-day "0d")))
          (todo ""
                ((org-agenda-files '("~/org/inbox.org"))))))))

;; Manage buffer states
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

;;; Elisp development helper
;; Highlights function and variable definitions in Emacs Lisp mode
(use-package highlight-defined
  :commands highlight-defined-mode
  :hook
  (emacs-lisp-mode . highlight-defined-mode))

;; Default fonts
(set-face-attribute 'default nil
                    :family "IBM Plex Mono"
                    :height 120)

;; Proportional/document font
(set-face-attribute 'variable-pitch nil
                    :family "IBM Plex Sans"
                    :height 1.0)

;; Text scale stays through every buffer
(use-package persist-text-scale
  :init
  (setq text-scale-mode-step 1.07)
  (persist-text-scale-mode 1))

;;; Enable automatic insertion and management of matching pairs of characters
;;; (e.g., (), {}, "") globally using `electric-pair-mode'.
(use-package elec-pair
  :ensure nil
  :init
  (electric-pair-mode 1)
  :hook
  (org-mode . (lambda () (electric-pair-local-mode -1))))

;; Set the fringes to match the pixel height of a character. This ensures the
;; fringe is wide enough, scaling dynamically with the current font size.
(fringe-mode (frame-char-width))

;; General indentation defaults
(setq-default tab-width 4)
(setq-default indent-tabs-mode nil)

;; When Delete Selection mode is enabled, typed text replaces the selection
;; if the selection is active.
(delete-selection-mode 1)

;; Display of line numbers in the buffer:
(setq-default display-line-numbers-type 'relative)
(dolist (hook '(prog-mode-hook conf-mode-hook))
  (add-hook hook #'display-line-numbers-mode))

;; Set the maximum level of syntax highlighting for Tree-sitter modes
(setq treesit-font-lock-level 4)

(setq pixel-scroll-precision-use-momentum nil) ; Precise/smoother scrolling
(pixel-scroll-precision-mode 1)

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
(use-package winner
  :ensure nil
  :init
  (winner-mode 1))

(setq uniquify-buffer-name-style 'reverse)
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

;; Terminal emulator in emacs
(use-package vterm
  :if (bound-and-true-p module-file-suffix)
  :commands (vterm
             vterm-other-window)
  :init
  (setq vterm-timer-delay 0.05
        vterm-kill-buffer-on-exit t
        vterm-max-scrollback 5000)
  :bind
  (("C-c t" . vterm)))

(use-package doom-modeline
  :init
  (doom-modeline-mode 1)
  :custom
  (doom-modeline-minor-modes nil)
  (doom-modeline-buffer-file-name-style 'file-name)
  (doom-modeline-icon nil)
  (doom-modeline-evil-state-icon nil)
  (doom-modeline-buffer-encoding nil)
  (doom-modeline-indent-info nil)
  (doom-modeline-height 25))
