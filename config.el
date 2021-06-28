;; [[file:config.org::*doom emacs init][doom emacs init:1]]
;;; $DOOMDIR/config.el -*- lexical-binding: t; -*-

;; Place your private configuration here! Remember, you do not need to run 'doom
;; sync' after modifying this file!


;; Some functionality uses this to identify you, e.g. GPG configuration, email
;; clients, file templates and snippets.
(setq user-full-name "An Li"
      user-mail-address "kidylee@gmail.com")

;; Doom exposes five (optional) variables for controlling fonts in Doom. Here
;; are the three important ones:
;;
;; + `doom-font'
;; + `doom-variable-pitch-font'
;; + `doom-big-font' -- used for `doom-big-font-mode'; use this for
;;   presentations or streaming.
;;
;; They all accept either a font-spec, font string ("Input Mono-12"), or xlfd
;; font string. You generally only need these two:
;; (setq doom-font (font-spec :family "monospace" :size 12 :weight 'semi-light)
;;       doom-variable-pitch-font (font-spec :family "sans" :size 13))

;; There are two ways to load a theme. Both assume the theme is installed and
;; available. You can either set `doom-theme' or manually load a theme with the
;; `load-theme' function. This is the default:
(setq doom-theme 'doom-one)


;; If you use `org' and don't want your org files in the default location below,
;; change `org-directory'. It must be set before org loads!
(setq org-directory "~/org/")

;; This determines the style of line numbers in effect. If set to `nil', line
;; numbers are disabled. For relative line numbers, set this to `relative'.
(setq display-line-numbers-type t)


;; Here are some additional functions/macros that could help you configure Doom:
;;
;; - `load!' for loading external *.el files relative to this one
;; - `use-package!' for configuring packages
;; - `after!' for running code after a package has loaded
;; - `add-load-path!' for adding directories to the `load-path', relative to
;;   this file. Emacs searches the `load-path' when you load packages with
;;   `require' or `use-package'.
;; - `map!' for binding new keys
;;
;; To get information about any of these functions/macros, move the cursor over
;; the highlighted symbol at press 'K' (non-evil users must press 'C-c c k').
;; This will open documentation for it, including demos of how they are used.
;;
;; You can also try 'gd' (or 'C-c c d') to jump to their definition and see how
;; they are implemented.
;; doom emacs init:1 ends here

;; [[file:config.org::*Simple settings][Simple settings:1]]
(setq-default
 delete-by-moving-to-trash t                      ; Delete files to trash
 window-combination-resize t                      ; take new window space from all other windows (not just current)
 x-stretch-cursor t)                              ; Stretch cursor to the glyph width

(setq undo-limit 80000000                         ; Raise undo-limit to 80Mb
      auto-save-default t                         ; Nobody likes to loose work, I certainly don't
      truncate-string-ellipsis "…")               ; Unicode ellispis are nicer than "...", and also save /precious/ space

(display-time-mode 1)                             ; Enable time in the mode-line

(if (equal "Battery status not available"
           (battery))
    (display-battery-mode 1)                        ; On laptops it's nice to know how much power you have
  (setq password-cache-expiry nil))               ; I can trust my desktops ... can't I? (no battery = desktop)

(global-subword-mode 1)                           ; Iterate through CamelCase words

(delete-selection-mode 1)
(add-hook 'prog-mode-hook 'delete-selection-mode)
(setq save-interprogram-paste-before-kill t)
;; Simple settings:1 ends here

;; [[file:config.org::*UI][UI:1]]
(add-to-list 'default-frame-alist '(fullscreen . maximized))
;; UI:1 ends here

;; [[file:config.org::*Windows][Windows:1]]
(global-set-key (kbd "C-x 2") (lambda () (interactive) (split-window-below) (other-window 1) (+ivy/switch-buffer)))
(global-set-key (kbd "C-x 3") (lambda () (interactive) (split-window-right) (other-window 1) (+ivy/switch-buffer)))

(setq +ivy-buffer-preview t)



(setq frame-title-format
      '(""
        (:eval
         (if (s-contains-p org-roam-directory (or buffer-file-name ""))
             (replace-regexp-in-string
              ".*/[0-9]*-?" "☰ "
              (subst-char-in-string ?_ ?  buffer-file-name))
           "%b"))
        (:eval
         (let ((project-name (projectile-project-name)))
           (unless (string= "-" project-name)
             (format (if (buffer-modified-p)  " ◉ %s" "  ●  %s") project-name))))))
;; Windows:1 ends here

;; [[file:config.org::*Hotkeys][Hotkeys:1]]
(map! "C-s" #'swiper)
(map! "M-0" #'treemacs-select-window)
(map! "C-M-j" #'+ivy/switch-workspace-buffer)
(map! "C-s-j" #'+ivy/switch-buffer)
(global-set-key [mouse-8] 'better-jumper-jump-backward)
(global-set-key [mouse-9] 'better-jumper-jump-forward)
;; Hotkeys:1 ends here

;; [[file:config.org::*Font][Font:1]]
(setq doom-font (font-spec :family "JetBrains Mono" :size 18)
      doom-big-font (font-spec :family "JetBrains Mono" :size 20)
      doom-variable-pitch-font (font-spec :family "Overpass" :size 18)
      doom-unicode-font (font-spec :family "JuliaMono")
      doom-serif-font (font-spec :family "IBM Plex Mono" :weight 'light))

(defvar required-fonts '("JetBrainsMono.*" "Overpass" "JuliaMono" "IBM Plex Mono" "Merriweather" "Alegreya"))

(defvar available-fonts
  (delete-dups (or (font-family-list)
                   (split-string (shell-command-to-string "fc-list : family")
                                 "[,\n]"))))

(defvar missing-fonts
  (delq nil (mapcar
             (lambda (font)
               (unless (delq nil (mapcar (lambda (f)
                                           (string-match-p (format "^%s$" font) f))
                                         available-fonts))
                 font))
             required-fonts)))

(if missing-fonts
    (pp-to-string
     `(unless noninteractive
        (add-hook! 'doom-init-ui-hook
          (run-at-time nil nil
                       (lambda ()
                         (message "%s missing the following fonts: %s"
                                  (propertize "Warning!" 'face '(bold warning))
                                  (mapconcat (lambda (font)
                                               (propertize font 'face 'font-lock-variable-name-face))
                                             ',missing-fonts
                                             ", "))
                         (sleep-for 0.5))))))
  ";; No missing fonts detected")
