;; p129
;; 4-1-3

(defun one-window-p-test ()
  (interactive)
  (message "nomini t:%s nil:%s" (one-window-p t) (one-window-p)))
;; C-X p で one-window-p の挙動を確認できる
(global-set-key (kbd "C-x p") 'one-window-p-test) ; => one-window-p-test

;; (save-selected-window
;;   (switch-to-buffer " test1")
;;   (insert "This is test1")
;;   (select-window (split-window-vertically))
;;   ;; (select-window (split-window-horizontally))
;;   (switch-to-buffer " test2")
;;   (insert "This is test2"))				; => nil

;; line-to-top-of-window is init.el already written
(defun line-to-top-of-window-test ()
  (interactive)
  (recenter 0))							; => line-to-top-of-window-test
(global-set-key (kbd "C-z") 'line-to-top-of-window-test) ; => line-to-top-of-window-test
