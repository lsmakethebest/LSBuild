# LSBuild
命令打包 以及上传到蒲公英 ,fir,app-store,然后分发邮件
## 使用之前先修改shell目录下build_setting.plist里的打包配置
![image](https://github.com/lsmakethebest/LSBuild/blob/master/images/4.png)
## 1.将shell文件夹拖动到截图所处位置
![image](https://github.com/lsmakethebest/LSBuild/blob/master/images/1.png)
## 2.cd到build.sh目录，运行build.sh脚本 参数方法可使用./build.sh -o查看
![image](https://github.com/lsmakethebest/LSBuild/blob/master/images/3.png)
## 如打app-store包并上传到app-store可使用如下命令
### ./build.sh -m app-store:app-store -u apple_id@163.com -p Aa12763

## 如打app-store包并上传到app-store并发送邮件并且抄送给某人可使用如下命令
### ./build.sh -m app-store:app-store -u apple_id@163.com -p Aa12763 -e itiapp@163.com,327923 -h smtp.163.com -s 1@163.com,2@163.com   -c 3@163.com,4@163.com
## 如打dev包并上传到pgyer并发送邮件并且抄送给某人可使用如下命令
### ./build.sh -m development:pgyer -k  fsfunvsldlqnf3289bfsd -e itiapp@163.com,327923 -h smtp.163.com -s 1@163.com,2@163.com   -c 3@163.com,4@163.com
## 如打dev包并上传到fir并发送邮件并且抄送给某人可使用如下命令
### ./build.sh -m development:fir -t  fshkdjwejnhfs -e itiapp@163.com,327923 -h smtp.163.com -s 1@163.com,2@163.com   -c 3@163.com,4@163.com


## 3.如果需要重签名,具体使用方法见此链接 https://github.com/lsmakethebest/Resign
## 打包成功后 生成的ipa在ipa文件夹下
![image](https://github.com/lsmakethebest/LSBuild/blob/master/images/2.png)
