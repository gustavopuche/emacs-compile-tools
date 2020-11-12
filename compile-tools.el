;;; compile-tools.el --- Compile settings

;; Copiright (C) 2020 Gustavo Puche

;; Author: Gustavo Puche <gustavo.puche@gmail.com>
;; Created: 30 July 2020
;; Version: 0.2
;; Keywords: languages all
;; Package-Requires:


;;; Commentary:
;; Settup keybindings for compile commands.

;;; Code:

;; Environment variables
(defvar compile-tools--target nil
	"Qt TARGET.")

(defvar compile-tools--qtdir nil
	"QTDIR path.")

(defvar compile-tools--qtdir-linux "/opt/extra/Qt-linux-5.12.3/5.12.3/gcc_64"
	"QTDIR path.")

(defvar compile-tools--qtdir-android-v8a "/opt/extra/Qt5.12.3/5.12.3/android_arm64_v8a"
	"QTDIR path.")

(defvar compile-tools--qtdir-android-v7 "/opt/extra/Qt5.12.3/5.12.3/android_armv7"
	"QTDIR path.")

(defvar compile-tools--clang-flags mil
	"clang debug flags")

(defvar compile-tools--clang-flags-linux "-spec linux-clang CONFIG+=debug CONFIG+=qml_debug"
	"clang debug flags")

(defvar compile-tools--clang-flags-android "-spec android-clang CONFIG+=debug CONFIG+=qml_debug"
	"clang debug flags")

(defvar compile-tools--android-ndk-root "/opt/extra/android/android-ndk-r19c"
	"Android NDK path.")

(defvar compile-tools--qt-build-path nil
	"Qt Build path.")

(defvar compile-tools--qt-pro-file "~/share/workspace/logger-qt/logger-suite.pro"
	"Qt Build path.")

;; example of setting env var named “path”, by appending a new path to existing path
(setenv "ANDROID_HOME" "/opt/extra/android")

(setenv "ANDROID_NDK_HOST" "linux-x86_64")

(setenv "ANDROID_NDK_ROOT" "/opt/extra/android/android-ndk-r19c")

(setenv "ANDROID_SDK_ROOT" "/opt/extra/android")

;; Important to reuse
(defun compile-tools-set-target ()
  "Minibuffer chooser of TARGET options"
  (interactive)
  (setq compile-tool--target (completing-read "Choose TARGET: " '("linux" "Android ARMv8a" "Android ARMv7") nil t))
  (message "You chose `%s'" compile-tool--target)
  (if (equal compile-tool--target "linux")
			;; Linux
			(progn
				(setq compile-tools--qtdir compile-tools--qtdir-linux)
				(setq compile-tools--clang-flags compile-tools--clang-flags-linux))
		(if (equal compile-tool--target "Android ARMv8a")
				;; Android v8
				(progn
				(setq compile-tools--qtdir compile-tools--qtdir-android-v8a)
				(setq compile-tools--clang-flags compile-tools--clang-flags-android)
				(setenv "ANDROID_NDK_PLATFORM" "android-21"))
			;; Android v7
			(progn
				(setq compile-tools--qtdir compile-tools--qtdir-android-v7)
				(setq compile-tools--clang-flags compile-tools--clang-flags-android)
				(setenv "ANDROID_NDK_PLATFORM" "android-16")))))

(defun compile-tools-get-target-qtdir ()
	""
	(interactive)
	(if (null compile-tools--qtdir)
			(compile-tools-set-target))
	(message compile-tools--qtdir))

(defun compile-tools-reset-target ()
	""
	(interactive)
	(setq compile-tools--qtdir nil)
	(setq compile-tools--clang-flags nil))

(defun compile-tools-pro-file ()
	"Gets Qt main PRO file."
	(car (file-expand-wildcards (concat (projectile-project-root) "*.pro"))))

;; Sets Qt project build path
(defun compile-tools-set-qt-build-path ()
	"Opens a directory chooser and setup `compile-tools--qt-build-path'."
	(interactive)
	(setq compile-tools--qt-build-path (read-directory-name "Please choose Qt project build folder:")))

(defun compile-tools-qmake ()
	"Execute qmake in build folder.
COMMANDS
/opt/extra/Qt-linux-5.12.3/5.12.3/gcc_64/bin/qmake ~/share/workspace/logger-qt/logger-suite.pro -spec linux-clang CONFIG+=debug CONFIG+=qml_debug

make -f ./Makefile qmake_all"
	(interactive)
	(compile (concat "cd " compile-tools--qt-build-path
									 " && "
									 (compile-tools-get-target-qtdir) "/bin/qmake" " " (compile-tools-pro-file) " " compile-tools--clang-flags
									 " && "
									 "make -f ./Makefile qmake_all"))
	)

(defun compile-tools-compile-make ()
	"Execute make command."
	(interactive)
	(if (null compile-tools--qt-build-path)
			(compile "make -j4")
		(compile (concat "cd " compile-tools--qt-build-path
										 " && "
										 "make -j4"))))

(defun compile-tools-compile-make-run ()
	"Execute make run command."
	(interactive)
	(compile "make run"))

(defun compile-tools-compile-make-clean ()
	"Execute make clean command."
	(interactive)
	(if (null compile-tools--qt-build-path)
			(compile "make clean")
		(compile (concat "cd " compile-tools--qt-build-path
										 " && "
										 "make clean"))))

(defun compile-tools-compile-make-test ()
	"Execute make test-pc command."
	(interactive)
	(compile "make test-pc"))

(defun compile-tools-debug ()
	"Debug"
	(interactive)
	(message (car (file-expand-wildcards (concat (projectile-project-root) "*.pro")))))

(global-set-key (kbd "<f9>") 'compile-tools-compile-make)
(global-set-key (kbd "<f8>") 'compile-tools-compile-make-clean)
(global-set-key (kbd "<f7>") 'compile-tools-compile-make-test)
(global-set-key (kbd "<f6>") 'compile-tools-debug)
(global-set-key (kbd "<f5>") 'compile-tools-compile-make-run)
(global-set-key (kbd "<f4>") 'compile-tools-qmake)

(provide 'compile-tools)

;;; compile-tools.el ends here
