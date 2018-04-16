#!/bin/bash
# Linux system check script.
# Operating system: Suse11/RHEL

IPADDR1=`ip addr|awk -F"[/ ]+" '(/inet /) && ($0 !~ /lo$/) && ($0 !~ /virbr0$/){print $3}'|awk 'NR==1{print $0}'`
IPADDR2=`ip addr|awk -F"[/ ]+" '(/inet /) && ($0 !~ /lo$/) && ($0 !~ /virbr0$/){print $3}'|awk 'NR==2{print $0}'`
IPADDR3=`ip addr|awk -F"[/ ]+" '(/inet /) && ($0 !~ /lo$/) && ($0 !~ /virbr0$/){print $3}'|awk 'NR==3{print $0}'`
IPADDR4=`ip addr|awk -F"[/ ]+" '(/inet /) && ($0 !~ /lo$/) && ($0 !~ /virbr0$/){print $3}'|awk 'NR==4{print $0}'`
HOSTNAME=$HOSTNAME
DATETIME=`date '+%F %T'`
DATE=`date '+%F'`

Logfile=/tmp/${HOSTNAME}_${IPADDR1}_${DATE}.log

ECHO="echo -e"
SPACE="\t\t\t\t\t"

M_="----------------------------------------"
TII="\E[33m"
TIA="\E[0m"
I_="$M_ $TII"
A_="$TIA $M_"

if [ "X$IPADDR2" == "X" ];then
    IPADDR2=$IPADDR1
elif [ "X$IPADDR3" == "X" ];then
    IPADDR3=$IPADDR1
elif [ "X$IPADDR4" == "X" ];then
    IPADDR4=$IPADDR1
fi

function FOO {
/bin/bash << HM
echo -e "+-------------------------------------------------------------------------------------------------------------+"
echo -e "+  \E[34mUDB System Check Script.  检查时间: `date '+%F %T'`   检查主机: ${HOSTNAME}_${IPADDR1}\E[0m"
echo -e "+-------------------------------------------------------------------------------------------------------------+"
HM
};FOO

function ITEM {
$ECHO "\E[36m# [ITEM_$n]>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>[ITEM_$n]\E[0m"
}

function HEAD {
    Kernel_version=`uname -r | awk -F"-" '{print $1}'`
    Login_user=`last -a | grep "logged in" | wc -l`
    Up_lastime=`date -d "$(awk -F. '{print $1}' /proc/uptime) second ago" +"%Y-%m-%d %H:%M:%S"`
    Up_runtime=`cat /proc/uptime| awk -F. '{run_days=$1 / 86400;run_hour=($1 % 86400)/3600;run_minute=($1 % 3600)/60;run_second=$1 % 60;printf("%d天%d时%d分%d秒",run_days,run_hour,run_minute,run_second)}'`
    Last_user=`last | awk '(/pts/) && (/-/){print "User: "$1" - ""OlineTime: "$NF" - ""IP: "$3" - ""LoginTime: "$4" "$5" "$6" "$7}'| head -1 | sed -e 's/(//g' -e 's/)//g'`
    echo ""
    $ECHO "\
                            System information
    主机名: $HOSTNAME
    内核版本: $Kernel_version
    系统已运行时间: $Up_runtime
    上一次重启时间: $Up_lastime
    当前登入用户数: $Login_user
    上一次登入用户: $Last_user
    -------------------------------------------------------------
    "
};HEAD

function check_os {
    $ECHO "$I_(1).系统版本$A_"
    if [ -e /etc/redhat-release ];then
	version=`cat /etc/redhat-release | awk '{print $1$2$(NF-1)}' | sed -e 's/release//g' -e 's/Linux//g'`
        release=$(cat /etc/redhat-release)
	LINEINFO=("[${LOGNAME}@${HOSTNAME} ~]#")
	LI="\E[31m"$LINEINFO"\E[0m"
        OI=("[oracle@${HOSTNAME} ~]$")
        $ECHO "$LI cat /etc/redhat-release"
    elif [ -e /etc/SuSE-release ];then
	version=`cat /etc/SuSE-release | awk 'NR==1{printf $1$2$(NF-1)}END{print "SP"$NR}' | sed -e 's/release//g' -e 's/Linux//g'`
        release=$(cat /etc/SuSE-release)
	LINEINFO=(${HOSTNAME}":~ #")
	LI="\E[31m$LINEINFO\E[0m"
        OI=("oracle@${HOSTNAME}:~>")
        GI=("grid@${HOSTNAME}:~>")
        $ECHO "$LI cat /etc/SuSE-release"
    else
        release=$(cat /etc/issue)
	LINEINFO=("#")
	LI="\E[31m"$LINEINFO"\E[0m"
        $ECHO "$LI cat /etc/issue"
    fi
    echo $release
    echo ""
}

