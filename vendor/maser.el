;; some things that don’d deserve to have their own package

(defun maser-vim-o ()
  "insert new line below current line and move there"
  (interactive)
  (move-end-of-line nil)
  (newline-and-indent))

(defun maser-vim-O ()
  "insert new line above current line and move there"
  (interactive)
  (move-beginning-of-line nil)
  (open-line 1)
  (indent-according-to-mode))
