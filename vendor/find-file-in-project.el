;;; find-file-in-project.el

;; Copyright (C) 2008, 2009 Chris Wanstrath <chris@ozmm.org>

;; Licensed under the same terms as Emacs.

;; Keywords: textmate osx mac
;; Created: 22 Nov 2008
;; Author: Chris Wanstrath <chris@ozmm.org>
;; Version: 2

;; This file is NOT part of GNU Emacs.

;;; Commentary:

;; This minor mode has been extracted from textmate.el because
;; I only want to use its go to file feature.

;; A "project" in textmate-mode is determined by the presence of
;; a .git directory, an .hg directory, a Rakefile, or a Makefile.

;; You can configure what makes a project root by appending a file
;; or directory name onto the `*textmate-project-roots*' list.

;; If no project root indicator is found in your current directory,
;; textmate-mode will traverse upwards until one (or none) is found.
;; The directory housing the project root indicator (e.g. a .git or .hg
;; directory) is presumed to be the project's root.

;; In other words, calling Go to File from
;; ~/Projects/fieldrunners/app/views/towers/show.html.erb will use
;; ~/Projects/fieldrunners/ as the root if ~/Projects/fieldrunners/.git
;; exists.


;;; Minor mode

(defvar *find-file-in-project-gf-exclude* "/\\/\\.|(\\/|^)(\\.|vendor|fixtures|tmp|log|build)($|\\/)|(\\.xcodeproj|\\.nib|\\.framework|\\.app|\\.pbproj|\\.pbxproj|\\.xcode|\\.xcodeproj|\\.bundle|\\.pyc)$"
  "Regexp of files to exclude from `find-file-in-project-goto-file'.")

(defvar *find-file-in-project-project-roots*
  '(".git" ".hg" "Rakefile" "Makefile" "README" "build.xml" ".emacs-project")
  "The presence of any file/directory in this list indicates a project root.")

(defvar find-file-in-project-use-file-cache t
  "Should `find-file-in-project-goto-file' keep a local cache of files?")

