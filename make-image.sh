#!/bin/bash

cd  /eir_images/L2/

unset CURRENT_MOUNT_POINT
function bye {
    [ -n "$CURRENT_MOUNT_POINT" ] && sudo umount $CURRENT_MOUNT_POINT
    EXITCODE=$1
    shift
    test $# -gt 0 && echo $*
    exit $EXITCODE
}

function get_vnfc {
    case $1 in
        RDBMS) echo REPLACE_VNFC_RDBMS;;
        MGMS) echo REPLACE_VNFC_MGMS;;
        CDR) echo REPLACE_VNFC_CDR;;
        TSLEE) echo REPLACE_VNFC_TSLEE;;
        GTW) echo REPLACE_VNFC_GTW;;
        DRA) echo REPLACE_VNFC_DRA;;
        SIPP) echo SIPP;;
	IMDB) echo REPLACE_VNFC_IMDB;;
	MS) echo MS-FE;;
	KMS) echo KMS;;
	KMS-CL) echo KMS-CL;;
	EIR-PMS) echo EIR-PMS;;
	EIR-BE) echo EIR-BE;;
    esac
}

function get_os {
    case $1 in
        RDBMS) echo CentOS_7.9;;
        MGMS) echo CentOS_7.9;;
        CDR) echo CentOS_7.9;;
        TSLEE) echo CentOS_7.9;;
        GTW) echo CentOS_7.9;;
        DRA) echo CentOS_7.9;;
        SIPP) echo CentOS_7.9;;
	IMDB) echo CentOS_7.9;;
	MS) echo CentOS_7.9;;
	KMS) echo CentOS_7.9;;
	KMS-CL) echo CentOS_7.9;;
        EIR-PMS) echo CentOS_7.9;;
        EIR-BE) echo CentOS_7.9;;
    esac
}

#set -x
HDIR=/ftp-comviva/10.232.15.132/volumeF/base/CentOS-7.9/
DIR=$(realpath $(dirname $0))
cd "$DIR" || bye 1

