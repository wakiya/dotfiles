
;; (when (require 'wa nil t)
;;   (global-set-key (kbd "M-k") 'wa-copy-this-line)
;;   (global-set-key (kbd "C-c C-k") 'wa-kill-line-without-kill-ring)
;; )

(require 'cl)
(defvar wa-version "0.1")

(defun wa-copy-this-line ()
  "現在行をキルリングにセットする。改行無し。メッセージ有り"
  (interactive)
  (kill-new (replace-regexp-in-string "\n+$" "" (thing-at-point 'line)))
  (message (car kill-ring)))

(defun wa-kill-line-without-kill-ring ()
  "Deletes a line, but does not put it in the kill-ring. (kinda)"
  (interactive)
  (move-beginning-of-line 1)
  (kill-line 1)
  (setq kill-ring (cdr kill-ring)))

(provide 'wa)

;;; wa.el ends here
