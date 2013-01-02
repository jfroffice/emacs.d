(load-conf "yasnippet")
(load-conf "ruby-mode")

(add-to-list 'load-path "~/.emacs.d/vendor/rspec-mode")
(require 'rspec-mode)

(yas/load-directory "~/.emacs.d/vendor/yasnippets-rspec/rspec-snippets")
