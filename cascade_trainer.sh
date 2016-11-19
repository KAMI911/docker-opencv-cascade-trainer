#!/bin/bash

OPENCV_BIN="/usr/local/bin/"
NUM_THREADS="20"
MAX_WEAK="300"
NUM_STAGES="8"
MIN_HR="0.98"
MAX_FA="0.04"
VAL_BUFFER_SIZE="30000"
IDX_BUFFER_SIZE="30000"
IMG_WIDTH="32"
IMG_HEIGHT="32"

while [[ $# -gt 1 ]]
do
key="$1"

case $key in
    -t|--type)
    TYPE="$2"
    shift # past argument
    case ${TYPE} in
        pf|PF|peopleface|PEOPLEFACE)
        TYPE="people_face"
	POS_IMAGE_PATH="./people_face_frontal_positive/ ./people_face_side_positive/ ./people_positive/"
	NEG_IMAGE_PATH="./people_negative/"
        ;;
        pff|PFF|peoplefacefrontal|PEOPLEFACEFRONTAL)
        TYPE="people_face_frontal"
	POS_IMAGE_PATH="./people_face_frontal_positive/"
	NEG_IMAGE_PATH="./people_negative/"
        ;;
        pfs|PFS|peoplefaceside|PEOPLEFACEFRONTALSIDE)
        TYPE="people_face_side"
	POS_IMAGE_PATH="./people_face_side_positive/"
	NEG_IMAGE_PATH="./people_negative/"
        ;;
        pb|PB|peoplebody|PEOPLEBODY)
        TYPE="people_body"
	POS_IMAGE_PATH="./people_body_positive/"
	NEG_IMAGE_PATH="./people_negative/"
        ;;
        lp|LP|licenseplate|LICENSEPLATE)
        TYPE="license_plate"
	POS_IMAGE_PATH="./license_plate_frontal_positive/ ./license_plate_side_positive/ ./license_plate_positive/"
	POS_IMAGE_PATH="./license_plate_frontal_positive/ ./license_plate_side_positive/"
	NEG_IMAGE_PATH="./license_plate_negative/"
        ;;
        lpf|LPF|licenseplatefrontal|LICENSEPLATEFRONTAL)
        TYPE="license_plate_frontal"
	POS_IMAGE_PATH="./license_plate_frontal_positive/"
	NEG_IMAGE_PATH="./license_plate_negative/"
        ;;
        lps|LPS|licenseplateside|LICENSEPLATESIDE)
        TYPE="license_plate_side"
	POS_IMAGE_PATH="./license_plate_side_positive/"
	NEG_IMAGE_PATH="./license_plate_negative/"
        ;;
        *)
        TYPE="license_plate"
	POS_IMAGE_PATH="./license_plate_frontal_positive/ ./license_plate_side_positive/ ./license_plate_positive/" 
	NEG_IMAGE_PATH="./license_plate_negative/"
        ;;
    esac
    ;;
    -c|--classifier)
    CLASSIFIER="$2"
    shift # past argument
    case ${CLASSIFIER} in
        l|haar|HAAR)
        CLASSIFIER="haar"
        ;;
        l|lbp|LBP)
        CLASSIFIER="lbp"
        ;;
        *)
        CLASSIFIER="haar"
        ;;
    esac
    ;;
    -n|--numberpositives)
    NUM_POS="$2"
    shift # past argument
    ;;
    --default)
    TYPE="license_plate"
    CLASSIFIER="haar"
    NUM_POS="12000"
    POS_IMAGE_PATH="./license_plate_frontal_positive/ ./license_plate_side_positive/ ./license_plate_positive/"
    NEG_IMAGE_PATH="./license_plate_negative/"
    ;;
    *)
    TYPE="license_plate"
    CLASSIFIER="haar"
    NUM_POS="12000"
    POS_IMAGE_PATH="./license_plate_frontal_positive/ ./license_plate_side_positive/ ./license_plate_positive/"
    NEG_IMAGE_PATH="./license_plate_negative/"
    ;;
esac
shift # past argument or value
done

FIND_CMD=$(which find)
PERL_CMD=$(which perl)

TIME_STAMP=$(date "+%Y%m%d-%H%M%S")

CLASSIFIER_PATH="./classifiers/classifier_${TYPE}_${TIME_STAMP}"
WORKING_PATH="./working/${TYPE}_${TIME_STAMP}"
#POS_IMAGE_PATH="./license_plate_positive/"
#ABS_NEG_IMAGE_PATH="./license_plate_people_negative/" # This folder contains no license plates and people at all

POS_IMAGE_LIST="./${TYPE}_positives_${TIME_STAMP}.txt"
NEG_IMAGE_LIST="./${TYPE}_negatives_${TIME_STAMP}.txt"

echo "TYPE              = ${TYPE}"
echo "CLASSIFIER        = ${CLASSIFIER}"
echo "NUMBER_POSITIVES  = ${NUM_POS}"
echo "POS_IMAGE_PATH    = ${POS_IMAGE_PATH}"
echo "NEG_IMAGE_PATH    = ${NEG_IMAGE_PATH}"

mkdir -p ${CLASSIFIER_PATH}

SAMPLES="./${TYPE}_${TIME_STAMP}.vec"

echo "* List files"
${FIND_CMD} ${POS_IMAGE_PATH} -name '*.jpg' -exec identify -format '%i 1 0 0 %w %h' \{\} \; > ${POS_IMAGE_LIST}
#${FIND_CMD} ${ABS_NEG_IMAGE_PATH} -iname "*.jpg" > ${NEG_IMAGE_LIST}
${FIND_CMD} ${NEG_IMAGE_PATH} -iname "*.jpg" >> ${NEG_IMAGE_LIST} # Never overwrite already listed negative images

NUM_POS_M=`cat ${POS_IMAGE_LIST} | wc -l`
NUM_NEG=`cat ${NEG_IMAGE_LIST} | wc -l`

echo "* Creating samples"
CMD_LINE="${OPENCV_BIN}/opencv_createsamples -num ${NUM_POS_M} -info ${POS_IMAGE_LIST} -vec ${SAMPLES} -bgcolor 0 -bgthresh 0 -maxxangle 1.1 -maxyangle 1.1 maxzangle 0.5 -maxidev 40 -w ${IMG_WIDTH} -h ${IMG_HEIGHT}"
echo "${CMD_LINE}" > ${CLASSIFIER_PATH}/commnd_line.txt
${CMD_LINE}

echo "* Creating ${TYPE} ${CLASSIFIER} classifier"
CMD_LINE="${OPENCV_BIN}opencv_traincascade -data ${CLASSIFIER_PATH} -vec ${SAMPLES} -bg ${NEG_IMAGE_LIST} -numStages ${NUM_STAGES} -minHitRate ${MIN_HR} -maxFalseAlarmRate ${MAX_FA} -maxWeakCount ${MAX_WEAK} -numPos ${NUM_POS} -numNeg ${NUM_NEG} -featureType ${CLASSIFIER} -mode ALL -numThreads ${NUM_THREADS} -precalcValBufSize ${VAL_BUFFER_SIZE} -precalcIdxBufSize ${IDX_BUFFER_SIZE}  -w ${IMG_WIDTH} -h ${IMG_HEIGHT}"
echo "${CMD_LINE}" >> ${CLASSIFIER_PATH}/commnd_line.txt
${CMD_LINE} | tee -a 2>&1 ${CLASSIFIER_PATH}/process.log
