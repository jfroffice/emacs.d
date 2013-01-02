(add-to-list 'load-path "~/.emacs.d/vendor/expand-region.el")
(require 'expand-region)
(global-set-key (kbd "C-M-m") 'er/expand-region)
(global-set-key (kbd "C-M-c") 'er/contract-region)