function kernel_version {
    $ECHO "$I_(2).内核版本$A_"
    $ECHO "$LI uname -r"
    uname -r
    echo ""

};

function tcp_connet {
    $ECHO "$I_(3).TCP 连接$A_"
    $ECHO "$LI netstat -ant"
    netstat -ant | awk '/^tcp/{++S[$NF]}END{for (a in S) print a,S[a]}'
    echo ""
};

function cpu_status {
    top -b -n3 2>&1 | grep -E "Tasks|Cpu\(s\)" >/tmp/cpu_load.txt
    #Cpu load
    Load_avg15=`uptime | awk -F"[, ]" '{print $NF}'`
    Load_avg5=`uptime | awk -F"[, ]" '{print $(NF-2)}'`
    Load_avg1=`uptime | awk -F"[, ]" '{print $(NF-4)}'`
    # Cpu status
    us=`cat /tmp/cpu_load.txt | awk -F"[, ]+" '/Cpu/{print $2}' | awk -F% '{sum += $1}END{printf "%.2f\n",sum/3}'`
    sy=`cat /tmp/cpu_load.txt | awk -F"[, ]+" '/Cpu/{print $3}' | awk -F% '{sum += $1}END{printf "%.2f\n",sum/3}'`
    ni=`cat /tmp/cpu_load.txt | awk -F"[, ]+" '/Cpu/{print $4}' | awk -F% '{sum += $1}END{printf "%.2f\n",sum/3}'`
    id=`cat /tmp/cpu_load.txt | awk -F"[, ]+" '/Cpu/{print $5}' | awk -F% '{sum += $1}END{printf "%.2f\n",sum/3}'`
    wa=`cat /tmp/cpu_load.txt | awk -F"[, ]+" '/Cpu/{print $6}' | awk -F% '{sum += $1}END{printf "%.2f\n",sum/3}'`
    hi=`cat /tmp/cpu_load.txt | awk -F"[, ]+" '/Cpu/{print $7}' | awk -F% '{sum += $1}END{printf "%.2f\n",sum/3}'`
    si=`cat /tmp/cpu_load.txt | awk -F"[, ]+" '/Cpu/{print $8}' | awk -F% '{sum += $1}END{printf "%.2f\n",sum/3}'`
    # Tasks status
    Task_total=`cat /tmp/cpu_load.txt | awk -F"[:,]" '/Tasks/{print $2}' | awk 'NR==1{printf "%s\n",$1}'`
    Task_running=`cat /tmp/cpu_load.txt | awk -F"[:,]" '/Tasks/{print $3}' | awk 'NR==1{printf "%s\n",$1}'`
    Task_sleeping=`cat /tmp/cpu_load.txt | awk -F"[:,]" '/Tasks/{print $4}' | awk 'NR==1{printf "%s\n",$1}'`
    Task_stoped=`cat /tmp/cpu_load.txt | awk -F"[:,]" '/Tasks/{print $5}' | awk 'NR==1{printf "%s\n",$1}'`
    Task_zombie=`cat /tmp/cpu_load.txt | awk -F"[:,]" '/Tasks/{print $6}' | awk 'NR==1{printf "%s\n",$1}'`

    $ECHO "$I_(4).CPU 负载$A_"
    $ECHO "$LI uptime
         CPU最近1分钟负载值:  $Load_avg1
         CPU最近5分钟负载值:  $Load_avg5
         CPU最近15分钟负载值: $Load_avg15
         "
    $ECHO "$I_(5).CPU运行状态$A_"
    $ECHO "$LI top
         CPU空闲时间百分比平均值(%idle): $id
         用户空间占用CPU时间百分比(%us): $us
         内核空间占用CPU时间百分比(%sy): $sy
         等待IO所消耗CPU时间百分比(%wa): $wa
         硬中断所消耗CPU时间百分比(%hi): $hi
         软中断所消耗CPU时间百分比(%si): $si
         用户进程改变过优先级占用CPU百分比(%ni): $ni
         "
    id_e=`echo $id | awk -F. '{print $1}'`
    if [ $id_e -lt 25 ];then
        $ECHO "\E[31mWarning: CPU使用率过高!! 当前空闲平均值小于25%.\E[0m"
        CPU_HIGH1=25
    fi

    $ECHO "$I_(6).运行任务状态$A_"
    $ECHO "
         +------------------------------+
         + 当前系统的总进程数: $Task_total\t+
         + 处于运行状态进程数: $Task_running\t+
         + 处于休眠状态进程数: $Task_sleeping\t+
         + 处于停止状态进程数: $Task_stoped\t+
         + 处于僵化状态进程数: $Task_zombie\t+
         +------------------------------+
         "
};

