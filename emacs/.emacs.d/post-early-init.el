;;; post-early-init.el --- Loads after early-init.el -*- no-byte-compile: t; lexical-binding: t; -*-

(let ((deny-list '("\\(?:[/\\\\]\\.dir-locals\\.el\\(?:\\.gz\\)?$\\)"
                   "\\(?:[/\\\\]modus-vivendi-theme\\.el\\(?:\\.gz\\)?$\\)"
                   "\\(?:[/\\\\][^/\\\\]+-loaddefs\\.el\\(?:\\.gz\\)?$\\)"
                   "\\(?:[/\\\\][^/\\\\]+-autoloads\\.el\\(?:\\.gz\\)?$\\)")))
  (setq native-comp-jit-compilation-deny-list deny-list)
  (with-no-warnings
    (setq native-comp-deferred-compilation-deny-list deny-list)
    (setq comp-deferred-compilation-deny-list deny-list)))

;; Prevent Emacs from writing custom settings to any file
(with-eval-after-load 'cus-edit
  (advice-add 'custom-save-all :override #'ignore))
