#!/bin/bash
##########################################################################
function getSize()
{
    if [ -f $1 ]; then
        echo $(expr $(stat -c %s $1) / 1048576)MB
    else
        echo "N/A"
    fi;
}

CLR_RST=$(tput sgr0)                        ## reset flag
CLR_RED=$CLR_RST$(tput setaf 1)             #  red, plain
CLR_GRN=$CLR_RST$(tput setaf 2)             #  green, plain
CLR_YLW=$CLR_RST$(tput setaf 3)             #  yellow, plain
CLR_BLU=$CLR_RST$(tput setaf 4)             #  blue, plain
CLR_PPL=$CLR_RST$(tput setaf 5)             #  purple,plain
CLR_CYA=$CLR_RST$(tput setaf 6)             #  cyan, plain
CLR_BLD=$(tput bold)                        ## bold flag
CLR_BLD_RED=$CLR_RST$CLR_BLD$(tput setaf 1) #  red, bold
CLR_BLD_GRN=$CLR_RST$CLR_BLD$(tput setaf 2) #  green, bold
CLR_BLD_YLW=$CLR_RST$CLR_BLD$(tput setaf 3) #  yellow, bold
CLR_BLD_BLU=$CLR_RST$CLR_BLD$(tput setaf 4) #  blue, bold
CLR_BLD_PPL=$CLR_RST$CLR_BLD$(tput setaf 5) #  purple, bold
CLR_BLD_CYA=$CLR_RST$CLR_BLD$(tput setaf 6) #  cyan, bold

# Variables
BUILD_DATE=$(date +"%m%d%Y")
BUILD_TIME=$(date "+%H%M%S")
EKRP_VENDOR=vendor/ekrp
MAGISKBOOT=$EKRP_VENDOR/extras/magiskboot
EKRP_OUT=$OUT
EKRP_WORK_DIR=$OUT/zip
EKRP_META_DATA_DIR=$OUT/zip/META-INF
RECOVERY_IMG=$OUT/recovery.img
EKRP_DEVICE=$(cut -d'_' -f2-3 <<<$TARGET_PRODUCT)
EKRP_VERSION="1.0"
EKRP_TYPE="HOMEMADE"

ZIP_NAME=EKRP-$EKRP_VERSION-$EKRP_TYPE-$EKRP_DEVICE-$BUILD_DATE-$BUILD_TIME

if [ -d "$EKRP_META_DATA_DIR" ]; then
        rm -rf "$EKRP_META_DATA_DIR"
        rm -rf "$EKRP_OUT"/*.zip
fi
mkdir -p "$EKRP_WORK_DIR/addons"
cp -a $EKRP_VENDOR/addons/. $EKRP_WORK_DIR/addons
mkdir -p "$EKRP_WORK_DIR/META-INF/com/google/android"

#create updater-script before packing ZIP..
  cat > "$EKRP_WORK_DIR/META-INF/com/google/android/updater-script" <<EOF
show_progress(1.000000, 0);
ui_print("             ");
ui_print("Eureka Recovery Project                  ");
ui_print("[EKRP]: $EKRP_VERSION    ");
ui_print("[DEVICE]: $EKRP_DEVICE");
delete_recursive("/sdcard/EKRP");
package_extract_dir("addons", "/sdcard/EKRP/addons");
set_progress(0.500000);
package_extract_file("recovery.img", "/dev/block/by-name/recovery");
set_progress(0.700000);
ui_print("                                                  ");
ui_print("Eureka Recovery Install done!");
set_progress(1.000000);
EOF
  cp -R "$EKRP_VENDOR/updater/update-binary" "$EKRP_WORK_DIR/META-INF/com/google/android/update-binary"
  cp "$RECOVERY_IMG" "$EKRP_WORK_DIR"
  cp "$MAGISKBOOT"  "$EKRP_WORK_DIR"

echo -e ""
cd $EKRP_WORK_DIR
zip -r ${ZIP_NAME}.zip *
mv $EKRP_WORK_DIR/*.zip $EKRP_OUT

ZIPFILE=$EKRP_OUT/$ZIP_NAME.zip
ZIPFILE_SHA1=$(sha1sum -b $ZIPFILE)
ZIPFILE_MD5=$(echo -n $ZIPFILE | md5sum | cut -d '-' -f1)

#Build Done Result..
echo ""
echo "$CLR_CYA|${CLR_BLD}############Eureka Recovery Project${CLR_RST}$CLR_CYA############$CLR_RST"
echo "|${CLR_BLD_YLW}Device -${CLR_RST} $EKRP_DEVICE"
echo "|${CLR_BLD_YLW}Version -${CLR_RST} $EKRP_VERSION"
echo "$CLR_CYA|${CLR_BLD}----------File Info${CLR_RST}$CLR_CYA----------$CLR_RST"
echo "|${CLR_BLD_YLW}Recovery ZIP -${CLR_RST} $ZIP_NAME.zip"
echo "|${CLR_BLD_YLW}File Size -${CLR_RST} $(getSize $ZIPFILE)"
echo "|${CLR_BLD_YLW}SHA1 -${CLR_RST} ${ZIPFILE_SHA1:0:40}"
echo "|${CLR_BLD_YLW}MD5 -${CLR_RST} ${ZIPFILE_MD5}"
echo "$CLR_CYA############${CLR_BLD}BUILD DONE!############${CLR_RST}"
echo ""