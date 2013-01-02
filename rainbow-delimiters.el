(when (require 'rainbow-delimiters nil 'noerror)
  (progn
    (add-hook 'ruby-mode-hook 'rainbow-delimiters-mode)
    (add-hook 'js2-mode-hook 'rainbow-delimiters-mode)
    (add-hook 'scss-mode-hook 'rainbow-delimiters-mode)
    (add-hook 'emacs-lisp-mode-hook 'rainbow-delimiters-mode)))
