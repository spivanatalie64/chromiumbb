(define-module (chromiumbb util)
  #:export (run status ok fail dim bold cyan yellow red green project-root
           chromium-source-dir? depot-dir?))

(use-modules (ice-9 popen) (ice-9 rdelim) (ice-9 format))

(define* (run cmd #:key (cwd (getcwd)))
  (let ((full-cmd (if (string? cmd) cmd (string-join cmd " "))))
    (format #t " ~a ~a~%" (dim "⏵") full-cmd)
    (let ((ret (with-output-to-string
                 (lambda ()
                   (with-error-to-string
                    (lambda ()
                      (system (string-append "cd " cwd " && " full-cmd))))))))
      (unless (zero? (status:exit-val ret))
        (format (current-error-port) " ~a exit ~a~%" (red "✗") ret))
      ret)))

(define (run-line cmd)
  (let* ((port (open-input-pipe cmd))
         (line (read-line port)))
    (close-pipe port)
    (string-trim-both line)))

(define (project-root)
  (let loop ((dir (getcwd)))
    (cond
     ((file-exists? (string-append dir "/.git")) dir)
     ((file-exists? (string-append dir "/.gclient")) dir)
     ((file-exists? (string-append dir "/DEPS")) dir)
     ((string=? dir "/") #f)
     (else (loop (dirname dir))))))

(define (chromium-source-dir? dir)
  (or (file-exists? (string-append dir "/DEPS"))
      (file-exists? (string-append dir "/src/DEPS"))))

(define (depot-dir?)
  (file-exists? (string-append (getenv "HOME") "/depot_tools")))

(define (c code s)
  (format #f "~c[~am~a~c[0m" #\escape code s #\escape))
(define (dim s) (c "2" s))
(define (bold s) (c "1" s))
(define (cyan s) (c "36" s))
(define (yellow s) (c "33" s))
(define (green s) (c "32" s))
(define (red s) (c "31" s))

(define* (status icon msg #:key (nl #t))
  (if nl (format #t " ~a ~a~%" icon msg) (format #t " ~a ~a" icon msg)))
(define (ok msg) (status (green "✓") msg))
(define (fail msg) (status (red "✗") msg))
