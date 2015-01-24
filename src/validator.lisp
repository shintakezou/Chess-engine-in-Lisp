(load "~/chess/movegen.lisp")


(defun invalid-pawnmove (b move)
  (let* ((fcord (logand (ash move -6) 63))
	 (fpiece (aref (arBoard b) fcord))
	 (tcord (logand move 63))
	 (tpiece (aref (arBoard b) tcord))
	 (flag (ash move -12))
	 (color (color b))
	 (blocker (blocker b))
	 (enemies (if (= flag ENPASSANT)
		      (logior (getEnemies b color) (aref bitPosArray (enpassant b)))
		    (getEnemies b color))))

    (if (= fpiece PAWN)
	(if (= color WHITE)
	    (if (and 
		 (zero (logand (move-array PAWN fcord) (aref bitPosArray tcord)
				 enemies))
		 (not (and (= (- tcord fcord) 8) (= tpiece EMPTY)))
		 (not (and (= (- tcord fcord) 16) (= (ash fcord -3) 1)))
		 (zero (logand (aref fromToRay fcord tcord) blocker)))
		t nil)
	    (if (and 
		 (zero (logand (move-array BPAWN fcord) (aref bitPosArray tcord)
			       enemies))
		 (not (and (= (- tcord fcord) -8) (= tpiece EMPTY)))
		 (not (and (= (- tcord fcord) -16) (= (ash fcord -3) 6)))
		 (zero (logand (aref fromToRay fcord tcord) blocker)))
		t nil)))))

(defun invalid-kingmove (b move)
  (let* ((fcord (logand (ash move -6) 63))
	 (fpiece (aref (arBoard b) fcord))
	 (tcord (logand move 63))
	 (flag (ash move -12))
	 (color (color b))
	 (blocker (blocker b)))

    (if (= color WHITE)
	(if (and
	     (zero (logand (move-array fpiece fcord) (aref bitPosArray tcord)))
	     (not (and (= fcord E1) (= tcord G1) (= flag KING_CASTLE) 
		       (not-zero (logand (castling b) W_OO))
		       (zero (logand (aref fromToRay E1 G1) blocker))
		       (not (isAttacked b E1 BLACK))
		       (not (isAttacked b F1 BLACK))
		       (not (isAttacked b G1 BLACK))))
	     (not (and (= fcord E1) (= tcord C1) (= flag KING_CASTLE) 
		       (not-zero (logand (castling b) W_OOO))
		       (zero (logand (aref fromToRay E1 B1) blocker))
		       (not (isAttacked b E1 BLACK))
		       (not (isAttacked b D1 BLACK))
		       (not (isAttacked b C1 BLACK)))))
	    t nil)
	(if (and
	     (zero (logand (move-array fpiece fcord) (aref bitPosArray tcord)))
	     (not (and (= fcord E8) (= tcord G8) (= flag KING_CASTLE) 
		       (not-zero (logand (castling b) B_OO))
		       (zero (logand (aref fromToRay E8 G8) blocker))
		       (not (isAttacked b E8 WHITE))
		       (not (isAttacked b F8 WHITE))
		       (not (isAttacked b G8 WHITE))))
	     (not (and (= fcord E8) (= tcord C8) (= flag QUEEN_CASTLE) 
		       (not-zero (logand (castling b) B_OOO))
		       (zero (logand (aref fromToRay E8 G8) blocker))
		       (not (isAttacked b E8 WHITE))
		       (not (isAttacked b D8 WHITE))
		       (not (isAttacked b C8 WHITE)))))
	    t nil))))      


(defun validateMove (b move)
  (let* ((fcord (logand (ash move -6) 63))
	 (fpiece (aref (arBoard b) fcord))
	 (tcord (logand move 63))
	 (flag (ash move -12))
	 (color (color b))
	 (friends (aref (friends b) color))
	 (blocker (blocker b)))
	 
    (cond ((= fpiece EMPTY)
	   nil)
	  ((zero (logand (aref bitPosArray fcord) friends))
	   nil)
	  ((not-zero (logand (aref bitPosArray tcord) friends))
	   nil)
	  ((and (or (find flag promotions) (= flag ENPASSANT))
		(not (= fpiece PAWN)))
	   nil)
	  ((and (not (= tcord (enpassant b))) (= flag enpassant))
	   nil)
	  ((and (find flag `(,king_castle ,queen_castle)) (not (= fpiece KING)))
	   nil)
	  ((and (= fpiece PAWN) (invalid-pawnmove b move))
	   nil)
	  ((and (= fpiece KING) (invalid-kingmove b move))
	   nil)
	  ((not (zero (logand (move-array fpiece fcord)
			     (aref bitPosArray tcord))))
	   nil)
	  ((and (nth fpiece sliders) 
		(zero (logand (returnWithClearbit (aref fromToRay fcord tcord) tcord)
			 blocker)))
	   nil)
	  (t t))))





