(add-to-list 'load-path
              "~/.emacs.d/vendor")
(require 'yasnippet-bundle)
;;(require 'yasnippet)
(yas/initialize)
(yas/load-directory "~/.emacs.d/vendor/my-snippets")
