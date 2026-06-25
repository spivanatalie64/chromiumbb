(define-module (chromiumbb cli)
  #:export (chromiumbb-main))

(use-modules (ice-9 format) (chromiumbb util)
             (chromiumbb sync) (chromiumbb build) (chromiumbb config))

(define (help)
  (format #t "\
Usage: chromiumbb COMMAND [ARGS...]

Chromium build, but better.  Replaces depot_tools/gclient/gn/ninja.

Commands:
  sync              Fetch/patch Chromium source (replaces gclient sync)
  patch-deps        Install build dependencies (replaces install-build-deps)
  configure [ARGS]  Configure build (replaces gn gen)
  build [TARGET]    Build (replaces ninja)
  clean             Clean build artifacts
  status            Show build status
  help              Show this help
  version           Show version
"))

(define (version)
  (format #t "chromiumbb 0.1.0~%"))

(define (dispatch cmd args)
  (cond
   ((string=? cmd "sync")          (sync-source))
   ((string=? cmd "patch-deps")    (install-build-deps))
   ((string=? cmd "configure")     (apply configure args))
   ((string=? cmd "build")         (apply build args))
   ((string=? cmd "clean")         (clean))
   ((string=? cmd "status")        (status))
   ((string=? cmd "help")          (help))
   ((string=? cmd "version")       (version))
   (else
    (format (current-error-port) "chromiumbb: unknown command ~s~%" cmd)
    (help)
    (exit 1))))

(define (chromiumbb-main args)
  (if (< (length args) 2)
      (begin (help) (exit 0)))
  (dispatch (list-ref args 1) (drop args 2)))
