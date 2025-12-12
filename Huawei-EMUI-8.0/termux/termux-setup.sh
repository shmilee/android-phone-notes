#!/data/data/com.termux/files/usr/bin/bash

export PREFIX=${PREFIX:-/data/data/com.termux/files/usr}
export PATH=$PREFIX/bin:$PATH
SDIR=$(dirname $0)


echo "==> 修改 motd ..."
cat > $PREFIX/etc/motd <<EOF
Yes,sir! Welcome to Termux!
EOF

echo "==> 使用 TUNA 镜像 ..."
MIRROR=https://mirrors.tuna.tsinghua.edu.cn/termux
cat > $PREFIX/etc/apt/sources.list <<EOF
# The main tremux repository:
#deb https://termux.net stable main
deb [arch=all,$(uname -m)] $MIRROR stable main
EOF
pkg update

echo "==> 安装软件 ..."
pkg install htop proot screenfetch

echo "==> 添加 git ..."
pkg install git
install -Dm644 "$SDIR"/dotfile/gitconfig $HOME/.gitconfig

echo "==> 添加 ssh ..."
pkg install gnupg openssh
ssh-keygen
install -Dm644 "$SDIR"/dotfile/ssh_config $HOME/.ssh/config

echo "==> 添加 python ..."
pkg install python
install -Dm644 "$SDIR"/dotfile/pip.conf $HOME/.pip/pip.conf
pip install ipython

echo "==> 添加 vim ..."
pkg install vim-python
install -Dm644 "$SDIR"/dotfile/vimrc $HOME/.vimrc

echo "==> 添加 zsh ..."
pkg install curl zsh
sh -c "$(curl -fsSL https://github.com/Cabbagec/termux-ohmyzsh/raw/master/install.sh)"

echo "==> 添加 mpv-android ..."
pkg install coreutils ffmpeg
pip install you-get
install -Dm755 "$SDIR"/bin/mpv-android $PREFIX/bin/mpv-android

rm -rf $HOME/termux-ohmyzsh/
rm -rf $HOME/.cache/
echo "==> Done."
