(define-module (chromiumbb build)
  #:export (configure build clean status))

(use-modules (ice-9 format) (ice-9 regex) (chromiumbb util))

(define* (configure #:rest args)
  (let ((root (or (project-root)
                  (begin (fail "Not in a Chromium source tree") (exit 1)))))
    (let ((src-dir (if (file-exists? (string-append root "/src")) "src" "."))
          (target-cpu "arm64")
          (build-args ""))

      ;; Parse out --target-cpu if given
      (let loop ((as args))
        (when (pair? as)
          (cond
           ((string=? (car as) "--target-cpu")
            (set! target-cpu (cadr as))
            (loop (cddr as)))
           (else
            (set! build-args (string-append build-args " " (car as)))
            (loop (cdr as))))))

      (let ((out-dir (string-append root "/out/" target-cpu)))
        (mkdir-p out-dir)

        ;; Default args for AcreetionOS builds
        (let ((default-args "
target_os=\"android\"
android_channel=\"stable\"
is_chrome_branded=false
is_component_build=false
is_official_build=true
use_official_google_api_keys=false
symbol_level=0
ffmpeg_branding=\"Chrome\"
proprietary_codecs=true
is_debug=false
"))

          (let ((gn-args (string-append default-args build-args))
                (gn-path (if (file-exists? (string-append root "/src/tools/gn"))
                             (string-append root "/src/tools/gn")
                             "gn")))
            (ok (format #f "Configuring for ~a..." target-cpu))
            (let ((cmd (string-append gn-path " gen " out-dir " --args='" gn-args "'")))
              (run cmd)
              (ok (format #f "Config written to ~a" out-dir)))))))))

(define (mkdir-p dir)
  (let ((parts (string-split dir #\/))
        (path ""))
    (for-each (lambda (p)
                (set! path (string-append path "/" p))
                (unless (file-exists? path)
                  (mkdir path)))
              (cdr parts))))

(define* (build #:key (target "chrome_public_apk") (jobs #f))
  (let ((root (or (project-root)
                  (begin (fail "Not in a Chromium source tree") (exit 1)))))
    (ok "Building...")
    (let* ((target-cpu (or (and=> (stat (string-append root "/out/arm64")) (const "arm64"))
                          (and=> (stat (string-append root "/out/arm")) (const "arm"))
                          "arm64"))
           (out-dir (string-append root "/out/" target-cpu))
           (ninja-args (if jobs (format #f " -j~a" jobs) "")))
      (unless (file-exists? out-dir)
        (fail "No build config found. Run 'chromiumbb configure' first.")
        (exit 1))
      (run (string-append "ninja" ninja-args " -C " out-dir " " target))
      (ok "Build complete"))))

(define (clean)
  (let ((root (or (project-root)
                  (begin (fail "Not in a Chromium source tree") (exit 1)))))
    (ok "Removing out/...")
    (system (string-append "rm -rf " root "/out"))
    (ok "Clean complete")))

(define (status)
  (let ((root (project-root)))
    (format #t "~%")
    (format #t "  ~a:~t~a~%" "Version" "0.1.0")
    (format #t "  ~a:~t~a~%" "Project Root" (or root (dim "(none)")))
    (when root
      (let ((has-deps (file-exists? (string-append root "/DEPS"))))
        (format #t "  ~a:~t~a~%" "Chromium source" (if has-deps (green "Yes") (red "No"))))
      (let ((has-out (file-exists? (string-append root "/out"))))
        (format #t "  ~a:~t~a~%" "out/ configured" (if has-out (green "Yes") (red "No"))))
      (let ((src (string-append root "/src")))
        (format #t "  ~a:~t~a~%" "src/" (if (file-exists? src) (green "Yes") (dim "No")))))
    (newline)))
