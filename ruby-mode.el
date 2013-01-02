(load-conf "nxhtml")
(load-conf "yasnippet")
(load-conf "flymake")

;; ruby-mode
(require 'ruby-mode)
(add-to-list 'auto-mode-alist '("\\.rjs$" . ruby-mode))
(add-to-list 'auto-mode-alist '("\\.rake$" . ruby-mode))
(add-to-list 'auto-mode-alist '("Rakefile" . ruby-mode))
(add-to-list 'auto-mode-alist '("Capfile" . ruby-mode))
(add-to-list 'auto-mode-alist '("Gemfile" . ruby-mode))
(add-to-list 'auto-mode-alist '("Vagrantfile" . ruby-mode))
(add-to-list 'auto-mode-alist '(".irbrc" . ruby-mode))
(add-to-list 'auto-mode-alist '("\\.builder$" . ruby-mode))
(add-to-list 'auto-mode-alist '("\\.rabl$" . ruby-mode))

(defun my-newline-and-indent ()
  "I don't like backtraces popping up and ruby-indent-line seems to really enjoy that."
  (interactive)
  (condition-case err
      (newline-and-indent)
    (error
     (message "%s" (error-message-string err))))
  )

(defun update-tags-file ()
  (when (and (eq major-mode 'ruby-mode) buffer-file-name (not (string-match "\.erb$" buffer-file-name)))
                                        ; make sure tags-file-name variable is set
    (etags-table-build-table-list buffer-file-name)
    (if tags-file-name
        (let* ((file-to-update buffer-file-name)
               (tags-file-to-update tags-file-name)
               (output
                (condition-case err
                    (progn
                      (with-output-to-string
                        (with-current-buffer standard-output
                          (message "hello")
                          (message file-to-update)
                          (message tags-file-to-update)
                          (call-process "/home/maser/.bin/rtags" nil t nil "--quiet" "-a" "-f" tags-file-to-update file-to-update)
                          (message "TAGS file updated"))))
                  (error (message "%s" (error-message-string err))))))))))

;; ruby-mode-hook
(add-hook 'ruby-mode-hook
          (lambda ()
            (add-hook 'after-save-hook 'update-tags-file)
            (set (make-local-variable 'indent-tabs-mode) 'nil)
            (set (make-local-variable 'tab-width) 2)
            (when (not (and (eq major-mode 'ruby-mode) buffer-file-name (not (string-match "\.erb$" buffer-file-name))))
              (set (make-local-variable 'ruby-insert-encoding-magic-comment) nil))
            (local-set-key (kbd "<return>") 'my-newline-and-indent)
            (add-to-list 'ac-sources 'ac-source-rsense-method)
            (add-to-list 'ac-sources 'ac-source-rsense-constant)
            (flyspell-prog-mode)
            (highlight-indentation-current-column-mode)
            ))

; use html-mode, not nxhtml-mode for erb mumamo
(add-to-list 'auto-mode-alist '("\\.html\\.erb\\'" . eruby-html-mumamo-mode))
; mumamo for .text.plain.erb files
(add-to-list 'auto-mode-alist '("\\.text\\.plain\\.erb\\'" . eruby-mumamo-mode))

;; Rsense
(setq rsense-home (expand-file-name "~/.emacs.d/vendor/rsense"))
(add-to-list 'load-path (concat rsense-home "/etc"))
(require 'rsense)

(yas/load-directory "~/.emacs.d/vendor/yasnippets-rails/rails-snippets")

; automatically reindent after typing "end"
(defun ruby-electric-indent-function (char)
  (if (eq major-mode 'ruby-mode)
      (if (char-equal char ?d)
          (string-equal "end" (buffer-substring (max 1 (- (point) 3)) (point))))))
(add-hook 'electric-indent-functions 'ruby-electric-indent-function)


;; do not complete end keyword
(add-hook 'ruby-mode-hook
          (lambda ()
            (make-local-variable 'ac-stop-words)
            (add-to-list 'ac-stop-words "end")))