(defvar find-file-in-project-completing-library 'ido
  "The library `textmade-goto-symbol' and `find-file-in-project-goto-file' should use for
completing filenames and symbols (`ido' by default)")

(defvar find-file-in-project-find-files-command "cd \"%s\"; find -type f | sed 's/^\\\.\\\///'"
  "The command `find-file-in-project-project-root' uses to find files. %s will be replaced
the project root.")

(defvar *find-file-in-project-completing-function-alist* '((ido ido-completing-read)
                                               (icicles  icicle-completing-read)
                                               (none completing-read))
  "The function to call to read file names and symbols from the user")

(defvar *find-file-in-project-completing-minor-mode-alist*
  `((ido ,(lambda (a) (progn (ido-mode a) (setq ido-enable-flex-matching t))))
    (icicles ,(lambda (a) (icy-mode a)))
    (none ,(lambda (a) ())))
  "The list of functions to enable and disable completing minor modes")


(defvar *find-file-in-project-mode-map*
  (let ((map (make-sparse-keymap)))
    ; what the hell is comment-or-uncomment-region doing here?!
    (define-key map [(control c)(control /)] 'comment-or-uncomment-region)
    (define-key map [(control x)(meta t)] 'find-file-in-project-goto-file)
    (define-key map (kbd "C-x t") 'find-file-in-project-goto-file)
  map))

(defvar *find-file-in-project-project-root* nil
  "Used internally to cache the project root.")
(defvar *find-file-in-project-project-files* '()
  "Used internally to cache the files in a project.")

;; (defun find-file-in-project-ido-fix ()
;;   "Add up/down keybindings for ido."
;;   (define-key ido-completion-map [up] 'ido-prev-match)
;;   (define-key ido-completion-map [down] 'ido-next-match))

(defun find-file-in-project-completing-read (&rest args)
  "Uses `*find-file-in-project-completing-function-alist*' to call the appropriate completing
function."
  (let ((reading-fn
         (cadr (assoc find-file-in-project-completing-library
                      *find-file-in-project-completing-function-alist*))))
  (apply (symbol-function reading-fn) args)))

;; http://chopmo.blogspot.com/2008/09/quickly-jumping-to-symbols.html
(defun find-file-in-project-goto-symbol ()
  "Update the imenu index and then use ido to select a symbol to navigate to.
Symbols matching the text at point are put first in the completion list."
  (interactive)
  (imenu--make-index-alist)
  (let ((name-and-pos '())
        (symbol-names '()))
    (flet ((addsymbols (symbol-list)
                       (when (listp symbol-list)
                         (dolist (symbol symbol-list)
                           (let ((name nil) (position nil))
                             (cond
                              ((and (listp symbol) (imenu--subalist-p symbol))
                               (addsymbols symbol))

                              ((listp symbol)
                               (setq name (car symbol))
                               (setq position (cdr symbol)))

                              ((stringp symbol)
                               (setq name symbol)
                               (setq position
                                     (get-text-property 1 'org-imenu-marker
                                                        symbol))))

                             (unless (or (null position) (null name))
                               (add-to-list 'symbol-names name)
                               (add-to-list 'name-and-pos (cons name position))))))))
      (addsymbols imenu--index-alist))
    ;; If there are matching symbols at point, put them at the beginning
    ;; of `symbol-names'.
    (let ((symbol-at-point (thing-at-point 'symbol)))
      (when symbol-at-point
        (let* ((regexp (concat (regexp-quote symbol-at-point) "$"))
               (matching-symbols (delq nil
                                       (mapcar
                                        (lambda (symbol)
                                          (if (string-match regexp symbol)
                                              symbol))
                                        symbol-names))))
          (when matching-symbols
            (sort matching-symbols (lambda (a b) (> (length a) (length b))))
            (mapc (lambda (symbol)
                    (setq symbol-names (cons symbol
                                             (delete symbol symbol-names))))
                  matching-symbols)))))
    (let* ((selected-symbol (ido-completing-read "Symbol? " (reverse symbol-names)))
           (position (cdr (assoc selected-symbol name-and-pos))))
      (goto-char (if (overlayp position) (overlay-start position) position)))))

(defun find-file-in-project-goto-file (prefix-arg)
  "Uses your completing read to quickly jump to a file in a project."
  (interactive "p")
  (let ((root (find-file-in-project-project-root)) (show-full-path (if (/= prefix-arg 1) 't)))
    (if (null root)
        (message "Can't find any .git directory")
      (let ((files (find-file-in-project-cached-project-files root))
            (name-file-mapping (make-hash-table :test 'equal))
            (display-names '()))

        ;; generate display names for files and a mapping from the name to the file name
        (mapcar (lambda (file)
                  (if show-full-path
                      (puthash file file name-file-mapping)
                    (find-file-in-project-puthash file name-file-mapping))
                  ) files)

        (maphash (lambda (display-name file)
                   (setq display-names (cons display-name display-names)))
                 name-file-mapping)
        
        (find-file
         (concat
          (expand-file-name root) "/"
          (gethash (find-file-in-project-completing-read
                    "Find file: "
                    display-names)
                   name-file-mapping)))))))

(defun find-file-in-project-puthash (file hash)
  "Put filename into hash, but make sure the key is unique (works more or less like uniquify)."
  (find-file-in-project-puthash-uniquify file 
                                         (find-file-in-project-puthash-find-unique-level file hash) 
                                         hash))

(defun find-file-in-project-puthash-find-unique-level (file hash &optional level)
  "Figure out how many levels of directories have to be included to make the file name unique in the hash."
  (if (null level)
      (setq level 0))
  (let ((max-level (- (length (reverse (split-string file "/"))) 1)))
       (cond ((> level max-level)
              max-level)
             ((null (gethash (find-file-in-project-puthash-build-name file level) hash))
              level)
             (t (find-file-in-project-puthash-find-unique-level file hash (+ level 1))))))

(defun find-file-in-project-puthash-uniquify (file level hash)
  "Put the filename into the hash and append `level' levels of directories to it and the existing file in the hash."
  (puthash (find-file-in-project-puthash-build-name file level) file hash)
  (if (> level 0)
      (let* ((old-level (- level 1))
             (old-entry-name (find-file-in-project-puthash-build-name file old-level))
             (old-entry (gethash old-entry-name hash)))
        (unless (string= old-entry file)
          (remhash old-entry-name hash)
          (puthash (find-file-in-project-puthash-build-name old-entry level) old-entry hash)))))


(defun find-file-in-project-puthash-build-name (file level)
  "Build a name that includes `level' directories"
  (let* ((levels (reverse (split-string file "/")))
        (actual-level (min (+ level 1) (length levels))))
    (if (< level 0)
        (error "level negative: %s" level))
    (mapconcat 'identity (nbutlast levels (- (length levels) actual-level)) "|")))

(defun find-file-in-project-clear-cache ()
  "Clears the project root and project files cache. Use after adding files."
  (interactive)
  (setq *find-file-in-project-project-root* nil)
  (setq *find-file-in-project-project-files* nil)
  (message "find-file-in-project-mode cache cleared."))

;;; Utilities

(defun find-file-in-project-project-files (root)
  "Finds all files in a given project."
  (let ((result (split-string
    (shell-command-to-string
     (concat
      (find-file-in-project-string-replace "%s" root find-file-in-project-find-files-command)
      "  | grep -vE '"
      *find-file-in-project-gf-exclude*
      "' | sed 's:"
      *find-file-in-project-project-root*
      "/::'")) "\n" t)))
    result)
)

;; http://snipplr.com/view/18683/stringreplace/
(defun find-file-in-project-string-replace (this withthat in)
  "replace THIS with WITHTHAT' in the string IN"
  (with-temp-buffer
    (insert in)
    (goto-char (point-min))
    (while (search-forward this nil t)
      (replace-match withthat nil t))
    (buffer-substring (point-min) (point-max))))


(defun find-file-in-project-cached-project-files (&optional root)
  "Finds and caches all files in a given project."
  (cond
   ((null find-file-in-project-use-file-cache) (find-file-in-project-project-files root))
   ((equal (find-file-in-project-project-root) (car *find-file-in-project-project-files*))
    (cdr *find-file-in-project-project-files*))
   (t (cdr (setq *find-file-in-project-project-files*
                 `(,root . ,(find-file-in-project-project-files root)))))))

(defun find-file-in-project-project-root ()
  "Returns the current project root."
  (when (or
         (null *find-file-in-project-project-root*)
         (not (string-match *find-file-in-project-project-root* default-directory)))
    (let ((root (find-file-in-project-find-project-root)))
      (if root
          (setq *find-file-in-project-project-root* (expand-file-name (concat root "/")))
        (setq *find-file-in-project-project-root* nil))))
  *find-file-in-project-project-root*)

(defun root-match(root names)
	(member (car names) (directory-files root)))

(defun root-matches(root names)
	(if (root-match root names)
			(root-match root names)
			(if (eq (length (cdr names)) 0)
					'nil
					(root-matches root (cdr names))
					)))

(defun find-file-in-project-find-project-root (&optional root)
  "Determines the current project root by recursively searching for an indicator."
  (when (null root) (setq root default-directory))
  (cond
   ((root-matches root *find-file-in-project-project-roots*)
		(expand-file-name root))
   ((equal (expand-file-name root) "/") nil)
   (t (find-file-in-project-find-project-root (concat (file-name-as-directory root) "..")))))

;;;###autoload
(define-minor-mode find-file-in-project-mode
  "find-file-in-project Minor Mode"
  :lighter " ffip"
  :global t
  :keymap *find-file-in-project-mode-map*
  ;; (add-hook 'ido-setup-hook 'find-file-in-project-ido-fix)
  ;; (find-file-in-project-define-comment-line)
  ;; activate preferred completion library
  (dolist (mode *find-file-in-project-completing-minor-mode-alist*)
    (if (eq (car mode) find-file-in-project-completing-library)
        (funcall (cadr mode) t)
      (when (fboundp
             (cadr (assoc (car mode) *find-file-in-project-completing-function-alist*)))
        (funcall (cadr mode) -1))))
)

(provide 'find-file-in-project)