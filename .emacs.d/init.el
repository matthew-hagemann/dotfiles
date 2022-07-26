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
(global-set-key (kbd "C-h") 'evil-window-left)
(global-set-key (kbd "C-l") 'evil-window-right)
(global-set-key (kbd "C-j") 'evil-window-down)
(global-set-key (kbd "C-k") 'evil-window-up)
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
  (setq which-key-idle-delay 0.8
	which-key-add-column-padding 1
        which-key-min-display-lines 3
  ))

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
       "fu"   '(sudo-edit-find-file :which-key "Sudo find file")
       "fy"   '(dt/show-and-copy-buffer-path :which-key "Yank file path")
       "fC"   '(copy-file :which-key "Copy file")
       "fD"   '(delete-file :which-key "Delete file")
       "fR"   '(rename-file :which-key "Rename file")
       "fS"   '(write-file :which-key "Save file as...")
       "fU"   '(sudo-edit :which-key "Sudo edit file")
       "s"    '(:ignore t :which-key "search") 
       "sr"   '(counsel-rg :which-key "ripgrep") ;; t stands for text, cause thats what we are looking though.
       "ss"   '(swiper :which-key "Swiper")) ;; NO SWIPING
;; General keybindings, all Doom inspired.
(leader-key-def
       "SPC"   '(counsel-M-x :which-key "M-x")
       "c"     '(:ignore t :which-key "code")
       "c c"   '(compile :which-key "Compile")
       "c C"   '(recompile :which-key "Recompile")
       "h r r" '((lambda () (interactive) (load-file "~/.emacs.d/init.el")) :which-key "Reload emacs config")
       "t"     '(:igore t :which-key "toggles")
       "t t"   '(toggle-truncate-lines :which-key "Toggle truncate lines"))

;; Splits and windows
(winner-mode 1)
(leader-key-def
       "w"     '(:ignore t :which-key "windows")
       ;; Window splits
       "w c"   '(evil-window-delete :which-key "Close window")
       "w n"   '(evil-window-new :which-key "New window")
       "w s"   '(evil-window-split :which-key "Horizontal split window")
       "w v"   '(evil-window-vsplit :which-key "Vertical split window")
       ;; Window motions
       "w h"   '(evil-window-left :which-key "Window left")
       "w j"   '(evil-window-down :which-key "Window down")
       "w k"   '(evil-window-up :which-key "Window up")
       "w l"   '(evil-window-right :which-key "Window right")
       "w w"   '(evil-window-next :which-key "Goto next window")
       ;; winner mode
       "w <left>"  '(winner-undo :which-key "Winner undo")
       "w <right>" '(winner-redo :which-key "Winner redo"))

;; Registers
(leader-key-def
       "r"     '(:ignore t :which-key "registers")
       "r c"   '(copy-to-register :which-key "Copy to register")
       "r f"   '(frameset-to-register :which-key "Frameset to register")
       "r i"   '(insert-register :which-key "Insert register")
       "r j"   '(jump-to-register :which-key "Jump to register")
       "r l"   '(list-registers :which-key "List registers")
       "r n"   '(number-to-register :which-key "Number to register")
       "r r"   '(counsel-register :which-key "Choose a register")
       "r v"   '(view-register :which-key "View a register")
       "r w"   '(window-configuration-to-register :which-key "Window configuration to register")
       "r +"   '(increment-register :which-key "Increment register")
       "r SPC" '(point-to-register :which-key "Point to register"))

;;;;
;; Ivy setup
;;
;; Ivy is a generic completion mechanism for emaics. There are a couple alternatives, the big one being
;; Helm, but lets start here and branch out when we are feeling constrained.
;;;;

(use-package ivy
  :diminish
  :bind (("C-s" . swiper)
         :map ivy-minibuffer-map
         ("TAB" . ivy-alt-done)
         ("C-f" . ivy-alt-done)
         ("C-l" . ivy-alt-done)
         ("C-j" . ivy-next-line)
         ("C-k" . ivy-previous-line)
	 ("C-h" . ivy-backward-delete-char)
         :map ivy-switch-buffer-map
         ("C-k" . ivy-previous-line)
         ("C-l" . ivy-done)
         ("C-d" . ivy-switch-buffer-kill)
         :map ivy-reverse-i-search-map
         ("C-k" . ivy-previous-line)
         ("C-d" . ivy-reverse-i-search-kill))
  :init
  (ivy-mode 1)
  :config
  (setq ivy-use-virtual-buffers t)
  (setq ivy-wrap t)
  (setq ivy-count-format "(%d/%d) ")
  (setq enable-recursive-minibuffers t)

  ;; Use different regex strategies per completion command
  (push '(completion-at-point . ivy--regex-fuzzy) ivy-re-builders-alist) ;; This doesn't seem to work...
  (push '(swiper . ivy--regex-ignore-order) ivy-re-builders-alist)
  (push '(counsel-M-x . ivy--regex-ignore-order) ivy-re-builders-alist)

  ;; Set minibuffer height for different commands
  (setf (alist-get 'counsel-projectile-ag ivy-height-alist) 15)
  (setf (alist-get 'counsel-projectile-rg ivy-height-alist) 15)
  (setf (alist-get 'swiper ivy-height-alist) 15)
  (setf (alist-get 'counsel-switch-buffer ivy-height-alist) 7))

(use-package ivy-hydra
  :defer t
  :after hydra)

(use-package ivy-rich
  :init
  (ivy-rich-mode 1)
  :after counsel
  :config
  (setq ivy-format-function #'ivy-format-function-line)
  (setq ivy-rich-display-transformers-list
        (plist-put ivy-rich-display-transformers-list
                   'ivy-switch-buffer
                   '(:columns
                     ((ivy-rich-candidate (:width 40))
                      (ivy-rich-switch-buffer-indicators (:width 4 :face error :align right)); return the buffer indicators
                      (ivy-rich-switch-buffer-major-mode (:width 12 :face warning))          ; return the major mode info
                      (ivy-rich-switch-buffer-project (:width 15 :face success))             ; return project name using `projectile'
                      (ivy-rich-switch-buffer-path (:width (lambda (x) (ivy-rich-switch-buffer-shorten-path x (ivy-rich-minibuffer-width 0.3))))))  ; return file path relative to project root or `default-directory' if project is nil
                     :predicate
                     (lambda (cand)
                       (if-let ((buffer (get-buffer cand)))
                           ;; Don't mess with EXWM buffers
                           (with-current-buffer buffer
                             (not (derived-mode-p 'exwm-mode)))))))))

(use-package counsel
  :demand t
  :bind (("M-x" . counsel-M-x)
         ("C-x b" . counsel-ibuffer)
         ("C-x C-f" . counsel-find-file)
         ;; ("C-M-j" . counsel-switch-buffer)
         ("C-M-l" . counsel-imenu)
         :map minibuffer-local-map
         ("C-r" . 'counsel-minibuffer-history))
  :custom
  (counsel-linux-app-format-function #'counsel-linux-app-format-function-name-only)
  :config
  (setq ivy-initial-inputs-alist nil)) ;; Don't start searches with ^

(use-package flx  ;; Improves sorting for fuzzy-matched results
  :after ivy
  :defer t
  :init
  (setq ivy-flx-limit 10000))

(use-package wgrep)

(use-package ivy-posframe
  :disabled
  :custom
  (ivy-posframe-width      115)
  (ivy-posframe-min-width  115)
  (ivy-posframe-height     10)
  (ivy-posframe-min-height 10)
  :config
  (setq ivy-posframe-display-functions-alist '((t . ivy-posframe-display-at-frame-center)))
  (setq ivy-posframe-parameters '((parent-frame . nil)
                                  (left-fringe . 8)
                                  (right-fringe . 8)))
  (ivy-posframe-mode 1))

(use-package prescient
  :after counsel
  :config
  (prescient-persist-mode 1))

(use-package ivy-prescient
  :after prescient
  :config
  (ivy-prescient-mode 1))

(leader-key-def
  "r"   '(ivy-resume :which-key "ivy resume")
  "f"   '(:ignore t :which-key "files")
  "ff"  '(counsel-find-file :which-key "open file")
  "C-f" 'counsel-find-file
  "fr"  '(counsel-recentf :which-key "recent files")
  "fR"  '(revert-buffer :which-key "revert file")
  "fj"  '(counsel-file-jump :which-key "jump to file"))

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

;; Rust you need the rust toolchain and rust-analyzer
(use-package rustic
  :ensure t
  :bind (("C-c 6" . rustic-format-buffer))
  :config
  (require 'lsp-rust))

;;Python
;; Requires the following:
;; pip3 install jedi autopep8 flake8 ipython importmagic yapf
(use-package elpy
  :ensure t
  :init
  (elpy-enable))

;; Gosh Python can complain about formatting...
(use-package py-autopep8)
(use-package blacken)

(when (require 'flycheck nil t)
  (setq elpy-modules (delq 'elpy-module-flymake elpy-modules))
  (add-hook 'elpy-mode-hook 'flycheck-mode))

;; Autoformat on save
(require 'py-autopep8)
(add-hook 'elpy-mode-hook 'py-autopep8-enable-on-save)

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

;; Eshell
(leader-key-def
      "e h"   '(counsel-esh-history :which-key "Eshell history")
      "e s"   '(eshell :which-key "Eshell"))

;; ’eshell-syntax-highlighting’ – adds fish/zsh-like syntax highlighting.
;; ’eshell-rc-script’ – your profile for eshell; like a bashrc for eshell.
;; ’eshell-aliases-file’ – sets an aliases file for the eshell.

(use-package eshell-syntax-highlighting
  :after esh-mode
  :config
  (eshell-syntax-highlighting-global-mode +1))

(setq eshell-rc-script (concat user-emacs-directory "eshell/profile")
      eshell-aliases-file (concat user-emacs-directory "eshell/aliases")
      eshell-history-size 5000
      eshell-buffer-maximum-lines 5000
      eshell-hist-ignoredups t
      eshell-scroll-to-bottom-on-input t
      eshell-destroy-buffer-when-process-dies t
      eshell-visual-commands'("bash" "fish" "htop" "ssh" "top" "zsh"))

;; Vterm, cause you can never have too many terminals.
(use-package vterm)
(setq shell-file-name "/bin/zsh"
      vterm-max-scrollback 5000
      vterm-timer-delay 0.001)

(leader-key-def
      "t v"   '(vterm :which-key "Vterm"))

;; Treemacs
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
   '(ivy-prescient prescient wgrep flx ivy-hydra vterm blacken py-autopep8 elpy company lsp-mode treemacs-evil treemacs neotree which-key use-package evil-collection doom-themes doom-modeline)))
(custom-set-faces
 ;; custom-set-faces was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
 )
