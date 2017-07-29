(TeX-add-style-hook
 "dictonary"
 (lambda ()
   (TeX-add-to-alist 'LaTeX-provided-class-options
                     '(("article" "a4paper")))
   (TeX-add-to-alist 'LaTeX-provided-package-options
                     '(("inputenc" "utf8") ("fontenc" "T1") ("ulem" "normalem") ("geometry" "margin=0.8in")))
   (add-to-list 'LaTeX-verbatim-environments-local "minted")
   (add-to-list 'LaTeX-verbatim-macros-with-braces-local "path")
   (add-to-list 'LaTeX-verbatim-macros-with-braces-local "url")
   (add-to-list 'LaTeX-verbatim-macros-with-braces-local "nolinkurl")
   (add-to-list 'LaTeX-verbatim-macros-with-braces-local "hyperbaseurl")
   (add-to-list 'LaTeX-verbatim-macros-with-braces-local "hyperimage")
   (add-to-list 'LaTeX-verbatim-macros-with-braces-local "hyperref")
   (add-to-list 'LaTeX-verbatim-macros-with-delims-local "path")
   (TeX-run-style-hooks
    "latex2e"
    "article"
    "art10"
    "inputenc"
    "fontenc"
    "fixltx2e"
    "graphicx"
    "longtable"
    "float"
    "wrapfig"
    "rotating"
    "ulem"
    "amsmath"
    "textcomp"
    "marvosym"
    "wasysym"
    "amssymb"
    "hyperref"
    "minted"
    "geometry"
    "fancyhdr"
    "lastpage")
   (LaTeX-add-labels
    "sec-1"
    "sec-2"
    "sec-3"
    "sec-4"
    "sec-5"
    "sec-6"
    "sec-7"
    "sec-8"
    "sec-9"
    "sec-10"
    "sec-11"
    "sec-12"
    "sec-13"
    "fig:Meiosis"
    "sec-14"
    "sec-15"
    "sec-16"
    "sec-17"
    "sec-18"
    "sec-19"
    "sec-20"
    "sec-21"
    "sec-22"
    "sec-23"
    "sec-24"
    "sec-25"
    "fig:Mendel"
    "fig:Mendel2"
    "sec-26"))
 :latex)

