(autoload 'scss-mode "scss-mode")
(add-to-list 'auto-mode-alist '("\\.scss\\'" . scss-mode))
(setq scss-compile-at-save nil)

(defun configure-auto-complete-for-scss ()
  (add-to-list 'ac-sources 'ac-source-css-property))
(add-hook 'scss-mode-hook 'configure-auto-complete-for-scss)
(add-to-list 'ac-modes 'scss-mode)

(add-hook 'css-mode-hook 'rainbow-mode)
