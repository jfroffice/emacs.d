(add-to-list 'load-path "~/.emacs.d/vendor/multiple-cursors.el")
(require 'multiple-cursors)

(global-set-key (kbd "C-S-c C-S-c") 'mc/edit-lines)
(global-set-key (kbd "C-S-c C-a") 'mc/edit-beginnings-of-lines)
(global-set-key (kbd "C-S-c C-e") 'mc/edit-ends-of-lines)

(global-set-key (kbd "s-SPC") 'set-rectangular-region-anchor)
