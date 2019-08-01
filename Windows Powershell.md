[toc]
# Windows PowerShell
## 基础概念
### Cmdlet(命令)
```
PS C:\Users\Administrator> Get-Service          ----Cmdlet
Status   Name               DisplayName                           
------   ----               -----------                           
Running  360rp              360 杀毒实时防护加载服务                        
Stopped  AdobeARMservice    Adobe Acrobat Update Service          
```
### 参数以及实参
```
PS C:\Users\Administrator> Get-Service -Name alg
Status   Name               DisplayName                           
------   ----               -----------                           
Stopped  alg                Application Layer Gateway Service  

Cmdlet都有参数和实参
cmdlet          parameter   actual parameter
Get-Service     Name        alg

必须参数：[-Parameter] <Type>		-name <string>
可选参数：[-Parameter <Type>]		[-name <string>]
开关参数：[- Parameter <Type> []]	[-name <string> []]
```
### 管道
使用管道将命令结果在不同命令之间传递(命令结果一个一个传递)
```
PS C:\Users\Administrator> Get-Service -Name ALG
Status   Name               DisplayName                           
------   ----               -----------                           
Stopped  ALG                Application Layer Gateway Service     

PS C:\Users\Administrator> Get-Service -Name ALG |Start-Service
```

### Object(对象)
1. 类：  
类就是对一组具有相同属性和方法的对象的一个抽象，简单说就是一个概念，比如“女神”就是一个类
2. 对象：  
对象就是类的一个实例，简单说就是一个真实存在的实物，是一个具体的东西了，比如女神林志玲
3. 属性：  
属性就是对象的特征，是名词，比如上面的女神都有身高、体重、姓名、年龄和三围等。林志玲，43和保密。
4. 方法：  
方法就是对象的行为，是动词或动名词  
林姐姐有游泳、跑步和拍广告等方法。    

**Powershell对象=属性+方法**  
在现实世界中，你可能已经了解对象就是那些能够摸到的东西。Powershell中的对象和现实生活很相似。例如要在现实生活中描述一把小刀。我们可能会分两方面描述它  
***属性***：一把小刀拥有一些特殊的属性，比如它的颜色、制造商、大小、刀片数。这个对象是红色的，重55克，有3个刀片，ABC公司生产的。因此属性描述了一个对象是什么。  
***方法***：可以使用这个对象做什么，比如切东西、当螺丝钉用、开啤酒盖。一个对象能干什么就属于这个对象的方法。  
#### 属性(Property)
属性用于描述对象特性
- 调用属性 Object.Property

#### 方法(Memthod)
方法是对象行为的实现
- 调用方法 Object.Memthod()

#### 类型
- System.Init32
- System.String
- System.boolean
- System.Collection.Hastable
```
PS C:\Users\Administrator> Get-Service -Name alg    ----对象
Status   Name ---属性       DisplayName  ----属性                         
------   ----               -----------                           
Stopped  alg                Application Layer Gateway Service

PS C:\Users\Administrator> Get-Service -Name alg |Get-Member
   TypeName:System.ServiceProcess.ServiceController  ----类型
Name                      MemberType    Definition                                           
----                      ----------    ----------                                          
Name                      AliasProperty Name = ServiceName                               
RequiredServices          AliasProperty RequiredServices = ServicesDependedOn      
Disposed                  Event         System.EventHandler Disposed(System.Object, System.EventArgs)
Close                     Method(方法)  void Close()                                            
Equals                    Method        bool Equals(System.Object obj)                                       
Refresh                   Method        void Refresh()
Start                     Method        void Start(), void Start(string[] args) 
Stop                      Method        void Stop()
CanPauseAndContinue       Property(属性)bool CanPauseAndContinue {get;}
CanShutdown               Property      bool CanShutdown {get;} 
CanStop                   Property      bool CanStop {get;}
```

