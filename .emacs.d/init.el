;;;;
;; Package
;;;;

;; Setup package and add melph, always refreshing on start.
(require 'package)

(setq package-archives '(("melpa" . "https://melpa.org/packages/")
                         ("melpa-stable" . "https://stable.melpa.org/packages/")
                         ("org" . "https://orgmode.org/elpa/")
                         ("elpa" . "https://elpa.gnu.org/packages/")))
;;(package-refresh-contents)
(package-initialize)

;; Install use-package.
(unless (package-installed-p 'use-package)
  (package-install 'use-package))
(require 'use-package)
(setq use-package-always-ensure t)
(setq debug-on-error t)
(setq use-package-verbose t)

;; Silence compiler warnings as they can be pretty disruptive
(if (boundp 'comp-deferred-compilation)
    (setq comp-deferred-compilation nil)
    (setq native-comp-deferred-compilation nil))
;; In noninteractive sessions, prioritize non-byte-compiled source files to
;; prevent the use of stale byte-code. Otherwise, it saves us a little IO time
;; to skip the mtime checks on every *.elc file.
(setq load-prefer-newer noninteractive)

;;;;
;; Keybindings
;;;;

;; Global escape
(global-set-key (kbd "<escape>") 'keyboard-escape-quit)
;; Install evil, attach evil-undo to emacs's new undo-redo system thingy.
(use-package evil
  :init      ;; tweak evil's configuration before loading it
  (setq evil-want-integration t) ;; This is optional since it's already set to t by default.
  (setq evil-want-keybinding nil)
  (setq evil-vsplit-window-right t)
  (setq evil-split-window-below t)
  (setq evil-want-minibuffer t)
  :config
  (evil-mode 1))
(use-package evil-collection
  :after evil
  :custom (evil-collection-setup-minibuffer t)
  :config
  (setq evil-collection-mode-list '(dashboard dired ibuffer))
  (evil-collection-init))

;; Which Key, so I don't need to remember anything!
(use-package which-key
  :init (which-key-mode)
  :diminish which-key-mode
  :config
  (setq which-key-idle-delay 0.3))

;; General Keybindings, to make setting keybindings easier
(use-package general
  :config
  (general-evil-setup t)

  (general-create-definer leader-key-def
    :keymaps '(normal insert visual emacs)
    :prefix "SPC"
    :global-prefix "C-SPC") 

  (general-create-definer ctrl-c-keys
    :prefix "C-c"))

;; For some reason, emacs decided "C-u" was its hill to die on. 
(define-key evil-normal-state-map (kbd "C-u") 'evil-scroll-up)
(define-key evil-visual-state-map (kbd "C-u") 'evil-scroll-up)
(define-key evil-insert-state-map (kbd "C-u")
  (lambda ()
    (interactive)
    (evil-delete (point-at-bol) (point))))

;; zoom in/out like we do everywhere else.
(global-set-key (kbd "C-=") 'text-scale-increase)
(global-set-key (kbd "C--") 'text-scale-decrease)
(global-set-key (kbd "<C-wheel-up>") 'text-scale-increase)
(global-set-key (kbd "<C-wheel-down>") 'text-scale-decrease)

;; Really liked how Doom did things, so going to borrow from there for now :)
;; Bindings for buffers and bookmarks
(leader-key-def
       "b"     '(:ignore t :which-key "buffers")
       "bb"   '(ibuffer :which-key "Ibuffer")
       "bc"   '(clone-indirect-buffer-other-window :which-key "Clone indirect buffer other window")
       "bk"   '(kill-current-buffer :which-key "Kill current buffer")
       "bn"   '(next-buffer :which-key "Next buffer")
       "bp"   '(previous-buffer :which-key "Previous buffer")
       "bB"   '(ibuffer-list-buffers :which-key "Ibuffer list buffers")
       "bK"   '(kill-buffer :which-key "Kill buffer"))

;; Evaluating Elisp expresions
;; Some of the little Emacs I do know, so lets not have to use the Emacs bindings for it ;)
(leader-key-def
       "e"    '(:ignore t :which-key "eval")
       "eb"   '(eval-buffer :which-key "Eval elisp in buffer")
       "ed"   '(eval-defun :which-key "Eval defun")
       "ee"   '(eval-expression :which-key "Eval elisp expression")
       "el"   '(eval-last-sexp :which-key "Eval last sexression")
       "er"   '(eval-region :which-key "Eval region"))

;; Dired is Emacs default file managers, lets embrace it!
(use-package all-the-icons-dired)
(use-package dired-open)
(use-package peep-dired)

(leader-key-def
               "d"   '(:ignore t :which-key "dired")
               "dd" '(dired :which-key "Open dired")
               "dj" '(dired-jump :which-key "Dired jump to current")
               "dp" '(peep-dired :which-key "Peep-dired"))

(with-eval-after-load 'dired
  ;;(define-key dired-mode-map (kbd "M-p") 'peep-dired)
  (evil-define-key 'normal dired-mode-map (kbd "h") 'dired-up-directory)
  (evil-define-key 'normal dired-mode-map (kbd "l") 'dired-open-file) ; use dired-find-file instead if not using dired-open package
  (evil-define-key 'normal peep-dired-mode-map (kbd "j") 'peep-dired-next-file)
  (evil-define-key 'normal peep-dired-mode-map (kbd "k") 'peep-dired-prev-file))

(add-hook 'peep-dired-hook 'evil-normalize-keymaps)
;; Get file icons in dired
(add-hook 'dired-mode-hook 'all-the-icons-dired-mode)
;; With dired-open plugin, you can launch external programs for certain extensions
;; For example, I set all .png files to open in 'sxiv' and all .mp4 files to open in 'mpv'
(setq dired-open-extensions '(("gif" . "sxiv")
                              ("jpg" . "sxiv")
                              ("png" . "sxiv")
                              ("mkv" . "mpv")
                              ("mp4" . "mpv")))

;; File-related keybindings. Also very Doom inspired. 
(leader-key-def
       "."     '(find-file :which-key "Find file")
       "f"     '(:ignore t :which-key "files")
       "ff"   '(find-file :which-key "Find file")
       "fr"   '(counsel-recentf :which-key "Recent files")
       "fs"   '(save-buffer :which-key "Save file")
       "fu"   '(sudo-edit-find-file :which-key "Sudo find file")
       "fy"   '(dt/show-and-copy-buffer-path :which-key "Yank file path")
       "fC"   '(copy-file :which-key "Copy file")
       "fD"   '(delete-file :which-key "Delete file")
       "fR"   '(rename-file :which-key "Rename file")
       "fS"   '(write-file :which-key "Save file as...")
       "fU"   '(sudo-edit :which-key "Sudo edit file"))

;; General keybindings, all Doom inspired.
(leader-key-def
       "SPC"   '(counsel-M-x :which-key "M-x")
       "c"     '(:ignore t :which-key "code")
       "c c"   '(compile :which-key "Compile")
       "c C"   '(recompile :which-key "Recompile")
       "h r r" '((lambda () (interactive) (load-file "~/.emacs.d/init.el")) :which-key "Reload emacs config")
       "t t"   '(toggle-truncate-lines :which-key "Toggle truncate lines"))
;;;;
;; Ivy setup
;;
;; Ivy is a generic completion mechanism for emaics. There are a couple alternatives, the big one being
;; Helm, but lets start here and branch out when we are feeling constrained.
;;;;

(use-package counsel
  :after ivy
  :config (counsel-mode))
(use-package ivy
  :defer 0.1
  :diminish
  :bind
  (("C-c C-r" . ivy-resume)
   ("C-x B" . ivy-switch-buffer-other-window))
  :custom
  (setq ivy-count-format "(%d/%d) ")
  (setq ivy-use-virtual-buffers t)
  (setq enable-recursive-minibuffers t)
  :config
  (ivy-mode))
(use-package ivy-rich
  :after ivy
  :custom
  (ivy-virtual-abbreviate 'full
   ivy-rich-switch-buffer-align-virtual-buffer t
   ivy-rich-path-style 'abbrev)
  :config
  (ivy-set-display-transformer 'ivy-switch-buffer
                               'ivy-rich-switch-buffer-transformer)
  (ivy-rich-mode 1)) ;; this gets us descriptions in M-x.
(use-package swiper
  :after ivy
  :bind (("C-s" . swiper)
         ("C-r" . swiper)))

;; Gets rid of that ‘^’ 
(setq ivy-initial-inputs-alist nil)

;; M-x remembers your history and displays last command first.
(use-package smex)
(smex-initialize)

;; Ivy-posframe is an ivy extension, which lets ivy use posframe to show its candidate menu.  Some of the settings below involve:

;; ivy-posframe-display-functions-alist – sets the display position for specific programs
;; ivy-posframe-height-alist – sets the height of the list displayed for specific programs

;; Available functions (positions) for ‘ivy-posframe-display-functions-alist’

;; ivy-posframe-display-at-frame-center
;; ivy-posframe-display-at-window-center
;; ivy-posframe-display-at-frame-bottom-left
;; ivy-posframe-display-at-window-bottom-left
;; ivy-posframe-display-at-frame-bottom-window-center
;; ivy-posframe-display-at-point
;; ivy-posframe-display-at-frame-top-center

;; NOTE: If the setting for ‘ivy-posframe-display’ is set to ‘nil’ (false), anything that is set to ‘ivy-display-function-fallback’ will just default to their normal position in Doom Emacs (usually a bottom split).  However, if this is set to ‘t’ (true), then the fallback position will be centered in the window.

(use-package ivy-posframe
  :init
  (setq ivy-posframe-display-functions-alist
    '((swiper                     . ivy-posframe-display-at-point)
      (complete-symbol            . ivy-posframe-display-at-point)
      (counsel-M-x                . ivy-display-function-fallback)
      (counsel-esh-history        . ivy-posframe-display-at-window-center)
      (counsel-describe-function  . ivy-display-function-fallback)
      (counsel-describe-variable  . ivy-display-function-fallback)
      (counsel-find-file          . ivy-display-function-fallback)
      (counsel-recentf            . ivy-display-function-fallback)
      (counsel-register           . ivy-posframe-display-at-frame-bottom-window-center)
      (dmenu                      . ivy-posframe-display-at-frame-top-center)
      (nil                        . ivy-posframe-display))
    ivy-posframe-height-alist
    '((swiper . 20)
      (dmenu . 20)
      (t . 10)))
  :config
  (ivy-posframe-mode 1)) ; 1 enables posframe-mode, 0 disables it.

;;;;
;; Git client through Magit
;;;;
(use-package magit
  :bind ("C-M-;" . magit-status)
  :commands (magit-status magit-get-current-branch)
  :custom
  (magit-display-buffer-function #'magit-display-buffer-same-window-except-diff-v1))

(leader-key-def
  "g"   '(:ignore t :which-key "git")
  "gs"  'magit-status
  "gd"  'magit-diff-unstaged
  "gc"  'magit-branch-or-checkout
  "gl"   '(:ignore t :which-key "log")
  "glc" 'magit-log-current
  "glf" 'magit-log-buffer-file
  "gb"  'magit-branch
  "gP"  'magit-push-current
  "gp"  'magit-pull-branch
  "gf"  'magit-fetch
  "gF"  'magit-fetch-all
  "gr"  'magit-rebase)

;;;;
;; Programming languages
;;;;

;; lsp-mode 
(use-package lsp-mode
  :ensure t)

(leader-key-def
  "l"   '(:ignore t :which-key "lsp")
  "ld"  '(lsp-describe-thing-at-point :which-key "Describe at point")
  "la"  '(lsp-execute-code-action :which-key "Code action")
  "ll"  '(lsp-command-map :which-key "lsp command map"))

;; Company for completion.
;; Elisp init from company, cause I can.
(use-package company
  :ensure t
  :hook ((emacs-lisp-mode . (lambda ()
			      (setq-local company-backends '(company-elisp))))
         (emacs-lisp-mode . company-mode))
  :config
  (company-keymap--unbind-quick-access company-active-map)
  (company-tng-configure-default)
  (setq company-idle-delay 0.1
	company-minimum-prefix-length 1))

;; Flycheck
(use-package flycheck
  :ensure t)

;; Go
;; Make sure you have go installed along with gofmt, goimports and godoc
(use-package go-mode
  :ensure t
  :hook ((go-mode . lsp-deferred)
	 (go-mode . company-mode))
  :bind (:map go-mode-map
	      ("C-c 6" . gofmt))
  :config
  (require 'lsp-go)
  (setq lsp-go-analyses
	'((fieldalignment . t)
	  (nilness        . t)
	  (unusedwrite    . t)
	  (unusedparams   . t)))
  ;; GOPATH/bin
  (add-to-list 'exec-path "~/Go/bin")
  (setq gofmt-command "goimports"))

;; Rust
(use-package rustic
  :ensure t
  :bind (("C-c 6" . rustic-format-buffer))
  :config
  (require 'lsp-rust))

;;Python
(use-package elpy
  :ensure t
  :init
  (elpy-enable))

;;;;
;; GUI
;;;;

;; Icons
(use-package all-the-icons)

;; Emojis!
(use-package emojify
  :hook (after-init . global-emojify-mode))

;; Theme
(use-package doom-themes)
(setq doom-themes-enable-bold t    ; if nil, bold is universally disabled
      doom-themes-enable-italic t) ; if nil, italics is universally disabled
(load-theme 'doom-one t)

;; Fonts
(set-face-attribute 'default nil
  :font "FiraCode Nerd Font"
  :height 150
  :weight 'medium)
(set-face-attribute 'variable-pitch nil
  :font "FiraCode Nerd Font"
  :height 150
  :weight 'medium)
(set-face-attribute 'fixed-pitch nil
  :font "FiraCode Nerd Font"
  :height 150
  :weight 'medium)
;; Makes commented text and keywords italics.
;; This is working in emacsclient but not emacs.
;; Your font must have an italic face available.
(set-face-attribute 'font-lock-comment-face nil
  :slant 'italic)
(set-face-attribute 'font-lock-keyword-face nil
  :slant 'italic)

;; Uncomment the following line if line spacing needs adjusting.
;;(setq-default line-spacing 0.12)

;; changes certain keywords to symbols, such as lamda!
(setq global-prettify-symbols-mode t)

;; GUI tweaks
;; Disable menubar, toolbar and scrollbar. We don't want em >.>
(menu-bar-mode -1)
(tool-bar-mode -1)
(scroll-bar-mode -1)

;; Linenumbers and truncated lines
(global-display-line-numbers-mode 1)
(global-visual-line-mode t)

;;Treemacs
(use-package treemacs
  :ensure t)
(treemacs-follow-mode t)
(treemacs-filewatch-mode t)
(treemacs-fringe-indicator-mode 'always)

(use-package treemacs-evil
  :after (treemacs evil)
  :ensure t)

(use-package projectile
  :config
  (projectile-global-mode 1))

(use-package page-break-lines)

;; Dashboard
(use-package dashboard
  :init      ;; tweak dashboard config before loading it
  (setq dashboard-set-heading-icons t)
  (setq dashboard-set-file-icons t)
  (setq dashboard-banner-logo-title "This is what happens when noone gives me CLion!")
  ;;(setq dashboard-startup-banner 'logo) ;; use standard emacs logo as banner
  (setq dashboard-startup-banner "~/.emacs.d/ferris.png")  ;; use custom image as banner
  (setq dashboard-center-content nil) ;; set to 't' for centered content
  (setq dashboard-items '((recents . 5)
                          (bookmarks . 3)
                          (projects . 3)))
  :config
  (dashboard-setup-startup-hook)
  (dashboard-modify-heading-icons '((recents . "file-text")
			      (bookmarks . "book"))))

;; Doom's modeline
(use-package doom-modeline)
(doom-modeline-mode 1)
(custom-set-variables
 ;; custom-set-variables was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
 '(package-selected-packages
   '(elpy company lsp-mode treemacs-evil treemacs neotree which-key use-package evil-collection doom-themes doom-modeline)))
(custom-set-faces
 ;; custom-set-faces was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
 )