function mem_status {
    $ECHO "$I_(7).内存使用率$A_"
    $ECHO "$LI free -m"
    free -m
    mem_total=`free -m | awk '{if(NR==2) printf "%.f",$2}'`
    mem_cache_use=`free -m | awk '{if(NR==2) printf "%.f",$3}'`
    mem_cache_fre=`free -m | awk '{if(NR==2) printf "%.f",$4}'`
    cached_use=`free -m | awk '{if(NR==2) printf "%.f",$7}END{print "M"}'`
    buffer_use=`free -m | awk '{if(NR==2) printf "%.f",$6}END{print "M"}'`
    mem_real_use=`free -m | awk '{if(NR==3) printf "%.f",$3}'`
    mem_real_fre=`free -m | awk '{if(NR==3) printf "%.f",$4}'`
    mem_cache_per=`free -m | awk '{if(NR==2) {printf "%.2f",$3/$2*100}}'`
    mem_real_per=`free -m | awk '{if(NR==3) {printf "%.2f",$3/($3+$4)*100}}'`
    $ECHO "
         ----------------------------------------
         系统共有内存(M):\t\t${mem_total}M
         系统已缓存内存使用量(M):\t${mem_cache_use}M
         系统已缓存内存剩余量(M):\t${mem_cache_fre}M
         系统已缓存内存使用率(%):\t${mem_cache_per}%
         ----------------------------------------
         Cached 使用量(M):\t\t${cached_use}
         Buffers使用量(M):\t\t${buffer_use}
         ----------------------------------------
         系统内存实际使用量(M):\t\t${mem_real_use}M
         系统内存实际剩余量(M):\t\t${mem_real_fre}M
         系统内存实际使用率(%):\t\t${mem_real_per}%
         ----------------------------------------
         "
    if [ ${mem_cache_fre} -lt 20 ];then
        $ECHO "\E[31mWarning: 系统当前已缓存内存使用过高, 小于20M.\E[0m"
	MEM_HIGH1=20
    fi

    if [ ${mem_real_fre} -lt 100 ];then
        $ECHO "\E[31mWarning: 系统当前可用内存小于100M!!!\E[0m"
	MEM_HIGH2=100
    fi
};

function swap_status {
    $ECHO "$I_(8).Swap分区检查$A_"
    $ECHO "$LI swapon -s"
    swapon -s
    swap_use=`free -m | awk '{if(NR==4) printf "%.f",$3}END{print "M"}'`
    swap_tot=`free -m | awk '{if(NR==4) printf "%.f",$2}END{print "M"}'`
    swap_use_per=`free -m | awk '/Swap/{printf "%.2f",$3/$2*100}'`
    $ECHO "
         swap交换分区已用(M):\t\t${swap_use}
         swap交换分区容量(M):\t\t${swap_tot}
         swap交换分区使用率(%):\t\t${swap_use_per}%
         ----------------------------------------
         "
}

