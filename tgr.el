;;; tgr.el --- Interact with tags in your org files -*- lexical-binding:t -*-

;; Copyright (C) 2025 Lorenzo Colombo

;; Author: Lorenzo Colomvo
;; Version: 0.1.2
;; Keywords: Org-Mode, tgr
;; URL: https://github.com/L-Colombo/tgr-emacs-wrapper

;; This program is free software; you can redistribute it and/or
;; modify it under the terms of the GNU General Public License as
;; published by the Free Software Foundation; either version 3, or (at
;; your option) any later version.

;; This program is free software: you can redistribute it and/or modify
;; it under the terms of the GNU General Public License as published by
;; the Free Software Foundation, either version 3 of the License, or
;; (at your option) any later version.

;; This program is distributed in the hope that it will be useful,
;; but WITHOUT ANY WARRANTY; without even the implied warranty of
;; MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
;; GNU General Public License for more details.

;; You should have received a copy of the GNU General Public License
;; along with this program.  If not, see <http://www.gnu.org/licenses/>.

;;; Commentary:

;; This packages provides wrappers around the "tgr" command line tool
;; (https://github.com/L-Colombo/tgr) The aim of "tgr" is to provide
;; an easy and faster way to interact (list, search and refile) with tags in your .org files.

;;; Code:

(defvar tgr/tgr-directory
  nil
  "The directory where your Org files to be searched reside")

;;;###autoload
(defun tgr/locate ()
  "Show files that contain tags matching a given pattern"
  (interactive)
  (let* ((pattern (read-from-minibuffer "[tgr/locate] Query pattern: "))
         (file-list (string-split (shell-command-to-string
                                   (format "tgr locate %s" pattern))))
         (link-buf-name (format "%s.org" pattern))
         (header
          (format "* Files containing tags that match the pattern \"%s\"\n" pattern)))
      (with-current-buffer
          (get-buffer-create link-buf-name)
        (insert header)
        (dolist (file file-list)
          (insert (format "[[%s][%s]]\n"
                          (format "%s/%s" tgr/tgr-directory file) file)))
        (beginning-of-buffer)
        (org-mode)
        (org-fold-show-all)
        (switch-to-buffer-other-window link-buf-name))))

;;;###autoload
(defun tgr/refile ()
  "Refile all subtrees that match a given pattern"
  (interactive)
  (let* ((pattern (read-from-minibuffer "[tgr/refile] Query pattern: "))
         (refiled-file-contents (shell-command-to-string
                                 (format "tgr refile %s --no-pager" pattern)))
         (refiled-bufname (format "tgr_refiled_%s.org" pattern)))
    (with-current-buffer
        (get-buffer-create refiled-bufname)
      (insert refiled-file-contents)
      (beginning-of-buffer)
      (org-mode)
      (switch-to-buffer-other-window refiled-bufname))))

;;;###autoload
(defun tgr/search ()
  "Search for tags in your tgr directory"
  (interactive)
  (let* ((pattern (read-from-minibuffer "[tgr/search] Query pattern: "))
         (search-output (shell-command-to-string
                         (concat "tgr search " pattern))))
    (if (= 1 (length search-output))
        (message (format "No result for query \"%s\"" pattern))
      (with-current-buffer-window
          (get-buffer-create (format "*tgr search: %s*" pattern))
          nil nil
        (insert search-output)
        (switch-to-buffer-other-window (format "*tgr search: %s*" pattern))))))

;;;###autoload
(defun tgr/tags-all ()
  "Get a quick view of all the tags in your tgr directory"
  (interactive)
  (let ((tags (shell-command-to-string "tgr tags")))
    (with-current-buffer-window
        (get-buffer-create "*All tags*")
        nil nil
      (insert tags)
      (switch-to-buffer-other-window "*All tags*"))))

;;;###autoload
(defun tgr/tags-file ()
  "Get all your tags in a specific file withing your tgr directory"
  (interactive)
  (let ((file (completing-read
               "[tgr/tags-file] Where? "
               (directory-files
                tgr/tgr-directory))))
    (with-current-buffer-window
        (get-buffer-create (format "*Tags in %s*" file))
        nil nil
      (insert (shell-command-to-string (format "tgr tags --file=%s" file)))
      (switch-to-buffer-other-window (format "*Tags in %s*" file)))))

(provide 'tgr)

;;; tgr.el ends here
