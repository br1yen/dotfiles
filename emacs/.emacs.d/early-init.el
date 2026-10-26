;;; early-init.el --- Early Init -*- lexical-binding: t; -*-

;; Prefer loading newer compiled files
(setq load-prefer-newer t)

;;; Garbage collection
;; Raise the threshold during startup, then restore it afterwards.

(setq gc-cons-threshold (if noninteractive
                            268435456 ; 256 MB
                          most-positive-fixnum)
      gc-cons-percentage 1.0)

(defvar post-startup-gc-cons-threshold (* 32 1024 1024)
  "Value to which `gc-cons-threshold' is set after Emacs startup.")

(defvar post-startup-gc-cons-percentage 0.1
  "Value to which `gc-cons-percentage' is set after Emacs startup.")

(defun restore-gc-after-startup ()
  "Restore garbage collection settings after startup."
  (setq gc-cons-threshold post-startup-gc-cons-threshold
        gc-cons-percentage post-startup-gc-cons-percentage))

(add-hook 'emacs-startup-hook #'restore-gc-after-startup 105)

;;; Native compilation and byte compilation

(unless (and (featurep 'native-compile)
             (fboundp 'native-comp-available-p)
             (native-comp-available-p))
  ;; Deactivate the `native-compile' feature if it is not available
  (setq native-comp-jit-compilation nil
        features (delq 'native-compile features)))

(setq native-comp-warning-on-missing-source init-file-debug
      native-comp-async-report-warnings-errors init-file-debug
      jka-compr-verbose init-file-debug
      byte-compile-warnings init-file-debug
      byte-compile-verbose init-file-debug)

;;; Miscellaneous

(set-language-environment "UTF-8")

(setq
 ;; Increase how much is read from processes in a single chunk
 read-process-output-max (* 1024 1024)
 process-adaptive-read-buffering nil

 ;; Don't ping things that look like domain names.
 ffap-machine-p-known 'reject

 warning-minimum-level (if init-file-debug :warning :error)
 warning-suppress-types '((defvaralias) (lexical-binding))
 warning-inhibit-types '((files missing-lexbind-cookie))

 ;; Disable warnings from the legacy advice API.
 ad-redefinition-action 'accept)

(when init-file-debug
  (setq message-log-max 16384))

;; No second, case-insensitive pass over `auto-mode-alist'.
(setq auto-mode-case-fold nil)

(unless noninteractive
  ;; In PGTK, this timeout introduces latency. Reducing it from the default 0.1
  ;; improves responsiveness.
  (when (boundp 'pgtk-wait-for-event-timeout)
    (setq pgtk-wait-for-event-timeout 0.001))

  (setq
   inhibit-compacting-font-caches t
   frame-resize-pixelwise t
   window-resize-pixelwise nil
   ;; Without this, Emacs will try to resize itself to a specific column size
   frame-inhibit-implied-resize t

   ;; Startup screen
   inhibit-startup-screen t
   inhibit-splash-screen t
   inhibit-startup-echo-area-message user-login-name
   initial-buffer-choice nil
   inhibit-startup-buffer-menu t
   inhibit-x-resources t

   ;; Give up some bidirectional functionality for slightly faster redisplay.
   bidi-inhibit-bpa t)

  (setq-default bidi-display-reordering 'left-to-right
                bidi-paragraph-direction 'left-to-right)

  (advice-add 'display-startup-echo-area-message :override #'ignore)
  (advice-add 'display-startup-screen :override #'ignore))

;;; Performance: file-name-handler-alist

(defvar original-file-name-handler-alist
  (default-toplevel-value 'file-name-handler-alist)
  "Value of `file-name-handler-alist' before startup optimizations.")

(defun respect-file-handlers-on-command-line (fn args-left)
  "Respect file handlers while Emacs processes command-line files.
FN is the function and ARGS-LEFT is the same argument as `command-line-1'.
Command-line files may be TRAMP paths, so restore `file-name-handler-alist'
for that stage of startup."
  (let ((file-name-handler-alist (if args-left
                                     original-file-name-handler-alist
                                   file-name-handler-alist)))
    (funcall fn args-left)))

(defun restore-file-name-handler-alist ()
  "Restore `file-name-handler-alist' after startup."
  (set-default-toplevel-value
   'file-name-handler-alist
   (delete-dups (append file-name-handler-alist
                        original-file-name-handler-alist))))

(unless (or init-file-debug noninteractive)
  ;; If bundled libraries are compressed, keep the gzip handler; otherwise omit
  ;; it during startup for faster startup and package load time.
  (set-default-toplevel-value
   'file-name-handler-alist
   (if (locate-file-internal "calc-loaddefs.el" load-path)
       nil
     (list (rassq 'jka-compr-handler
                  original-file-name-handler-alist))))

  (put 'file-name-handler-alist 'initial-value
       original-file-name-handler-alist)

  (advice-add 'command-line-1 :around #'respect-file-handlers-on-command-line)
  (add-hook 'emacs-startup-hook #'restore-file-name-handler-alist 101))

;;; UI elements

(unless noninteractive
  (setq frame-title-format "%b - Emacs"
        icon-title-format "%b - Emacs")

  ;; Set frame parameters through `default-frame-alist' and the mode variables
  ;; instead of calling the mode functions, which can trigger extra redraws.
  (push '(menu-bar-lines . 0) default-frame-alist)
  ;; On a TTY the initial frame is created before early-init.el loads, so
  ;; `default-frame-alist' does not apply to it.
  (unless initial-window-system
    (set-frame-parameter nil 'menu-bar-lines 0))
  (unless (memq window-system '(mac ns))
    (setq menu-bar-mode nil))

  (push '(tool-bar-lines . 0) default-frame-alist)
  (setq tool-bar-mode nil)

  (push '(vertical-scroll-bars) default-frame-alist)
  (push '(horizontal-scroll-bars) default-frame-alist)
  (setq default-frame-scroll-bars 'right
        scroll-bar-mode nil)

  (when (bound-and-true-p tooltip-mode)
    (tooltip-mode -1))

  ;; Disable GUI dialogs
  (setq use-file-dialog nil
        use-dialog-box nil)

  (add-to-list 'default-frame-alist '(font . "Inconsolata Medium-12")))

;;; Security

(setq gnutls-verify-error t
      tls-checktrust gnutls-verify-error)

;;; Package

(setq
 use-package-expand-minimally t
 use-package-minimum-reported-time (if init-file-debug 0 0.1)
 use-package-verbose init-file-debug
 use-package-always-ensure (not noninteractive)
 use-package-enable-imenu-support t

 package-enable-at-startup nil  ; init.el calls `package-initialize'
 package-archives '(("melpa"        . "https://melpa.org/packages/")
                    ("gnu"          . "https://elpa.gnu.org/packages/")
                    ("nongnu"       . "https://elpa.nongnu.org/nongnu/")
                    ("melpa-stable" . "https://stable.melpa.org/packages/"))
 package-archive-priorities '(("gnu"    . 99)
                              ("nongnu" . 80)
                              ("melpa"  . 70)
                              ("melpa-stable" . 50)))

;;; early-init.el ends here
