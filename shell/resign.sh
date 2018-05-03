 #!/bin/sh

#参数顺序 ipa  .mobileprovision  plist   证书名称

if ! ([ -e "$1" ]); then
echo \"$1\"文件不存在
exit 2
fi

if ! ([ -e "$2" ]); then
echo \"$2\"文件不存在
exit 2
fi

if ! ([ -e "$3" ]); then
echo \"$3\"文件不存在
exit 2
fi

echo ""
####################################################################
cer_name="iPhone Distribution: Beijing Tuge Technology Co., Ltd."
#是否使用pod
if [ "$4" != "" ]
then
cer_name=$4
echo "使用自定义证书名"
fi

echo "ipa目录     :"$1
echo "描述文件目录 :"$2
echo "plist目录   :"$3
echo "证书名      :"$cer_name
echo ""

#ipaName
ipa_path=$1;
ipaName=$(basename $ipa_path .ipa)
ipa_path=$(dirname $ipa_path)/
unzip -o $1 -d ${ipa_path}

# 描述文件路径
mobileprovision_file=$2

# 将描述文件转换成plist方便查看描述文件里的信息 重签名过程不使用
mobileprovision_plist=${ipa_path}"embedded.plist"
security cms -D -i $mobileprovision_file  > $mobileprovision_plist
teamId=`/usr/libexec/PlistBuddy -c "Print Entitlements:com.apple.developer.team-identifier" $mobileprovision_plist`
#echo $teamId
application_identifier=`/usr/libexec/PlistBuddy -c "Print Entitlements:application-identifier" $mobileprovision_plist`
#echo $application_identifier
bundleid=${application_identifier/$teamId./}
#echo $bundleid
rm -rf $mobileprovision_plist



##########  1.解压 删除签名  2.拷贝描述文件  3.使用plist签名  ##############
#1.删除签名证书文件
rm -rf ${ipa_path}Payload/*.app/_CodeSignature/
#2.拷贝配置文件到Payload目录下
cp $2 ${ipa_path}Payload/*.app/embedded.mobileprovision

#修改bundleid
#/usr/libexec/PlistBuddy -c "Set CFBundleIdentifier $bundleid" ${ipa_path}Payload/*.app/Info.plist

#/usr/libexec/PlistBuddy -c "Set CFBundleDisplayName 微信resign" ${ipa_path}Payload/*.app/Info.plist

#/usr/libexec/PlistBuddy -c "Set CFBundleName 微信resign" ${ipa_path}Payload/*.app/Info.plist

#3.使用plist签名
(/usr/bin/codesign -vvv -fs "$cer_name" --entitlements=$3 ${ipa_path}Payload/*.app/) || {
echo "########################   重新签名失败  #########################"
rm -rf ${ipa_path}Payload/
exit
}

cd $ipa_path
echo $ipa_path
zip -r ${ipaName}-resign.ipa Payload/
rm -rf ${ipa_path}Payload/
echo "######################  重新签名成功  ##############################"

