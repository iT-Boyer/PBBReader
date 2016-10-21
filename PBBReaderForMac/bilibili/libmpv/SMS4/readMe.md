1. 在mpv中新增方法，需要通过mpv-build/mpv/libmpv/mpv.def来声明，才会生效
release_key
set_key_info

2. 把SMS4.h／pbb_key.h 添加到目录mpv-build/mpv/stream ，同时合并同目录的strem_file.c
