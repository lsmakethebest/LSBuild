# LSBuild
命令打包 以及上传到蒲公英 ,fir,app-store,然后分发邮件
## 使用之前先修改shell目录下build_setting.plist里的打包配置,如果之前导出过对应模式的包(比如上传过app-store包,则app-store模式可以自动打包，会自动找对应的证书和描述文件)可以使用automatic自动证书打包，免去设置证书，描述文件的麻烦，所以只需要设置teamid就可以了，其他的啥都不需要修改，manual为手动，则还需要设置证书和描述文件，如果有推送扩展等，描述文件得设置多个，支持将serviceExtension等扩展的version，buildNumber设置成和主target相同，免去手动修改的麻烦
![image](https://github.com/lsmakethebest/LSBuild/blob/master/images/4.png)
## 1.将shell文件夹拖动到截图所处位置
![image](https://github.com/lsmakethebest/LSBuild/blob/master/images/1.png)
## 2.cd到build.sh目录，运行build.sh脚本 参数方法可使用./build.sh -o查看
![image](https://github.com/lsmakethebest/LSBuild/blob/master/images/3.png)
### 2.1如打app-store包并上传到app-store可使用如下命令
#### ./build.sh -m app-store:app-store -u apple_id@163.com -p Aa12763

### 2.2如打app-store包并上传到app-store并发送邮件并且抄送给某人可使用如下命令
#### ./build.sh -m app-store:app-store -u apple_id@163.com -p Aa12763 -e itiapp@163.com,327923 -h smtp.163.com -s 1@163.com,2@163.com   -c 3@163.com,4@163.com
### 2.3如打dev包并上传到pgyer并发送邮件并且抄送给某人可使用如下命令
#### ./build.sh -m development:pgyer -k  fsfunvsldlqnf3289bfsd -e itiapp@163.com,327923 -h smtp.163.com -s 1@163.com,2@163.com   -c 3@163.com,4@163.com
### 2.4如打dev包并上传到fir并发送邮件并且抄送给某人可使用如下命令
#### ./build.sh -m development:fir -t  fshkdjwejnhfs -e itiapp@163.com,327923 -h smtp.163.com -s 1@163.com,2@163.com   -c 3@163.com,4@163.com

### 2.5如打dev包而且重签名，并上传到fir并发送邮件并且抄送给某人可使用如下命令，证书名需加双引号因为可能有空格，重签名使用到的文件可以放在任意目录因为传参数是全目录，但是建议放在脚本同一目录方便管理
#### ./build.sh -m development:fir -t  fshkdjwejnhfs -e itiapp@163.com,327923 -h smtp.163.com -s 1@163.com,2@163.com   -c 3@163.com,4@163.com -r /Users/liusong/LSMakeEmotion/transparentExpression/shell/commytogoresign.mobileprovision,/Users/liusong/LSMakeEmotion/transparentExpression/shell/entitlements.plist,"iPhone Distribution: XXXXX  Technology Co., Ltd"


## 重签名具体使用方法见此链接 https://github.com/lsmakethebest/Resign
## 打包成功后 生成的ipa在ipa文件夹下
![image](https://github.com/lsmakethebest/LSBuild/blob/master/images/2.png)
