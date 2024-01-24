#!/bin/bash
#
# entrypoint.sh copies the startup and management files into their proper
# locations, then fires off startup.sh

# Customization
OPENONI_SOURCE_DIR="/opt/openoni_source"
OPENONI_INSTALL_DIR="/opt/openoni"

FILE_CONTENTS_01="data
themes"

FILE_CONTENTS_02="data
onisite
themes
"

echo "Begin copying files ..."
if [ -z "$(ls -A "${OPENONI_INSTALL_DIR}")" ] || \
   [ "$(ls -A "${OPENONI_INSTALL_DIR}")" = "${FILE_CONTENTS_01}" ] || \
   [ "$(ls -A "${OPENONI_INSTALL_DIR}")" = "${FILE_CONTENTS_02}" ]; then
    echo "${OPENONI_INSTALL_DIR} does not exist or ${OPENONI_INSTALL_DIR} is empty."
    echo "Open ONI files will be copied from ${OPENONI_SOURCE_DIR} to ${OPENONI_INSTALL_DIR} ..."
    cp -a ${OPENONI_SOURCE_DIR}/* ${OPENONI_INSTALL_DIR}
    echo "Files copied from ${OPENONI_SOURCE_DIR} to ${OPENONI_INSTALL_DIR}"
    echo
    echo "Contents in \"${OPENONI_INSTALL_DIR}\":"
    ls -al ${OPENONI_INSTALL_DIR}
    echo
else
    echo "${OPENONI_INSTALL_DIR} already exists and not empty. Skipping the copy."
    echo "Contents in \"${OPENONI_INSTALL_DIR}\":"
    ls -al ${OPENONI_INSTALL_DIR}
    echo
fi

echo "Preparation work finished successfully. The \"web\" service can be safely started."

tail -f /dev/null