#### 对象的使用
```
PS C:\Users\Administrator> Get-Service -Name alg

Status   Name               DisplayName                           
------   ----               -----------                           
Stopped  alg                Application Layer Gateway Service 

PS C:\Users\Administrator> Get-Service -Name alg |Get-Member
   TypeName:System.ServiceProcess.ServiceController
Name                      MemberType    Definition                                                          
----                      ----------    ----------                                                          
Name                      AliasProperty Name = ServiceName                                                  
RequiredServices          AliasProperty RequiredServices = ServicesDependedOn                               
Disposed                  Event         System.EventHandler Disposed(System.Object, System.EventArgs)       
Close                     Method        void Close()                                                        
Continue                  Method        void Continue()                                                     
CreateObjRef              Method        System.Runtime.Remoting.ObjRef CreateObjRef(type requestedType)
Dispose                   Method        void Dispose(), void IDisposable.Dispose()
Equals                    Method        bool Equals(System.Object obj)            

PS C:\Users\Administrator> Get-Service -Name alg |Select-Object *
Name                : alg
RequiredServices    : {}
CanPauseAndContinue : False
CanShutdown         : False
CanStop             : False
DisplayName         : Application Layer Gateway Service
DependentServices   : {}
MachineName         : .
ServiceName         : alg
ServicesDependedOn  : {}
ServiceHandle       : 
Status              : Stopped
ServiceType         : Win32OwnProcess
StartType           : Manual
Site                : 
Container           : 

PS C:\Users\Administrator> (Get-Service -Name alg).Status
Stopped

PS C:\Users\Administrator> (Get-Service -Name alg).status |Select-Object *
value__
-------
      1

PS C:\Users\Administrator> Get-Service |Where-Object {$_.name -like "*lg*"}
Status   Name               DisplayName                           
------   ----               -----------                           
Stopped  ALG                Application Layer Gateway Service     
Stopped  XblGameSave        Xbox Live 游戏保存 
```
### foreach的使用
```
PS C:\Users\Administrator> Get-LocalUser |ForEach-Object {$_.name}
Administrator
DefaultAccount
defaultuser0
Guest
WDAGUtilityAccount

$services=Get-Service
foreach ($service in $services)
{
    $service.name
    $service.start()
}
```
### for循环
```
for ($i=0;$i -le 99;$i++)
{
    $i
}
```
### 数组的定义
```
$array = "a","b","c"  
$array = @("a","b","c")  
$array.Count 数组元素个数

数组和for的套用
$array = "a","b","c" 
for ($i=0;$i -le 99;$i++)
{
    $array[$i]
}
```
### if判断
```
$service=Get-Service -Name alg
if($service.status -eq "Stopped")
{
    $Host.UI.WriteDebugLine("Stopped")
}
else
{
    $service.Stop()
}
```
### 自动变量
- $_
- $?    上一条命令是否执行完成
- $^    上一条命令
- $Error
    - $Error[0].Exception
- $Ture
- $Env: 环境变量
- $PSScriptRoot 当前脚本所在的目录
- $HOME 当前用户家目录

### 远程操作
- NT6.1,6.2 2008R2
    - WinRM默认不开启
- NT6.3 2012R2,Win8.1
    - WinRM Server默认开启，client默认不开启
- 首次建立链接
    - 通过HTTP/HTTPS建立连接
    - 开启服务
    - 注册侦听器(HTTP 5985/HTTPS 5986  _WSMAN的前缀)
