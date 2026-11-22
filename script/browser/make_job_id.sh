#!/bin/bash
SESSION_ID=$1

text="SELECT IFNULL(MAX(job_number)+1, 1) FROM session_info WHERE session_id = \"${SESSION_ID}\" ;"
JOB_ID=$(mysql -u webtest KUBDS -Bse "$text")
DO_INSERT1='INSERT INTO session_info (session_id, job_number) VALUE ('
DO_INSERT2=')'
INS_CMD="INSERT INTO session_info (session_id, job_number) VALUE (\"$SESSION_ID\", $JOB_ID)"
INRESULT=$(mysql -u webtest KUBDS -Bse "$INS_CMD")
echo $JOB_ID
