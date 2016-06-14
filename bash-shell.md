<style>
img[alt=chmod] { width: 562px; }
</style>
####背景
目前大部分的开发同学使用都是Mac os，我们开发的程序也是部署在Linux机器上面，Mac os和Linux默认的Shell都是Bash shell。掌握好Bash shell常用的命令，无论是对于我们开发效率还是排查线上问题的效率都有不错的提升，而且还能写一些很有趣的shell脚本。
####常用命令
#####1. 基本操作(<font color=red>pwd ls cd man clear history</font>)
基本使用前的Tips：Bash Shell默认都是按<font color=red>Tab</font>键进行补全，当你输入的命令或路径过长时可使用<font color=red>Tab</font>键进行补全；方向键向上按键可调出上一个使用的命令。</br>
<font color=red>pwd</font>打印当前所在位置的完整路径。单独的<font color=red>ls</font>是列出当前的路径的文件列表，也可以在<font color=red>ls</font>后面指定要列出的目录或文件。常用的<font color=red>ls -al</font>，<font color=red>a</font>是列出所有文件包含隐藏文件，<font color=red>l</font>是列出文件的所有属性(文件的权限，文件的所有者等)。
在Mac os和linux中点开头的是隐藏文件，比如<font color=red>.atom</font>。![](/content/images/2016/06/1.png)
<font color=red>cd</font>是切换工作目录，<font color=red>cd</font>后面可以跟绝对路径也可以跟相对路径，相对路径是相对于当前的工作路径。常用<font color=red>cd ..</font>，返回上级目录；直接使用<font color=red>cd</font>，返回默认工作目录(Mac os和Linux会为每一个用户设置一个默认工作目录)。
![](/content/images/2016/06/2-2.png)
<font color=red>man</font>命令，Bash Shell提供了丰富的帮助手册，当你需要查看某个命令的参数时不必到处上网查找，只要<font color=red>man command</font>一下即可。比如<font color=red>man ls</font>，见下图。
![](/content/images/2016/06/3.png)
clear和history是两个辅助命令，clear是清空当前屏幕，history是查看命令的历史输入情况。
#####2. 对文件和文件夹操作(<font color=red>touch mkdir rm rmdir mv cp</font>)
<font color=red>touch</font>是创建一个文件，<font color=red>touch filename</font>。<font color=red>mkdir</font>是创建一个文件夹，<font color=red>mkdir dirname</font>。<font color=red>rm</font>是删除文件或文件夹，<font color=red>rm filename</font>删除文件,<font color=red>rm -r dirname</font>删除文件夹。<font color=red>rmdir</font>是删除文件作用和<font color=red>rm -r</font>一样。
![](/content/images/2016/06/4.png)
<font color=red>mv</font>是移动或者重命名文件或者文件夹，<font color=red>mv file1 file2</font>将file1重命名为file2，<font color=red>mv file1 dir1</font>将file1移动到dir1下，<font color=red>mv</font>还有文件夹移动和重命名，请自行尝试。<font color=red>cp</font>是复制文件或文件夹，<font color=red>cp file1 file2</font>将file1复制为file2，<font color=red>cp -r dir1 dir2</font>将文件夹dir1复制为文件夹dir2。
![](/content/images/2016/06/5.png)
#####3. 对文件或文件夹的权限进行操作(<font color=red>chmod</font>)
如下图所示，通过<font color=red>ls -al</font>我们可以看到文件的属主和权限。第一列<font color=red>-rwxr--r--</font>，第一位的<font color=red>-</font>表示file3是一个文件(第一位是<font color=red>d</font>代表是文件夹)，后面的九位分为三组（文件属主，用户所在组，其他用户）的读<font color=red>r</font>写<font color=red>w</font>执行<font color=red>x</font>的权限（如果对应没有权限则显示<font color=red>-</font>)。第三列lishuhong代表文件的属主。
![](/content/images/2016/06/6.png)
我们可以通过<font color=red>chmod</font>这个命令来改变文件的权限（下图是从网络上找的），<font color=red>u</font>代表文件属主，<font color=red>g</font>代表用户所在组，<font color=red>o</font>代表其他用户，<font color=red>a</font>代表所有(<font color=red>ugo</font>)。只有文件的属主和root用户，才能更改文件的权限。
![chmod](/content/images/2016/06/7.png)
即使你是文件的属主，但如果你设置了<font color=red>u</font>(文件属主)是没有读取的权限，读取文件时(<font color=red>cat</font>命令会在下面介绍)也会报错：权限不足。
![](/content/images/2016/06/8.png)
#####4. 查看和编辑文件内容(<font color=red>cat tail  head echo vim emacs</font>)
首先说一下重定向<font color=red>></font>，<font color=red>>></font>和管道<font color=red>|</font>。要想详细理解<font color=red>></font>，<font color=red>>></font>和<font color=red>|</font>需要完整的理解文件描述符，这边只是说一下如何使用<font color=red>></font>，<font color=red>>></font>和<font color=red>|</font>。一般命令的结果都是直接输出在屏幕上，我们可以使用<font color=red>></font>和<font color=red>>></font>将命令的结果重定向到文件中。也可以将上一个命令处理的结果通过管道<font color=red>|</font>传给下一个命令。
<font color=red>cat</font>是查看文件内容，<font color=red>cat</font>会将文件的个内容全部显示出来，对于大文件不建议使用<font color=red>cat</font>。<font color=red>tail</font>是从文件的尾部查看文件，常用<font color=red>tail -n filename</font>显示文件结尾的<font color=red>n</font>行，<font color=red>tail -nf filename</font>动态的显示文件的结尾<font color=red>n</font>行(查看Java程序的动态日志时，可采用此种方式)。<font color=red>head</font>表示从文件头部查看文件，和<font color=red>tail</font>相反，用法类似。
![](/content/images/2016/06/9.png)
<font color=red>echo</font>是输出变量或常量到屏幕，我们可以通过<font color=red>echo</font>加重定向完整简单的向文件输入内容。<font color=red>></font>是完全覆盖文件内容，<font color=red>>></font>是在文件的尾部追加内容。
![](/content/images/2016/06/10.png)
<font color=red>vim</font>编辑器命令，<font color=red>vim filename</font>进入<font color=red>vim</font>模式器模式，关于<font color=red>vim</font>有太多太多可说的了，这里只是提起一下，有想了解的请自行Google。<font color=red>emacs</font>同样可编辑文件，也请自行Google。如果你想成为有逼格有信仰的程序猿，请坚持使用<font color=red>vim</font>或<font color=red>emacs</font>作为编辑器。
#####5. 文件及文件夹查找(<font color=red>find</font>)
说<font color=red>find</font>命令前，简单说一下通配符<font color=red>\*</font>和<font color=red>?</font>，Bash Shell中很多的命令都支持通配符。<font color=red>\*</font>代表任意多个字符，<font color=red>?</font>代表一个字符。程序猿一直流传这样一个悲剧：某运维不小心执行了<font color=red>rm -rf /\*</font>，其实想执行的是<font color=red>rm -rf  \*</font>。
![](/content/images/2016/06/11.png)
<font color=red>find</font>命令使用方法众多，参数也非常多，这里面只说一些常用的方法。<font color=red>find  path -name "filename" -exec ls -l {} +</font>，在path路径下按文件名查找(会递归查找)，找到文件名为filename的文件后执行<font color=red>ls -l</font>。可将<font color=red>-name</font>换成<font color=red>-type</font>(按类型查找)，还有按修改时间查找<font color=red>-mtime</font>。如果不想进行递归查找，可加上<font color=red>-maxdepth 1</font>。
![](/content/images/2016/06/12.png)
#####6. 最强的三剑客(<font color=red>grep sed awk</font>)
这三个命令加上上面所说的管道以及重定向基本能满足你对文本处理的所有需求，这里简单介绍下三剑客几个常用的用法。<font color=red>grep</font>全称是Global Regular Expression Print，是一种强大的文本搜索工具，它能使用正则表达式搜索文本，并把匹配的行打印出来。<font color=red>grep -in 'findstring' filename</font>在文件中查找满足findstring的行且不区分大小写，打印满足的行号和行的内容。<font color=red>grep -E 'regex' filename</font>使用正则表达式搜索满足的行并打印出来<font color=red>。grep 'findstring' *</font>搜索当前路径下所有的文件，结果会打印满足行的文件名。<font color=red>grep -An -Bn 'findstring' filename</font>将满足行的前n行和后n行业打印出来，<font color=red>A</font>是after，<font color=red>B</font>是before。
![](/content/images/2016/06/13.png)
<font color=red>sed</font>是一种在线编辑器，它一次处理一行内容。处理时，把当前处理的行存储在临时缓冲区中，称为“模式空间”（pattern space），接着用<font color=red>sed</font>命令处理缓冲区中的内容，处理完成后，把缓冲区的内容送往屏幕。接着处理下一行，这样不断重复，直到文件末尾。<font color=red>文件内容并没有改变，但可以使用重定向存储输出到新的文件中</font>。<font color=red>sed '2d'  filename</font>删除文件第二行。<font color=red>sed '/test/d' filename</font>删除文件所有满足test的行。<font color=red>sed -n '1,/^test/p' filename</font>打印从第1行开始到第一个包含以test开始的行之间的所有行。<font color=red>sed 's/test/mytest/g' filename</font>在整行范围内把test替换为mytest。如果没有<font color=red>g</font>标记，则只有每行第一个匹配的test被替换成mytest。
![](/content/images/2016/06/14.png)
<font color=red>awk</font>严格来说也是一种编程语言，和c语言有很多相同之处，它能轻松的对文本进行处理和分析。<font color=red>awk -F '|' '{print $1}' filename</font>将文件中的每一行按照<font color=red>|</font>分隔并打印第一部分。<font color=red>F</font>指定以什么分隔，默认是空格。
![](/content/images/2016/06/15.png)
#####7. 系统信息及状态相关(<font color=red>ps top  kill mount uname ulimit</font>)
<font color=red>ps</font>监视当前系统进程运行情况，<font color=red>ps</font>是显示瞬间进程的状态，并不动态连续。<font color=red>ps -ef</font>显示全部进程的详细信息，<font color=red>e</font>所有进程，<font color=red>f</font>详细信息。
![](/content/images/2016/06/16.png)
<font color=red>top</font>命令提供了实时的对系统处理器的状态监视，它将显示系统中CPU最“敏感”的任务列表。该命令可以按CPU使用，内存使用和执行时间对任务进行排序；而且该命令的很多特性都可以通过交互式命令或者在个人定制文件中进行设定。重点关注Cpu，Mem(内存)，load average(负载)的情况。
![](/content/images/2016/06/17.png)
<font color=red>kill</font>用来终止指定进程的退出。<font color=red>kill pid</font>终止进程，<font color=red>kill -9 pid</font>强制终止进程，<font color=red>kill -3 pid</font>给进程一个sigquit信号量。<font color=red>kill -3 javapid</font>连续执行3到4次，可生成Java进程的Thread dump，作用和Java命令<font color=red>jstack</font>类似。特别注意对于Java进程来说如果使用<font color=red>kill -9</font>强制终止的话，ShutdownHook是不会执行的。在杀死进程的时候尽量直接使用<font color=red>kil</font>，不要使用<font color=red>kill -9</font>。
<font color=red>mount</font>命令用来查看磁盘挂载信息。<font color=red>uname</font>是显示当前操作系统信息，<font color=red>uname -a</font>显示操作系统全部信息。<font color=red>ulimit</font>用于shell启动进程所占用的资源，<font color=red>ulimit -a</font>查看所有资源信息。在linux中socket连接也是被看成文件句柄，如果程序碰到了<font color=red>java.net.SocketException: Too many open files</font>，可首先使用<font color=red>ulimit -n</font>查看单个进程能打开的最大句柄数是否设置过小，然后再对代码进行排查。
![](/content/images/2016/06/18.png)
#####8. 统计命令(<font color=red>df du wc</font>)
<font color=red>df</font>命令的功能是用来检查系统的磁盘空间占用情况。<font color=red>df -h</font>以方便阅读的方式展示结果，例如1K 234M 2G等，直接<font color=red>df</font>默认使用512字节为单位显示。我们有时候使用code打包部署的时候，有时候会<font color=red>java.io.IOException: No space left on device</font>，可以登录到机器上使用<font color=red>df -h</font>查看磁盘空间的使用情况，然后联系运维。
![](/content/images/2016/06/19.png)
<font color=red>du</font>是统计文件夹或文件的所占磁盘空间，<font color=red>du -sh dirname or filename</font>统计文件夹或文件所占磁盘空间，<font color=red>h</font>和<font color=red>df</font>命令的<font color=red>h</font>是一样的意思，<font color=red>s</font>是统计当前目录不递归列出子目录。注意点：<font color=red>du</font>能统计文件或文件夹所占磁盘空间的前提是，你对文件或文件夹有可访问的权限，不然会报权限不足。下图中com.adobe.flashplayer.installmanager.savedState这个文件夹可以看出lishuhong这个用户是没有权限访问的，所以报Permission denied。<font color=red>wc</font>统计指定文件的行数，单词数，字节数。下图中378是行数，400是单词数，12504是字节数。注意点：<font color=red>wc</font>命令只能对文件使用。
![](/content/images/2016/06/20.png)
####结束语
文章中基本上都是一些常用的命令和常用的用法，有兴趣的同学推荐看看鸟哥的linux私房菜。关于环境变量env以及profile的加载顺序及配置，这里就不介绍了。后续有时间会介绍一下shell脚本的编写，如何用shell脚本实现一些实用的功能。最后的最后，作为一个有信仰的键盘党和命令控，强烈安利一波mac下的神器iterm2+oh my zsh+autojump和alfred2，使用它们会让你的手指在键盘上飞起来，谁用谁知道。