

project_name="test"
project_directory="/Users/liusong/Desktop/代码/test/"  #项目根目录
export_directoty_home="/Users/liusong/Desktop/ipa/"
export_directory=${export_directoty_home}${project_name}/
pythonPath=${export_directoty_home}upload.py
plistFinePath=""

#development_ExprotOptionsPlist.plist
#app-store, ad-hoc, enterprise, development
#CODE_SIGN_IDENTITY=证书
#PROVISIONING_PROFILE=描述文件UUID
AppleID=""
AppleIDPWD=""

#AD_Hoc_CODE_SIGN_IDENTITY="iPhone Distributio"
#AD_Hoc_PROVISIONING_PROFILE="039"
#
#AppStore_CODE_SIGN_IDENTITY="iPhone Distribution: "
#AppStore_PROVISIONING_PROFILE="i"







Project="project"
Xcodeproj="xcodeproj"
emailDebug=0

configuration=$1
isPod=$2
uploadMethod=$3
emailDebug=$4

if [ "$1" = "" ]
then
configuration=1
fi

if [ "$2" = "" ]
then
isPod=1
fi

if [ "$3" = "" ]
then
uploadMethod=1
fi

if [ "$4" = "" ]
then
emailDebug=1
fi

echo "参数值:" $configuration  $isPod  $uploadMethod  $emailDebug



#更新描述路径
updateDescriptionPath=${export_directory}log.txt

#是否使用pod
if [ "$isPod" = "1" ];then
Project="workspace"
Xcodeproj="xcworkspace"
else
Project="project"
Xcodeproj="xcodeproj"
fi

#sleep 0.2


Sign_ODE_SIGN_IDENTITY=""
PROVISIONING_PROFILE=""

#切换到目录
cd $project_directory

#保存log到文件中
#git log -3 --date=format:'%Y-%m-%d %H:%M:%S' --pretty=format:"提交人:%an%n 提交时间:%cd%n 提交日志: %s" > ${export_directory}log.txt
git log -3 --date=format:'%Y-%m-%d %H:%M:%S' --pretty=format:"last commit%n person:%an%n time:%cd%n" > ${export_directory}log.txt


#先删除上次生成文件
echo "#####################################################################################"
echo "*************  开始删除上一次生产的xcarchive ipa文件 **************"
rm -rf ${export_directory}${project_name}.xcarchive
rm -rf ${export_directory}${project_name}.ipa
echo "#####################################################################################"
echo "************   删除完成 ， 开始清理构建缓存       ******************"
#clean
xcodebuild -target ${project_name} clean
echo "#####################################################################################"
echo "************  清理构建缓存文件完毕，开始归档 **************"

#编译
#判断字符串是否相等  用自动签名证书
if [ "$configuration" = "1" ];
then
plistFinePath=${export_directory}"plist/development_ExprotOptionsPlist.plist"
xcodebuild archive -${Project} ${project_name}.${Xcodeproj} -configuration Debug -scheme ${project_name} -archivePath ${export_directory}${project_name}.xcarchive
elif [ "$configuration" = "2" ]
then
plistFinePath=${export_directory}"plist/ad-hoc_ExprotOptionsPlist.plist"
xcodebuild archive -${Project} ${project_name}.${Xcodeproj} -configuration Release -scheme ${project_name} -archivePath ${export_directory}${project_name}.xcarchive
elif [ "$configuration" = "3" ]
then
plistFinePath=${export_directory}"plist/app-store_ExprotOptionsPlist.plist"
xcodebuild archive -${Project} ${project_name}.${Xcodeproj} -configuration Release -scheme ${project_name} -archivePath ${export_directory}${project_name}.xcarchive
fi
echo "#####################################################################################"
echo "****** 归档完成，开始导出归档文件，路径:${export_directory}${project_name}.xcarchive ******"

#导出ipa
xcodebuild -exportArchive -archivePath ${export_directory}${project_name}.xcarchive -exportPath ${export_directory} -exportOptionsPlist  ${plistFinePath} > ${export_directory}errorLog.txt
if [ ! -e "${export_directory}${project_name}.ipa" ]; then
echo "#####################################################################################"
echo  "**********  导出失败! 请查看日志文件，路径:${export_directory}errorLog.txt **********"
exit 2
else
echo "#####################################################################################"
echo "*************** 导出成功 ，路径:${export_directory}${project_name}.ipa ***************"
fi

ipaPath=${export_directory}${project_name}.ipa

#读取entitlements.plist 得在当前目录
if [ "$5" = "1" ];
then
cd ${export_directoty_home}
bash ${export_directoty_home}resign.sh ${export_directory}${project_name}.ipa ${export_directoty_home}com.liusong.resign.mobileprovision ${export_directoty_home}entitlements.plist
ipaPath=${export_directory}${project_name}-resign.ipa
fi


if [ "$uploadMethod" = "1" ];
then
#运行上传ipa到蒲公英脚本
/usr/bin/python $pythonPath ${project_name} $ipaPath ${emailDebug} ${updateDescriptionPath}
elif [ "$uploadMethod" = "2" ]
then
#fir
fir login -T $upload_token       # fir.im token
fir publish ${export_directory}${project_name}.ipa
elif [ "$uploadMethod" = "3" ]
then
altoolPath="/Applications/Xcode.app/Contents/Applications/Application\ Loader.app/Contents/Frameworks/ITunesSoftwareService.framework/Versions/A/Support/altool"
${altoolPath} --validate-app \
-f ${export_directory}${project_name}.ipa \
-u ${AppleID} \
-p ${AppleIDPWD} \
-t ios --output-format xml

if [ $? = 0 ]
then
echo "~~~~~~~~~~~~~~~~验证ipa成功~~~~~~~~~~~~~~~~~~~"
${altoolPath} --upload-app \
-f ${IPAPATH} \
-u ${AppleID} \
-p ${AppleIDPWD} \
-t ios --output-format xml

if [ $? = 0 ]
then
echo "~~~~~~~~~~~~~~~~提交AppStore成功~~~~~~~~~~~~~~~~~~~"
else
echo "~~~~~~~~~~~~~~~~提交AppStore失败~~~~~~~~~~~~~~~~~~~"
fi
else
echo "~~~~~~~~~~~~~~~~验证ipa失败~~~~~~~~~~~~~~~~~~~"
fi
fi





#完成后删除项目中新生成的build文件夹
rm -rf ${project_directory}/build





