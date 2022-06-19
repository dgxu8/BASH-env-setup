sudo apt install libevent-dev
sudo apt install libncurses5-dev

tar -zxf tmux-*.tar.gz
cd tmux-*/
./configure
make && sudo make install
cd ..
