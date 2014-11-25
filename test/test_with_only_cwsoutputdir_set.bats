#!/usr/bin/env bats

load test_helper

#
# Test CHM Workflow with no arguments
#
@test "chmworkflow.kar with only -CWS_outputdir set" {

  # verify $KEPLER_SH is in path if not skip this test
  skipIfKeplerNotInPath

  # Run kepler.sh with no other arguments
  run $KEPLER_SH -runwf -redirectgui $THE_TMP -CWS_outputdir $THE_TMP $CHM_WF 

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
  [ "${lines[0]}" == "simple.error.message=Unable to create CHM job" ] 
  [[ "${lines[1]}" == "detailed.error.message=Non zero exit code received from /home/churas/panfish/cws_vizwall/cws/bin/panfishCHM/createCHMJob.sh"* ]]

  # Check output of README.txt file
  [ -s "$THE_TMP/$README_TXT" ]
  run cat "$THE_TMP/$README_TXT"
  [ "$status" -eq 0 ]
  [ "${lines[0]}" == "CHM workflow" ]
  [ "${lines[1]}" == "Job Name:  jobname" ]
  [ "${lines[2]}" == "User:  user" ] 
  [ "${lines[3]}" == "Workflow Job Id:  jobid" ]
  [ "${lines[6]}" == "Create CHM Job Script:  /home/churas/panfish/cws_vizwall/cws/bin/panfishCHM/createCHMJob.sh" ]
  [ "${lines[7]}" == "Trained Model:  " ]
  [ "${lines[8]}" == "Input Images:  " ]
  [ "${lines[9]}" == "CHM options:  -T 122 -b 500x500 -o 20x20 -h" ] 
}

