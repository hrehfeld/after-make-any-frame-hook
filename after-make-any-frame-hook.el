;; after-make-any-frame-hook.el --- Run hooks after any frame is created, including the initial frame

;; Author: Hauke Rehfeld
;; Version: 0.1
;; Package-Requires: ((emacs "27.1"))
;; Keywords: frames, hooks

;;; Commentary:
;; This package provides two hooks:
;; 1. `after-make-any-frame-hook-initial-frame-hook`: Run once after the initial frame is created.
;; 2. `after-make-any-frame-hook-any-frame-hook`: Run after any frame is created, including the initial frame.

;;; Code:

(defvar after-make-any-frame-hook-initial-frame-done nil
  "Non-nil if the initial frame hook has already been run.")

(defvar after-make-any-frame-hook-initial-frame-hook nil
  "Normal hook run once after the initial frame is created.")

(defvar after-make-any-frame-hook-any-frame-hook nil
  "Normal hook run after any frame is created, including the initial frame.")

(defvar after-make-any-frame-hook-any-frame-hook--retry-timer-delay 0.1 "Delay until we try checking for frame focus again.")

(defun after-make-any-frame-hook-run (&optional frame)
  "Run `after-make-any-frame-hook-any-frame-hook' and, if appropriate, `after-make-any-frame-hook-initial-frame-hook' for FRAME."
  (let ((focused-frame (cl-find-if (lambda (frame) (eq (frame-focus-state frame) t)) (frame-list))))
    (if focused-frame
        ;; only run hooks once frame is focused
        (progn
          (if after-make-any-frame-hook-initial-frame-done
              (progn
                (message "running any frame hook %S %S %S" (selected-frame) (frame-live-p (selected-frame)) (cl-find-if (lambda (frame) (eq (frame-focus-state frame) t)) (frame-list)))
                (ignore-errors
                  (run-hooks 'after-make-any-frame-hook-any-frame-hook)))
            (message "running first any frame hook %S %S %S" (selected-frame) (frame-live-p (selected-frame)) (cl-find-if (lambda (frame) (eq (frame-focus-state frame) t)) (frame-list)))
            (setq after-make-any-frame-hook-initial-frame-done t))
            (ignore-errors
              (run-hooks 'after-make-any-frame-hook-initial-frame-hook))
          )
      (message "retrying for live frame")
      (run-with-timer after-make-any-frame-hook-any-frame-hook--retry-timer-delay nil #'after-make-any-frame-hook-run))))

(defun after-make-any-frame-hook-setup ()
  "Set up hooks to run `after-make-any-frame-hook-run' after frame creation."
  ;; For frames created in daemon mode or via emacsclient
  (add-hook 'server-after-make-frame-hook #'after-make-any-frame-hook-run)
  (add-hook 'after-make-frame-functions 'after-make-any-frame-hook-run)
  ;; For the initial frame in non-daemon mode, since neither hook above will catch it
  ;; (unless (or (daemonp) after-make-any-frame-hook-initial-frame-done)
  ;;   (after-make-any-frame-hook-run))
  )

;; Set up the package
(after-make-any-frame-hook-setup)

(provide 'after-make-any-frame-hook)

;;; after-make-any-frame-hook.el ends here
