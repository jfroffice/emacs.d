(require 'whitespace)
;;(setq whitespace-style '(trailing face lines-tail))
(setq whitespace-style '(trailing face tabs lines-tail))

(defun enable-whitespace-mode ()
  (whitespace-mode 1))
(add-hook 'prog-mode-hook 'enable-whitespace-mode)

(setq modes-where-I-want-whitespace-mode-to-be-enabled
      '(ruby-mode-hook
        javascript-mode-hook
        js-mode-hook
        css-mode-hook
        sass-mode-hook
        yaml-mode-hook
;;        emacs-lisp-mode-hook
        nxhtml-mode-hook))

(mapc (lambda (mode-hook)
        (add-hook mode-hook 'enable-whitespace-mode))
      modes-where-I-want-whitespace-mode-to-be-enabled)
