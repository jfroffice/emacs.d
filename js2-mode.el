(add-to-list 'load-path "~/.emacs.d/vendor/mooz-js2-mode")
(require 'js2-mode)
(add-to-list 'auto-mode-alist '("\\.js$" . js2-mode))
(require 'js2-highlight-vars)

(replace-auto-mode 'javascript-mode 'js2-mode)
(replace-auto-mode 'js-mode 'js2-mode)

;; js2 configuration
(setq js2-basic-offset 4)
(setq js2-mode-indent-ignore-first-tab t)
(setq js2-highlight-external-variables nil)
(setq js2-highlight-level 3)
(setq js2-mirror-mode nil)
(setq js2-mode-show-parse-errors nil)
(setq js2-mode-show-strict-warnings nil)
(setq js2-bounce-indent-p nil)
(setq js2-pretty-multiline-declarations t)

(defun my-js2-mode-hook ()
  (local-set-key (kbd "<return>") 'newline-and-indent)
  (if (featurep 'js2-highlight-vars)
      (js2-highlight-vars-mode)))

(add-hook 'js2-mode-hook 'my-js2-mode-hook)

(require 'flymake-jshint)
(add-hook 'js2-mode-hook 'flymake-mode)
(setq jshint-configuration-path "~/.jshint.json")
