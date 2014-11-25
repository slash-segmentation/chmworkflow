#!/usr/bin/env bats

load test_helper

#
# CHM workflow where run chm job has non zero
# exit code
#
@test "chmworkflow.kar where run chm job has nonzero exit code" {
  
  # verify $KEPLER_SH is in path if not skip this test
  skipIfKeplerNotInPath

  /bin/mkdir -p "$THE_TMP/run"
  /bin/ln -s $THE_TMP/bin/command $THE_TMP/run/runCHMViaPanfish.sh

  echo "1,error,,/bin/echo" > "$THE_TMP/run/runCHMViaPanfish.sh.tasks"

  echo "0,,,/bin/echo" > "$THE_TMP/bin/createchm.tasks"
  # Run kepler.sh with no other arguments
  run $KEPLER_SH -runwf -redirectgui $THE_TMP -trainedModel /bar -inputImages /images -CWS_user johnny -CWS_jobname foo -CWS_jobid 43 -createChmJob $THE_TMP/bin/createchm -CWS_outputdir $THE_TMP $CHM_WF

  # Check exit code
  [ "$status" -eq 0 ]

  # Check output from kepler.sh
  [[ "${lines[0]}" == "The base dir is"* ]]

  echo "Output from kepler.  Should only see this if something below fails ${lines[@]}"

   # Verify we got a workflow failed txt file
  [ -s "$THE_TMP/$WORKFLOW_FAILED_TXT" ]

  # Check output of workflow failed txt file
  run cat "$THE_TMP/$WORKFLOW_FAILED_TXT"
  [ "$status" -eq 0 ]
  [ "${lines[0]}" == "simple.error.message=Unable to run CHM job" ]
  [[ "${lines[1]}" == "detailed.error.message=Non zero exit code received from "* ]]

}


