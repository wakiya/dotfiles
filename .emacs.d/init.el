
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; 3.2 Emacsの起動と終了                                  ;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;;; P30 デバッグモードでの起動
;; おまじない
(require 'cl)
;; Emacsからの質問をy/nで回答する
(fset 'yes-or-no-p 'y-or-n-p)
;; スタートアップメッセージを非表示
(setq inhibit-startup-screen t)

;; Top,leftの現在位置を確認
;; (frame-parameters)
;; (frame-width)
;; (frame-height)

(setq initial-frame-alist
    (append
    '(
     (top                 . 0)    ; フレームの Y 位置(ピクセル数)
	 (left                . 2560)   ; フレームの X 位置(ピクセル数)
	 (width               . 546)    ; フレーム幅(文字数)
	 (height              . 70))   ; フレーム高(文字数)
       initial-frame-alist))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; 4.1 効率的な設定ファイルの作り方と管理方法             ;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;; P60-61 Elisp配置用のディレクトリを作成
;; Emacs 23より前のバージョンを利用している方は
;; user-emacs-directory変数が未定義のため次の設定を追加
(when (< emacs-major-version 23)
  (defvar user-emacs-directory "~/.emacs.d/"))

;; load-path を追加する関数を定義
(defun add-to-load-path (&rest paths)
  (let (path)
    (dolist (path paths paths)
      (let ((default-directory
              (expand-file-name (concat user-emacs-directory path))))
        (add-to-list 'load-path default-directory)
        (if (fboundp 'normal-top-level-add-subdirs-to-load-path)
            (normal-top-level-add-subdirs-to-load-path))))))

;; 引数のディレクトリとそのサブディレクトリをload-pathに追加
;; (add-to-load-path "elisp" "conf" "public_repos")
(add-to-load-path "elisp")

;; ▼要拡張機能インストール▼（ただし、Emacs24からはインストール不要）
;;; P115-116 Emacs Lisp Package Archive（ELPA）──Emacs Lispパッケージマネージャ
;; package.elの設定
(when (require 'package nil t)
  ;; パッケージリポジトリにMarmaladeと開発者運営のELPAを追加
  (add-to-list 'package-archives
               '("marmalade" . "http://marmalade-repo.org/packages/"))
  (add-to-list 'package-archives '("ELPA" . "http://tromey.com/elpa/"))
  ;; インストールしたパッケージにロードパスを通して読み込む
  (package-initialize))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; 4.2 環境に応じた設定の分岐                             ;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;; P65 CUIとGUIによる分岐
;; ターミナル以外はツールバー、スクロールバーを非表示
;;(when window-system
  ;; tool-barを非表示
;;  (tool-bar-mode 0)
  ;; scroll-barを非表示
;;  (scroll-bar-mode 0))

;; CocoaEmacs以外はメニューバーを非表示
;;(unless (eq window-system 'ns)
  ;; menu-barを非表示
;;  (menu-bar-mode 0))



;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; 5.2 キーバインドの設定                                 ;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;; P80 C-hをバックスペースにする
;; 入力されるキーシーケンスを置き換える
;; ?\C-?はDELのキーシケンス
;; (keyboard-translate ?\C-h ?\C-?)

;;; P79-81 お勧めのキー操作
;; C-mにnewline-and-indentを割り当てる。
;; 先ほどとは異なりglobal-set-keyを利用
;;(global-set-key (kbd "C-m") 'newline-and-indent)
;; 折り返しトグルコマンド
(define-key global-map (kbd "C-c l") 'toggle-truncate-lines)
;; "C-t" でウィンドウを切り替える。初期値はtranspose-chars
;; (define-key global-map (kbd "C-t") 'other-window)



;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; 5.3 環境変数の設定                                     ;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;; P82-83 パスの設定
;;(add-to-list 'exec-path "/opt/local/bin")
(add-to-list 'exec-path "/usr/local/bin")
;;(add-to-list 'exec-path "~/bin")

;;; P85 文字コードを指定する
(set-language-environment "Japanese")
(prefer-coding-system 'utf-8)

;;; P86 ファイル名の扱い
;; Mac OS Xの場合のファイル名の設定
(when (eq system-type 'darwin)
  (require 'ucs-normalize)
  (set-file-name-coding-system 'utf-8-hfs)
  (setq locale-coding-system 'utf-8-hfs))

;; Windowsの場合のファイル名の設定
(when (eq window-system 'w32)
  (set-file-name-coding-system 'cp932)
  (setq locale-coding-system 'cp932))



;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; 5.4 フレームに関する設定                               ;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;; P87-89 モードラインに関する設定
;; カラム番号も表示
(column-number-mode t)
;; ファイルサイズを表示
;;(size-indication-mode t)
;; 時計を表示（好みに応じてフォーマットを変更可能）
;; (setq display-time-day-and-date t) ; 曜日・月・日を表示
;; (setq display-time-24hr-format t) ; 24時表示
;;(display-time-mode t)
;; バッテリー残量を表示
;;(display-battery-mode t)
;; リージョン内の行数と文字数をモードラインに表示する（範囲指定時のみ）
;; http://d.hatena.ne.jp/sonota88/20110224/1298557375
(defun count-lines-and-chars ()
  (if mark-active
      (format "%d lines,%d chars "
              (count-lines (region-beginning) (region-end))
              (- (region-end) (region-beginning)))
      ;; これだとエコーエリアがチラつく
      ;;(count-lines-region (region-beginning) (region-end))
    ""))

(add-to-list 'default-mode-line-format
             '(:eval (count-lines-and-chars)))

;;; P90 タイトルバーにファイルのフルパスを表示
(setq frame-title-format "%f")
;; 行番号を常に表示する
;; (global-linum-mode t)
;; F5で行番号を表示
(global-set-key [f5] 'linum-mode)


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; 5.5インデントの設定                                    ;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;; P92-94 タブ文字の表示幅
;; TABの表示幅。初期値は8
(setq-default tab-width 4)
;; インデントにタブ文字を使用しない
;;(setq-default indent-tabs-mode nil)
;; php-modeのみタブを利用しない
;; (add-hook 'php-mode-hook
;;           '(lambda ()
;;             (setq indent-tabs-mode nil)))

;; C、C++、JAVA、PHPなどのインデント
(add-hook 'c-mode-common-hook
          '(lambda ()
             (c-set-style "java")))



;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; 5.6 表示・装飾に関する設定                             ;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;; P95-96 フェイス
;; リージョンの背景色を変更
;; (set-face-background 'region "darkgreen")

;; ▼要拡張機能インストール▼
;;; P96-97 表示テーマの設定
;; http://download.savannah.gnu.org/releases/color-theme/color-theme-6.6.0.tar.gz
;; (when (require 'color-theme nil t)
;;   ;; テーマを読み込むための設定
;;   (color-theme-initialize)
;;   ;; テーマhoberに変更する
;;   (color-theme-simple-1))

;; ;;; P97-99 フォントの設定
;; (when (eq window-system 'ns)
;;   ;; asciiフォントをMenloに
;;   (set-face-attribute 'default nil
;;                       :family "Menlo"
;;                       :height 120)
;;   ;; 日本語フォントをヒラギノ明朝 Proに
;;   (set-fontset-font
;;    nil 'japanese-jisx0208
;;    ;; 英語名の場合
;;    ;; (font-spec :family "Hiragino Mincho Pro"))
;;    (font-spec :family "ヒラギノ明朝 Pro"))
;;   ;; ひらがなとカタカナをモトヤシーダに
;;   ;; U+3000-303F	CJKの記号および句読点
;;   ;; U+3040-309F	ひらがな
;;   ;; U+30A0-30FF	カタカナ
;;   (set-fontset-font
;;    nil '(#x3040 . #x30ff)
;;    (font-spec :family "NfMotoyaCedar"))
;;   ;; フォントの横幅を調節する
;;   (setq face-font-rescale-alist
;;         '((".*Menlo.*" . 1.0)
;;           (".*Hiragino_Mincho_Pro.*" . 1.2)
;;           (".*nfmotoyacedar-bold.*" . 1.2)
;;           (".*nfmotoyacedar-medium.*" . 1.2)
;;           ("-cdac$" . 1.3))))

;; (when (eq system-type 'windows-nt)
;;   ;; asciiフォントをConsolasに
;;   (set-face-attribute 'default nil
;;                       :family "Consolas"
;;                       :height 120)
;;   ;; 日本語フォントをメイリオに
;;   (set-fontset-font
;;    nil
;;    'japanese-jisx0208
;;    (font-spec :family "メイリオ"))
;;   ;; フォントの横幅を調節する
;;   (setq face-font-rescale-alist
;;         '((".*Consolas.*" . 1.0)
;;           (".*メイリオ.*" . 1.15)
;;           ("-cdac$" . 1.3))))


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; 5.7 ハイライトの設定                                   ;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;; P100 現在行のハイライト
(defface my-hl-line-face
  ;; 背景がdarkならば背景色を紺に
  '((((class color) (background dark))
     (:background "NavyBlue" t))
    ;; 背景がlightならば背景色を緑に
    (((class color) (background light))
     (:background "LightGoldenrodYellow" t))
    (t (:bold t)))
  "hl-line's my face")
(setq hl-line-face 'my-hl-line-facep)
(global-hl-line-mode t)

;; P101 括弧の対応関係のハイライト
;; paren-mode：対応する括弧を強調して表示する
(setq show-paren-delay 0) ; 表示までの秒数。初期値は0.125
(show-paren-mode t) ; 有効化
;; parenのスタイル: expressionは括弧内も強調表示
(setq show-paren-style 'expression)
;; フェイスを変更する
;; (set-face-background 'show-paren-match-face nil)
;; (set-face-underline-p 'show-paren-match-face "yellow")


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; 5.8 バックアップとオートセーブ                         ;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;; P102-103 バックアップとオートセーブの設定
;; バックアップファイルを作成しない
;; (setq make-backup-files nil) ; 初期値はt
;; オートセーブファイルを作らない
;; (setq auto-save-default nil) ; 初期値はt

;; バックアップファイルの作成場所をシステムのTempディレクトリに変更する
(setq backup-directory-alist
      `((".*" . ,temporary-file-directory)))
;; オートセーブファイルの作成場所をシステムのTempディレクトリに変更する
(setq auto-save-file-name-transforms
      `((".*" ,temporary-file-directory t)))

;; バックアップとオートセーブファイルを~/.emacs.d/backups/へ集める
(add-to-list 'backup-directory-alist
             (cons "." "~/.emacs.d/backups/"))
(setq auto-save-file-name-transforms
      `((".*" ,(expand-file-name "~/.emacs.d/backups/") t)))

;; オートセーブファイル作成までの秒間隔
;; (setq auto-save-timeout 15)
;; ;; オートセーブファイル作成までのタイプ間隔
;; (setq auto-save-interval 60)


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; 5.9 フック                                             ;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; ファイルが #! から始まる場合、+xを付けて保存する
(add-hook 'after-save-hook
          'executable-make-buffer-file-executable-if-script-p)

;; rubikichi p231 eldoc-extension.el を使用
;; ;; emacs-lisp-mode-hook用の関数を定義
;; (defun elisp-mode-hooks ()
;;   "lisp-mode-hooks"
;;   (when (require 'eldoc nil t)
;;     (setq eldoc-idle-delay 0.2)
;;     (setq eldoc-echo-area-use-multiline-p t)
;;     (turn-on-eldoc-mode)))

;; ;; emacs-lisp-modeのフックをセット
;; (add-hook 'emacs-lisp-mode-hook 'elisp-mode-hooks)


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; 6.1 Elispをインストールしよう                          ;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; ▼要拡張機能インストール▼
;;; P113 拡張機能を自動インストール──auto-install
;; auto-installの設定
(when (require 'auto-install nil t)	; ←1●
  ;; 2●インストールディレクトリを設定する 初期値は ~/.emacs.d/auto-install/
  (setq auto-install-directory "~/.emacs.d/elisp/")
  ;; EmacsWikiに登録されているelisp の名前を取得する
  (auto-install-update-emacswiki-package-name t)
  ;; 必要であればプロキシの設定を行う
  ;; (setq url-proxy-services '(("http" . "localhost:8339")))
  ;; 3●install-elisp の関数を利用可能にする
  (auto-install-compatibility-setup)) ; 4●

;; ▼要拡張機能インストール▼
;;; P114-115 auto-installを利用する
;; (install-elisp "http://www.emacswiki.org/emacs/download/redo+.el")
(when (require 'redo+ nil t)
  ;; C-' にリドゥを割り当てる
  (global-set-key (kbd "C-'") 'redo)
  ;; 日本語キーボードの場合C-. などがよいかも
  ;; (global-set-key (kbd "C-.") 'redo)
  ) ; ←ここでC-x C-eで設定反映


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; 6.2 統一したインタフェースでの操作                     ;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; ▼要拡張機能インストール▼
;;; P122-129 候補選択型インタフェース──Anything
;; (auto-install-batch "anything")
(when (require 'anything nil t)
  (setq
   ;; 候補を表示するまでの時間。デフォルトは0.5
   anything-idle-delay 0.3
   ;; タイプして再描写するまでの時間。デフォルトは0.1
   anything-input-idle-delay 0.2
   ;; 候補の最大表示数。デフォルトは50
   anything-candidate-number-limit 100
   ;; 候補が多いときに体感速度を早くする
   anything-quick-update t
   ;; 候補選択ショートカットをアルファベットに
   anything-enable-shortcuts 'alphabet)

  (when (require 'anything-config nil t)
    ;; root権限でアクションを実行するときのコマンド
    ;; デフォルトは"su"
    (setq anything-su-or-sudo "sudo"))

  (require 'anything-match-plugin nil t)

  (when (and (executable-find "cmigemo")
             (require 'migemo nil t))
    (require 'anything-migemo nil t))

  (when (require 'anything-complete nil t)
    ;; lispシンボルの補完候補の再検索時間
    (anything-lisp-complete-symbol-set-timer 150))

  (require 'anything-show-completion nil t)

  (when (require 'auto-install nil t)
    (require 'anything-auto-install nil t))

  (when (require 'descbinds-anything nil t)
    ;; describe-bindingsをAnythingに置き換える
    (descbinds-anything-install))
)

;; ▼要拡張機能インストール▼
;;; P127-128 過去の履歴からペースト──anything-show-kill-ring
;; M-yにanything-show-kill-ringを割り当てる
(define-key global-map (kbd "M-y") 'anything-show-kill-ring)
;; すべてのkillを表示
;; http://dev.ariel-networks.com/articles/emacs/part4/
(setq anything-kill-ring-threshold 0)

;; ▼要拡張機能インストール▼
;;; P128-129 moccurを利用する──anything-c-moccur
(when (require 'anything-c-moccur nil t)
  (setq
   ;; anything-c-moccur用 `anything-idle-delay'
   anything-c-moccur-anything-idle-delay 0.1
   ;; バッファの情報をハイライトする
   anything-c-moccur-higligt-info-line-flag t
   ;; 現在選択中の候補の位置をほかのwindowに表示する
   anything-c-moccur-enable-auto-look-flag t
   ;; 起動時にポイントの位置の単語を初期パターンにする
   anything-c-moccur-enable-initial-pattern t)
  ;; M-s だと paredit.el の
  ;; M-s runs the command paredit-splice-sexp, which is an interactive
  ;; と干渉する為
  ;; (global-set-key (kbd "M-s") 'anything-c-moccur-occur-by-moccur)
  (define-key isearch-mode-map (kbd "C-o") 'anything-c-moccur-from-isearch)
  (define-key isearch-mode-map (kbd "C-M-o") 'isearch-occur))


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; 6.3 入力の効率化                                       ;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; ▼要拡張機能インストール▼
;;; P130-131 利用可能にする
(when (require 'auto-complete-config nil t)
  (add-to-list 'ac-dictionary-directories
    "~/.emacs.d/elisp/ac-dict")
  (define-key ac-mode-map (kbd "M-TAB") 'auto-complete)
  (ac-config-default))


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; 6.4 検索と置換の拡張                                   ;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; ▼要拡張機能インストール▼
;;; P132 検索結果をリストアップする──color-moccur
;; color-moccurの設定
(when (require 'color-moccur nil t)
  ;; M-oにoccur-by-moccurを割り当て
  (define-key global-map (kbd "M-o") 'occur-by-moccur)
  ;; スペース区切りでAND検索
  (setq moccur-split-word t)
  ;; ディレクトリ検索のとき除外するファイル
  (add-to-list 'dmoccur-exclusion-mask "\\.DS_Store")
  (add-to-list 'dmoccur-exclusion-mask "^#.+#$")
  ;; Migemoを利用できる環境であればMigemoを使う
  (when (and (executable-find "cmigemo")
             (require 'migemo nil t))
    (setq moccur-use-migemo t))
)

;; ▼要拡張機能インストール▼
;;; P133-134 moccurの結果を直接編集──moccur-edit
;; moccur-editの設定
(require 'moccur-edit nil t)
;; moccur-edit-finish-editと同時にファイルを保存する
;; (defadvice moccur-edit-change-file
;;   (after save-after-moccur-edit-buffer activate)
;;   (save-buffer))

;; ▼要拡張機能インストール▼
;;; P136 grepの結果を直接編集──wgrep
;; wgrepの設定
(require 'wgrep nil t)


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; 6.5 さまざまな履歴管理                                 ;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; ▼要拡張機能インストール▼
;;; P137-138 編集履歴を記憶する──undohist
;; undohistの設定
(when (require 'undohist nil t)
  (undohist-initialize))

;; ▼要拡張機能インストール▼
;;; P138 アンドゥの分岐履歴──undo-tree
;; undo-treeの設定
(when (require 'undo-tree nil t)
  (global-undo-tree-mode))


;; ▼要拡張機能インストール▼
;;; P139-140 カーソルの移動履歴──point-undo
;; point-undoの設定
(when (require 'point-undo nil t)
  ;; (define-key global-map [f5] 'point-undo)
  ;; (define-key global-map [f6] 'point-redo)
  ;; 筆者のお勧めキーバインド
  ;; (define-key global-map (kbd "M-[") 'point-undo)
  ;; (define-key global-map (kbd "M-]") 'point-redo)
  ;; rubikichi p115
  (define-key global-map (kbd "<f7>") 'point-undo)
  (define-key global-map (kbd "s-<f7>") 'point-redo)
)


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; 6.6 ウンドウ管理                                     ;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; ▼要拡張機能インストール▼
;;; P141-143 ウィンドウの分割状態を管理──ElScreen
;; ElScreenのプレフィックスキーを変更する（初期値はC-z）
(setq elscreen-prefix-key (kbd "C-t"))
(when (require 'elscreen nil t)
  (define-key global-map (kbd "s-]") 'elscreen-next)
  (define-key global-map (kbd "s-[") 'elscreen-previous)
  ;; C-z C-zをタイプした場合にデフォルトのC-zを利用する
  (if window-system
      (define-key elscreen-map (kbd "C-z") 'iconify-or-deiconify-frame)
    (define-key elscreen-map (kbd "C-z") 'suspend-emacs)))


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; 6.8 特殊な範囲の編集                                   ;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;; P151 矩形編集──cua-mode
;; cua-modeの設定
(cua-mode t) ; cua-modeをオン
(setq cua-enable-cua-keys nil) ; CUAキーバインドを無効にする


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; 7.1 各種言語の開発環境                                 ;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;; P158 nxml-modeをHTML編集のデフォルトモードに
;; HTML編集のデフォルトモードをnxml-modeにする
;; (add-to-list 'auto-mode-alist '("\\.[sx]?html?\\(\\.[a-zA-Z_]+\\)?\\'" . nxml-mode))
;; ;; ▼要拡張機能インストール▼
;; ;;; P159 HTML5をnxml-modeで編集する
;; ;; HTML5
;; (eval-after-load "rng-loc"
;;   '(add-to-list 'rng-schema-locating-files "~/.emacs.d/public_repos/html5-el/schemas.xml"))
;; (require 'whattf-dt)

;; ;;; P160 nxml-modeの基本設定
;; ;; </を入力すると自動的にタグを閉じる
;; (setq nxml-slash-auto-complete-flag t)
;; ;; M-TABでタグを補完する
;; (setq nxml-bind-meta-tab-to-complete-flag t)
;; ;; nxml-modeでauto-complete-modeを利用する
;; (add-to-list 'ac-modes 'nxml-mode)
;; ;; 子要素のインデント幅を設定する。初期値は2
;; (setq nxml-child-indent 0)
;; ;; 属性値のインデント幅を設定する。初期値は4
;; (setq nxml-attribute-indent 0)

;; ▼要拡張機能インストール▼
;;; P161 cssm-modeの基本設定
(defun css-mode-hooks ()
  "css-mode hooks"
  ;; インデントをCスタイルにする
  (setq cssm-indent-function #'cssm-c-style-indenter)
  ;; インデント幅を2にする
  (setq cssm-indent-level 2)
  ;; インデントにタブ文字を使わない
  (setq-default indent-tabs-mode nil)
  ;; 閉じ括弧の前に改行を挿入する
  (setq cssm-newline-before-closing-bracket ))

(add-hook 'css-mode-hook 'css-mode-hooks)

;;; P163 js-modeの基本設定
(defun js-indent-hook ()
  ;; インデント幅を4にする
  (setq js-indent-level 2
        js-expr-indent-offset 2
        indent-tabs-mode nil)
  ;; switch文のcaseラベルをインデントする関数を定義する
  (defun my-js-indent-line () ; ←1●
    (interactive)
    (let* ((parse-status (save-excursion (syntax-ppss (point-at-bol))))
           (offset (- (current-column) (current-indentation)))
           (indentation (js--proper-indentation parse-status)))
      (back-to-indentation)
      (if (looking-at "case\\s-")
          (indent-line-to (+ indentation 2))
        (js-indent-line))
      (when (> offset 0) (forward-char offset))))
  ;; caseラベルのインデント処理をセットする
  (set (make-local-variable 'indent-line-function) 'my-js-indent-line)
  ;; ここまでcaseラベルを調整する設定
  )

;; js-modeの起動時にhookを追加
(add-hook 'js-mode-hook 'js-indent-hook)

;; ▼要拡張機能インストール▼
;;; P165 php-mode
;; php-modeの設定
(when (require 'php-mode nil t)
  (add-to-list 'auto-mode-alist '("\\.ctp\\'" . php-mode))
  (setq php-search-url "http://jp.php.net/ja/")
  (setq php-manual-url "http://jp.php.net/manual/ja/"))

;;; P166 php-modeのインデントを調整する
;; php-modeのインデント設定
(defun php-indent-hook ()
  (setq tab-width 4)
  (setq indent-tabs-mode nil)
  (setq c-basic-offset 4)
  (c-set-offset 'case-label '+) ; switch文のcaseラベル
  (c-set-offset 'arglist-intro '+) ; 配列の最初の要素が改行した場合
  (c-set-offset 'arglist-close 0)) ; 配列の閉じ括弧

(add-hook 'php-mode-hook 'php-indent-hook)

;; ▼要拡張機能インストール▼
;;; P166-167 PHP補完入力──php-completion
;; php-modeの補完を強化する
(defun php-completion-hook ()
  (when (require 'php-completion nil t)
    (php-completion-mode t)
    (define-key php-mode-map (kbd "C-o") 'phpcmp-complete)

    (when (require 'auto-complete nil t)
    (make-variable-buffer-local 'ac-sources)
    (add-to-list 'ac-sources 'ac-source-php-completion)
    (auto-complete-mode t))))

(add-hook 'php-mode-hook 'php-completion-hook)

;; comment を /* */ から // へ
;; http://stackoverflow.com/questions/10758743/how-to-configure-emacs-to-properly-comment-code-in-php-mode
(defun php-comment-hook()
  (setq comment-multi-line nil
        comment-start "// "
        comment-end ""
        comment-style 'indent
        comment-use-syntax t))
(add-hook 'php-mode-hook 'php-comment-hook)

;; P168-169 cperl-mode
;; perl-modeをcperl-modeのエイリアスにする
(defalias 'perl-mode 'cperl-mode)

;;; P170 cperl-modeのインデントを調整する
;; cperl-modeのインデント設定
(setq cperl-indent-level 4 ; インデント幅を4にする
      cperl-continued-statement-offset 4 ; 継続する文のオフセット※
      cperl-brace-offset -4 ; ブレースのオフセット
      cperl-label-offset -4 ; labelのオフセット
      cperl-indent-parens-as-block t ; 括弧もブロックとしてインデント
      cperl-close-paren-offset -4 ; 閉じ括弧のオフセット
      cperl-tab-always-indent t ; TABをインデントにする
      cperl-highlight-variables-indiscriminately t) ; スカラを常にハイライトする

;; ▼要拡張機能インストール▼
;;; P170 yaml-mode
;; yaml-modeの設定
(when (require 'yaml-mode nil t)
  (add-to-list 'auto-mode-alist '("\\.yml$" . yaml-mode)))

;; ▼要拡張機能インストール▼
;;; P171 Perl補完入力──perl-completion
;; perl-completionの設定
(defun perl-completion-hook ()
  (when (require 'perl-completion nil t)
    (perl-completion-mode t)
    (when (require 'auto-complete nil t)
      (auto-complete-mode t)
      (make-variable-buffer-local 'ac-sources)
      (setq ac-sources
            '(ac-source-perl-completion)))))

(add-hook  'cperl-mode-hook 'perl-completion-hook)

;;; P172 ruby-modeのインデントを調整する
;; ruby-modeのインデント設定
(setq
      ruby-deep-indent-paren-style nil ; 改行時のインデントを調整する
	  ;; ruby-indent-level 3 ; インデント幅を3に。初期値は2
      ;; ruby-mode実行時にindent-tabs-modeを設定値に変更
      ;; ruby-indent-tabs-mode t ; タブ文字を使用する。初期値はnil
      )

;; ▼要拡張機能インストール▼
;;; P172-173 Ruby編集用の便利なマイナーモード
;; 括弧の自動挿入──ruby-electric
(require 'ruby-electric nil t)
;; endに対応する行のハイライト──ruby-block
(when (require 'ruby-block nil t)
  (setq ruby-block-highlight-toggle t))
;; インタラクティブRubyを利用する──inf-ruby
(autoload 'run-ruby "inf-ruby"
  "Run an inferior Ruby process")
(autoload 'inf-ruby-keys "inf-ruby"
  "Set local key defs for inf-ruby in ruby-mode")

;; ruby-mode-hook用の関数を定義
(defun ruby-mode-hooks ()
  (inf-ruby-keys)
  (ruby-electric-mode t)
  (ruby-block-mode t))
;; ruby-mode-hookに追加
(add-hook 'ruby-mode-hook 'ruby-mode-hooks)


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; 7.5 特殊な文字の入力補助                               ;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; ▼要拡張機能インストール▼
;;; P201-202 絵文字の入力補助 emoji.el
;; (require 'emoji)



;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; 7.6 差分とマージ                                       ;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;; P206 同一フレーム内にコントロールパネルを表示する
;; ediffコントロールパネルを別フレームにしない
;; (setq ediff-window-setup-function 'ediff-setup-windows-plain)




;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; 7.7 Emacsからデータベースを操作                        ;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;; P210-211 MySQLへ接続する──sql-interactive-mode
;; SQLサーバへ接続するためのデフォルト情報
;; (setq sql-user "root" ; デフォルトユーザ名
;;       sql-database "database_name" ;  データベース名
;;       sql-server "localhost" ; ホスト名
;;       sql-product 'mysql) ; データベースの種類



;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; 7.8 バージョン管理                                     ;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; ▼要拡張機能インストール▼
;;; P215-216 Subversionフロントエンド psvn
;; (when (executable-find "svn")
;;   (setq svn-status-verbose nil)
;;   (autoload 'svn-status "psvn" "Run `svn status'." t))

;; ▼要拡張機能インストール▼
;;; P217-219 Gitフロントエンド Egg
;; GitフロントエンドEggの設定
;; (when (executable-find "git")
;;   (require 'egg nil t))



;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; 7.9 シェルの利用                                       ;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; ▼要拡張機能インストール▼
;;; ターミナルの利用 multi-term
;; multi-termの設定
(when (require 'multi-term nil t)
  ;; 使用するシェルを指定
  (setq multi-term-program "/bin/zsh")

  (add-to-list 'term-unbind-key-list '"M-x")
  (add-to-list 'term-unbind-key-list '"C-t"))

(add-hook 'term-mode-hook
		  '(lambda ()
			 ;; C-h を term 内文字削除にする
			 (define-key term-raw-map (kbd "C-h") 'term-send-backspace)
			 ;; C-y を term 内ペーストにする
			 (define-key term-raw-map (kbd "C-y") 'term-paste)
			 ;; ESC ESC で vi での ESC にする
			 (define-key term-raw-map (kbd "ESC ESC") 'term-send-raw)
			 ))


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; 7.10 TRAMPによるサーバ接続                             ;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; (require 'tramp)
;; (require 'tramp-sh)

;; (setq explicit-shell-file-name "bash")

;; (setq tramp-default-method "ssh")
;; (setq tramp-encoding-shell "bash")
;;; P225 バックアップファイルを作成しない
;; TRAMPでバックアップファイルを作成しない
(add-to-list 'backup-directory-alist
                  (cons tramp-file-name-regexp nil))

;; http://stackoverflow.com/questions/13794433/how-to-disable-autosave-for-tramp-buffers-in-emacs
(setq tramp-auto-save-directory "/tmp")

;; (setq tramp-default-method "ssh")
;; (setq tramp-verbose 10)
;; (add-to-list 'tramp-remote-path "/usr/bin/id")


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; 7.11 ドキュメント閲覧・検索                            ;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;; P226-228 Emacs版manビューア（WoMan）の利用
;; キャッシュを作成
;; (setq woman-cache-filename "~/.emacs.d/.wmncach.el")
;; ;; manパスを設定
;; (setq woman-manpath '("/usr/share/man"
;;                       "/usr/local/share/man"
;;                       "/usr/local/share/man/ja"))
;; ;; ▼要拡張機能インストール▼
;; ;; anything-for-document用のソースを定義
;; (setq anything-for-document-sources
;;       (list anything-c-source-man-pages
;;             anything-c-source-info-cl
;;             anything-c-source-info-pages
;;             anything-c-source-info-elisp
;;             anything-c-source-apropos-emacs-commands
;;             anything-c-source-apropos-emacs-functions
;;             anything-c-source-apropos-emacs-variables))

;; ;; anything-for-documentコマンドを作成
;; (defun anything-for-document ()
;;   "Preconfigured `anything' for anything-for-document."
;;   (interactive)
;;   (anything anything-for-document-sources
;;             (thing-at-point 'symbol) nil nil nil
;;             "*anything for document*"))

;; ;; Command+dにanything-for-documentを割り当て
;; (define-key global-map (kbd "s-d") 'anything-for-document)




;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;            オマケ                                      ;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;; カーソル位置のファイルパスやアドレスを "C-x C-f" で開く
(ffap-bindings)

;;; 筆者のキーバインド設定
;; Mac の Command + f と C-x b で anything-for-files
(define-key global-map (kbd "s-f") 'anything-for-files)
(define-key global-map (kbd "C-x b") 'anything-for-files)
;; M-k でカレントバッファを閉じる
(define-key global-map (kbd "M-k") 'kill-this-buffer)
;; Mac の command + 3 でウィンドウを左右に分割
(define-key global-map (kbd "s-3") 'split-window-horizontally)
;; Mac の Command + 2 でウィンドウを上下に分割
(define-key global-map (kbd "s-2") 'split-window-vertically)
;; Mac の Command + 1 で現在のウィンドウ以外を閉じる
(define-key global-map (kbd "s-1") 'delete-other-windows)
;; Mac の Command + 0 で現在のウィンドウを閉じる
(define-key global-map (kbd "s-0") 'delete-window)
;; バッファを全体をインデント
(defun indent-whole-buffer ()
  (interactive)
  (indent-region (point-min) (point-max)))
;; C-<f8> でバッファ全体をインデント
(define-key global-map (kbd "C-<f8>") 'indent-whole-buffer)

;;; P169 コラム　便利なエイリアス
;; dtwをdelete-trailing-whitespaceのエイリアスにする
(defalias 'dtw 'delete-trailing-whitespace)

;; 行末の空白を削除
;; http://reiare.net/blog/2010/12/16/emacs-space-tab/
;; 無駄な行末の空白を削除する(Emacs Advent Calendar jp:2010) - tototoshiの日記
;; http://d.hatena.ne.jp/tototoshi/20101202/1291289625
(add-hook 'before-save-hook 'delete-trailing-whitespace)

;; 改行やタブを可視化する whitespace-mode
(setq whitespace-display-mappings
      '((space-mark ?\x3000 [?\□]) ; zenkaku space
        (newline-mark 10 [8629 10]) ; newlne
        (tab-mark 9 [187 9] [92 9]) ; tab » 187
        )
      whitespace-style
      '(spaces
        ;; tabs
        trailing
        newline
        space-mark
        tab-mark
        newline-mark))
;; whitespace-modeで全角スペース文字を可視化　
(setq whitespace-space-regexp "\\(\x3000+\\)")
;; whitespace-mode をオン
;; (global-whitespace-mode t)
;; F5 で whitespace-mode をトグル
(define-key global-map (kbd "<f8>") 'global-whitespace-mode)


;;; Mac でファイルを開いたときに、新たなフレームを作らない
(setq ns-pop-up-frames nil)


;;; 最近閉じたバッファを復元
;; http://d.hatena.ne.jp/kitokitoki/20100608/p2
(defvar my-killed-file-name-list nil)

(defun my-push-killed-file-name-list ()
  (when (buffer-file-name)
    (push (expand-file-name (buffer-file-name)) my-killed-file-name-list)))

(defun my-pop-killed-file-name-list ()
  (interactive)
  (unless (null my-killed-file-name-list)
    (find-file (pop my-killed-file-name-list))))
;; kill-buffer-hook (バッファを消去するときのフック) に関数を追加
(add-hook 'kill-buffer-hook 'my-push-killed-file-name-list)
;; Mac の Command + z で閉じたバッファを復元する
(define-key global-map (kbd "s-z") 'my-pop-killed-file-name-list)

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;              rubikitch technique                       ;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

(tool-bar-mode -1)
(scroll-bar-mode -1)
;; p216 view-mode
(setq view-read-only t)

;; rubikichi p78
;; 同時押しコマンド
(when (require 'key-chord nil t)
  (setq key-chord-two-keys-delay 0.04)
  (key-chord-mode 1)
  ;; p217 view-mode
  (key-chord-define-global "jk" 'view-mode)
  (key-chord-define-global "df" 'anything-c-moccur-occur-by-moccur)
)

;; rubikichi p78
;; スペース同時押し
;; http://d.hatena.ne.jp/rubikitch/20081105/1225856491
;; (when (require 'space-chord nil t)
;;   (setq space-chord-delay 0.04)
;;   (space-chord-define-global "h" 'anything-for-files)
;;   (space-chord-define-global "j" 'anything-c-moccur-occur-by-moccur)
;; )

;; rubikichi p79
;; `raise-minor-mode-map-alist' / `lower-minor-mode-map-alist' - resolve `minor-mode-map-alist' conflict
;; (when (require 'minor-mode-hack nil t)
;;   (lower-minor-mode-map-alist 'ruby-electric-mode)
;;   (raise-minor-mode-map-alist ')
;; )

;; p87 recentfを拡張する
;; http://d.hatena.ne.jp/rubikitch/20091224/recentf
(when (require 'recentf-ext nil t)
  (setq recentf-max-saved-items 3000)
  (setq recentf-exclude '("/TAGS$" "/var/tmp/"))
  (global-set-key (kbd "C-c f") 'recentf-open-files)
)

;; p102 dired でファイル名を直接編集
(define-key dired-mode-map "r" 'wdired-change-to-wdired-mode)

;; for C/Migemo
;; written by migemo.el
;; p113 cmigemo
;; http://www.kaoriya.net/software/cmigemo/
;; https://github.com/koron/cmigemo
;; migemo.el
;; https://gist.github.com/tomoya/457761
(when (and (executable-find "cmigemo")
           (require 'migemo nil t))
  (setq migemo-command "/usr/local/bin/cmigemo")
  (setq migemo-options '("-q" "--emacs"))
  (setq migemo-dictionary "/usr/local/share/migemo/utf-8/migemo-dict")
  (setq migemo-user-dictionary nil)
  (setq migemo-coding-system 'utf-8-unix)
  (setq migemo-regex-dictionary nil)
  (load-library "migemo")
  (migemo-init)
)

;; p116 bm.el
;; カーソル位置に印を付ける
;; http://cvs.savannah.gnu.org/viewvc/*checkout*/bm/bm/bm.el
(when (require 'bm nil t)
  ;; マークのセーブ
  (setq-default bm-buffer-persistence t)
  ;; セーブファイル名の設定
  (setq bm-repository-file "~/.emacs.d/bm/.bm-repository")
  ;; 起動時に設定のロード
  (setq bm-restore-repository-on-load t)
  (add-hook 'after-init-hook 'bm-repository-load)
  (add-hook 'find-file-hooks 'bm-buffer-restore)
  (add-hook 'after-revert-hook 'bm-buffer-restore)
  ;; 設定ファイルのセーブ
  (add-hook 'kill-buffer-hook 'bm-buffer-save)
  (add-hook 'auto-save-hook 'bm-buffer-save)
  (add-hook 'after-save-hook 'bm-buffer-save)
  (add-hook 'vc-before-checkin-hook 'bm-buffer-save)
  ;; Saving the repository to file when on exit
  ;; kill-buffer-hook is not called when emacs is killed, so we
  ;; must save all bookmarks first
  (add-hook 'kill-emacs-hook '(lambda nil
								(bm-buffer-save-all)
								(bm-repository-save)))
  (global-set-key (kbd "<M-SPC>") 'bm-toggle)
  (global-set-key (kbd "M-[") 'bm-next)
  (global-set-key (kbd "M-]") 'bm-previous)
)

;; p117 goto-chg.el
;; 最後の変更箇所にカーソル移動
(when (require 'goto-chg nil t)
  (define-key global-map (kbd "<f8>") 'goto-last-change)
  (define-key global-map (kbd "s-<f8>") 'goto-last-change-reverse))

;; p126 hippie-expand
;; http://dev.ariel-networks.com/Members/matsuyama/emacs-abbrev/
(define-key global-map (kbd "C-,") 'hippie-expand)
(setq hippie-expand-try-functions-list
      '(try-complete-file-name-partially
        try-complete-file-name
        try-expand-all-abbrevs
        try-expand-list try-expand-line
        try-expand-dabbrev
        try-expand-dabbrev-all-buffers
        try-expand-dabbrev-from-kill
        try-complete-lisp-symbol-partially
        try-complete-lisp-symbol))

;; p154 正規表現置換
(defalias 'qrr 'query-replace-regexp)

;; p214 view-mode
(when (require 'viewer nil t)
  ;; 書き込み不能ファイルでview-modeから抜けなくなる
  (viewer-stay-in-setup)
  ;; view-modeの時に色を変える。書き込み不可=tomato 書き込み可=orange
  (setq viewer-modeline-color-unwritable "tomato"
		viewer-modeline-color-view "orange")
  (viewer-change-modeline-color-setup)
)

;; p218 define-key view-mode-map
;; http://d.hatena.ne.jp/syohex/20110114/1294958917
(when (require 'view nil t)
  ;; less like
  (define-key view-mode-map (kbd "N") 'View-search-last-regexp-backward)
  (define-key view-mode-map (kbd "?") 'View-search-regexp-backward )
  (define-key view-mode-map (kbd "G") 'View-goto-line-last)
  (define-key view-mode-map (kbd "b") 'View-scroll-page-backward)
  (define-key view-mode-map (kbd "f") 'View-scroll-page-forward)
  ;; vi/w3m like
  (define-key view-mode-map (kbd "h") 'backward-char)
  (define-key view-mode-map (kbd "j") 'next-line)
  (define-key view-mode-map (kbd "k") 'previous-line)
  (define-key view-mode-map (kbd "l") 'forward-char)
  (define-key view-mode-map (kbd "J") 'View-scroll-line-forward)
  (define-key view-mode-map (kbd "K") 'View-scroll-line-backward)
  (when (require 'bm nil t)
	(define-key view-mode-map (kbd "m") 'bm-toggle)
	(define-key view-mode-map (kbd "[") 'bmprevious)
	(define-key view-mode-map (kbd "]") 'bm-next))
)

;; emacs lisp
;; http://www.mag2.com/sample/0001373131
;; p228 括弧の対応を保持して編集する設定
;; scan error unbalanced parentheses
;; M-s runs the command paredit-splice-sexp, which is an interactive
(when (require 'paredit nil t)
  (add-hook 'emacs-lisp-mode-hook 'enable-paredit-mode)
  (add-hook 'lisp-interaction-mode-hook 'enable-paredit-mode)
  (add-hook 'lisp-mode-hook 'enable-paredit-mode)
  (add-hook 'ielm-mode-hook 'enable-paredit-mode)
)
;; http://www.emacswiki.org/emacs/ParEdit
;; (autoload 'enable-paredit-mode "paredit" "Turn on pseudo-structural editing of Lisp code." t)
;; (add-hook 'emacs-lisp-mode-hook       #'enable-paredit-mode)
;; ;; (add-hook 'eval-expression-minibuffer-setup-hook #'enable-paredit-mode)
;; (add-hook 'ielm-mode-hook             #'enable-paredit-mode)
;; (add-hook 'lisp-mode-hook             #'enable-paredit-mode)
;; (add-hook 'lisp-interaction-mode-hook #'enable-paredit-mode)
;; ;; (add-hook 'scheme-mode-hook           #'enable-paredit-mode)

;; p231 関数、変数のヘルプをエコーエリアに表示
;; http://www.emacswiki.org/emacs/eldoc-extension.el
;; http://d.hatena.ne.jp/sandai/20120304/p2
(when (require 'eldoc-extension nil t)
  (add-hook 'emacs-lisp-mode-hook 'turn-on-eldoc-mode)
  (add-hook 'lisp-interaction-mode-hook 'turn-on-eldoc-mode)
  (add-hook 'ielm-mode-hook 'turn-on-eldoc-mode)
  (setq eldoc-idle-delay 0.2)
  (setq eldoc-minor-mode-string ""))

;; p232 find-functionをキー割り当てする
(find-function-setup-keys)

;; 試行錯誤用ファイルを開くための設定
(when (require 'open-junk-file nil t)
  ;; C-x C-zで試行錯誤ファイルを開く
  (global-set-key (kbd "C-x C-z") 'open-junk-file))

;; p239 式の評価結果を注釈するための設定
(when (require 'lispxmp nil t)
  ;; emacs-lisp-modeでC-c C-dを押すと注釈される
  (define-key emacs-lisp-mode-map (kbd "C-c C-d") 'lispxmp))

;; p35 自動バイトコンパイル
(when (require 'auto-async-byte-compile nil t)
  ;; 自動バイトコンパイルを無効にするファイル名の正規表現
  (setq auto-async-byte-compile-exclude-files-regexp "/junk/")
  (add-hook 'emacs-lisp-mode-hook 'enable-auto-async-byte-compile-mode))

;; 釣り合いのとれる括弧をハイライトする
(show-paren-mode 1)

;; 改行と同時にインデントも行う
(global-set-key "\C-m" 'newline-and-indent)

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;              rubikitch lisp                            ;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;




;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;                     wa                                 ;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;;; キーバインド設定
(define-key global-map (kbd "s-m") 'follow-delete-other-windows-and-split)
;; http://akisute3.hatenablog.com/entry/20120318/1332059326
;; http://kiyotakagoto.hatenablog.com/entry/2013/02/06/230546
;; (define-key global-map (kbd "C-h") 'delete-backward-char)
(keyboard-translate ?\C-h ?\C-?)
(define-key global-map (kbd "M-g") 'goto-line)
(define-key global-map (kbd "C-z") 'line-end-position)
;; http://www.fan.gr.jp/~ring/Meadow/meadow.html#scroll-down
;; (global-set-key "\C-z" 'scroll-down)
(global-set-key [f2] 'multi-term)
(global-set-key (kbd "C-c r") 'query-replace)

(add-hook 'term-mode-hook
     (lambda ()
	   ;; multi-term でコマンド履歴を遡れるようにする
	   ;; 合わせて .zshrc に以下を記述
	   ;; bindkey "hbsb-ep" history-beginning-search-backward-end
	   ;; bindkey "hbsb-en" history-beginning-search-forward-end
        (define-key term-raw-map (kbd "M-p")
          (lambda ()
            "history-beginning-search-backward-end"
            (interactive)
            (term-send-raw-string "hbsb-ep")))
        (define-key term-raw-map (kbd "M-n")
          (lambda ()
            "history-beginning-search-forward-end"
            (interactive)
            (term-send-raw-string "hbsb-en")))
        ))

;; 小文字
(put 'downcase-region 'disabled nil)

;; custom-theme
;; https://github.com/neomantic/Emacs-Sunburst-Color-Theme
;; https://github.com/neomantic/Emacs-Sunburst-Color-Theme/blob/master/sunburst-theme.el
(add-to-list 'custom-theme-load-path "~/.emacs.d/themes")
(load-theme 'sunburst t)

;; 行コピー
;; http://akisute3.hatenablog.com/entry/20120412/1334237294
(defun copy-whole-line (&optional arg)
  "Copy current line."
  (interactive "p")
  (or arg (setq arg 1))
  (if (and (> arg 0) (eobp) (save-excursion (forward-visible-line 0) (eobp)))
      (signal 'end-of-buffer nil))
  (if (and (< arg 0) (bobp) (save-excursion (end-of-visible-line) (bobp)))
      (signal 'beginning-of-buffer nil))
  (unless (eq last-command 'copy-region-as-kill)
    (kill-new "")
    (setq last-command 'copy-region-as-kill))
  (cond ((zerop arg)
         (save-excursion
           (copy-region-as-kill (point) (progn (forward-visible-line 0) (point)))
           (copy-region-as-kill (point) (progn (end-of-visible-line) (point)))))
        ((< arg 0)
         (save-excursion
           (copy-region-as-kill (point) (progn (end-of-visible-line) (point)))
           (copy-region-as-kill (point)
                                (progn (forward-visible-line (1+ arg))
                                       (unless (bobp) (backward-char))
                                       (point)))))
        (t
         (save-excursion
           (copy-region-as-kill (point) (progn (forward-visible-line 0) (point)))
           (copy-region-as-kill (point)
                                (progn (forward-visible-line arg) (point))))))
  ;; wa 変更予定　末尾の改行削除
  ;; (kill-new (substring (car kill-ring-yank-pointer) 0 -1) nil)
  ;; (message (substring (car kill-ring-yank-pointer) 0 -1))
  (kill-new (replace-regexp-in-string "\n+$" "" (car kill-ring-yank-pointer)) nil)
  (message (replace-regexp-in-string "\n+$" "" (car kill-ring-yank-pointer)) nil))

(global-set-key (kbd "M-k") 'copy-whole-line)
(global-set-key (kbd "M-K") 'kill-whole-line)

;; ange-ftp
;; keirin-express ftp setting
(require 'ange-ftp)
(setq ange-ftp-default-user "ftp-kviss1")
(ange-ftp-set-passwd "117.20.102.133" "ftp-kviss1" "zZT6ffcL")

;; automatic highlighting current symbol like eclipse IDE.
;; https://github.com/emacsmirror/auto-highlight-symbol
(when (require 'auto-highlight-symbol nil t)
  (global-auto-highlight-symbol-mode t))

;; http://dev.ariel-networks.com/articles/emacs/part5/
;; http://www.emacswiki.org/emacs/download/thing-opt.el
;; (when (require 'thing-opt nil t)
;;   (define-thing-commands)
;;   ;; (global-set-key (kbd "C-;") 'mark-word*)
;;   (global-set-key (kbd "C-=") 'mark-string)
;;   ;; (global-set-key (kbd "C-(") 'mark-up-list)
;; )

;; expand region
;; http://d.hatena.ne.jp/syohex/20120117/1326814127
;; https://github.com/magnars/expand-region.el
(when (require 'expand-region nil t)
  (global-set-key (kbd "C-;") 'er/expand-region)
  ;; リージョンを狭める
  (global-set-key (kbd "C-M-;") 'er/contract-region)
  (transient-mark-mode t)
)

;; バッファ自動再読み込み
;; emacs以外のものからファイルが編集された場合もbufferを再読込する
(global-auto-revert-mode 1)

;; マウスホイールでスクロール
;; http://superm.hatenablog.com/entry/20100908/1283910730
;; http://www.emacswiki.org/emacs/SmoothScrolling#toc3
;; (defun scroll-down-with-lines ()
;;   "" (interactive) (scroll-down 1))
;; (defun scroll-up-with-lines ()
;;    "" (interactive) (scroll-up 1))
;; (global-set-key [mouse-4] 'scroll-down-with-lines)
;; (global-set-key [mouse-5] 'scroll-up-with-lines)

;; スクロールステップ 2 に設定
;; scroll one line at a time (less "jumpy" than defaults)
;; one line at a time
(setq mouse-wheel-scroll-amount '(2 ((shift) . 1)))
;; don't accelerate scrolling
(setq mouse-wheel-progressive-speed nil)
;; scroll window under mouse
(setq mouse-wheel-follow-mouse 't)
;; keyboard scroll one line at a time
;; (setq scroll-step 1)
(setq scroll-conservatively 10000)
(setq auto-window-vscroll nil)

;; window scroll
;; http://www.geocities.co.jp/SiliconValley-Bay/9285/ELISP-JA/elisp_425.html
(defun line-to-top-of-window ()
  "Scroll current line to top of window.
Replaces three keystroke sequence C-u 0 C-l."
  (interactive)
  (recenter 15))

(global-set-key [f6] 'line-to-top-of-window)

;; kill-ring に同じ内容の文字列を複数入れない
;; http://www.fan.gr.jp/~ring/Meadow/meadow.html
(defadvice kill-new (before ys:no-kill-new-duplicates activate)
  (setq kill-ring (delete (ad-get-arg 0) kill-ring)))

;; ssh-ageng
;; load-path 設定
(setq load-path
      (cons
       (expand-file-name "~/projects/dotfiles/.emacs.d/elisp/ssh-agent") load-path))
;; ライブラリ読み込み
(cond ((locate-library "ssh-agent") (load-library "ssh-agent")))

;; ;; 行頭に移動
;; (beginning-of-line)
;; ;; 行頭に移動 (goto-char)
;; (goto-char (line-beginning-position))
;; ;; 行末に移動
;; (end-of-line)
;; ;; 行末に移動 (goto-char)
;; (goto-char (line-end-position))

;; (defun move-to-beginning-of-line (&optional arg)
;;   (goto-char (line-beginning-position)))
;; (global-set-key (kbd "C-c a") 'move-to-beginning-of-line)

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; C# support
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;; Dired の g (revert-buffer)で symbol's value as variable is void となる為コメントアウト
;; https://code.google.com/p/csharpmode/issues/detail?id=8
;; http://kurokawh.blogspot.jp/2013/04/emacs-csharp-moderevert-buffer.html
;; 上記により
;; line 2656.
;; (let ((is-flymake-enabled
;;      (and (fboundp 'flymake-mode)
;;      	  flymake-mode)))
;; I replaced `fboundp' with `boundp' and this fixed it for me.
;; fboundp を boundp に置き換えて byte-compile すると
;; In toplevel form:
;; csharp-mode.el:2028:1:Error: Symbol's value as variable is void: csharp-enum-decl-re
;; となって elc が作れないので断念

;; http://d.hatena.ne.jp/InoHiro/20100609/1276061924
;; http://www.emacswiki.org/emacs/CSharpMode
;; http://www.emacswiki.org/emacs/csharp-mode.el

;; (autoload 'csharp-mode "csharp-mode" "Major mode for editing C# code." t)

;; (when (require 'csharp-mode nil t)
;;   (setq auto-mode-alist (cons '("\\.cs$" . csharp-mode) auto-mode-alist))

;;   ;; Patterns for finding Microsoft C# compiler error messages:
;;   (require 'compile)
;;   (push '("^\\(.*\\)(\\([0-9]+\\),\\([0-9]+\\)): error" 1 2 3 2) compilation-error-regexp-alist)
;;   (push '("^\\(.*\\)(\\([0-9]+\\),\\([0-9]+\\)): warning" 1 2 3 1) compilation-error-regexp-alist)

;;   ;; Patterns for defining blocks to hide/show:
;;   (push '(csharp-mode
;; 		  "\\(^\\s *#\\s *region\\b\\)\\|{"
;; 		  "\\(^\\s *#\\s *endregion\\b\\)\\|}"
;; 		  "/[*/]"
;; 		  nil
;; 		  hs-c-like-adjust-block-beginning)
;; 		hs-special-modes-alist)
;;   (put 'upcase-region 'disabled nil)
;; )

;; SQL*Plus
;; https://github.com/lmanolov/personal-emacs-lisp/blob/master/init.el
;; ********************************************************************************
;; ORACLE
;; (setenv "ORACLE_HOME" "/usr/lib/oracle/xe/app/oracle/product/10.2.0/server")
;; (setenv "PATH" (concat (getenv "ORACLE_HOME") "/bin:" (getenv "PATH")))
;; (setq sql-oracle-program (concat (getenv "ORACLE_HOME") "/bin/" "sqlplus"))
;; ********************************************************************************
(setenv "ORACLE_HOME" "/Users/yoshihirowakiya/projects/dotfiles/.emacs.d/oracle/instantclient_10_2")
(setq sql-oracle-program (concat (getenv "ORACLE_HOME") "/" "sqlplus"))
(setenv "DYLD_LIBRARY_PATH" (concat (getenv "DYLD_LIBRARY_PATH") ":" (getenv "ORACLE_HOME")))
(setenv "SQLPATH" (concat (getenv "ORACLE_HOME") "/aka/sql"))
(setenv "PATH" (concat (getenv "PATH") ":" (getenv "ORACLE_HOME")))
(setenv "NLS_LANG" "Japanese_Japan.AL32UTF8")
