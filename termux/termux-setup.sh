#!/data/data/com.termux/files/usr/bin/bash

export PREFIX=${PREFIX:-/data/data/com.termux/files/usr}
SDIR=$(dirname $0)

echo "==> 0.更新 ..."
pkg upgrade

echo "==> 1.修改 motd ..."
cat > $PREFIX/etc/motd <<EOF
Yes,sir! Welcome to Termux!
EOF

echo "==> 2.安装软件 ..."
pkg install htop proot neofetch git gnupg openssh python-pip vim zsh

echo "==> 3.配置 git, ssh, python-pip, vim ..."
install -Dm644 "$SDIR"/dotfile/gitconfig $HOME/.gitconfig
ssh-keygen
install -Dm644 "$SDIR"/dotfile/ssh_config $HOME/.ssh/config
install -Dm644 "$SDIR"/dotfile/pip.conf $HOME/.pip/pip.conf
pip install ipython
install -Dm644 "$SDIR"/dotfile/vimrc $HOME/.vimrc

echo "==> 4.配置 oh-my-zsh ..."
sh -c "$(curl -fsSL https://github.com/Cabbagec/termux-ohmyzsh/raw/master/install.sh)"

rm -rf $HOME/termux-ohmyzsh/
rm -rf $HOME/.cache/
echo "==> Done."
