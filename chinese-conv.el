;;; chinese-conv.el --- Chinese Conversion,
;;; eg. between tradition and simplified forms

;; Author: gucong <gucong43216@gmail.com>

;; This program is free software; you can redistribute it and/or
;; modify it under the terms of the GNU General Public License,
;; version 2, as published by the Free Software Foundation.

;; This program is distributed in the hope that it will be
;; useful, but WITHOUT ANY WARRANTY; without warranty of
;; MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
;; GNU General Public License for more details.

;; You should have received a copy of the GNU General Public
;; License along with this program; if not, write to the Free
;; Software Foundation, Inc., 59 Temple Place, Suite 330, Boston,
;; MA 02111-1307 USA

;;; Commentary:

;; This file works with opencc (http://code.google.com/p/opencc/)
;; and/or cconv (http://code.google.com/p/cconv)

;; Put this file into your load-path and the following into your
;; ~/.emacs:
;;   (require 'chinese-conv)

;;; Changelog:

;; 2013/02/13
;;     * New feature: multiple backend.
;;       Customizable through `chinese-conv-backend'.
;;       Built-in support for opencc and cconv. More backends
;;       can be added through `chinese-conv-backend-alist'
;;     * New Command: `chinese-conv-replace'
;;     * API change: `chinese-conv'
;;
;; 2012/01/28
;;     * Initial commit
;;

;;; Code:

(defvar chinese-conv-temp-path
  "/tmp/chinese_conv.tmp"
  "temp file for Chinese conversion")

;; opencc backend
(defvar chinese-conv-opencc-program
  "opencc"
  "The opencc program path")

(defvar chinese-conv-opencc-alist
  '(("simplified"  "/usr/share/opencc/mix2zhs.ini")
    ("traditional" "/usr/share/opencc/mix2zht.ini")
    ("from Simplified Chinese to Traditional Chinese" "/usr/share/opencc/zhs2zht.ini")
    ("from Simplified to phrases of Taiwan" "/usr/share/opencc/zhs2zhtw_p.ini")
    ("from Simplified to variants of Taiwan" "/usr/share/opencc/zhs2zhtw_v.ini")
    ("from Simplified to variants and phrases of Taiwan" "/usr/share/opencc/zhs2zhtw_vp.ini")
    ("Standard Configuration for Conversion from Traditional Chinese to Simplified Chinese" "/usr/share/opencc/zht2zhs.ini")
    ("from Traditional to phrases of Taiwan" "/usr/share/opencc/zht2zhtw_p.ini")
    ("from Traditional to variants of Taiwan" "/usr/share/opencc/zht2zhtw_v.ini")
    ("from Traditional to variants and phrases of Taiwan" "/usr/share/opencc/zht2zhtw_vp.ini")
    ("from Taiwan to China phrases (Simplified)" "/usr/share/opencc/zhtw2zhcn_s.ini")
    ("from Taiwan to China phrases (Traditional)" "/usr/share/opencc/zhtw2zhcn_t.ini")
    ("from Taiwan to Simplified" "/usr/share/opencc/zhtw2zhs.ini")
    ("from Taiwan to Traditional" "/usr/share/opencc/zhtw2zht.ini"))
  "Alist of opencc conversions.")

(defun chinese-conv-opencc-command (conv)
  (let ((arg (cadr (assoc conv chinese-conv-opencc-alist))))
    (if (null arg) (error "Undefined conversion")
      (concat chinese-conv-opencc-program
              " -i " chinese-conv-temp-path
              " -c " arg))))

;; cconv backend
(defvar chinese-conv-cconv-program
  "cconv"
  "The cconv program path")

(defvar chinese-conv-cconv-alist
  '(("simplified"  "UTF8-CN")
    ("traditional" "UTF8-TW")
    ("Taiwan"      "UTF8-TW")
    ("Hong Kong"   "UTF8-HK"))
  "Alist of cconv conversions.")

(defun chinese-conv-cconv-command (conv)
  (let ((arg (cadr (assoc conv chinese-conv-cconv-alist))))
    (if (null arg) (error "Undefined conversion")
      (concat chinese-conv-cconv-program
              " -f UTF8 " " -t " arg
              " " chinese-conv-temp-path))))

;; common
(defun chinese-conv-get-alist (&optional backend)
  (let ((l (cadr (assoc (or backend chinese-conv-backend)
                        chinese-conv-backend-alist))))
    (if (null l) (error "Undefined backend")
      l)))

(defun chinese-conv-get-command (&optional backend)
  (let ((f (caddr (assoc (or backend chinese-conv-backend)
                         chinese-conv-backend-alist))))
    (if (null f) (error "Undefined backend")
      f)))

;;;###autoload
(defun chinese-conv (str conv &optional backend)
  "Convert a Chinese string, eg. between simplified and traditional forms.
STR is the string to convert.
BACKEND is the backend to be used, see `chinese-conv-backend-alist'."
  (interactive
   (let* ((guess (or (and transient-mark-mode mark-active
                        (buffer-substring-no-properties
                         (region-beginning) (region-end)))
                   (current-word nil t)))
          (word (read-string (format "String to convert (default: %s): " guess)
                             nil nil guess))
          (conv (completing-read "Converion: "
                                 (chinese-conv-get-alist) nil t)))
     (list word conv nil)))
  (with-temp-file chinese-conv-temp-path
    (insert str "\n"))
  (let ((result
         (substring
          (shell-command-to-string
           (funcall (chinese-conv-get-command backend) conv))
          0 -1)))
    (if (called-interactively-p 'any)
        (message result)
      result)))

;;;###autoload
(defun chinese-conv-replace (start end conv &optional backend)
  "Convert a Chinese string in place. See `chinese-con'."
  (interactive
   (let ((start (region-beginning))
         (end (region-end))
         (conv (completing-read "Conversion: "
                                (chinese-conv-get-alist) nil t)))
     (list start end conv)))
  (let ((str (buffer-substring-no-properties start end)))
    (kill-region start end)
    (insert (chinese-conv str conv (or backend chinese-conv-backend)))))

;; customization

(defvar chinese-conv-backend-alist
  `(("opencc" ,chinese-conv-opencc-alist ,#'chinese-conv-opencc-command)
    ("cconv" ,chinese-conv-cconv-alist ,#'chinese-conv-cconv-command))
  "An alist to provide essential information about backends in the format
 ((BACKEND CONVERSION-ALIST COMMAND-GENERATOR) ... )

CONVERSION-ALIST is in the format ((IDENTIFIER INFO ... ) ... ).
The IDENTIFIER specifies a conversion direction and INFO provides
information to be used by COMMAND-GENERATOR.  It is preferable to
have \"simplified\" and \"traditional\" among the IDENTIFIERs.

COMMAND-GENERATOR is a function that consumes a string to be
matched with IDENTIFIER in CONVERSION-ALIST and produces a shell
command in the form of a string.")

(defvar chinese-conv-backend
  "opencc"
  "Backend of the conversion, see `chinese-conv-backend-alist'.")

(provide 'chinese-conv)
