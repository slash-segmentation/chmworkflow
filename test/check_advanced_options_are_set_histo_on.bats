#!/usr/bin/env bats

load test_helper

#
#
@test "check advanced options are properly being passed histo on" {
  
  # verify $KEPLER_SH is in path if not skip this test
  skipIfKeplerNotInPath

  echo "1,,,/bin/echo" > "$THE_TMP/bin/createchm.tasks"
  # Run kepler.sh with
  run $KEPLER_SH -runwf -redirectgui $THE_TMP -histoCheckBox true -overlap 50x20 -tilesPerTask 233 -tileSize 24x5 -trainedModel /bar -inputImages /images -CWS_user johnny -CWS_jobname foo -CWS_jobid 43 -createChmJob $THE_TMP/bin/createchm -CWS_outputdir $THE_TMP $CHM_WF

  # Check exit code
  [ "$status" -eq 0 ]

  # Check output from kepler.sh
  [[ "${lines[0]}" == "The base dir is"* ]]

  echo "Output from kepler.  Should only see this if something below fails ${lines[@]}"

  # Check output of createchmtrainjob.out file
  [ -s "$THE_TMP/$CREATECHMJOB_OUT" ]

  run cat "$THE_TMP/$CREATECHMJOB_OUT"
  [ "$status" -eq 0 ]
  echo "Output from $CREATECHMJOB_OUT file.  Should only see this if something below fails :${lines[@]}:"
  cat "$THE_TMP/$README_TXT"
  echo "::${lines[0]}::"
  [ "${lines[0]}" == "createpretrained $THE_TMP/run -m /bar -i /images -T 233 -b 24x5 -o 50x20" ]

  # Check output of README.txt file
  [ -s "$THE_TMP/$README_TXT" ]
  run cat "$THE_TMP/$README_TXT"
  [ "$status" -eq 0 ]
  [ "${lines[0]}" == "CHM workflow" ]
  [ "${lines[1]}" == "Job Name:  foo" ]
  [ "${lines[2]}" == "User:  johnny" ]
  [ "${lines[3]}" == "Workflow Job Id:  43" ]
  [ "${lines[9]}" == "CHM options:  -T 233 -b 24x5 -o 50x20 " ]

  run egrep "Path selected:  /images$" "$THE_TMP/$README_TXT"
  [ "$status" -eq 0 ]

}

