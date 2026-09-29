;;; init.el --- my config ;; -*- lexical-binding: t; no-byte-compile: t; -*-

;;; Commentary:

;;; Code:

;; Emacs randomly edits my config
;; I want those edits here
(setq load-prefer-newer t
      custom-file (expand-file-name "custom.el" user-emacs-directory))
(load custom-file 'noerror 'nomessage)

;; Set up package.el to work with MELPA
(require 'package)
(setq package-archives
      '(("gnu"    . "https://elpa.gnu.org/packages/")
        ("nongnu" . "https://elpa.nongnu.org/nongnu/")
        ("melpa"  . "https://melpa.org/packages/")))
(package-initialize)
(unless package-archive-contents (package-refresh-contents))
(setq use-package-always-ensure t
      use-package-always-defer t)

;; Turn of startup screen
(setq inhibit-splash-screen t)
(setq initial-major-mode 'fundamental-mode)
(setq initial-scratch-message nil)

;; Makes some sweeping ui/ux changes
;; this turns on modes I may want off later
(load-theme 'newcomers-presets t)
(setq modus-themes-common-palette-overrides
      '((fg-line-number-inactive "gray50")
        (fg-line-number-active   fg-main)
        (bg-line-number-inactive unspecified)
        (bg-line-number-active   unspecified)))

(load-theme 'modus-operandi t)

;; UI
(tool-bar-mode -1)
(blink-cursor-mode -1)

;; Behavior

;;; Line numbers
(setq display-line-numbers-type 'relative)

;;; Scroll
(pixel-scroll-precision-mode 1)
(setq scroll-conservatively 101
      scroll-margin 0
      scroll-preserve-screen-position t
      mouse-wheel-scroll-amount '(2 ((shift) . 1))
      mouse-wheel-progressive-speed nil)

;;; Yes or no prompts
(setq use-short-answers t)

;;; Lock files
(setq create-lockfiles nil)

;;; Put auto-saves and backups in .emacs.d
(let ((backup-dir (expand-file-name "backups/" user-emacs-directory))
      (auto-save-dir (expand-file-name "auto-saves/" user-emacs-directory)))
  (make-directory backup-dir t)
  (make-directory auto-save-dir t)

  ;; Backups (file~)
  (setq backup-directory-alist `(("." . ,backup-dir))
        backup-by-copying t        ; safer with symlinks and hard links
        version-control t          ; numbered backups
        kept-new-versions 6
        kept-old-versions 2
        delete-old-versions t)

  ;; Auto-saves (#file#)
  (setq auto-save-file-name-transforms `((".*" ,auto-save-dir t))
        auto-save-list-file-prefix (expand-file-name ".saves-" auto-save-dir)))

;; Which key
(use-package which-key
  :demand t
  :config
  (setq which-key-idle-delay 0)
  (which-key-mode 1))


;; Performance settings that don't need to be early
(setq read-process-output-max (* 1024 1024)
      process-adaptive-read-buffering nil)

;; Evil mode
(use-package evil
  :demand t
  :init
  (setq evil-want-keybinding nil
        evil-want-integration t
        evil-collection-key-blacklist '("SPC")
        evil-want-C-u-scroll t
        evil-want-C-u-delete t
        evil-want-minibuffer t
        evil-echo-state nil
        evil-undo-system 'undo-fu)
  :config
  (evil-mode 1))

;; Evil mode key maps
(evil-define-key '(motion normal visual operator) 'global
  (kbd "gh") #'evil-beginning-of-line
  (kbd "gl") #'evil-end-of-line
  (kbd "gs") #'evil-first-non-blank)

(defun my-visual-v ()
  "In charwise visual, switch to linewise (like `vv'). Otherwise toggle as usual."
  (interactive)
  (if (eq evil-visual-selection 'char)
      (evil-visual-line)
    (evil-visual-char)))

(defun my-visual-to-eol ()
  "Start charwise visual and select to end of line (like `v$')."
  (interactive)
  (evil-visual-char)
  (evil-end-of-line))

(with-eval-after-load 'evil
  (define-key evil-visual-state-map (kbd "v") #'my-visual-v)
  (evil-define-key 'normal 'global (kbd "V") #'my-visual-to-eol))

;; Predictable minibuffer with evil mode
(evil-set-initial-state 'minibuffer-mode 'insert)
(defun my-minibuffer-evil-setup ()
  (evil-local-set-key 'normal (kbd "RET") #'exit-minibuffer)
  (evil-local-set-key 'normal (kbd "<escape>") #'abort-recursive-edit))
(add-hook 'minibuffer-setup-hook #'my-minibuffer-evil-setup)

;; Evil collection
(use-package evil-collection
  :after evil
  :demand t
  :config
  (evil-collection-init))

;; C-[ as general purpose escape key sequence.
(defun my-esc (_prompt)
  "Return [escape] in Evil states, otherwise C-g."
  (if (or (evil-insert-state-p) (evil-normal-state-p)
          (evil-replace-state-p) (evil-visual-state-p))
      [escape]
    (kbd "C-g")))

(when (display-graphic-p)
  (define-key key-translation-map (kbd "C-[") #'my-esc)
  (define-key evil-operator-state-map (kbd "C-[") #'keyboard-quit))

;; Undo-fu + session -- Persistent and intuitive undo
(use-package undo-fu :demand t)

(use-package undo-fu-session
  :demand t
  :config
  (setq undo-fu-session-directory
        (expand-file-name "undo-fu-session/" user-emacs-directory))
  (undo-fu-session-global-mode 1))

(setq undo-limit 800000
      undo-strong-limit 12000000
      undo-outer-limit 120000000)

;; Evil org mode
(use-package evil-org
  :demand t
  :after org
  :hook (org-mode . evil-org-mode)
  :config
  (require 'evil-org-agenda)
  (evil-org-agenda-set-keys))

;; Evil commentary
(use-package evil-commentary
  :demand t
  :config
  (evil-commentary-mode))

;; Diminish -- hide minor modes in status bar
(use-package diminish :demand t)
(diminish 'eldoc-mode)
(diminish 'which-key-mode)
(diminish 'evil-commentary-mode)
(diminish 'evil-collection-unimpaired-mode)

;; Vertico
(use-package vertico
  :custom
  (vertico-scroll-margin 0)
  (vertico-count 20)
  (vertico-resize t)
  (vertico-cycle t)
  :init
  (vertico-mode))

;; Persist history over Emacs restarts. Vertico sorts by history position.
(use-package savehist
  :init
  (savehist-mode))

;; Emacs minibuffer configurations.
(use-package emacs
  :custom
  ;; Enable context menu. `vertico-multiform-mode' adds a menu in the minibuffer
  ;; to switch display modes.
  (context-menu-mode t)
  ;; Support opening new minibuffers from inside existing minibuffers.
  (enable-recursive-minibuffers t)
  ;; Hide commands in M-x which do not work in the current mode.  Vertico
  ;; commands are hidden in normal buffers. This setting is useful beyond
  ;; Vertico.
  (read-extended-command-predicate #'command-completion-default-include-p)
  ;; Do not allow the cursor in the minibuffer prompt
  (minibuffer-prompt-properties
   '(read-only t cursor-intangible t face minibuffer-prompt)))

;; Orderless -- convenient completion results
(use-package orderless
  :custom
  (completion-styles '(orderless basic))
  (completion-category-overrides '((file (styles partial-completion))))
  (completion-category-defaults nil)
  (completion-pcm-leading-wildcard t))

;; Marginalia -- descriptive annotations
(use-package marginalia
  :init
  (marginalia-mode))

;; Helpful -- Better help commands
(use-package helpful
  :bind
  (("C-h f" . helpful-callable)
   ("C-h v" . helpful-variable)
   ("C-h k" . helpful-key)
   ("C-h x" . helpful-command)))

(use-package pdf-tools
  :init
  (pdf-loader-install)
  :hook
  (pdf-view-mode . (lambda ()
                     (display-line-numbers-mode -1)
                     (setq-local cursor-type nil)
                     (setq-local evil-normal-state-cursor '(nil)))))

(use-package denote
  :demand t
  :hook (dired-mode . denote-dired-mode)
  :bind
  (("C-c n n" . denote)
   ("C-c n r" . denote-rename-file)
   ("C-c n l" . denote-link)
   ("C-c n b" . denote-backlinks)
   ("C-c n d" . denote-dired)
   ("C-c n g" . denote-grep))
  :config
  (setq denote-known-keywords
        '("snc185" "rel103" "csc373" "csc301"
          "lecture" "reading" "hw" "idea"
          "todo" "incomplete" "review" "confusing"
          "midterm" "final" "fall26"
          "ref" "code" "admin"))
  (setq denote-infer-keywords t)
  (setq denote-sort-keywords t)
  (setq denote-file-type nil)
  ;; stop vertico from auto selecting first entry
  (setq denote-prompts '(title keywords))
  (setq denote-date-prompt-use-org-read-date t)
  (setq denote-directory (expand-file-name "~/sync/notes/"))

  ;; Automatically rename Denote buffers when visiting them
  (denote-rename-buffer-mode 1))

(defun my-eval-last-sexp ()
  "Like `eval-last-sexp', but also works when point is on the closing paren in Evil normal state."
  (interactive)
  (save-excursion
    (unless (eobp) (forward-char))
    (call-interactively #'eval-last-sexp)))

;;; Leader key execute
(defvar-keymap my-execute-map
  :doc "Execute commands under SPC x."
  "e" #'my-eval-last-sexp
  "d" #'eval-defun
  "b" #'eval-buffer
  "r" #'eval-region
  "s" #'shell-command
  "c" #'compile)

;;; Leader key help
(defvar-keymap my-help-map
  :doc "Help commands under SPC h."
  "f" #'helpful-callable
  "v" #'helpful-variable
  "k" #'helpful-key
  "x" #'helpful-command
  "m" #'helpful-macro
  "p" #'helpful-at-point
  "F" #'helpful-function)

;;; Leader key notes (denote)
(defvar-keymap my-notes-map
  :doc "Denote commands under SPC n."
  "n" #'denote
  "o" #'denote-open-or-create
  "l" #'denote-link
  "L" #'denote-link-after-creating
  "b" #'denote-backlinks
  "d" #'denote-dired
  "g" #'denote-grep
  "r" #'denote-rename-file
  "R" #'denote-rename-file-using-front-matter
  "k" #'denote-keywords-add
  "K" #'denote-keywords-remove
  "s" #'denote-silo)

;; Leader key bindings
(defvar-keymap my-leader-map
  :doc "Leader key map."
  "SPC" #'execute-extended-command
  "u" #'universal-argument
  "f" #'find-file
  "r" #'recentf
  "e" #'dired-jump
  "b" #'switch-to-buffer
  "w" #'save-buffer
  "x" my-execute-map
  "h" my-help-map
  "n" my-notes-map)

(define-key evil-motion-state-map (kbd "SPC") nil)
(define-key evil-normal-state-map (kbd "SPC") nil)
(evil-define-key '(normal motion visual) 'global (kbd "SPC") my-leader-map)

(which-key-add-keymap-based-replacements my-leader-map
  "x" "execute"
  "h" "help")

(provide 'init)
;;; init.el ends here
