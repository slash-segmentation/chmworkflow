#!/usr/bin/env bats

load test_helper

#
# CHM workflow successful run
#
@test "chmworkflow.kar successful run" {
  
  # verify $KEPLER_SH is in path if not skip this test
  skipIfKeplerNotInPath

  /bin/mkdir -p "$THE_TMP/run"
  /bin/ln -s $THE_TMP/bin/command $THE_TMP/run/runCHMViaPanfish.sh
  /bin/ln -s $THE_TMP/bin/command $THE_TMP/run/runMergeTilesViaPanfish.sh

  echo "0,,," > "$THE_TMP/run/runCHMViaPanfish.sh.tasks"
  echo "0,,," > "$THE_TMP/run/runMergeTilesViaPanfish.sh.tasks"

  echo "0,,,/bin/echo" > "$THE_TMP/bin/createchm.tasks"

  # Run kepler.sh with no other arguments
  run $KEPLER_SH -runwf -redirectgui $THE_TMP -trainedModel /bar -inputImages /images -CWS_user johnny -CWS_jobname foo -CWS_jobid 43 -createChmJob $THE_TMP/bin/createchm -CWS_notifyemail 'bob@bob.com' -CWS_outputdir $THE_TMP $CHM_WF

  # Check exit code
  [ "$status" -eq 0 ]

  # Check output from kepler.sh
  [[ "${lines[0]}" == "The base dir is"* ]]

  echo "Output from kepler.  Should only see this if something below fails ${lines[@]}"
  # Verify we didnt get a workflow failed txt file
  [ ! -e "$THE_TMP/$WORKFLOW_FAILED_TXT" ]
  
  # Check output of README.txt file
  [ -s "$THE_TMP/$README_TXT" ]
  run cat "$THE_TMP/$README_TXT"
  [ "$status" -eq 0 ]
  [ "${lines[4]}" == "Notify Email:  bob@bob.com" ]

} 
 
