#!/usr/bin/env bats

load test_helper

#
# CHM workflow run Merge Tiles Fails
#
@test "chmworkflow.kar run Merge Tiles has non zero exit code" {

  # verify $KEPLER_SH is in path if not skip this test
  skipIfKeplerNotInPath

  /bin/mkdir -p "$THE_TMP/run"
  /bin/ln -s $THE_TMP/bin/command $THE_TMP/run/runCHMViaPanfish.sh
  /bin/ln -s $THE_TMP/bin/command $THE_TMP/run/runMergeTilesViaPanfish.sh

  echo "0,,," > "$THE_TMP/run/runCHMViaPanfish.sh.tasks"
  echo "1,,,/bin/echo" > "$THE_TMP/run/runMergeTilesViaPanfish.sh.tasks"

  echo "0,,," > "$THE_TMP/bin/createchm.tasks"

  # Run kepler.sh with no other arguments
  run $KEPLER_SH -runwf -redirectgui $THE_TMP -trainedModel /bar -inputImages /images -CWS_user johnny -CWS_jobname foo -CWS_jobid 43 -createChmJob $THE_TMP/bin/createchm -CWS_notifyemail 'bob@bob.com' -CWS_outputdir $THE_TMP $CHM_WF

  # Check exit code
  [ "$status" -eq 0 ]

  # Check output from kepler.sh
  [[ "${lines[0]}" == "The base dir is"* ]]

  echo "Output from kepler.  Should only see this if something below fails ${lines[@]}"
  # Verify we didnt get a workflow failed txt file
  [ -e "$THE_TMP/$WORKFLOW_FAILED_TXT" ]

  # Check output of workflow failed txt file
  run cat "$THE_TMP/$WORKFLOW_FAILED_TXT"
  [ "$status" -eq 0 ]
  [ "${lines[0]}" == "simple.error.message=Unable to run Merge Tiles Job" ]
  [[ "${lines[1]}" == "detailed.error.message=Non zero exit code received from "* ]]


  # Check output of createchmtrainjob.out file
  [ -s "$THE_TMP/$MERGETILES_OUT" ]

  run cat "$THE_TMP/$MERGETILES_OUT"
  [ "$status" -eq 0 ]
  echo "Output from $MERGETILES_OUT file.  Should only see this if something below fails :${lines[@]}:"
  # there is a -n flag, but it is eaten by the echo command so we just look for the login
  # its not perfect, but close enough
  [ "${lines[0]}" == "johnny_chm" ]



  # Check README.txt file exists
  [ -s "$THE_TMP/$README_TXT" ]
}