```
PowerShell开启WinRM服务，启用远程管理

Enable-PSRemoting -Force
Set-WSManQuickConfig -force
Enable-WSManCredSSP -Role Server -Force
Set-NetFirewallProfile -All -Enabled False

如果clent端没有在域环境中,则需要额外的操作：
server端：
查看本地信任列表
PS C:\Windows\system32> Get-ChildItem WSMan:\localhost\Client\TrustedHosts
   WSManConfig:Microsoft.WSMan.Management\WSMan::localhost\Client
Type            Name                           SourceOfValue   Value
----            ----                           -------------   -----
System.String   TrustedHosts                                   192.168.1.11 

Set-Item wsman:\localhost\client\trustedhosts -Value 192.168.1.11
Restart-Service WinRM

测试通信：
Test-WsMan xxx.xxx.xxx.xxx

这种方式需要手工输入密码，不是很方便，我们只需要将这些用户名密码参数化就可以实验脚本化登录了：
$Username = '*********'
$PWD = '********'
$pass = ConvertTo-SecureString -AsPlainText $PWD -Force
$Cred = New-Object System.Management.Automation.PSCredential -ArgumentList $Username,$pass
Invoke-Command -ComputerName 10.112.20.84 -ScriptBlock { iisreset } -credential $Cred
```
#### 远程执行的两种方法：
```
Get-Service -Name ALG -ComputerName 192.168.1.11
Invoke-Command -ComputerName 192.168.1.11 -ScriptBlock {Get-Service -Name alg} -Credential administrator
```
##### 案例：
- 安装IIS
```
$server="192.168.1.11","192.168.1.12"
foreach ($i in $server)
{
#   Add-WindowsFeature -Name web-server -IncludeAllSubFeature -IncludeManagementTools -Restart -ComputerName $i -Credential administrator
    Invoke-Command -ComputerName $i -ScriptBlock {Add-WindowsFeature -Name web-server -IncludeAllSubFeature -Restart} -Credential administrator
}

Success Restart Needed Exit Code      Feature Result                                PSComputerName
------- -------------- ---------      --------------                                --------------
True    No             Success        {IIS 可承载 Web 核心, 管理服务, FTP Service, IIS 管理... 192.168.1.11
True    No             Success        {IIS 可承载 Web 核心, 管理服务, FTP Service, IIS 管理... 192.168.1.12
```
- 永久会话
```
PS C:\Windows\system32> Enter-PSSession -ComputerName 192.168.1.11 -Credential administrator
[192.168.1.11]: PS C:\Users\Administrator\Documents> 
```
- 使用Session远程
```
[192.168.1.11]: PS C:\> Enter-PSSession -ComputerName 192.168.1.11 -Credential administrator
[192.168.1.11]: PS C:\> Get-WindowsFeature |Where-Object {$_.name -like "*fail*"}
Display Name                                            Name                   
------------                                            ----                   
[ ] 故障转移群集   Failover-Clustering
```
```
$session=New-PSSession -ComputerName "192.168.1.11","192.168.1.12" -Credential administrator

Measure-Command {
    Invoke-Command -Session $session -ScriptBlock {Add-WindowsFeature -Name Failover-Clustering -IncludeAllSubFeature -Restart}
}
```
### 函数  
#### 函数基础
**标准函数**
```
function 函数名
{
    Param       #参数
    ()
    Begin       #接受参数的传递(只执行一次)
    ()
    Process     #重复(输入的参数的个数) Process 你真正执行的东西
    ()
    End         #只执行一次(完全看个人需求。记录日志，只显示调试信息，详细信息，警告)
    ()
}
```
***示例1：***
```
Function A123
{
    Param
    ( $A1 )
    Begin
    {
    Write-Host Begin
    $A1.count 
    }
    Process
    {
    Write-Host Process
    foreach($1 in $A1)
        {
            $1
        }
    }
    End
    { 
    Write-Host End
    $A1 |Out-File C:\1.txt 
    }
}
```
***示例2：***
```
Function SystemLog
{
    Param
    (
    $ComputerName
    )
    Get-EventLog -LogName System -Newest 3 -ComputerName $ComputerName
}
```
```
PS C:\Windows\system32> function SystemLog
{
    Param
    (
    $ComputerName
    )
    Get-EventLog -LogName System -Newest 3 -ComputerName $ComputerName
}
 
PS C:\Windows\system32> SystemLog -ComputerName 192.168.1.254
   Index Time          EntryType   Source                 InstanceID Message
   ----- ----          ---------   ------                 ---------- -------
   10079 7月 21 16:41   Information Service Control M...   1073748860 Windows Update 服务处于 停止 状态。
   10078 7月 21 16:39   Information Service Control M...   1073748860 Microsoft Storage Spaces SMP 服务处于 停止 状态。
   10077 7月 21 16:36   Information Service Control M...   1073748860 Remote Registry 服务处于 正在运行 状态。
```

