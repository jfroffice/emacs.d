(require 'sass-mode)

(defun sass-electric-indent-function (char)
  (if (eq major-mode 'sass-mode)
      false))
(add-hook 'electric-indent-functions 'sass-electric-indent-function)

(defun configure-auto-complete-for-sass ()
  (add-to-list 'ac-sources 'ac-source-css-property))
(add-hook 'sass-mode-hook 'configure-auto-complete-for-sass)
(add-to-list 'ac-modes 'sass-mode)

(add-hook 'sass-mode-hook 'rainbow-mode)
