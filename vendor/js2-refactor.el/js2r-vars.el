(require 'mark-multiple)

;; Helpers

(defun js2r--name-node-at-point ()
  (let ((current-node (js2-node-at-point)))
    (unless (js2-name-node-p current-node)
      (setq current-node (js2-node-at-point (- (point) 1))))
    (if (not (and current-node (js2-name-node-p current-node)))
        (error "Point is not on an identifier.")
      current-node)))

(defun js2r--local-name-node-at-point ()
  (let ((current-node (js2r--name-node-at-point)))
    (unless (js2r--local-name-node-p current-node)
      (error "Point is not on a local identifier"))
    current-node))

(defun js2r--local-name-node-p (node)
  (and (js2-name-node-p node)
       (not (save-excursion ; not key in object literal { key: value }
              (goto-char (+ (js2-node-abs-pos node) (js2-node-len node)))
              (looking-at "[\n\t ]*:")))
       (not (save-excursion ; not property lookup on object
              (goto-char (js2-node-abs-pos node))
              (looking-back "\\.[\n\t ]*")))))

(defun js2r--local-var-positions (var-node)
  (unless (js2r--local-name-node-p var-node)
    (error "Node is not on a local identifier"))
  (let* ((name (js2-name-node-name var-node))
         (scope (js2-node-get-enclosing-scope var-node))
         (scope (js2-get-defining-scope scope name))
         (current-start (js2-node-abs-pos var-node))
         (current-end (+ current-start (js2-node-len var-node)))
         (result nil))
    (js2-visit-ast
     scope
     (lambda (node end-p)
       (when (and (not end-p)
                  (js2r--local-name-node-p node)
                  (string= name (js2-name-node-name node)))
         (add-to-list 'result (js2-node-abs-pos node)))
       t))
    result))

(defun js2r--var-defining-node (var-node)
  (unless (js2r--local-name-node-p var-node)
    (error "Node is not on a local identifier"))
  (let* ((name (js2-name-node-name var-node))
         (scope (js2-node-get-enclosing-scope var-node))
         (scope (js2-get-defining-scope scope name)))
    (js2-symbol-ast-node
     (js2-scope-get-symbol scope name))))


;; Add to jslint globals annotation

(defun current-line-contents ()
  "Find the contents of the current line, minus indentation."
  (buffer-substring (save-excursion (back-to-indentation) (point))
                    (save-excursion (end-of-line) (point))))

(require 'thingatpt)

(defun js2r-add-to-globals-annotation ()
  (interactive)
  (let ((var (word-at-point)))
    (save-excursion
      (beginning-of-buffer)
      (when (not (string-match "^/\\* global " (current-line-contents)))
        (newline)
        (forward-line -1)
        (insert "/* global */")
        (newline)
        (forward-line -1))
      (while (not (string-match "*/" (current-line-contents)))
        (forward-line))
      (end-of-line)
      (delete-char -2)
      (unless (looking-back "global ")
        (while (looking-back " ")
          (delete-char -1))
        (insert ", "))
      (insert (concat var " */")))))


;; Rename variable

(defun js2r-rename-var ()
  "Renames the variable on point and all occurrences in its lexical scope."
  (interactive)
  (js2r--guard)
  (let* ((current-node (js2r--local-name-node-at-point))
         (len (js2-node-len current-node))
         (current-start (js2-node-abs-pos current-node))
         (current-end (+ current-start len)))
    (push-mark current-end)
    (goto-char current-start)
    (activate-mark)
    (mm/create-master current-start current-end)
    (js2-with-unmodifying-text-property-changes
      (mapc (lambda (beg)
              (when (not (= beg current-start))
                (mm/add-mirror beg (+ beg len))))
            (js2r--local-var-positions current-node)))))

;; Change local variable to use this. instead

(defun js2r-var-to-this ()
  "Changes the variable on point to use this.var instead."
  (interactive)
  (js2r--guard)
  (save-excursion
    (mapc (lambda (beg)
            (goto-char beg)
            (when (looking-back "var ")
              (delete-char -4))
            (insert "this."))
          (js2r--local-var-positions (js2r--local-name-node-at-point)))))

;; Inline var

(defun js2r-inline-var ()
  (interactive)
  (js2r--guard)
  (save-excursion
    (let* ((current-node (js2r--local-name-node-at-point))
           (definer (js2r--var-defining-node current-node))
           (definer-start (js2-node-abs-pos definer))
           (var-init-node (js2-node-parent definer))
           (initializer (js2-var-init-node-initializer
                         var-init-node)))
      (unless initializer
        (error "Var is not initialized when defined."))
      (let* ((var-len (js2-node-len current-node))
             (init-beg (js2-node-abs-pos initializer))
             (init-end (+ init-beg (js2-node-len initializer)))
             (contents (buffer-substring init-beg init-end)))
        (mapc (lambda (beg)
                (when (not (= beg definer-start))
                  (goto-char beg)
                  (delete-char var-len)
                  (insert contents)))
              (js2r--local-var-positions current-node))
        (js2r--delete-var-init-node var-init-node)
        ))))


(defun js2r--was-single-var ()
  (or (string= "var ;" (current-line-contents))
      (string= "," (current-line-contents))))

(defun js2r--was-starting-var ()
  (looking-back "var "))

(defun js2r--was-ending-var ()
  (looking-at ";"))

(defun js2r--delete-var-init-node (node)
  (goto-char (js2-node-abs-pos node))
  (delete-char (js2-node-len node))
  (cond
   ((js2r--was-single-var)
    (beginning-of-line)
    (delete-char (save-excursion (end-of-line) (current-column)))
    (delete-blank-lines))

   ((js2r--was-starting-var)
    (delete-char 1)
    (if (looking-at " ")
        (delete-char 1)
      (join-line -1)))

   ((js2r--was-ending-var)
    (if (looking-back ", ")
        (delete-char -1)
      (join-line)
      (delete-char 1))
    (delete-char -1))

   (t (delete-char 2)
      )))

;; two cases
;;   - it's the only var -> remove the line
;;   - there are several vars -> remove the node then clean up commas


;; Extract variable

(defun js2r--start-of-parent-stmt ()
  (js2-node-abs-pos (js2-node-parent-stmt (js2-node-at-point))))

(defun js2r--object-literal-key-behind (pos)
  (save-excursion
    (goto-char pos)
    (when (looking-back "\\sw: ?")
      (backward-char 2)
      (js2-name-node-name (js2r--name-node-at-point)))))

(defun js2r--line-above-is-blank ()
  (save-excursion
    (forward-line -1)
    (string= "" (current-line-contents))))

(defun js2r-extract-var (start end)
  (interactive "r")
  (unless (use-region-p)
    (error "Mark the expression you want to extract first."))
  (let ((deactivate-mark nil)
        (expression (buffer-substring start end))
        (varpos (make-marker))
        (name (or (js2r--object-literal-key-behind start) "name"))
        beg)
    (delete-region start end)
    (set-marker varpos (point))
    (insert name)
    (goto-char (js2r--start-of-parent-stmt))
    (insert "var ")
    (setq beg (point))
    (insert name)
    (insert (concat " = " expression ";"))
    (when (or (js2r--line-above-is-blank)
              (string-match-p "^function " expression))
      (newline))
    (newline)
    (goto-char varpos)
    (indent-region beg (point))
    (push-mark (+ (length name) varpos) t t)
    (mm/create-master varpos (+ (length name) varpos))
    (mm/add-mirror beg (+ (length name) beg))))

;; Split var declaration

(defun js2r-split-var-declaration ()
  (interactive)
  (js2r--guard)
  (save-excursion
    (let* ((declaration (or (js2r--closest #'js2-var-decl-node-p) (error "No var declaration at point.")))
           (kids (js2-var-decl-node-kids declaration))
           (stmt (js2-node-parent-stmt declaration)))
      (goto-char (js2-node-abs-end stmt))
      (mapc (lambda (kid)
              (insert "var " (js2-node-string kid) ";")
              (newline)
              (if (save-excursion
                    (goto-char (js2-node-abs-end kid))
                    (looking-at ", *\n *\n"))
                  (newline)))
            kids)
      (delete-char -1) ;; delete final newline
      (let ((end (point)))
        (js2r--goto-and-delete-node stmt)
        (indent-region (point) end)))))

(provide 'js2r-vars)
