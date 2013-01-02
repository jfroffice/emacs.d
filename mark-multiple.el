(require 'inline-string-rectangle)
(global-set-key (kbd "C-x r t") 'inline-string-rectangle)

(require 'mark-more-like-this)
(global-set-key (kbd "M-(") 'mark-previous-like-this)
(global-set-key (kbd "M-)") 'mark-next-like-this)

(require 'rename-sgml-tag)
(let ((map-rename-sgml-tag (lambda ()
                             (local-set-key (kbd "C-c C-r") 'rename-sgml-tag))))
  (add-hook 'nxml-mode-hook map-rename-sgml-tag)
  (add-hook 'eruby-html-mumamo-mode-hook map-rename-sgml-tag))

