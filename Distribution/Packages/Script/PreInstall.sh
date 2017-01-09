#!/bin/sh

#  PreInstall.sh
#  PBBReaderForMac
#
#  Created by pengyucheng on 16/9/6.
#  Copyright © 2016年 recomend. All rights reserved.

#timeDir=Time.new.strftime("%Y%m%d")
timeDir=`date '+%Y%m%d'`
echo "------------------------${timeDir}=============="
pwd
#拷贝

APPName="PBBReader"
ProductPath="$TARGET_BUILD_DIR/${APPName}.app"
Distribution="$PROJECT_DIR/Distribution"
ImportSVN="$Distribution/ImportSVN"
SVNURL="https://192.168.85.6/svn/Installation_Package/mac%20os"
#重命名导入SVN
versionNumber=$(/usr/libexec/PlistBuddy -c "Print CFBundleShortVersionString" "$INFOPLIST_FILE")
buildNumber=$(/usr/libexec/PlistBuddy -c "Print CFBundleVersion" "$INFOPLIST_FILE")
BundleName=$(/usr/libexec/PlistBuddy -c "Print MakeInstallerName" "$INFOPLIST_FILE")
ProductName="$BundleName $versionNumber.${buildNumber}α"

#上传时，先删除SVN目录
rm -rf ${ImportSVN}
pwd
if [ -d "$ImportSVN" ]; then
echo 'svn目录已存在'
else
echo '新建svn目录'
mkdir $ImportSVN
fi
echo "cp -rf $ProductPath ${ImportSVN}/${APPName}.app"
cp -rf $ProductPath "${ImportSVN}/${APPName}.app"

#下载安装
Perfect="/Applications/Packages.app"
# -d: 判断目录是否存在  -f: 判断文件是否存在
if [ -d "$Perfect" ]; then
echo 'Packages.app已安装'
else
echo '下载Packages.dmg程序...'
curl -o Packages.dmg http://s.sudre.free.fr/Software/files/Packages.dmg
#安装Packages.app
MOUNTDIR=$(echo `hdiutil mount Packages.dmg | tail -1 \
| awk '{$1=$2=""; print $0}'` | xargs -0 echo) \
&& sudo installer -pkg "${MOUNTDIR}/"*.pkg -target /
rm -rf "Packages.dmg"
#卸载操作： ${MOUNTDIR}值是/Volumes/Packages\ 1.1.3\ 1
#sudo sh ${MOUNTDIR}/Extras/uninstall.sh
fi
#打开程序
#open $PROJECT_DIR/Distribution/PBBReaderForOSX.pkgproj
#开始制作安装文件
if [ -d "${ImportSVN}/${APPName}.app" ]; then
echo "开始制作安装文件..."
/usr/local/bin/packagesbuild -vF $Distribution/ -t $Distribution/ $Distribution/PBBReaderForOSX.pkgproj
else
 echo "app源文件不存在，无法制作pkg安装包"
fi

#安装packages并生成pkg安装包之后删除.app文件,目的是不让在上传SVN时，误上传文件
rm -rf "${ImportSVN}/${APPName}.app"

##########导入svn============
#读取releaseNote.md更新信息
releaseNote=$(cat ${Distribution}/releaseNote.md)
#echo "svn import "${ImportSVN}" ${SVNURL} -m "${releaseNote}"
export LC_CTYPE="zh_CN.UTF-8" #设置当前系统的 locale,支持中文路径

#先判断svn目录是否存在,直接checkout目录导ImportSVN中
cd $ImportSVN
svn checkout ${SVNURL}/${timeDir}
#新建日期目录
SVNTimeDir=$ImportSVN/${timeDir}
if [ -d "$SVNTimeDir" ]; then
    echo 'SVNTimeDir目录已存在，先svn checkout再commit'
    cat $Distribution/releaseNote.md > ${SVNTimeDir}/${ProductName}.txt
    #把pkg文件移动到SVN版本目录，同时实现重命名
    mv -i ${ImportSVN}/${APPName}.pkg "${SVNTimeDir}/$ProductName.pkg"
    cd ${timeDir}     # 进入checkout目录
    svn add *.*      # 安装包加入版本库
    svn commit -m "${releaseNote}"   # 提交
else
    echo '新建SVNTimeDir目录，直接svn import'
    mkdir $SVNTimeDir
    cat $Distribution/releaseNote.md > ${SVNTimeDir}/${ProductName}.txt
    mv -i ${ImportSVN}/${APPName}.pkg "${SVNTimeDir}/$ProductName.pkg"
    svn import "${ImportSVN}" ${SVNURL} -m "${releaseNote}"
fi

#上传到SVN服务器之后，移除pkg
#rm -rf "${SVNTimeDir}/$ProductName.pkg"

#Showing All Messages
#svn: E170013: Unable to connect to a repository at URL 'https://192.168.85.6/svn/Installation_Package/mac%20os'
#svn: E230001: Server SSL certificate verification failed: certificate issued for a different hostname, issuer is not trusted
#解决办法：
#在终端运行该命令，会提示
#(R)eject, accept (t)emporarily or accept (p)ermanently? p
#选择 p 回车即可。

