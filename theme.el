; colors
(if (>= emacs-major-version 24)
    (progn
      (add-to-list 'custom-theme-load-path "~/.emacs.d/themes/")
      (load-theme 'twilight)
      )
  (progn
    (require 'color-theme)
    (setq color-theme-is-global t)
    (require 'zenburn)
    (color-theme-zenburn)))
