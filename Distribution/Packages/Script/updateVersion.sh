#!/bin/sh
echo "---更新Packages 中的Welcome.html文件中的版本号---"
versionNumber=$(/usr/libexec/PlistBuddy -c "Print CFBundleShortVersionString" "$INFOPLIST_FILE")
buildNumber=$(/usr/libexec/PlistBuddy -c "Print CFBundleVersion" "$INFOPLIST_FILE")
ProductName="$versionNumber.${buildNumber}"
#Welcome文件 绝对路径
Welcome_PATH=Distribution/Packages/Text/Welcome.html
#数据的搜寻并替换
#sed 's/要被取代的字串/新的字串/g'
#echo ${Welcome_PATH}
#echo "sed -i \"s/>Version.*</>Version ${ProductName}</g\" ${PushConfig_FILE_PATH}"
#cat ${Welcome_PATH} | grep '>Version' | sed "s/Version\s{1}.*</${ProductName}</g"
#直接修改文件内容 : -i    -i之后必须跟单引号'' ，否则：error sed: -i may not be used with stdin
sed -i '' "s/Version.*</Version ${ProductName}</g" ${Welcome_PATH}
echo "--替换成功--"
exit 0
