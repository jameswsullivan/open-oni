#!/bin/bash

OPENONI_INSTALL_DIR="/opt/openoni"

cd ${OPENONI_INSTALL_DIR}
source ENV/bin/activate
echo "yes" | ./manage.py collectstatic -c

echo
exit

echo "Theme static files have been compiled. Restart container."