;; Font:1 ends here

;; [[file:config.org::*info-colors][info-colors:1]]
(use-package! info-colors
  :commands (info-colors-fontify-node))

(add-hook 'Info-selection-hook 'info-colors-fontify-node)

(add-hook 'Info-mode-hook #'mixed-pitch-mode)
;; info-colors:1 ends here

;; [[file:config.org::*avy][avy:1]]
(use-package! avy
  :bind ("M-s" . avy-goto-char))
;; avy:1 ends here

;; [[file:config.org::*paredit][paredit:1]]
(use-package! paredit
  :config
  (add-hook 'emacs-lisp-mode-hook 'paredit-mode)
  ;; enable in the *scratch* buffer
  (add-hook 'lisp-interaction-mode-hook 'paredit-mode)
  (add-hook 'lisp-mode-hook 'paredit-mode)
  (add-hook 'eval-expression-minibuffer-setup-hook 'paredit-mode)
  (add-hook 'clojure-mode-hook 'paredit-mode)
  (add-hook 'clojurescript-mode-hook 'paredit-mode)
  (add-hook 'clojurec-mode-hook 'paredit-mode)
  (add-hook 'cider-repl-mode-hook 'paredit-mode))
;; paredit:1 ends here

;; [[file:config.org::*magit][magit:1]]
(defun ediff-copy-both-to-C ()
  (interactive)
  (ediff-copy-diff ediff-current-difference nil 'C nil
              (concat
           (ediff-get-region-contents ediff-current-difference 'A ediff-control-buffer)
           (ediff-get-region-contents ediff-current-difference 'B ediff-control-buffer))))
(defun add-d-to-ediff-mode-map () (define-key ediff-mode-map "d" 'ediff-copy-both-to-C))
(add-hook 'ediff-keymap-setup-hook 'add-d-to-ediff-mode-map)
;; magit:1 ends here

;; [[file:config.org::*eshell][eshell:1]]
(setq-hook! 'eshell-mode-hook esh-autosuggest-mode t)
(setq-hook! 'eshell-mode-hook fish-completion-mode t)
;; eshell:1 ends here

;; [[file:config.org::*comment][comment:1]]
(use-package! evil-nerd-commenter
  :bind ("M-/" . evilnc-comment-or-uncomment-lines))
;; comment:1 ends here

;; [[file:config.org::*treemacs][treemacs:1]]
(setq doom-themes-treemacs-theme "doom-colors")
;; treemacs:1 ends here

;; [[file:config.org::*LSP][LSP:1]]
(after! lsp-mode
  (add-to-list 'lsp-file-watch-ignored-directories "[/\\\\]\\.shadow-cljs\\'"))
;; LSP:1 ends here
