;;; ob-plantuml-cmd.el --- org-babel functions for plantuml evaluation using plantuml container

;; Copyright (C) 2010-2015 Free Software Foundation, Inc.

;; Author: Radu Popescu (based on original version ob-plantuml.el by Zhang Weize)
;; Keywords: literate programming, reproducible research
;; Homepage: http://orgmode.org

;; This file is part of GNU Emacs.

;; GNU Emacs is free software: you can redistribute it and/or modify
;; it under the terms of the GNU General Public License as published by
;; the Free Software Foundation, either version 3 of the License, or
;; (at your option) any later version.

;; GNU Emacs is distributed in the hope that it will be useful,
;; but WITHOUT ANY WARRANTY; without even the implied warranty of
;; MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
;; GNU General Public License for more details.

;; You should have received a copy of the GNU General Public License
;; along with GNU Emacs.  If not, see <http://www.gnu.org/licenses/>.

;;; Commentary:

;; Org-Babel support for evaluating plantuml script. This script allows specifying an
;; arbitrary command to run, instead of a jar file, allowing one, for instance, to
;; use plantuml inside a Docker container (i.e. docker run -i think/plantuml)
;;
;; Inspired by Zhang Weize's ob-plantuml.el
;; http://www.emacswiki.org/emacs/org-export-blocks-format-plantuml.el

;;; Requirements:

;; plantuml | http://plantuml.sourceforge.net/
;; `org-plantuml-cmd' should point to the jar file

;;; Code:
(require 'ob)

(defvar org-babel-default-header-args:plantuml-cmd
  '((:results . "file") (:exports . "results"))
  "Default arguments for evaluating a plantuml source block.")

(defcustom org-plantuml-cmd ""
  "plantuml command to run file."
  :group 'org-babel
  :version "24.1"
  :type 'string)

(defun org-babel-execute:plantuml-cmd (body params)
  "Execute a block of plantuml code with org-babel.
This function is called by `org-babel-execute-src-block'."
  (let* ((result-params (split-string (or (cdr (assoc :results params)) "")))
	 (out-file (or (cdr (assoc :file params))
		       (error "PlantUML requires a \":file\" header argument")))
	 (in-file (org-babel-temp-file "plantuml-"))
	 (cmd (if (string= "" org-plantuml-cmd)
		  (error "`org-plantuml-command' is not set")
		(concat org-plantuml-cmd
			(if (string= (file-name-extension out-file) "svg")
			    " -tsvg" "")
			(if (string= (file-name-extension out-file) "eps")
			    " -teps" "")
			" < "
			(org-babel-process-file-name in-file)
			" > "
			(org-babel-process-file-name out-file)))))
    (with-temp-file in-file (insert (concat "@startuml\n" body "\n@enduml")))
    (message "%s" cmd) (org-babel-eval cmd "")
    nil)) ;; signal that output has already been written to file

(defun org-babel-prep-session:plantuml-cmd (session params)
  "Return an error because plantuml does not support sessions."
  (error "Plantuml does not support sessions"))

(provide 'ob-plantuml-cmd)



;;; ob-plantuml-cmd.el ends here
