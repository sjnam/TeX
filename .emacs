;; Language environments
(when (and (getenv "LANG")
           (string-match "ko" (getenv "LANG")))
  (set-language-environment "Korean"))

(prefer-coding-system       'utf-8)
(set-default-coding-systems 'utf-8-unix)
(set-terminal-coding-system 'utf-8)
(set-keyboard-coding-system 'utf-8)
(setq default-buffer-file-coding-system 'utf-8)

;; goto-line
(global-set-key "\C-x\C-j" 'goto-line)

;; Save space
(menu-bar-mode -1)
(tool-bar-mode -1)
(scroll-bar-mode -1)

(setq-default tab-width 4)
(setq-default indent-tabs-mode nil)

;; cc-mode
(setq c-basic-offset 4)
(setq c-default-style '((java-mode . "java")
			(awk-mode . "awk")
			(other . "linux")))

;; etags
(fset 'find-next-tag "\C-u\256")        ; macro for C-u M-.
(fset 'find-prev-tag "\C-u-\256")       ; macro for C-u - M-.
(global-set-key "\M-]" 'find-next-tag)
(global-set-key "\M-[" 'find-prev-tag)

; line number
;(require 'linum)
;(setq linum-format "%4d ")

;; 한글 폰트 설정
(set-face-font 'default "Monaco-12")
(set-fontset-font "fontset-default" '(#x1100 . #xffdc)
                  '("NanumGothic" . "iso10646-1"))
(set-fontset-font "fontset-default" '(#xe0bc . #xf66e)
                  '("NanumGothic" . "iso10646-1"))
(set-fontset-font "fontset-default" 'kana
                  '("Hiragino Kaku Gothic Pro" . "iso10646-1"))
(set-fontset-font "fontset-default" 'han
                  '("Hiragino Kaku Gothic Pro" . "iso10646-1"))
(set-fontset-font "fontset-default" 'japanese-jisx0208
                  '("Hiragino Kaku Gothic Pro" . "iso10646-1"))
(set-fontset-font "fontset-default" 'katakana-jisx0201
                  '("Hiragino Kaku Gothic Pro" . "iso10646-1"))
(setq face-font-rescale-alist
      '((".*hiragino.*" . 1.2) (".*nanum.*" . 1.0)))


;; color
(custom-set-variables
 ;; custom-set-variables was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
 '(custom-enabled-themes (quote (tango-dark))))
(custom-set-faces
 ;; custom-set-faces was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
 )


(require 'package)
;;  패키지 저장소 Marmalade 추가
(add-to-list 'package-archives
             '("marmalade" . "http://marmalade-repo.org/packages/") t)
;; 설치된 패키지들 활성화
(package-initialize)
