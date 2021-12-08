(defun jbb-theme ()
  (interactive)
  (load-theme `manoj-dark
              1) ) ;; Suppresses the request for confirmation.

(defun shorten-other-window ()
  "Expand current window to use a bit more than half of the other window's lines."
  (interactive)
  (enlarge-window (floor (* (window-height (next-window)) 0.45))))

(global-auto-revert-mode t) ;; reload files when changed

(custom-set-variables
 ;; custom-set-variables was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
 '(custom-safe-themes
   '("cf7ed2618df675fdd07e64d5c84b32031ec97a8f84bfd7cc997938ad8fa0799f" default))
 '(org-adapt-indentation t) ;; contents inherit indentation changes
 '(org-fontify-done-headline nil)
 '(org-hide-block-startup t)
 '(org-id-link-to-org-use-id t)
 '(org-startup-folded t)
 '(org-todo-keywords '((sequence "TODO" "BLOCKED" "DONE")))
 '(package-archives
   '(("gnu" . "http://elpa.gnu.org/packages/")
     ("melpa" . "http://melpa.org/packages/")
     ("melpa-stable" . "http://stable.melpa.org/packages/")))
 '(package-selected-packages
   '(erlang org-roam undo-tree scala-mode python-mode org nix-mode markdown-mode magit intero hide-lines csv-mode auctex)))

;; word wrap when starting org-mode
(add-hook 'org-mode-hook 'toggle-truncate-lines)

;; custom, jbb
  (show-paren-mode 1)
  (tool-bar-mode -1) ;; hide some icons I never use
  ;; fonts, colors
    (add-to-list 'default-frame-alist '(background-color . "#eeeeee"))
    (set-face-attribute 'region nil :background "#ccc")
    (load-theme 'manoj-dark)

(custom-set-faces
 ;; custom-set-faces was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
 '(default ((t (:family "DejaVu Sans Mono" :foundry "PfEd" :slant normal :weight normal :height 220 :width normal))))
 '(ctrlf-highlight-active ((t (:inherit isearch :background "#00ff55" :distant-foreground "#550000" :foreground "#990000"))))
 '(org-level-1 ((t (:extend nil :foreground "#ff8888"))))
   ;; pink rather than red, which is dark
 '(org-level-10 ((t (:foreground "orange"))))
 '(org-level-11 ((t (:foreground "yellow"))))
 '(org-level-12 ((t (:foreground "green"))))
 '(org-level-13 ((t (:foreground "cyan"))))
 '(org-level-14 ((t (:foreground "blue"))))
 '(org-level-15 ((t (:foreground "purple"))))
 '(org-level-16 ((t (:foreground "red"))))
 '(org-level-2 ((t (:foreground "orange"))))
 '(org-level-3 ((t (:foreground "yellow"))))
 '(org-level-4 ((t (:foreground "green"))))
 '(org-level-5 ((t (:foreground "cyan"))))
 '(org-level-6 ((t (:foreground "blue"))))
 '(org-level-7 ((t (:foreground "purple"))))
 '(org-level-8 ((t (:foreground "red"))))
 '(org-level-9 ((t (:foreground "red"))))
 '(rainbow-delimiters-base-error-face ((t (:inherit rainbow-delimiters-base-face :background "Red" :foreground "White"))))
 '(rainbow-delimiters-depth-1-face ((t (:inherit rainbow-delimiters-base-face :background "Black" :foreground "White"))))
 '(rainbow-delimiters-depth-2-face ((t (:inherit rainbow-delimiters-base-face :background "white" :foreground "black"))))
 '(rainbow-delimiters-depth-3-face ((t (:inherit rainbow-delimiters-base-face :background "#000066" :foreground "White"))))
 '(rainbow-delimiters-depth-4-face ((t (:inherit rainbow-delimiters-base-face :background "#9999ff" :foreground "black"))))
 '(rainbow-delimiters-depth-5-face ((t (:inherit rainbow-delimiters-base-face :background "#003300" :foreground "white"))))
 '(rainbow-delimiters-depth-6-face ((t (:inherit rainbow-delimiters-base-face :background "#77ff77" :foreground "black"))))
 '(rainbow-delimiters-depth-7-face ((t (:inherit rainbow-delimiters-base-face :background "#884400" :foreground "white"))))
 '(rainbow-delimiters-depth-8-face ((t (:inherit rainbow-delimiters-base-face :background "#ffff66" :foreground "black"))))
 '(rainbow-delimiters-depth-9-face ((t (:inherit rainbow-delimiters-base-face :background "#550055" :foreground "#ffff33")))))

;; from Stevey Egge: https://sites.google.com/site/steveyegge2/my-dot-emacs-file
(defun rename-file-and-buffer (new-name)
  "Renames both current buffer and file it's visiting to NEW-NAME."
  (interactive "sNew name: ")
  (let ((name (buffer-name))
	(filename (buffer-file-name)))
    (if (not filename)
	(message "Buffer '%s' is not visiting a file!" name)
      (if (get-buffer new-name)
	  (message "A buffer named '%s' already exists!" new-name)
	(progn
	  (rename-file filename new-name 1)
	  (rename-buffer new-name)
	  (set-visited-file-name new-name)
	  (set-buffer-modified-p nil))))))

;; Never understood why Emacs doesn't have this function, either.
(defun move-buffer-file (dir)
  "Moves both current buffer and file it's visiting to DIR."
  (interactive "DNew directory: ")
  (let* ((name (buffer-name))
         (filename (buffer-file-name))
         (dir
          (if (string-match dir "\\(?:/\\|\\\\)$")
              (substring dir 0 -1) dir))
         (newname (concat dir "/" name)))
    (if (not filename)
        (message "Buffer '%s' is not visiting a file!" name)
      (progn
	(copy-file filename newname 1)
	(delete-file filename)
	(set-visited-file-name newname)))))

(put 'narrow-to-region 'disabled nil)
(put 'downcase-region 'disabled nil)
(put 'upcase-region 'disabled nil)
(put 'scroll-left 'disabled nil)

;; plucked from https://gitlab.haskell.org/ghc/ghc/-/wikis/emacs
(add-hook 'before-save-hook 'delete-trailing-whitespace)
(setq kill-whole-line t) ;; cursor at start => C-k kills the newline too
(column-number-mode 1)
(defun untabify-buffer ()
  "Untabify current buffer."
  (interactive)
  (save-excursion (untabify (point-min) (point-max))))
(setq-default fill-column 80) ;; reformat a comment with M-q
