;;; nxhml
(load "~/.emacs.d/vendor/nxhtml/autostart.el")
(setq
 mumamo-chunk-coloring 1
 nxhtml-skip-welcome t
 rng-nxml-auto-validate-flag nil)

; can't stand the default colors
(custom-set-faces
 '(mumamo-background-chunk-major ((t nil)))
 '(mumamo-background-chunk-submode1 ((t (:background "#222222"))))
 '(mumamo-background-chunk-submode2 ((t (:background "#222222"))))
 '(mumamo-background-chunk-submode3 ((t (:background "#222222"))))
 '(mumamo-background-chunk-submode4 ((t (:background "#222222")))))

; I only want mumamo, not nxhtml-mode
(add-to-list 'auto-mode-alist '("\\.html\\'" . html-mumamo-mode))
(replace-auto-mode 'nxhtml-mumamo-mode 'html-mumamo-mode)

;; shut nxhtml up about obsolete variables, I am not maintaining the
;; package, why should I care?!
(when (and (equal emacs-major-version 23)
           (equal emacs-minor-version 3))
  (eval-after-load "bytecomp"
    '(add-to-list 'byte-compile-not-obsolete-vars
                  'font-lock-syntactic-keywords))
  (eval-after-load "bytecomp"
    '(add-to-list 'byte-compile-not-obsolete-vars
                  'font-lock-beginning-of-syntax-function))
  ;; tramp-compat.el clobbers this variable!
  (eval-after-load "tramp-compat"
    '(add-to-list 'byte-compile-not-obsolete-vars
                  'font-lock-syntactic-keywords))
  (eval-after-load "tramp-compat"
    '(add-to-list 'byte-compile-not-obsolete-vars
                  'font-lock-beginning-of-syntax-function)))
