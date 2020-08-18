# 使用前可以先手动安装工具,提升速度
# 由于GrowingIOTest链接工程较多,费事较长
# //1. 先拉下专案
# brew tap growingio/homebrew-oclint
# //2. 然后安装库
# brew install oclint-growing
# //3. gem install xcpretty

# 关于检测结果，最终可以过滤 GrowingIOCodeChecker 来查看检测的错误

export HOMEBREW_NO_AUTO_UPDATE=true
export LC_ALL=en_US.UTF-8
export LANG=en_US.UTF-8

# 0. 检测brew工具
if which brew 2>/dev/null; then
echo 'brew already installed'
else # install oclint
echo 'brew not install,exit!'
exit 0;
fi

# 如果没有安装最好翻墙，不然会很慢
# 1. 环境配置，判断是否安装oclint-growing，没有则安装
if which oclint 2>/dev/null; then
echo 'oclint-growing already installed'
else # install oclint
brew tap growingio/homebrew-oclint
brew install oclint-growing
fi

# 2. 环境配置，判断是否安装xcpretty，没有则安装
if which xcpretty 2>/dev/null; then
echo 'xcpretty already installed'
else
echo 'xcpretty need permissions,please enter sudo gem install xcpretty in your terminal,exit!'
exit 0;
fi


unset LLVM_TARGET_TRIPLE_SUFFIX

RootDir=${SRCROOT}/../

cd ${RootDir}

COMPILE_JSON=${RootDir}/../compile_commands.json

echo "==== json file : $COMPILE_JSON ===="

if [[ -f $COMPILE_JSON ]]; then
    #statements
    echo "remove $COMPILE_JSON"
    rm -r $COMPILE_JSON
    
fi

#echo "[]" > $COMPILE_JSON
echo "==== Root Path : ${RootDir} ===="
# 生成编译配置文件，oclint使用clang分析的话，需要知道编译环境，这里就是生成编译环境的一个环节
# 1.workspace的编译
xcodebuild -workspace GrowingAnalytics.xcworkspace -scheme Example -configuration Release -sdk iphonesimulator -arch x86_64 clean build | xcpretty -r json-compilation-database -o compile_commands.json


# 2.默认target编译
#xcodebuild clean
#xcodebuild COMPILER_INDEX_STORE_ENABLE=NO | xcpretty -r json-compilation-database --output compile_commands.json
echo "==== start xcpretty ===="

echo "==== oclint-json-compilation-database start ===="

oclint-json-compilation-database -e Pods -- -report-type xcode -rc GIO_METHOD_ALLOW_UPPERCASE="URL,FMG3DB,TXT,UTF,STM,IMP" -rc GIO_CATEGORY_PREFIX=Growing -rc GIO_CLASS_PREFIX=Growing -max-priority-2=0
