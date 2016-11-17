#!/bin/sh

#  PreInstall.sh
#  PBBReaderForMac
#
#  Created by pengyucheng on 16/9/6.
#  Copyright © 2016年 recomend. All rights reserved.

echo "------------------------1111111=============="
pwd
#拷贝
APPName="PBBReader"
ProductPath="$TARGET_BUILD_DIR/${APPName}.app"
Distribution="$PROJECT_DIR/Distribution"
ImportSVN="$Distribution/ImportSVN"
#重命名导入SVN
versionNumber=$(/usr/libexec/PlistBuddy -c "Print CFBundleShortVersionString" "$INFOPLIST_FILE")
buildNumber=$(/usr/libexec/PlistBuddy -c "Print CFBundleVersion" "$INFOPLIST_FILE")
BundleName=$(/usr/libexec/PlistBuddy -c "Print CFBundleName" "$INFOPLIST_FILE")
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
    packagesbuild -vF $Distribution/ -t $Distribution/ $Distribution/PBBReaderForOSX.pkgproj
else
 echo "app源文件不存在，无法制作pkg安装包"
fi

#安装packages并生成pkg安装包之后删除.app文件,目的是不让在上传SVN时，误上传文件
rm -rf "${ImportSVN}/${APPName}.app"

#重命名:注在命名文件时，存在空格时必须有反斜杠修饰，或使用双毛号括住文件名
echo "mv ${ImportSVN}/${APPName}.pkg ${ImportSVN}/$ProductName.pkg"
mv -i ${ImportSVN}/${APPName}.pkg "${ImportSVN}/$ProductName.pkg"

#导入svn
echo "import "${ImportSVN}" https:\/\/192.168.85.6/svn/Installation_Package/mac%20os -m "${ProductName}""
export LC_CTYPE="zh_CN.UTF-8" #设置当前系统的 locale,支持中文路径
svn import "${ImportSVN}" https://192.168.85.6/svn/Installation_Package/mac%20os -m "${ProductName}"
#上传到SVN服务器之后，移除pkg
rm -rf "${ImportSVN}/$ProductName.pkg"

#Showing All Messages
#svn: E170013: Unable to connect to a repository at URL 'https://192.168.85.6/svn/Installation_Package/mac%20os'
#svn: E230001: Server SSL certificate verification failed: certificate issued for a different hostname, issuer is not trusted
#解决办法：
#在终端运行该命令，会提示
#(R)eject, accept (t)emporarily or accept (p)ermanently? p
#选择 p 回车即可。

