;; move-text
(require 'move-text)
(define-key input-decode-map "\e\eOA" [(meta up)])
(define-key input-decode-map "\e\eOB" [(meta down)])
(global-set-key [(meta up)] 'move-text-up)
(global-set-key [(meta down)] 'move-text-down)
