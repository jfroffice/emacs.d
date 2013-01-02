;; org-mode
;;(require 'org-install)

;;(add-to-list 'auto-mode-alist '("\\.org$" . org-mode))
;;(add-hook 'org-mode-hook 'flyspell-mode)
(global-set-key "\C-ca" 'org-agenda)

(setq org-agenda-custom-commands
      '(("l" "lazy TODOs" todo nil
	 ((org-agenda-skip-function
	  '(org-agenda-skip-entry-if 'scheduled 'deadline 'timestamp))))))

;; Fontify org-mode code blocks
;;(setq org-src-fontify-natively t)

;;(define-key global-map "\C-cc" 'org-capture)

;; (setq maser/todo-file (concat org-directory "/todo.org"))

;; (setq org-capture-templates
;;        '(("t" "TODO" entry (file jfroffice/todo-file)
;;  	 "* TODO %?\n  %i\n")))