***示例3：***  
*如果什么都不写，默认全被视为End块*
```
function Disk
{
    Get-Disk
}
```
```
PS C:\Windows\system32> function Disk
{
    Get-Disk
}
PS C:\Windows\system32> Disk
Number Friendly Name                                                                                      Serial Number                    HealthStatus         OperationalStatus      Total Size Partition 

Style     
------ -------------                                                                                      -------------                    ------------         -----------------      ---------- ----------
0      AVAGO MR9361-8i                                                                                    002d590c0557130000e0da840bb00506 Healthy              Online                    2.18 TB MBR       PS   
```

#### 函数高级功能
```
function 函数名
{
  [CmdletBinding(ConfirmImpact=<String>,
             DefaultParameterSetName=<String>,
             HelpURI=<URI>,
             SupportsPaging=<Boolean>,
             SupportsShouldProcess=<Boolean>,
             PositionalBinding=<Boolean>)]

  Param ($Parameter1)
  Begin{}
  Process{}
  End{}
}
```


- 命令等级(ConfirmImpact)：
```
PS C:\Windows\system32> $ConfirmPreference(当前环境等级)
High
ConfirmImpact=[System.Management.Automation.Confirmimpact]::High
命令中的确认等级为高。
当命令中的确认等级大于或者等于当前环境中的确认等级，运行命令时会发生警告。
```
```
function 函数名
{
  [CmdletBinding(ConfirmImpact=[System.Management.Automation.Confirmimpact]::High)]
  Param ($Parameter1)
  Begin{}
  Process{}
  End{}
}
```

