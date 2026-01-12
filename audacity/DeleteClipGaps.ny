;nyquist plug-in
;version 4
;type tool
;name "Delete Clip Gaps"
;author "Steve Daulton"
;release 2.4.2
;copyright "GNU General Public License v2.0 or later"


(defun get_focus_track_id ()
  (let ((data (aud-get-info "Tracks"))
        (trk-count 0))
    (dolist (track data)
      (when (= (second (assoc `focused track)) 1)
        (return trk-count))
      (incf trk-count))))


(defun clipcount (clipdata tracknum)
  ;;; Return number of clips in specified track
  (setf trackcount 0)
  (dolist (clip clipdata trackcount)
    (if (= (second (assoc 'track clip)) tracknum)
        (incf trackcount))))


(defun remove-gaps (trknum)
  (setf clipdata (aud-get-info "Clips"))
  (setf clipcount (clipcount clipdata trknum))
  (dotimes (i clipcount)
    (aud-do "CursTrackStart:")
    (aud-do "SelNextClip")
    (aud-do "Cut")
    (aud-do "CursTrackEnd:")
    (aud-do "Paste"))
  (aud-do "CursProjectStart:")
  (aud-do  "SelTrackStartToCursor")
  (aud-do "Delete")
  "")


; Work around ripple editing off by default.
(setf old-pref (first (aud-do "GetPreference: Name=\"GUI/EditClipCanMove\"")))
(unless (string= old-pref "1")
  (aud-do "SetPreference: Name=\"GUI/EditClipCanMove\" Value=1"))


(remove-gaps (get_focus_track_id))

; Reset preferences.
(aud-do (format nil
                "SetPreference: Name=\"GUI/EditClipCanMove\" Value=~s"
                old-pref))