[ $# -lt 1 ] && bye "USAGE: make-image.sh [all|<image list>]"

if [ "$1" == all ]
then
    for FOLDER in *
    do
        [ -d $FOLDER ] || continue
        [ -f $FOLDER/.make-image ] || continue
        IMAGE_DIRS="$IMAGE_DIRS $FOLDER"
    done
else
    for FOLDER in $*
    do
        [ -d $FOLDER ] || continue
        [ -f $FOLDER/.make-image ] || continue
        IMAGE_DIRS="$IMAGE_DIRS $FOLDER"
    done
fi

for FOLDER in $IMAGE_DIRS
do
    [ -d $FOLDER ] || continue
    [ -f $FOLDER/.make-image ] || continue
    if [ -x $FOLDER/prepare.sh ]
    then
        ./$FOLDER/prepare.sh || bye 1
    fi
    OS=$(get_os $FOLDER)
    IMAGE_NAME="Comviva_L2_${FOLDER}_${OS}"

    sudo cp base-$FOLDER-img.qcow2 $FOLDER/$IMAGE_NAME.qcow2 || bye 1

    sudo mkdir -p /mnt/$FOLDER || bye 1
  #  sudo guestmount -i -a $FOLDER/$IMAGE_NAME.qcow2 /mnt/$FOLDER || bye 1
  #### NEW IMAGE MOUNT 
  modprobe nbd max_part=8
qemu-nbd --connect=/dev/nbd0 /eir_images/Comviva_L2_MGMS_CentOS_7.9.qcow2
mount /dev/nbd0p1 /mnt/$FOLDER

    export CURRENT_MOUNT_POINT=/mnt/$FOLDER

    # ##################################################################################
    # instalo mgms-agent enla imagen
    # ##################################################################################
    if [ $FOLDER != "MGMS" ]
    then
    sudo mkdir -p /mnt/$FOLDER/mcom/mgms || bye 1
    #( cd mgms ; tar --create --exclude-vcs --to-stdout .) | sudo bash -c "cd /mnt/$FOLDER/mcom/mgms ; tar --extract --verbose --file -" || bye 1
    sudo cp -p --recursive mgms /mnt/$FOLDER/mcom/ || bye 1
    sudo mkdir -p /mnt/$FOLDER/mcom/mgms/admin/data/ || bye 1
    sudo rm -f /mnt/$FOLDER/etc/systemd/system/mgms.service
    sudo cat >/tmp/mgms.service <<EOF
[Unit]
Description=Mahindra Comviva MGMS Front End
After=network.target
After=syslog.target

[Install]
WantedBy=multi-user.target

[Service]
Type=forking
ExecStart=/mcom/mgms/admin/bin/start-admin-mgms.sh
TimeoutStartSec=10
ExecStop=/mcom/mgms/admin/bin/kill-admin-mgms.sh
TimeoutStopSec=300
PIDFile=/mcom/mgms/admin/data/mgms.pid
Restart=always
RestartSec=60
User=mgms
Environment=JAVA_HOME=/usr/java/jdk-15.0.2/
EOF
    [ $? -eq 0 ] || bye 1
    sudo cp /tmp/mgms.service /mnt/$FOLDER/etc/systemd/system/mgms.service || bye 1
    else
	echo "contenido de mgms"
	sudo mkdir -p /mnt/$FOLDER/mcom/mgms || bye 1
	sudo cp -p --recursive mgms /mnt/$FOLDER/mcom/ || bye 1
        #######################################################################
        ## Contruct Centralized Configuration ZIP
        #######################################################################

        #
        # Part of the ZIP is centralized in VCC_OFFLINE_1.zip
        #
        rm -f MGMS/tree/mcom/mgms/cca/conf/*.csv || bye 1
		cp -f MGMS/VCC_EXT_ENDPOINTS.csv MGMS/tree/mcom/mgms/cca/conf/ || bye 1
		cp -f MGMS/VCC_ENDPOINTS_ROUTING.csv MGMS/tree/mcom/mgms/cca/conf/ || bye 1
        cd MGMS/tree/mcom/mgms/cca/conf || bye 1
        #unzip VCC_OFFLINE_1.zip || bye 1
        cd - || bye 1
        cp MGMS/tree/mcom/mgms/cca/conf/*.csv MGMS/tree/mcom/bcfg/.vccinstall/  || bye 1

        #
        # Make VCC_EXT_ENDPOINTS_TYPES.csv from */*.jsonschema
        #
        find . -type f -name '*.jsonschema' | xargs dos2unix -q
        rm -f /tmp/VCC_EXT_ENDPOINTS_TYPES.csv || bye 1
        for FILE in */*.jsonschema
        do
            VNFC=$(get_vnfc $(dirname $FILE))
            ENDPOINT_TYPE=$(basename $FILE | sed 's/\.jsonschema$//')
            echo -n "$ENDPOINT_TYPE,\"" >>/tmp/VCC_EXT_ENDPOINTS_TYPES.csv || bye 1
            sed 's/"/""/g' $FILE >>/tmp/VCC_EXT_ENDPOINTS_TYPES.csv || bye 1
            echo '",true' >>/tmp/VCC_EXT_ENDPOINTS_TYPES.csv || bye 1
        done
        cp /tmp/VCC_EXT_ENDPOINTS_TYPES.csv MGMS/tree/mcom/bcfg/.vccinstall/VCC_EXT_ENDPOINTS_TYPES.csv || bye 1
	cp /tmp/VCC_EXT_ENDPOINTS_TYPES.csv $HDIR/tmp/
        mv /tmp/VCC_EXT_ENDPOINTS_TYPES.csv MGMS/tree/mcom/mgms/cca/conf/VCC_EXT_ENDPOINTS_TYPES.csv || bye 1
        #
        # Make VCC_TEMPLATES.csv from */*.ftl
        #
        find . -type f -name '*.schema' -o -name '*.tags' -o -name '*.translation' -o -name '*.ftl' | xargs dos2unix -q
        rm -f /tmp/VCC_TEMPLATES.csv || bye 1
	rm -f /tmp/VCC_TEMPLATES2.csv || bye 1
        for FILE in */*.ftl
        do
            VNFC=$(get_vnfc $(dirname $FILE))
            MODULE_NAME=$(basename $FILE | sed 's/\.ftl$//')
            if basename $FILE | grep '^.*-v[A-Za-z.0-9-][A-Za-z.0-9_-]*\.ftl' >/dev/null
            then
                MODULE_VERSION=$(basename $FILE | sed 's/^.*-v\([A-Za-z.0-9_-][A-Za-z.0-9_-]*\)\.ftl$/\1/')
                MODULE_NAME=$(basename $FILE | sed 's/^\(.*\)-v[A-Za-z.0-9_-][A-Za-z.0-9_-]*\.ftl$/\1/')
            else
                MODULE_VERSION="0"
            fi
            echo -n "TSLEE,$VNFC,$MODULE_NAME,$MODULE_VERSION,\"" >>/tmp/VCC_TEMPLATES.csv || bye 1
            printf %s "$(cat $FILE)" > /tmp/eolftl.csv
            sed 's/"/""/g' /tmp/eolftl.csv >>/tmp/VCC_TEMPLATES.csv || bye 1
            echo '"' >>/tmp/VCC_TEMPLATES.csv || bye 1
            echo -n "TSLEE,$VNFC,$MODULE_NAME,$MODULE_VERSION,\"" >>/tmp/VCC_TEMPLATES2.csv || bye 1
            printf %s "$(cat $FILE)" > /tmp/eolftl2.csv
            sed 's/"/""/g' /tmp/eolftl2.csv >>/tmp/VCC_TEMPLATES2.csv || bye 1
            echo '",true' >>/tmp/VCC_TEMPLATES2.csv || bye 1
        done
	cp /tmp/VCC_TEMPLATES.csv $HDIR/tmp/
	cp /tmp/VCC_TEMPLATES2.csv $HDIR/tmp/
        mv /tmp/VCC_TEMPLATES.csv MGMS/tree/mcom/mgms/cca/conf/VCC_TEMPLATES.csv || bye 1
        mv /tmp/VCC_TEMPLATES2.csv MGMS/tree/mcom/bcfg/.vccinstall/VCC_TEMPLATES.csv || bye 1

        #
        # Make VCC_VARIABLES.csv from */*.variables
        #
        sed '/^[ 	]*$/d' */*.variables >MGMS/tree/mcom/mgms/cca/conf/VCC_VARIABLES.csv || bye 1
        sed '/^[ 	]*$/d' */*.variables >MGMS/tree/mcom/bcfg/.vccinstall/VCC_VARIABLES.csv || bye 1
	cp MGMS/tree/mcom/mgms/cca/conf/VCC_VARIABLES.csv $HDIR/tmp/
        #
        # Make VCC_DEF_TEMPLATES.csv from */*.schema, */*.translation and */*.tags
        #
        rm -f /tmp/VCC_DEF_TEMPLATES.csv || bye 1
        for FILE in */*.schema
        do
            DIR=$(dirname $FILE)
            VNFC=$(get_vnfc $DIR)
            MODULE_NAME=$(basename $FILE | sed 's/\.schema$//')
			if basename $FILE | grep '^.*-v[A-Za-z.0-9-][A-Za-z.0-9_-]*\.schema' >/dev/null
            then
                MODULE_VERSION=$(basename $FILE | sed 's/^.*-v\([A-Za-z.0-9_-][A-Za-z.0-9_-]*\)\.schema$/\1/')
                MODULE_NAME=$(basename $FILE | sed 's/^\(.*\)-v[A-Za-z.0-9_-][A-Za-z.0-9_-]*\.schema$/\1/')
                FTLFILE="$DIR/$MODULE_NAME-v$MODULE_VERSION.ftl"
                TRANSLATIONFILE="$DIR/$MODULE_NAME-v$MODULE_VERSION.translation"
                TAGSFILE="$DIR/$MODULE_NAME-v$MODULE_VERSION.tags"
            else
                MODULE_VERSION="0"
                FTLFILE="$DIR/$MODULE_NAME.ftl"
                TRANSLATIONFILE="$DIR/$MODULE_NAME.translation"
                TAGSFILE="$DIR/$MODULE_NAME.tags"
            fi			
            echo -n "TSLEE,$VNFC,$MODULE_NAME,$MODULE_VERSION,\"" >>/tmp/VCC_DEF_TEMPLATES.csv || bye 1
            sed 's/"/""/g' $FILE >>/tmp/VCC_DEF_TEMPLATES.csv || bye 1
            echo -n '","' >>/tmp/VCC_DEF_TEMPLATES.csv || bye 1
            sed 's/"/""/g' "$FTLFILE" >>/tmp/VCC_DEF_TEMPLATES.csv || bye 1
            echo -n '","' >>/tmp/VCC_DEF_TEMPLATES.csv || bye 1
            if [ -f "$TRANSLATIONFILE" ]
            then
                sed 's/"/""/g' "$TRANSLATIONFILE" >>/tmp/VCC_DEF_TEMPLATES.csv || bye 1
            else
                echo -n '""""' >>/tmp/VCC_DEF_TEMPLATES.csv || bye 1
            fi
            echo -n '","' >>/tmp/VCC_DEF_TEMPLATES.csv || bye 1
            if [ -f "$TAGSFILE" ]
            then
                sed 's/"/""/g' "$TAGSFILE" >>/tmp/VCC_DEF_TEMPLATES.csv || bye 1
            else
                echo -n '""{}""' >>/tmp/VCC_DEF_TEMPLATES.csv || bye 1
            fi
            echo '",true' >>/tmp/VCC_DEF_TEMPLATES.csv || bye 1
        done
	cp /tmp/VCC_DEF_TEMPLATES.csv $HDIR/tmp/
        cp /tmp/VCC_DEF_TEMPLATES.csv MGMS/tree/mcom/bcfg/.vccinstall/VCC_DEF_TEMPLATES.csv || bye 1
        mv /tmp/VCC_DEF_TEMPLATES.csv MGMS/tree/mcom/mgms/cca/conf/VCC_DEF_TEMPLATES.csv || bye 1

        #
        # Finally make VCC_OFFLINE_1.zip
        #
        cd MGMS/tree/mcom/mgms/cca/conf || bye 1
        rm -f VCC_OFFLINE_1.zip || bye 1
        zip -q VCC_OFFLINE_1.zip *.csv || bye 1
        rm -f *.csv || bye 1
        cd - || bye 1
        cd MGMS/tree/mcom/bcfg/.vccinstall/ || bye 1
        rm -f VCC_OFFLINE_1.zip || bye 1
        zip -q VCC_OFFLINE_1.zip *.csv || bye 1
        rm -f *.csv || bye 1
        cd - || bye 1
    fi

    sudo cat >/tmp/cpu-mgms-cca-0.conf <<EOF
PRODUCT="REPLACE_VNFI"
PRODUCT_INSTANCE="REPLACE_VNFC_GROUP"
COMPONENT="REPLACE_VNFC"
COMPONENT_INSTANCE="REPLACE_VNFC-REPLACE_INSTANCE_NUMBER"
MODULE="mgms-cca"
MODULE_INSTANCE=0
REGEX=^[^:]*:mgms:[^:]*:[^:]*:[^:]*:.*ComponentConfigAgent.*$
EOF
    [ $? -eq 0 ] || bye 1
    sudo mkdir -p /mnt/$FOLDER/mcom/mgms/mgms-agent/conf/component-cpu-conf || bye 1
    sudo mv -f /tmp/cpu-mgms-cca-0.conf /mnt/$FOLDER/mcom/mgms/mgms-agent/conf/component-cpu-conf/cpu-mgms-cca-0.conf || bye 1

    sudo cat >/tmp/cpu-mgms-agent-0.conf <<EOF
PRODUCT="REPLACE_VNFI"
PRODUCT_INSTANCE="REPLACE_VNFC_GROUP"
COMPONENT="REPLACE_VNFC"
COMPONENT_INSTANCE="REPLACE_VNFC-REPLACE_INSTANCE_NUMBER"
MODULE="mgms-agent"
MODULE_INSTANCE=0
REGEX=^[^:]*:mgms:[^:]*:[^:]*:[^:]*:.*MgmsAgent.*$
EOF
    [ $? -eq 0 ] || bye 1
    sudo mv -f /tmp/cpu-mgms-agent-0.conf /mnt/$FOLDER/mcom/mgms/mgms-agent/conf/component-cpu-conf/cpu-mgms-agent-0.conf || bye 1

    sudo cat >/tmp/mem-mgms-cca-0.conf <<EOF
PRODUCT="REPLACE_VNFI"
PRODUCT_INSTANCE="REPLACE_VNFC_GROUP"
COMPONENT="REPLACE_VNFC"
COMPONENT_INSTANCE="REPLACE_VNFC-REPLACE_INSTANCE_NUMBER"
MODULE="mgms-cca"
MODULE_INSTANCE=0
REGEX=^[^:]*:mgms:[^:]*:[^:]*:[^:]*:.*ComponentConfigAgent.*$
EOF
    [ $? -eq 0 ] || bye 1
    sudo mkdir -p /mnt/$FOLDER/mcom/mgms/mgms-agent/conf/component-mem-conf || bye 1
    sudo mv -f /tmp/mem-mgms-cca-0.conf /mnt/$FOLDER/mcom/mgms/mgms-agent/conf/component-mem-conf/mem-mgms-cca-0.conf || bye 1

    sudo cat >/tmp/mem-mgms-agent-0.conf <<EOF
PRODUCT="REPLACE_VNFI"
PRODUCT_INSTANCE="REPLACE_VNFC_GROUP"
COMPONENT="REPLACE_VNFC"
COMPONENT_INSTANCE="REPLACE_VNFC-REPLACE_INSTANCE_NUMBER"
MODULE="mgms-agent"
MODULE_INSTANCE=0
REGEX=^[^:]*:mgms:[^:]*:[^:]*:[^:]*:.*MgmsAgent.*$
EOF
    [ $? -eq 0 ] || bye 1
    sudo mv -f /tmp/mem-mgms-agent-0.conf /mnt/$FOLDER/mcom/mgms/mgms-agent/conf/component-mem-conf/mem-mgms-agent-0.conf || bye 1

    # ##################################################################################
    # instalo cca (Component Config Agent) 
    # ##################################################################################
    find cca/ -type f -name '*~' | xargs rm -f
    sudo mkdir -p /mnt/$FOLDER/mcom/mgms/cca/conf || bye 1
    #tar --create --to-stdout --exclude-vcs cca | sudo bash -c "cd /mnt/$FOLDER/mcom/mgms/ ; tar --extract --verbose --file -" || bye 1
    sudo cp -p --recursive cca /mnt/$FOLDER/mcom/mgms/ || bye 1
    sudo rm -f /mnt/$FOLDER/mcom/mgms/cca/conf/cca.xml
    sudo ./replace-templates.pl $FOLDER/modules.json cca/conf/cca.xml /mnt/$FOLDER/mcom/mgms/cca/conf/cca.xml || bye 1
    sudo rm -f /mnt/$FOLDER/etc/systemd/system/system.cca.service
    sudo cat >/tmp/cca.service <<EOF
[Unit]
Description=Mahindra Comviva Component Config Agent (CCA)
After=network.target
After=syslog.target

[Install]
WantedBy=multi-user.target

[Service]
Type=forking
ExecStart=/mcom/mgms/cca/bin/cca.sh
TimeoutStartSec=10
ExecStop=/mcom/mgms/cca/bin/kill-cca.sh
TimeoutStopSec=300
PIDFile=/mcom/mgms/cca/bin/cca.pid
Restart=always
RestartSec=5
User=mgms
Environment=JAVA_HOME=/usr/java/jdk-15.0.2/
EOF
    [ $? -eq 0 ] || bye 1
    sudo mv -f /tmp/cca.service /mnt/$FOLDER/etc/systemd/system/cca.service || bye 1

    # ##################################################################################
    # Copio el contenido del tree en la imagen
    # ##################################################################################
    #( cd $FOLDER/tree; tar --create --to-stdout --exclude-vcs . ) | sudo bash -c "cd /mnt/$FOLDER ; sudo tar --extract --verbose --file - " || bye 1
    echo "antes de copiar el tree"
    sudo cp -p --recursive $FOLDER/tree/* /mnt/$FOLDER/ || bye 1
    echo "despues de copiar el tree"
    # ##################################################################################
    # Muestro como quedaron los binarios en la imagen
    # ##################################################################################
    #sudo find /mnt/$FOLDER/mcom

    # ##################################################################################
    # Termino de preparar la imagen
    # ##################################################################################
  #  sudo umount /mnt/$FOLDER
   umount /mnt/$FOLDER
	 qemu-nbd --disconnect /dev/nbd0
	rmmod nbd

    unset CURRENT_MOUNT_POINT
    sudo virt-sysprep -a $FOLDER/$IMAGE_NAME.qcow2 || bye 1
    echo MOVE IMAGE to  $FOLDER/$IMAGE_NAME.qcow2
    sudo mv $FOLDER/$IMAGE_NAME.qcow2 $FOLDER/$IMAGE_NAME.qcow2- || bye 1
    sudo qemu-img convert -c -O qcow2 $FOLDER/$IMAGE_NAME.qcow2- $FOLDER/$IMAGE_NAME.qcow2 || bye 1
    sudo cp  $FOLDER/$IMAGE_NAME.qcow2 /    /ftp-comviva/IMAGES/UBU || bye 1
    sudo rm -f $FOLDER/$IMAGE_NAME.qcow2- || bye 1
#    md5sum $FOLDER/$IMAGE_NAME.qcow2 | sed 's/ .*//' >$FOLDER/$IMAGE_NAME.qcow2.md5
done

[ $? -eq 0 ] && echo "Imagens Criadas Exito"
