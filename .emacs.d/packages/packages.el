;; packages.el --- my selection of packages         -*- lexical-binding: t; -*-

;; Copyright (C) 2021  Odd-Harald Myhren

;; Author: Odd-Harald Myhren <knarkzel@gmail.com>

(setq custom-packages '(aggressive-indent
                        ace-link
                        company
                        dired-ranger
                        evil evil-collection evil-commentary evil-leader evil-lispy
                        elfeed
                        eglot
                        fancy-battery
                        gcmh
                        helpful
                        emms soundklaus
                        racket-mode geiser geiser-racket macrostep
                        leaf-convert
                        lispyville
			            pulseaudio-control
                        dmenu
                        ivy counsel
                        gpastel
                        sudo-edit
                        exwm
                        magit
                        org-ref org-roam
                        disk-usage
                        rainbow-delimiters rainbow-mode
                        rustic
                        tree-sitter tree-sitter-langs
                        yasnippet yasnippet-snippets
                        vterm vterm-toggle
                        which-key
                        zig-mode
                        zoom))

(let ((inhibit-message nil))
  (dolist (package custom-packages)
    (unless (package-installed-p package)
      (package-install package))))

(leaf evil
  :init
  (setq evil-want-C-u-scroll t
        evil-want-integration t
        evil-cross-lines t
        evil-disable-insert-state-bindings t
        evil-want-keybinding nil
        evil-lookup-func 'eldoc
        evil-undo-system 'undo-redo)

  (leaf evil-collection
    :after evil
    :config
    (evil-collection-init))

  (evil-commentary-mode t)

  (leaf evil-leader
    :config
    (global-evil-leader-mode)
    (evil-leader/set-leader "<SPC>")
    (evil-leader/set-key
      "b" 'ivy-switch-buffer
      "d" 'dired-jump
      "g" 'magit
      "e" 'eshell
      "l" 'elfeed
      "o" 'odd/open-config-folder
      "x" 'counsel-M-x
      "k" 'previous-window-any-frame
      "p" project-prefix-map))

  (define-key global-map (kbd "s-x") 'counsel-M-x)
  
  (evil-define-key 'insert global-map (kbd "C-w") 'backward-kill-word)

  (evil-mode t))

(leaf yasnippet
  :require t
  :config
  (add-hook 'prog-mode-hook #'yas-minor-mode)

  (define-key yas-minor-mode-map (kbd "<tab>") nil)
  (define-key yas-minor-mode-map (kbd "TAB") nil)

  (evil-define-key 'insert yas-minor-mode-map (kbd "C-o") 'yas-expand)

  (yas-global-mode t))

(leaf eww
  :init
  (setq shr-max-image-proportion 0.25)
  (evil-define-key 'normal 'eww-mode-map (kbd "g l") 'ace-link-eww)
  :hook (eww-after-render-hook . eww-readable))

(leaf eshell
  :init
  (setq
   eshell-ls-use-colors t
   eshell-cmpl-cycle-completions nil
   eshell-history-size (* 1024 8)
   eshell-hist-ignoredups t
   eshell-banner-message ""
   eshell-destroy-buffer-when-process-dies t

   eshell-visual-commands '("vi" "screen" "tmux" "top"
                            "htop" "less" "more" "lynx"
                            "links" "ncftp" "mutt" "pine"
                            "tin" "trn" "elm" "pacman")
   eshell-visual-subcommands '(("sudo" "pacman") ("git" "diff" "log" "show")))

  (add-hook 'eshell-mode-hook
            (lambda () (interactive)
              (evil-define-key 'insert eshell-mode-map
                (kbd "C-k") 'eshell-previous-matching-input-from-input
                (kbd "C-j") 'eshell-next-matching-input-from-input
                (kbd "C-l") 'odd/eshell-clear)

              (evil-define-key 'normal eshell-mode-map (kbd "C-l") 'odd/eshell-clear)

              (abbrev-mode t)))

  (define-abbrev-table 'eshell-mode-abbrev-table
    '(("si" "sudo pacman -S")
      ("sr" "sudo pacman -R")
      ("sl" "sudo pacman -Ss")
      ("srht" "git remote add sourcehut git@git.sr.ht:~knarkzel/"))))

(leaf ivy 
  :init
  (setq ivy-use-virtual-buffers t
        enable-recursive-minibuffers t
        ivy-fixed-height-minibuffer t
        ivy-extra-directories nil)
  (ivy-mode t))

(leaf counsel 
  :init
  ;; File names beginning with # or ., and ending with # or ~
  (setq counsel-find-file-ignore-regexp
        (concat "\\(?:\\`[#.]\\)"
                "\\|\\(?:\\`.+?[#~]\\'\\)"))
  (counsel-mode t))

(leaf company
  :require t
  :init
  (setq company-idle-delay 0.5
        company-minimum-prefix-length 1)
  
  (add-hook 'company-mode-hook
            (lambda () (interactive)
              (define-key company-active-map (kbd "<down>") (lambda () (interactive) (company-complete-common-or-cycle 1)))
              (define-key company-active-map (kbd "<up>") (lambda () (interactive) (company-complete-common-or-cycle -1)))

              (evil-define-key 'insert company-mode-map
                (kbd "C-n") (lambda () (interactive) (company-complete-common-or-cycle 1))
                (kbd "C-p") (lambda () (interactive) (company-complete-common-or-cycle -1)))))

  (add-hook 'after-init-hook 'global-company-mode))

(leaf eldoc
  :init
  (setq eldoc-echo-area-display-truncation-message nil
        eldoc-echo-area-use-multiline-p nil))

(leaf eglot
  :init
  (evil-define-key 'normal eglot-mode-map (kbd "C-a") 'eglot-code-actions)
  :hook ((rustic-mode-hook js-mode-hook c-mode-hook zig-mode-hook) . eglot-ensure))

(leaf rustic
  :require t
  :init
  (setq rustic-lsp-client 'eglot)
  (add-hook 'rustic-mode-hook 'electric-pair-mode)

  (defhydra hydra-rustic (:color blue)
    "rustic-mode"
    ;; ("a" rustic-cargo-add "cargo-add" :column "Rustic")
    ;; ("b" rustic-cargo-build "cargo-build")
    ;; ("r" rustic-cargo-run "cargo-run")
    ("f" rustic-format-buffer "format" :column "Eglot")
    ("n" eglot-rename "rename")
    ("c" eglot-reconnect "reconnect")
    ("e" flymake-goto-next-error "next-error" :column "Flymake"))
  
  (evil-leader/set-key-for-mode 'rustic-mode "SPC" 'hydra-rustic/body))

(leaf dired
  :init
  (leaf dired-x :require t)

  (put 'dired-find-alternate-file 'disabled nil)

  (setq dired-omit-files "^\\.+"
        dired-recursive-copies 'always
        dired-recursive-deletes 'always
        dired-clean-confirm-killing-deleted-buffers nil
        dired-listing-switches "-AlghX")
  
  (defhydra hydra-dired (:color blue)
    "dired-mode"
    ("p" odd/create-project "new org project" :column "Project"))

  (add-hook 'dired-mode-hook (lambda () (interactive)
                               (dired-hide-details-mode t)
                               (dired-omit-mode t)))

  (evil-leader/set-key-for-mode 'dired-mode "SPC" 'hydra-dired/body)

  (evil-define-key 'normal dired-mode-map
    (kbd "y") (lambda () (interactive) (dired-copy-filename-as-kill 0))
    (kbd "=") 'dired-create-directory
    (kbd "+") 'dired-diff
    (kbd "<return>") 'dired-find-file
    (kbd "J") 'dired-find-file
    (kbd "K") 'dired-up-directory
    (kbd ".") 'dired-omit-mode
    (kbd "c") 'dired-ranger-copy
    (kbd "p") 'dired-ranger-paste
    (kbd "P") 'dired-ranger-move))

(leaf evil-lispy
  :require t
  :init
  (evil-define-key 'insert evil-lispy-mode-map
    (kbd "C-9") 'lispy-wrap-round)

  (add-hook 'evil-lispy-mode-hook
            (lambda () (interactive)
              (evil-define-key 'normal evil-lispy-mode-map
                (kbd "K") 'eldoc
                (kbd "C-9") (lambda () (interactive) (evil-find-char-backward 1 (string-to-char "(")))
                (kbd "C-0") (lambda () (interactive) (evil-find-char 1 (string-to-char ")")))))))

(leaf lispyville
  :init
  (lispyville-set-key-theme '(c-w operators text-objects slurp/barf-cp additional-insert)))

(leaf emacs-lisp
  :init
  (define-key emacs-lisp-mode-map (kbd "C-c C-c") 'eval-defun)
  (odd/add-hooks 'emacs-lisp-mode-hook
                 '(eldoc-mode
                   evil-lispy-mode
                   aggressive-indent-mode
                   lispyville-mode)))

(leaf elfeed
  :require t
  :init
  (setq elfeed-feeds '(;;; ARTICLES
                       ("https://buttondown.email/j2kun/rss"       article)
                       ("https://jduchniewicz.com/posts/index.xml" article)
                       ("https://fasterthanli.me/index.xml"        article)
                       ("https://rust-analyzer.github.io/feed.xml" article)
                       ("https://ambrevar.xyz/atom.xml"            article)
                       ("https://this-week-in-rust.org/rss.xml"    article)
                       ("https://lukesmith.xyz/rss.xml"            article)
                       ("https://smallcultfollowing.com/babysteps/atom.xml" article)))

  (setq-default elfeed-search-title-max-width 100
                elfeed-search-title-min-width 100
                elfeed-search-filter "+unread")
  :config
  (evil-define-key 'normal elfeed-search-mode-map
    (kbd "/") 'elfeed-search-set-filter
    (kbd "g r") 'elfeed-update
    (kbd "L") 'elfeed-search-browse-url
    (kbd "<return>") 'elfeed-visit-or-play-with-mpv
    (kbd "<escape>") (lambda () (interactive)
                       (elfeed-search-clear-filter)
                       (setq elfeed-search-filter "+unread"))))

(leaf org-mode
  :init
  (leaf org-ref
    :config
    (setq org-goto-interface 'outline-path-completion
          org-outline-path-complete-in-steps nil
          org-confirm-babel-evaluate nil
          org-highlight-latex-and-related '(latex script entities)
          org-hide-emphasis-markers t
          org-image-actual-width 500
          org-latex-pdf-process (list "latexmk -pdf %f" "rm *.fls" "rm *.log" "rm *.out" "rm *.fdb_latexmk" "rm *.tex"))
    (delete '("\\.pdf\\'" . default) org-file-apps)
    (add-to-list 'org-file-apps '("\\.pdf" . "zathura %s")))

  (leaf bibtex
    :init
    (defhydra hydra-bibtex (:color blue)
      "bibtex-mode"
      ("i" yas-insert-snippet "yas-insert-snippet" :column "Yas"))
    (evil-leader/set-key-for-mode 'bibtex-mode "SPC" 'hydra-bibtex/body))

  (leaf org-roam
    :custom (org-roam-directory . "~/.emacs.d/org-roam")
    :hook (after-init-hook . org-roam-mode)
    :bind (:org-roam-mode-map
           ("C-c n i" . org-roam-capture)
           ("C-c n f" . org-roam-find-file))))

;; (leaf winner-mode
;;   :init
;;   (winner-mode t)
;;   (evil-define-key 'normal winner-mode-map
;;     (kbd "U") (lambda () (interactive)
;;                 (let ((inhibit-message t))
;;                   (winner-undo)))
;;     (kbd "R") (lambda () (interactive)
;;                 (let ((inhibit-message t))
;;                   (winner-redo)))))

(leaf project
  :init
  (setq project-switch-commands '((project-find-file "Find file")
                                  (project-find-regexp "Find regexp")
                                  (project-dired "Dired")
                                  (project-eshell "Eshell"))))

(leaf emms
  :init
  (emms-all)
  (emms-default-players)
  (setq emms-source-file-default-directory "~/downloads/other/music/")
  (add-hook 'emms-playlist-source-inserted-hook 'emms-shuffle))

(leaf which-key
  :init (which-key-setup-minibuffer)
  :global-minor-mode which-key-mode)

(leaf helpful
  :bind
  (("C-h f" . helpful-callable)
   ("C-h v" . helpful-variable)
   ("C-h k" . helpful-key)))

(leaf vterm
  :config
  (evil-define-key 'insert vterm-mode-map
    (kbd "C-v") 'vterm-yank
    (kbd "C-k") 'vterm-send-up
    (kbd "C-j") 'vterm-send-down))

(leaf system
  :bind ("C-x k" . odd/kill-buffer-window)
  :init
  (evil-define-key 'normal global-map
    (kbd "K") 'eldoc
    (kbd "0") 'evil-first-non-blank
    (kbd "C-p") 'odd/go-back-window-only
    (kbd "g h") (lambda nil (interactive) (dired "~"))
    (kbd "g s") (lambda nil (interactive) (dired "~/source/rust"))))

(leaf zoom
  :init
  (setq zoom-size '(0.618 . 0.618))
  (zoom-mode t))

(leaf tree-sitter
  :hook (tree-sitter-mode-hook . tree-sitter-hl-mode)
  :init
  (global-tree-sitter-mode t))

(leaf rainbow-delimiters
  :setq (rainbow-delimiters-max-face-count . 4)
  :hook (prog-mode-hook . rainbow-delimiters-mode))

(leaf flymake
  :setq (flymake-no-changes-timeout . 0.25))

(leaf gcmh
  :global-minor-mode gcmh-mode)

(leaf rainbow-mode
  :hook (prog-mode-hook . rainbow-mode))

(leaf electric-pair
  :hook (prog-mode-hook . electric-pair-mode))

(leaf magit
  :init
  (setq ediff-window-setup-function 'ediff-setup-windows-plain))

(leaf fancy-battery
  :hook (after-init-hook . fancy-battery-mode))

(leaf racket-mode
  :hook (scheme-mode-hook . racket-mode)
  :config
  (odd/add-hooks 'racket-mode-hook
                 '(eldoc-mode
                   evil-lispy-mode
                   aggressive-indent-mode
                   lispyville-mode))

  (defhydra hydra-racket (:color blue)
    "racket-mode"
    ("z" geiser-mode-switch-to-repl "switch repl" :column "Geiser")
    ("a" geiser-mode-switch-to-repl-and-enter "switch repl enter")
    ("b" geiser-eval-buffer "eval buffer")
    ("c" geiser-eval-defintion "eval definition")
    ("k" geiser-compile-current-buffer "compile buffer"))

  (evil-leader/set-key-for-mode 'racket-mode "SPC" 'hydra-racket/body)

  (leaf geiser
    :hook (racket-mode-hook . geiser-mode)
    :config
    (setq geiser-active-implementations '(racket))))
