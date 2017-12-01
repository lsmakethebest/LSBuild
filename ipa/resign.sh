#!/bin/sh

#参数顺序 ipa .mobileprovision plist
echo $1
echo $2
echo $3
if ! ([ -e "$1" ]); then
echo \"${1}\"文件不存在
exit
fi

if ! ([ -e "$2" ]); then
echo \"${2}\"文件不存在
exit
fi

if ! ([ -e "$3" ]); then
echo \"${2}\"文件不存在
exit
fi

####################################################################
cer_name="iPhone Distribution: XXXXX  Technology Co., Ltd."
#是否使用pod
if [ "$4" != "" ];then
$cer_name=$4;
echo "证书名:"$4
fi



#ipaName
ipa_path=$1;
ipaName=$(basename $ipa_path .ipa)
ipa_path=$(dirname $ipa_path)/
unzip -o $1 -d ${ipa_path}

# 描述文件路径
mobileprovision_file=$2

# 将描述文件转换成plist
mobileprovision_plist=${ipa_path}"embedded.plist"
security cms -D -i $mobileprovision_file  > $mobileprovision_plist
teamId=`/usr/libexec/PlistBuddy -c "Print Entitlements:com.apple.developer.team-identifier" $mobileprovision_plist`
#echo $teamId
application_identifier=`/usr/libexec/PlistBuddy -c "Print Entitlements:application-identifier" $mobileprovision_plist`
#echo $application_identifier
bundleid=${application_identifier/$teamId./}
#echo $bundleid
rm -rf $mobileprovision_plist




#删除签名证书文件
rm -rf ${ipa_path}Payload/*.app/_CodeSignature/
#拷贝配置文件到Payload目录下
cp $2 ${ipa_path}Payload/*.app/embedded.mobileprovision
#修改bundleid
#/usr/libexec/PlistBuddy -c "Set CFBundleIdentifier $bundleid" ${ipa_path}Payload/*.app/Info.plist


(/usr/bin/codesign -vvv -fs "$cer_name" --entitlements=entitlements.plist ${ipa_path}Payload/*.app/) || {
echo "########################   重新签名失败  #########################"
rm -rf ${ipa_path}Payload/
exit
}

cd $ipa_path
echo $ipa_path
zip -r ${ipaName}-resign.ipa Payload/
rm -rf ${ipa_path}Payload/
echo "######################  重新签名成功  ##############################"

