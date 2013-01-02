;; redo
(add-to-list  'load-path "~/.emacs.d/vendor/redo")
(require 'redo)
;;(global-set-key [(meta backspace)] 'undo)
;;(global-set-key [(meta shift backspace)] 'redo)
(global-set-key [(control -)] 'redo)