- 默认参数集(DefaultParameterSetName)
```
Param
  (
    [parameter(Mandatory=$true,             # 参数是否必须          <控制参数行为>
               ValueFromPipeline=$true)     # 参数是否接受管道输入
               ParameterSetName="Computer"]   #参数集名字
               Position=1               #控制参数的位置
               HelpMessage="help 1"     #用于帮助或者注释
    [Alias(p3)]                         #参数别名
    [ValidateCount("abc","def")]        #固定参数
    [String[]]                  <控制参数类型>
    $ComputerName
  )
```
```
function get-test
{
    [CmdletBinding(DefaultParameterSetName="ByUserName")]
    param
    (
        [Parameter(Mandatory=$true,
                   ValueFromPipeline=$true,
                   ParameterSetName="ByComputerName",Position=1，
                   HelpMessage="help 1"
        )]
        $par1,
        [Parameter(Mandatory=$true,ParameterSetName="ByUserName",Position=1，HelpMessage="help 2")]
        $par2
        [Parameter(Mandatory=$true)]
        [Alias(p3)]
        [ValidateSet("abc","def")]
        $par3
    )
    begin
    {}
    process
    {
        if($PSCmdlet.ParameterSetName -eq "ByComputerName")
            {
            Write-Host "ByComputerName"         #不同数集执行的不同语句
            $par1
            }
        if($PSCmdlet.ParameterSetName -eq "ByUserName")
            {
            Write-Host "ByUserName"         #不同数集执行的不同语句
            $par2
            }
    }
    end
    {}
}

PS C:\Windows\system32> get-test -par1 1
ByComputerName
1

PS C:\Windows\system32> get-test -par2 2
ByUserName
2

PS C:\Windows\system32> get-test 1
ByUserName
1

PS C:\Windows\system32> get-test -par1 1 -p3 abc
ByComputerName
1

PS C:\Windows\system32> get-test
位于命令管道位置 1 的 cmdlet get-test
请为以下参数提供值:
(键入 !? 以查看帮助。)
par2: !?
help 2
par2: ada
ByUserName
ada
```
### 模块
```
<#
.Synopsis
    更改用户属性
.DESCRIPTION
    此命令用于更改活动目录用户的属性
.EXAMPLE
    PS C:\Users\Administrator> set-jcxuser -UserDN CN=jcx2 -PathDN "OU=jcx,DC=jcx,DC=com" -Properties Description -PropertieValue 123456

    确认是否确实要执行此操作?
    正在目标“CN=jcx2”上执行操作“更改属性:Description更改为123456”。
    [Y] 是(Y)  [A] 全是(A)  [N] 否(N)  [L] 全否(L)  [S] 挂起(S)  [?] 帮助 (默认值为“Y”): y

    distinguishedName : {CN=jcx2,OU=jcx,DC=jcx,DC=com}
    Path              : LDAP://WIN-2MCU4UVOCKN.jcx.com/CN=jcx2,OU=jcx,DC=jcx,DC=com

.INPUTS
    System.string
.OUTPUTS
    DirectoryServices.DirectoryEntry
.NOTES
    一般注释
.COMPONENT
    此 cmdlet 所属的组件
.ROLE
    此 cmdlet 所属的角色
.FUNCTIONALITY
    最准确描述此 cmdlet 的功能
.Parameter UserDN
    用户的DN表示
    CN=jcx1
#>

function set-jcxuser
{
    [Cmdletbinding(SupportsShouldProcess=$true,Confirmimpact=[System.Management.Automation.ConfirmImpact]::High)]
    param
    (
        [parameter(Mandatory=$true)]
        [ValidatePattern("[C][N][=][0-9a-z]")]
        [string]$UserDN,
        [parameter(Mandatory=$true)]
        [string]$PathDN,
        [parameter(Mandatory=$true)]
        [string]$Properties,
        [parameter(Mandatory=$true)]
        [string]$PropertieValue,
        [string]$Server
    )
    begin
    {}
    process
    {
        if($PSCmdlet.ShouldProcess($UserDN,"更改属性:"+$Properties+"更改为"+$PropertieValue))
        {
            if($Server)
            {
                $PSCmdlet.WriteVerbose("使用用户输入构造LADPString")
                $LADPString="LDAP://"+$Server+"/"+$PathDN
            }
            else
            {
                $PSCmdlet.WriteVerbose("自动发现DC构造LADPString")
                $DefaultDomain=[System.DirectoryServices.ActiveDirectory.DirectoryContextType] ([System.DirectoryServices.ActiveDirectory.DirectoryContextType]::Domain);
                $DefaultDC=[System.DirectoryServices.ActiveDirectory.DomainController]::FindOne($DefaultDomain,[System.DirectoryServices.ActiveDirectory.LocatorOptions]::WriteableRequired)
                $LADPString="LDAP://"+$DefaultDC.Name+"/"+$PathDN
            }
            $PSCmdlet.WriteVerbose("初始化DirectoryEntry")
            $Entry=New-Object System.DirectoryServices.DirectoryEntry("$LADPString")
            $PSCmdlet.WriteVerbose("查找用户")
            $User=$Entry.Children.Find("$UserDN","User")
            $PSCmdlet.WriteVerbose("修改属性")
            $User.$Properties.value=$PropertieValue
            $PSCmdlet.WriteVerbose("提交修改")
            $User.CommitChanges()
        }
    }
    end
    {
        $PSCmdlet.WriteObject($User)
    }
}
```
- 模块文件：将函数另存为.psm1结尾的文件。
- 模块描述文件：
    - 命令：New-ModuleManifest
    - -Path：模块存放路径
    - -Author：作者名
    - -CompanyName：公司名
    - -Copyright：版权信息
    - -FileList：此模块内包含的psm1文件或者其他应该包含的文件
    - -ModuleList：与此模块相关的其他模块
    - -CmdletsToExport：此模块到处的命令
```
PS C:\> New-ModuleManifest -Path 'C:\Users\Administrator\Desktop\jcxuser\jcxuser.psd1' -Author jichengxi -CompanyName jcx -Copyright "2019 (R) tiancheng" -FileList "jcxuser.psm1" -CmdletsToExport "set-jcxuser"

PS C:\> Test-ModuleManifest -Path 'C:\Users\Administrator\Desktop\jcxuser\jcxuser.psd1'

ModuleType Version    Name                                ExportedCommands
---------- -------    ----                                ----------------
Manifest   1.0        jcxuser                             set-jcxuser 
```

