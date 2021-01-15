;;; pocket-reader-org-roam-capture.el --- Convert pocket-reader entries into org-roam files  -*- lexical-binding: t; -*-

;; Copyright (C) 2021  Christof Damian

;; Author: Christof Damian <christof@damian.net>
;; URL: https://github.com/christofdamian/pocket-reader-org-roam-capture
;; Keywords: extensions, tools
;; Package-Requires: ((emacs "25.1") (pocket-reader "0.2.1") (org-roam "1.2.3"))
;; Version: 0.1.0

;; This program is free software; you can redistribute it and/or modify
;; it under the terms of the GNU General Public License as published by
;; the Free Software Foundation, either version 3 of the License, or
;; (at your option) any later version.

;; This program is distributed in the hope that it will be useful,
;; but WITHOUT ANY WARRANTY; without even the implied warranty of
;; MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
;; GNU General Public License for more details.

;; You should have received a copy of the GNU General Public License
;; along with this program.  If not, see <https://www.gnu.org/licenses/>.

;;; Commentary:

;; Convert pocket-reader entries into org-roam files

;;; Code:
;;;; Dependencies
(require 'pocket-reader)
(require 'org-roam)

;; Declarations
(defcustom pocket-reader-org-roam-capture-templates '(("d" "default" plain #'org-roam--capture-get-point "%?" :file-name "pocket/${item_id}-${slug}" :head "#+TITLE: ${title}
#+roamtags: ${tags}

URL: ${url}
Id: ${item_id}

${excerpt}
" :unnarrowed t))
  "Capture template for `pocket-reader' to `org-roam' capture.

The bound variables are mapping to `pocket-reader' values like this:

title: resolved_title
slug: resolved_title
url: resolved_url
item_id: item_id
excerpt: excerpt
tags: tags (joined with spaces and quoted)")

;;;; Functions
(defun pocket-reader-org-roam-capture ()
  "Create an `org-roam' capture for all marked or current pocket reader items."
  (interactive)
  (pocket-reader--at-marked-or-current-items
    (when-let (
	       (resolved_title (pocket-reader--get-property 'resolved_title))
	       (resolved_url (pocket-reader--get-property 'resolved_url))
               (item_id (pocket-reader--get-property 'item_id))
               (time_added (pocket-reader--get-property 'time_added))
               (excerpt (pocket-reader--get-property 'excerpt))
	       (tags (combine-and-quote-strings (pocket-reader--get-property 'tags))))
      (let (
            (org-roam-capture-templates pocket-reader-org-roam-capture-templates)
            (org-roam-capture--info `((title . ,resolved_title)
                                      (slug  . ,resolved_title)
                                      (url . ,resolved_url)
                                      (item_id . ,item_id)
                                      (excerpt . ,excerpt)
				      (tags . ,tags)))
            (org-roam-capture--context 'title))
	(setq org-roam-capture-additional-template-props (list :finalize 'find-file))
	(org-roam-capture--capture)))))


(provide 'pocket-reader-org-roam-capture)
;;; pocket-reader-org-roam-capture.el ends here
