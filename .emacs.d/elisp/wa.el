(require 'cl)
(defvar wa-version "0.1")

(defun wa-copy-this-line ()
  "現在行をキルリングにセットする。改行無し。メッセージ有り"
  (interactive)
  (kill-new (replace-regexp-in-string "\n+$" "" (thing-at-point 'line)))
  (message (car kill-ring)))

(provide 'wa)

;;; wa.el ends here