function disk_status {
    disk_count=`fdisk -l 2>&1 | awk -F"[:, ]+" '(/^Disk.*bytes/)&&(/\/dev/){printf "\t "$2"\t";printf "%d",$3;printf $4"\n"}'`
    $ECHO "$I_(9).文件系统空间检查$A_"
    $ECHO "$LI df -Th"
    df -Th
    $ECHO "
         ----------------------------------------
         系统所有磁盘数及容量"
    $ECHO "$disk_count
         ----------------------------------------"
    disk_use=`df -h | awk '/^\/dev/{print "\t "$6"\t\t"$5}'`
    $ECHO "\
         磁盘分区使用率"
    $ECHO "$disk_use
         ----------------------------------------"

    USE_RATE=`df -h | awk '/^\/dev/{print int($5)}'`
    for i in $USE_RATE; do
        if [ $i -gt 80 ];then
            PART=`df -h | awk '{if(int($5)=='''$i''') print "\t "$6}'`
            $ECHO "$PART = ${i}%"
            $ECHO "\
         \E[31m注意: 文件系统空间使用率超过80%!\E[0m
         ----------------------------------------"
        fi
    done
};

function net_device {
    $ECHO "$I_(10).网卡设备及IP地址检查$A_"
    $ECHO "$LI ifconfig -a"
    ifconfig -a
    NET_LIST=(lo lo:0 lo:1 br0 eth0 docker0 eth1 eth2 eth3 eth4 eth0:0 eth0:1 eth0:2 eth0:3 eth1:0 eth1:1 eth1:2 eth2:0 eth2:1 eth3:0 eth4:0 eth5 eth6 eth7 eth8 bond0 bond1 bond0:0 bond0:1 em0 em1 em2 em0:0 em0:1)
    $ECHO "
         ----------------------------------------
         网卡设备名及对应的IP地址:"
    for i in ${NET_LIST[@]};do
        ip=`ifconfig $i 2>&1 | awk -F"[: ]+" '/inet addr/{print $4}'`
        if [ "X$ip" == "X" ];then
            unset NET_LIST[@]
        else
            $ECHO "\
         $i\t\t$ip"
        fi
    done
    echo "\
        ----------------------------------------"
    echo ""
};

function cpu_top10 {
    $ECHO "$I_(11).CPU占用最高的10个进程$A_"
    $ECHO "$LI ps aux"
    ps aux | head -1
    ps aux | sort -k 3 -nr | head -10
    echo ""
};

function mem_top10 {
    $ECHO "$I_(12).MEM占用最高的10个进程$A_"
    $ECHO "$LI ps aux"
    ps aux | head -1
    ps aux | sort -k 4 -nr | head -10
    echo ""
};

function messages_error_log {
    $ECHO "$I_(13).系统错误日志信息$A_"
    $ECHO "$LI grep error /var/log/messages"
    grep -Ei "error|failed" /var/log/messages | tail -20
    echo ""
};

