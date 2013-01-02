;; Interactively Do Things
(require 'ido)
(ido-mode t)

(setq ido-enable-flex-matching t
      ido-enable-prefix nil
      ido-create-new-buffer 'always
      ido-use-filename-at-point nil
      ido-max-prospects 10)

(add-hook 'ido-setup-hook '(lambda ()
			     (define-key ido-completion-map "\C-h" 'ido-delete-backward-updir)
			     (define-key ido-completion-map "\C-n" 'ido-next-match)
			     (define-key ido-completion-map "\C-f" 'ido-next-match)
			     (define-key ido-completion-map "\C-p" 'ido-prev-match)
			     (define-key ido-completion-map "\C-b" 'ido-prev-match)
			     (define-key ido-completion-map " " 'ido-exit-minibuffer)
	  ))

;; Use C-w to go back up a dir to better match normal usage of C-w
;; - insert current file name with C-x C-w instead.
(define-key ido-file-completion-map (kbd "C-w") 'ido-delete-backward-updir)
(define-key ido-file-completion-map (kbd "C-x C-w") 'ido-copy-current-file-name)

;; Display ido results vertically, rather than horizontally
(setq ido-decorations (quote ("\n-> " "" "\n   " "\n   ..." "[" "]" " [No match]" " [Matched]" " [Not readable]" " [Too big]" " [Confirm]")))
(defun ido-disable-line-trucation () (set (make-local-variable 'truncate-lines) nil))
(add-hook 'ido-minibuffer-setup-hook 'ido-disable-line-trucation)

(ido-ubiquitous-mode 1)
