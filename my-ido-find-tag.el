(load-conf "ido")

;; ido search for tags
(load-file "~/.emacs.d/vendor/my-ido-find-tag.el")
(global-set-key (kbd "M-.") 'my-ido-find-tag)
