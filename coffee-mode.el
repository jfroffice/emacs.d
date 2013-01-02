;; coffee-mode
(add-to-list 'load-path "~/.emacs.d/vendor/coffee-mode")
(require 'coffee-mode)
(add-hook 'coffee-mode-hook
	  '(lambda() (set (make-local-variable 'tab-width) 2)))