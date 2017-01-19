#!/bin/sh

#  updateMupdf.sh
#  PBBReaderForMac
#
#  Created by pengyucheng on 19/01/2017.
#  Copyright © 2017 recomend. All rights reserved.

pwd
mupdfDir="../mupdf"
mupdfRepo="https://server.local/git/mupdf.git"
if [ -d "$mupdfDir" ]; then
    echo 'mupdf目录已存在，开始拉取mupdf最新代码'
    cd ${mupdfDir}     # 进入mupdf目录
    git pull server master    # 安装包加入版本库
else
    echo 'mupdf目录不存在时,开始下载mupdf库'
    cd ../
pwd
    git clone $mupdfRepo
    if [ -d "mupdf" ]; then
        echo 'build 第三方依赖'
        cd mupdf/thirdparty/
        git submodule init
        git submodule update
    else
        echo 'clone mupdf 失败'
    fi
fi
