#!/usr/bin/env bats

setup() {
  CHM_WF="${BATS_TEST_DIRNAME}/../src/chmworkflow.kar"
  KEPLER_SH="kepler.sh"
  WORKFLOW_FAILED_TXT="WORKFLOW.FAILED.txt"
  CREATECHMJOB_OUT="createchmjob.out"
  MERGETILES_OUT="mergetiles.out"
  RUNCHM_OUT="run.out"
  README_TXT="README.txt"
  export THE_TMP="${BATS_TMPDIR}/"`uuidgen`
  /bin/mkdir -p $THE_TMP
  /bin/cp -a "${BATS_TEST_DIRNAME}/bin" "${THE_TMP}/."
  /bin/rm -rf ~/.kepler

}

teardown() {
  #echo "Removing $THE_TMP" 1>&2
  /bin/rm -rf $THE_TMP
}

#
# Verify $KEPLER_SH is in path if not skip whatever test we are in
#
skipIfKeplerNotInPath() {

  # verify $KEPLER_SH is in path if not skip this test
  run which $KEPLER_SH

  if [ "$status" -eq 1 ] ; then
    skip "$KEPLER_SH is not in path"
  fi

}

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

  # Check output of createchmtrainjob.out file
  [ -s "$THE_TMP/$CREATECHMJOB_OUT" ]

  run cat "$THE_TMP/$CREATECHMJOB_OUT"
  [ "$status" -eq 0 ] 
  [[ "${lines[0]}" == *"No such file or directory"* ]]

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

#
# CHM workflow where create chm job has non zero
# exit code
#
@test "chmworkflow.kar where create chm job has nonzero exit code" {
  
  # verify $KEPLER_SH is in path if not skip this test
  skipIfKeplerNotInPath

  echo "1,,,/bin/echo" > "$THE_TMP/bin/createchm.tasks"
  # Run kepler.sh with
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
  [ "${lines[0]}" == "simple.error.message=Unable to create CHM job" ]
  [[ "${lines[1]}" == "detailed.error.message=Non zero exit code received from "* ]]

  # Check output of createchmtrainjob.out file
  [ -s "$THE_TMP/$CREATECHMJOB_OUT" ]

  run cat "$THE_TMP/$CREATECHMJOB_OUT"
  [ "$status" -eq 0 ]
  echo "Output from $CREATECHMJOB_OUT file.  Should only see this if something below fails :${lines[@]}:"
  [ "${lines[0]}" == "createpretrained $THE_TMP/run -m /bar/run/runCHMTrainOut/trainedmodel -i /images -T 122 -b 500x500 -o 20x20 -h" ]

  # Check output of README.txt file
  [ -s "$THE_TMP/$README_TXT" ]
  run cat "$THE_TMP/$README_TXT"
  [ "$status" -eq 0 ]
  [ "${lines[0]}" == "CHM workflow" ]
  [ "${lines[1]}" == "Job Name:  foo" ]
  [ "${lines[2]}" == "User:  johnny" ]
  [ "${lines[3]}" == "Workflow Job Id:  43" ]
  [ "${lines[9]}" == "CHM options:  -T 122 -b 500x500 -o 20x20 -h" ]

}

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
 
