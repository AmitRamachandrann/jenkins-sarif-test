#!/bin/bash

export PATH="${PKG_BASE_DIR}/nodejs/bin":$PATH
tar zxf "${PKG_BASE_DIR}/noderest/noderest-1.0.0.tgz"
mv package/* package/.[^.]* .
cp -R "${PKG_BASE_DIR}/node_modules/node_modules" .
npm start