> Windows PowerShell模块放置在C:\Windows\System32\WindowsPowerShell\v1.0\Modules下,模块的文件夹名要和模块名一致，模块文件和模块描述文件要在一个文件夹内。
> - 模块文件：以.psm1结尾
> - 模块描述文件：以.psd1结尾，要和主模块文件文件名一致

### Desired State Configuration
- 查看系统当前已经有的DscResource
```
PS C:\Users\Administrator> Get-DscResource

ImplementedAs   Name                      Module                         Properties
-------------   ----                      ------                         ----------
Binary          File                                                     {DestinationPath, Attributes, Checksum, Content...
PowerShell      Archive                   PSDesiredStateConfiguration    {Destination, Path, Checksum, DependsOn...}       
PowerShell      Environment               PSDesiredStateConfiguration    {Name, DependsOn, Ensure, Path...}                
PowerShell      Group                     PSDesiredStateConfiguration    {GroupName, Credential, DependsOn, Description...}
Binary          Log                       PSDesiredStateConfiguration    {Message, DependsOn}、
PowerShell      Package                   PSDesiredStateConfiguration    {Name, Path, ProductId, Arguments...}             
PowerShell      Registry                  PSDesiredStateConfiguration    {Key, ValueName, DependsOn, Ensure...}            
PowerShell      Script                    PSDesiredStateConfiguration    {GetScript, SetScript, TestScript, Credential...} 
PowerShell      Service                   PSDesiredStateConfiguration    {Name, BuiltInAccount, Credential, DependsOn...}  
PowerShell      User                      PSDesiredStateConfiguration    {UserName, DependsOn, Description, Disabled...}
PowerShell      WindowsFeature            PSDesiredStateConfiguration    {Name, Credential, DependsOn, Ensure...}
PowerShell      WindowsProcess            PSDesiredStateConfiguration    {Arguments, Path, Credential, DependsOn...}
```
- 查看一个DscResoure所拥有的属性
```
PS C:\Users\Administrator> (Get-DscResource -Name File).Properties
Name                                     PropertyType                                                          IsMandatory Values                                  
----                                     ------------                                                          ----------- ------                                  
DestinationPath                          [string]                                                                     True {}                                      
Attributes                               [string[]]                                                                  False {Archive, Hidden, ReadOnly, System}     
Checksum                                 [string]                                                                    False {CreatedDate, ModifiedDate, SHA-1, SH...
Contents                                 [string]                                                                    False {}                                      
Credential                               [PSCredential]                                                              False {}                                      
DependsOn                                [string[]]                                                                  False {}                                      
Ensure                                   [string]                                                                    False {Absent, Present}                       
Force                                    [bool]                                                                      False {}
MatchSource                              [bool]                                                                      False {}                                      
Recurse                                  [bool]                                                                      False {}                                      
SourcePath                               [string]                                                                    False {}                                      
Type                                     [string]                                                                    False {Directory, File}             
```
***示例***
```
Configuration TouchFile
{
    param
    (
        [string[]]$computer
    )
    node $computer
    {
        File newfile
        {
           DestinationPath = "c:\123.html"
           Contents = "123"
           Type = "File"
        }
    }
}
```
```
PS C:\Users\Administrator> get-help TouchFile
名称
    TouchFile
语法
    TouchFile [[-InstanceName] <string>] [[-OutputPath] <string>] [[-ConfigurationData] <hashtable>] [[-computer] <string[]>]     
别名
    无
备注
    无

PS C:\> TouchFile -computer 127.0.0.1
    目录: C:\TouchFile
Mode                LastWriteTime     Length Name
----                -------------     ------ ----
-a---          2019/8/1     21:39       1210 127.0.0.1.mof

PS C:\> Start-DscConfiguration -Path C:\TouchFile
Id     Name            PSJobTypeName   State         HasMoreData     Location             Command
--     ----            -------------   -----         -----------     --------             -------
16     Job16           Configuratio... Running       True            127.0.0.1,192.168... Start-DscConfiguration...
```




