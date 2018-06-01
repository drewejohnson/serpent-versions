#! /usr/bin/env bash
# Script to run all SERPENT files present in 
# their versioned directories
#
# Will be extended later to be more general
# and flexible

# Paths to serpent executables
CODE_ROOT=~/codes/serpent/v
sss2_1_28=$CODE_ROOT/sss2.1.28
sss2_1_29=$CODE_ROOT/sss2.1.29
sss2_1_30=$CODE_ROOT/sss2.1.30

SSS_VERS=(2.1.28 2.1.29 2.1.30)
SSS_EXE=($sss2_1_28 $sss2_1_29 $sss2_1_30)
NUM_VERS=${#SSS_VERS[*]}
NUM_EXE=${#SSS_EXE[*]}

# Arguments for running each file
# will be called as <serpent executable> ${RUN_ARGS} <input file>
RUN_ARGS="-omp 6"

# Quiet
# If equal to 1, then stdout will be written to
# a file for each version
QUIET=0
OUT_ARGS=
# Version-independent input file
# Name of the input file that exists in each
# directory
# files will be found with ${INPUT}<serpent version>
INPUT=i

versionInput() {
    echo $1/${INPUT}$1
}

setupDir() {
    # function to make a directory for a specific version
    # expects the version as the first argument
    mkdir -v $1
    INAME=$( versionInput $1 )
    echo Test file for serpent version $1 > $INAME
    echo "include \"base\" " >> $INAME
    echo Created input file $INAME
}

if [ "$NUM_VERS" -ne "$NUM_EXE" ]; then
    echo ${NUM_EXE} executables and ${NUM_VERS} versions not equal
    exit 1
fi

for index in ${!SSS_EXE[*]}; do
    thisX=${SSS_EXE[$index]}
    thisV=${SSS_VERS[$index]}
    echo ${thisV} ${thisX}
    if [ ! -x $thisX ]; then
        echo Executable for version ${thisV} not executable
        echo Path: ${thisX}
        exit 1
    fi
    if [ ! -d $thisV ]; then
        setupDir $thisV
    fi

    thisI=$( versionInput $thisV )
    if [ $QUIET -eq 1 ]; then
        echo Preparing to execute SERPENT $thisV
        OUT_ARGS=" > ${thisI}.log"
    fi
    $thisX $RUN_ARGS $thisI $OUT_ARGS
    if [ $QUIET -eq 1 ]; then
        echo "  done "
    fi
done
