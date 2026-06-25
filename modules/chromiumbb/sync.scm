(define-module (chromiumbb sync)
  #:export (sync-source install-build-deps))

(use-modules (ice-9 format) (chromiumbb util))

(define* (sync-source #:key (revision #f))
  (let ((root (or (project-root)
                  (begin (fail "Not in a Chromium source tree") (exit 1)))))
    (ok "Syncing Chromium source...")

    ;; Check if depot_tools exists
    (unless (depot-dir?)
      (ok "depot_tools not found, fetching...")
      (system "git clone https://chromium.googlesource.com/chromium/tools/depot_tools.git ~/depot_tools"))

    (let ((depot (string-append (getenv "HOME") "/depot_tools"))
          (path (getenv "PATH")))
      (setenv "PATH" (string-append depot ":" path)))

    ;; gclient sync
    (if (file-exists? (string-append root "/.gclient"))
        (begin
          (ok "Running gclient sync...")
          (run (string-append "cd " root " && gclient sync --force --delete_unversioned_trees --reset"))
          (if revision
              (run (string-append "cd " root " && gclient sync --revision " revision))))
        (begin
          (fail "No .gclient found. Run 'gclient config' first or use an existing Chromium checkout.")
          (exit 1)))
    (ok "Sync complete")))

(define (install-build-deps)
  (let ((root (or (project-root)
                  (begin (fail "Not in a Chromium source tree") (exit 1)))))
    (ok "Installing build dependencies...")
    (let ((script (string-append root "/src/build/install-build-deps.sh")))
      (if (file-exists? script)
          (run (string-append "bash " script " --no-prompt --no-chromeos-fonts --no-syms --no-backwards-compatible"))
          (let ((script2 (string-append root "/build/install-build-deps.sh")))
            (if (file-exists? script2)
                (run (string-append "bash " script2 " --no-prompt"))
                (begin (fail "install-build-deps.sh not found") (exit 1))))))
    (ok "Dependencies installed")))
