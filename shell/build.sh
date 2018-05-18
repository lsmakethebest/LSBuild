Pyger_API_KEY=""
Fir_Token=""
AppleID=""
AppleIDPWD=""
isResign="0"
methodParam=""
emailUser=""
emailPwd=""
emailToUsers=""
emailToCCUsers=""
emailHost=""
resignMobileprovision=""
resignPlist=""
resignCerName=""
resignParams=""

#安装应用时需要输入的密码，这个可不填
installPassword='121219'



emails=""
while getopts 'm:r:u:p:e:t:k:s:h:c:o' OPT; do
case $OPT in
m)
methodParam=$OPTARG;;
r)
resignParams=$OPTARG
isResign="1";;
u)
AppleID=$OPTARG;;
p)
AppleIDPWD=$OPTARG;;
e)
emails=$OPTARG;;
h)
emailHost=$OPTARG;;
s)
emailToUsers=$OPTARG;;
c)
emailToCCUsers=$OPTARG;;
k)
Pyger_API_KEY=$OPTARG;;
t)
Fir_Token=$OPTARG;;
o)
echo -e "\033[34m 参数含义 没有用到的参数不必设置 ，如果不发送邮件，邮件参数也不用设置 \033[0m"
echo -e "\033[34m 修改plist目录下的plist文件,签名方式为(manual,automatic)两种，如果为自动签名不需要设置证书和描述文件，反之设置，还需要设置其他参数如：teamID，compileBitcode等，如果含有Extension等扩展需要多个描述文件，那么就在provisioningProfiles下添加多个 \033[0m"
echo    '-m'
echo    '   development            仅dev打包'
echo    '   development:pgyer      dev打包上传到蒲公英'
echo    '   development:fir        dev打包上传到fir'
echo    ''
echo    '   ad-hoc                 仅ad-hoc打包'
echo    '   ad-hoc:pgyer           ad-hoc打包上传到蒲公英'
echo    '   ad-hoc:fir             ad-hoc打包上传到fir'
echo    ''
echo    '   app-store              仅app-store打包'
echo    '   app-store:pgyer        app-store打包上传到蒲公英'
echo    '   app-store:fir          app-store打包上传到fir'
echo    '   app-store:app-store    app-store打包上传到app-store'
echo    ''
echo    '   enterprise:pgyer'
echo    '   enterprise:fir'


echo   '-r   是否重签名 参数例如 (/Users/resign.mobileprovision,/Users/embedded.plist,"iPhone Distribution: Beijing Tuge")'
echo   '-u   开发者账号用户名'
echo   '-p   开发者账号密码'
echo   '-e   邮箱用户名密码逗号分隔(用户名,密码)         "name@163.com,123456"'
echo   '-s   发送邮件给哪些人逗号分隔(用户,用户,用户)     11@163.com,22@163,com,33@163.com'
echo   '-c   发送邮件抄送给哪些人逗号分隔(用户,用户,用户)  11@163.com,22@163,com,33@163.com'
echo   '-t   fir token'
echo   '-k   pgyer api_key'

exit 0;;

?)
echo "Usage: `basename $0` [options] filename"
esac
done
shift $(($OPTIND - 1))

