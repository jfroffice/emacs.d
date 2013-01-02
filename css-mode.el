;; css
(add-hook 'css-mode-hook
         (lambda()
           (local-set-key (kbd "<return>") 'newline-and-indent)
))

(add-hook 'css-mode-hook 'rainbow-mode)
