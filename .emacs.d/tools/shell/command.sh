
# 指定以外のファイルを削除
ls | grep -v -G '27.krn$' | xargs rm

# 検索して並び替え
ls -lt `find save/2014/04/ -name "1000.krn"`

# 指定文字列を含むファイル検索 行番号表示
find /var/www/TASK/fuel/app/modules/vis/tasks/ -type f -name "*.php" | xargs grep -n "set_krn"
# fuelphp core
find /var/www/TASK/fuel/core/ -type f -name "*.php" | xargs grep -n "error_info"
