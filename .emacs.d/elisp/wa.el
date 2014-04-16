
;; (when (require 'wa nil t)
;;   (global-set-key (kbd "M-k") 'wa-copy-this-line)
;;   (global-set-key (kbd "C-c C-k") 'wa-kill-line-without-kill-ring)
;;   (global-set-key (kbd "C-a") 'vs-move-beginning-of-line)
;;   (global-set-key (kbd "C-c C-j") 'wa-set-region-one-line)
;;   (global-set-key (kbd "C-c ;") 'wa-paredit-comment-dwim-one-line)
;; )

(require 'cl)
(defvar wa-version "0.1")

(defun wa-copy-this-line ()
  "現在行をキルリングにセットする。改行無し。メッセージ有り"
  (interactive)
  ;; http://d.hatena.ne.jp/gongoZ/20111206/1323177550
  ;; 行頭、行末の改行、空白を削除
  (kill-new (replace-regexp-in-string "\\`\\(?:\\s-\\|\n\\)+\\|\\(?:\\s-\\|\n\\)+\\'" "" (thing-at-point 'line)))
  (message (car kill-ring)))

;; (defun wa-kill-line-without-kill-ring ()
;;   "Deletes a line, but does not put it in the kill-ring. (kinda)"
;;   (interactive)
;;   (move-beginning-of-line 1)
;;   ;; http://flex.phys.tohoku.ac.jp/texi/eljman/eljman_210.html
;;   ;; kill-line &optional count Comamnd
;;   ;; (kill-line 1) ;;countに１を渡すと改行を含めキルする為、下記に変更
;;   (kill-line)
;;   (setq kill-ring (cdr kill-ring)))

;; http://unix.stackexchange.com/questions/26360/emacs-deleting-a-line-without-sending-it-to-the-kill-ring
(defun wa-kill-line-without-kill-ring (&optional arg)
  (interactive "P")
  (move-beginning-of-line 1)
  (flet ((kill-region (begin end)
                      (delete-region begin end)))
    (kill-line arg)))

;; https://github.com/ncaq/vs-move-beginning-of-line
(defun is-reverse-point-whitespace-all ()
  "カーソルの位置の前には空白文字しかありません"
  (looking-back "^[\t ]+"))

(defun vs-move-beginning-of-line ()
  "Visual StdioライクなC-a,通常はインデントに従いHomeへ,もう一度押すと本来のHome"
  (interactive)
  (cond
   ((is-reverse-point-whitespace-all) (move-beginning-of-line nil))
   (t (back-to-indentation))))

(defun wa-set-region-one-line ()
  (interactive)
  (push-mark (beginning-of-line) nil t)
  (end-of-line))

(defun wa-paredit-comment-dwim-one-line ()
  (interactive)
  (push-mark (beginning-of-line) nil t)
  (end-of-line)
  (paredit-comment-dwim))

(provide 'wa)

;; wa.el ends here
