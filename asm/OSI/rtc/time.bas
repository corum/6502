10 REM SHOW TIME FROM INTERRUPT ROUTINE.
20 REM NEED TO RUN RTC BEFORE RUNNING THIS.
30 S = PEEK(30001)
40 M = PEEK(30002)
50 H = PEEK(30003)
60 PRINT H;":";
70 IF M < 10 THEN PRINT "0";M;":";
80 IF M >= 10 THEN PRINT M;":";
90 IF S < 10 THEN PRINT "0";S
100 IF S >= 10 THEN PRINT S
110 IF S = PEEK(1026) THEN GOTO 110
120 GOTO 20
130 END
