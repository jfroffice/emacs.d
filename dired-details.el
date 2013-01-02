(require 'dired)

;; dired-details
(require 'dired-details)
(setq dired-details-hidden-string "--- ")
(dired-details-install)

;; C-a is nicer in dired if it moves back to start of files
(defun dired-back-to-start-of-files ()
  (interactive)
  (backward-char (- (current-column) 2)))

(define-key dired-mode-map (kbd "C-a") 'dired-back-to-start-of-files)
