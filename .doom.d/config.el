;;; $DOOMDIR/config.el -*- lexical-binding: t; -*-



;; Place your private configuration here! Remember, you do not need to run 'doom
;; sync' after modifying this file!


;; Some functionality uses this to identify you, e.g. GPG configuration, email
;; clients, file templates and snippets. It is optional.
(setq user-full-name "Matt Hagemann"
      user-mail-address "matt1hagemann@gmail.com")

;; Doom exposes five (optional) variables for controlling fonts in Doom:
;;
;; - `doom-font' -- the primary font to use
;; - `doom-variable-pitch-font' -- a non-monospace font (where applicable)
;; - `doom-big-font' -- used for `doom-big-font-mode'; use this for
;;   presentations or streaming.
;; - `doom-unicode-font' -- for unicode glyphs
;; - `doom-serif-font' -- for the `fixed-pitch-serif' face
;;
;; See 'C-h v doom-font' for documentation and more examples of what they
;; accept. For example:
;;
;;(setq doom-font (font-spec :family "Fira Code" :size 12 :weight 'semi-light)
;;      doom-variable-pitch-font (font-spec :family "Fira Sans" :size 13))
;;
;; If you or Emacs can't find your font, use 'M-x describe-font' to look them
;; up, `M-x eval-region' to execute elisp code, and 'M-x doom/reload-font' to
;; refresh your font settings. If Emacs still can't find your font, it likely
;; wasn't installed correctly. Font issues are rarely Doom issues!

;; There are two ways to load a theme. Both assume the theme is installed and
;; available. You can either set `doom-theme' or manually load a theme with the
;; `load-theme' function. This is the default:
(setq doom-theme 'doom-dracula)

;; This determines the style of line numbers in effect. If set to `nil', line
;; numbers are disabled. For relative line numbers, set this to `relative'.
(setq display-line-numbers-type 'relative)

;; If you use `org' and don't want your org files in the default location below,
;; change `org-directory'. It must be set before org loads!
(setq org-directory "~/org/")

;; Font settings
;; 'doom-font' - Default font used all over.
;; 'doom-variable-pitch-font' - Some plugins need this.
;; 'doom-big-font' - Big font mode for presentations. There is a command for it.
;; 'doom-themes-enable-bold' - Don't show '*', just bold.
;; 'doom-themes-enable-italic' - Don't show '/', just italic.
;; 'font-lock-comment-face' - Comments look cool when coding.
;;  'font-lock-keyword-face' - Keywords look cool while coding.

;; (setq doom-font (font-spec :family "MesloLGLDZ Nerd Font Mono" :size 18)
;;       doom-variable-pitch-font (font-spec :family "MesloLGLDZ Nerd Font Mono" :size 18)
;;       doom-big-font (font-spec :family "MesloLGLDZ Nerd Font Mono" :size 26))
(setq doom-font (font-spec :family "Ubuntu Nerd Font" :size 18)
      doom-variable-pitch-font (font-spec :family "Ubuntu Nerd Font" :size 18)
      doom-big-font (font-spec :family "Ubuntu Nerd Font" :size 26))
(after! doom-themes
  (setq doom-themes-enable-bold t
        doom-themes-enable-italic t))
(custom-set-faces!
  '(font-lock-comment-face :slant italic)
  '(font-lock-keyword-face :slant italic))

;; Python
(use-package! python-black
  :demand t
  :after python)
(add-hook! 'python-mode-hook #'python-black-on-save-mode)

(map! :leader
      (:prefix ("v" . "venv")
       :desc "Create venv" "c" #'pyvenv-create
       :desc "Activate venv" "a" (lambda () (interactive) (call-interactively 'pyvenv-activate))
       :desc "Deactivate venv" "d" #'pyvenv-deactivate))


;; Rust
(after! rustic
  (setq lsp-rust-server 'rust-analyzer))

;; Debugger setup
(setq dap-auto-configure-mode t)
(after! dap-mode
  (require 'dap-cpptools))

;; Registers
(map! :leader
      (:prefix ("r" . "registers")
       :desc "Copy to register" "c" #'copy-to-register
       :desc "Frameset to register" "f" #'frameset-to-register
       :desc "Insert contents of register" "i" #'insert-register
       :desc "Jump to register" "j" #'jump-to-register
       :desc "List registers" "l" #'list-registers
       :desc "Number to register" "n" #'number-to-register
       :desc "Interactively choose a register" "r" #'counsel-register
       :desc "View a register" "v" #'view-register
       :desc "Window configuration to register" "w" #'window-configuration-to-register
       :desc "Increment register" "+" #'increment-register
       :desc "Point to register" "SPC" #'point-to-register))

;; Terminal setup
(setq shell-file-name "/bin/zsh"
      vterm-max-scrollback 5000)
(setq eshell-rc-script "~/.config/doom/eshell/profile"
      eshell-aliases-file "~/.config/doom/eshell/aliases"
      eshell-history-size 5000
      eshell-buffer-maximum-lines 5000
      eshell-hist-ignoredups t
      eshell-scroll-to-bottom-on-input t
      eshell-destroy-buffer-when-process-dies t
      eshell-visual-commands'("bash" "fish" "htop" "ssh" "top" "zsh"))


;; lsp-treemacs
(use-package! lsp-treemacs)


;; General keybindings
(map! :leader
      :desc "Eshell" "e s" #'eshell
      :desc "Eshell popup toggle" "e t" #'+eshell/toggle
      :desc "Counsel eshell history" "e h" #'counsel-esh-history
      :desc "Vterm popup toggle" "t v" #'+vterm/toggle
      :desc "Toggle treemacs" "t e" #'+treemacs/toggle
      :desc "Toggle truncate lines" "t t" #'toggle-truncate-lines
      :desc "Comment line" "c /" #'comment-or-uncomment-region
      :desc "Other frame" "w f" #'other-frame
      :desc "Spawn Frame" "w O" #'make-frame-command
      :desc "Treemacs error list" "c z" #'lsp-treemacs-errors-list)

;; Copilot
;; accept completion from copilot and fallback to company
(use-package! copilot
  :hook (prog-mode . copilot-mode)
  :bind (:map copilot-completion-map
              ("<tab>" . 'copilot-accept-completion)
              ("TAB" . 'copilot-accept-completion)
              ("C-TAB" . 'copilot-accept-completion-by-word)
              ("C-<tab>" . 'copilot-accept-completion-by-word)))

;; GOPATH/bin
(add-to-list 'exec-path "~/go/bin")

;; protobuf
;;(use-package! protobuf-mode)
;;(protobuf-mode 1)

(setq doom-fallback-buffer-name "*dashboard*")
;; Compiler:
(use-package compile
  :custom
  (compilation-scroll-output t)) ;; autoscroll the output

(setq doom-themes-treemacs-theme "doom-colors")


;;; Tree Sitter

(use-package! tree-sitter
  :hook (prog-mode . turn-on-tree-sitter-mode)
  :hook (tree-sitter-after-on . tree-sitter-hl-mode)
  :config
  (require 'tree-sitter-langs)
  ;; This makes every node a link to a section of code
  (setq tree-sitter-debug-jump-buttons t
        ;; and this highlights the entire sub tree in your code
        tree-sitter-debug-highlight-jump-region t))

;; Whenever you reconfigure a package, make sure to wrap your config in an
;; `after!' block, otherwise Doom's defaults may override your settings. E.g.
;;
;;   (after! PACKAGE
;;     (setq x y))
;;
;; The exceptions to this rule:
;;
;;   - Setting file/directory variables (like `org-directory')
;;   - Setting variables which explicitly tell you to set them before their
;;     package is loaded (see 'C-h v VARIABLE' to look up their documentation).
;;   - Setting doom variables (which start with 'doom-' or '+').
;;
;; Here are some additional functions/macros that will help you configure Doom.
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
;; Alternatively, use `C-h o' to look up a symbol (functions, variables, faces,
;; etc).
;;
;; You can also try 'gd' (or 'C-c c d') to jump to their definition and see how
;; they are implemented.