emailUser=${emails%,*}
emailPwd=${emails#*,}    ##*   #*区别在于##是最后一个匹配  删除左边保留右边


resignMobileprovision=${resignParams%%,*}
lastTwoParam=${resignParams#*,}   #前2个参数
resignPlist=${lastTwoParam%%,*}
if [[ $lastTwoParam =~ "," ]]
then
resignCerName=${lastTwoParam#*,}
fi





current_directory=$(cd `dirname $0`; pwd)/  #当前目录
project_directory=$(cd `dirname $0`; pwd)  #项目根目录
project_directory=${project_directory%/*}/

cd $project_directory


fullName=$(ls -d *.xcodeproj)  ## name.xcodeproj
project_name=${fullName%.*}   ##项目目录名称


export_directory=${project_directory}ipa/
ipaPath=${export_directory}${project_name}.ipa




Project="project"
Xcodeproj="xcodeproj"
plistFinePath=""
configuration="Debug"


##是否使用Pod
if ls *.xcworkspace >/dev/null 2>&1;then
Project="workspace"
Xcodeproj="xcworkspace"
else
Project="project"
Xcodeproj="xcodeproj"
fi


method=${methodParam%:*}

if [[ $methodParam =~ ":" ]]
then
channel=${methodParam#*:}
fi



if [[ $method =~ "dev" ]]
then
configuration="Debug"
elif [[ $method =~ "hoc" ]]
then
configuration="Release"
elif [[ $method =~ "app" ]]
then
configuration="Release"
elif [[ $method =~ "ent" ]]
then
configuration="Release"
fi



echo "打包方法:"$method
echo "上传渠道:"$channel

if [[ $isResign == "1" ]]
then
echo "是否重签名:是"
else
echo "是否重签名:否"
fi

echo "重签名描述文件:"$resignMobileprovision
echo "重签名plsit:"$resignPlist
echo "重签名证书名："$resignCerName

echo "邮箱用户名:"$emailUser
echo "邮箱密码:"$emailPwd
echo "邮箱host:"$emailHost
echo "邮件接收人:"$emailToUsers
echo "邮件抄送人:"$emailToCCUsers
echo "开发者账号:"$AppleID
echo "开发者密码:"$AppleIDPWD

echo "蒲公英key:"$Pyger_API_KEY
echo "Fir token:"$Fir_Token
echo "蒲公英或Fir安装密码:"$installPassword

if [[ $method == "development" ]] || [[ $method == "ad-hoc" ]] || [[ $method == "app-store" ]] || [[ $method == "enterprise" ]]
then
echo ""
else
echo -e "\033[31m 请输入正确打包方式，可以使用  -o 查看说明 \033[0m"
exit 2
fi


needSendEmail="1"
if [ -z $emailUser ]
then
echo "未设置邮件发送人地址"
needSendEmail="0"
fi

if [ -z $emailPwd ]
then
echo "未设置邮件发送人密码"
needSendEmail="0"
fi

if [ -z $emailToUsers ]
then
echo "未设置邮箱收件人"
needSendEmail="0"
fi

if [ -z $emailHost ]
then
echo "未设置邮件host"
needSendEmail="0"
fi



BundleId=""
MainInfoPlistFilePath=""
BundleId=""
Version=""
BuildNumber=""

path="$(xcodebuild -project ${project_name}.xcodeproj -alltargets -showBuildSettings | grep -E "PRODUCT_SETTINGS_PATH|PRODUCT_BUNDLE_IDENTIFIER")"
OLD_IFS="$IFS"
IFS=$'\n'
path_arr=($path)
#共有几个target #因为开头第一组bundle id和plist path会在最后重复出现一次
len=`expr ${#path_arr[@]} / 2 - 1`
IFS="$OLD_IFS"

for (( i = 0; i < $len; i++ )); do
bundle_id_index=`expr $i \* 2`
substr="    PRODUCT_BUNDLE_IDENTIFIER = "
str=${path_arr[$bundle_id_index]}
bundle_id=${str#$substr}
if [[ $i == 0 ]]
then
BundleId=$bundle_id
fi


plist_index=`expr $i \* 2 + 1`
substr="    PRODUCT_SETTINGS_PATH = "
str=${path_arr[$plist_index]}
plist=${str#$substr}

if [[ $i == 0 ]]
then
MainInfoPlistFilePath=$plist
Version=`/usr/libexec/PlistBuddy -c "Print CFBundleShortVersionString" $plist`
BundleDisplayName=`/usr/libexec/PlistBuddy -c "Print CFBundleDisplayName" $plist`
BuildNumber=`/usr/libexec/PlistBuddy -c "Print CFBundleVersion" $plist`
fi

#只设置扩展 Tests  UITests Target不设置
if [[ $bundle_id =~ "$BundleId." ]]
then
#修改buildNumber
/usr/libexec/PlistBuddy -c "set CFBundleVersion $BuildNumber" "$plist"
#修改版本号
/usr/libexec/PlistBuddy -c "set CFBundleShortVersionString $Version" "$plist"
fi

done


emailName=$BundleDisplayName
emailVersion=$Version
emailStatus="0"
emailBody=""
emailType=$channel
emailPassword=""
emailCommit=""
emailPassword=$installPassword




#切换到目录
cd $project_directory

rm -rf ~/Library/Caches/build_cache/$BundleDisplayName
mkdir -p  ~/Library/Caches/build_cache/$BundleDisplayName
plistFinePath=~/Library/Caches/build_cache/$BundleDisplayName/ExportOptions.plist

plutil -extract $method xml1 ${current_directory}build_setting.plist -o $plistFinePath
plutil -insert stripSwiftSymbols -bool "Yes" $plistFinePath
plutil -insert method -string $method $plistFinePath


#commitText=$(git log -3 --date=format:'%Y-%m-%d %H:%M:%S' --pretty=format:"last commit%n person:%an%n time:%cd%n")
emailCommit=$commitText


#先删除上次生成文件
echo "#####################################################################################"
echo "*************  开始删除上一次生产的xcarchive ipa文件 **************"

rm -rf ${export_directory}
rm -rf ${project_directory}build
mkdir ${export_directory}

echo "#####################################################################################"
echo "************   删除完成 ， 开始清理构建缓存       ******************"


#clean
xcodebuild clean -alltargets -configuration ${configuration} > ${export_directory}cleanLog.txt

echo "#####################################################################################"
echo "************  清理构建缓存文件完毕，开始归档 **************"
#完成后删除项目中新生成的build文件夹
rm -rf ${project_directory}/build

DEVELOPMENT_TEAM=`/usr/libexec/PlistBuddy -c "Print :teamID" $plistFinePath`

result=$(xcodebuild archive -${Project} ${project_name}.${Xcodeproj} -configuration ${configuration} -scheme ${project_name} -archivePath ${export_directory}${project_name}.xcarchive CODE_SIGN_STYLE="Automatic" DEVELOPMENT_TEAM="${DEVELOPMENT_TEAM}" > ${export_directory}buildLog.txt)

sendEmail(){
#归档失败  导出失败 验证失败   上传成功与否会发送邮件
/usr/bin/python ${current_directory}smtp.py  $emailHost $emailUser $emailPwd "$content" $emailToUsers $emailToCCUsers
}


echo "#####################################################################################"

if [  -e "${export_directory}${project_name}.xcarchive" ]
then
echo "****** 归档完成，开始导出ipa，归档文件路径:${export_directory}${project_name}.xcarchive ******"
else

echo "****** 归档失败，失败原因请查看 ${export_directory}buildLog.txt  ******"
emailBody='{"message":"归档失败，具体原因请看控制台"}'
emailStatus="1"
content='{"name":"'${emailName}'","version":"'${emailVersion}'","body":'$emailBody',"status":"'$emailStatus'","type":"'$emailType'","password":"'$emailPassword'","commit":"'${emailCommit}'","firToken":"'${Fir_Token}'"}'
if [ "$needSendEmail" = "1" ];
then
sendEmail
fi
exit 2
fi


#导出ipa
exportResult=$(xcodebuild -exportArchive -archivePath ${export_directory}${project_name}.xcarchive -exportPath ${export_directory} -exportOptionsPlist  ${plistFinePath} > ${export_directory}exportLog.txt)
if [ ! -e "${ipaPath}" ]; then
echo "#####################################################################################"
echo  "**********  导出失败! 请查看日志文件，路径:${export_directory}errorLog.txt **********"

emailBody='{"message":"导出失败，具体原因请看控制台"}'
emailStatus="2"

content='{"name":"'${emailName}'","version":"'${emailVersion}'","body":'$emailBody',"status":"'$emailStatus'","type":"'$emailType'","password":"'$emailPassword'","commit":"'${emailCommit}'","firToken":"'${Fir_Token}'"}'
if [ "$needSendEmail" = "1" ];
then
sendEmail
fi
exit 2
else
echo "#####################################################################################"
echo "*************** 导出成功 ，路径:${ipaPath} ***************"
fi


#读取entitlements.plist 得在当前目录
if [ "$isResign" = "1" ];
then
echo "###############开始重签名###############"


bash ${current_directory}resign.sh "${ipaPath}" "$resignMobileprovision" ${resignPlist} "${resignCerName}"
ipaPath=${export_directory}${project_name}-resign.ipa
echo "###############重签名完成###############"
fi



if [ "$channel" = "pgyer" ];
then


if [[ $Pyger_API_KEY == "" ]]
then
echo -e "\033[34m 请输入蒲公英API_Key \033[0m"
exit 2
fi

fileParam='file=@'${ipaPath}
api_key_param='_api_key='${Pyger_API_KEY}
buildInstallTypeParam='buildInstallType=2'
buildPasswordParam='buildPassword='${installPassword}
buildUpdateDescriptionParam='buildUpdateDescription='${commitText}


echo "###########开始将ipa上传到蒲公英########"
result=$(curl -F $fileParam -F $api_key_param -F $buildInstallTypeParam -F $buildPasswordParam -F "$buildUpdateDescriptionParam" https://www.pgyer.com/apiv2/app/upload)

if [[ $result =~ 'code":0' ]]
then
echo "蒲公英上传成功"
emailBody=$result
emailStatus="0"
else
echo "蒲公英上传失败 原因:"$result
emailBody=$result
emailStatus="3"
fi



elif [ "$channel" = "fir" ]
then

if [[ $Fir_Token == "" ]]
then
echo -e "\033[34m 请输入firToken \033[0m"
exit 2
fi

#fir
result=$(gem list)
if [[ $result =~ "fir-cli" ]]
then
echo '安装了fir-cli'
else
echo '未安装fir-cli'
gem install fir-cli
fi
echo "###########开始将ipa上传到fir########"
result=$(fir login -T $Fir_Token)       # fir.im token
if [[ $result =~ "succeed" ]]
then
result=$(fir publish ${export_directory}${project_name}.ipa)
echo $result
if [[ $result =~ "succeed" ]]
then
echo '###################################'
echo "fir上传成功"

result=$(curl "http://api.fir.im/apps?api_token=${Fir_Token}")
emailBody=$result
emailStatus="0"
else
echo "fir上传失败 原因:"$result
emailBody=$result
emailStatus="3"

fi
else
echo "fir上传失败 原因:"$result
emailBody='{"message":"fir token错误"}'
emailStatus="3"
fi





elif [ "$channel" = "app-store" ]
then
#app-store

if [[ $AppleID == "" ]]
then
echo '请输入开发者账号'
exit 2
fi

if [[ $AppleID == "" ]]
then
echo '请输入开发者账号密码'
exit 2
fi



echo "~~~~~~~~~~~~~~~~开始验证ipa~~~~~~~~~~~~~~~~~~~"
altoolPath="/Applications/Xcode.app/Contents/Applications/Application Loader.app/Contents/Frameworks/ITunesSoftwareService.framework/Support/altool"

#alias altool="$altoolPath"
result=$("$altoolPath" --validate-app -f $ipaPath -u $AppleID -p $AppleIDPWD -t ios --output-format xml)

if [ $? = 0 ]
then
echo "~~~~~~~~~~~~~~~~验证ipa成功~~~~~~~~~~~~~~~~~~~"
echo "~~~~~~~~~~~~~~~~开始上传AppStore~~~~~~~~~~~~~~~~~~~"
uploadResult=$("$altoolPath" --upload-app -f $ipaPath -u $AppleID -p $AppleIDPWD -t ios --output-format xml)

#验证成功开始提交
if [ $? = 0 ]
then
echo "~~~~~~~~~~~~~~~~提交AppStore成功~~~~~~~~~~~~~~~~~~~"
emailBody='{"message":"上传成功"}'
emailStatus="0"
else
echo "~~~~~~~~~~~~~~~~提交AppStore失败~~~~~~~~~~~~~~~~~~~"
echo "~~~~~~~~~~~~~~~~提交AppStore失败原因:$uploadResult~~~~~~~~~~~~~~~~~~~"
emailBody='{"message":"上传失败，具体原因请看控制台"}'
emailStatus="3"
fi

else
#验证失败
echo "~~~~~~~~~~~~~~~~验证ipa失败~~~~~~~~~~~~~~~~~~~"
echo "~~~~~~~~~~~~~~~~失败原因：$result~~~~~~~~~~~~~~~~~~~"
emailBody='{"message":"上传失败，具体原因请看控制台"}'
emailStatus="3"
fi

fi


content='{"name":"'${emailName}'","version":"'${emailVersion}'","body":'$emailBody',"status":"'$emailStatus'","type":"'$emailType'","password":"'$emailPassword'","commit":"'${emailCommit}'","firToken":"'${Fir_Token}'"}'

if [ "$needSendEmail" = "1" ]
then
sendEmail
fi



rm -rf ${export_directory}${project_name}.xcarchive

