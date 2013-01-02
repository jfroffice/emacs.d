;; ecb
(require 'ecb)
(setq ecb-tip-of-the-day nil)
(setq ecb-primary-secondary-mouse-buttons (quote mouse-1--mouse-2))

(add-hook 'window-setup-hook 'ecb-redraw-layout t)
