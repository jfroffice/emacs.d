;; maxframe
(add-to-list  'load-path "~/.emacs.d/vendor/maxframe")
(require 'maxframe)
(add-hook 'window-setup-hook 'maximize-frame t)
