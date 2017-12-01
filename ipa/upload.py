#coding:utf-8
import time
import urllib2
import time
import json
import mimetypes
import os
import sys
from email.Header import Header
import smtplib
from email.MIMEText import MIMEText
from email.MIMEMultipart import MIMEMultipart


#第1个参数为项目名 第2个参数为ipa路径 第3个参数为update.txt路径
filePath=""
#用于发邮件时显示名称
project_name=""
#更新内容文件路径
updateContentPath=""
#更新内容
updateContent=""

#################### 1:我   2:我 + 测试组   3:产品部  4：研发部 + 抄送
debug = 0

for i in range(1, len(sys.argv)):
    if (i==1):
        project_name = sys.argv[i]
    elif (i==2):
        filePath = sys.argv[i]
    elif (i==3):
        debug =int(sys.argv[i])
    elif (i==4):
        updateContentPath = sys.argv[i]

print "\n     ipa路径:",filePath
print "     项目名称:", project_name
print "     发送邮件模式:", debug
print "     提交描述路径:", updateContentPath


if  updateContentPath.strip()!='':
    f = open(updateContentPath, "r")
    for line in f:
        updateContent += line
    f.close()
print "     更新描述:\n" + updateContent


mail_receiver=''
#mail_receiver = ['song.liu@mytogo.com','yan.li@mytogo.com','zhe.qin@mytogo.com']


if debug==1:
    mail_receiver = ['']
elif debug==2:
     mail_receiver = ['']
elif debug==3:
    mail_receiver = []
elif debug==4:
    mail_receiver = []

#抄送接受者
cc_mail_receiver = []
print "     邮箱接收者:", mail_receiver


#邮箱发送者信息
#根据不同邮箱配置 host，user，和pwd
mailHost = 'smtp.163.com'
mailUser = ''
mailPassword = ''




#蒲公英提供的 API Key
_api_key = ''
#蒲公英应用上传地址
url = 'https://www.pgyer.com/apiv2/app/upload'
#安装应用时需要输入的密码，这个可不填
installPassword = ''

# 运行时环境变量字典
#environsDict = os.environ
#此次 jenkins 构建版本号
#jenkins_build_number = environsDict['BUILD_NUMBER']


#请求字典编码
def _encode_multipart(params_dict):
    
    boundary = '----------%s' % hex(int(time.time() * 1000))
    data = []
    for k, v in params_dict.items():
        data.append('--%s' % boundary)
        
        if hasattr(v, 'read'):
            filename = getattr(v, 'name', '')
            content = v.read()
            decoded_content = content.decode('ISO-8859-1')
            data.append('Content-Disposition: form-data; name="%s"; filename="kangda.ipa"' % k)
            data.append('Content-Type: application/octet-stream\r\n')
            data.append(decoded_content)
        else:
            data.append('Content-Disposition: form-data; name="%s"\r\n' % k)
            data.append(v if isinstance(v, str) else v.decode('utf-8'))
    data.append('--%s--\r\n' % boundary)
    return '\r\n'.join(data), boundary


#处理 蒲公英 上传结果



#处理 蒲公英 上传结果
def handle_resule(result):
    json_result = json.loads(result)
    print json_result
    if json_result['code'] is 0:
        if debug!=0:
            send_Email(json_result)
            os.system("open 'http://www.pgyer.com/my'")

#发送邮件
def send_Email(json_result):
    
    appName = json_result['data']['buildName']
    buildKey = json_result['data']['buildKey']
    appVersion = json_result['data']['buildVersion']
    appBuildVersion = json_result['data']['buildBuildVersion']
    appShortcutUrl = json_result['data']['buildShortcutUrl']
    
    #邮件接受者
    
    mail_host = mailHost
    mail_user = mailUser
    mail_pwd = mailPassword
    
    mail_to = ','.join(mail_receiver)
    mail_title = project_name +'(iOS) 版本:' + str(appVersion) + '(build ' + str(appBuildVersion) + ')打包'
    msg = MIMEMultipart()
    
    environsString = '<p>项目名称 : '+ project_name + '<p>'
    
    
    #    environsString += '<p>'+ update + '<p>'
    #    environsString += '<p>构建ID:' + jenkins_build_number +'<p>'
    environsString += '<p>你可以从蒲公英网站在线安装，也可以直接安装 :<p>'
    environsString += '<p> 密码: '+ installPassword + '<p>'
    environsString += '<li><a href=https://www.pgyer.com/' + str(appShortcutUrl) + '>蒲公英安装</a></li>'
    environsString += '<p><p>'
    environsString += '<li><a href="itms-services://?action=download-manifest&url=https://www.pgyer.com/app/plist/' + str(buildKey) + '">点我直接安装</a></li>'
    
    if  updateContentPath.strip()!='':
        f = open(updateContentPath, "r")
        for line in f:
            environsString += '<p>'+ line + '</p>'
        f.close()
        f = open(updateContentPath, "w")
        f.write('此邮件为定时发送')
        f.close()

    environsString+='<p>----</p>'
    environsString+='<p>刘松(iOS开发)</p>'
    environsString+='<p>北京XXXXX有限公司</p>'
    environsString+='<p>电话 : 11111111</p>'
    environsString+='<p>QQ : 111111111 </p>'
    
    print environsString

    message = environsString
    body = MIMEText(message, _subtype='html', _charset='utf-8')
    msg.attach(body)
    msg['To'] = mail_to
    msg['from'] = mail_user
    msg['subject'] = Header(mail_title,'utf-8')
    
    try:
        s = smtplib.SMTP()
        s.connect(mail_host)
        s.login(mail_user, mail_pwd)
        if debug==3:
            s.sendmail(mail_user, [mail_receiver,cc_mail_receiver], msg.as_string())
        else:
            s.sendmail(mail_user, mail_receiver, msg.as_string())
        s.quit()
        print '邮件发送成功'
    except Exception, e:
        print '邮件发送失败'
        print e


#############################################################
#请求参数字典
#应用安装方式，值为(1,2,3)。1：公开，2：密码安装，3：邀请安装。默认为1公开
params = {
    '_api_key': _api_key,
    'file': open(filePath,'rb'),
    'installType': '2',
    'password': installPassword,
    'updateDescription':updateContent
}


coded_params, boundary = _encode_multipart(params)
req = urllib2.Request(url, coded_params.encode('ISO-8859-1'))
req.add_header('Content-Type', 'multipart/form-data; boundary=%s' % boundary)
try:
    resp = urllib2.urlopen(req)
    body = resp.read().decode('utf-8')
    handle_resule(body)

except urllib2.HTTPError as e:
    print(e.fp.read())




