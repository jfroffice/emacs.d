(require 'mark-multiple)

(defun maser/toggle-quotes-mark-and-then-toggle ()
  (er/mark-outside-quotes)
  (if mark-active
      (maser/toggle-quotes (region-beginning) (region-end))))

(defun maser/toggle-quotes-region-quoted? (start end)
  (let ((first-char (buffer-substring start (+ start 1)))
        (last-char (buffer-substring (- end 1) end)))
    (and
     (string-equal first-char last-char)
     (or (string-equal "'" first-char)
         (string-equal "\"" first-char)))))

(defun maser/toggle-quotes-region-without-quotes (start end)
  (buffer-substring (+ start 1) (- end 1)))

(defun maser/toggle-quotes-toggle-quote-character (quote-character)
  (if (string-equal "'" quote-character)
      "\""
    "'"))

(defun maser/toggle-quotes-replace-quotes (start end new-quote-character)
  (goto-char start)
  (delete-char 1)
  (insert new-quote-character)
  (goto-char end)
  (delete-char -1)
  (insert new-quote-character))

(defun maser/toggle-quotes (start end)
  (interactive "r")
  (save-excursion
    (if (not mark-active)
        (maser/toggle-quotes-mark-and-then-toggle)
      (when (maser/toggle-quotes-region-quoted? start end)
        (let 
            ((quote-character (maser/toggle-quotes-toggle-quote-character (buffer-substring start (+ start 1)))))
          (maser/toggle-quotes-replace-quotes start end quote-character))))))

(provide 'toggle-quotes)