function check_udb {
    ##-------------
    $ECHO "$I_(14).CRM同步应用检查$A_"
    $ECHO "$LI /opt/udb/udbsync/DBSyncService.sh check"
    /opt/udb/udbsync/DBSyncService.sh check 2>/dev/null
    if [ $? -ne 0 ];then
        DBSyncService=0
        $ECHO "
         ${HOSTNAME}_${IPADDR1} 无CRM同步应用
         "
    fi

    ##-------------
    $ECHO "$I_(15).CRM同步应用日志采集代理检查$A_"
    $ECHO "$LI /opt/udb/udblogAgent/udbLogAgentService.sh check"
    /opt/udb/udblogAgent/udbLogAgentService.sh check 2>/dev/null
    if [ $? -ne 0 ];then
        udbLogAgentService=0
        $ECHO "
         ${HOSTNAME}_${IPADDR1} 无CRM同步应用日志采集代理
         "
    fi

    ##-------------
    $ECHO "$I_(16).是否有jboss进程$A_"
    $ECHO "$LI ps -ef | grep jboss"
    jboss_pid=`ps -ef | grep java | awk '/jboss/{print $2}'`
    ps -ef | grep jboss
    if [ "X$jboss_pid" == "X" ];then
        $ECHO "
         \E[35m注意: ${HOSTNAME}_${IPADDR1} 没有检测到jboss进程\E[0m
         "
    else
        $ECHO "
         jboss进程PID: $jboss_pid
         "
    fi

    ##-------------
    $ECHO "$I_(17).是否有udb-logAgent日志采集代理进程$A_"
    $ECHO "$LI ps -ef | grep java | grep udb-logAgent"
    ps -ef | grep java | grep udb-logAgent
    logagent_pid=`ps -ef | grep java | awk '/udb-logAgent/{print $2}'`
    if [ "X$logagent_pid" == "X" ];then
        udbloganent=0
        $ECHO "
         \E[35m注意: ${HOSTNAME}_${IPADDR1} 没有检测到udb-logAgent日志采集代理进程\E[0m
         "
    else
        $ECHO "
         udb-logAgent进程PID: $logagent_pid
         "
    fi

    ##-------------
    $ECHO "$I_(18).认证服务日志采集代理检查$A_"
    $ECHO "$LI /opt/udb/udblogAgent/udbLogAgentService.sh check"
    /opt/udb/udblogAgent/udbLogAgentService.sh check 2>/dev/null
    if [ $? -ne 0 ];then
        udbLogAgentService=0
        $ECHO "
         ${HOSTNAME}_${IPADDR1} 无认证服务日志采集代理
         "
    fi

    ##-------------
    $ECHO "$I_(19).是否有udb-logAnalysis日志分析服务进程$A_"
    $ECHO "$LI ps -ef | grep java | grep udb-logAnalysis"
    ps -ef | grep java | grep udb-logAnalysis
    loganalysis_pid=`ps -ef | grep java | awk '/udb-logAnalysis/{print $2}'`
    if [ "X$loganalysis_pid" == "X" ];then
        udbloganalysis=0
        $ECHO "
         \E[35m注意: ${HOSTNAME}_${IPADDR1} 没有检测到udb-logAnalysi日志分析服务进程\E[0m
         "
    else
        $ECHO "
         udb-logAnalysis进程ID为: $loganalysis_pid
         "
    fi

    ##-------------
    $ECHO "$I_(20).日志分析服务检查$A_"
    $ECHO "$LI /opt/udb/udblogAnalysis/LogAnalysisService.sh check"
    /opt/udb/udblogAnalysis/LogAnalysisService.sh check 2>/dev/null
    if [ $? -ne 0 ];then
        LogAnalysisService=0
        $ECHO "
         ${HOSTNAME}_${IPADDR1} 无日志分析服务
         "
    fi

    ##-------------
    $ECHO "$I_(21).SOAP认证接口检查$A_"
    $ECHO "$LI curl http://${IPADDR1}/SOAP/services/UDBCommon?wsdl -I"
    if [ "X$jboss_pid" == "X" -a $udbLogAgentService=0 ];then
        $ECHO "
         ${HOSTNAME}_${IPADDR1} 无认证接口
         "
    else
        curl http://${IPADDR1}/SOAP/services/UDBCommon?wsdl -I --connect-timeout 2 2>/dev/null
        $ECHO "$LI curl http://${IPADDR2}/SOAP/services/UDBCommon?wsdl -I"
        curl http://${IPADDR2}/SOAP/services/UDBCommon?wsdl -I --connect-timeout 2 2>/dev/null
        $ECHO "$LI curl http://${IPADDR1}:8080/SOAP/services/UDBCommon?wsdl -I"
        curl http://${IPADDR1}:8080/SOAP/services/UDBCommon?wsdl -I --connect-timeout 2 2>&1
        $ECHO "$LI curl http://${IPADDR2}:8080/SOAP/services/UDBCommon?wsdl -I"
        curl http://${IPADDR2}:8080/SOAP/services/UDBCommon?wsdl -I --connect-timeout 2 2>&1
        if [ "X$IPADDR3" != "X" ];then
            $ECHO "$LI curl http://${IPADDR3}/SOAP/services/UDBCommon?wsdl -I"
            curl http://${IPADDR3}/SOAP/services/UDBCommon?wsdl -I --connect-timeout 2 2>&1
        elif [ "X$IPADDR4" != "X" ];then
            IP4=1
            $ECHO "$LI curl http://${IPADDR4}/SOAP/services/UDBCommon?wsdl -I"
            curl http://${IPADDR4}/SOAP/services/UDBCommon?wsdl -I --connect-timeout 2 2>&1
        fi
        $ECHO "
         注意: 只要有一个能访问成功就说明这个URL可以正常访问.(URL地址可能不准确,需要手动检查确认.)
         "
    fi

    ##-------------
    $ECHO "$I_(22).Portal服务检查$A_"
    $ECHO "$LI curl http://[name].passport.189.cn"
    $ECHO "
         将以上URL中[name]改为省份名称,然后在浏览器中访问,检查结果.
         "

    ##-------------
    $ECHO "$I_(23).账号经营系统检查$A_"
    $ECHO "$LI curl http://$IPADDR1:8080/udb-as/ -I"
    if [[ $LogAnalysisService = 0 ]];then
        $ECHO "
         ${HOSTNAME}_${IPADDR1} 无账号经营系统
         "
    else
        curl http://$IPADDR1:8080/udb-as/ -I --connect-timeout 2 2>/dev/null
        echo ""
        $ECHO "$LI curl http://$IPADDR1/udb-as/ -I"
        curl http://$IPADDR1/udb-as/ -I --connect-timeout 2 2>/dev/null
        echo ""
        $ECHO "$LI curl http://$IPADDR2:8080/udb-as/ -I"
        curl http://$IPADDR2:8080/udb-as/ -I --connect-timeout 2 2>/dev/null
        echo ""
    fi

    ##-------------
    $ECHO "$I_(24).日志数据库工作状态检查$A_"
    $ECHO "$LI ps -ef | grep mysql | grep -v grep"
    ps -ef | grep mysql | grep -v grep
    if [ $? -ne 0 ];then
        $ECHO "
         ${HOSTNAME}_${IPADDR1} 无MySQL服务运行"
    fi
    if [[ $LogAnalysisService = 0 ]];then
        $ECHO "
         ${HOSTNAME}_${IPADDR1} 无日志数据库
         "
    fi
};

function check_oracle_status {
    $ECHO "${I_}Oracle监听状态$A_"
    $ECHO "$OI lsnrctl status "
    su - oracle << EOF
    lsnrctl status
EOF
    if [ $? -ne 0 ];then
	$ECHO "
         检查oracle监听失败
         "
    fi

    su - oracle << EOF
    sqlplus -S "/ as sysdba"
    host sleep 1
    host $ECHO '${I_}Oracle实例状态$A_'
    host echo -e 'SQL> select instance_name,version,status,database_status from v\$instance;' | awk '{ printf "%s",\$0}'
    set linesize 300
    select instance_name,version,status,database_status from v\$instance;

    host sleep 1
    host $ECHO '${I_}Oracle是否启用归档模式$A_'
    host echo -e 'SQL> select name,log_mode,open_mode from v\$database;' | awk '{ printf "%s",\$0}'
    set linesize 100
    set pagesize 200
    select name,log_mode,open_mode from v\$database;

    host sleep 1
    host $ECHO '$I_检查Oracle会话状态$A_'
    host echo -e 'SQL> select count(*) from v\$session;' | awk '{ printf "%s",\$0}'
    select count(*) from v\$session;

    host sleep 1
    host $ECHO '$I_检查Oracle锁等待会话$A_'
    host echo -e 'SQL> select count(*) from v\$session where lockwait is not null;' | awk '{ printf "%s",\$0}'
    select count(*) from v\$session where lockwait is not null;

    host sleep 1
    host $ECHO '$I_检查Oracle控制文件状态$A_'
    host echo -e 'SQL> select * from v\$controlfile;' | awk '{ printf "%s",\$0}'
    select * from v\$controlfile;

    host sleep 1
    host $ECHO '$I_检查Oracle表空间状态$A_'
    host echo -e 'SQL> select tablespace_name,status from dba_tablespaces;' | awk '{ printf "%s",\$0}'
    select tablespace_name,status from dba_tablespaces;
    exit
EOF

    echo -e '\E[33m---------------------------------------- 检查Oracle数据库表空间 ----------------------------------------\E[0m'
    cat << EOF
SQL> select ff.s tablespace_name,
ff.b total,
              (ff.b - fr.b)usage,
fr.b free,
              round((ff.b - fr.b) / ff.b * 100) || '% ' usagep
from (select tablespace_name s, sum(bytes) / 1024 / 1024 b
                    from dba_data_files
                  group by tablespace_name) ff,
              (select tablespace_name s, sum(bytes) / 1024 / 1024 b
                    from dba_free_space
                  group by tablespace_name) fr
where ff.s = fr.s;
EOF

echo ""
su - oracle << EOF
sqlplus -S "/ as sysdba"
set linesize 500
set pagesize 200
select ff.s tablespace_name,
ff.b total,
              (ff.b - fr.b)usage, 
fr.b free, 
              round((ff.b - fr.b) / ff.b * 100) || '% ' usagep
from (select tablespace_name s, sum(bytes) / 1024 / 1024 b
                    from dba_data_files
                  group by tablespace_name) ff,
              (select tablespace_name s, sum(bytes) / 1024 / 1024 b
                    from dba_free_space
                  group by tablespace_name) fr
where ff.s = fr.s;
EOF
sleep 1
};

function test_oracle {
su - oracle <<EOF
lsnrctl show &>/dev/null
EOF
if [ $? -ne 0 ];then
    isora=no
else
    isora=yes
fi
};

function test_grid {
su - oracle <<EOF
lsnrctl show &>/dev/null
EOF
if [ $? -ne 0 ];then
    isgri=no
else
    isgri=yes
fi
};

function check_oracle {
    orac_use=`awk -F: '/oracle/{print $1}' /etc/passwd`
    grid_use=`awk -F: '/grid/{print $1}' /etc/passwd`
    $ECHO "$I_(25).Oracle数据库检查$A_\n"
    $ECHO "${I_}Oracle数据库进程$A_"
    $ECHO "$LI ps -ef | grep ora_"

    if [ "$orac_use" == "oracle" ];then
        test_oracle
        if [ "$isora" == no ];then
            $ECHO "
         ${HOSTNAME}_${IPADDR1} 没有Oracle数据库
         "
        else
           # $ECHO "$LI ps -ef | grep ora_"
            ora_pro=`ps -ef | grep ora_ | grep -v grep | wc -l`
            if [ $ora_pro -lt 3 ];then
                $ECHO "
                 ${HOSTNAME}_${IPADDR1} 没有检测到oracle数据库实例进程
                 "
            else
                ps -ef | grep ora_ | grep -v grep
                $ECHO "
         $M_
         Oracle数据库实例进程总数: $ora_pro
         $M_\n"
                check_oracle_status
            fi
        fi
    else
        $ECHO "
         ${HOSTNAME}_${IPADDR1} 没有Oracle数据库
         "
    fi

    if [ "$orac_use" == "oracle" -a "$grid_use" == "grid" ];then
        test_grid
        if [ "$isgri" == yes ];then
            $ECHO "
         $M_
         Oracle RAC集群环境
         $M_
         "
            $ECHO "${I_}Oracle RAC 集群状态检查$A_"
            $ECHO "$GI crs_stat -t -v"
            su - grid << EOF
            crs_stat -t -v
EOF
        fi
    fi

};

_main_sys_() {
    FOO
    HEAD
    check_os
    kernel_version
    tcp_connet
    cpu_status
    mem_status
    swap_status
    disk_status
    net_device
    cpu_top10
    mem_top10
    messages_error_log
}

_main_udb_() {
    check_udb
}

_main_ora_() {
    check_oracle
}

_main_() {
    rm -rf $Logfile
    echo -e "\n------\E[36m[System information]\E[0m------"
    echo -e "\n------\E[36m[系统巡检]\E[0m------"
    _main_sys_ >> $Logfile
    echo -e "\n------\E[36m[UDB巡检]\E[0m------"
    _main_udb_ >> $Logfile
    echo -e "\n------\E[36m[Oracle巡检]\E[0m------"
    _main_ora_ >> $Logfile
    echo ""
    echo "Check ok!"
};
_main_

    echo ""
    echo -e "The check log file is \E[32m${Logfile}\E[0m."
    echo -e "You can choose the option to view the check log. "
    PS3="Enter the option: "
    select option in "Cat" "Quit"
    do
    case $option in
        "Cat")
            cat ${Logfile} ;;
        "Quit")
            exit 0 ;;
    esac
    done
