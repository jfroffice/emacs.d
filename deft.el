(load-conf "org")

;; http://jblevins.org/projects/deft/
(when (require 'deft nil 'noerror) 
  (setq
   deft-extension "org"
   deft-directory "~/org/deft/"
   deft-text-mode 'org-mode)
  (global-set-key (kbd "<f9>") 'deft))
