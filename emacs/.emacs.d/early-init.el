;;; early-init.el --- performance optimizations -*- lexical-binding: t; no-byte-compile: t; -*-

;;; Commentary:

;;; Code:

;; GC: off during startup, restored after
(setq gc-cons-threshold most-positive-fixnum
      gc-cons-percentage 1.0)
(add-hook 'emacs-startup-hook
          (lambda () (setq gc-cons-threshold (* 16 1024 1024)
                           gc-cons-percentage 0.1)))

;; Skip file-name handlers during startup
(defvar my--fnha file-name-handler-alist)
(setq file-name-handler-alist nil)
(add-hook 'emacs-startup-hook
          (lambda () (setq file-name-handler-alist my--fnha)))

;; Package system: stop the automatic init (init.el does it)
(setq package-enable-at-startup nil)

;; Native comp noise
(setq native-comp-async-report-warnings-errors 'silent)

;; Frame/UI
(setq frame-inhibit-implied-resize t
      frame-resize-pixelwise t
      inhibit-startup-screen t
      inhibit-x-resources t
      inhibit-compacting-font-caches t)
(push '(menu-bar-lines . 1) default-frame-alist)
(push '(tool-bar-lines . 0) default-frame-alist)
(push '(vertical-scroll-bars) default-frame-alist)
(push '(background-color . "#ffffff") default-frame-alist)
(push '(foreground-color . "#000000") default-frame-alist)
(push '(font . "Hack-12") default-frame-alist)

(add-hook 'emacs-startup-hook
          (lambda ()
            (setq file-name-handler-alist
                  (delete-dups (append file-name-handler-alist my--fnha)))))

(provide 'early-init)
;;; early-init.el ends here
