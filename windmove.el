;; windmove

; windmove shows a stacktrace when there is nothing to move to

(defmacro maser/swallow-errors (name f-with-error)
  `(defun ,name ()
  (interactive)
  (condition-case err
       (,f-with-error)
     (error
      (message "%s" (error-message-string err))))))

(maser/swallow-errors windmove-down-without-errors  windmove-down)
(maser/swallow-errors windmove-up-without-errors  windmove-up)
(maser/swallow-errors windmove-right-without-errors  windmove-right)
(maser/swallow-errors windmove-left-without-errors  windmove-left)

(global-set-key (kbd "M-N") 'windmove-down-without-errors)
(global-set-key (kbd "M-P") 'windmove-up-without-errors)
(global-set-key (kbd "M-F") 'windmove-right-without-errors)
(global-set-key (kbd "M-B") 'windmove-left-without-errors)
