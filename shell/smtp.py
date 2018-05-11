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
from urllib import quote



reload(sys)
sys.setdefaultencoding('utf-8')



mailHost = ''
mailUser = ''
mailPassword = ''
content=''
mail_receiver=''
mail_receiver_cc=''

for i in range(1, len(sys.argv)):
    if (i==1):
        mailHost = sys.argv[i]
    elif (i==2):
        mailUser = sys.argv[i]
    elif (i==3):
        mailPassword =sys.argv[i]
    elif (i==4):
        content =sys.argv[i]
    elif (i==5):
        mail_receiver =sys.argv[i]
    elif (i==6):
        mail_receiver_cc =sys.argv[i]



def get(url):
    import urllib2
    req = urllib2.Request(url)
    result = urllib2.urlopen(req)
    res = result.read()
    json_result = json.loads(res)
    return json_result['download_token']


def http_put(url,params):
    jdata = json.dumps(params)                  # 对数据进行JSON格式化编码
    request = urllib2.Request(url, data=jdata)
    request.add_header('Content-Type', 'application/json')
    request.get_method = lambda:'PUT'           # 设置HTTP的访问方式
    request = urllib2.urlopen(request)
    return request.read()


#发送邮件
def send_Email(json_content):
#    print json_content
    json_result=json.loads(json_content)
    
    msg = MIMEMultipart()
    environsString = ''
    status = json_result['status']
    body = json_result['body']
    name = json_result['name']
    version = json_result['version']
    type = json_result['type']
    title = ''
    
    typeName=""
    if type == 'pgyer':
        typeName = '蒲公英'
    elif type == 'app-store':
        typeName = 'app-store'
    elif type == 'fir':
        typeName = 'fir'

    if status == '0':
        
        title = name +'(' + version +')上传成功--' + typeName
        
        if type == 'app-store':
            environsString += '<p> app-store上传成功 <p>'
        else:
            password = json_result['password']
            commit = json_result['commit']
            download = ''
            online = ''
            
            appid = ''
            download_token=''
            if type == 'pgyer':
                download = 'https://www.pgyer.com/' + body['data']['buildShortcutUrl']
                online = 'https://www.pgyer.com/app/plist/' + body['data']['buildKey']
            elif type == 'fir':
                list=body['items']
                firToken=json_result['firToken']
                for dic in list:
                    if dic['name'] == name:
                        appid = dic['id']
                        download = 'http://fir.im/' + dic['short']
                        break
                download_token=get('http://api.fir.im/apps/' + appid + '/download_token?api_token=' + firToken)
                online = 'https://download.fir.im/apps/' + appid+ '/install?download_token=' + download_token
                dict = {'api_token':firToken , 'passwd': password, 'is_opened': 'false' , 'desc': commit}
                http_put('http://api.fir.im/apps/' + appid ,dict)

            online=quote(online)
            environsString += '<p>您可以在线安装，也可以直接安装 :<p>'
            environsString += '<p> 密码: '+ password + '<p>'
            environsString += '<li><a href=' + download + '>在线安装</a></li>'
            environsString += '<p><p>'
            environsString += '<li><a href="itms-services://?action=download-manifest&url=' + online  + '">点我直接安装</a></li>'
            environsString += '<p>'+ commit + '</p>'

    elif status == '1':
        #归档失败
        environsString += '<p>' + body['message'] + '<p>'
        title = name +'(' + version +')归档失败'
    elif status == '2':
        #导出失败
        environsString += '<p>' + body['message'] + '<p>'
        title = name +'(' + version +')导出失败'
    elif status == '3':
        #上传失败
        environsString += '<p>上传失败原因:' + body['message'] + '<p>'
        title = name +'(' + version +')上传失败--' + typeName



    environsString+='<p>----</p>'
    environsString+='<p>刘松(iOS开发)</p>'
    environsString+='<p>北京途歌科技股份有限公司</p>'
    environsString+='<p>电话 : 18519341834</p>'
    environsString+='<p>QQ : 623501561 </p>'
    
    
    
    message = environsString
    print message

    body = MIMEText(message, _subtype='html', _charset='utf-8')
    msg.attach(body)
    msg['To'] = mail_receiver
    msg['from'] = mailUser
    msg['subject'] = Header(title,'utf-8')
    msg['Cc'] = mail_receiver_cc

    try:
        s = smtplib.SMTP()
        s.connect(mailHost)
        s.login(mailUser, mailPassword)
        s.sendmail(mailUser, mail_receiver.split(',')+mail_receiver_cc.split(','), msg.as_string())
        s.quit()
        print '邮件发送成功'
    except Exception, e:
        print '邮件发送失败'
        print e


send_Email(content)



