#!/usr/bin/env bats

load test_helper

#
#
#
@test "Test where trainedmodel/run/runCHMTrainOut/trainedmodel has param.mat" {
  # verify $KEPLER_SH is in path if not skip this test
  skipIfKeplerNotInPath

  echo "1,,,/bin/echo" > "$THE_TMP/bin/createchm.tasks"
   mkdir -p "$THE_TMP/foo/run/runCHMTrainOut/trainedmodel"
  echo "hi" > "$THE_TMP/foo/run/runCHMTrainOut/trainedmodel/param.mat"
  # Run kepler.sh with
  run $KEPLER_SH -runwf -redirectgui $THE_TMP -trainedModel "$THE_TMP/foo" -inputImages "$THE_TMP" -CWS_user johnny -CWS_jobname foo -CWS_jobid 43 -createChmJob $THE_TMP/bin/createchm -CWS_outputdir $THE_TMP $CHM_WF

  # Check exit code
  [ "$status" -eq 0 ]

  # Check output from kepler.sh
  [[ "${lines[0]}" == "The base dir is"* ]]

  echo "Output from kepler.  Should only see this if something below fails ${lines[@]}"

  # How we check that the data subdirectory was detected
  run egrep "Path selected:  $THE_TMP$" "$THE_TMP/$README_TXT"
  [ "$status" -eq 0 ]

  # How we check that the trained model directory was left alone
  run egrep "Model selected:  $THE_TMP/foo/run/runCHMTrainOut/trainedmodel$" "$THE_TMP/$README_TXT"
  [ "$status" -eq 0 ]

}

