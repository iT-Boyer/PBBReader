#!/bin/sh

#  Script.sh
#  PBBReaderForMac
#
#  Created by pengyucheng on 16/9/5.
#  Copyright © 2016年 recomend. All rights reserved.

###############获取版本号,bundleID
#获取版本号
#方式一
#bundleBuildVersion="`/usr/libexec/PlistBuddy -c \"Print CFBundleVersion\" $INFOPLIST_FILE`"
#echo $bundleBuildVersion
#方法二CFBundleShortVersionString
#http://stackoverflow.com/questions/6851660/version-vs-build-in-xcode
versionNumber=$(/usr/libexec/PlistBuddy -c "Print CFBundleShortVersionString" "$INFOPLIST_FILE")
buildNumber=$(/usr/libexec/PlistBuddy -c "Print CFBundleVersion" "$INFOPLIST_FILE")
#
#新建导入目录
ProductName="$PRODUCT_NAME.$versionNumber.${buildNumber}"
ProductPath="$TARGET_BUILD_DIR/$PRODUCT_NAME.app"
ImportSVN="ImportSVN"
#上传时，先删除SVN目录
rm -rf ${ImportSVN}
pwd
if [ -d "$ImportSVN" ]; then
echo 'svn目录已存在'
else
echo '新建svn目录'
mkdir $ImportSVN
fi
echo "cp -rf $ProductPath ${ImportSVN}/$ProductName.app"
#压缩
#拷贝
cp -rf $ProductPath ${ImportSVN}/$ProductName.app
cd $ImportSVN
pwd
echo "zip -r $ProductName.app.zip . -i ./*"
#压缩后删除源文件
zip -rm "$ProductName.app.zip" . -i  ./*
#*/
cd ../
pwd

echo "svn import "${ImportSVN}" https:\/\/192.168.85.64/svn/安装包/MAC -m "${ProductName}""
export LC_CTYPE="zh_CN.UTF-8" #设置当前系统的 locale,支持中文路径
#svn import "${ImportSVN}" https:\/\/192.168.85.64/svn/安装包/MAC -m "${ProductName}"

###把Git迁移到SVN
[参考](http://blog.csdn.net/zhangskd/article/details/43452627)
cd git项目
svn mkdir https://192.168.85.6/svn/DRM_iOS/trunk/MusicLrc -m "init"
git svn init https://huoshuguang@192.168.85.6/svn/DRM_iOS/trunk/MusicLrc
git show-ref  #获取refs/remotes/git-svn git-svn最新提交hash SVNLastcommitID
git log --pretty=oneline master | tail -n 1  #获取Git proj 的第一个GitFirstcommitID
echo "GitFirstcommitID SVNLastcommitID" >> .git/info/grafts  #把Git proj从第一次提交，添加到SVN proj在最后一次提交之后。
git-svn dcommit // 提交Git proj的更新
注意！这个时候会报错：
Unable to determine upstream SVN information from HEAD history.
Perhaps the repository is empty. at /usr/local/git/libexec/git-core/git-svn line 852.
解决方法
# git show-ref trunk // 显示SVN proj trunk分支的HEAD，即r1
79563196f21ce4699a04fa4ae24d0ca916bf3acf refs/remotes/trunk
# git log --pretty=oneline master | tail -n 1 // 显示Git proj 的第一个commit
561c439a15f807b8d62551a0c64f939c15489899 initial import
# echo "561c439a15f807b8d62551a0c64f939c15489899 79563196f21ce4699a04fa4ae24d0ca916bf3acf" >> .git/info/grafts
把Git proj从561c43开始的提交，添加到SVN proj在795631之后的提交。
# git-svn dcommit // 提交Git proj的更新到SVN proj中
这个时候就把Git proj完整的转化成SVN proj，后者完全符合SVN的规范了。

### fatal: refusing to merge unrelated histories
#http://blog.csdn.net/lindexi_gd/article/details/52554159
git pull origin master --allow-unrelated-histories

------------------------------
#clone源码
git svn clone https://huoshuguang@192.168.85.6/svn/PBBReader_Mac -T trunk -b branches -t tags PBBReaderRepo
#添加git远程仓库
git remote add PBBReader https://git.oschina.net/huosan/PBBReader.git
#pull 主分支 ,此时会自动合并
git pull PBBReader master
#合并后，向SVN仓库提交更新
git svn dcommit
#变基：从服务器拉取本地还没有的改动，并将你所有的工作变基到服务器的内容之上
git svn rebase  #.DS_Store导致空分支问题：* (no branch, rebasing master)  解决：SVN要添加忽略.DS_Store设置

#拉取最新
git svn fetch
#根据SVN项目中的svn:ignore设置生成对应git忽略文件.gitnore
git svn create-ignore
git svn show-ignore > .git/info/exclude

#查看内容变化
git diff
git diff --staged
git diff --cached
#强制覆盖服务器端上的分支
git push -u origin master -f

####(HEAD detached at origin/master)   /  rebase in progress; onto c25f039
现象：
git status
提示：(HEAD detached at origin/master)
解决在该分支上操作如下：
1. 解决冲突
    git add .
    git commit -m "some temporary message"
2. 建一个temp分支：
    git checkout -b temp
    git svn dcommit   //提交到svn
    //git merge -—no-ff master //把master合并到temp中
3. 切换到master分支：
    git checkout master //结束
4. 将temp分支合并到master分支：
    git merge temp
5. 完成：此时svn服务器上的版本已经和master分支同步
    就可以在master分支上执行git svn dcommit
6. 收尾：删除temp临时分支：
    git branch -D temp  //删除temp分支


#问题：git svn branch results in Authentication failed
#无法新建分支http://stackoverflow.com/questions/34623108/git-svn-branch-results-in-authentication-failed
原文：当Tortoise SVN 和 git-svn合用时，会导致git svn branch results in Authentication failed
卸载Tortoise SVN，执行新建分支命令git svn branch opera
git svn branch opera #新建分支 类同 svn copy trunk branches/opera，该命令不会检出该分支，提交代码时还是提交到trunk中
git branch opera     #切换独立工作的独立分支
git merge master   #把master分支合并进当前分支
