(defvar my-tags-completion-table nil
  "Obarray of tag names defined in current tags table.")

(defun my-ido-find-tag ()
  "Find a tag using ido"
  (interactive)
    (my-tags-completion-table)
    (let (tag-names)
      (mapc (lambda (x)
              (unless (integerp x)
                (push (prin1-to-string x t) tag-names)))
            my-tags-completion-table)
      ;; put symbol-at-point at the beginning
      ;; inspired (i.e. copied) from textmate-goto-symbol in textmate.el
      (when (symbol-at-point)
        (let* ((regexp (concat (regexp-quote (prin1-to-string (symbol-at-point))) "$"))
               (matching-tags (delq nil
                                       (mapcar
                                        (lambda (tag)
                                          (if (string-match regexp tag)
                                              tag))
                                        tag-names))))
          (when matching-tags
            (sort matching-tags (lambda (a b) (> (length a) (length b))))
            (mapc (lambda (tag)
                    (setq tag-names (cons tag
                                             (delete tag tag-names))))
                  matching-tags))))
      (find-tag (ido-completing-read "Tag: " tag-names))))

(defun my-tags-completion-table ()
  "Build `tags-completion-table' on demand.
This is a copy of tags-completion-table from etags.el with one modification:
It calls anything-yaetags-make-candidates instead of (funcall tags-completion-function).

The tags included in the completion table are those in the current
tags table and its (recursively) included tags tables.
"
  (or my-tags-completion-table
      ;; No cached value for this buffer.
      (condition-case ()
          (let (current-table combined-table)
            (message "Making tags completion table for %s..." buffer-file-name)
            (save-excursion
              ;; Iterate over the current list of tags tables.
              (while (visit-tags-table-buffer (and combined-table t))
                ;; Find possible completions in this table.
                (message (number-to-string (length (setq current-table (anything-yaetags-make-candidates)))))
                ;; Merge this buffer's completions into the combined table.
                (if combined-table
                    (mapatoms
                     (lambda (sym) (intern (symbol-name sym) combined-table))
                     current-table)
                  (setq combined-table current-table))))
            (message "Making tags completion table for %s...done"
                     buffer-file-name)
            ;; Cache the result in a buffer-local variable.
            (setq my-tags-completion-table combined-table))
        (quit (message "Tags completion table construction aborted.")
              (setq my-tags-completion-table nil)))))


;; anything-yaetags-make-candidates from anything-yaetags.el, as
;; etags-tags-completion-table only returns 511 tags
;;
;;; anything-yaetags.el --- Yet another etags interface with anything.

;; Copyright (C) 2009  Taiki SUGAWARA

;; Author: Taiki SUGAWARA <buzz.taiki@gmail.com>
;; Keywords: anything, etags
;; Version: 1.0.1
;; Time-stamp: <2009-04-02 19:22:24 UTC taiki>
;; URL: http://www.emacswiki.org/cgi-bin/wiki/anything-yaetags.el

(defun anything-yaetags-make-candidates ()
  "Make tag candidates from current TAGS buffer.
We don't use `etags-tags-completion-table', because this function is faster than `etags-tags-completion-table'."
  (save-excursion
    (let ((tab (make-hash-table :test 'equal :size 511)))
      (let ((reporter
             (make-progress-reporter
              (format "Making candidates for %s..." buffer-file-name)
              (point-min) (point-max))))
        (goto-char (point-min))
        (while (re-search-forward "\^?\\(.+\\)\^a" nil t)
          (puthash (match-string-no-properties 1) t tab)
          (progress-reporter-update reporter (point)))
      (let ((msg (format "Sorting candidates for %s..." buffer-file-name))
            list)
        (message "%s" msg)
        (maphash (lambda (key value) (push key list))
                 tab)
        (prog1
            (sort list
                  (lambda (a b)
                    (let ((cmp (compare-strings a 0 nil b 0 nil t)))
                      (if (eq cmp t)
                          (string< a b)
                        (< cmp 0)))))
          (message "%sdone" msg)))))))
