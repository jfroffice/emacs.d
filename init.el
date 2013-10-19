(when
    (load
     (expand-file-name "~/.emacs.d/package.el"))
  (package-initialize))

(defun load-conf (filename)
  "load the file in ~/.emacs.d/ unless it has already been loaded"
  (defvar *my-loaded-files* '())
  (if (not (memq filename *my-loaded-files*))
      (progn
        (load-file (expand-file-name (concat "~/.emacs.d/" filename ".el")))
        (add-to-list '*my-loaded-files* filename))))

;; This function replaces modes in some alist with another mode
;;
;; Some modes just insist on putting themselves into the
;; auto-mode-alist, this function helps me get rid of them
(defun replace-auto-mode (oldmode newmode)
  (dolist (aitem auto-mode-alist)
    (if (eq (cdr aitem) oldmode)
        (setcdr aitem newmode))))

(add-to-list 'load-path "~/.emacs.d/vendor/")

                                        ; basic
;;(load-conf "packages")
(load-conf "basic-customization")
(load-conf "customizations")
;;(load-conf "browser")
;;(load-conf "maxframe")
(load-conf "powerline")
;;(load-conf "redo")   ;; a l'air pas mal mais pas de racourci utilisable

;; permet de rechercher les fichiers a ouvrir par C-x b
;;(load-conf "ido")
(load-conf "dired-details")
(load-conf "uniquify")
(load-conf "theme")

;; C-x r m / l / b
(load-conf "bookmarks")
;; M-B or M-F
(load-conf "windmove")
(load-conf "whitespace")
;;(load-conf "hl-line")
;;(load-conf "my")
;; integrer dans emacs24
;;(load-conf "electric-indent-mode")

                                        ; general - text
;; a priori super mais ne fonctionne pas ESC <up> non redefinisable ???
(load-conf "move-text")
;;(load-conf "camelscore")
(load-conf "autopair")
                                        ; (load-conf "rainbow-delimiters")
;;(load-conf "lorem-ipsum")
                                        ; (load-conf "auto-fill-mode")
                                        ; (load-conf "viper")
(load-conf "mark-multiple")
(load-conf "multiple-cursors")
(load-conf "expand-region")
(load-conf "toggle-quotes")
(load-conf "highlight-indentation")
(load-conf "zencoding")

                                        ; general - other
(load-conf "auto-complete")
;;(load-conf "yasnippet")
(load-conf "etags-table")
;;(load-conf "my-ido-find-tag")
(load-conf "find-file-in-project")
(load-conf "ace-jump-mode")
(load-conf "smex")
;;(load-conf "annoying-arrows-mode")

(load-conf "flymake")
(load-conf "org")
(load-conf "deft")
(load-conf "magit")
;;(load-conf "edit-server")
                                        ; (load-conf "ecb")

                                        ; language modes
;;(load-conf "ruby-mode")
;;(load-conf "rspec-mode")
;;(load-conf "cucumber")
;;(load-conf "cc-mode")
;;(load-conf "puppet-mode")
;;(load-conf "coffee-mode")
(load-conf "css-mode")
;;(load-conf "nxhtml")
;;(load-conf "scss-mode")
;;(load-conf "sass-mode")
(load-conf "js2-mode")
(load-conf "js2-refactor")
;;(load-conf "markdown-mode")
;;(load-conf "yaml-mode")

(global-set-key "\C-w" 'clipboard-kill-region)

;; to fix yas with js2-mode
(eval-after-load 'js2-mode
  '(progn
     (define-key js2-mode-map (kbd "TAB") (lambda()
                                            (interactive)
                                            (let ((yas/fallback-behavior 'return-nil))
                                              (unless (yas/expand)
                                                (indent-for-tab-command)
                                                (if (looking-back "^\s*")
                                                    (back-to-indentation))))))))
